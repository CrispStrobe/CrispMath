import 'package:crisp_math/engine/calculator_engine.dart';
import 'package:crisp_math/engine/notepad.dart';
import 'package:crisp_math/engine/notepad_evaluator.dart';
import 'package:crisp_math/engine/polynomial.dart';
import 'package:crisp_math/services/engine_dispatch.dart';
import 'package:crisp_math/services/engine_op.dart';
import 'package:crisp_math/services/integral_arguments.dart';
import 'package:crisp_math/services/notepad_dispatcher.dart';
import 'package:flutter_test/flutter_test.dart';

// Strict single-monomial grammar keeps grouping and integration constants.
// Only a leading rational coefficient may have its parentheses removed.
String? _canonicalMonomial(String source) {
  var text = source.replaceAll(' ', '').replaceAll('**', '^')
      .replaceAll('²', '^2').replaceAll('³', '^3');
  text = text.replaceAllMapped(
      RegExp(r'^\(([+-]?\d+/\d+)\)(?=\*?x\^)'), (match) => match[1]!);
  final first = RegExp(r'^([+-]?\d+)(?:/(\d+))?\*?x\^([23])(\+C)?$')
      .firstMatch(text);
  if (first != null) {
    final coefficient = Rational(BigInt.parse(first[1]!),
        BigInt.parse(first[2] ?? '1'));
    return '$coefficient*x^${first[3]}${first[4] ?? ''}';
  }
  final last = RegExp(r'^([+-]?\d+)?\*?x\^([23])(?:/(\d+))?(\+C)?$')
      .firstMatch(text);
  if (last == null) return null;
  final coefficient = Rational(BigInt.parse(last[1] ?? '1'),
      BigInt.parse(last[3] ?? '1'));
  return '$coefficient*x^${last[2]}${last[4] ?? ''}';
}

void _expectMonomial(String actual, String reference) {
  final normalized = _canonicalMonomial(actual);
  expect(normalized, isNotNull, reason: 'Unsupported monomial notation: $actual');
  expect(normalized, _canonicalMonomial(reference));
}

NotepadDocument _document(List<String> sources) =>
    NotepadDocument.fresh(name: 'Solve scope controls')
      ..lines.clear()
      ..lines.addAll(sources.map((source) => NotepadLine.fresh(source: source)));

NotepadEvaluator _evaluator(List<EngineOp> routed) {
  final engine = CalculatorEngine();
  final dispatcher = NotepadDispatcher(
      engine: engine,
      yieldLocalWork: false,
      formatNumber: (value) => value,
      runOperation: (op) async {
        routed.add(op);
        return runEngineOp(engine, op);
      },
      runDetailedOperation: (op) async {
        routed.add(op);
        return runEngineOpDetailed(engine, op);
      },
      evaluateExpression: (source) async => engine.evaluate(source),
      evaluateDetailedExpression: (source) async =>
          runEngineOpDetailed(engine, EngineOp('evaluate', source)));
  return NotepadEvaluator(
      dispatcher: dispatcher.evaluate,
      detailedDispatcher: dispatcher.evaluateDetailed);
}

void main() {
  test('monomial assertions accept equivalent coefficients and preserve grouping',
      () {
    for (final source in ['1/3x^3+C', '(1/3)*x³ + C', 'x^3/3+C']) {
      _expectMonomial(source, 'x^3/3+C');
    }
    for (final source in ['2/3x^3+C', '(2/3)*x³+C', '2*x^3/3+C']) {
      _expectMonomial(source, '2*x^3/3+C');
    }
    expect(_canonicalMonomial('x^3/(3+C)'), isNull);
    expect(_canonicalMonomial('(x^3+C)/3'), isNull);
    expect(_canonicalMonomial('x^3/3'),
        isNot(_canonicalMonomial('x^3/3+C')));
    expect(_canonicalMonomial('2*x^3/3+C'),
        isNot(_canonicalMonomial('x^3/3+C')));
    expect(_canonicalMonomial('x^2/3+C'),
        isNot(_canonicalMonomial('x^3/3+C')));
  });
  test('real worksheet solve shadows a global variable and routes its declaration',
      () async {
    final routed = <EngineOp>[];
    final doc = _document(['x=9', 'solve(x^2-1,x)']);
    expect(buildDependencyGraph(doc).dependsOn[1], isEmpty);
    final evaluator = _evaluator(routed);
    await evaluator.evaluateAll(doc);
    expect(doc.lines.last.cachedError, isNull);
    expect(doc.lines.last.cachedResult,
        isIn(['x = {-1, 1}', 'x = {1, -1}']));
    expect(doc.lines.last.cachedFreeVars, isEmpty);
    expect(routed.last.kind, 'solve');
    expect(routed.last.arg2, 'x');
    expect(routed.last.arg1, contains('x'));
    doc.lines.first.source = 'x=100';
    await evaluator.evaluateFrom(doc, 0);
    expect(doc.lines.last.cachedResult,
        isIn(['x = {-1, 1}', 'x = {1, -1}']));
  });

  test('reported rational worksheet solve binds x and preserves exclusions',
      () async {
    final doc = _document(['x=9', 'solve((x-1)/(x+2)-2,x)']);
    await _evaluator([]).evaluateAll(doc);
    expect(doc.lines.last.cachedError, isNull);
    expect(doc.lines.last.cachedResult, 'x = -5');
    expect(doc.lines.last.cachedFreeVars, isEmpty);
  });

  test('solve coefficients remain reactive with an explicit bound variable',
      () async {
    final doc = _document(['a=2', 'x=9', 'solve(a*x=6,x)']);
    expect(buildDependencyGraph(doc).dependsOn[2], {0});
    final evaluator = _evaluator([]);
    await evaluator.evaluateAll(doc);
    expect(doc.lines.last.cachedError, isNull);
    expect(doc.lines.last.cachedResult, 'x = 3');
    expect(doc.lines.last.cachedFreeVars, isEmpty);
    doc.lines.first.source = 'a=3';
    await evaluator.evaluateFrom(doc, 0);
    expect(doc.lines.last.cachedResult, 'x = 2');
  });

  test('solve lexical scope retains coefficients and variables outside its call',
      () {
    Set<String> free(String source) => freeVariablesOfLine(
        classifyNotepadLine(source, lineIndex: 0, firstCodeLineIndex: 0), {});
    expect(free('solve(x^2-1,x)'), isEmpty);
    expect(free('solve(a*x-b,x)'), {'a', 'b'});
    expect(free('solve(x+y,x)+x'), {'x', 'y'});
    expect(free('solve(x^2-1,x+1)'), {'x'});
    expect(free('solve(x^2-1)'), {'x'});
    // These outputs retain the variable; solve-specific binding must not
    // silently reclassify differentiation or indefinite integration.
    expect(free('diff(x^2,x)'), {'x'});
    expect(free('integrate(x^2,x)'), {'x'});
  });

  test('actual derivative and indefinite integral keep formal variables symbolic',
      () async {
    final routed = <EngineOp>[];
    final doc = _document(['x=9', 'diff(x^3,x)', 'integrate(x^2,x)']);
    final evaluator = _evaluator(routed);
    expect(buildDependencyGraph(doc).dependsOn[1], isEmpty);
    expect(buildDependencyGraph(doc).dependsOn[2], isEmpty);
    await evaluator.evaluateAll(doc);
    expect(doc.lines[1].cachedError, isNull);
    _expectMonomial(doc.lines[1].cachedResult!, '3x^2');
    expect(doc.lines[2].cachedError, isNull);
    _expectMonomial(doc.lines[2].cachedResult!, '1/3x^3+C');
    expect(doc.lines[1].cachedFreeVars, isEmpty);
    expect(doc.lines[2].cachedFreeVars, isEmpty);
    expect(routed.where((op) => op.kind == 'differentiate').single.arg2, 'x');
    expect(routed.where((op) => op.kind == 'integrate').single.arg2, 'x');
    doc.lines.first.source = 'x=100';
    await evaluator.evaluateFrom(doc, 0);
    _expectMonomial(doc.lines[1].cachedResult!, '3x^2');
    _expectMonomial(doc.lines[2].cachedResult!, '1/3x^3+C');
  });

  test('formal operation coefficients react without capturing their variable',
      () async {
    final doc = _document(['a=2', 'x=9', 'diff(a*x^3,x)', 'integrate(a*x^2,x)']);
    final evaluator = _evaluator([]);
    expect(buildDependencyGraph(doc).dependsOn[2], {0});
    expect(buildDependencyGraph(doc).dependsOn[3], {0});
    await evaluator.evaluateAll(doc);
    _expectMonomial(doc.lines[2].cachedResult!, '6x^2');
    _expectMonomial(doc.lines[3].cachedResult!, '2/3x^3+C');
    doc.lines.first.source = 'a=3';
    await evaluator.evaluateFrom(doc, 0);
    _expectMonomial(doc.lines[2].cachedResult!, '9x^2');
    _expectMonomial(doc.lines[3].cachedResult!, 'x^3+C');
  });

  test('formal output chips remain visible outside enclosing definite scopes', () {
    Set<String> free(String source, [Set<String> scope = const {}]) =>
        freeVariablesOfLine(
            classifyNotepadLine(source, lineIndex: 0, firstCodeLineIndex: 0), scope);
    expect(free('diff(x^3,x)'), {'x'});
    expect(free('integrate(x^2,x)'), {'x'});
    expect(free('diff(a*x^3,x)'), {'a', 'x'});
    expect(free('integrate(a*x^2,x)'), {'a', 'x'});
    expect(free('diff(x^3,x)', {'x'}), isEmpty);
    expect(free('integrate(x^2,x)', {'x'}), isEmpty);
    expect(free('integrate(diff(x^3,x),x,0,1)'), isEmpty);
    expect(free('solve(diff(x^3,x)-3,x)'), isEmpty);
    expect(free('limit(integrate(x,x),x,0)'), isEmpty);
    expect(free('integrate(diff(x^3,x),x,0,x)'), {'x'});
    expect(free('d/dx(x^3,x)'), {'x'});
    expect(free('d/dx(x^3,x)+d+dx'), {'x', 'd', 'dx'});
    expect(parseDifferentiationArguments('diff(f(x,y),x)'), ['f(x,y)', 'x']);
    expect(parseDifferentiationArguments('d/dx(x^3,x)'), ['x^3', 'x']);
    expect(parseDifferentiationArguments('diff(x^3,x+1)'), isNull);
  });

  test('actual derivative alias survives bindings named after callee fragments',
      () async {
    final doc = _document(['d=4', 'dx=5', 'x=9', 'd/dx(x^3,x)']);
    final routed = <EngineOp>[];
    expect(buildDependencyGraph(doc).dependsOn[3], isEmpty);
    await _evaluator(routed).evaluateAll(doc);
    expect(doc.lines.last.cachedError, isNull);
    _expectMonomial(doc.lines.last.cachedResult!, '3*x^2');
    expect(doc.lines.last.cachedFreeVars, isEmpty);
    expect(routed.last.kind, 'differentiate');
    expect(routed.last.arg2, 'x');
  });

  test('incremental edits refresh formal availability without recalculating CAS',
      () async {
    final routed = <EngineOp>[];
    final doc = _document(['x=9', 'diff(x^3,x)', 'integrate(x^2,x)']);
    final evaluator = _evaluator(routed);
    await evaluator.evaluateAll(doc);
    final symbolicResults =
        doc.lines.skip(1).map((line) => line.cachedResult).toList();
    final evidence = doc.lines.skip(1).map((line) => line.resultEvidence).toList();
    final initialCasCalls = routed
        .where((op) => op.kind == 'differentiate' || op.kind == 'integrate')
        .length;
    for (final source in ['y=9', 'x=4', 'x=1/0', 'x=2', '# removed x', 'x=3']) {
      doc.lines.first.source = source;
      await evaluator.evaluateChanged(doc, {0});
      final available = source == 'x=4' || source == 'x=2' || source == 'x=3';
      for (final line in doc.lines.skip(1)) {
        expect(line.cachedFreeVars, available ? isEmpty : ['x'], reason: source);
      }
      expect(doc.lines.skip(1).map((line) => line.cachedResult).toList(),
          symbolicResults, reason: source);
      expect(doc.lines.skip(1).map((line) => line.resultEvidence).toList(),
          evidence, reason: source);
      expect(
          routed
              .where((op) => op.kind == 'differentiate' || op.kind == 'integrate')
              .length,
          initialCasCalls,
          reason: source);
    }
  });

  test('formal output badges use available globals without hiding unbound names',
      () async {
    // The function forces the full scope path before x has a cached value.
    final doc = _document([
      'g(t)=t', 'x=9', 'diff(x^3,x)', 'integrate(x^2,x)',
    ]);
    final evaluator = _evaluator([]);
    await evaluator.evaluateAll(doc);
    expect(doc.lines[2].cachedFreeVars, isEmpty);
    expect(doc.lines[3].cachedFreeVars, isEmpty);
    expect(buildDependencyGraph(doc).dependsOn[2], isEmpty);
    expect(buildDependencyGraph(doc).dependsOn[3], isEmpty);
    doc.lines[1].source = '';
    await evaluator.evaluateAll(doc);
    expect(doc.lines[2].cachedFreeVars, ['x']);
    expect(doc.lines[3].cachedFreeVars, ['x']);
    final unbound = _document(['diff(x^3,x)', 'integrate(x^2,x)']);
    await _evaluator([]).evaluateAll(unbound);
    expect(unbound.lines[0].cachedFreeVars, ['x']);
    expect(unbound.lines[1].cachedFreeVars, ['x']);
  });

  test('explicit solve parser validates declarations and folds equations', () {
    expect(parseSolveArguments('solve(x^2=1,x)'), ['(x^2)-(1)', 'x']);
    expect(parseSolveArguments('solve(f(x,y)-a,x)'), ['f(x,y)-a', 'x']);
    for (final source in [
      'solve(x,x+1)', 'solve(x,(x))', 'solve(x,)', 'solve(x)',
      'solve(x==1,x)', 'solve(x=,x)', 'solve(f(x],x)',
    ]) {
      expect(parseSolveArguments(source), isNull, reason: source);
    }
  });
}

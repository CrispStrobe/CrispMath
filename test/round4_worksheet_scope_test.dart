import 'package:crisp_math/engine/calculator_engine.dart';
import 'package:crisp_math/engine/notepad.dart';
import 'package:crisp_math/engine/notepad_evaluator.dart';
import 'package:crisp_math/engine/result_evidence.dart';
import 'package:crisp_math/services/engine_op.dart';
import 'package:crisp_math/services/engine_dispatch.dart';
import 'package:crisp_math/services/notepad_dispatcher.dart';
import 'package:flutter_test/flutter_test.dart';

class _PureScopeEngine extends CalculatorEngine {
  @override
  bool get isNativeAvailable => false;
}

ParsedNotepadLine parse(String source) => classifyNotepadLine(source,
    lineIndex: 0, firstCodeLineIndex: 0);

void main() {
  test('limit binder is local but its point and coefficients remain free', () {
    final parsed = parse('limit(a*x^2,x,b)');
    expect(freeVariablesOfLine(parsed, {}), {'a', 'b'});
    expect(dependenciesOfLine(parsed, {'a', 'b', 'x'}), {'a', 'b'});
    final doc = NotepadDocument.fresh(name: 'Limit scope');
    expect(
        preprocessNotepadLine(parsed, doc: doc, lineIndex: 0,
            scope: {'x': '9', 'a': '2', 'b': '3'}),
        'limit((2)*x^2,x,(3))');
    final sameNamePoint = parse('limit(x^2,x,x)+x');
    expect(freeVariablesOfLine(sameNamePoint, {}), {'x'});
    expect(dependenciesOfLine(sameNamePoint, {'x'}), {'x'});
    expect(
        preprocessNotepadLine(sameNamePoint, doc: doc, lineIndex: 0,
            scope: {'x': '3'}),
        'limit(x^2,x,(3))+(3)');
  });

  test('invalid limits and indefinite integrals do not acquire lexical binders', () {
    expect(freeVariablesOfLine(parse('limit(x^2,x)'), {}), {'x'});
    expect(freeVariablesOfLine(parse('limit(x^2,x+1,0)'), {}), {'x'});
    expect(freeVariablesOfLine(parse('integrate(x^2,x)'), {}), {'x'});
  });

  test('unit syntax owns catalog names only in valid quantity expressions', () {
    final units = parse('1 kPa in N/cm^2');
    expect(freeVariablesOfLine(units, {}), isEmpty);
    expect(dependenciesOfLine(units, {'N', 'cm', 'kPa', 'in'}), isEmpty);
    expect(
        preprocessNotepadLine(units,
            doc: NotepadDocument.fresh(name: 'Units'), lineIndex: 0,
            scope: {'N': '99', 'cm': '2', 'kPa': '7', 'in': '8'}),
        '1 kPa in N/cm^2');
    expect(freeVariablesOfLine(parse('N+cm+kPa'), {}), {'N', 'cm', 'kPa'});
    expect(dependenciesOfLine(parse('N+cm'), {'N', 'cm'}), {'N', 'cm'});
    expect(freeVariablesOfLine(parse('1 bogus in N/cm^2'), {}), contains('bogus'));
  });

  test('quantity magnitude references survive unit syntax shielding', () {
    final quantity = parse('pressure kPa in N/cm^2');
    expect(freeVariablesOfLine(quantity, {}), {'pressure'});
    expect(dependenciesOfLine(quantity, {'pressure', 'kPa', 'N', 'cm'}), {'pressure'});
    expect(
        preprocessNotepadLine(quantity,
            doc: NotepadDocument.fresh(name: 'Units'), lineIndex: 0,
            scope: {'pressure': '2', 'kPa': '7', 'N': '99', 'cm': '2'}),
        '(2) kPa in N/cm^2');
    final namedLikeUnit = parse('m km in m');
    expect(dependenciesOfLine(namedLikeUnit, {'m', 'km'}), {'m'});
    expect(
        preprocessNotepadLine(namedLikeUnit,
            doc: NotepadDocument.fresh(name: 'Units'), lineIndex: 0,
            scope: {'m': '2', 'km': '9'}),
        '(2) km in m');
  });

  test('scientific unit magnitudes keep exponent tokens out of scope', () {
    final doc = NotepadDocument.fresh(name: 'Scientific units');
    for (final source in ['1e-3 kPa in N/cm^2', '1E3 kPa in N/cm^2']) {
      final parsed = parse(source);
      expect(freeVariablesOfLine(parsed, {}), isEmpty);
      expect(dependenciesOfLine(parsed, {'e', 'E3', 'kPa', 'N', 'cm'}), isEmpty);
      expect(preprocessNotepadLine(parsed, doc: doc, lineIndex: 0,
          scope: {'e': '7', 'E3': '8', 'kPa': '9', 'N': '99', 'cm': '2'}),
          source);
    }
  });

  test('later quantity magnitudes with unit-like names retain their bindings', () {
    final parsed = parse('v km + m m');
    expect(freeVariablesOfLine(parsed, {}), {'v', 'm'});
    expect(dependenciesOfLine(parsed, {'v', 'm', 'km'}), {'v', 'm'});
    expect(preprocessNotepadLine(parsed,
        doc: NotepadDocument.fresh(name: 'Summed units'), lineIndex: 0,
        scope: {'v': '2', 'm': '3', 'km': '9'}), '(2) km + (3) m');
  });

  test('unit-like scalar factors remain references while unit tokens stay local', () {
    final doc = NotepadDocument.fresh(name: 'Unit scalars');
    final quotient = parse('5 km / m');
    expect(freeVariablesOfLine(quotient, {}), {'m'});
    expect(dependenciesOfLine(quotient, {'m', 'km'}), {'m'});
    expect(preprocessNotepadLine(quotient, doc: doc, lineIndex: 0,
        scope: {'m': '2', 'km': '9'}), '5 km / (2)');
    final leading = parse('m * 5 km');
    expect(dependenciesOfLine(leading, {'m', 'km'}), {'m'});
    expect(preprocessNotepadLine(leading, doc: doc, lineIndex: 0,
        scope: {'m': '2', 'km': '9'}), '(2) * 5 km');
    expect(dependenciesOfLine(parse('N/cm'), {'N', 'cm'}), {'N', 'cm'});
  });

  test('worksheet limit routing shadows global x and reacts to its point', () async {
    final engine = _PureScopeEngine();
    final calls = <EngineOp>[];
    final dispatcher = NotepadDispatcher(
        engine: engine, yieldLocalWork: false, formatNumber: (value) => value,
        evaluateDetailedExpression: (source) async =>
            runEngineOpDetailed(engine, EngineOp('evaluate', source)),
        runDetailedOperation: (op) async {
          calls.add(op);
          expect(op.kind, 'limit');
          expect(op.arg1, '(2)*x^2');
          expect(op.arg2, 'x');
          // This continuous polynomial's limit equals its value at the
          // approach point. Exercise real substitution and exact evaluation;
          // native/WASM runtime and UI checks cover the actual limit backend.
          final value = engine.evaluate(
              engine.substitute(op.arg1, op.arg2!, op.arg3!));
          return ComputedResult(value, engine.lastResultEvidence);
        });
    final doc = NotepadDocument.fresh(name: 'Reactive limit');
    doc.lines
      ..clear()
      ..addAll(['a=2', 'x=9', 'limit(a*x^2,x,x)']
          .map((source) => NotepadLine.fresh(source: source)));
    final evaluator = NotepadEvaluator(
        dispatcher: dispatcher.evaluate,
        detailedDispatcher: dispatcher.evaluateDetailed);
    await evaluator.evaluateAll(doc);
    expect(doc.lines.last.cachedError, isNull);
    expect(doc.lines.last.cachedResult, '162');
    expect(calls, hasLength(1));
    expect(calls.single.arg3, '(9)');
    expect(doc.lines.last.cachedFreeVars, isEmpty);
    expect(buildDependencyGraph(doc).dependsOn[2], {0, 1});
    doc.lines[1].source = 'x=3';
    await evaluator.evaluateFrom(doc, 1);
    expect(doc.lines.last.cachedError, isNull);
    expect(doc.lines.last.cachedResult, '18');
    expect(calls, hasLength(2));
    expect(calls.last.arg3, '(3)');
    expect(doc.lines.last.cachedFreeVars, isEmpty);
  });

  test('actual unit dispatcher retains names and reacts to quantity magnitudes', () async {
    final dispatcher = NotepadDispatcher(
        yieldLocalWork: false, formatNumber: (value) => value,
        evaluateExpression: (_) async => throw StateError('Unit expression reached CAS'));
    final doc = NotepadDocument.fresh(name: 'Reactive quantity');
    doc.lines
      ..clear()
      ..addAll(['N=99', 'cm=2', 'kPa=7', 'pressure=1',
        'pressure kPa in N/cm^2']
          .map((source) => NotepadLine.fresh(source: source)));
    final evaluator = NotepadEvaluator(
        dispatcher: dispatcher.evaluate,
        detailedDispatcher: dispatcher.evaluateDetailed);
    await evaluator.evaluateAll(doc);
    expect(doc.lines.last.cachedError, isNull);
    expect(doc.lines.last.cachedResult, '0.1 N/cm²');
    expect(doc.lines.last.cachedFreeVars, isEmpty);
    expect(buildDependencyGraph(doc).dependsOn[4], {3});
    doc.lines[3].source = 'pressure=2';
    await evaluator.evaluateFrom(doc, 3);
    expect(doc.lines.last.cachedError, isNull);
    expect(doc.lines.last.cachedResult, '0.2 N/cm²');
  });
}

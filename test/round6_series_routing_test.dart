import 'package:crisp_math/engine/calculator_engine.dart';
import 'package:crisp_math/engine/notepad.dart';
import 'package:crisp_math/engine/notepad_evaluator.dart';
import 'package:crisp_math/services/engine_dispatch.dart';
import 'package:crisp_math/services/engine_op.dart';
import 'package:crisp_math/services/integral_arguments.dart';
import 'package:crisp_math/services/notepad_dispatcher.dart';
import 'package:flutter_test/flutter_test.dart';

NotepadDocument _document(List<String> sources) =>
    NotepadDocument.fresh(name: 'Taylor routing controls')
      ..lines.clear()
      ..lines.addAll(sources.map((source) => NotepadLine.fresh(source: source)));

void main() {
  test('Taylor parsers retain nested arguments and reject malformed declarations', () {
    expect(parseSeriesArguments('series(abs(x),x,(-2),3)'),
        ['abs(x)', 'x', '(-2)', '3']);
    expect(parseSeriesArguments('taylor(max(x,y),x,a,n)'),
        ['max(x,y)', 'x', 'a', 'n']);
    for (final source in [
      'series(x,x,0)', 'series(x,9,0,3)', 'series(x,x+1,0,3)',
      'series(x,x,0,3,4)', 'series(x,x,,3)', 'series((x],x,0,3)',
    ]) {
      expect(parseSeriesArguments(source), isNull, reason: source);
    }
    expect(parseSeriesOrder('((2))+1'), 3);
    expect(parseSeriesOrder('64'), 64);
    for (final order in ['0', '-1', '65', '3/2', 'n', '1/0']) {
      expect(parseSeriesOrder(order), isNull, reason: order);
    }
  });

  test('actual worksheet dispatcher routes both aliases without generic evaluate', () async {
    final routed = <EngineOp>[];
    final dispatcher = NotepadDispatcher(
        formatNumber: (value) => value,
        yieldLocalWork: false,
        evaluateExpression: (_) async => throw StateError('generic evaluate called'),
        runOperation: (op) async {
          routed.add(op);
          // Transport-only sentinel; mathematical values are independently
          // checked through the actual native/WASM document runtime fixtures.
          return 'transport-ok';
        });
    for (final alias in ['series', 'taylor']) {
      expect(await dispatcher.evaluate('$alias(abs(x),x,(-2),((3)))'), 'transport-ok');
      expect(routed.last.kind, 'series');
      expect(routed.last.arg1, 'abs(x)');
      expect(routed.last.arg2, 'x');
      expect(routed.last.arg3, '(-2)');
      expect(routed.last.arg4, '3');
    }
    final count = routed.length;
    for (final source in ['series(x,9,0,3)', 'series(x,x,0,3/2)',
      'taylor(x,x,0,65)', 'series(x,x,0)']) {
      expect(await dispatcher.evaluate(source), startsWith('Error:'), reason: source);
    }
    expect(routed.length, count);
  });

  test('formal Taylor variable shadows global x while center and order stay reactive', () async {
    final routed = <EngineOp>[];
    final engine = CalculatorEngine();
    final dispatcher = NotepadDispatcher(
        formatNumber: (value) => value,
        yieldLocalWork: false,
        evaluateExpression: (source) async => engine.evaluate(source),
        runOperation: (op) async {
          routed.add(op);
          return 'x'; // Verify scope/routing separately from hosted CAS math.
        });
    final evaluator = NotepadEvaluator(dispatcher: dispatcher.evaluate);
    final document = _document(['x=9', 'a=2', 'p=2', 'n=3',
        'series(a*abs(x),x,p,n)', 'taylor(abs(x),x,x,3)']);
    final graph = buildDependencyGraph(document);
    expect(graph.dependsOn[4], {1, 2, 3});
    expect(graph.dependsOn[5], {0});
    await evaluator.evaluateAll(document);
    expect(document.lines[4].cachedError, isNull);
    expect(document.lines[4].cachedFreeVars, isEmpty);
    final coefficientCall = routed.singleWhere((op) => op.arg1 != 'abs(x)');
    expect(coefficientCall.arg1, '(2)*abs(x)');
    expect(coefficientCall.arg2, 'x');
    expect(coefficientCall.arg3, '(2)');
    expect(coefficientCall.arg4, '3');
    final globalCenter = routed.singleWhere((op) => op.arg1 == 'abs(x)');
    expect(globalCenter.arg2, 'x');
    expect(globalCenter.arg3, '(9)');
    document.lines[2].source = 'p=-2';
    await evaluator.evaluateFrom(document, 2);
    expect(routed.last.arg3, '(-2)');
    document.lines[3].source = 'n=4';
    await evaluator.evaluateFrom(document, 3);
    expect(routed.last.arg4, '4');
  });

  test('unbound formal Taylor output stays free and nested bound scope prevails', () {
    ParsedNotepadLine parse(String source) => classifyNotepadLine(
        source, lineIndex: 0, firstCodeLineIndex: 0);
    expect(freeVariablesOfLine(parse('series(a*x,x,p,n)'), {}), {'a', 'x', 'p', 'n'});
    expect(freeVariablesOfLine(parse('taylor(a*x,x,p,n)'), {'a', 'x', 'p', 'n'}), isEmpty);
    expect(freeVariablesOfLine(parse('integrate(series(x,x,0,3),x,0,1)'), {}), isEmpty);
    expect(freeVariablesOfLine(parse('series(x,x,0,3)+x'), {}), {'x'});
  });

  test('actual engine cusp failure remains an error through worksheet routing', () async {
    final engine = CalculatorEngine();
    final dispatcher = NotepadDispatcher(
        formatNumber: (value) => value,
        yieldLocalWork: false,
        evaluateExpression: (source) async => engine.evaluate(source),
        runDetailedOperation: (op) async => runEngineOpDetailed(engine, op));
    expect(await dispatcher.evaluate('series(abs(x),x,0,3)'),
        contains('derivative does not exist'));
  });
}

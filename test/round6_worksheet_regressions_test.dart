import 'package:crisp_math/engine/calculator_engine.dart';
import 'package:crisp_math/engine/notepad.dart';
import 'package:crisp_math/engine/notepad_evaluator.dart';
import 'package:crisp_math/engine/result_evidence.dart';
import 'package:flutter_test/flutter_test.dart';

ParsedNotepadLine _parse(String source) =>
    classifyNotepadLine(source, lineIndex: 0, firstCodeLineIndex: 0);

void main() {
  test('rounding aliases reserve callees while preserving free arguments', () {
    for (final name in ['floor', 'ceil', 'ceiling']) {
      expect(freeVariablesOfLine(_parse('$name(a)'), {}), {'a'});
      expect(freeVariablesOfLine(_parse('$name(a)'), {'a'}), isEmpty);
      expect(_parse('$name=7').kind, NotepadLineKind.expression);
      expect(_parse('$name(t)=t+1').kind, NotepadLineKind.expression);
    }
    expect(_parse('ceilingRate=7').kind, NotepadLineKind.assignment);
    expect(
        freeVariablesOfLine(_parse('ceilingRate+q'), {}), {'ceilingRate', 'q'});
  });

  test('rounding results and badges remain correct after coefficient edits',
      () async {
    final engine = CalculatorEngine();
    final document = NotepadDocument.fresh(name: 'Rounding alias controls')
      ..lines.clear()
      ..lines.addAll(['a=-7/3', 'ceiling(a)', 'floor(a)', 'ceil(a)']
          .map((source) => NotepadLine.fresh(source: source)));
    final evaluator =
        NotepadEvaluator(dispatcher: (s) async => engine.evaluate(s));
    expect(buildDependencyGraph(document).dependsOn[1], {0});
    await evaluator.evaluateAll(document);
    expect(document.lines.map((line) => line.cachedResult),
        ['-2.3333333333333333', '-2', '-3', '-2']);
    expect(document.lines.every((line) => line.cachedFreeVars.isEmpty), isTrue);
    document.lines[0].source = 'a=7/3';
    await evaluator.evaluateFrom(document, 0);
    expect(document.lines.map((line) => line.cachedResult),
        ['2.3333333333333333', '3', '2', '3']);
    expect(document.lines.every((line) => line.cachedFreeVars.isEmpty), isTrue);
  });

  test('fraction variables are passed on exactly, not as rounded decimals',
      () async {
    final engine = CalculatorEngine();
    final document = NotepadDocument.fresh(name: 'Exact fractions')
      ..lines.clear()
      ..lines.addAll(['a=1/3', '3*a', 'c=10/3', 'c*3-10', 'Ans+1']
          .map((source) => NotepadLine.fresh(source: source)));
    // Like the app: results are display-rounded, evidence is kept.
    final evaluator = NotepadEvaluator(
        dispatcher: (s) async => engine.evaluate(s),
        detailedDispatcher: (s) async {
          engine.lastResultEvidence = null;
          final value = engine.evaluate(s);
          var shown = double.tryParse(value)?.toStringAsPrecision(12) ?? value;
          if (shown.contains('.') && !shown.contains('e')) {
            shown = shown
                .replaceFirst(RegExp(r'0+$'), '')
                .replaceFirst(RegExp(r'\.$'), '');
          }
          return ComputedResult(shown, engine.lastResultEvidence);
        });
    await evaluator.evaluateAll(document);
    expect(document.lines.map((line) => line.cachedResult),
        ['0.333333333333', '1', '3.33333333333', '0', '1']);
  });
}

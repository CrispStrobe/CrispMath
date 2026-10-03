import 'package:crisp_math/engine/calculator_engine.dart';
import 'package:crisp_math/engine/notepad.dart';
import 'package:crisp_math/engine/notepad_evaluator.dart';
import 'package:crisp_math/engine/numeric_fallback.dart';
import 'package:flutter_test/flutter_test.dart';

ParsedNotepadLine _parse(String source) => classifyNotepadLine(
    source, lineIndex: 0, firstCodeLineIndex: 0);

NotepadDocument _document(List<String> sources) =>
    NotepadDocument.fresh(name: 'Scientific scope regression')
      ..lines.clear()
      ..lines.addAll(sources.map((source) => NotepadLine.fresh(source: source)));

void main() {
  test('scientific numbers have no identifier fragments', () {
    for (final source in [
      '1e308*1e-308', '1E+308*1E-308', '1.e3', '.25e-3',
      '2.5E+12', '-1e-3', 'diff(1.e3*x,x)',
    ]) {
      expect(freeVariablesOfLine(_parse(source), {'x'}), isEmpty,
          reason: source);
      expect(dependenciesOfLine(_parse(source), {'e308', 'E', 'e3'}),
          isEmpty, reason: source);
    }
    expect(identifierWordsIn('1e308*x+e308+1.e3*a+.25E-3*b'),
        {'x', 'e308', 'a', 'b'});
    expect(identifierWordsIn('x1e308+e308+E308+e+x+2x'),
        {'x1e308', 'e308', 'E308', 'e', 'x'});
    expect(freeVariablesOfLine(_parse('e308+1e308'), {}), {'e308'});
    expect(dependenciesOfLine(_parse('a*1E-3+e308'), {'a', 'e308', 'E'}),
        {'a', 'e308'});
  });

  test('scope replacement preserves scientific numbers in both binding paths', () {
    final document = _document(['1']);
    for (final value in ['7', 'y+1']) {
      expect(preprocessNotepadLine(_parse('1.e308+e308+1E-3'),
          doc: document, lineIndex: 0,
          scope: {'e308': value, 'E': '9'}),
          '1.e308+($value)+1E-3');
    }
    // A symbolic replacement can itself introduce a scientific literal;
    // later substitutions must still consume that literal as one token.
    expect(preprocessNotepadLine(_parse('rate+e3'),
        doc: document, lineIndex: 0,
        scope: {'rate': '1.e3+x', 'e3': '7'}), '(1.e3+x)+(7)');
    final functions = _document(['f(e3)=1.e3+e3']);
    functions.lines.single.cachedResult = '1.e3+e3';
    expect(expandNotepadFunctionCalls('f(2)', functions), '(1.e3+(2))');
  });

  test('global exponent-like name remains reactive without numeric dependencies', () async {
    final engine = CalculatorEngine();
    final calls = <String>[];
    final evaluator = NotepadEvaluator(dispatcher: (source) async {
      calls.add(source);
      return engine.evaluate(source);
    });
    final document = _document([
      'e308=7', '1e308*1e-308', 'e308+1', 'a=2', 'a*1e-3',
    ]);
    final graph = buildDependencyGraph(document);
    expect(graph.dependsOn[1], isEmpty);
    expect(graph.dependsOn[2], {0});
    expect(graph.dependsOn[4], {3});
    await evaluator.evaluateAll(document);
    expect(document.lines[1].cachedResult, '1');
    expect(document.lines[1].cachedFreeVars, isEmpty);
    expect(document.lines[2].cachedResult, '8');
    // Worksheet presentation may use a terminating decimal for this exact
    // rational. The independently derived value is a / 1000 in either form.
    expect(NumericFallbackEvaluator.evalNumeric(document.lines[4].cachedResult!),
        closeTo(2 / 1000, 1e-15));
    expect(document.lines[4].cachedFreeVars, isEmpty);
    calls.clear();
    document.lines[0].source = 'e308=9';
    await evaluator.evaluateChanged(document, {0});
    expect(document.lines[2].cachedResult, '10');
    expect(document.lines[1].cachedResult, '1');
    expect(calls, isNot(contains('1e308*1e-308')));
    document.lines[3].source = 'a=3';
    await evaluator.evaluateChanged(document, {3});
    expect(NumericFallbackEvaluator.evalNumeric(document.lines[4].cachedResult!),
        closeTo(3 / 1000, 1e-15));
    expect(document.lines[4].cachedFreeVars, isEmpty);
  });
}

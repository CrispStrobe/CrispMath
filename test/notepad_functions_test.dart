import 'package:crisp_math/engine/notepad.dart';
import 'package:crisp_math/engine/notepad_evaluator.dart';
import 'package:crisp_math/engine/numeric_fallback.dart';
import 'package:flutter_test/flutter_test.dart';

NotepadDocument document(List<String> sources) =>
    NotepadDocument.fresh(name: 'Functions')
      ..lines.clear()
      ..lines.addAll(sources.map((s) => NotepadLine.fresh(source: s)));
final evaluator = NotepadEvaluator(dispatcher: (s) async {
  final value = NumericFallbackEvaluator.evalNumeric(s);
  return value == null ? 'Error: cannot evaluate $s' : value.toInt().toString();
});
void main() {
  test('parameters shadow document scalars; captured bindings recalculate',
      () async {
    final doc = document(['x=100', 'a=2', 'f(x)=x^2+a', 'f(3)']);
    await evaluator.evaluateAll(doc);
    expect(doc.lines.last.cachedResult, '11');
    expect(buildDependencyGraph(doc).dependsOn[2], {1});
    expect(doc.lines[2].cachedFreeVars, isEmpty);
    expect(buildNotepadScope(doc), isNot(contains('f')));
    doc.lines[1].source = 'a=5';
    await evaluator.evaluateChanged(doc, {1});
    expect(doc.lines.last.cachedResult, '14');
  });
  test('forward definitions, multiple arguments and nested calls', () async {
    final doc = document(['g(f(2), f(3))', 'g(x,y)=x-y', 'f(t)=t^2+1']);
    await evaluator.evaluateAll(doc);
    expect(doc.lines.first.cachedResult, '-5');
    expect(doc.lines.first.cachedFreeVars, isEmpty);
    final restored = NotepadDocument.fromJson(doc.toJson());
    await evaluator.evaluateAll(restored);
    expect(restored.lines.first.cachedResult, '-5');
  });
  test('arguments substitute simultaneously, preserving precedence', () async {
    final doc = document(['x=2', 'y=5', 'g(x,y)=x-y', 'g(y,x)+g(1+2,2*3)']);
    await evaluator.evaluateAll(doc);
    expect(doc.lines.last.cachedResult, '0');
  });
  test('nested function captures and body edits reach downstream calls',
      () async {
    final doc = document(['a=2', 'f(t)=t+a', 'g(x)=f(x)*2', 'g(3)']);
    await evaluator.evaluateAll(doc);
    expect(doc.lines.last.cachedResult, '10');
    doc.lines[1].source = 'f(t)=t*a';
    await evaluator.evaluateChanged(doc, {1});
    expect(doc.lines.last.cachedResult, '12');
    doc.lines.first.source = 'a=4';
    await evaluator.evaluateChanged(doc, {0});
    expect(doc.lines.last.cachedResult, '24');
  });
  test('wrong arity errors and blocks downstream results', () async {
    final doc = document(['f(x,y)=x+y', 'b=f(1)', 'b+1']);
    await evaluator.evaluateAll(doc);
    expect(doc.lines[1].cachedError, contains('expects 2 arguments'));
    expect(doc.lines.last.cachedError, isNotNull);
    expect(doc.lines.last.cachedResult, isNull);
  });
  test('mutually recursive functions report cycles', () async {
    final doc = document(['f(x)=g(x)', 'g(y)=f(y)', 'f(1)']);
    await evaluator.evaluateAll(doc);
    expect(doc.lines.every((l) => l.cachedError != null), isTrue);
  });
  test('zero-argument functions and prefix-safe names', () async {
    final doc = document(['f()=2', 'foo(x)=x+1', 'foo(f( ))']);
    await evaluator.evaluateAll(doc);
    expect(doc.lines.last.cachedResult, '3');
  });
  test('invalid definitions fail before calls and never retain old results',
      () async {
    final doc = document(['f(x)=x+1', 'f(2)']);
    await evaluator.evaluateAll(doc);
    expect(doc.lines.last.cachedResult, '3');
    doc.lines.first.source = 'f(x)=sin(x,x)';
    await evaluator.evaluateChanged(doc, {0});
    expect(doc.lines.first.cachedError, contains('wrong number of arguments'));
    expect(doc.lines.last.cachedError, isNotNull);
    expect(doc.lines.last.cachedResult, isNull);
    doc.lines.first.source = 'f(x)=x+2';
    await evaluator.evaluateChanged(doc, {0});
    expect(doc.lines.last.cachedResult, '4');
  });
  test('large expansions stop before allocating an unbounded body', () async {
    final doc = document(['f(x)=x+x+x', 'f(${'1+' * 20000}1)']);
    await evaluator.evaluateAll(doc);
    expect(doc.lines.last.cachedError, contains('exceeds its limit'));
    expect(doc.lines.last.cachedResult, isNull);
  });
  test('the latest function definition owns calls and dependency edges',
      () async {
    final doc = document(['f(x)=x+1', 'f(x)=x+2', 'f(3)']);
    await evaluator.evaluateAll(doc);
    expect(doc.lines.last.cachedResult, '5');
    expect(buildDependencyGraph(doc).dependsOn[2], {1});
    doc.lines.first.source = 'f(x)=x+100';
    await evaluator.evaluateChanged(doc, {0});
    expect(doc.lines.last.cachedResult, '5');
    doc.lines[1].source = 'f(x)=x*2';
    await evaluator.evaluateChanged(doc, {1});
    expect(doc.lines.last.cachedResult, '6');
  });
  test('a function definition removes an older scalar binding of its name',
      () async {
    final doc = document(['f=100', 'f(x)=x+1', 'f(3)']);
    await evaluator.evaluateAll(doc);
    expect(buildNotepadScope(doc), isNot(contains('f')));
    expect(doc.lines.last.cachedResult, '4');
  });
  test('CAS names and mathematical constants cannot become local functions',
      () {
    for (final name in ['sin', 'series', 'taylor', 'linsolve', 'I']) {
      final parsed = classifyNotepadLine('$name(x)=x+1',
          lineIndex: 0, firstCodeLineIndex: 0);
      expect(parsed.isFunction, isFalse, reason: name);
    }
  });
}

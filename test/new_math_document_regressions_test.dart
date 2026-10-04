import 'package:crisp_math/engine/notepad.dart';
import 'package:crisp_math/engine/notepad_evaluator.dart';
import 'package:crisp_math/engine/numeric_fallback.dart';
import 'package:flutter_test/flutter_test.dart';

NotepadDocument mathDocument(List<String> sources) =>
    NotepadDocument.fresh(name: 'Fresh math policy checks')
      ..lines.clear()
      ..lines.addAll(sources.map((s) => NotepadLine.fresh(source: s)));

NotepadEvaluator mathEvaluator() =>
    NotepadEvaluator(dispatcher: (source) async {
      final value = NumericFallbackEvaluator.evalNumeric(source);
      return value != null && value.isFinite
          ? value.toInt().toString()
          : 'Error: nonnumeric expression';
    });

void main() {
  test('reactive same-name update is a self-reference, not imperative mutation',
      () async {
    final doc = mathDocument(['n=5', 'n=n+1', 'n^2']);
    final graph = buildDependencyGraph(doc);
    expect(graph.dependsOn[1], {1});
    expect(graph.dependsOn[2], {1});
    await mathEvaluator().evaluateAll(doc);
    expect(doc.lines.first.cachedResult, '5');
    expect(doc.lines[1].cachedError, startsWith('circularReference:'));
    expect(doc.lines[2].cachedResult, isNull);
    expect(doc.lines[2].cachedError, isNotNull);
  });

  test('a distinct next-value binding computes 36 and reacts to source edits',
      () async {
    final doc = mathDocument(['n=5', 'next=n+1', 'next^2']);
    final evaluator = mathEvaluator();
    await evaluator.evaluateAll(doc);
    expect(doc.lines.map((line) => line.cachedResult), ['5', '6', '36']);
    doc.lines.first.source = 'n=2';
    await evaluator.evaluateFrom(doc, 0);
    expect(doc.lines.map((line) => line.cachedResult), ['2', '3', '9']);
  });

  test('forward references and last-definition precedence remain reactive',
      () async {
    final forward = mathDocument(['next=n+1', 'n=5', 'next^2']);
    await mathEvaluator().evaluateAll(forward);
    expect(forward.lines.map((line) => line.cachedResult), ['6', '5', '36']);
    final duplicate = mathDocument(['n=5', 'n=8', 'n^2']);
    await mathEvaluator().evaluateAll(duplicate);
    expect(duplicate.lines.map((line) => line.cachedResult), ['5', '8', '64']);
  });

  test('genuine mutual cycles do not corrupt an independent calculation',
      () async {
    final doc = mathDocument(['a=b+1', 'b=a+1', '7']);
    await mathEvaluator().evaluateAll(doc);
    expect(doc.lines[0].cachedError, startsWith('circularReference:'));
    expect(doc.lines[1].cachedError, startsWith('circularReference:'));
    expect(doc.lines[2].cachedResult, '7');
    expect(doc.lines[2].cachedError, isNull);
  });
}

import 'dart:convert';

import 'package:crisp_math/engine/linked_graph.dart';
import 'package:crisp_math/engine/notepad.dart';
import 'package:crisp_math/engine/notepad_evaluator.dart';
import 'package:crisp_math/engine/notepad_plot.dart';
import 'package:crisp_math/engine/notepad_references.dart';
import 'package:crisp_math/engine/numeric_fallback.dart';
import 'package:crisp_math/engine/result_evidence.dart';
import 'package:crisp_math/engine/symbolic_expr.dart';
import 'package:crisp_math/engine/symbolic_web.dart';
import 'package:crisp_math/services/integral_arguments.dart';
import 'package:flutter_test/flutter_test.dart';

NotepadDocument document(List<String> sources) => NotepadDocument(
    id: 'document',
    name: 'Result references',
    createdAt: DateTime.utc(2026, 11, 10),
    updatedAt: DateTime.utc(2026, 11, 10),
    lines: [
      for (var i = 0; i < sources.length; i++)
        NotepadLine(id: 'r$i', source: sources[i]),
    ]);

// Use the same pure mathematical primitives as the production fallback, so
// dependency tests assert actual numbers and symbolic formulas, not canned rows.
String evaluateMath(String source) {
  final derivative = parseDifferentiationArguments(source);
  if (derivative != null) {
    return SymbolicWeb.differentiate(derivative[0], derivative[1]) ??
        'Error: unsupported derivative';
  }
  final integral = parseIntegralArguments(source);
  if (integral != null) {
    final antiderivative = SymbolicWeb.integrate(integral[0], integral[1]);
    if (antiderivative == null) return 'Error: unsupported integral';
    if (integral.length == 2) return antiderivative;
    final lo = NumericFallbackEvaluator.evalNumeric(integral[2]);
    final hi = NumericFallbackEvaluator.evalNumeric(integral[3]);
    if (lo == null || hi == null) return 'Error: invalid bounds';
    final low = NumericFallbackEvaluator.evalNumeric(
        antiderivative, {integral[1]: lo});
    final high = NumericFallbackEvaluator.evalNumeric(
        antiderivative, {integral[1]: hi});
    if (low == null || high == null) return 'Error: invalid antiderivative';
    return (high - low).toString();
  }
  return NumericFallbackEvaluator.tryEvaluate(source) ??
      SymbolicExpressionEvaluator.tryEvaluate(source) ??
      'Error: cannot evaluate $source';
}

NotepadEvaluator evaluator({Map<String, String> external = const {}}) =>
    NotepadEvaluator(
        externalScope: external,
        dispatcher: (source) async => evaluateMath(source));

double? value(NotepadLine line, [Map<String, double> scope = const {}]) =>
    line.cachedResult == null
        ? null
        : NumericFallbackEvaluator.evalNumeric(line.cachedResult!, scope);

void main() {
  group('reference source helpers', () {
    test('tokens round trip imported IDs and expose UTF-16 editor spans', () {
      const id = 'row /#} α " \u{1f9ee}';
      final token = resultReferenceToken(id);
      final source = '\u{1f9ee} $token + 1';
      final reference = resultReferencesIn(source, strict: true).single;
      expect(reference.lineId, id);
      expect(reference.start, 3);
      expect(source.substring(reference.start, reference.end), token);
      expect(token, isNot(contains('#')));
      expect(() => resultReferenceToken(''), throwsFormatException);
    });

    test('quoted text and comments are not live references', () {
      const source =
          '@{a} + "@{quoted}" + \'@{also-quoted}\' // @{comment}\n'
          '@{b} # @{last-comment}';
      expect(resultReferencesIn(source).map((r) => r.lineId), ['a', 'b']);
      expect(resultReferencesIn('"escaped\\" @{quoted}" + @{a}')
          .map((r) => r.lineId), ['a']);
      expect(resultReferencesIn('# @{unfinished', strict: true), isEmpty);
    });

    test('typing is tolerant while strict evaluation rejects malformed tokens',
        () {
      for (final source in [
        '@{}', '@{unfinished', '@{%}', '@{%GG}', '@{%FF}',
        '@{raw space}', '@{raw/#}', '@{nested{row}}',
      ]) {
        expect(resultReferencesIn(source), isEmpty, reason: source);
        expect(() => resultReferencesIn(source, strict: true),
            throwsFormatException, reason: source);
      }
    });

    test('copy remapping preserves dangling refs and literal commentary', () {
      const source = '@{a}+@{missing}+"@{a}" # @{a}';
      final remapped = remapResultReferences(source, {'a': 'new/#row'});
      expect(remapped,
          '${resultReferenceToken('new/#row')}+@{missing}+"@{a}" # @{a}');
      expect(remapResultReferences(source, const {}), source);
    });
  });

  test('only successful ordinary result kinds are offered for reuse', () {
    for (final source in ['2+3', 'a=5', 'total']) {
      final line = NotepadLine(id: 'row', source: source, cachedResult: '5');
      expect(canReferenceNotepadLine(line), isTrue, reason: source);
      line.cachedError = 'failure';
      expect(canReferenceNotepadLine(line), isFalse);
      line.cachedError = null;
      line.cachedResult = null;
      expect(canReferenceNotepadLine(line), isFalse);
    }
    for (final source in [
      '', '# note', '## Section', '---', 'use a', 'f(t)=t+1',
      'plot(x)', 'fzn: solve satisfy;',
    ]) {
      expect(canReferenceNotepadLine(
          NotepadLine(id: 'row', source: source, cachedResult: '5')),
          isFalse, reason: source);
    }
    expect(canReferenceNotepadLine(NotepadLine(id: 'row', source: 'x',
        cachedResult: '__plot__:x|x|-1|1')), isFalse);
  });

  test('forward references have identity edges and recalculate on source edits',
      () async {
    final doc = document(['@{r2}+1', '99', 'a=2']);
    final engine = evaluator(external: {'r2': '500'});
    expect(buildDependencyGraph(doc).dependsOn[0], {2});
    expect(freeVariablesOfLine(ParsedNotepadLine.expression('@{r2}+u'),
        const {}), {'u'});
    await engine.evaluateAll(doc);
    expect(value(doc.lines.first), 3);
    expect(doc.lines.first.cachedFreeVars, isEmpty);
    doc.lines[2].source = 'a=4';
    await engine.evaluateFrom(doc, 2);
    expect(value(doc.lines.first), 5);
    expect(value(doc.lines[1]), 99);
  });

  test('reordering and insertion preserve identities while lineN stays positional',
      () async {
    final doc = document(['2', '3', '@{r0}+line1']);
    final engine = evaluator();
    await engine.evaluateAll(doc);
    expect(value(doc.lines.last), 4);
    doc.lines.insert(0, doc.lines.removeAt(1));
    await engine.evaluateAll(doc);
    expect(value(doc.lines.last), 5);
    doc.lines.insert(0, NotepadLine(id: 'inserted', source: '100'));
    await engine.evaluateAll(doc);
    expect(value(doc.lines.last), 102);
    expect(doc.lines.last.source, '@{r0}+line1');
  });

  test('deleted source clears its consumer and the same restored row recovers',
      () async {
    final doc = document(['2', '@{r0}*3']);
    final engine = evaluator();
    await engine.evaluateAll(doc);
    expect(value(doc.lines.last), 6);
    final removed = doc.lines.removeAt(0);
    await engine.evaluateAll(doc);
    expect(doc.lines.single.cachedResult, isNull);
    expect(doc.lines.single.cachedError, contains('missing'));
    doc.lines.insert(0, removed);
    await engine.evaluateAll(doc);
    expect(value(doc.lines.last), 6);
    expect(doc.lines.last.cachedError, isNull);
  });

  test('duplicate source identities are rejected without choosing a row',
      () async {
    final doc = document(['2', '9', '@{r0}+1']);
    doc.lines[1] = NotepadLine(id: 'r0', source: '9');
    doc.lines.last.cachedResult = '999';
    await evaluator().evaluateAll(doc);
    expect(doc.lines.last.cachedResult, isNull);
    expect(doc.lines.last.cachedError, contains('duplicated'));
    expect(resolveLinkedGraph(doc, 'r0').error, contains('duplicated'));
  });

  test('pending and failed results clear consumers rather than reuse old output',
      () async {
    final doc = document(['2', '@{r0}+1']);
    final engine = evaluator();
    await engine.evaluateAll(doc);
    doc.lines.first.source = '2 +';
    await engine.evaluateFrom(doc, 0);
    expect(doc.lines.last.cachedResult, isNull);
    expect(doc.lines.last.cachedError, contains('not ready'));
    doc.lines.first.source = '1/0';
    await engine.evaluateFrom(doc, 0);
    expect(doc.lines.last.cachedResult, isNull);
    expect(doc.lines.last.cachedError,
        NotepadErrorPrefix.blocked(doc.lines.first.id, 'line1'));
    doc.lines.first.source = '7';
    await engine.evaluateFrom(doc, 0);
    expect(value(doc.lines.last), 8);
  });

  test('plot, function, structure and solver outputs cannot be referenced', () {
    for (final source in [
      'plot(x)', 'f(t)=t+1', '## Section', 'fzn: solve satisfy;',
    ]) {
      final doc = document([source, '@{r0}+1']);
      doc.lines.first.cachedResult = '5';
      expect(() => preprocessNotepadLine(
          ParsedNotepadLine.expression(doc.lines.last.source),
          doc: doc, lineIndex: 1, scope: const {}),
          throwsFormatException, reason: source);
    }
  });

  test('self and mutual reference cycles clear stale values before dispatch',
      () async {
    for (final sources in [
      ['@{r0}+1'], ['@{r1}+1', '@{r0}+1'],
    ]) {
      final doc = document(sources);
      for (final row in doc.lines) {
        row.cachedResult = '20';
      }
      await evaluator().evaluateAll(doc);
      for (final row in doc.lines) {
        expect(row.cachedResult, isNull);
        expect(row.cachedError, startsWith(NotepadErrorPrefix.circularReference));
      }
    }
  });

  test('malformed references clear a formerly successful calculation', () async {
    final doc = document(['2', '@{r0}+1']);
    final engine = evaluator();
    await engine.evaluateAll(doc);
    for (final source in ['@{}+1', '@{%GG}+1', '@{unfinished']) {
      doc.lines.last.source = source;
      await engine.evaluateFrom(doc, 1);
      expect(doc.lines.last.cachedResult, isNull);
      expect(doc.lines.last.cachedError, contains('Invalid result reference'));
    }
  });

  test('references preserve symbolic results against downstream scalar capture',
      () async {
    final doc = document(['x=100', 'diff(x^3,x)', '@{r1}+x']);
    final engine = evaluator();
    await engine.evaluateAll(doc);
    expect(buildDependencyGraph(doc).dependsOn[2], {0, 1});
    expect(value(doc.lines[2], {'x': 2}), 112);
    expect(doc.lines[2].cachedFreeVars, ['x']);
    doc.lines.first.source = 'x=101';
    await engine.evaluateFrom(doc, 0);
    expect(value(doc.lines[2], {'x': 2}), 113);
    expect(value(doc.lines[1], {'x': 2}), 12);
  });

  test('unknown symbols from referenced output are shown instead of row IDs',
      () async {
    final doc = document(['y^2', '@{r0}+1']);
    await evaluator().evaluateAll(doc);
    expect(doc.lines.last.cachedError, isNull);
    expect(doc.lines.last.cachedFreeVars, ['y']);
    expect(value(doc.lines.last, {'y': 3}), 10);
  });

  test('functions bind their own parameters without capturing nested symbols',
      () async {
    final doc = document([
      'x=100', 'diff(x^3,x)', 'f(t)=@{r1}+t', 'f(3)',
      'g(x)=f(x)', 'g(4)', 'h(x)=@{r1}', 'h(3)',
      'square(t)=t^2', 'square(@{r1})', 'diff(h(x),x)',
    ]);
    await evaluator().evaluateAll(doc);
    expect(value(doc.lines[3], {'x': 2}), 15);
    expect(value(doc.lines[5], {'x': 2}), 16);
    expect(value(doc.lines[7]), 27);
    expect(value(doc.lines[9], {'x': 2}), 144);
    expect(value(doc.lines[10], {'x': 2}), 12);
    expect(doc.lines[3].cachedFreeVars, ['x']);
    expect(doc.lines[7].cachedFreeVars, isEmpty);
    for (final row in doc.lines) {
      expect(row.cachedError, isNull, reason: row.source);
      expect(row.cachedResult, isNot(contains('\uE002')), reason: row.source);
    }
  });

  test('reference-bearing functions retain explicit imports and recalculate',
      () async {
    final doc = document(['2', 'f(t)=@{r0}+offset*t', 'f(3)']);
    final external = {'offset': '4'};
    final engine = evaluator(external: external);
    await engine.evaluateAll(doc);
    expect(value(doc.lines.last), 14);
    doc.lines.first.source = '5';
    await engine.evaluateFrom(doc, 0);
    expect(value(doc.lines.last), 17);
  });

  test('calculus owns its coordinate around a referenced formula', () async {
    final doc = document([
      'x=100', 'diff(x^3,x)', 'diff(@{r1},x)',
      'integrate(@{r1},x,0,2)',
    ]);
    await evaluator().evaluateAll(doc);
    expect(buildDependencyGraph(doc).dependsOn[2], {1});
    expect(buildDependencyGraph(doc).dependsOn[3], {1});
    expect(value(doc.lines[2], {'x': 2}), 12);
    expect(value(doc.lines[3]), 8);
    expect(doc.lines[3].cachedFreeVars, isEmpty);
  });

  test('plot expressions and bounds follow referenced values and errors',
      () async {
    final doc = document([
      'a=2', 'radius=3', 'plot(@{r0}*x^2,x,-@{r1},@{r1})',
    ]);
    final engine = evaluator();
    await engine.evaluateAll(doc);
    expect(buildDependencyGraph(doc).dependsOn[2], {0, 1});
    var plot = PlotSpec.tryParse(doc.lines.last.cachedResult)!;
    expect(plot.lo, -3);
    expect(plot.hi, 3);
    expect(NumericFallbackEvaluator.evalNumeric(plot.graphExpression, {'x': 2}), 8);
    expect(resolveLinkedGraph(doc, 'r2').plot!.hi, 3);
    doc.lines[0].source = 'a=4';
    doc.lines[1].source = 'radius=5';
    await engine.evaluateChanged(doc, {0, 1});
    plot = PlotSpec.tryParse(doc.lines.last.cachedResult)!;
    expect(plot.lo, -5);
    expect(plot.hi, 5);
    expect(NumericFallbackEvaluator.evalNumeric(plot.graphExpression, {'x': 2}), 16);
    doc.lines[1].source = 'radius=0';
    await engine.evaluateFrom(doc, 1);
    expect(doc.lines.last.cachedResult, isNull);
    expect(resolveLinkedGraph(doc, 'r2').expression, isNull);
  });

  test('symbolic references share graph coordinates without scalar rebinding',
      () async {
    final doc = document([
      'x=100', 't=99', 'diff(t^3,t)', 'plot(@{r2},t,-2,2)',
      'diff(x^3,x)', '@{r4}',
    ]);
    await evaluator().evaluateAll(doc);
    final plot = resolveLinkedGraph(doc, 'r3');
    expect(plot.error, isNull);
    expect(NumericFallbackEvaluator.evalNumeric(plot.expression!, {'x': 2}), 12);
    final expression = resolveLinkedGraph(doc, 'r5');
    expect(expression.error, isNull);
    expect(NumericFallbackEvaluator.evalNumeric(expression.expression!, {'x': 2}),
        12);
    doc.lines[4].cachedResult = null;
    expect(resolveLinkedGraph(doc, 'r5').expression, isNull);
    expect(resolveLinkedGraph(doc, 'r5').error, contains('not ready'));
  });

  test('approximate source evidence follows stable edges and function captures',
      () async {
    final doc = document(['sqrt(2)', '@{r0}*2', 'f(t)=@{r0}+t', 'f(1)']);
    final engine = NotepadEvaluator(
        dispatcher: (source) async => evaluateMath(source),
        detailedDispatcher: (source) async => ComputedResult(
            evaluateMath(source),
            ResultEvidence(
                source.contains('sqrt')
                    ? ResultAccuracy.approximate
                    : ResultAccuracy.exact,
                ComputationMethod.numericFallback)));
    await engine.evaluateAll(doc);
    expect(value(doc.lines[1]), closeTo(2.8284271247461903, 1e-14));
    expect(value(doc.lines[3]), closeTo(2.414213562373095, 1e-14));
    for (final row in doc.lines) {
      expect(row.resultEvidence!.accuracy, ResultAccuracy.approximate);
    }
  });

  test('reload preserves source identities and never persists private markers',
      () async {
    final doc = document(['3', 'f(t)=@{r0}*t', 'f(4)', '@{r2}+1']);
    await evaluator().evaluateAll(doc);
    final encoded = jsonEncode(doc.toJson());
    expect(encoded, isNot(contains('\uE002')));
    final restored = NotepadDocument.fromJson(
        jsonDecode(encoded) as Map<String, dynamic>);
    expect(restored.lines.map((line) => line.id), doc.lines.map((line) => line.id));
    expect(restored.lines[1].source, 'f(t)=@{r0}*t');
    await evaluator().evaluateAll(restored);
    expect(value(restored.lines.last), 13);
  });
}

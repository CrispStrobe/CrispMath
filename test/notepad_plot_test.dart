import 'dart:convert';

import 'package:crisp_math/engine/linked_graph.dart';
import 'package:crisp_math/engine/notepad.dart';
import 'package:crisp_math/engine/notepad_evaluator.dart';
import 'package:crisp_math/engine/notepad_plot.dart';
import 'package:crisp_math/engine/numeric_fallback.dart';
import 'package:crisp_math/engine/symbolic_expr.dart';
import 'package:flutter_test/flutter_test.dart';

NotepadDocument document(List<String> sources) =>
    NotepadDocument.fresh(name: 'Connected plots')
      ..lines.clear()
      ..lines.addAll(sources.map((source) => NotepadLine.fresh(source: source)));

NotepadEvaluator evaluator({Map<String, String> imports = const {}}) =>
    NotepadEvaluator(
        externalScope: imports,
        dispatcher: (source) async =>
            NumericFallbackEvaluator.tryEvaluate(source) ??
            SymbolicExpressionEvaluator.tryEvaluate(source) ??
            'Error: cannot evaluate $source');

double? at(PlotSpec spec, double x) =>
    NumericFallbackEvaluator.evalNumeric(spec.graphExpression, {'x': x});

void main() {
  test('inline and linked plots share local functions and captured bindings',
      () async {
    final doc = document(['a=2', 'f(t)=a*t^2', 'plot(f(x),x,-2,2)']);
    final engine = evaluator();
    await engine.evaluateAll(doc);
    final row = doc.lines.last;
    final inline = PlotSpec.tryParse(row.cachedResult)!;
    final linked = resolveLinkedGraph(doc, row.id);
    expect(row.cachedError, isNull);
    expect(at(inline, -2), 8);
    expect(at(inline, 0), 0);
    expect(linked.expression, inline.graphExpression);
    expect(linked.scope, {'a': '2'});
    expect(linked.plot!.lo, -2);
    expect(linked.plot!.hi, 2);

    doc.lines.first.source = 'a=3';
    await engine.evaluateFrom(doc, 0);
    final changed = PlotSpec.tryParse(row.cachedResult)!;
    expect(at(changed, -2), 12);
    expect(resolveLinkedGraph(doc, row.id).expression, changed.graphExpression);
  });

  test('forward function definitions and parameter ranges recalculate',
      () async {
    final doc = document(['plot(f(t),t,-radius,radius)', 'radius=2', 'f(u)=u+1']);
    final engine = evaluator();
    await engine.evaluateAll(doc);
    var spec = PlotSpec.tryParse(doc.lines.first.cachedResult)!;
    expect(spec.lo, -2);
    expect(spec.hi, 2);
    expect(at(spec, 2), 3);
    expect(buildDependencyGraph(doc).dependsOn[0], {1, 2});

    doc.lines[1].source = 'radius=4';
    await engine.evaluateFrom(doc, 1);
    spec = PlotSpec.tryParse(doc.lines.first.cachedResult)!;
    expect(spec.lo, -4);
    expect(spec.hi, 4);
    expect(at(spec, 4), 5);
  });

  test('coordinate shadows document scalar in body but not in range bounds',
      () async {
    final doc = document(['t=2', 'plot(t^2,t,-t,t)', 'plot(t^2,t,-1,1)']);
    final engine = evaluator();
    await engine.evaluateAll(doc);
    final bounded = PlotSpec.tryParse(doc.lines[1].cachedResult)!;
    expect(at(bounded, 3), 9);
    expect(bounded.lo, -2);
    expect(bounded.hi, 2);
    expect(buildDependencyGraph(doc).dependsOn[1], {0});
    expect(buildDependencyGraph(doc).dependsOn[2], isEmpty);
    expect(doc.lines[1].cachedFreeVars, isEmpty);
    expect(doc.lines[2].cachedFreeVars, isEmpty);
    final fixed = doc.lines[2].cachedResult;
    doc.lines.first.source = 't=4';
    await engine.evaluateFrom(doc, 0);
    expect(PlotSpec.tryParse(doc.lines[1].cachedResult)!.hi, 4);
    expect(doc.lines[2].cachedResult, fixed);
  });

  test('upstream failures remove old plots and recover after a correction',
      () async {
    final doc = document(['a=2', 'f(t)=a*t', 'plot(f(x))']);
    final engine = evaluator();
    await engine.evaluateAll(doc);
    expect(at(PlotSpec.tryParse(doc.lines.last.cachedResult)!, 3), 6);
    doc.lines.first.source = 'a=1/0';
    await engine.evaluateFrom(doc, 0);
    expect(doc.lines.last.cachedResult, isNull);
    expect(doc.lines.last.cachedError, startsWith(NotepadErrorPrefix.blockedBy));
    expect(resolveLinkedGraph(doc, doc.lines.last.id).expression, isNull);
    doc.lines.first.source = 'a=5';
    await engine.evaluateFrom(doc, 0);
    expect(doc.lines.last.cachedError, isNull);
    expect(at(PlotSpec.tryParse(doc.lines.last.cachedResult)!, 3), 15);
  });

  test('range dependency failures block a previously valid plot', () async {
    final doc = document(['radius=2', 'plot(x,x,-radius,radius)']);
    final engine = evaluator();
    await engine.evaluateAll(doc);
    doc.lines.first.source = 'radius=1/0';
    await engine.evaluateFrom(doc, 0);
    expect(doc.lines.last.cachedResult, isNull);
    expect(doc.lines.last.cachedError,
        NotepadErrorPrefix.blocked(doc.lines.first.id, 'line1'));
  });

  test('missing values and invalid plot syntax never leave a cached curve',
      () async {
    final doc = document(['plot(x)']);
    final engine = evaluator();
    await engine.evaluateAll(doc);
    for (final source in [
      'plot(a*x)',
      'plot(x,x,-radius,radius)',
      'plot(sinn(x))',
      'plot(sin(x,x))',
      'plot(x+,x,-1,1)',
      'plot(x,x,1,1)',
      'plot(x,x,2,-2)',
      'plot(x,x,-inf,inf)',
      'plot(x,x,0,1e309)',
      'plot(x,x,0,sqrt(-1))',
      'plot(x,2,0,1)',
      'plot(x,pi,0,1)',
      'plot(x,x,,1)',
      'plot(x,x,0,)',
    ]) {
      doc.lines.first.source = source;
      await engine.evaluateFrom(doc, 0);
      expect(doc.lines.first.cachedResult, isNull, reason: source);
      expect(doc.lines.first.cachedError, isNotNull, reason: source);
      expect(resolveLinkedGraph(doc, doc.lines.first.id).expression, isNull,
          reason: source);
    }
  });

  test('free coordinate does not appear among missing bindings', () async {
    final doc = document(['plot(a*t,t,-2,2)']);
    await evaluator().evaluateAll(doc);
    expect(doc.lines.first.cachedFreeVars, ['a']);
    expect(doc.lines.first.cachedError, contains('Define a'));
  });

  test('recognized reciprocal trig calls are not undefined scalar bindings',
      () async {
    final doc = document(['plot(sec(x))', 'plot(csc(x))', 'plot(cot(x))']);
    await evaluator().evaluateAll(doc);
    for (final (index, name) in ['sec', 'csc', 'cot'].indexed) {
      final row = doc.lines[index];
      expect(row.cachedError, isNull, reason: name);
      expect(row.cachedFreeVars, isEmpty, reason: name);
      final spec = PlotSpec.tryParse(row.cachedResult)!;
      expect(spec.graphExpression, '$name(x)');
      expect(resolveLinkedGraph(doc, row.id).expression, '$name(x)');
    }
  });

  test('recognized calls do not hide missing scalars or malformed calls',
      () async {
    final doc = document(['plot(sec(x))']);
    final engine = evaluator();
    await engine.evaluateAll(doc);
    for (final source in [
      'plot(sec*x)',
      'plot(sec(x)+sec)',
      'plot(sinn(x))',
      'plot(sec(x,x))',
    ]) {
      doc.lines.first.source = source;
      await engine.evaluateFrom(doc, 0);
      expect(doc.lines.first.cachedResult, isNull, reason: source);
      expect(doc.lines.first.cachedError, isNotNull, reason: source);
    }
  });

  test('a same-named scalar binds beside a builtin without replacing its call',
      () async {
    final doc = document(['sec=2', 'plot(sec(x)+sec)']);
    await evaluator().evaluateAll(doc);
    expect(doc.lines.last.cachedError, isNull);
    final spec = PlotSpec.tryParse(doc.lines.last.cachedResult)!;
    expect(SymbolicExpressionEvaluator.tryParse(spec.expression)!.key,
        SymbolicExpressionEvaluator.tryParse('sec(x)+2')!.key);

    // Force the ordered symbolic-value path as well as numeric substitution.
    final symbolic = preprocessNotepadLine(
        classifyNotepadLine('sec (x)+sec',
            lineIndex: 1, firstCodeLineIndex: 0),
        doc: document(['1', 'sec (x)+sec']),
        lineIndex: 1,
        scope: {'sec': 'a+1', 'a': '1'});
    expect(SymbolicExpressionEvaluator.tryParse(symbolic!)!.key,
        SymbolicExpressionEvaluator.tryParse('sec(x)+2')!.key);
  });

  test('callee protection preserves local expansion and calculus variables',
      () async {
    final doc = document(['a=2', 'sec(t)=a*t', 'plot(sec(x))']);
    final engine = evaluator();
    await engine.evaluateAll(doc);
    expect(at(PlotSpec.tryParse(doc.lines.last.cachedResult)!, 2), 4);
    expect(buildDependencyGraph(doc).dependsOn[2], {1});
    doc.lines.first.source = 'a=3';
    await engine.evaluateFrom(doc, 0);
    expect(at(PlotSpec.tryParse(doc.lines.last.cachedResult)!, 2), 6);

    const source = 'diff(sec(x)+sec,x)+sec';
    final protected = preprocessNotepadLine(
        classifyNotepadLine(source, lineIndex: 0, firstCodeLineIndex: 0),
        doc: document([source]),
        lineIndex: 0,
        scope: {'sec': '2', 'x': '100'});
    expect(protected, 'diff(sec(x)+(2),x)+(2)');
  });

  test('builtin-only calls do not depend on a same-named failed scalar',
      () async {
    final doc = document(['sec=1/0', 'plot(sec(x))', 'plot(sec(x)+sec)']);
    await evaluator().evaluateAll(doc);
    expect(doc.lines.first.cachedError, isNotNull);
    expect(doc.lines[1].cachedError, isNull);
    expect(PlotSpec.tryParse(doc.lines[1].cachedResult)!.expression, 'sec(x)');
    expect(buildDependencyGraph(doc).dependsOn[1], isEmpty);
    expect(resolveLinkedGraph(doc, doc.lines[1].id).scope, isEmpty);
    expect(doc.lines.last.cachedResult, isNull);
    expect(doc.lines.last.cachedError,
        NotepadErrorPrefix.blocked(doc.lines.first.id, 'line1'));
  });

  test('an unrelated failed scalar does not capture the plot coordinate',
      () async {
    final doc = document(['t=1/0', 'plot(t^2,t,-2,2) // independent coordinate']);
    await evaluator().evaluateAll(doc);
    expect(doc.lines.first.cachedError, isNotNull);
    expect(doc.lines.last.cachedError, isNull);
    expect(at(PlotSpec.tryParse(doc.lines.last.cachedResult)!, 3), 9);
  });

  test('numeric range expressions and declared imports agree with graph links',
      () async {
    final doc = document(['use a, r', 'plot(a*t,t,-sqrt(r),2*pi)']);
    const globals = {'a': '3', 'r': '4', 'unimported': '100'};
    await evaluator(imports: {'a': '3', 'r': '4'}).evaluateAll(doc);
    final spec = PlotSpec.tryParse(doc.lines.last.cachedResult)!;
    expect(spec.lo, -2);
    expect(spec.hi, closeTo(6.283185307179586, 1e-14));
    expect(at(spec, 2), 6);
    final linked = resolveLinkedGraph(doc, doc.lines.last.id, globals: globals);
    expect(linked.expression, spec.graphExpression);
    expect(linked.plot!.hi, spec.hi);
    expect(linked.scope, {'a': '3', 'r': '4'});
  });

  test('plots and headings do not become Ans or line aliases', () async {
    final doc = document(['a=3', 'plot(x)', '## Result', '---', 'Ans+2']);
    final engine = evaluator();
    await engine.evaluateAll(doc);
    expect(doc.lines.last.cachedResult, '5');
    expect(buildDependencyGraph(doc).dependsOn[4], {0});
    expect(buildNotepadScope(doc), isNot(contains('line2')));
    doc.lines.first.source = 'a=5';
    await engine.evaluateFrom(doc, 0);
    expect(doc.lines.last.cachedResult, '7');
    final linked = resolveLinkedGraph(doc, doc.lines.last.id);
    expect(NumericFallbackEvaluator.evalNumeric(linked.expression!), 7);
  });

  test('Ans in a plot interval tracks the prior answer across other plots',
      () async {
    final doc = document(['a=2', 'plot(x)', 'plot(x,x,-Ans,Ans)']);
    final engine = evaluator();
    await engine.evaluateAll(doc);
    expect(PlotSpec.tryParse(doc.lines.last.cachedResult)!.hi, 2);
    expect(buildDependencyGraph(doc).dependsOn[2], {0});
    doc.lines.first.source = 'a=4';
    await engine.evaluateFrom(doc, 0);
    expect(PlotSpec.tryParse(doc.lines.last.cachedResult)!.hi, 4);
  });

  test('saved source recomputes plots without trusting an old sentinel',
      () async {
    final doc = document(['a=2', 'plot(a*x,x,-3,3)']);
    await evaluator().evaluateAll(doc);
    final restored = NotepadDocument.fromJson(
        jsonDecode(jsonEncode(doc.toJson())) as Map<String, dynamic>);
    restored.lines.first.source = 'a=4';
    await evaluator().evaluateAll(restored);
    expect(at(PlotSpec.tryParse(restored.lines.last.cachedResult)!, 3), 12);
  });

  test('latest binding owns the plot even if an older definition failed',
      () async {
    final doc = document(['a=1/0', 'a=3', 'plot(a*x)']);
    await evaluator().evaluateAll(doc);
    expect(doc.lines.last.cachedError, isNull);
    expect(at(PlotSpec.tryParse(doc.lines.last.cachedResult)!, 2), 6);
    expect(resolveLinkedGraph(doc, doc.lines.last.id).error, isNull);
  });

  test('plot transport is strict and coordinate normalization preserves numbers',
      () {
    const spec = PlotSpec(expression: '1e-3*t+tan(t)', variable: 't', lo: -2, hi: 2);
    expect(spec.graphExpression, '1e-3*x+tan(x)');
    expect(PlotSpec.tryParse(spec.toSentinel())!.graphExpression,
        spec.graphExpression);
    for (final invalid in [
      '__plot__:x|x|NaN|2',
      '__plot__:x|x|-2|Infinity',
      '__plot__:x|x|2|2',
      '__plot__:x|x|0|1e-20',
      '__plot__:x|x|-1e20|1e20',
      '__plot__:x|x|-2|2|extra',
      '__plot__:|x|-2|2',
      '__plot__:x|x+y|-2|2',
    ]) {
      expect(PlotSpec.tryParse(invalid), isNull, reason: invalid);
    }
  });
}

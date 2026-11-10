import 'dart:async';
import 'dart:ui' as ui;

import 'package:crisp_math/engine/calculator_engine.dart';
import 'package:crisp_math/engine/graph_sampling.dart';
import 'package:crisp_math/localization/app_localizations.dart';
import 'package:crisp_math/widgets/mini_plot_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _NoUiEvaluationEngine extends CalculatorEngine {
  int calls = 0;

  @override
  String evaluate(String expression) {
    calls++;
    throw StateError('Inline sampling must not evaluate on the UI thread.');
  }

  @override
  String substitute(String expression, String variable, String value) {
    calls++;
    throw StateError('Inline sampling must not substitute on the UI thread.');
  }
}

void main() {
  late _NoUiEvaluationEngine engine;
  setUp(() => engine = _NoUiEvaluationEngine());

  PlotSpec spec({String expression = 't^2', double lo = -2, double hi = 2}) =>
      PlotSpec(expression: expression, variable: 't', lo: lo, hi: hi);

  const curve = GraphSamples(curves: [
    [(x: -2, y: 4, ok: true), (x: 0, y: 0, ok: true), (x: 2, y: 4, ok: true)]
  ]);

  Widget app(
    PlotSpec plot,
    Future<GraphSamples> Function(Map<String, dynamic>) sampler, {
    VoidCallback? onOpenGraph,
    double width = 260,
    bool enabled = true,
  }) =>
      MaterialApp(
        localizationsDelegates: const [AppLocalizationsDelegate()],
        theme: ThemeData(colorScheme: const ColorScheme.light(primary: Colors.red)),
        home: Scaffold(
          body: TickerMode(
            enabled: enabled,
            child: Center(
              child: SizedBox(
                width: width,
                child: MiniPlotWidget(
                  spec: plot,
                  engine: engine,
                  sampler: sampler,
                  onOpenGraph: onOpenGraph,
                ),
              ),
            ),
          ),
        ),
      );

  testWidgets('sampling is asynchronous and unchanged rebuilds reuse geometry',
      (tester) async {
    final pending = Completer<GraphSamples>();
    final requests = <Map<String, dynamic>>[];
    Future<GraphSamples> sample(Map<String, dynamic> request) {
      requests.add(request);
      return pending.future;
    }

    await tester.pumpWidget(app(spec(), sample));
    expect(find.text('Updating graph'), findsOneWidget);
    expect(requests, hasLength(1));
    expect(requests.single['functions'], ['x^2']);
    expect(requests.single['xMin'], -2);
    expect(requests.single['xMax'], 2);
    expect(find.text('-2 ≤ t ≤ 2'), findsOneWidget);
    await tester.pumpWidget(app(spec(), sample));
    expect(requests, hasLength(1));

    pending.complete(curve);
    await tester.pump();
    expect(find.byKey(const ValueKey('notepad-mini-plot-canvas')), findsOneWidget);
    expect(find.text('Updating graph'), findsNothing);
    await tester.pumpWidget(app(spec(), sample));
    expect(requests, hasLength(1));
    expect(engine.calls, 0);
  });

  testWidgets('a previous request cannot draw over a changed expression',
      (tester) async {
    final first = Completer<GraphSamples>();
    final second = Completer<GraphSamples>();
    var requests = 0;
    Future<GraphSamples> sample(Map<String, dynamic> _) =>
        ++requests == 1 ? first.future : second.future;

    await tester.pumpWidget(app(spec(), sample));
    await tester.pumpWidget(app(spec(expression: 'sqrt(-t^2-1)'), sample));
    expect(requests, 2);
    first.complete(curve);
    await tester.pump();
    expect(find.text('Updating graph'), findsOneWidget);
    expect(find.byKey(const ValueKey('notepad-mini-plot-canvas')), findsNothing);

    second.complete(const GraphSamples(curves: [
      [(x: -2, y: 0, ok: false), (x: 2, y: 0, ok: false)]
    ]));
    await tester.pump();
    expect(find.textContaining('No real values in this range'), findsOneWidget);
    expect(find.byKey(const ValueKey('notepad-mini-plot-canvas')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('hidden plots defer changed expressions until visible',
      (tester) async {
    final requests = <Map<String, dynamic>>[];
    Future<GraphSamples> sample(Map<String, dynamic> request) async {
      requests.add(request);
      return curve;
    }

    await tester.pumpWidget(app(spec(), sample));
    await tester.pumpAndSettle();
    expect(requests, hasLength(1));
    await tester.pumpWidget(app(spec(), sample, enabled: false));
    // Hiding a completed chart does not discard its useful geometry.
    expect(find.byKey(const ValueKey('notepad-mini-plot-canvas')), findsOneWidget);
    await tester.pumpWidget(app(spec(), sample));
    expect(requests, hasLength(1));
    // Changing both visibility and expression in one frame must also defer.
    await tester.pumpWidget(app(spec(expression: '3*t^2'), sample, enabled: false));
    expect(requests, hasLength(1));
    await tester.pumpWidget(app(spec(expression: '3*t^2'), sample));
    await tester.pumpAndSettle();
    expect(requests, hasLength(2));
    expect(requests.last['functions'], ['3*x^2']);
    expect(find.byKey(const ValueKey('notepad-mini-plot-canvas')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('invalid intervals fail visibly without starting a worker',
      (tester) async {
    var requests = 0;
    Future<GraphSamples> sample(Map<String, dynamic> _) async {
      requests++;
      return curve;
    }

    await tester.pumpWidget(app(spec(lo: 2, hi: -2), sample));
    await tester.pump();
    expect(requests, 0);
    expect(find.text('Could not update the graph.'), findsOneWidget);
    expect(find.byKey(const ValueKey('notepad-mini-plot-canvas')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('worker failure is visible and Retry starts a fresh request',
      (tester) async {
    final first = Completer<GraphSamples>();
    final second = Completer<GraphSamples>();
    var requests = 0;
    Future<GraphSamples> sample(Map<String, dynamic> _) =>
        ++requests == 1 ? first.future : second.future;

    await tester.pumpWidget(app(spec(), sample));
    first.completeError(StateError('Worker failed'));
    await tester.pump();
    expect(find.text('Could not update the graph.'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(requests, 2);
    expect(find.text('Updating graph'), findsOneWidget);
    second.complete(curve);
    await tester.pump();
    expect(find.byKey(const ValueKey('notepad-mini-plot-canvas')), findsOneWidget);
    expect(find.text('Retry'), findsNothing);
  });

  testWidgets('tap and keyboard can open the connected full graph',
      (tester) async {
    var opened = 0;
    Future<GraphSamples> sample(Map<String, dynamic> _) async => curve;
    await tester.pumpWidget(app(spec(), sample, onOpenGraph: () => opened++));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('notepad-mini-plot-canvas')));
    expect(opened, 1);
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(opened, 2);
    expect(find.text('View linked graph'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('late worker failure after removing a row is ignored',
      (tester) async {
    final pending = Completer<GraphSamples>();
    await tester.pumpWidget(app(spec(), (_) => pending.future));
    await tester.pumpWidget(const SizedBox.shrink());
    pending.completeError(StateError('Late worker failure'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('undefined samples leave a visible gap between valid segments',
      (tester) async {
    Future<GraphSamples> sample(Map<String, dynamic> _) async =>
        const GraphSamples(curves: [
          [
            (x: 0, y: 1, ok: true),
            (x: 1, y: 1, ok: true),
            (x: 2, y: 0, ok: false),
            (x: 3, y: 1, ok: true),
            (x: 4, y: 1, ok: true),
          ]
        ]);
    await tester.pumpWidget(app(spec(lo: 0, hi: 4), sample, width: 200));
    await tester.pumpAndSettle();
    final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(const ValueKey('notepad-mini-plot-canvas')));
    final pixels = await tester.runAsync(() async {
      final image = await boundary.toImage();
      final bytes = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!
          .buffer
          .asUint8List();
      List<int> pixel(int x) {
        final offset = ((image.height ~/ 2) * image.width + x) * 4;
        return bytes.sublist(offset, offset + 4);
      }

      final result = [pixel(image.width ~/ 8), pixel(image.width ~/ 2)];
      image.dispose();
      return result;
    });
    final curvePixel = pixels![0], gapPixel = pixels[1];
    expect(curvePixel[0], greaterThan(curvePixel[1]));
    expect(curvePixel[3], greaterThan(0));
    expect(gapPixel[3], 0,
        reason: 'No curve segment may bridge an undefined sample.');
  });
}

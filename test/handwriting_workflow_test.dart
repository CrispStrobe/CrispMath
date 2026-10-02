import 'dart:typed_data';

import 'package:crisp_math/engine/ocr_provider.dart';
import 'package:crisp_math/widgets/drawing_canvas.dart';
import 'package:crisp_math/widgets/handwriting_input_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class InkProvider extends OcrProvider implements HandwritingOcrProvider {
  @override
  final String name;
  @override
  final bool requiresNetwork;
  @override
  final bool supportsHandwriting;
  @override
  final String? licenseToAccept;
  @override
  bool get isAvailable => true;
  @override
  bool get requiresApiKey => requiresNetwork;
  int calls = 0;
  Uint8List? pixels;
  InkProvider(this.name,
      {this.requiresNetwork = false,
      this.supportsHandwriting = true,
      this.licenseToAccept});
  @override
  Future<OcrResult?> recognize(Uint8List imageBytes, int width, int height,
      {void Function(int, int, double, double, double, double)?
          onProgress}) async {
    calls++;
    pixels = imageBytes;
    return OcrResult(text: '2+3', rawOutput: '2+3', providerName: name);
  }
}

void main() {
  tearDown(() => OcrProviders.active = null);
  test(
      'handwriting selection prefers compatible local models without changing photo selection',
      () {
    final printed = InkProvider('Printed', supportsHandwriting: false);
    final cloud = InkProvider('Cloud', requiresNetwork: true);
    final local = InkProvider('Ink');
    OcrProviders.active = printed;
    expect(
        selectHandwritingProvider([printed, cloud, local], preferred: printed),
        local);
    expect(selectHandwritingProvider([printed], preferred: printed), isNull);
    expect(OcrProviders.active, printed);
  });
  test('dark theme strokes export as visible black ink on white paper', () {
    final pixels = renderDrawingRgba([
      Stroke(
          points: [const Offset(0, 0), const Offset(100, 50)],
          color: Colors.white)
    ], 384, 384);
    final ink = [for (var i = 0; i < pixels.length; i += 4) pixels[i]];
    expect(ink.any((value) => value == 0), isTrue);
    expect(ink.any((value) => value == 255), isTrue);
  });
  test('rectangular target preserves square geometry and single-point dots',
      () {
    final pixels = renderDrawingRgba([
      Stroke(points: [
        const Offset(0, 0),
        const Offset(100, 0),
        const Offset(100, 100),
        const Offset(0, 100),
        const Offset(0, 0)
      ])
    ], 400, 100);
    final black = <Offset>[];
    for (var i = 0; i < 400 * 100; i++) {
      if (pixels[i * 4] < 100) {
        black.add(Offset((i % 400).toDouble(), (i ~/ 400).toDouble()));
      }
    }
    final xs = black.map((p) => p.dx).toList()..sort();
    final ys = black.map((p) => p.dy).toList()..sort();
    expect((xs.last - xs.first) / (ys.last - ys.first), closeTo(1, .05));
    final dot = renderDrawingRgba([
      Stroke(points: [const Offset(40, 20)])
    ], 100, 100);
    expect(
        [for (var i = 0; i < dot.length; i += 4) dot[i]].contains(0), isTrue);
    expect(() => renderDrawingRgba([], 0, 100), throwsArgumentError);
  });
  Future<void> open(WidgetTester tester, List<OcrProvider> providers) async {
    await tester.binding.setSurfaceSize(const Size(390, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
            body: Builder(
                builder: (context) => TextButton(
                    onPressed: () => showDialog<void>(
                        context: context,
                        builder: (_) =>
                            HandwritingInputDialog(providers: providers)),
                    child: const Text('Open'))))));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.byType(DrawingCanvas));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Recognize'));
    await tester.pumpAndSettle();
  }

  testWidgets('cloud ink requires confirmation and cancellation sends nothing',
      (tester) async {
    final cloud = InkProvider('Cloud fixture', requiresNetwork: true);
    await open(tester, [cloud]);
    expect(find.text('Send drawing to cloud?'), findsOneWidget);
    expect(cloud.calls, 0);
    await tester.tap(find.text('Cancel').last);
    await tester.pumpAndSettle();
    expect(cloud.calls, 0);
    expect(tester.takeException(), isNull);
  });
  testWidgets('model terms are checked before downloading or recognition',
      (tester) async {
    final model =
        InkProvider('Licensed fixture', licenseToAccept: 'CC BY-NC-SA 3.0');
    await open(tester, [model]);
    expect(find.text('Model usage terms'), findsOneWidget);
    expect(model.calls, 0);
    await tester.tap(find.text('Cancel').last);
    await tester.pumpAndSettle();
    expect(model.calls, 0);
  });
  testWidgets(
      'local ink opens editable review without mutating the printed choice',
      (tester) async {
    final printed = InkProvider('Printed', supportsHandwriting: false);
    final ink = InkProvider('Local fixture');
    OcrProviders.active = printed;
    await open(tester, [printed, ink]);
    expect(ink.calls, 1);
    expect(ink.pixels!.any((value) => value < 100), isTrue);
    expect(find.text('Insert'), findsOneWidget);
    expect(OcrProviders.active, printed);
    expect(tester.takeException(), isNull);
  });
}

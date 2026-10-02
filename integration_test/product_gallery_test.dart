import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:crisp_math/engine/app_state.dart';
import 'package:crisp_math/engine/calculator_engine.dart';
import 'package:crisp_math/engine/notepad.dart';
import 'package:crisp_math/engine/notepad_evaluator.dart';
import 'package:crisp_math/main.dart';
import 'package:crisp_math/widgets/drawing_canvas.dart';
import 'package:crisp_math/services/engine_dispatch.dart';
import 'package:crisp_math/services/engine_op.dart';
import 'package:crisp_math/services/notepad_dispatcher.dart';
import 'package:crisp_math/screens/graphing_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('real native calculation, worksheet and linked graph gallery',
      (tester) async {
    SharedPreferences.setMockInitialValues(
        {'crisp.onboardingDismissed': true, 'crisp.locale': 'en'});
    final state = AppState();
    await state.load(force: true);
    final engine = CalculatorEngine();
    expect(engine.isNativeAvailable, isTrue,
        reason: 'Native CAS must actually link');
    final nativeDerivative = engine.differentiate('sin(x)', 'x');
    expect(nativeDerivative, 'cos(x)',
        reason: 'Exercise a native transcendental CAS operation');
    final integral = runEngineOpDetailed(
        engine, const EngineOp('integrate', 'x^2', 'x', '0', '1'));
    expect(integral.value, '1/3');
    state.addHistoryEntry('integrate(x^2,x,0,1)', integral.value,
        resultEvidence: integral.evidence);
    final doc = NotepadDocument.fresh(name: 'Explore a function');
    doc.lines.clear();
    for (final source in [
      '## Explore a function',
      'a=3',
      'f=a*sin(x)',
      'integrate(x^2,x,0,1)'
    ]) {
      doc.lines.add(NotepadLine.fresh(source: source));
    }
    final dispatcher = NotepadDispatcher(formatNumber: state.formatNumber);
    await NotepadEvaluator(
            dispatcher: dispatcher.evaluate,
            detailedDispatcher: dispatcher.evaluateDetailed)
        .evaluateAll(doc);
    expect(doc.lines[1].cachedResult, '3');
    expect(doc.lines[3].cachedResult, '1/3');
    expect(doc.lines.any((l) => l.cachedError != null), isFalse);
    state.setNotepadDocument(doc);
    state.setCurrentNotepadDoc(doc.id);
    state.linkNotepadLine(doc.id, doc.lines[2].id);
    final galleryKey = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(
        key: galleryKey, child: const CrispMathApp()));
    if (Platform.isMacOS) {
      expect(await const MethodChannel('crispmath/native_gallery')
          .invokeMethod<bool>('sizeWindow'), isTrue);
    }
    final desktopImages = <Map<String, dynamic>>[];
    Future<void> screenshot(String name) async {
      if (!Platform.isMacOS) {
        await binding.takeScreenshot(name);
        return;
      }
      // Capture the actual native Flutter render tree, including dialogs and
      // sampled graph geometry, rather than an HTML replica or a mock view.
      final boundary = galleryKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      expect(bytes, isNotNull);
      desktopImages.add({'name': name,
        'pngBase64': base64Encode(bytes!.buffer.asUint8List()),
        'width': image.width, 'height': image.height});
      image.dispose();
    }
    Future<void> settle() async {
      for (var i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(tester.takeException(), isNull);
    }

    await settle();
    await screenshot('calculator-exact-integral');
    await tester.tap(find.text('Notepad').first);
    await settle();
    await screenshot('connected-worksheet');
    await tester.tap(find.text('Graphing').first);
    await settle();
    Future<void> populatedGraph({int minimumCurves = 1}) async {
      var ready = false;
      for (var i = 0; i < 100; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        ready = tester.widgetList<CustomPaint>(find.byType(CustomPaint))
            .map((widget) => widget.painter)
            .whereType<GraphPainter>()
            .any((painter) => painter.samples.curves.length >= minimumCurves &&
                painter.samples.curves.every((curve) =>
                    curve.where((point) => point.ok).length >= 30));
        if (ready) break;
      }
      expect(ready, isTrue, reason: 'Visible graph must contain real samples');
      expect(tester.takeException(), isNull);
    }
    await populatedGraph();
    await screenshot('linked-function-graph');
    state.updateFunction(1, 'x^2-2');
    // Preserve the worksheet-linked slot when adding comparison curves.
    state.updateFunction(0, 'cos(x)');
    await settle();
    await populatedGraph(minimumCurves: 3);
    await screenshot('multiple-function-graph');
    await tester.tap(find.byTooltip('Trace curve'));
    await settle();
    await populatedGraph();
    expect(find.textContaining('x = '), findsWidgets);
    expect(find.text('Trace: waiting for samples'), findsNothing);
    await screenshot('graph-curve-trace');
    await tester.tap(find.byTooltip('Value table'));
    await settle();
    await tester.tap(find.text('Generate table'));
    for (var i = 0; i < 100; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (tester.widgetList<SelectableText>(find.byType(SelectableText))
          .any((text) => (text.data ?? '').contains('\t'))) {
        break;
      }
    }
    expect(tester.widgetList<SelectableText>(find.byType(SelectableText))
        .any((text) => (text.data ?? '').split('\n').length >= 10), isTrue);
    await screenshot('generated-graph-value-table');
    await tester.tap(find.text('Close').last);
    await settle();
    final workflow = Uri(
        scheme: 'crispmath',
        host: 'worksheet',
        queryParameters: {
          'name': 'Shortcuts worksheet',
          'lines': 'a=3\nf(t)=t^2+a\nf(4)'
        });
    final workflowSupported = Platform.isIOS;
    if (workflowSupported) {
      expect(await launchUrl(workflow, mode: LaunchMode.externalApplication),
          isTrue);
    } else {
      // macOS has no registered worksheet URL handler yet. Exercise the same
      // native evaluator and real worksheet screen without claiming URL support.
      final shortcutDoc = NotepadDocument.fresh(name: 'Shortcuts worksheet');
      shortcutDoc.lines.clear();
      for (final source in ['a=3', 'f(t)=t^2+a', 'f(4)']) {
        shortcutDoc.lines.add(NotepadLine.fresh(source: source));
      }
      await NotepadEvaluator(dispatcher: dispatcher.evaluate,
          detailedDispatcher: dispatcher.evaluateDetailed).evaluateAll(shortcutDoc);
      state.setNotepadDocument(shortcutDoc);
      state.setCurrentNotepadDoc(shortcutDoc.id);
      await tester.tap(find.text('Notepad').first);
    }
    var workflowPassed = false;
    for (var i = 0; i < 150; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      final current = state.notepadDocuments[state.currentNotepadDocId];
      if (current?.name == 'Shortcuts worksheet' &&
          current!.lines.last.cachedResult == '19') {
        workflowPassed = true;
        break;
      }
    }
    expect(workflowPassed, isTrue,
        reason: 'Native worksheet must evaluate to 19');
    expect(tester.takeException(), isNull);
    await screenshot('shortcuts-created-worksheet');
    final engineering = NotepadDocument.fresh(name: 'Design a circular tank');
    engineering.lines.clear();
    for (final source in ['## Circular tank', 'r=3', 'h=5',
      'area=pi*r^2', 'volume=area*h', 'volume/1000']) {
      engineering.lines.add(NotepadLine.fresh(source: source));
    }
    await NotepadEvaluator(dispatcher: dispatcher.evaluate,
        detailedDispatcher: dispatcher.evaluateDetailed).evaluateAll(engineering);
    expect(engineering.lines.any((line) => line.cachedError != null), isFalse);
    expect(engineering.lines[2].cachedResult, '5');
    expect(engineering.lines[4].cachedResult, isNotEmpty);
    state.setNotepadDocument(engineering);
    state.setCurrentNotepadDoc(engineering.id);
    await settle();
    await screenshot('evaluated-engineering-worksheet');
    state.setCurrentNotepadDoc(doc.id);
    await settle();
    Future<void> menu(String label) async {
      await tester.tap(find.byTooltip('Document menu'));
      await settle();
      await tester.ensureVisible(find.text(label).last);
      await tester.tap(find.text(label).last);
      await settle();
    }

    expect(state.graphLinks.values.any((link) => link.documentId == doc.id),
        isTrue, reason: 'Export must retain the worksheet graph link');
    await menu('Worksheet export preview');
    expect(find.text('Save HTML'), findsOneWidget);
    await tester.drag(find.byType(ListView).last, const Offset(0, -120));
    await settle();
    await screenshot('worksheet-graph-export-preview');
    await tester.tap(find.text('Close').last);
    await settle();
    await menu('Document history');
    await tester.tap(find.text('Save checkpoint'));
    await settle();
    expect(find.text('Compare'), findsOneWidget);
    await screenshot('worksheet-checkpoint-history');
    await tester.tap(find.text('Close').last);
    await settle();
    final write = find.byTooltip('Write math');
    if (write.evaluate().isNotEmpty) {
      await tester.tap(write);
      await settle();
    } else {
      await menu('Write math');
    }
    final paper = find.byType(DrawingCanvas);
    expect(paper, findsOneWidget);
    final rect = tester.getRect(paper);
    Future<void> stroke(List<Offset> points) async {
      Offset position(Offset point) => rect.topLeft +
          Offset(rect.width * point.dx, rect.height * point.dy);
      final gesture = await tester.startGesture(position(points.first));
      for (final point in points.skip(1)) {
        await gesture.moveTo(position(point));
        await tester.pump(const Duration(milliseconds: 40));
      }
      await gesture.up();
    }
    // Actual pen gestures write x² + 1, rather than a blank recognition panel.
    await stroke([const Offset(.20, .40), const Offset(.36, .65)]);
    await stroke([const Offset(.36, .40), const Offset(.20, .65)]);
    await stroke([const Offset(.40, .30), const Offset(.44, .25),
      const Offset(.48, .29), const Offset(.40, .40), const Offset(.49, .40)]);
    await stroke([const Offset(.57, .52), const Offset(.72, .52)]);
    await stroke([const Offset(.645, .41), const Offset(.645, .63)]);
    await stroke([const Offset(.79, .44), const Offset(.83, .40),
      const Offset(.83, .65)]);
    await settle();
    expect(tester.state<DrawingCanvasState>(paper).strokeCount,
        greaterThanOrEqualTo(6));
    await screenshot('handwriting-editable-input');
    binding.reportData ??= {};
    binding.reportData!['nativeBridge'] = engine.isNativeAvailable;
    binding.reportData!['nativeDerivative'] = nativeDerivative;
    binding.reportData!['integral'] = integral.toJson();
    binding.reportData!['document'] = doc.toJson();
    binding.reportData!['nativeWorkflowUrl'] = workflowSupported && workflowPassed;
    binding.reportData!['nativeWorkflowUrlSupported'] = workflowSupported;
    binding.reportData!['populatedGraph'] = true;
    binding.reportData!['graphTrace'] = true;
    binding.reportData!['generatedValueTable'] = true;
    binding.reportData!['engineeringWorksheet'] = engineering.toJson();
    binding.reportData!['captureKind'] = Platform.isMacOS
        ? 'native-macos-render-tree' : 'native-ios-simulator';
    binding.reportData!['desktopImages'] = desktopImages;
    binding.reportData!['exportPreview'] = true;
    binding.reportData!['historyCheckpoint'] = true;
    binding.reportData!['handwritingInput'] = true;
  });
}

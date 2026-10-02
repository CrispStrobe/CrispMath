import 'package:crisp_math/engine/app_state.dart';
import 'package:crisp_math/engine/calculator_engine.dart';
import 'package:crisp_math/engine/notepad.dart';
import 'package:crisp_math/engine/notepad_evaluator.dart';
import 'package:crisp_math/main.dart';
import 'package:crisp_math/widgets/drawing_canvas.dart';
import 'package:crisp_math/services/engine_dispatch.dart';
import 'package:crisp_math/services/engine_op.dart';
import 'package:crisp_math/services/notepad_dispatcher.dart';
import 'package:flutter/widgets.dart' show ListView;
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
    await tester.pumpWidget(const CrispMathApp());
    Future<void> settle() async {
      for (var i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(tester.takeException(), isNull);
    }

    await settle();
    await binding.takeScreenshot('calculator-exact-integral');
    await tester.tap(find.text('Notepad').first);
    await settle();
    await binding.takeScreenshot('connected-worksheet');
    await tester.tap(find.text('Graphing').first);
    await settle();
    await binding.takeScreenshot('linked-function-graph');
    final workflow = Uri(
        scheme: 'crispmath',
        host: 'worksheet',
        queryParameters: {
          'name': 'Shortcuts worksheet',
          'lines': 'a=3\nf(t)=t^2+a\nf(4)'
        });
    expect(await launchUrl(workflow, mode: LaunchMode.externalApplication),
        isTrue);
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
        reason: 'Native URL must reach Flutter and calculate the worksheet');
    expect(tester.takeException(), isNull);
    await binding.takeScreenshot('shortcuts-created-worksheet');
    state.setCurrentNotepadDoc(doc.id);
    await settle();
    Future<void> menu(String label) async {
      await tester.tap(find.byTooltip('Document menu'));
      await settle();
      await tester.ensureVisible(find.text(label).last);
      await tester.tap(find.text(label).last);
      await settle();
    }

    await menu('Worksheet export preview');
    expect(find.text('Save HTML'), findsOneWidget);
    await tester.drag(find.byType(ListView).last, const Offset(0, -120));
    await settle();
    await binding.takeScreenshot('worksheet-graph-export-preview');
    await tester.tap(find.text('Close').last);
    await settle();
    await menu('Document history');
    await tester.tap(find.text('Save checkpoint'));
    await settle();
    expect(find.text('Compare'), findsOneWidget);
    await binding.takeScreenshot('worksheet-checkpoint-history');
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
    final start = rect.topLeft + Offset(rect.width * .25, rect.height * .4);
    await tester.dragFrom(start, Offset(rect.width * .4, rect.height * .15));
    await tester.tapAt(rect.center);
    await settle();
    await binding.takeScreenshot('handwriting-editable-input');
    binding.reportData ??= {};
    binding.reportData!['nativeBridge'] = engine.isNativeAvailable;
    binding.reportData!['nativeDerivative'] = nativeDerivative;
    binding.reportData!['integral'] = integral.toJson();
    binding.reportData!['document'] = doc.toJson();
    binding.reportData!['nativeWorkflowUrl'] = workflowPassed;
    binding.reportData!['exportPreview'] = true;
    binding.reportData!['historyCheckpoint'] = true;
    binding.reportData!['handwritingInput'] = true;
  });
}

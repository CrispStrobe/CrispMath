import 'package:crisp_math/engine/app_state.dart';
import 'package:crisp_math/engine/calculator_engine.dart';
import 'package:crisp_math/engine/notepad.dart';
import 'package:crisp_math/engine/notepad_evaluator.dart';
import 'package:crisp_math/main.dart';
import 'package:crisp_math/services/engine_dispatch.dart';
import 'package:crisp_math/services/engine_op.dart';
import 'package:crisp_math/services/notepad_dispatcher.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    binding.reportData ??= {};
    binding.reportData!['nativeBridge'] = engine.isNativeAvailable;
    binding.reportData!['nativeDerivative'] = nativeDerivative;
    binding.reportData!['integral'] = integral.toJson();
    binding.reportData!['document'] = doc.toJson();
  });
}

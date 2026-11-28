// The calculator's math input is a custom widget, not a TextField, so it
// gets clipboard commands explicitly: controller helpers, a right-click /
// long-press menu, and (via Actions) the macOS Edit menu's intents.

import 'package:crisp_math/controllers/latex_controller.dart';
import 'package:crisp_math/widgets/calculator_input_bar.dart';
import 'package:crisp_math/widgets/latex_input_field.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late String? clipboard;

  setUp(() {
    clipboard = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        clipboard = (call.arguments as Map)['text'] as String?;
      } else if (call.method == 'Clipboard.getData') {
        return clipboard == null ? null : {'text': clipboard};
      }
      return null;
    });
  });

  test('copy, cut and paste use the whole input without a selection', () async {
    final c = LatexController()..insert('2+3');
    await c.copyToClipboard();
    expect(clipboard, '2+3');
    expect(c.text, '2+3');
    await c.cutToClipboard();
    expect(c.text, '');
    clipboard = '4*5\n';
    await c.pasteFromClipboard();
    expect(c.text, '4*5');
    expect(c.selection, const TextSelection.collapsed(offset: 3));
  });

  test('paste inserts at the cursor and replaces a selection', () async {
    final c = LatexController()..insert('1+9');
    c.moveCursor(-1);
    clipboard = '2*';
    await c.pasteFromClipboard();
    expect(c.text, '1+2*9');
    c.selectAll();
    clipboard = '7';
    await c.pasteFromClipboard();
    expect(c.text, '7');
  });

  testWidgets('right-click on the math field offers paste', (tester) async {
    final c = LatexController();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Column(children: [
          CalculatorInputBar(
              controller: c, onResetFocus: () {}, onEvaluate: () {}),
        ]),
      ),
    ));
    await tester.pumpAndSettle();
    clipboard = 'sqrt(2)';
    final field = find.byType(LatexInputField);
    await tester.tapAt(tester.getCenter(field), buttons: kSecondaryButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Paste'));
    await tester.pumpAndSettle();
    expect(c.text, 'sqrt(2)');
  });

  testWidgets('Edit-menu intents reach the math input through Actions',
      (tester) async {
    final c = LatexController()..insert('8/2');
    final focus = FocusNode();
    addTearDown(focus.dispose);
    await tester.pumpWidget(MaterialApp(
      home: Actions(
        actions: <Type, Action<Intent>>{
          CopySelectionTextIntent: CallbackAction<CopySelectionTextIntent>(
              onInvoke: (i) => i.collapseSelection
                  ? c.cutToClipboard()
                  : c.copyToClipboard()),
          PasteTextIntent: CallbackAction<PasteTextIntent>(
              onInvoke: (_) => c.pasteFromClipboard()),
        },
        child:
            Focus(focusNode: focus, autofocus: true, child: const SizedBox()),
      ),
    ));
    await tester.pump();
    final ctx = FocusManager.instance.primaryFocus!.context!;
    Actions.invoke(ctx, CopySelectionTextIntent.copy);
    await tester.pump();
    expect(clipboard, '8/2');
    clipboard = '+1';
    Actions.invoke(ctx, const PasteTextIntent(SelectionChangedCause.keyboard));
    await tester.pump();
    expect(c.text, '8/2+1');
  });
}

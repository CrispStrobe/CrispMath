import 'dart:convert';

import 'package:crisp_math/engine/ai_output_attribution.dart';
import 'package:crisp_math/widgets/ai_content_notice.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('copy actions carry readable and structured origin', (
    tester,
  ) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData')
          copied = call.arguments['text'] as String;
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    final attribution = AiOutputAttribution.fromResponse(
      kind: AiOutputKind.generatedText,
      endpoint: 'https://example.test/v1',
      requestedModel: 'requested-only',
    );
    const content = 'Two equal parts.\nKeep this newline.\n';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              AiContentNotice(
                kind: AiOutputKind.generatedText,
                attribution: attribution,
              ),
              AiOutputCopyButton(
                content: content,
                attribution: attribution,
                complete: false,
              ),
            ],
          ),
        ),
      ),
    );
    expect(find.text('AI-generated explanation'), findsOneWidget);
    expect(
      find.textContaining('Requested model: requested-only'),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip('Copy with source'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Text with attribution'));
    await tester.pumpAndSettle();
    expect(copied, contains('AI-generated explanation'));
    expect(copied, contains('Partial or unconfirmed response'));
    expect(copied, endsWith(content));
    await tester.tap(find.byTooltip('Copy with source'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('JSON with attribution'));
    await tester.pumpAndSettle();
    expect(jsonDecode(copied!)['content'], content);
    expect(jsonDecode(copied!)['provenance']['origin'], 'ai_generated');
  });
}

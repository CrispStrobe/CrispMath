import 'dart:convert';
import 'package:crisp_math/widgets/ai_math_dialog.dart';
import 'package:crisp_math/services/ai_provider_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  testWidgets(
      'clarification remains a question and cannot be inserted into calculator',
      (tester) async {
    final service = ProviderAiService(
        config: () => const AiProviderConfig(
            endpoint: 'http://localhost/v1/chat/completions',
            model: 'test-model'),
        clientFactory: () => MockClient((_) async => http.Response(
            jsonEncode({
              'choices': [
                {
                  'message': {'content': 'CLARIFY: What is the radius?'}
                }
              ]
            }),
            200)));
    await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: AiMathDialog(service: service))));
    await tester.enterText(find.byType(TextField).first, 'circle area');
    await tester.tap(find.text('Translate'));
    await tester.pumpAndSettle();
    expect(find.textContaining('What is the radius?'), findsOneWidget);
    expect(find.text('Use in calculator'), findsNothing);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Translate'), findsOneWidget);
  });
  testWidgets('provider error supports retry and translation stays editable',
      (tester) async {
    var calls = 0;
    final service = ProviderAiService(
        config: () => const AiProviderConfig(
            endpoint: 'http://localhost/v1/chat/completions',
            model: 'test-model'),
        clientFactory: () => MockClient((_) async => ++calls == 1
            ? http.Response('bad', 503)
            : http.Response(
                jsonEncode({
                  'choices': [
                    {
                      'message': {'content': '2+2'}
                    }
                  ]
                }),
                200)));
    await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: AiMathDialog(service: service))));
    await tester.enterText(find.byType(TextField).first, 'two plus two');
    await tester.tap(find.text('Translate'));
    await tester.pumpAndSettle();
    expect(find.textContaining('HTTP 503'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Provider responded. Review or edit this expression:'),
        findsOneWidget);
    await tester.enterText(find.byType(TextField).last, '3+3');
    expect(find.text('Use in calculator'), findsOneWidget);
  });
}

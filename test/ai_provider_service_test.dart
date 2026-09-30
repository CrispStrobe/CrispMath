import 'dart:async';
import 'dart:convert';
import 'package:crisp_math/services/ai_provider_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test(
      'provider sends actual input, model and credentials and never calculates',
      () async {
    final requests = <Map<String, dynamic>>[];
    final service = ProviderAiService(
        config: () => const AiProviderConfig(
            endpoint: 'https://example.test/v1/chat/completions',
            model: 'configured-model',
            apiKey: 'test-key'),
        clientFactory: () => MockClient((request) async {
              expect(request.headers['Authorization'], 'Bearer test-key');
              final body = jsonDecode(request.body) as Map<String, dynamic>;
              requests.add(body);
              expect(body['model'], 'configured-model');
              return http.Response(
                  jsonEncode({
                    'choices': [
                      {
                        'message': {
                          'content': requests.length == 1
                              ? 'integrate(x^2,x)'
                              : 'diff(sin(x),x)'
                        }
                      }
                    ]
                  }),
                  200);
            }));
    expect(await service.processMathNLP('integrate x squared'),
        'integrate(x^2,x)');
    expect(
        await service.processMathNLP('differentiate sine'), 'diff(sin(x),x)');
    expect(requests[0]['messages'].last['content'], 'integrate x squared');
    expect(requests[1]['messages'].last['content'], 'differentiate sine');
  });
  test('Anthropic response and fenced expressions use the selected endpoint',
      () async {
    final service = ProviderAiService(
        config: () => const AiProviderConfig(
            endpoint: 'https://example.test/v1/messages',
            model: 'm',
            apiKey: 'k'),
        clientFactory: () => MockClient((r) async {
              expect(r.headers['x-api-key'], 'k');
              expect(jsonDecode(r.body)['system'], contains('Do not compute'));
              return http.Response(
                  jsonEncode({
                    'content': [
                      {'text': '```math\n2+2\n```'}
                    ]
                  }),
                  200);
            }));
    expect(await service.processMathNLP('two plus two'), '2+2');
  });
  test('configuration, HTTP and malformed response failures remain errors',
      () async {
    final unconfigured = ProviderAiService(
        config: () => const AiProviderConfig(endpoint: '', model: ''));
    expect(unconfigured.isReady, isFalse);
    await expectLater(unconfigured.processMathNLP('test'), throwsStateError);
    for (final response in [
      http.Response('{}', 200),
      http.Response('bad json', 200),
      http.Response('do not display this body', 401)
    ]) {
      final service = ProviderAiService(
          config: () => const AiProviderConfig(
              endpoint: 'http://localhost:1234/v1/chat/completions',
              model: 'local'),
          clientFactory: () => MockClient((_) async => response));
      await expectLater(service.processMathNLP('test'),
          throwsA(anyOf(isA<Exception>(), isA<StateError>())));
    }
  });
  test('cancel and timeout release a pending request and allow retry',
      () async {
    final pending = Completer<http.Response>();
    final service = ProviderAiService(
        config: () => const AiProviderConfig(
            endpoint: 'http://localhost:1234/v1/chat/completions',
            model: 'local'),
        clientFactory: () => MockClient((_) => pending.future));
    final result = service.processMathNLP('pending');
    final assertion = expectLater(result, throwsA(isA<AiRequestCancelled>()));
    service.cancel();
    await assertion;
    pending.complete(http.Response('{}', 200));
    final timeout = ProviderAiService(
        config: () => const AiProviderConfig(
            endpoint: 'http://localhost:1234/v1/chat/completions',
            model: 'local',
            timeout: Duration(milliseconds: 10)),
        clientFactory: () =>
            MockClient((_) => Completer<http.Response>().future));
    await expectLater(
        timeout.processMathNLP('pending'), throwsA(isA<TimeoutException>()));
  });
}

// lib/engine/ocr_cloud_llm_web.dart
//
// Web implementation of cloud LLM OCR — uses dart:js_interop fetch()
// instead of dart:io HttpClient. Selected via conditional import on web.

import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

import 'ocr_provider.dart';
import '../engine/app_state.dart';

// JS interop for fetch
@JS('_ccocrFetchJson')
external JSPromise _jsFetchJson(
    JSString url, JSString method, JSString headers, JSString body);

@JS('eval')
external void _jsEval(JSString code);

bool _fetchHelpersInjected = false;

void _injectFetchHelpers() {
  if (_fetchHelpersInjected) return;
  _jsEval('''
    window._ccocrFetchJson = function(url, method, headersJson, body) {
      var headers = JSON.parse(headersJson);
      return fetch(url, {
        method: method,
        headers: headers,
        body: body || undefined
      }).then(function(response) {
        return response.text().then(function(text) {
          return JSON.stringify({status: response.status, body: text});
        });
      }).catch(function(err) {
        return JSON.stringify({status: 0, body: err.toString()});
      });
    };
  '''
      .toJS);
  _fetchHelpersInjected = true;
}

/// Cloud LLM OCR provider for web — uses browser fetch() API.
class CloudLlmOcrProviderWeb implements OcrProvider {
  @override
  String get name => 'Cloud LLM (handwritten + printed)';

  @override
  bool get isAvailable => AppState().crispAssistEnabled;

  @override
  bool get requiresNetwork => true;

  @override
  bool get requiresApiKey => true;

  @override
  Future<OcrResult?> recognize(
      Uint8List imageBytes, int width, int height) async {
    final appState = AppState();
    if (!appState.crispAssistEnabled) return null;

    final apiUrl = appState.crispAssistApiUrl;
    final apiKey = appState.crispAssistApiKey;
    final model = appState.crispAssistModel;
    final isAnthropic = apiUrl.contains('anthropic');

    try {
      _injectFetchHelpers();

      final base64Image = base64Encode(imageBytes);
      const mimeType = 'image/png';

      final Map<String, String> headers;
      final String body;

      if (isAnthropic) {
        headers = {
          'Content-Type': 'application/json',
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01',
        };
        body = jsonEncode({
          'model': model,
          'max_tokens': 512,
          'temperature': 0.0,
          'messages': [
            {
              'role': 'user',
              'content': [
                {
                  'type': 'image',
                  'source': {
                    'type': 'base64',
                    'media_type': mimeType,
                    'data': base64Image,
                  },
                },
                {'type': 'text', 'text': _prompt},
              ],
            },
          ],
        });
      } else {
        headers = {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        };
        body = jsonEncode({
          'model': model,
          'max_tokens': 512,
          'temperature': 0.0,
          'messages': [
            {
              'role': 'user',
              'content': [
                {
                  'type': 'image_url',
                  'image_url': {
                    'url': 'data:$mimeType;base64,$base64Image',
                  },
                },
                {'type': 'text', 'text': _prompt},
              ],
            },
          ],
        });
      }

      final result = await _jsFetchJson(
        apiUrl.toJS,
        'POST'.toJS,
        jsonEncode(headers).toJS,
        body.toJS,
      ).toDart;

      if (result == null || result.isNull) return null;
      final responseStr = (result as JSString).toDart;
      final response = jsonDecode(responseStr) as Map<String, dynamic>;

      final status = response['status'] as int? ?? 0;
      if (status < 200 || status >= 300) return null;

      final responseBody = response['body'] as String? ?? '';
      final decoded = jsonDecode(responseBody) as Map<String, dynamic>;

      String latex;
      if (isAnthropic) {
        final content = decoded['content'] as List?;
        if (content == null || content.isEmpty) return null;
        latex = (content[0] as Map)['text'] as String? ?? '';
      } else {
        final choices = decoded['choices'] as List?;
        if (choices == null || choices.isEmpty) return null;
        final message = choices[0]['message'] as Map?;
        latex = message?['content'] as String? ?? '';
      }

      latex = latex
          .replaceAll(RegExp(r'```(?:latex|tex)?\n?'), '')
          .replaceAll('```', '')
          .trim();

      if (latex.isEmpty) return null;

      final engineSyntax = latexToEngineSyntax(latex);

      return OcrResult(
        text: engineSyntax,
        rawOutput: latex,
        providerName: name,
      );
    } catch (e) {
      return null;
    }
  }

  static const _prompt = '''Recognize the mathematical expression in this image.
Return ONLY the LaTeX representation — no explanation, no markdown fences.
If it's handwritten, do your best to interpret the symbols.
If you cannot recognize any math, return "ERROR".
Examples:
- "x^{2} + 1"
- "\\frac{a}{b}"
- "\\int_{0}^{\\infty} e^{-x} dx"''';
}

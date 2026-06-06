// lib/engine/ocr_cloud_llm.dart
//
// Cloud LLM OCR provider — sends math images to Claude/GPT-4V for
// handwritten + printed math recognition. Uses the CrispAssist
// infrastructure (API key, URL from AppState).
//
// This is the cross-platform fallback for handwritten math that
// doesn't require an on-device model. Works on all platforms
// including web.

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'ocr_provider.dart';
import '../engine/app_state.dart';

/// OCR provider that sends images to a cloud LLM (Claude/GPT-4V)
/// for math equation recognition.
class CloudLlmOcrProvider implements OcrProvider {
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
      final base64Image = base64Encode(imageBytes);
      const mimeType = 'image/png';

      final String body;
      final Map<String, String> headers;

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
                {
                  'type': 'text',
                  'text': _prompt,
                },
              ],
            },
          ],
        });
      } else {
        // OpenAI-compatible format
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
                {
                  'type': 'text',
                  'text': _prompt,
                },
              ],
            },
          ],
        });
      }

      final client = HttpClient();
      final request = await client.postUrl(Uri.parse(apiUrl));
      headers.forEach((k, v) => request.headers.set(k, v));
      request.add(utf8.encode(body));

      final response = await request.close().timeout(
            const Duration(seconds: 30),
          );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }

      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

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

      // Clean up LLM response — strip markdown fences, trim
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

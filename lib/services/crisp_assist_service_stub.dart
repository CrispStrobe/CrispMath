// lib/services/crisp_assist_service_stub.dart
//
// Web stub — CrispAssist uses dart:io HttpClient, unavailable on web.
// All methods throw; the UI gates on crispAssistEnabled which is always
// false on web (no SharedPreferences with API keys on first load).

import '../engine/step_engine.dart';

class CrispAssistConfig {
  const CrispAssistConfig({
    required this.apiUrl,
    required this.apiKey,
    this.model = 'claude-sonnet-4-20250514',
    this.timeout = const Duration(seconds: 60),
    this.maxOutputTokens = 1024,
    this.temperature = 0.0,
  });

  final String apiUrl;
  final String apiKey;
  final String model;
  final Duration timeout;
  final int maxOutputTokens;
  final double temperature;

  bool get enabled => apiUrl.isNotEmpty && apiKey.isNotEmpty;
}

class CrispAssistCancelToken {
  bool cancelled = false;
  void cancel() => cancelled = true;
}

class CrispAssistDisabledException implements Exception {
  final String reason;
  const CrispAssistDisabledException(this.reason);
  @override
  String toString() => 'CrispAssistDisabledException: $reason';
}

class CrispAssistHttpException implements Exception {
  final int statusCode;
  final String body;
  CrispAssistHttpException(this.statusCode, this.body);
  @override
  String toString() => 'CrispAssistHttpException(status=$statusCode): $body';
}

class CrispAssistService {
  CrispAssistService();
  void dispose() {}

  Future<String> translate({
    required String userInput,
    required CrispAssistConfig config,
  }) async =>
      throw const CrispAssistDisabledException('Not available on web');

  Future<String> explain({
    required String expression,
    required String result,
    required CrispAssistConfig config,
  }) async =>
      throw const CrispAssistDisabledException('Not available on web');

  Future<String> narrateSteps({
    required String expression,
    required List<MathStep> steps,
    required CrispAssistConfig config,
  }) async =>
      throw const CrispAssistDisabledException('Not available on web');

  Stream<String> streamExplain({
    required String expression,
    required String result,
    required CrispAssistConfig config,
    CrispAssistCancelToken? cancel,
  }) =>
      Stream.error(
          const CrispAssistDisabledException('Not available on web'));
}

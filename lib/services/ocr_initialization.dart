import '../engine/ocr_providers_init_stub.dart'
    if (dart.library.io) '../engine/ocr_providers_init.dart'
    if (dart.library.js_interop) '../engine/ocr_providers_init_web.dart';

Future<void>? _initialization;

/// One shared initialization for concurrent camera, handwriting and settings
/// requests. Optional OCR is never initialized by calculator startup.
Future<void> ensureOcrProviders() => _initialization ??= _initialize();

Future<void> _initialize() async {
  try {
    await initOcrProviders();
    if (!isOcrAvailable) _initialization = null;
  } catch (_) {
    _initialization = null;
    rethrow;
  }
}

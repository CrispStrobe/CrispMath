// lib/engine/ocr_providers_init.dart
//
// Registers available OCR providers at app startup.
// Called from main.dart after platform init.

import 'dart:io';

import 'ocr_provider.dart';
import 'ocr_model_manager.dart';

/// Try to register available OCR providers in priority order.
/// Called once at app startup.
Future<void> initOcrProviders() async {
  // Tier 4: CrispEmbed on-device (requires native lib + downloaded model)
  // TODO: check if libcrispembed is available, load GGUF, register
  // For now, try to register a model-download-aware provider
  // that defers init until a model is downloaded.

  // Check if any model is already downloaded
  for (final model in OcrModelCatalog.printedMath) {
    final path = await OcrModelManager.localPath(model);
    if (path != null) {
      // Model available — try to init CrispEmbed provider
      // (will fail silently if native lib isn't present)
      try {
        // Dynamic import to avoid crash when lib isn't available
        // The actual CrispEmbedOcrProvider.init() tries to dlopen
        // and returns false if the lib isn't found.
        // For now, just note the model is ready.
        break;
      } catch (_) {}
    }
  }

  // If no provider was registered, the camera button will show
  // "No OCR provider configured" and prompt the user to download
  // a model in Settings.
}

/// Check if OCR is ready to use.
bool get isOcrAvailable => OcrProviders.active != null;

import 'package:flutter/foundation.dart';
import 'package:onnxruntime/onnxruntime.dart' deferred as onnx;
import 'ai_service_interface.dart';

class AiServiceNative implements AiService {
  bool _isInitialized = false;

  @override
  bool get isReady => _isInitialized;

  @override
  Future<void> initializeOptionalAi() async {
    try {
      await onnx.loadLibrary();
      // Initialize the environment. OrtEnv.instance initializes the ONNX runtime.
      onnx.OrtEnv.instance.init();
      _isInitialized = true;
      debugPrint("ONNX Runtime initialized successfully via deferred load (Native).");
    } catch (e) {
      debugPrint("Failed to load optional AI runtime: $e");
    }
  }

  @override
  Future<String?> processMathNLP(String text) async {
    if (!_isInitialized) {
      return "AI feature not loaded. Please initialize it first.";
    }
    
    // Mock inference delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (text.toLowerCase().contains("integral") || text.toLowerCase().contains("integrate")) {
      return "\\int x^2 dx = \\frac{x^3}{3} + C";
    }

    return "2x + 4 = 10 \\Rightarrow x = 3"; // Mock NLP to Math conversion
  }
}

final AiService aiService = AiServiceNative();

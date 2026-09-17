import 'package:flutter/foundation.dart';
import 'package:onnx_runtime_dart/onnx_runtime_dart.dart' deferred as onnx;
import 'ai_service_interface.dart';

class AiServiceWeb implements AiService {
  bool _isInitialized = false;
  var _sessionOptions;
  var _env;

  @override
  bool get isReady => _isInitialized;

  @override
  Future<void> initializeOptionalAi() async {
    try {
      await onnx.loadLibrary();
      // Initialize the environment. OrtEnv.instance initializes the ONNX runtime.
      onnx.OrtEnv.instance.init();
      _env = onnx.OrtEnv.instance;
      _sessionOptions = onnx.OrtSessionOptions();
      _isInitialized = true;
      debugPrint("ONNX Runtime initialized successfully via deferred load (Web).");
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

final AiService aiService = AiServiceWeb();

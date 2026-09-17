abstract class AiService {
  bool get isReady;
  Future<void> initializeOptionalAi();
  Future<String?> processMathNLP(String text);
}

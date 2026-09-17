import 'ai_service_interface.dart';

class AiServiceStub implements AiService {
  @override
  bool get isReady => false;

  @override
  Future<void> initializeOptionalAi() async {}

  @override
  Future<String?> processMathNLP(String text) async => null;
}

final AiService aiService = AiServiceStub();

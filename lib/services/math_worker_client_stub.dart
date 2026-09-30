class MathWorkerClient {
  Future<dynamic> request(String type, Map<String, dynamic> payload) =>
      throw UnsupportedError('Browser workers require the web platform');
  void cancel() {}
}

import 'package:flutter/foundation.dart';

import '../engine/calculator_engine.dart';
import '../engine/graph_sampling.dart';
import '../engine/graph_inspection.dart';
import 'math_worker_client_stub.dart'
    if (dart.library.js_interop) 'math_worker_client_web.dart';

class GraphSamplingService {
  // Separate from the calculator worker: cancelling an integral does not
  // interrupt sampling, and graph gestures do not queue behind CAS requests.
  static final _worker = MathWorkerClient();
  static Future<GraphSamples> graph(Map<String, dynamic> request) async {
    if (!kIsWeb) return compute(_sampleGraph, request);
    final data = await _worker.request('graph', request) as Map;
    return GraphSamples.fromJson(data.cast<String, dynamic>());
  }

  static Future<List<List<double?>>> values(
      String expression, List<double> xs) async {
    final request = <String, dynamic>{'expression': expression, 'xs': xs};
    if (!kIsWeb) return compute(_sampleValues, request);
    final data = await _worker.request('values', request) as List;
    return data
        .map(
            (row) => (row as List).map((n) => (n as num?)?.toDouble()).toList())
        .toList();
  }

  static Future<List<List<double>>> surface(
      Map<String, dynamic> request) async {
    if (!kIsWeb) return compute(_sampleSurface, request);
    final data = await _worker.request('surface', request) as List;
    return data
        .map((row) => (row as List).map((n) => (n as num).toDouble()).toList())
        .toList();
  }
}

double? _fallback(
  CalculatorEngine engine,
  String expression,
  Map<String, double> vars,
) {
  final bound = expression.replaceAllMapped(
    RegExp(r'\b[A-Za-z_][A-Za-z_0-9]*\b'),
    (m) => vars.containsKey(m[0]) ? '(${vars[m[0]]})' : m[0]!,
  );
  return double.tryParse(engine.evaluateForGraphing(bound));
}

GraphSamples _sampleGraph(Map<String, dynamic> request) {
  CalculatorEngine? engine;
  return sampleGraph(
    request,
    fallback: (expression, vars) =>
        _fallback(engine ??= CalculatorEngine(), expression, vars),
  );
}

List<List<double>> _sampleSurface(Map<String, dynamic> request) {
  CalculatorEngine? engine;
  return sampleSurface(
    request,
    fallback: (expression, vars) =>
        _fallback(engine ??= CalculatorEngine(), expression, vars),
  );
}

List<List<double?>> _sampleValues(Map<String, dynamic> request) {
  CalculatorEngine? engine;
  return sampleGraphValues(request,
      fallback: (expression, vars) =>
          _fallback(engine ??= CalculatorEngine(), expression, vars));
}

// Compiled separately with dart compile js. No Flutter renderer is loaded.
import 'dart:js_interop';

import '../engine/calculator_engine.dart';
import '../engine/graph_sampling.dart';
import '../engine/graph_inspection.dart';
import 'engine_dispatch.dart';
import 'engine_op.dart';

@JS('self.onmessage')
external set _onMessage(JSFunction handler);
@JS('self.postMessage')
external void _postMessage(JSAny? message);

@JS()
@staticInterop
class _Message {}

extension on _Message {
  external JSAny get data;
}

void main() {
  final engine = CalculatorEngine();
  double? fallback(String expression, Map<String, double> vars) {
    final bound = expression.replaceAllMapped(
        RegExp(r'\b[A-Za-z_][A-Za-z_0-9]*\b'),
        (m) => vars.containsKey(m[0]) ? '(${vars[m[0]]})' : m[0]!);
    return double.tryParse(engine.evaluateForGraphing(bound));
  }

  _onMessage = ((_Message event) {
    final message = (event.data.dartify() as Map).cast<String, dynamic>();
    final payload = (message['payload'] as Map).cast<String, dynamic>();
    try {
      final dynamic result;
      switch (message['type']) {
        case 'graph':
          result = sampleGraph(payload, fallback: fallback).toJson();
        case 'values':
          result = sampleGraphValues(payload, fallback: fallback);
        case 'surface':
          result = sampleSurface(payload, fallback: fallback);
        case 'engine':
          result = runEngineOp(
              engine,
              EngineOp(payload['kind'], payload['arg1'], payload['arg2'],
                  payload['arg3'], payload['arg4']));
        default:
          throw StateError('Unknown math request');
      }
      _postMessage({'id': message['id'], 'result': result}.jsify());
    } catch (e) {
      _postMessage({'id': message['id'], 'error': e.toString()}.jsify());
    }
  }).toJS;
}

// Separate diagnostic entry point: the UI worker remains small and synchronous.
import 'dart:async';
import 'dart:js_interop';
import '../engine/calculator_engine.dart';
import 'workflow_tasks.dart';

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
  final runner = WorkflowTasks(CalculatorEngine());
  Future<void> handle(_Message event) async {
    final message = (event.data.dartify() as Map).cast<String, dynamic>();
    try {
      final payload = (message['payload'] as Map).cast<String, dynamic>();
      final result = await runner.run(payload['tasks'] as List);
      _postMessage({'id': message['id'], 'result': result}.jsify());
    } catch (e) {
      _postMessage({'id': message['id'], 'error': e.toString()}.jsify());
    }
  }

  _onMessage = ((_Message event) {
    unawaited(handle(event));
  }).toJS;
}

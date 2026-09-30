import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'engine_op.dart';

/// A lazy, persistent worker. Every response is matched to its request ID;
/// termination rejects all pending work and the next call starts fresh.
class MathWorkerClient {
  web.Worker? _worker;
  int _nextId = 0;
  final _pending = <int, Completer<dynamic>>{};
  final _timeouts = <int, Timer>{};

  Future<dynamic> request(String type, Map<String, dynamic> payload) {
    final worker = _worker ??= _start();
    final id = _nextId++;
    final completer = Completer<dynamic>();
    _pending[id] = completer;
    _timeouts[id] = Timer(const Duration(seconds: 60),
        () => _fail(TimeoutException('Background math timed out')));
    try {
      worker.postMessage({'id': id, 'type': type, 'payload': payload}.jsify());
    } catch (error) {
      _timeouts.remove(id)?.cancel();
      _pending.remove(id);
      completer.completeError(error);
    }
    return completer.future;
  }

  web.Worker _start() {
    final worker = web.Worker(Uri.parse(web.document.baseURI)
        .resolve('math_worker.js')
        .toString()
        .toJS);
    worker.onmessage = ((web.MessageEvent event) {
      if (!identical(_worker, worker)) return;
      final data = (event.data.dartify() as Map).cast<String, dynamic>();
      if (data['type'] == 'fatal') {
        _fail(StateError(data['error'] as String));
        return;
      }
      final id = data['id'];
      if (id is! int) return;
      _timeouts.remove(id)?.cancel();
      final pending = _pending.remove(id);
      if (data['error'] != null) {
        pending?.completeError(StateError(data['error'] as String));
      } else {
        pending?.complete(data['result']);
      }
    }).toJS;
    worker.onerror = ((web.Event event) {
      if (!identical(_worker, worker)) return;
      event.preventDefault();
      _fail(StateError('Background math could not load'));
    }).toJS;
    worker.onmessageerror = ((web.MessageEvent _) {
      if (identical(_worker, worker)) {
        _fail(StateError('Background math returned an invalid response'));
      }
    }).toJS;
    return worker;
  }

  void _fail(Object error) {
    _worker?.terminate();
    _worker = null;
    for (final timer in _timeouts.values) {
      timer.cancel();
    }
    _timeouts.clear();
    final pending = _pending.values.toList();
    _pending.clear();
    for (final completer in pending) {
      completer.completeError(error);
    }
  }

  void cancel() => _fail(const EngineCancelled());
}

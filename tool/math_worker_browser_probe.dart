// Compile to web/math_worker_probe.dart.js and load in a browser on the same
// origin as math_worker.js. Sets window.mathWorkerProbeResult for CI probes.
import 'dart:convert';
import 'dart:js_interop';

import '../lib/services/math_worker_client_web.dart';
import '../lib/services/engine_op.dart';
import '../lib/engine/ocr_wasm_bridge.dart';

@JS('mathWorkerProbeResult')
external set _result(JSString value);

Future<void> main() async {
  final worker = MathWorkerClient();
  try {
    final results = await Future.wait([
      worker.request('engine', {'kind': 'evaluate', 'arg1': '2+3'}),
      worker.request('engine', {
        'kind': 'integrate',
        'arg1': 'x^2',
        'arg2': 'x',
        'arg3': '0',
        'arg4': '1'
      }),
      worker.request('engine', {'kind': 'expand', 'arg1': '(x+1)^2'}),
    ]);
    final cancelled = worker
        .request('engine', {'kind': 'evaluate', 'arg1': '123+456'}).then(
            (_) => false,
            onError: (Object e) => e is EngineCancelled);
    worker.cancel();
    final cancellationWorks = await cancelled;
    final restarted =
        await worker.request('engine', {'kind': 'evaluate', 'arg1': '2+2'});
    worker.cancel();
    final ocrStartedUnloaded = !CrispEmbedOcrWasm.isAvailable;
    final ocrLoadedOnDemand = await CrispEmbedOcrWasm.initModule();
    _result = jsonEncode({
      'ocrStartedUnloaded': ocrStartedUnloaded,
      'ocrLoadedOnDemand': ocrLoadedOnDemand,
      'results': results,
      'cancelled': cancellationWorks,
      'restarted': restarted
    }).toJS;
  } catch (e) {
    worker.cancel();
    _result = jsonEncode({'error': e.toString()}).toJS;
  }
}

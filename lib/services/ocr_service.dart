import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:crispembed/crispembed.dart';

import '../engine/ocr_providers_init.dart' as p;

class OcrOp {
  final String type; // 'math_gray', 'vlm_raw', 'granite_raw'
  final String modelPath;
  final Uint8List imageBytes;
  final int width;
  final int height;

  const OcrOp(
      this.type, this.modelPath, this.imageBytes, this.width, this.height);
}

class OcrService {
  static final _PersistentWorker _worker = _PersistentWorker();

  static Future<String?> recognizeAsync(OcrOp op) {
    if (kIsWeb) return Future.value(null); // Web has WASM fallback
    return _worker.send(op);
  }

  static Future<void> kill() => _worker.kill();
}

class _WorkerRequest {
  final int id;
  final OcrOp op;
  const _WorkerRequest(this.id, this.op);
}

class _WorkerResponse {
  final int id;
  final String? result;
  const _WorkerResponse(this.id, this.result);
}

class _PersistentWorker {
  Isolate? _isolate;
  SendPort? _commandPort;
  ReceivePort? _responsePort;
  StreamSubscription<dynamic>? _responseSub;
  int _nextId = 0;
  final Map<int, Completer<String?>> _pending = {};
  Completer<void>? _startup;

  Future<void> _ensureStarted() async {
    if (_commandPort != null) return;
    if (_startup != null) return _startup!.future;

    final startup = _startup = Completer<void>();
    _responsePort = ReceivePort();
    _responseSub = _responsePort!.listen(_onResponse);
    _isolate = await Isolate.spawn(
      _workerEntry,
      _responsePort!.sendPort,
      errorsAreFatal: false,
    );
    await startup.future;
  }

  void _onResponse(dynamic msg) {
    if (msg is SendPort) {
      _commandPort = msg;
      _startup?.complete();
      return;
    }
    if (msg is _WorkerResponse) {
      final completer = _pending.remove(msg.id);
      completer?.complete(msg.result);
    }
  }

  Future<String?> send(OcrOp op) async {
    await _ensureStarted();
    final id = _nextId++;
    final completer = Completer<String?>();
    _pending[id] = completer;
    _commandPort!.send(_WorkerRequest(id, op));
    return completer.future;
  }

  Future<void> kill() async {
    final pending = _pending.values.toList();
    _pending.clear();
    final startup = _startup;
    _isolate?.kill(priority: Isolate.immediate);
    await _responseSub?.cancel();
    _responsePort?.close();
    _isolate = null;
    _commandPort = null;
    _responsePort = null;
    _responseSub = null;
    _startup = null;
    if (startup != null && !startup.isCompleted) {
      startup.future.then((_) {}, onError: (_) {});
      startup.completeError(Exception('OcrCancelled'));
    }
    for (final c in pending) {
      if (!c.isCompleted) {
        c.future.then((_) {}, onError: (_) {});
        c.completeError(Exception('OcrCancelled'));
      }
    }
  }
}

// ---------------- Worker Entry Point ----------------
void _workerEntry(SendPort mainSendPort) {
  final commandPort = ReceivePort();
  mainSendPort.send(commandPort.sendPort);

  // We cache the model so we don't reload it every stroke! (Pre-warming)
  CrispEmbedOcr? _ocr;
  CrispGraniteVision? _granite;
  String? _loadedModelPath;

  commandPort.listen((message) {
    if (message is _WorkerRequest) {
      final op = message.op;

      try {
        // If we switch models, dispose the old one
        if (_loadedModelPath != op.modelPath) {
          _ocr?.dispose();
          _ocr = null;
          _granite?.dispose();
          _granite = null;

          if (op.type == 'math_gray' || op.type == 'vlm_raw') {
            _ocr = CrispEmbedOcr(op.modelPath, nThreads: 4);
          } else if (op.type == 'granite_raw') {
            _granite = CrispGraniteVision(op.modelPath, nThreads: 4);
          }

          _loadedModelPath = op.modelPath;
        }

        String? result;
        if (op.type == 'math_gray' && _ocr != null) {
          final gray =
              p.toGrayscaleForIsolate(op.imageBytes, op.width, op.height);
          result = _ocr!.recognizeGray(gray, op.width, op.height);
        } else if (op.type == 'vlm_raw' && _ocr != null) {
          final channels = op.imageBytes.length ~/ (op.width * op.height);
          result =
              _ocr!.recognizeRaw(op.imageBytes, op.width, op.height, channels);
        } else if (op.type == 'granite_raw' && _granite != null) {
          final channels = op.imageBytes.length ~/ (op.width * op.height);
          result = _granite!.recognize(op.imageBytes, op.width, op.height,
              channels: channels);
        }

        mainSendPort.send(_WorkerResponse(message.id, result));
      } catch (e) {
        print("OCR Worker Error: \$e");
        mainSendPort.send(_WorkerResponse(message.id, null));
      }
    }
  });
}

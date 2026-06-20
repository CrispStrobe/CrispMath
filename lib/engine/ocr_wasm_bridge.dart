// lib/engine/ocr_wasm_bridge.dart
//
// WASM-backed math OCR via CrispEmbed compiled to WebAssembly.
//
// Loading flow:
//   1. web/index.html loads crispembed_ocr.js (Emscripten loader)
//   2. Dart calls CrispEmbedOcrWasm.init() which instantiates the module
//   3. JS fetches the GGUF model and writes it to Emscripten MEMFS
//   4. C code opens it via fopen/fread and runs inference
//
// Follows the same dart:js_interop pattern as symbolic_math_bridge_web.dart.

import 'dart:js_interop';
import 'dart:typed_data';

// ---------------------------------------------------------------------------
// JS interop bindings
// ---------------------------------------------------------------------------

/// CrispEmbedOCR module factory (set by crispembed_ocr.js, MODULARIZE=1).
@JS('CrispEmbedOCR')
external JSFunction? get _jsModuleFactory;

/// Module instance (set after init).
@JS('_crispEmbedOcrInstance')
external JSObject? get _jsModule;

@JS('_crispEmbedOcrReady')
external bool get _jsReady;

// Helper functions injected into window scope.
@JS('_ceOcrVersion')
external JSString _jsOcrVersion();

@JS('_ceOcrInit')
external JSNumber _jsOcrInit(JSString path, JSNumber nThreads);

@JS('_ceOcrRecognizeGray')
external JSString? _jsOcrRecognizeGray(
    JSNumber ctx, JSNumber pixelsPtr, JSNumber width, JSNumber height);

@JS('_ceOcrRecognize')
external JSString? _jsOcrRecognize(JSNumber ctx, JSNumber pixelsPtr,
    JSNumber width, JSNumber height, JSNumber channels);

@JS('_ceOcrFree')
external void _jsOcrFree(JSNumber ctx);

@JS('_ceOcrWriteModel')
external void _jsOcrWriteModel(JSString path, JSAny data);

@JS('_ceOcrMalloc')
external JSNumber _jsOcrMalloc(JSNumber size);

@JS('_ceOcrFreePtr')
external void _jsOcrFreePtr(JSNumber ptr);

@JS('_ceOcrHeapF32')
external JSFloat32Array _jsOcrHeapF32();

@JS('_ceOcrHeapU8')
external JSUint8Array _jsOcrHeapU8();

@JS('eval')
external void _jsEval(JSString code);

// ---------------------------------------------------------------------------
// Helper injection
// ---------------------------------------------------------------------------

bool _helpersInjected = false;

void _injectHelpers() {
  if (_helpersInjected) return;
  _jsEval('''
    window._crispEmbedOcrReady = false;
    window._crispEmbedOcrInstance = null;

    window._ceOcrVersion = function() {
      return _crispEmbedOcrInstance.ccall('wasm_ocr_version', 'string', [], []);
    };
    window._ceOcrInit = function(path, nThreads) {
      return _crispEmbedOcrInstance.ccall(
        'wasm_ocr_init', 'number', ['string', 'number'], [path, nThreads]);
    };
    window._ceOcrRecognizeGray = function(ctx, pixelsPtr, w, h) {
      var outLenPtr = _crispEmbedOcrInstance._malloc(4);
      _crispEmbedOcrInstance.setValue(outLenPtr, 0, 'i32');
      var resultPtr = _crispEmbedOcrInstance.ccall(
        'wasm_ocr_recognize_gray', 'number',
        ['number', 'number', 'number', 'number', 'number'],
        [ctx, pixelsPtr, w, h, outLenPtr]);
      _crispEmbedOcrInstance._free(outLenPtr);
      if (resultPtr === 0) return null;
      return _crispEmbedOcrInstance.UTF8ToString(resultPtr);
    };
    window._ceOcrRecognize = function(ctx, pixelsPtr, w, h, channels) {
      var outLenPtr = _crispEmbedOcrInstance._malloc(4);
      _crispEmbedOcrInstance.setValue(outLenPtr, 0, 'i32');
      var resultPtr = _crispEmbedOcrInstance.ccall(
        'wasm_ocr_recognize', 'number',
        ['number', 'number', 'number', 'number', 'number', 'number'],
        [ctx, pixelsPtr, w, h, channels, outLenPtr]);
      _crispEmbedOcrInstance._free(outLenPtr);
      if (resultPtr === 0) return null;
      return _crispEmbedOcrInstance.UTF8ToString(resultPtr);
    };
    window._ceOcrFree = function(ctx) {
      _crispEmbedOcrInstance.ccall('wasm_ocr_free', null, ['number'], [ctx]);
    };
    window._ceOcrWriteModel = function(path, data) {
      _crispEmbedOcrInstance.FS.writeFile(path, data);
    };
    window._ceOcrMalloc = function(size) {
      return _crispEmbedOcrInstance._malloc(size);
    };
    window._ceOcrFreePtr = function(ptr) {
      _crispEmbedOcrInstance._free(ptr);
    };
    window._ceOcrHeapF32 = function() {
      return _crispEmbedOcrInstance.HEAPF32;
    };
    window._ceOcrHeapU8 = function() {
      return _crispEmbedOcrInstance.HEAPU8;
    };
  '''
      .toJS);
  _helpersInjected = true;
}

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

class CrispEmbedOcrWasm {
  static bool _moduleLoaded = false;
  int _ctx = 0;
  bool _disposed = false;

  CrispEmbedOcrWasm._();

  /// Whether the WASM module has been loaded and is ready.
  static bool get isAvailable => _moduleLoaded;

  /// Initialize the Emscripten module. Call once at app startup.
  /// Returns true if the module loaded successfully.
  static Future<bool> initModule() async {
    if (_moduleLoaded) return true;
    if (_jsModuleFactory == null) return false;

    try {
      _injectHelpers();

      // Start the factory and wait for the Promise to resolve.
      _jsEval('''
        CrispEmbedOCR().then(function(instance) {
          window._crispEmbedOcrInstance = instance;
          window._crispEmbedOcrReady = true;
          console.log('CrispEmbed OCR WASM loaded');
        }).catch(function(err) {
          console.warn('CrispEmbed OCR WASM failed:', err);
        });
      '''
          .toJS);

      // Poll until ready (max 10 seconds).
      for (int i = 0; i < 100; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        if (_jsReady && _jsModule != null) {
          _moduleLoaded = true;
          return true;
        }
      }
    } catch (e) {
      return false;
    }
    return false;
  }

  /// Load a GGUF model from bytes into MEMFS and initialize the OCR context.
  /// [modelBytes] — raw GGUF file content.
  /// [modelName] — filename for MEMFS (e.g. 'pix2tex-mfr-q4_k.gguf').
  /// [nThreads] — CPU threads (1 recommended for WASM).
  static CrispEmbedOcrWasm? loadModel(
    Uint8List modelBytes, {
    String modelName = 'model.gguf',
    int nThreads = 1,
  }) {
    if (!_moduleLoaded) return null;

    final path = '/$modelName';

    // Write model bytes to Emscripten MEMFS.
    _jsOcrWriteModel(path.toJS, modelBytes.toJS);

    // Initialize the OCR context.
    final ctx = _jsOcrInit(path.toJS, nThreads.toJS).toDartInt;
    if (ctx == 0) return null;

    final ocr = CrispEmbedOcrWasm._();
    ocr._ctx = ctx;
    return ocr;
  }

  /// Get the WASM build version string.
  static String get version {
    if (!_moduleLoaded) return 'not loaded';
    return _jsOcrVersion().toDart;
  }

  /// Recognize math from grayscale float pixels [0..1].
  /// Returns LaTeX string or null on failure.
  String? recognizeGray(Float32List pixels, int width, int height) {
    if (_disposed || _ctx == 0) return null;

    // Allocate WASM heap memory and copy pixels.
    final nBytes = pixels.length * 4; // float32 = 4 bytes
    final ptr = _jsOcrMalloc(nBytes.toJS).toDartInt;
    if (ptr == 0) return null;

    try {
      // Bulk copy Float32List into WASM HEAPF32.
      final heap = _jsOcrHeapF32().toDart;
      final offset = ptr ~/ 4; // HEAPF32 index = byte offset / 4
      heap.setRange(offset, offset + pixels.length, pixels);

      final result =
          _jsOcrRecognizeGray((_ctx).toJS, ptr.toJS, width.toJS, height.toJS);

      if (result == null) return null;
      return result.toDart;
    } finally {
      _jsOcrFreePtr(ptr.toJS);
    }
  }

  /// Recognize math from raw pixel bytes (RGB/RGBA/grayscale).
  String? recognizeRaw(Uint8List bytes, int width, int height, int channels) {
    if (_disposed || _ctx == 0) return null;

    final ptr = _jsOcrMalloc(bytes.length.toJS).toDartInt;
    if (ptr == 0) return null;

    try {
      // Bulk copy bytes into WASM HEAPU8.
      final heap = _jsOcrHeapU8().toDart;
      heap.setRange(ptr, ptr + bytes.length, bytes);

      final result = _jsOcrRecognize(
          _ctx.toJS, ptr.toJS, width.toJS, height.toJS, channels.toJS);

      if (result == null) return null;
      return result.toDart;
    } finally {
      _jsOcrFreePtr(ptr.toJS);
    }
  }

  void dispose() {
    if (!_disposed && _ctx != 0) {
      _jsOcrFree(_ctx.toJS);
      _ctx = 0;
      _disposed = true;
    }
  }
}

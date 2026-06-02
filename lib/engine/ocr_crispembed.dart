// lib/engine/ocr_crispembed.dart
//
// Tier 4 OCR provider: pix2tex via CrispEmbed's ggml inference.
//
// Loads a pix2tex GGUF model and runs the ViT encoder + transformer
// decoder entirely on-device. No Python, no ONNX, no cloud.
//
// The native library is loaded from the platform-specific location
// (same pattern as symbolic_math_bridge). If the library isn't
// present, isAvailable returns false and the provider is skipped.

import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:typed_data';

import 'ocr_provider.dart';

// FFI type definitions matching crispembed.h.
typedef _MathOcrInitC = ffi.Pointer<ffi.Void> Function(
    ffi.Pointer<ffi.Utf8>, ffi.Int32);
typedef _MathOcrInitDart = ffi.Pointer<ffi.Void> Function(
    ffi.Pointer<ffi.Utf8>, int);

typedef _MathOcrFreeC = ffi.Void Function(ffi.Pointer<ffi.Void>);
typedef _MathOcrFreeDart = void Function(ffi.Pointer<ffi.Void>);

typedef _MathOcrRecognizeC = ffi.Pointer<ffi.Utf8> Function(
    ffi.Pointer<ffi.Void>,
    ffi.Pointer<ffi.Uint8>,
    ffi.Int32,
    ffi.Int32,
    ffi.Int32,
    ffi.Pointer<ffi.Int32>);
typedef _MathOcrRecognizeDart = ffi.Pointer<ffi.Utf8> Function(
    ffi.Pointer<ffi.Void>,
    ffi.Pointer<ffi.Uint8>,
    int,
    int,
    int,
    ffi.Pointer<ffi.Int32>);

/// OCR provider backed by CrispEmbed's pix2tex GGUF model.
class CrispEmbedOcrProvider implements OcrProvider {
  ffi.DynamicLibrary? _lib;
  ffi.Pointer<ffi.Void>? _ctx;
  _MathOcrRecognizeDart? _recognizeFn;
  _MathOcrFreeDart? _freeFn;

  @override
  String get name => 'CrispEmbed pix2tex (on-device)';

  @override
  bool get isAvailable => _lib != null;

  @override
  bool get requiresNetwork => false;

  @override
  bool get requiresApiKey => false;

  /// Try to load the native library and initialize the model.
  /// [modelPath] — path to the pix2tex GGUF file.
  /// [nThreads] — CPU threads for inference.
  /// Returns false if the library or model can't be loaded.
  bool init({required String modelPath, int nThreads = 4}) {
    try {
      _lib = _openLibrary();
      if (_lib == null) return false;

      final initFn = _lib!.lookupFunction<_MathOcrInitC, _MathOcrInitDart>(
          'crispembed_math_ocr_init');
      _freeFn = _lib!.lookupFunction<_MathOcrFreeC, _MathOcrFreeDart>(
          'crispembed_math_ocr_free');
      _recognizeFn =
          _lib!.lookupFunction<_MathOcrRecognizeC, _MathOcrRecognizeDart>(
              'crispembed_math_ocr_recognize');

      final pathPtr = modelPath.toNativeUtf8();
      _ctx = initFn(pathPtr, nThreads);
      ffi.calloc.free(pathPtr);

      return _ctx != null && _ctx != ffi.nullptr;
    } catch (e) {
      _lib = null;
      return false;
    }
  }

  @override
  Future<OcrResult?> recognize(
      Uint8List imageBytes, int width, int height) async {
    if (_ctx == null || _recognizeFn == null) return null;

    // Allocate native memory for the image bytes.
    final ptr = ffi.calloc<ffi.Uint8>(imageBytes.length);
    ptr.asTypedList(imageBytes.length).setAll(0, imageBytes);

    final outLen = ffi.calloc<ffi.Int32>();

    // Assume RGB (3 channels). If the image is RGBA (4 channels),
    // the caller should convert or pass channels=4.
    final channels = imageBytes.length ~/ (width * height);

    final resultPtr =
        _recognizeFn!(_ctx!, ptr, width, height, channels, outLen);

    ffi.calloc.free(ptr);
    final len = outLen.value;
    ffi.calloc.free(outLen);

    if (resultPtr == ffi.nullptr) return null;

    final latex = resultPtr.toDartString(length: len);
    if (latex.isEmpty) return null;

    // Convert LaTeX to engine syntax.
    final engineSyntax = latexToEngineSyntax(latex);

    return OcrResult(
      text: engineSyntax,
      rawOutput: latex,
      providerName: name,
    );
  }

  void dispose() {
    if (_ctx != null && _freeFn != null) {
      _freeFn!(_ctx!);
      _ctx = null;
    }
  }

  static ffi.DynamicLibrary? _openLibrary() {
    try {
      if (Platform.isLinux) {
        return ffi.DynamicLibrary.open('libcrispembed.so');
      } else if (Platform.isMacOS) {
        return ffi.DynamicLibrary.open('libcrispembed.dylib');
      } else if (Platform.isWindows) {
        return ffi.DynamicLibrary.open('crispembed.dll');
      } else if (Platform.isAndroid) {
        return ffi.DynamicLibrary.open('libcrispembed.so');
      } else if (Platform.isIOS) {
        return ffi.DynamicLibrary.process();
      }
    } catch (_) {}
    return null;
  }
}

// FFI helpers (these would normally come from package:ffi).
extension on String {
  ffi.Pointer<ffi.Utf8> toNativeUtf8() {
    final units = codeUnits;
    final ptr = ffi.calloc<ffi.Uint8>(units.length + 1);
    for (var i = 0; i < units.length; i++) {
      ptr[i] = units[i];
    }
    ptr[units.length] = 0;
    return ptr.cast();
  }
}

extension on ffi.Pointer<ffi.Utf8> {
  String toDartString({int? length}) {
    if (this == ffi.nullptr) return '';
    final ptr = cast<ffi.Uint8>();
    final len = length ?? _strlen(ptr);
    final bytes = List<int>.generate(len, (i) => ptr[i]);
    return String.fromCharCodes(bytes);
  }

  static int _strlen(ffi.Pointer<ffi.Uint8> ptr) {
    var i = 0;
    while (ptr[i] != 0) {
      i++;
    }
    return i;
  }
}

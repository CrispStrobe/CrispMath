// Exercise the shipped DLL's real research-license gate after it is loaded.
// Marker checks the same runtime gate before attempting to open its model.
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:crisp_math/services/native_env.dart';

final class MarkerConfig extends Struct {
  @Uint64()
  external int structSize;
  external Pointer<Uint8> modelPath;
  external Pointer<Uint8> pdfiumPath;
  external Pointer<Uint8> password;
  @Int32()
  external int mode;
  @Int32()
  external int nThreads;
  @Int32()
  external int firstPage;
  @Int32()
  external int lastPage;
  @Int32()
  external int dpi;
  @Int32()
  external int maxTokens;
  @Int32()
  external int maxLayoutTokens;
  @Int32()
  external int maxBlocks;
  @Int32()
  external int maxPages;
  @Uint64()
  external int maxPixels;
  @Uint64()
  external int maxAssetBytes;
  @Int32()
  external int includePageHeaders;
  @Int32()
  external int extractImages;
}

typedef _MallocC = Pointer<Void> Function(IntPtr);
typedef _MallocD = Pointer<Void> Function(int);
typedef _FreeC = Void Function(Pointer<Void>);
typedef _FreeD = void Function(Pointer<Void>);
typedef _InitC = Pointer<Void> Function(Pointer<MarkerConfig>);
typedef _ErrorC = Pointer<Uint8> Function(Pointer<Void>);

void main() {
  test('packaged Windows DLL observes grant and withdrawal after loading', () {
    expect(Platform.isWindows, isTrue);
    final path = Platform.environment['CRISPMATH_OCR_LIBRARY'];
    expect(path, isNotNull);
    expect(File(path!).existsSync(), isTrue);
    final library = DynamicLibrary.open(File(path).absolute.path);
    final init = library.lookupFunction<_InitC, _InitC>('crispembed_marker_init');
    final error = library.lookupFunction<_ErrorC, _ErrorC>('crispembed_marker_error');
    final crt = DynamicLibrary.open('ucrtbase.dll');
    final malloc = crt.lookupFunction<_MallocC, _MallocD>('malloc');
    final free = crt.lookupFunction<_FreeC, _FreeD>('free');
    final raw = malloc(sizeOf<MarkerConfig>());
    final model = malloc(32).cast<Uint8>();
    expect(raw, isNot(nullptr));
    expect(model, isNot(nullptr));
    raw.cast<Uint8>().asTypedList(sizeOf<MarkerConfig>()).fillRange(0, sizeOf<MarkerConfig>(), 0);
    model.asTypedList(32).setAll(0, Uint8List.fromList([...('missing-teleocr.gguf'.codeUnits), 0]));
    final config = raw.cast<MarkerConfig>();
    config.ref
      ..structSize = sizeOf<MarkerConfig>()
      ..modelPath = model
      ..mode = 0
      ..nThreads = 2
      ..lastPage = -1
      ..dpi = 144
      ..maxTokens = 1024
      ..maxLayoutTokens = 2048
      ..maxBlocks = 512
      ..maxPages = 1000
      ..maxPixels = 16000000
      ..maxAssetBytes = 128 * 1024 * 1024
      ..extractImages = 1;
    String attempt() {
      expect(init(config), nullptr);
      final p = error(nullptr);
      expect(p, isNot(nullptr));
      var n = 0;
      while (p[n] != 0) { n++; }
      return String.fromCharCodes(p.asTypedList(n));
    }
    const gate = 'CRISPEMBED_ACCEPT_QWEN_RESEARCH_LICENSE';
    try {
      expect(setNativeEnv('CRISPEMBED_MARKER', '1'), isTrue);
      expect(setNativeEnv('CRISPEMBED_TELEOCR', '1'), isTrue);
      setCrispEmbedLicenseGate(gate, false);
      expect(attempt(), contains('Qwen RESEARCH LICENSE'));
      setCrispEmbedLicenseGate(gate, true);
      expect(attempt(), contains('strict TeleOCR-profile GGUF'));
      setCrispEmbedLicenseGate(gate, false);
      expect(attempt(), contains('Qwen RESEARCH LICENSE'));
    } finally {
      setNativeEnv(gate, null);
      setNativeEnv('CRISPEMBED_MARKER', null);
      setNativeEnv('CRISPEMBED_TELEOCR', null);
      free(model.cast<Void>());
      free(raw);
    }
  });
}

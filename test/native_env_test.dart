// test/native_env_test.dart
//
// The CrispEmbed license env gate must be visible to native getenv().

import 'dart:ffi';
import 'dart:io' show Platform;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:crisp_math/services/native_env.dart';

typedef _GetenvC = Pointer<Uint8> Function(Pointer<Uint8>);
typedef _MallocC = Pointer<Uint8> Function(IntPtr);
typedef _MallocD = Pointer<Uint8> Function(int);
typedef _FreeC = Void Function(Pointer<Uint8>);
typedef _FreeD = void Function(Pointer<Uint8>);

String? _nativeGetenv(String name) {
  final crt = Platform.isWindows
      ? DynamicLibrary.open('ucrtbase.dll')
      : DynamicLibrary.process();
  final getenv = crt.lookupFunction<_GetenvC, _GetenvC>('getenv');
  final malloc = crt.lookupFunction<_MallocC, _MallocD>('malloc');
  final free = crt.lookupFunction<_FreeC, _FreeD>('free');
  final bytes = Uint8List.fromList([...name.codeUnits, 0]);
  final n = malloc(bytes.length);
  n.asTypedList(bytes.length).setAll(0, bytes);
  try {
    final r = getenv(n);
    if (r == nullptr) return null;
    var len = 0;
    while (r[len] != 0) {
      len++;
    }
    return String.fromCharCodes(r.asTypedList(len));
  } finally {
    free(n);
  }
}

void main() {
  const gate = 'CRISPMATH_TEST_LICENSE_GATE';

  test('setCrispEmbedLicenseGate sets and clears a native env var', () {
    setCrispEmbedLicenseGate(gate, true);
    expect(_nativeGetenv(gate), '1');
    setCrispEmbedLicenseGate(gate, false);
    expect(_nativeGetenv(gate), isNull);
  });
}

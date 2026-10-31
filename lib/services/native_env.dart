// lib/services/native_env.dart
//
// Set a process environment variable from Dart so native code loaded in
// this process (CrispEmbed) observes it via getenv(). dart:io exposes the
// environment read-only, so this calls the C runtime through dart:ffi.
// Native platforms only. The OCR worker isolate shares the process, so a
// value set here before the model loads is visible to CrispEmbed.
//
// Limitation (Windows): a DLL statically linked against its own CRT keeps a
// private environment copy taken at load time. We update both the Win32
// process block and the shared UCRT copy; a statically linked CrispEmbed
// that was already loaded will only see the value after an app restart.

import 'dart:ffi';
import 'dart:io' show Platform;
import 'dart:typed_data';

typedef _MallocC = Pointer<Uint8> Function(IntPtr);
typedef _MallocD = Pointer<Uint8> Function(int);
typedef _FreeC = Void Function(Pointer<Uint8>);
typedef _FreeD = void Function(Pointer<Uint8>);
typedef _SetenvC = Int32 Function(Pointer<Uint8>, Pointer<Uint8>, Int32);
typedef _SetenvD = int Function(Pointer<Uint8>, Pointer<Uint8>, int);
typedef _UnsetenvC = Int32 Function(Pointer<Uint8>);
typedef _UnsetenvD = int Function(Pointer<Uint8>);
typedef _PutenvSC = Int32 Function(Pointer<Uint8>, Pointer<Uint8>);
typedef _PutenvSD = int Function(Pointer<Uint8>, Pointer<Uint8>);
typedef _SetEnvVarAC = Int32 Function(Pointer<Uint8>, Pointer<Uint8>);
typedef _SetEnvVarAD = int Function(Pointer<Uint8>, Pointer<Uint8>);

/// Sets ([value] non-null) or clears ([value] null) env var [name].
/// Returns false if the platform call is unavailable or fails; never throws.
bool setNativeEnv(String name, String? value) {
  try {
    final crt = Platform.isWindows
        ? DynamicLibrary.open('ucrtbase.dll')
        : DynamicLibrary.process();
    final malloc = crt.lookupFunction<_MallocC, _MallocD>('malloc');
    final free = crt.lookupFunction<_FreeC, _FreeD>('free');

    Pointer<Uint8> cstr(String s) {
      final bytes = Uint8List.fromList([...s.codeUnits, 0]);
      final p = malloc(bytes.length);
      p.asTypedList(bytes.length).setAll(0, bytes);
      return p;
    }

    final n = cstr(name);
    // Windows _putenv_s/SetEnvironmentVariableA delete with an empty value.
    final v = cstr(value ?? '');
    try {
      if (Platform.isWindows) {
        final putenvS = crt.lookupFunction<_PutenvSC, _PutenvSD>('_putenv_s');
        final setEnvA = DynamicLibrary.open(
          'kernel32.dll',
        ).lookupFunction<_SetEnvVarAC, _SetEnvVarAD>('SetEnvironmentVariableA');
        final crtOk = putenvS(n, v) == 0;
        final w32Ok = setEnvA(n, value == null ? nullptr : v) != 0;
        return crtOk && w32Ok;
      }
      if (value == null) {
        final unsetenv = crt.lookupFunction<_UnsetenvC, _UnsetenvD>('unsetenv');
        return unsetenv(n) == 0;
      }
      final setenv = crt.lookupFunction<_SetenvC, _SetenvD>('setenv');
      return setenv(n, v, 1) == 0;
    } finally {
      free(n);
      free(v);
    }
  } catch (_) {
    return false;
  }
}

/// Sets a CrispEmbed license gate to `1` (accepted) or clears it.
void setCrispEmbedLicenseGate(String envVar, bool accepted) {
  setNativeEnv(envVar, accepted ? '1' : null);
}

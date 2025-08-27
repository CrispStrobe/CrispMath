/// lib/engine/cas_bridge.dart (Refined & Simplified)

import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

// --- C function signatures ---
typedef _EvaluateC = Pointer<Utf8> Function(Pointer<Utf8> expression);
typedef _SolveC = Pointer<Utf8> Function(Pointer<Utf8> expression, Pointer<Utf8> symbol);
typedef _FreeStringC = Void Function(Pointer<Utf8> str);

// --- Dart function signatures ---
typedef _EvaluateDart = Pointer<Utf8> Function(Pointer<Utf8> expression);
typedef _SolveDart = Pointer<Utf8> Function(Pointer<Utf8> expression, Pointer<Utf8> symbol);
typedef _FreeStringDart = void Function(Pointer<Utf8> str);

/// A bridge class that loads and interacts with the native C++ CAS library.
class CASBridge {
  late final _EvaluateDart evaluate;
  late final _SolveDart solve;
  late final _FreeStringDart free_string;

  CASBridge() {
    final libraryPath = _getLibraryPath();
    final dylib = DynamicLibrary.open(libraryPath);

    evaluate = dylib.lookup<NativeFunction<_EvaluateC>>('evaluate').asFunction<_EvaluateDart>();
    solve = dylib.lookup<NativeFunction<_SolveC>>('solve').asFunction<_SolveDart>();
    free_string = dylib.lookup<NativeFunction<_FreeStringC>>('free_string').asFunction<_FreeStringDart>();
  }

  String _getLibraryPath() {
    if (Platform.isMacOS) return _findMacOSLibrary('libcas_wrapper.dylib');
    if (Platform.isLinux) return _findLinuxLibrary('libcas_wrapper.so');
    if (Platform.isWindows) return _findWindowsLibrary('cas_wrapper.dll');
    throw Exception('Unsupported platform');
  }

  String _findMacOSLibrary(String libName) {
    // Path for local development via `flutter run`
    final devPath = File(libName);
    if (devPath.existsSync()) {
      print('✅ Found native library for development at: ${devPath.absolute.path}');
      return devPath.path;
    }

    // Path for bundled application
    final bundlePath = File.fromUri(Uri.file(Platform.resolvedExecutable).resolve('../Frameworks/$libName'));
    if (bundlePath.existsSync()) {
      print('✅ Found native library in app bundle at: ${bundlePath.path}');
      return bundlePath.path;
    }

    throw Exception('''
❌ FATAL: Native library "$libName" not found.

Checked Locations:
  • Development: ${devPath.absolute.path}
  • App Bundle: ${bundlePath.path}

Ensure you have run the bundling script:
👉 ./bundle_symengine.sh
''');
  }

  // Basic search for other platforms
  String _findLinuxLibrary(String libName) {
    // Implement a simple search or assume it's in a standard location
    final devPath = File(libName);
    if (devPath.existsSync()) return devPath.path;
    throw Exception('Linux library "$libName" not found.');
  }

  String _findWindowsLibrary(String libName) {
    // Implement a simple search or assume it's in a standard location
    final devPath = File(libName);
    if (devPath.existsSync()) return devPath.path;
    throw Exception('Windows library "$libName" not found.');
  }
}
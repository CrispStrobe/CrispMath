// lib/services/engine_service.dart
//
// Long-evaluation off-main-thread wrapper. The native SymEngine bridge
// is synchronous FFI — calls block the calling isolate until they
// return. For a big integral or matrix inversion that can mean
// 1–5 seconds of UI freeze. This service offloads that work to a
// short-lived worker isolate via [compute] so the calculator stays
// interactive while long calculations run.
//
// The trade-off: each call pays a one-time bridge-initialization cost
// in the worker isolate (~tens of ms — `SymbolicMathBridge()` is a
// per-isolate singleton, so it re-loads symbols there). For quick
// operations (2+3, sin(pi), etc.) that overhead would be noticeable;
// callers should use [shouldRunAsync] to decide whether the
// expression warrants the trip.
//
// Tests have no native bridge available, but compute() still works —
// the CalculatorEngine returns a friendly "requires native library"
// error string. The async API path stays exercised.

import 'package:flutter/foundation.dart' show compute;

import '../engine/calculator_engine.dart';

class EngineService {
  /// Heuristic: returns true when [expression] looks slow enough to
  /// warrant the off-thread trip. Short bare-arithmetic expressions
  /// return false (the bridge-init overhead would dwarf the work).
  /// Anything with an integral, factor, simplify, or matrix shape, or
  /// a long expression, returns true.
  static bool shouldRunAsync(String expression) {
    if (expression.length > 80) return true;
    final slowFunctions = [
      'integrate(',
      'factor(',
      'simplify(',
      'expand(',
      'solve(',
      'limit(',
      'Matrix(',
      'rref(',
      'inv(',
      'det(',
    ];
    for (final fn in slowFunctions) {
      if (expression.contains(fn)) return true;
    }
    // Factorial or fibonacci of large numbers.
    final factMatch = RegExp(r'(\d+)!').firstMatch(expression);
    if (factMatch != null) {
      final n = int.tryParse(factMatch.group(1)!) ?? 0;
      if (n > 50) return true;
    }
    final fibMatch = RegExp(r'fib(?:onacci)?\((\d+)\)').firstMatch(expression);
    if (fibMatch != null) {
      final n = int.tryParse(fibMatch.group(1)!) ?? 0;
      if (n > 100) return true;
    }
    return false;
  }

  /// Run `engine.evaluate(expression)` in a worker isolate. The bridge
  /// is re-initialized in the worker; the result string is sent back
  /// over the isolate boundary. Returns the same string the synchronous
  /// path would return, including error prefixes.
  static Future<String> evaluateAsync(String expression) {
    return compute(_evaluateInIsolate, expression);
  }
}

// Top-level function so `compute` can serialize a reference to it.
String _evaluateInIsolate(String expression) {
  try {
    final engine = CalculatorEngine();
    return engine.evaluate(expression);
  } catch (e) {
    return 'Error: $e';
  }
}

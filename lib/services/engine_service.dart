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

  /// V2: generic dispatch for the specialized CalculatorEngine methods
  /// (expand, simplify, factor, solve, differentiate, integrate,
  /// limit, gcd, lcm, factorial, fibonacci). Each is its own bridge
  /// call so we wrap them individually rather than parsing the
  /// expression string in the isolate. Returns the same string the
  /// synchronous path would.
  static Future<String> runOpAsync(EngineOp op) {
    return compute(_runOpInIsolate, op);
  }
}

/// Tag + args for a generic worker dispatch. Held minimal (5 strings)
/// so it transports cleanly across the isolate boundary via compute().
class EngineOp {
  final String kind;
  final String arg1;
  final String? arg2;
  final String? arg3;
  final String? arg4;
  const EngineOp(this.kind, this.arg1, [this.arg2, this.arg3, this.arg4]);
}

// Top-level functions so `compute` can serialize a reference to them.

String _evaluateInIsolate(String expression) {
  try {
    final engine = CalculatorEngine();
    return engine.evaluate(expression);
  } catch (e) {
    return 'Error: $e';
  }
}

String _runOpInIsolate(EngineOp op) {
  try {
    final engine = CalculatorEngine();
    switch (op.kind) {
      case 'evaluate':
        return engine.evaluate(op.arg1);
      case 'expand':
        return engine.expand(op.arg1);
      case 'simplify':
        return engine.simplify(op.arg1);
      case 'factor':
        return engine.factor(op.arg1);
      case 'solve':
        return engine.solve(op.arg1, op.arg2!);
      case 'differentiate':
        return engine.differentiate(op.arg1, op.arg2!);
      case 'integrate':
        return engine.integrate(op.arg1, op.arg2!, op.arg3, op.arg4);
      case 'limit':
        return engine.limit(op.arg1, op.arg2!, op.arg3!);
      case 'gcd':
        return engine.gcd(op.arg1, op.arg2!);
      case 'lcm':
        return engine.lcm(op.arg1, op.arg2!);
      case 'factorial':
        return engine.factorial(int.parse(op.arg1));
      case 'fibonacci':
        return engine.fibonacci(int.parse(op.arg1));
      default:
        return 'Error: unknown engine op ${op.kind}';
    }
  } catch (e) {
    return 'Error: $e';
  }
}

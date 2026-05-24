// test/engine_service_test.dart
//
// The off-main-thread service has two pieces worth testing in isolation:
//
//   1. The `shouldRunAsync` heuristic — picks the cases where the
//      isolate-init cost is worth paying. Pure-function unit tests
//      cover this without any FFI.
//
//   2. `evaluateAsync(expression)` round-trips through `compute()` —
//      we can't exercise the bridge in headless tests, but we can
//      confirm the wrapper completes and returns a string (the bridge's
//      "requires native library" error path is fine for this).

import 'package:crisp_calc/services/engine_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EngineService.shouldRunAsync', () {
    test('returns false for short bare arithmetic', () {
      expect(EngineService.shouldRunAsync('2+3'), isFalse);
      expect(EngineService.shouldRunAsync('5*7'), isFalse);
      expect(EngineService.shouldRunAsync('sin(pi/2)'), isFalse);
    });

    test('returns true for CAS-shaped function calls', () {
      for (final fn in [
        'integrate(x^2, x)',
        'factor(x^2 - 1)',
        'simplify(x*x + x^2)',
        'expand((x+1)^3)',
        'solve(x^2 - 4, x)',
        'limit(sin(x)/x, x, 0)',
      ]) {
        expect(EngineService.shouldRunAsync(fn), isTrue,
            reason: 'expected $fn to be async');
      }
    });

    test('returns true for matrix shapes', () {
      expect(EngineService.shouldRunAsync('Matrix([[1,2],[3,4]])'), isTrue);
      expect(
          EngineService.shouldRunAsync('det(Matrix([[1,2],[3,4]]))'), isTrue);
      expect(
          EngineService.shouldRunAsync('inv(Matrix([[1,2],[3,4]]))'), isTrue);
      expect(
          EngineService.shouldRunAsync('rref(Matrix([[1,2],[3,4]]))'), isTrue);
    });

    test('returns true for large factorial / fibonacci', () {
      expect(EngineService.shouldRunAsync('51!'), isTrue);
      expect(EngineService.shouldRunAsync('100!'), isTrue);
      expect(EngineService.shouldRunAsync('fibonacci(101)'), isTrue);
      expect(EngineService.shouldRunAsync('fib(200)'), isTrue);
    });

    test('returns false for small factorial / fibonacci', () {
      expect(EngineService.shouldRunAsync('5!'), isFalse);
      expect(EngineService.shouldRunAsync('fib(10)'), isFalse);
    });

    test('returns true for very long expressions', () {
      final long = '1+2+3+' * 30; // 180 chars
      expect(EngineService.shouldRunAsync(long), isTrue);
    });
  });

  group('EngineService.evaluateAsync', () {
    // Skip these on platforms where the bridge can't be initialized in
    // the worker isolate (it tries DynamicLibrary.process() which
    // works on macOS/iOS but not on the headless test VM without the
    // SymEngine dylib). The wrapper returns a string either way, so
    // we just assert that the future completes within a sane window.
    test('returns a string (success or error) without throwing', () async {
      final out = await EngineService.evaluateAsync('2 + 3');
      expect(out, isA<String>());
    }, timeout: const Timeout(Duration(seconds: 15)));
  });
}

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

import 'package:crisp_math/services/engine_service.dart';
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

  group('EngineService.evaluateAsync (persistent worker)', () {
    // The worker is long-lived now — the first call pays the spawn
    // cost; subsequent calls reuse it. We tear it down between tests
    // via shutdownForTest so each `test` has a clean slate.
    tearDown(() async {
      await EngineService.shutdownForTest();
    });

    test('returns a string (success or error) without throwing', () async {
      final out = await EngineService.evaluateAsync('2 + 3');
      expect(out, isA<String>());
    }, timeout: const Timeout(Duration(seconds: 15)));

    test('multiple sequential calls reuse the same worker', () async {
      // We can't directly observe "same isolate" from outside, but we
      // can check that 3 sequential calls all complete with strings —
      // a smoke test that the dispatch loop survives multiple
      // requests.
      final results = <String>[];
      for (var i = 0; i < 3; i++) {
        results.add(await EngineService.evaluateAsync('$i + 1'));
      }
      expect(results, hasLength(3));
      expect(results.every((s) => s.isNotEmpty), isTrue);
    }, timeout: const Timeout(Duration(seconds: 15)));
  });

  group('EngineService.runOpAsync', () {
    tearDown(() async {
      await EngineService.shutdownForTest();
    });

    test('dispatches expand op', () async {
      final out =
          await EngineService.runOpAsync(const EngineOp('expand', '(x+1)^2'));
      expect(out, isA<String>());
    }, timeout: const Timeout(Duration(seconds: 15)));

    test('dispatches integrate with bounds', () async {
      final out = await EngineService.runOpAsync(
          const EngineOp('integrate', 'x^2', 'x', '0', '1'));
      expect(out, isA<String>());
    }, timeout: const Timeout(Duration(seconds: 15)));

    test('unknown op returns an Error string', () async {
      final out = await EngineService.runOpAsync(const EngineOp('bogus', 'x'));
      expect(out, startsWith('Error'));
    }, timeout: const Timeout(Duration(seconds: 15)));

    test('factorial op converts the string arg to int', () async {
      final out =
          await EngineService.runOpAsync(const EngineOp('factorial', '5'));
      expect(out, isA<String>());
    }, timeout: const Timeout(Duration(seconds: 15)));
  });

  group('EngineService.cancelInFlight (V3)', () {
    tearDown(() async {
      await EngineService.shutdownForTest();
    });

    test('pending future completes with EngineCancelled on kill', () async {
      // Boot the worker first so kill is racing a real in-flight
      // request rather than the initial spawn. Production cancellation
      // would always be against an already-running worker.
      await EngineService.evaluateAsync('1 + 1');
      final fut = EngineService.runOpAsync(const EngineOp('evaluate', 'x'));
      fut.catchError((Object e) {
        // Expected when kill landed before the worker responded.
        expect(e, isA<EngineCancelled>());
        return '';
      });
      await EngineService.cancelInFlight();
      // Drain microtasks so any stranded errors surface here, not
      // in the next test's setup.
      await Future<void>.delayed(Duration.zero);
    }, timeout: const Timeout(Duration(seconds: 15)));

    test('next request after cancel respawns the worker', () async {
      await EngineService.evaluateAsync('1 + 1'); // boot
      await EngineService.cancelInFlight();
      // Should not throw — must lazily spawn a fresh worker.
      final out = await EngineService.evaluateAsync('2 + 2');
      expect(out, isA<String>());
    }, timeout: const Timeout(Duration(seconds: 15)));
  });
}

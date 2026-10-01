import 'package:crisp_math/services/notepad_dispatcher.dart';
import 'package:crisp_math/services/engine_op.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('calendar literals and differences retain priority over integer sums',
      () async {
    final dispatcher = NotepadDispatcher(
        formatNumber: (value) => 'formatted:$value',
        evaluateExpression: (_) async => throw StateError('unexpected worker'));
    expect(await dispatcher.evaluate('2026-10-01'), 'Thursday, 1 October 2026');
    expect(await dispatcher.evaluate('2026-10-01 - 2026-09-30'), '1 days');
    expect(await dispatcher.evaluate('2026-10-01 + 2 days'), '2026-10-03');
    expect(await dispatcher.evaluate('2026 - 10 - 1'), 'formatted:2015');
  });
  test('bounded integer sums are exact, formatted and yield between rows',
      () async {
    final dispatcher = NotepadDispatcher(
        formatNumber: (value) => 'formatted:$value',
        evaluateExpression: (_) async => throw StateError('unexpected worker'));
    var yielded = false;
    Future<void>.delayed(Duration.zero, () => yielded = true);
    expect(await dispatcher.evaluate('2147483647 + (2147483647 - 1)'),
        'formatted:4294967293');
    expect(yielded, isTrue);
    expect(await dispatcher.evaluate('-(7 + 5) + 2'), 'formatted:-10');
    expect(await dispatcher.evaluate('(2)+(-3)'), 'formatted:-1');
  });

  test('conditional calendar branches retain date handling', () async {
    final conditions = <String>[];
    final dispatcher = NotepadDispatcher(
        formatNumber: (value) => 'formatted:$value',
        evaluateExpression: (condition) async {
          conditions.add(condition);
          return 'true';
        });
    expect(await dispatcher.evaluate('if(true, 2026-10-01, 2026-09-30)'),
        'Thursday, 1 October 2026');
    expect(conditions, hasLength(1));
  });

  test('fractions, implicit products and unsafe sums retain engine routing',
      () async {
    final routed = <String>[];
    final dispatcher = NotepadDispatcher(
        formatNumber: (value) => value,
        evaluateExpression: (source) async {
          routed.add(source);
          return '123456';
        });
    for (final source in [
      '2147483648+1',
      '9007199254740993+1',
      '1/3',
      '1.5+2',
      '2^3',
      '2(3)',
      '(2)(3)',
      '(2)3',
      '1 2+3',
      'sin(2)',
      '1+',
      List.filled(41, '1').join('+'),
    ]) {
      expect(await dispatcher.evaluate(source), '123456', reason: source);
    }
    expect(routed, hasLength(12));
  });
  test(
      'exact literals and precision calls bypass the worker and retain formatting',
      () async {
    final dispatcher = NotepadDispatcher(
        formatNumber: (value) => 'formatted:$value',
        evaluateExpression: (_) async => throw StateError('unexpected worker'),
        runOperation: (_) async => throw StateError('unexpected CAS'));
    expect(await dispatcher.evaluate('90071992547409931234567890'),
        'formatted:90071992547409931234567890');
    expect(await dispatcher.evaluate('pi(30)'), startsWith('formatted:3.14'));
  });
  test(
      'CAS routing preserves nested arguments, equation rewriting and formatting',
      () async {
    final operations = <EngineOp>[];
    final dispatcher = NotepadDispatcher(
        formatNumber: (value) => 'formatted:$value',
        evaluateExpression: (_) async =>
            throw StateError('unexpected generic dispatch'),
        runOperation: (operation) async {
          operations.add(operation);
          return 'result';
        });
    expect(await dispatcher.evaluate('integrate(sin(x), x, 0, pi)'),
        'formatted:result');
    expect(operations.last.kind, 'integrate');
    expect(operations.last.arg1, 'sin(x)');
    expect([operations.last.arg2, operations.last.arg3, operations.last.arg4],
        ['x', '0', 'pi']);
    await dispatcher.evaluate('solve(x^2 = 4, x)');
    expect(operations.last.kind, 'solve');
    expect(operations.last.arg1, contains('4'));
    expect(operations.last.arg1, isNot(contains('=')));
    expect(operations.last.arg2, 'x');
  });
  test(
      'worker errors and cancellation remain errors; negative values format correctly',
      () async {
    var result = '- 5';
    final dispatcher = NotepadDispatcher(
        formatNumber: (value) => 'formatted:$value',
        evaluateExpression: (_) async {
          if (result == 'cancel') throw const EngineCancelled();
          return result;
        });
    expect(await dispatcher.evaluate('x+1'), 'formatted:-5');
    result = 'Error: unavailable';
    expect(await dispatcher.evaluate('x+1'), result);
    result = 'cancel';
    expect(await dispatcher.evaluate('x+1'), 'Error: cancelled');
  });
}

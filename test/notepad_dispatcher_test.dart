import 'package:crisp_math/services/notepad_dispatcher.dart';
import 'package:crisp_math/services/engine_op.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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

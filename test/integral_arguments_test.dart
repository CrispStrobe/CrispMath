import 'package:flutter_test/flutter_test.dart';
import 'package:crisp_math/services/integral_arguments.dart';
import 'package:crisp_math/services/notepad_dispatcher.dart';

void main() {
  test('flat and tuple bounds share the same operation arguments', () {
    for (final source in ['integrate(x^2,x,0,1)', 'integrate(x^2,(x,0,1))']) {
      expect(parseIntegralArguments(source), ['x^2', 'x', '0', '1']);
    }
    expect(parseIntegralArguments('integrate(sin(x), x)'), ['sin(x)', 'x']);
  });
  test('commas inside bounds remain nested', () {
    expect(parseIntegralArguments('integrate(x,x,min(0,1),max(2,3))'),
        ['x', 'x', 'min(0,1)', 'max(2,3)']);
    expect(parseIntegralArguments('integrate(x,(x,min(0,1),max(2,3)))'),
        ['x', 'x', 'min(0,1)', 'max(2,3)']);
  });
  test('missing, empty and malformed arguments are rejected', () {
    for (final source in [
      'integrate(x)',
      'integrate(x,x,0)',
      'integrate(x,x,,1)',
      'integrate(x,(x,0,1,2))',
      'integrate(x,[x,0,1])',
      'integrate(x,(x,0,1])',
      'integrate(x,x+1,0,1)',
      'integrate(x,,0,1)'
    ]) {
      expect(parseIntegralArguments(source), isNull, reason: source);
    }
  });
  test('limits preserve nested points and reject invalid variable declarations', () {
    expect(parseLimitArguments('limit((sin(x)-x)/x^3,x,min(0,1))'),
        ['(sin(x)-x)/x^3', 'x', 'min(0,1)']);
    for (final source in ['limit(x,x)', 'limit(x,x,,1)', 'limit(x,x+1,0)',
      'limit(x,(x,0))', 'limit(x,x,min(0,1])', 'limit(x,,0)']) {
      expect(parseLimitArguments(source), isNull, reason: source);
    }
  });
  test('worksheet routes both forms with bounds and rejects a lone bound',
      () async {
    final routed = <List<String?>>[];
    final dispatcher = NotepadDispatcher(
        formatNumber: (s) => s,
        runOperation: (op) async {
          routed.add([op.kind, op.arg1, op.arg2, op.arg3, op.arg4]);
          return '1/3';
        });
    expect(await dispatcher.evaluate('integrate(x^2,x,0,1)'), '1/3');
    expect(await dispatcher.evaluate('integrate(x^2,(x,0,1))'), '1/3');
    expect(routed, [
      ['integrate', 'x^2', 'x', '0', '1'],
      ['integrate', 'x^2', 'x', '0', '1']
    ]);
    expect(
        await dispatcher.evaluate('integrate(x^2,x,0)'), startsWith('Error:'));
    expect(routed.length, 2);
  });
}

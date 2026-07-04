// Unit tests for the constant-coefficient linear ODE solver (C3).
// Pure Dart and deterministic — identical output on every platform.

import 'package:crisp_calc/engine/calculator_engine.dart';
import 'package:crisp_calc/engine/ode_solver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final engine = CalculatorEngine();
  String solve(String eq) => OdeSolver.solve(engine, eq);

  group('OdeSolver — homogeneous', () {
    test('first order growth/decay', () {
      expect(solve("y' = 3*y"), 'y = C1*exp(3*x)');
      expect(solve("y' + y = 0"), 'y = C1*exp(-x)');
      expect(solve("2*y' + y = 0"), 'y = C1*exp(-1/2*x)');
    });

    test('second order, distinct real roots', () {
      expect(solve("y'' + 3*y' + 2*y = 0"), 'y = C1*exp(-x) + C2*exp(-2*x)');
      expect(solve("y'' - y = 0"), 'y = C1*exp(x) + C2*exp(-x)');
    });

    test('second order, double root', () {
      expect(solve("y'' - 2*y' + y = 0"), 'y = (C1 + C2*x)*exp(x)');
    });

    test('second order, complex roots', () {
      expect(solve("y'' + y = 0"), 'y = C1*cos(x) + C2*sin(x)');
      expect(solve("y'' + 2*y' + 5*y = 0"),
          'y = exp(-x)*(C1*cos(2*x) + C2*sin(2*x))');
    });

    test('second order, irrational real roots keep exact surds', () {
      final r = solve("y'' - y' - y = 0");
      expect(r, contains('sqrt(5)'));
      expect(r, isNot(contains('2.236')));
    });
  });

  group('OdeSolver — undetermined coefficients', () {
    test('polynomial forcing', () {
      expect(solve("y' + y = x^2"), 'y = C1*exp(-x) + x^2 - 2*x + 2');
      expect(solve("y'' + y = x"), 'y = C1*cos(x) + C2*sin(x) + x');
    });

    test('pure integration when no y term', () {
      expect(solve("y' = x^2"), 'y = C1 + 1/3*x^3');
    });

    test('exponential forcing', () {
      expect(solve("y'' - y = exp(2*x)"),
          'y = C1*exp(x) + C2*exp(-x) + 1/3*exp(2*x)');
    });

    test('exponential resonance -> x*exp', () {
      expect(solve("y' - y = exp(x)"), 'y = C1*exp(x) + x*exp(x)');
    });

    test('trig forcing', () {
      expect(solve("y'' + y = sin(2*x)"),
          'y = C1*cos(x) + C2*sin(x) - 1/3*sin(2*x)');
    });

    test('trig resonance reports honestly', () {
      expect(solve("y'' + 4*y = cos(2*x)"), startsWith('Error'));
    });
  });

  group('OdeSolver — rejections', () {
    test('non-constant coefficient', () {
      expect(solve("x*y' + y = 0"), startsWith('Error'));
    });
    test('unsupported forcing', () {
      expect(solve("y' + y = tan(x)"), startsWith('Error'));
    });
    test('not an ODE', () {
      expect(solve('y = 3'), startsWith('Error'));
      expect(solve('x^2 = 4'), startsWith('Error'));
    });
  });
}

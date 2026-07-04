// Unit tests for the constant-coefficient ODE step generator (C5 /
// education). The final step's `after` must equal OdeSolver.solve so the
// trace can never disagree with the answer; the intermediate steps are
// checked for the key pedagogical content (characteristic equation,
// root classification, homogeneous form).

import 'package:crisp_calc/engine/calculator_engine.dart';
import 'package:crisp_calc/engine/ode_solver.dart';
import 'package:crisp_calc/engine/ode_steps.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final engine = CalculatorEngine();
  List steps(String eq) => OdeStepEngine.steps(engine, eq)!;

  group('OdeStepEngine', () {
    test('distinct real roots: full trace', () {
      final s = steps("y'' + 3*y' + 2*y = 0");
      expect(s.map((e) => e.rule), [
        'Characteristic equation',
        'Roots',
        'Homogeneous solution',
        'General solution',
      ]);
      expect(s[0].after, 'r^2 + 3r + 2 = 0');
      expect(s[1].after, 'r = -1, r = -2');
      expect(s[2].after, contains('C1*exp(-x) + C2*exp(-2*x)'));
      // final line matches the solver exactly
      expect(s.last.after, OdeSolver.solve(engine, "y'' + 3*y' + 2*y = 0"));
    });

    test('complex roots → cos/sin homogeneous form', () {
      final s = steps("y'' + y = 0");
      expect(s[1].after, 'r = 0 ± 1i');
      expect(s[2].after, contains('C1*cos(x) + C2*sin(x)'));
    });

    test('double root → (C1 + C2 x) form', () {
      final s = steps("y'' - 2*y' + y = 0");
      expect(s[1].after, contains('double'));
      expect(s[2].after, contains('(C1 + C2*x)*exp(x)'));
    });

    test('first order', () {
      final s = steps("y' + 2*y = 0");
      expect(s[0].after, 'r + 2 = 0');
      expect(s[1].after, 'r = -2');
      expect(s.last.after, 'y = C1*exp(-2*x)');
    });

    test('forced: homogeneous step shows y_h alone, plus a particular step',
        () {
      final s = steps("y' + y = x^2");
      expect(s.map((e) => e.rule), contains('Particular solution'));
      final yh = s.firstWhere((e) => e.rule == 'Homogeneous solution');
      expect(yh.after, 'y_h = C1*exp(-x)'); // NOT the full answer
      expect(s.last.after, OdeSolver.solve(engine, "y' + y = x^2"));
    });

    test('non-constant-coefficient → null (no trace)', () {
      expect(OdeStepEngine.steps(engine, "y' = x*y"), isNull);
      expect(OdeStepEngine.steps(engine, "x*y' + y = 0"), isNull);
    });

    test('every step has a non-empty English note', () {
      for (final st in steps("y'' + 2*y' + 5*y = 0")) {
        expect(st.note, isNotNull);
        expect(st.note!.trim(), isNotEmpty);
      }
    });
  });
}

import 'dart:math' as math;

import 'package:crisp_math/engine/calculator_engine.dart';
import 'package:crisp_math/engine/linear_system_solver.dart';
import 'package:crisp_math/engine/real_calculus_proofs.dart';
import 'package:crisp_math/engine/result_evidence.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('engine proves consistent overdetermined rational systems exactly', () {
    final engine = CalculatorEngine();
    expect(engine.solveLinearSystem([
      'x+y+z=6', 'x-y=0', '2*x+z=6', 'x+2*y+3*z=12',
    ], ['x', 'y', 'z']), 'x = 2, y = 2, z = 2');
    expect(engine.lastResultEvidence?.accuracy, ResultAccuracy.exact);
  });

  test('exact pivots and symbol order survive redundant rows', () {
    expect(LinearSystemSolver.solve([
      '0=0', 'y+x=3', 'x-y=1', '2*x+2*y=6',
    ], ['y', 'x']), 'y = 1, x = 2');
    expect(LinearSystemSolver.solve(List.filled(32, 'x=7/3'), ['x']),
        'x = 7/3');
  });

  test('inconsistent systems are rejected without least squares or exact badge', () {
    final engine = CalculatorEngine();
    engine.solveLinearSystem(['x=1'], ['x']);
    expect(engine.lastResultEvidence?.accuracy, ResultAccuracy.exact);
    expect(engine.solveLinearSystem(['x+y=3', 'x-y=1', '2*x=5'], ['x', 'y']),
        'Error: linsolve has no solutions');
    expect(engine.lastResultEvidence, isNull);
  });

  test('rank deficient systems do not fabricate a unique solution', () {
    expect(LinearSystemSolver.solve(['x+y=3', '2*x+2*y=6'], ['x', 'y']),
        'Error: linsolve has no unique solution');
    expect(LinearSystemSolver.solve(['0=0'], ['x']),
        'Error: linsolve has no unique solution');
  });

  test('unsupported linear grammar declines without a false exact proof', () {
    for (final source in ['x*x=1', 'a*x=1', 'sin(x)=0', 'x=1=2']) {
      expect(LinearSystemSolver.solve([source], ['x']), isNull, reason: source);
    }
    final engine = CalculatorEngine();
    expect(engine.solveLinearSystem(['x*x=1'], ['x']), startsWith('Error:'));
    expect(engine.lastResultEvidence, isNull);
  });

  test('linear proof respects dimension and source limits', () {
    expect(LinearSystemSolver.solve(List.filled(33, 'x=1'), ['x']),
        startsWith('Error:'));
    expect(LinearSystemSolver.solve(['x=1'], ['x', 'x']), startsWith('Error:'));
    expect(LinearSystemSolver.solve(['x=1'], ['x+1']), startsWith('Error:'));
    final oversized = List.filled(260, 'x').join('+');
    expect(LinearSystemSolver.solve(['$oversized=0'], ['x']), isNull);
  });

  test('unproved rectangular symbolic systems never enter unsafe native linsolve', () {
    final engine = CalculatorEngine();
    for (final equations in [
      ['a*x=1', 'a*x=2'],
      ['a*x+y=1'],
    ]) {
      final symbols = equations.length == 2 ? ['x'] : ['x', 'y'];
      expect(engine.solveLinearSystem(equations, symbols),
          contains('certified exact proof for rectangular systems'));
      expect(engine.lastResultEvidence, isNull);
    }
    // The square symbolic grammar still takes the normal CAS capability path.
    expect(engine.solveLinearSystem(['a*x=1'], ['x']),
        contains('requires a newer native library'));
    expect(engine.lastResultEvidence, isNull);
  });

  test('coefficient growth is bounded before Gaussian elimination allocations', () {
    // A modest hosted control exceeds the coefficient budget without asking
    // the implementation to allocate a gigantic decimal/exponential literal.
    expect(LinearSystemSolver.solve(['(2^64)^80*x=1'], ['x']), isNull);
    expect(LinearSystemSolver.solve(['(2^128)^128*x=1'], ['x']), isNull);
    expect(LinearSystemSolver.solve(['2^100*x=2^100'], ['x']), 'x = 1');
  });

  test('even logarithmic reciprocal moment diverges at either endpoint', () {
    final engine = CalculatorEngine();
    for (final bounds in [['0', '1'], ['1', '0']]) {
      expect(engine.integrate('ln(x)^2/x', 'x', bounds[0], bounds[1]),
          contains('divergent'));
      expect(engine.lastResultEvidence, isNull);
    }
  });

  test('odd and shifted logarithmic reciprocal powers also diverge', () {
    for (final source in ['ln(x)/x', 'log(x)^3/(2*x)',
      'ln(1-x)^2/(1-x)', 'ln(2*x-2)^4/(3*x-3)']) {
      final lower = source.contains('2*x-2') ? '1' : '0';
      final upper = source.contains('2*x-2') ? '2' : '1';
      expect(RealCalculusProofs.definite(source, 'x', lower, upper)?.error,
          contains('divergent'), reason: source);
    }
  });

  test('regular proportional affine logarithmic quotients use their primitive', () {
    final cube = math.pow(math.log(2), 3).toDouble();
    expect(RealCalculusProofs.definite('ln(x)^2/x', 'x', '1', '2')?.value,
        closeTo(cube / 3, 1e-14));
    expect(RealCalculusProofs.definite('ln(x+1)^2/(2*x+2)', 'x', '0', '1')?.value,
        closeTo(cube / 6, 1e-14));
    expect(RealCalculusProofs.definite('ln(2-x)^2/(2-x)', 'x', '0', '1')?.value,
        closeTo(cube / 3, 1e-14));
  });

  test('nonproportional denominators do not receive false endpoint proofs', () {
    for (final source in ['ln(x)^2/(x+1)',
      'ln(x)^2/(x+1/(10^100))', 'ln(x)^2/(x^2)',
      'ln(x)^9/x', 'ln(y)^2/y']) {
      expect(RealCalculusProofs.definite(source, 'x', '0', '1'), isNull,
          reason: source);
    }
  });

  test('negative log arguments fail the real domain rather than return a value', () {
    for (final bounds in [['-1', '1'], ['-2', '-1'], ['1', '-1']]) {
      final result = RealCalculusProofs.definite(
          'ln(x)^2/x', 'x', bounds[0], bounds[1]);
      expect(result?.error, contains('real integrand domain'));
      expect(result?.value, isNull);
    }
  });

  test('bare logarithmic moments retain their integrable endpoint', () {
    final result = RealCalculusProofs.definite('ln(x)^2', 'x', '0', '1');
    expect(result?.error, isNull);
    expect(result?.value, 2);
    expect(CalculatorEngine().integrate('ln(x)^2', 'x', '0', '1'), '2');
  });

  test('tiny positive exact endpoints are not classified as zero', () {
    final result = RealCalculusProofs.definite('ln(x)^2/x', 'x', '1e-320', '1');
    expect(result?.error, isNull);
    expect(result?.value, isNotNull);
    expect(result!.value!.isFinite, isTrue);
    expect(result.value, greaterThan(0));
    final adjacent = RealCalculusProofs.definite(
        'ln(x-1)^2/(x-1)', 'x', '1+1e-100', '2');
    expect(adjacent?.error, isNull);
    expect(adjacent?.value, greaterThan(0));
  });

  test('near-one endpoints retain a representable nonzero logarithmic moment', () {
    final result = RealCalculusProofs.definite(
        'ln(x)^2/x', 'x', '1+1e-100', '1+2e-100');
    expect(result?.error, isNull);
    expect(result?.value, isNotNull);
    expect(result!.value, greaterThan(0));
    // log(1+t)=t+O(t^2), so the relative correction is O(1e-100).
    expect(result.value! / (7e-300 / 3), closeTo(1, 1e-12));
  });

  test('small primitive powers combine with a tiny affine denominator scale', () {
    final result = RealCalculusProofs.definite(
        'ln(x)^2/(x/((10^100)^2))', 'x', '1+1e-150', '1+2e-150');
    expect(result?.error, isNull);
    expect(result?.value, isNotNull);
    expect(result!.value! / (7e-250 / 3), closeTo(1, 1e-12));
  });

  test('reciprocal odd logarithmic moments cancel only on exact symmetry', () {
    expect(RealCalculusProofs.definite('ln(x)/x', 'x', '1/2', '2')?.value, 0);
    final nearby = RealCalculusProofs.definite(
        'ln(x)/x', 'x', '1/2', '2+2e-100');
    expect(nearby?.error, isNull);
    expect(nearby?.value, isNotNull);
    expect(nearby!.value, greaterThan(0));
    expect(nearby.value! / (math.log(2) * 1e-100), closeTo(1, 1e-12));
  });

  test('unrepresentable nonzero integrals decline instead of certifying zero', () {
    expect(RealCalculusProofs.definite(
        'ln(x)^2/x', 'x', '1+1e-200', '1+2e-200'), isNull);
  });
}

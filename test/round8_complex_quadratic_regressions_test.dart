import 'package:crisp_math/engine/calculator_engine.dart';
import 'package:crisp_math/engine/complex_quadratic_solver.dart';
import 'package:crisp_math/engine/result_evidence.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Gaussian coefficients produce exact complete linear and quadratic roots', () {
    final references = <String, List<String>>{
      'x^2-2*I*x-2': ['-1+I', '1+I'],
      'x^2-2*I*x=2': ['-1+I', '1+I'],
      'I*x^2+2*x-I': ['I'],
      '(1+I)*x-(2+3*I)': ['5/2+1/2*I'],
      '(1+I)*x^2-(1+I)': ['-1', '1'],
      'x^2-2*I*x+3': ['-I', '3*I'],
      'x^2-(4+I)*x+5+5*I': ['1+2*I', '3-I'],
      'x/(1+I)-1': ['1+I'],
      'I*(x-2)^2': ['2'],
      '0*x^2+I*x+1': ['I'],
    };
    for (final entry in references.entries) {
      expect(ComplexQuadraticSolver.solve(entry.key, 'x'),
          unorderedEquals(entry.value), reason: entry.key);
    }
    expect(ComplexQuadraticSolver.solve('I*y^2+2*y-I', 'y'), ['I']);
    expect(ComplexQuadraticSolver.solve('I+1', 'x'), isEmpty);
    expect(ComplexQuadraticSolver.solve('I-I', 'x'), isNull,
        reason: 'An identically zero equation cannot be represented by finite roots');
    final engine = CalculatorEngine();
    expect(engine.solve('x^2-2*I*x-2', 'x'), 'x = {-1+I, 1+I}');
    expect(engine.lastResultEvidence?.accuracy, ResultAccuracy.exact);
    expect(engine.lastResultEvidence?.method, ComputationMethod.symbolicEvaluation);
  });

  test('nonrational complex discriminants retain exact symbolic branches', () {
    expect(ComplexQuadraticSolver.solve('x^2+I', 'x'), [
      '((0)-sqrt((-4*I)))/(2)',
      '((0)+sqrt((-4*I)))/(2)',
    ]);
  });

  test('unknown coefficients source holes and budgets decline before solving', () {
    for (final source in [
      'x^2+I*y', 'x^2+i+I', 'sin(I)*x+1', 'x^3+I',
      '(x^2-2*I*x-2)/(x-(1+I))', 'x/(I-I)+1',
      'x^2+I*1e100000000', 'x^2+I*2^100000000',
      'x^2+I*((2^128)^128)', 'x^2+I*(1e1024)^2',
      'x^2+I==2',
    ]) {
      expect(ComplexQuadraticSolver.solve(source, 'x'), isNull, reason: source);
    }
    expect(ComplexQuadraticSolver.solve('x^2+I', 'y'), isNull);
    expect(ComplexQuadraticSolver.solve('I^2+I', 'I'), isNull);
  });
}

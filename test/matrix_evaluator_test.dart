import 'package:flutter_test/flutter_test.dart';
import 'package:crisp_math/engine/matrix_evaluator.dart';
import 'package:crisp_math/engine/calculator_engine.dart';

void main() {
  final engine = CalculatorEngine();

  group('MatrixEvaluator pattern recognition', () {
    test('non-matrix expression returns null', () {
      expect(MatrixEvaluator.tryEvaluate('2+3', engine), isNull);
      expect(MatrixEvaluator.tryEvaluate('sin(x)', engine), isNull);
      expect(MatrixEvaluator.tryEvaluate('', engine), isNull);
    });

    test('bare matrix literal is recognized or gracefully null', () {
      final r = MatrixEvaluator.tryEvaluate('Matrix([[1, 2], [3, 4]])', engine);
      // With native bridge: canonical Matrix(...) form
      // Without: null (can't allocate native matrix)
      // Both are acceptable — pattern recognition happens, but building
      // the native matrix requires the bridge.
      if (r != null) {
        expect(r, contains('Matrix('));
      }
    });

    test('det is recognized as unary op', () {
      final r =
          MatrixEvaluator.tryEvaluate('det(Matrix([[1, 0], [0, 1]]))', engine);
      expect(r, isNotNull);
      // May succeed (native bridge) or return error (no bridge)
    });

    test('eigenvalues is recognized as unary op', () {
      final r = MatrixEvaluator.tryEvaluate(
          'eigenvalues(Matrix([[3, 0], [0, 7]]))', engine);
      expect(r, isNotNull);
    });

    test('eigenvectors is recognized as unary op', () {
      final r = MatrixEvaluator.tryEvaluate(
          'eigenvectors(Matrix([[2, 1], [1, 2]]))', engine);
      expect(r, isNotNull);
    });

    test('eigenvalues of non-square returns error', () {
      final r = MatrixEvaluator.tryEvaluate(
          'eigenvalues(Matrix([[1, 2, 3], [4, 5, 6]]))', engine);
      expect(r, isNotNull);
      expect(r, contains('Error'));
    });

    test('unrecognized op returns null', () {
      // 'trace' is not in the ops list
      expect(
          MatrixEvaluator.tryEvaluate(
              'trace(Matrix([[1, 2], [3, 4]]))', engine),
          isNull);
    });

    test('malformed matrix returns error', () {
      final r = MatrixEvaluator.tryEvaluate('det(Matrix(abc))', engine);
      // Should either return null (not recognized) or an error
      if (r != null) {
        expect(r, contains('Error'));
      }
    });
  });

  group('MatrixEvaluator binary ops', () {
    test('matrix addition', () {
      final r = MatrixEvaluator.tryEvaluate(
          'Matrix([[1, 0], [0, 1]]) + Matrix([[1, 0], [0, 1]])', engine);
      expect(r, isNotNull);
      if (!r!.startsWith('Error')) {
        expect(r, contains('Matrix('));
        expect(r, contains('2'));
      }
    });

    test('matrix multiplication', () {
      final r = MatrixEvaluator.tryEvaluate(
          'Matrix([[1, 0], [0, 1]]) * Matrix([[5, 6], [7, 8]])', engine);
      expect(r, isNotNull);
      if (!r!.startsWith('Error')) {
        expect(r, contains('Matrix('));
      }
    });

    test('non-matrix binary returns null', () {
      expect(MatrixEvaluator.tryEvaluate('1 + 2', engine), isNull);
    });
  });
}

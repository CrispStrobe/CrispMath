import 'package:flutter_test/flutter_test.dart';
import 'package:crisp_math/engine/eigen.dart';

void main() {
  group('eigenvalues', () {
    test('1x1 matrix', () {
      final r = computeEigenvalues([
        [5]
      ]);
      expect(r, isNotNull);
      expect(r!.eigenvalues.length, 1);
      expect(r.eigenvalues[0].real, closeTo(5, 1e-10));
    });

    test('2x2 identity', () {
      final r = computeEigenvalues([
        [1, 0],
        [0, 1],
      ]);
      expect(r, isNotNull);
      expect(r!.eigenvalues.length, 2);
      expect(r.eigenvalues[0].real, closeTo(1, 1e-10));
      expect(r.eigenvalues[1].real, closeTo(1, 1e-10));
    });

    test('2x2 diagonal', () {
      final r = computeEigenvalues([
        [3, 0],
        [0, 7],
      ]);
      expect(r, isNotNull);
      final vals = r!.eigenvalues.map((e) => e.real).toList()..sort();
      expect(vals[0], closeTo(3, 1e-10));
      expect(vals[1], closeTo(7, 1e-10));
    });

    test('2x2 with eigenvectors', () {
      final r = computeEigenvalues([
        [2, 1],
        [1, 2],
      ]);
      expect(r, isNotNull);
      final vals = r!.eigenvalues.map((e) => e.real).toList()..sort();
      expect(vals[0], closeTo(1, 1e-10));
      expect(vals[1], closeTo(3, 1e-10));
      expect(r.eigenvectors, isNotNull);
      expect(r.eigenvectors!.length, 2);
    });

    test('2x2 complex eigenvalues', () {
      // Rotation matrix — eigenvalues are i and -i
      final r = computeEigenvalues([
        [0, -1],
        [1, 0],
      ]);
      expect(r, isNotNull);
      expect(r!.eigenvalues.length, 2);
      // Both have real part 0, imaginary parts +/-1
      for (final e in r.eigenvalues) {
        expect(e.real.abs(), lessThan(1e-10));
        expect(e.imag.abs(), closeTo(1, 1e-10));
      }
    });

    test('3x3 symmetric', () {
      // Known eigenvalues: 1, 2, 3 for this symmetric matrix
      final r = computeEigenvalues([
        [2, -1, 0],
        [-1, 2, -1],
        [0, -1, 2],
      ]);
      expect(r, isNotNull);
      final vals = r!.eigenvalues.map((e) => e.real).toList()..sort();
      expect(vals[0], closeTo(2 - 1.41421356, 1e-4));
      expect(vals[1], closeTo(2, 1e-4));
      expect(vals[2], closeTo(2 + 1.41421356, 1e-4));
    });

    test('3x3 diagonal', () {
      final r = computeEigenvalues([
        [1, 0, 0],
        [0, 5, 0],
        [0, 0, 9],
      ]);
      expect(r, isNotNull);
      final vals = r!.eigenvalues.map((e) => e.real).toList()..sort();
      expect(vals[0], closeTo(1, 1e-10));
      expect(vals[1], closeTo(5, 1e-10));
      expect(vals[2], closeTo(9, 1e-10));
    });

    test('non-square returns null', () {
      final r = computeEigenvalues([
        [1, 2, 3],
        [4, 5, 6],
      ]);
      expect(r, isNull);
    });

    test('empty returns null', () {
      expect(computeEigenvalues([]), isNull);
    });
  });

  group('EigenResult formatting', () {
    test('formatValues real', () {
      final r = EigenResult([const Complex(3), const Complex(-1)]);
      expect(r.formatValues(), '{3, -1}');
    });

    test('formatValues complex', () {
      final r = EigenResult([const Complex(1, 2), const Complex(1, -2)]);
      final s = r.formatValues();
      expect(s, contains('1'));
      expect(s, contains('2i'));
    });

    test('formatVectors', () {
      final r = EigenResult(
        [const Complex(1), const Complex(2)],
        [
          [1, 0],
          [0, 1],
        ],
      );
      expect(r.formatVectors(), '{[1, 0], [0, 1]}');
    });
  });
}

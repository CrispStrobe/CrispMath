// Coverage for the MagicSquare generator helpers. The pure maths
// (constant, symmetry transforms, validation) is tested standalone; two
// end-to-end cases solve the emitted DSL program through CspSolver.

import 'dart:math';

import 'package:crisp_math/engine/csp_solver.dart';
import 'package:crisp_math/engine/magic_square.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Lo Shu 3×3 magic square, row-major.
  const loShu = [2, 7, 6, 9, 5, 1, 4, 3, 8];

  group('MagicSquare maths', () {
    test('magic constant matches N(N²+1)/2', () {
      expect(MagicSquare.constantFor(3), 15);
      expect(MagicSquare.constantFor(4), 34);
      expect(MagicSquare.constantFor(5), 65);
    });

    test('isMagic accepts a valid square and rejects a broken one', () {
      expect(MagicSquare.isMagic(loShu, 3), isTrue);
      final broken = [...loShu]..[0] = 5; // duplicate, breaks rows + perm
      expect(MagicSquare.isMagic(broken, 3), isFalse);
    });

    test('rotate90 / reflectHorizontal / complement preserve magic-ness', () {
      expect(MagicSquare.isMagic(MagicSquare.rotate90(loShu, 3), 3), isTrue);
      expect(MagicSquare.isMagic(MagicSquare.reflectHorizontal(loShu, 3), 3),
          isTrue);
      expect(MagicSquare.isMagic(MagicSquare.complement(loShu, 3), 3), isTrue);
    });

    test('rotate90 four times is the identity', () {
      var g = loShu;
      for (var i = 0; i < 4; i++) {
        g = MagicSquare.rotate90(g, 3);
      }
      expect(g, loShu);
    });

    test('randomVariant always yields a valid magic square', () {
      final rng = Random(12345);
      for (var i = 0; i < 50; i++) {
        final v = MagicSquare.randomVariant(loShu, 3, rng);
        expect(MagicSquare.isMagic(v, 3), isTrue);
      }
    });
  });

  group('MagicSquare end-to-end (solver)', () {
    for (final n in [3, 4]) {
      test('order $n: emitted program solves to a magic square', () async {
        final r = await CspSolver.solveDsl(MagicSquare.buildProgram(n),
            maxSolutions: 1);
        expect(r.ok, isTrue, reason: r.error);
        expect(r.solutions, isNotEmpty);
        final grid = MagicSquare.gridFromSolution(r.solutions.first, n);
        expect(MagicSquare.isMagic(grid, n), isTrue);
      }, timeout: const Timeout(Duration(seconds: 20)));
    }
  });
}

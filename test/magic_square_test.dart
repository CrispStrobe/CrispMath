// Coverage for the MagicSquare generator helpers. The pure maths
// (constant, symmetry transforms, validation) is tested standalone; the
// end-to-end cases solve the emitted DSL program for every offered order
// through CspSolver.

import 'dart:math';

import 'package:crisp_math/engine/csp_solver.dart';
import 'package:crisp_math/engine/magic_square.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every 3×3 arrangement of 1..9 that is a magic square, as row-major
/// comma-joined keys. Enumerated independently of the solver so the
/// symmetry claim can be checked without trusting dart_csp.
Set<String> _all3x3MagicSquares() {
  final found = <String>{};
  final grid = List<int>.filled(9, 0);
  final used = List<bool>.filled(10, false);
  void place(int index) {
    if (index == 9) {
      if (MagicSquare.isMagic(grid, 3)) found.add(grid.join(','));
      return;
    }
    for (var value = 1; value <= 9; value++) {
      if (used[value]) continue;
      used[value] = true;
      grid[index] = value;
      place(index + 1);
      used[value] = false;
    }
  }

  place(0);
  return found;
}

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

    // Order 3 has exactly one essentially-distinct magic square: all eight
    // 3×3 magic squares are dihedral images of the Lo Shu square. The
    // generator's D4 + complement transforms therefore reach every 3×3
    // square, not "eight essentially-distinct" ones.
    test('order 3: one essentially-distinct square whose D4 orbit is all 8', () {
      final all = _all3x3MagicSquares();
      expect(all.length, 8, reason: '3×3 has exactly 8 magic squares');

      final orbit = <String>{};
      for (var turns = 0; turns < 4; turns++) {
        var g = loShu;
        for (var t = 0; t < turns; t++) {
          g = MagicSquare.rotate90(g, 3);
        }
        for (final h in [g, MagicSquare.reflectHorizontal(g, 3)]) {
          orbit.add(h.join(','));
          orbit.add(MagicSquare.complement(h, 3).join(','));
        }
      }
      expect(orbit.length, 8, reason: 'the transforms must not collapse');
      expect(orbit, all,
          reason: 'every 3×3 magic square is in the single D4 orbit');
    });
  });

  group('MagicSquare end-to-end (solver)', () {
    for (final n in [3, 4, 5]) {
      test('order $n: emitted program solves to a magic square', () async {
        final r = await CspSolver.solveDsl(MagicSquare.buildProgram(n),
            maxSolutions: 1);
        expect(r.ok, isTrue, reason: r.error);
        expect(r.solutions, isNotEmpty);
        final grid = MagicSquare.gridFromSolution(r.solutions.first, n);
        expect(MagicSquare.isMagic(grid, n), isTrue);
      }, timeout: Timeout(Duration(seconds: n == 5 ? 120 : 20)));
    }

    // The tab hides Visualize for 5×5 because its replay cannot fit the
    // 20,000-event cap. Guard that reason with the only number the API
    // exposes: the trace stops at the cap and reports itself truncated, so
    // the full length is unknown and must not be quoted anywhere.
    test('5×5 trace exceeds the default 20,000-event cap', () async {
      final trace = await CspSolver.traceDsl(MagicSquare.buildProgram(5));
      expect(trace.ok, isTrue, reason: trace.error);
      expect(trace.truncated, isTrue);
      expect(trace.steps.length, 20000);
    }, timeout: const Timeout(Duration(seconds: 120)));
  });
}

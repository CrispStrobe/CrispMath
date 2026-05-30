import 'dart:math';

/// Pure helpers for the magic-square generator (Constraints → Magic
/// square tab). A magic square of order N places the integers 1..N² in
/// an N×N grid so that every row, column, and both main diagonals sum to
/// the magic constant M = N(N²+1)/2.
///
/// The actual solving is done by `CspSolver.solveDsl` over the program
/// [buildProgram] emits; this class only handles the surrounding maths so
/// it can be unit-tested without the solver. Grids are represented
/// row-major as a `List<int>` of length N².
class MagicSquare {
  MagicSquare._();

  /// Orders the generator UI offers. 6×6 is excluded — its 36-variable
  /// allDifferent makes the backtracking solve impractically slow
  /// (tens of seconds), unlike 3..5 which solve in well under 3s.
  static const List<int> supportedSizes = [3, 4, 5];

  /// The magic constant M = N(N²+1)/2.
  static int constantFor(int n) => n * (n * n + 1) ~/ 2;

  /// Builds the DSL program whose first solution is a magic square of
  /// order [n]: N² distinct values 1..N², with each row, column, and
  /// both diagonals constrained to the magic constant.
  static String buildProgram(int n) {
    final names = [for (var i = 0; i < n * n; i++) 'c$i'];
    final m = constantFor(n);
    final b = StringBuffer();
    b.writeln('vars: ${names.join(', ')} in 1..${n * n}');
    b.writeln('allDifferent(${names.join(', ')})');
    for (var r = 0; r < n; r++) {
      b.writeln('${[
        for (var c = 0; c < n; c++) names[r * n + c]
      ].join(' + ')} == $m');
    }
    for (var c = 0; c < n; c++) {
      b.writeln('${[
        for (var r = 0; r < n; r++) names[r * n + c]
      ].join(' + ')} == $m');
    }
    b.writeln(
        '${[for (var i = 0; i < n; i++) names[i * n + i]].join(' + ')} == $m');
    b.writeln('${[
      for (var i = 0; i < n; i++) names[i * n + (n - 1 - i)]
    ].join(' + ')} == $m');
    return b.toString();
  }

  /// Extracts the row-major grid (`c0..c{N²-1}`) from a solver solution.
  static List<int> gridFromSolution(Map<String, int> solution, int n) =>
      [for (var i = 0; i < n * n; i++) solution['c$i']!];

  /// Rotate the grid 90° clockwise.
  static List<int> rotate90(List<int> g, int n) {
    final out = List<int>.filled(n * n, 0);
    for (var r = 0; r < n; r++) {
      for (var c = 0; c < n; c++) {
        out[r * n + c] = g[(n - 1 - c) * n + r];
      }
    }
    return out;
  }

  /// Mirror the grid left↔right.
  static List<int> reflectHorizontal(List<int> g, int n) {
    final out = List<int>.filled(n * n, 0);
    for (var r = 0; r < n; r++) {
      for (var c = 0; c < n; c++) {
        out[r * n + c] = g[r * n + (n - 1 - c)];
      }
    }
    return out;
  }

  /// Replace each value v with N²+1−v. The complement of a magic square
  /// is itself magic (each N-cell line sum maps M → N(N²+1)−M = M).
  static List<int> complement(List<int> g, int n) =>
      [for (final v in g) n * n + 1 - v];

  /// Picks a random magic-preserving variant of [g]: one of the eight
  /// dihedral (D4) symmetries — k∈0..3 quarter-turns, optionally
  /// mirrored — optionally followed by the complement. Gives a deterministic
  /// solver visual variety on each "Generate" without re-solving. For
  /// order 3 this reaches all 8 essentially-distinct squares; for larger
  /// orders it samples the symmetry orbit of the one solved square.
  static List<int> randomVariant(List<int> g, int n, Random rng) {
    var out = g;
    final turns = rng.nextInt(4);
    for (var i = 0; i < turns; i++) {
      out = rotate90(out, n);
    }
    if (rng.nextBool()) out = reflectHorizontal(out, n);
    if (rng.nextBool()) out = complement(out, n);
    return out;
  }

  /// True when [g] is a valid magic square of order [n]: a permutation of
  /// 1..N² whose rows, columns, and both diagonals each sum to the magic
  /// constant. Used by tests and as a defensive check.
  static bool isMagic(List<int> g, int n) {
    if (g.length != n * n) return false;
    if (g.toSet().length != n * n) return false;
    if (g.any((v) => v < 1 || v > n * n)) return false;
    final m = constantFor(n);
    for (var r = 0; r < n; r++) {
      var sum = 0;
      for (var c = 0; c < n; c++) {
        sum += g[r * n + c];
      }
      if (sum != m) return false;
    }
    for (var c = 0; c < n; c++) {
      var sum = 0;
      for (var r = 0; r < n; r++) {
        sum += g[r * n + c];
      }
      if (sum != m) return false;
    }
    var d1 = 0, d2 = 0;
    for (var i = 0; i < n; i++) {
      d1 += g[i * n + i];
      d2 += g[i * n + (n - 1 - i)];
    }
    return d1 == m && d2 == m;
  }
}

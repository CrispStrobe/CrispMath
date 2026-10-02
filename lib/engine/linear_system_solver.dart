import 'multivariate_poly.dart';
import 'polynomial.dart';

/// Bounded exact Gaussian elimination for rational-coefficient linear systems.
/// null denotes syntax outside this grammar, never a numerical approximation.
class LinearSystemSolver {
  static String? solve(List<String> equations, List<String> symbols) {
    if (symbols.isEmpty ||
        symbols.length > 16 ||
        equations.isEmpty ||
        equations.length > 32 ||
        symbols.toSet().length != symbols.length ||
        symbols.any((s) => !RegExp(r'^[A-Za-z][A-Za-z0-9_]*$').hasMatch(s))) {
      return 'Error: linsolve requires 1–16 distinct symbols and 1–32 equations';
    }
    final rows = <List<Rational>>[];
    for (final equation in equations) {
      if (equation.length > 512) return null;
      final parts = equation.split('=');
      if (parts.length > 2) return null;
      final source =
          parts.length == 2 ? '(${parts[0]})-(${parts[1]})' : equation;
      final poly = MultivariatePolynomial.tryParse(source);
      if (poly == null ||
          poly.totalDegree > 1 ||
          poly.variables.any((v) => !symbols.contains(v))) {
        return null;
      }
      final row = List<Rational>.filled(symbols.length + 1, Rational.zero);
      for (final (powers, coefficient) in poly.terms) {
        final index = powers.indexWhere((power) => power != 0);
        if (index < 0) {
          row.last = row.last - coefficient;
        } else {
          final column = symbols.indexOf(poly.variables[index]);
          row[column] = row[column] + coefficient;
        }
      }
      rows.add(row);
    }
    var pivotRow = 0;
    final pivots = <int>[];
    for (var column = 0;
        column < symbols.length && pivotRow < rows.length;
        column++) {
      var found = pivotRow;
      while (found < rows.length && rows[found][column].isZero) {
        found++;
      }
      if (found == rows.length) continue;
      final temporary = rows[pivotRow];
      rows[pivotRow] = rows[found];
      rows[found] = temporary;
      final pivot = rows[pivotRow][column];
      for (var c = column; c <= symbols.length; c++) {
        rows[pivotRow][c] = rows[pivotRow][c] / pivot;
      }
      for (var r = 0; r < rows.length; r++) {
        if (r == pivotRow || rows[r][column].isZero) continue;
        final factor = rows[r][column];
        for (var c = column; c <= symbols.length; c++) {
          rows[r][c] = rows[r][c] - factor * rows[pivotRow][c];
        }
      }
      pivots.add(column);
      pivotRow++;
    }
    if (rows.any((row) =>
        row.take(symbols.length).every((c) => c.isZero) && !row.last.isZero)) {
      return 'Error: linsolve has no solutions';
    }
    if (pivots.length != symbols.length) {
      return 'Error: linsolve has no unique solution';
    }
    final values = List<Rational>.filled(symbols.length, Rational.zero);
    for (var i = 0; i < pivots.length; i++) {
      values[pivots[i]] = rows[i].last;
    }
    return List.generate(symbols.length, (i) => '${symbols[i]} = ${values[i]}')
        .join(', ');
  }
}

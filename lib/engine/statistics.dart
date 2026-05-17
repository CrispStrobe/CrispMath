// lib/engine/statistics.dart
//
// Descriptive statistics and simple linear regression. Pure Dart, no
// SymEngine dependency — these are standard formulas evaluated in
// double precision. Coverage:
//
//   - count, sum, mean, median, mode
//   - variance & standard deviation (sample n-1 and population n)
//   - min, max, range
//   - quartiles Q1 / Q3, IQR
//   - simple linear regression on (x, y) pairs: slope, intercept, R²

import 'dart:math' as math;

class DescriptiveStats {
  final int count;
  final double sum;
  final double mean;
  final double median;
  final List<double> modes;
  final double sampleVariance;
  final double populationVariance;
  final double sampleStddev;
  final double populationStddev;
  final double min;
  final double max;
  final double range;
  final double q1;
  final double q3;
  final double iqr;

  const DescriptiveStats({
    required this.count,
    required this.sum,
    required this.mean,
    required this.median,
    required this.modes,
    required this.sampleVariance,
    required this.populationVariance,
    required this.sampleStddev,
    required this.populationStddev,
    required this.min,
    required this.max,
    required this.range,
    required this.q1,
    required this.q3,
    required this.iqr,
  });
}

class LinearFit {
  final double slope;
  final double intercept;
  final double rSquared;
  final int count;
  const LinearFit({
    required this.slope,
    required this.intercept,
    required this.rSquared,
    required this.count,
  });
}

class PolynomialFit {
  /// Coefficients in ascending order — `coefficients[0]` is the
  /// constant term, `coefficients[1]` is the x coefficient, and so on.
  final List<double> coefficients;
  final double rSquared;
  final int count;
  final int degree;
  const PolynomialFit({
    required this.coefficients,
    required this.rSquared,
    required this.count,
    required this.degree,
  });

  /// Evaluate the fitted polynomial at [x]. Useful for plotting the
  /// regression curve on the data points.
  double evaluate(double x) {
    var y = 0.0;
    var p = 1.0;
    for (final c in coefficients) {
      y += c * p;
      p *= x;
    }
    return y;
  }
}

class Statistics {
  /// Compute everything in DescriptiveStats from a list of numbers.
  /// Throws ArgumentError on empty input.
  static DescriptiveStats describe(List<double> data) {
    if (data.isEmpty) {
      throw ArgumentError('describe() requires at least one data point.');
    }
    final n = data.length;
    final sorted = List<double>.from(data)..sort();
    final s = sorted.reduce((a, b) => a + b);
    final mean = s / n;

    // Variance: Welford-style two-pass is more numerically stable than
    // the textbook sum-of-squares form, but for small student-scale
    // datasets the difference is invisible. Use the textbook form.
    double sqDev = 0;
    for (final v in sorted) {
      final d = v - mean;
      sqDev += d * d;
    }
    final populationVariance = sqDev / n;
    final sampleVariance = n > 1 ? sqDev / (n - 1) : 0.0;
    final populationStddev = math.sqrt(populationVariance);
    final sampleStddev = math.sqrt(sampleVariance);

    return DescriptiveStats(
      count: n,
      sum: s,
      mean: mean,
      median: _median(sorted),
      modes: _modes(data),
      sampleVariance: sampleVariance,
      populationVariance: populationVariance,
      sampleStddev: sampleStddev,
      populationStddev: populationStddev,
      min: sorted.first,
      max: sorted.last,
      range: sorted.last - sorted.first,
      q1: _quantile(sorted, 0.25),
      q3: _quantile(sorted, 0.75),
      iqr: _quantile(sorted, 0.75) - _quantile(sorted, 0.25),
    );
  }

  /// Least-squares linear regression `y = a*x + b` on paired data.
  /// Throws when [xs] and [ys] differ in length or have fewer than two
  /// points (R² needs variance in both).
  static LinearFit linearFit(List<double> xs, List<double> ys) {
    if (xs.length != ys.length) {
      throw ArgumentError(
          'linearFit() expects same-length lists; got ${xs.length} vs ${ys.length}.');
    }
    if (xs.length < 2) {
      throw ArgumentError('linearFit() needs at least 2 points.');
    }
    final n = xs.length;
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0, sumY2 = 0;
    for (var i = 0; i < n; i++) {
      sumX += xs[i];
      sumY += ys[i];
      sumXY += xs[i] * ys[i];
      sumX2 += xs[i] * xs[i];
      sumY2 += ys[i] * ys[i];
    }
    final denom = n * sumX2 - sumX * sumX;
    if (denom == 0) {
      // All x's identical — regression undefined.
      return LinearFit(
          slope: double.nan, intercept: double.nan, rSquared: 0, count: n);
    }
    final slope = (n * sumXY - sumX * sumY) / denom;
    final intercept = (sumY - slope * sumX) / n;
    final denomY = n * sumY2 - sumY * sumY;
    final r2 = denomY == 0
        ? 1.0 // y is constant; treat fit as exact (slope=0).
        : math.pow(n * sumXY - sumX * sumY, 2) / (denom * denomY);
    return LinearFit(
      slope: slope,
      intercept: intercept,
      rSquared: r2.toDouble(),
      count: n,
    );
  }

  /// Least-squares polynomial regression of degree [degree]. Solves
  /// the normal equations (XᵀX)c = Xᵀy via Gaussian elimination with
  /// partial pivoting. Fine for the small datasets a calculator
  /// handles; SVD would be more numerically stable for ill-conditioned
  /// Vandermonde matrices but isn't worth the complexity here.
  ///
  /// Throws on inconsistent input or when there are fewer than
  /// [degree] + 1 distinct x-values (system is underdetermined).
  static PolynomialFit polynomialFit(
      List<double> xs, List<double> ys, int degree) {
    if (xs.length != ys.length) {
      throw ArgumentError(
          'polynomialFit() expects same-length lists; got ${xs.length} vs ${ys.length}.');
    }
    if (degree < 1) {
      throw ArgumentError('polynomialFit() degree must be ≥ 1.');
    }
    final n = xs.length;
    if (n < degree + 1) {
      throw ArgumentError(
          'polynomialFit() needs at least ${degree + 1} points for degree $degree.');
    }

    // Build the (degree+1) x (degree+1) normal-equations matrix A and
    // the (degree+1) RHS vector b.
    final m = degree + 1;
    final a = List.generate(m, (_) => List<double>.filled(m, 0.0));
    final b = List<double>.filled(m, 0.0);
    final powerSums = List<double>.filled(2 * m - 1, 0.0);
    for (final x in xs) {
      var p = 1.0;
      for (var k = 0; k < 2 * m - 1; k++) {
        powerSums[k] += p;
        p *= x;
      }
    }
    for (var i = 0; i < m; i++) {
      for (var j = 0; j < m; j++) {
        a[i][j] = powerSums[i + j];
      }
    }
    for (var i = 0; i < n; i++) {
      var p = 1.0;
      for (var k = 0; k < m; k++) {
        b[k] += ys[i] * p;
        p *= xs[i];
      }
    }

    // Gaussian elimination with partial pivoting.
    for (var k = 0; k < m; k++) {
      // Find pivot.
      var maxRow = k;
      var maxVal = a[k][k].abs();
      for (var r = k + 1; r < m; r++) {
        if (a[r][k].abs() > maxVal) {
          maxVal = a[r][k].abs();
          maxRow = r;
        }
      }
      if (maxVal < 1e-14) {
        throw ArgumentError(
            'polynomialFit() system is singular (need more distinct x-values).');
      }
      if (maxRow != k) {
        final tmpRow = a[k];
        a[k] = a[maxRow];
        a[maxRow] = tmpRow;
        final tmpB = b[k];
        b[k] = b[maxRow];
        b[maxRow] = tmpB;
      }
      // Eliminate.
      for (var r = k + 1; r < m; r++) {
        final factor = a[r][k] / a[k][k];
        for (var c = k; c < m; c++) {
          a[r][c] -= factor * a[k][c];
        }
        b[r] -= factor * b[k];
      }
    }
    // Back-substitution.
    final coeffs = List<double>.filled(m, 0.0);
    for (var i = m - 1; i >= 0; i--) {
      var s = b[i];
      for (var j = i + 1; j < m; j++) {
        s -= a[i][j] * coeffs[j];
      }
      coeffs[i] = s / a[i][i];
    }

    // R² = 1 - SS_res / SS_tot
    final yMean = ys.reduce((a, b) => a + b) / n;
    var ssRes = 0.0;
    var ssTot = 0.0;
    for (var i = 0; i < n; i++) {
      var yPred = 0.0;
      var p = 1.0;
      for (final c in coeffs) {
        yPred += c * p;
        p *= xs[i];
      }
      ssRes += math.pow(ys[i] - yPred, 2);
      ssTot += math.pow(ys[i] - yMean, 2);
    }
    final r2 = ssTot == 0 ? 1.0 : 1.0 - ssRes / ssTot;

    return PolynomialFit(
      coefficients: coeffs,
      rSquared: r2,
      count: n,
      degree: degree,
    );
  }

  // === Internal helpers ===================================================

  static double _median(List<double> sorted) {
    final n = sorted.length;
    return n.isOdd
        ? sorted[n ~/ 2]
        : 0.5 * (sorted[n ~/ 2 - 1] + sorted[n ~/ 2]);
  }

  /// All values tied for the highest frequency. Returns empty list when
  /// every value appears exactly once (no meaningful mode).
  static List<double> _modes(List<double> data) {
    if (data.length < 2) return const [];
    final counts = <double, int>{};
    for (final v in data) {
      counts[v] = (counts[v] ?? 0) + 1;
    }
    final maxCount = counts.values.reduce(math.max);
    if (maxCount == 1) return const [];
    final modes = <double>[];
    counts.forEach((k, c) {
      if (c == maxCount) modes.add(k);
    });
    modes.sort();
    return modes;
  }

  /// Linear-interpolation quantile (R type 7 / Excel-style). [sorted]
  /// must already be ascending. [p] in [0, 1].
  static double _quantile(List<double> sorted, double p) {
    final n = sorted.length;
    if (n == 1) return sorted[0];
    final h = (n - 1) * p;
    final lo = h.floor();
    final hi = h.ceil();
    if (lo == hi) return sorted[lo];
    final w = h - lo;
    return sorted[lo] * (1 - w) + sorted[hi] * w;
  }
}

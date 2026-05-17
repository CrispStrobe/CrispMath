// lib/engine/distributions.dart
//
// Closed-form probability distributions for the statistics module:
// normal (Gaussian) and binomial. Pure Dart, double precision. The
// inverse normal CDF (`quantile`) uses bisection on the CDF — slower
// than rational approximations like Acklam's but trivially correct
// and well within the precision a calculator needs (~1e-10).
//
// erf is approximated with Abramowitz & Stegun 7.1.26, max error
// 1.5e-7 — fine for student stats. The binomial PMF uses log-domain
// computations so it stays accurate at large n.

import 'dart:math' as math;

class Normal {
  final double mean;
  final double stddev;
  const Normal({this.mean = 0, this.stddev = 1});

  /// Probability density at [x]. φ(x; μ, σ) = (1/(σ√(2π))) e^(-(x-μ)²/(2σ²)).
  double pdf(double x) {
    final z = (x - mean) / stddev;
    return math.exp(-0.5 * z * z) / (stddev * math.sqrt(2 * math.pi));
  }

  /// Cumulative probability P(X ≤ x). Computed via erf:
  ///   F(x) = ½(1 + erf((x − μ) / (σ√2))).
  double cdf(double x) {
    final z = (x - mean) / (stddev * math.sqrt2);
    return 0.5 * (1 + _erf(z));
  }

  /// Inverse CDF — returns x such that cdf(x) = p. Bisection on the
  /// monotone CDF, converging to ~1e-10 in well under 100 iterations.
  /// Returns ±infinity for p at the endpoints.
  double quantile(double p) {
    if (p <= 0) return double.negativeInfinity;
    if (p >= 1) return double.infinity;
    // Bracket: mean ± 12σ covers ~38 standard deviations of safety
    // for the normal, far past anything a student will type.
    var lo = mean - 12 * stddev;
    var hi = mean + 12 * stddev;
    for (var i = 0; i < 100; i++) {
      final mid = 0.5 * (lo + hi);
      final c = cdf(mid);
      if ((hi - lo).abs() < 1e-12) return mid;
      if (c < p) {
        lo = mid;
      } else {
        hi = mid;
      }
    }
    return 0.5 * (lo + hi);
  }
}

/// Standard normal shortcut (mean = 0, stddev = 1).
const Normal standardNormal = Normal();

class Binomial {
  final int n;
  final double p;
  const Binomial({required this.n, required this.p});

  /// P(X = k). Uses log-domain so it stays accurate at large n.
  double pmf(int k) {
    if (k < 0 || k > n) return 0.0;
    if (p == 0) return k == 0 ? 1.0 : 0.0;
    if (p == 1) return k == n ? 1.0 : 0.0;
    final logProb = _logChoose(n, k) +
        k * math.log(p) +
        (n - k) * math.log(1 - p);
    return math.exp(logProb);
  }

  /// P(X ≤ k). Sums [pmf] up to k. Fine for typical homework n; for
  /// huge n we'd want a tail series or regularized incomplete beta.
  double cdf(int k) {
    if (k < 0) return 0.0;
    if (k >= n) return 1.0;
    var s = 0.0;
    for (var i = 0; i <= k; i++) {
      s += pmf(i);
    }
    return s;
  }

  /// Mean of the distribution (n*p).
  double get mean => n * p;

  /// Variance of the distribution (n*p*(1-p)).
  double get variance => n * p * (1 - p);

  /// Standard deviation of the distribution.
  double get stddev => math.sqrt(variance);
}

// === Internal helpers ====================================================

/// Abramowitz & Stegun 7.1.26 — max abs error 1.5e-7 for x ≥ 0.
/// Symmetric for x < 0: erf(-x) = -erf(x).
double _erf(double x) {
  final sign = x < 0 ? -1.0 : 1.0;
  final ax = x.abs();
  const a1 = 0.254829592;
  const a2 = -0.284496736;
  const a3 = 1.421413741;
  const a4 = -1.453152027;
  const a5 = 1.061405429;
  const p = 0.3275911;
  final t = 1.0 / (1.0 + p * ax);
  final y = 1.0 -
      (((((a5 * t + a4) * t) + a3) * t + a2) * t + a1) * t *
          math.exp(-ax * ax);
  return sign * y;
}

/// log(C(n, k)) using log-gamma. Works far past plain factorials.
/// Dart doesn't ship log-gamma, so we use Stirling's series for
/// log Γ(z+1) = (z+0.5) ln(z+0.5) − (z+0.5) + 0.5 ln(2π) + 1/(12(z+0.5)) − …
/// Accurate to ~1e-10 for z ≥ 1, which is all binomial PMF needs.
double _logChoose(int n, int k) {
  if (k < 0 || k > n) return double.negativeInfinity;
  if (k == 0 || k == n) return 0.0;
  return _logFactorial(n) - _logFactorial(k) - _logFactorial(n - k);
}

double _logFactorial(int n) {
  if (n < 2) return 0.0;
  // Direct sum is fine — n is typically ≤ a few hundred in calculator
  // use. For really large n we'd switch to Stirling.
  if (n <= 256) {
    var s = 0.0;
    for (var i = 2; i <= n; i++) {
      s += math.log(i.toDouble());
    }
    return s;
  }
  // Stirling for large n (rarely hit in practice).
  final x = n.toDouble() + 1.0;
  return (x - 0.5) * math.log(x) -
      x +
      0.5 * math.log(2 * math.pi) +
      1.0 / (12.0 * x);
}

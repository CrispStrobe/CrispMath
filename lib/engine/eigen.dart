// lib/engine/eigen.dart
//
// Pure-Dart eigenvalue/eigenvector computation for small matrices.
// Uses closed-form solutions for 2x2, QR algorithm for larger.

import 'dart:math' as math;

class EigenResult {
  final List<Complex> eigenvalues;
  final List<List<double>>? eigenvectors;

  EigenResult(this.eigenvalues, [this.eigenvectors]);

  String formatValues() {
    final parts = eigenvalues.map((e) {
      if (e.imag.abs() < 1e-10) {
        return _fmt(e.real);
      }
      final sign = e.imag >= 0 ? '+' : '-';
      return '${_fmt(e.real)} $sign ${_fmt(e.imag.abs())}i';
    });
    return '{${parts.join(', ')}}';
  }

  String formatVectors() {
    if (eigenvectors == null) return 'N/A';
    final rows = eigenvectors!.map((v) {
      return '[${v.map(_fmt).join(', ')}]';
    });
    return '{${rows.join(', ')}}';
  }

  static String _fmt(double v) {
    if (v == v.roundToDouble() && v.abs() < 1e12) {
      return v.toInt().toString();
    }
    // Remove trailing zeros
    var s = v.toStringAsFixed(6);
    if (s.contains('.')) {
      s = s.replaceAll(RegExp(r'0+$'), '');
      s = s.replaceAll(RegExp(r'\.$'), '');
    }
    return s;
  }
}

class Complex {
  final double real;
  final double imag;
  const Complex(this.real, [this.imag = 0]);

  Complex operator +(Complex o) => Complex(real + o.real, imag + o.imag);
  Complex operator -(Complex o) => Complex(real - o.real, imag - o.imag);
  double get magnitude => math.sqrt(real * real + imag * imag);

  @override
  String toString() => imag.abs() < 1e-10 ? '$real' : '$real + ${imag}i';
}

/// Compute eigenvalues of a square matrix [m] (row-major 2D list).
/// Returns null if the matrix is not square or empty.
EigenResult? computeEigenvalues(List<List<double>> m) {
  final n = m.length;
  if (n == 0 || m.any((r) => r.length != n)) return null;

  if (n == 1) {
    return EigenResult([Complex(m[0][0])]);
  }

  if (n == 2) {
    return _eigen2x2(m);
  }

  // QR algorithm for n >= 3
  return _eigenQR(m);
}

/// Closed-form 2x2 eigenvalues via characteristic polynomial.
EigenResult _eigen2x2(List<List<double>> m) {
  final a = m[0][0], b = m[0][1], c = m[1][0], d = m[1][1];
  final trace = a + d;
  final det = a * d - b * c;
  final disc = trace * trace - 4 * det;

  if (disc >= 0) {
    final sqrtDisc = math.sqrt(disc);
    final l1 = (trace + sqrtDisc) / 2;
    final l2 = (trace - sqrtDisc) / 2;

    // Compute eigenvectors
    final vecs = <List<double>>[];
    for (final l in [l1, l2]) {
      final v = _eigenvector2x2(m, l);
      if (v != null) vecs.add(v);
    }

    return EigenResult(
      [Complex(l1), Complex(l2)],
      vecs.length == 2 ? vecs : null,
    );
  } else {
    final realPart = trace / 2;
    final imagPart = math.sqrt(-disc) / 2;
    return EigenResult([
      Complex(realPart, imagPart),
      Complex(realPart, -imagPart),
    ]);
  }
}

List<double>? _eigenvector2x2(List<List<double>> m, double lambda) {
  final a = m[0][0] - lambda;
  final b = m[0][1];
  final c = m[1][0];
  final d = m[1][1] - lambda;

  // Use the row with larger coefficients
  if (a.abs() > 1e-10 || b.abs() > 1e-10) {
    if (b.abs() > 1e-10) {
      final norm = math.sqrt(a * a + b * b);
      return [-b / norm, a / norm];
    }
    return [0, 1];
  }
  if (c.abs() > 1e-10 || d.abs() > 1e-10) {
    if (d.abs() > 1e-10) {
      final norm = math.sqrt(c * c + d * d);
      return [-d / norm, c / norm];
    }
    return [0, 1];
  }
  return [1, 0]; // Identity-like
}

/// QR algorithm with implicit shifts for general n x n matrices.
/// Returns eigenvalues (possibly complex for real Schur form 2x2 blocks).
EigenResult _eigenQR(List<List<double>> m) {
  final n = m.length;

  // Copy to working matrix (Hessenberg reduction first)
  var h = _hessenberg(m);

  // QR iteration with Wilkinson shift
  const maxIter = 200;
  for (var iter = 0; iter < maxIter; iter++) {
    // Check convergence of last subdiagonal
    var converged = true;
    for (var i = 1; i < n; i++) {
      if (h[i][i - 1].abs() >
          1e-12 * (h[i][i].abs() + h[i - 1][i - 1].abs() + 1e-30)) {
        converged = false;
        break;
      }
    }
    if (converged) break;

    // Wilkinson shift
    final shift = h[n - 1][n - 1];

    // Shift
    for (var i = 0; i < n; i++) {
      h[i][i] -= shift;
    }

    // QR decomposition via Givens rotations
    final cs = List<double>.filled(n - 1, 0);
    final sn = List<double>.filled(n - 1, 0);
    for (var i = 0; i < n - 1; i++) {
      final r = math.sqrt(h[i][i] * h[i][i] + h[i + 1][i] * h[i + 1][i]);
      if (r < 1e-30) {
        cs[i] = 1;
        sn[i] = 0;
        continue;
      }
      cs[i] = h[i][i] / r;
      sn[i] = h[i + 1][i] / r;

      // Apply Givens rotation to rows i, i+1
      for (var j = 0; j < n; j++) {
        final t1 = cs[i] * h[i][j] + sn[i] * h[i + 1][j];
        final t2 = -sn[i] * h[i][j] + cs[i] * h[i + 1][j];
        h[i][j] = t1;
        h[i + 1][j] = t2;
      }
    }

    // R * Q (apply Givens from right)
    for (var i = 0; i < n - 1; i++) {
      for (var j = 0; j < n; j++) {
        final t1 = cs[i] * h[j][i] + sn[i] * h[j][i + 1];
        final t2 = -sn[i] * h[j][i] + cs[i] * h[j][i + 1];
        h[j][i] = t1;
        h[j][i + 1] = t2;
      }
    }

    // Un-shift
    for (var i = 0; i < n; i++) {
      h[i][i] += shift;
    }
  }

  // Extract eigenvalues from quasi-upper-triangular form
  final eigenvalues = <Complex>[];
  var i = 0;
  while (i < n) {
    if (i + 1 < n && h[i + 1][i].abs() > 1e-10) {
      // 2x2 block — extract complex conjugate pair
      final a = h[i][i], b = h[i][i + 1];
      final c = h[i + 1][i], d = h[i + 1][i + 1];
      final trace = a + d;
      final det = a * d - b * c;
      final disc = trace * trace - 4 * det;
      if (disc >= 0) {
        eigenvalues.add(Complex((trace + math.sqrt(disc)) / 2));
        eigenvalues.add(Complex((trace - math.sqrt(disc)) / 2));
      } else {
        eigenvalues.add(Complex(trace / 2, math.sqrt(-disc) / 2));
        eigenvalues.add(Complex(trace / 2, -math.sqrt(-disc) / 2));
      }
      i += 2;
    } else {
      eigenvalues.add(Complex(h[i][i]));
      i++;
    }
  }

  return EigenResult(eigenvalues);
}

/// Reduce to upper Hessenberg form via Householder reflections.
List<List<double>> _hessenberg(List<List<double>> m) {
  final n = m.length;
  final h = List<List<double>>.generate(
    n,
    (i) => List<double>.from(m[i]),
  );

  for (var k = 0; k < n - 2; k++) {
    // Build Householder vector for column k, rows k+1..n-1
    var norm = 0.0;
    for (var i = k + 1; i < n; i++) {
      norm += h[i][k] * h[i][k];
    }
    norm = math.sqrt(norm);

    if (norm < 1e-30) continue;

    if (h[k + 1][k] > 0) norm = -norm;
    final v = List<double>.filled(n, 0);
    v[k + 1] = h[k + 1][k] - norm;
    for (var i = k + 2; i < n; i++) {
      v[i] = h[i][k];
    }

    var vNorm = 0.0;
    for (var i = k + 1; i < n; i++) {
      vNorm += v[i] * v[i];
    }
    if (vNorm < 1e-30) continue;

    final factor = 2.0 / vNorm;

    // H = H - factor * v * (v^T * H)
    for (var j = 0; j < n; j++) {
      var dot = 0.0;
      for (var i = k + 1; i < n; i++) {
        dot += v[i] * h[i][j];
      }
      for (var i = k + 1; i < n; i++) {
        h[i][j] -= factor * v[i] * dot;
      }
    }

    // H = H - factor * (H * v) * v^T
    for (var i = 0; i < n; i++) {
      var dot = 0.0;
      for (var j = k + 1; j < n; j++) {
        dot += h[i][j] * v[j];
      }
      for (var j = k + 1; j < n; j++) {
        h[i][j] -= factor * dot * v[j];
      }
    }
  }

  return h;
}

// lib/engine/conic_math.dart
//
// Pure-math helpers for classifying conic sections of the form
//   A x² + B x y + C y² + D x + E y + F = 0
//
// Uses the discriminant Δ = B² − 4AC and the matrix
//   M = [ A   B/2 ]
//       [ B/2  C  ]
// to derive type, center, rotation, and semi-axes.

import 'dart:math' as math;

enum ConicKind {
  circle,
  ellipse,
  parabola,
  hyperbola,
  degenerate,
  notAConic,
}

class ConicAnalysis {
  /// Coefficients of `A x² + B x y + C y² + D x + E y + F = 0`.
  final double a, b, c, d, e, f;

  final double discriminant;
  final ConicKind kind;

  /// Center (only meaningful for central conics, i.e. discriminant != 0).
  final ({double x, double y})? center;

  /// Rotation angle of the principal axes, in radians. Only set when B != 0.
  final double? rotationRadians;

  /// Semi-axes when the shape is non-degenerate (ellipse / hyperbola).
  /// `major` is the longer one. `minor` is the shorter (or conjugate for
  /// hyperbolas).
  final double? semiMajor;
  final double? semiMinor;

  /// Eccentricity, when defined.
  final double? eccentricity;

  /// Notes when the shape is degenerate (point / pair of lines / imaginary).
  final String? notes;

  const ConicAnalysis({
    required this.a,
    required this.b,
    required this.c,
    required this.d,
    required this.e,
    required this.f,
    required this.discriminant,
    required this.kind,
    this.center,
    this.rotationRadians,
    this.semiMajor,
    this.semiMinor,
    this.eccentricity,
    this.notes,
  });
}

ConicAnalysis analyzeConic(
    double a, double b, double c, double d, double e, double f) {
  if (a == 0 && b == 0 && c == 0) {
    return ConicAnalysis(
      a: a,
      b: b,
      c: c,
      d: d,
      e: e,
      f: f,
      discriminant: 0,
      kind: ConicKind.notAConic,
      notes: 'No quadratic terms — this is a line, not a conic.',
    );
  }

  final disc = b * b - 4 * a * c;

  // P9-A5c.1: classify the full 3×3 form first to catch
  // degenerate cases the 2-variable discriminant alone can't
  // distinguish from a true parabola/ellipse/hyperbola.
  //
  // The matrix of the homogeneous form
  //   A x² + B xy + C y² + D x + E y + F = 0
  // is
  //   M3 = [[  A    B/2  D/2 ]
  //         [ B/2    C   E/2 ]
  //         [ D/2  E/2    F  ]]
  // and the conic is degenerate iff det(M3) == 0 (pair of lines,
  // a single point, or an imaginary set with no real points).
  // The discriminant Δ = B² − 4AC then tells the residual shape:
  // Δ < 0 → point / imaginary, Δ > 0 → pair of intersecting
  // lines, Δ = 0 → pair of parallel lines (the cylinder-axis
  // case from A5b's relaxed test).
  final m11 = a;
  final m22 = c;
  final m33 = f;
  final m12 = b / 2;
  final m13 = d / 2;
  final m23 = e / 2;
  final det3 = m11 * (m22 * m33 - m23 * m23) -
      m12 * (m12 * m33 - m23 * m13) +
      m13 * (m12 * m23 - m22 * m13);

  // Classify by discriminant.
  ConicKind kind;
  if (det3.abs() < 1e-9) {
    kind = ConicKind.degenerate;
  } else if (disc.abs() < 1e-9) {
    kind = ConicKind.parabola;
  } else if (disc < 0) {
    kind = (a == c && b == 0) ? ConicKind.circle : ConicKind.ellipse;
  } else {
    kind = ConicKind.hyperbola;
  }

  // Rotation: only meaningful when there's an xy term.
  double? rotation;
  if (b.abs() > 1e-9) {
    rotation = 0.5 * math.atan2(b, a - c);
  }

  // Central conics — compute center and semi-axes.
  ({double x, double y})? center;
  double? semiMajor;
  double? semiMinor;
  double? eccentricity;
  String? notes;

  if (disc.abs() > 1e-9) {
    // Solve [ 2A  B ; B  2C ] [x;y] = [-D;-E].
    final det = 4 * a * c - b * b;
    final cx = (-2 * c * d + b * e) / det;
    final cy = (-2 * a * e + b * d) / det;
    center = (x: cx, y: cy);

    final atCenter =
        a * cx * cx + b * cx * cy + c * cy * cy + d * cx + e * cy + f;
    if (atCenter.abs() < 1e-9) {
      kind = ConicKind.degenerate;
      notes = 'Degenerate at the center (single point or pair of lines).';
    } else {
      // Eigenvalues of [A B/2; B/2 C].
      final trace = a + c;
      final detM = a * c - (b * b) / 4;
      final disc2 = math.sqrt(math.max(0, (trace * trace / 4) - detM));
      final lam1 = trace / 2 + disc2;
      final lam2 = trace / 2 - disc2;
      if (kind == ConicKind.ellipse || kind == ConicKind.circle) {
        final aSq = -atCenter / lam1;
        final bSq = -atCenter / lam2;
        if (aSq > 0 && bSq > 0) {
          final ax = math.sqrt(aSq);
          final bx = math.sqrt(bSq);
          semiMajor = math.max(ax, bx);
          semiMinor = math.min(ax, bx);
          eccentricity =
              math.sqrt(1 - (semiMinor * semiMinor) / (semiMajor * semiMajor));
        } else {
          kind = ConicKind.degenerate;
          notes = 'Imaginary conic — no real points.';
        }
      } else if (kind == ConicKind.hyperbola) {
        final aSq = -atCenter / lam1;
        final bSq = atCenter / lam2;
        if (aSq > 0 && bSq > 0) {
          final ax = math.sqrt(aSq);
          final bx = math.sqrt(bSq);
          semiMajor = ax;
          semiMinor = bx;
          eccentricity = math.sqrt(1 + (bx * bx) / (ax * ax));
        }
      }
    }
  }

  return ConicAnalysis(
    a: a,
    b: b,
    c: c,
    d: d,
    e: e,
    f: f,
    discriminant: disc,
    kind: kind,
    center: center,
    rotationRadians: rotation,
    semiMajor: semiMajor,
    semiMinor: semiMinor,
    eccentricity: eccentricity,
    notes: notes,
  );
}

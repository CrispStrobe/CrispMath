// Sampling for the non-cartesian 2D plot modes (roadmap C5.2):
//   * parametric  (x(t), y(t))            — a curve traced by t
//   * polar       r(θ) → (r·cosθ, r·sinθ) — a curve traced by θ
//   * implicit    F(x, y) = 0             — a level set via marching squares
//
// Pure Dart on NumericFallbackEvaluator (multi-variable, no engine
// round-trip), so this is fast per point and fully unit-testable without
// the Flutter binding. Points and segments are plain records — the
// painter maps them to screen space.

import 'dart:math' as math;

import 'numeric_fallback.dart';

/// A sampled point in math coordinates; [ok] is false when the
/// expression was undefined / non-finite there (a break in the curve).
typedef PlotPt = ({double x, double y, bool ok});

/// A line segment between two math-coordinate points.
typedef PlotSeg = ({double x1, double y1, double x2, double y2});

class PlotTypes {
  /// Parametric curve (x(t), y(t)) for t in [tMin, tMax], [steps]+1 samples.
  /// Points where either expression is undefined get ok=false so the
  /// painter can lift the pen.
  static List<PlotPt> parametric(
    String xExpr,
    String yExpr, {
    required double tMin,
    required double tMax,
    int steps = 400,
  }) {
    final out = <PlotPt>[];
    final dt = (tMax - tMin) / steps;
    for (var i = 0; i <= steps; i++) {
      final t = tMin + i * dt;
      final x = _eval(xExpr, {'t': t});
      final y = _eval(yExpr, {'t': t});
      if (x == null || y == null || !x.isFinite || !y.isFinite) {
        out.add((x: 0, y: 0, ok: false));
      } else {
        out.add((x: x, y: y, ok: true));
      }
    }
    return out;
  }

  /// Polar curve r(θ) for θ in [thMin, thMax], converted to cartesian.
  /// Accepts `theta` or `t` as the angle variable in the expression.
  static List<PlotPt> polar(
    String rExpr, {
    double thMin = 0,
    double thMax = 6.283185307179586, // 2π
    int steps = 720,
  }) {
    final expr = rExpr.replaceAll('θ', 'theta');
    final out = <PlotPt>[];
    final dth = (thMax - thMin) / steps;
    for (var i = 0; i <= steps; i++) {
      final th = thMin + i * dth;
      final r = _eval(expr, {'theta': th, 't': th});
      if (r == null || !r.isFinite) {
        out.add((x: 0, y: 0, ok: false));
      } else {
        out.add((x: r * _cos(th), y: r * _sin(th), ok: true));
      }
    }
    return out;
  }

  /// Zero-contour of F(x, y) over [xMin,xMax]×[yMin,yMax] via marching
  /// squares on a [grid]×[grid] lattice. Returns disconnected segments.
  static List<PlotSeg> implicit(
    String fExpr, {
    required double xMin,
    required double xMax,
    required double yMin,
    required double yMax,
    int grid = 120,
  }) {
    final nx = grid, ny = grid;
    final dx = (xMax - xMin) / nx, dy = (yMax - yMin) / ny;
    // Sample F on the lattice once.
    final vals =
        List.generate(nx + 1, (i) => List<double>.filled(ny + 1, double.nan));
    for (var i = 0; i <= nx; i++) {
      final x = xMin + i * dx;
      for (var j = 0; j <= ny; j++) {
        final y = yMin + j * dy;
        final v = _eval(fExpr, {'x': x, 'y': y});
        vals[i][j] = (v != null && v.isFinite) ? v : double.nan;
      }
    }

    final segs = <PlotSeg>[];
    for (var i = 0; i < nx; i++) {
      for (var j = 0; j < ny; j++) {
        final x0 = xMin + i * dx, x1 = xMin + (i + 1) * dx;
        final y0 = yMin + j * dy, y1 = yMin + (j + 1) * dy;
        final bl = vals[i][j]; // bottom-left
        final br = vals[i + 1][j]; // bottom-right
        final tr = vals[i + 1][j + 1]; // top-right
        final tl = vals[i][j + 1]; // top-left
        if (bl.isNaN || br.isNaN || tr.isNaN || tl.isNaN) continue;

        // Corner sign bits (>= 0 → inside).
        var caseIdx = 0;
        if (bl >= 0) caseIdx |= 1;
        if (br >= 0) caseIdx |= 2;
        if (tr >= 0) caseIdx |= 4;
        if (tl >= 0) caseIdx |= 8;
        if (caseIdx == 0 || caseIdx == 15) continue; // no crossing

        // Edge crossing points (linear interpolation of the zero).
        PlotPt edgeB() => (x: _lerp(x0, x1, bl, br), y: y0, ok: true); // bottom
        PlotPt edgeR() => (x: x1, y: _lerp(y0, y1, br, tr), ok: true); // right
        PlotPt edgeT() => (x: _lerp(x0, x1, tl, tr), y: y1, ok: true); // top
        PlotPt edgeL() => (x: x0, y: _lerp(y0, y1, bl, tl), ok: true); // left

        void add(PlotPt a, PlotPt b) =>
            segs.add((x1: a.x, y1: a.y, x2: b.x, y2: b.y));

        // 16-case marching squares (ambiguous saddles 5/10 split simply).
        switch (caseIdx) {
          case 1:
          case 14:
            add(edgeL(), edgeB());
          case 2:
          case 13:
            add(edgeB(), edgeR());
          case 3:
          case 12:
            add(edgeL(), edgeR());
          case 4:
          case 11:
            add(edgeR(), edgeT());
          case 5:
            add(edgeL(), edgeT());
            add(edgeB(), edgeR());
          case 6:
          case 9:
            add(edgeB(), edgeT());
          case 7:
          case 8:
            add(edgeL(), edgeT());
          case 10:
            add(edgeL(), edgeB());
            add(edgeR(), edgeT());
        }
      }
    }
    return segs;
  }

  // --- helpers ------------------------------------------------------------

  static double? _eval(String expr, Map<String, double> vars) =>
      NumericFallbackEvaluator.evalNumeric(
          expr.replaceAll(' ', '').replaceAll('**', '^'), vars);

  /// Position along [a,b] where a linear function through (a,va),(b,vb)
  /// crosses zero.
  static double _lerp(double a, double b, double va, double vb) {
    final denom = va - vb;
    if (denom == 0) return (a + b) / 2;
    return a + (b - a) * (va / denom);
  }

  static double _sin(double x) => math.sin(x);
  static double _cos(double x) => math.cos(x);
}

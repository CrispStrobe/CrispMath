// Unit tests for the non-cartesian plot samplers (roadmap C5.2).
// Pure math, no Flutter binding — validated against known shapes.

import 'dart:math' as math;

import 'package:crisp_math/engine/plot_types.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlotTypes.parametric', () {
    test('unit circle (cos t, sin t) stays on radius 1', () {
      final pts = PlotTypes.parametric('cos(t)', 'sin(t)',
          tMin: 0, tMax: 2 * math.pi, steps: 200);
      expect(pts.length, 201);
      for (final p in pts) {
        expect(p.ok, isTrue);
        expect(math.sqrt(p.x * p.x + p.y * p.y), closeTo(1.0, 1e-9));
      }
    });

    test('line (t, 2*t + 1)', () {
      final pts =
          PlotTypes.parametric('t', '2*t + 1', tMin: -1, tMax: 1, steps: 4);
      expect(pts.first.x, closeTo(-1, 1e-12));
      expect(pts.first.y, closeTo(-1, 1e-12));
      expect(pts.last.y, closeTo(3, 1e-12));
    });

    test('undefined points marked ok=false', () {
      final pts = PlotTypes.parametric('1/t', 't', tMin: -1, tMax: 1, steps: 2);
      // middle sample is t=0 → 1/t undefined
      expect(pts[1].ok, isFalse);
    });
  });

  group('PlotTypes.polar', () {
    test('r = 1 traces the unit circle', () {
      final pts = PlotTypes.polar('1', steps: 360);
      for (final p in pts) {
        expect(math.sqrt(p.x * p.x + p.y * p.y), closeTo(1.0, 1e-9));
      }
    });

    test('r = theta (Archimedean spiral) grows with angle', () {
      final pts = PlotTypes.polar('theta', thMin: 0, thMax: 4 * math.pi);
      final radii = pts.map((p) => math.sqrt(p.x * p.x + p.y * p.y)).toList();
      expect(radii.first, closeTo(0, 1e-9));
      expect(radii.last, closeTo(4 * math.pi, 1e-6));
    });

    test('θ symbol accepted as the angle variable', () {
      final pts = PlotTypes.polar('2*cos(θ)', steps: 4);
      expect(pts.every((p) => p.ok), isTrue);
    });
  });

  group('PlotTypes.implicit', () {
    test('circle x^2 + y^2 - 1 = 0: all segment endpoints on radius 1', () {
      final segs = PlotTypes.implicit('x^2 + y^2 - 1',
          xMin: -2, xMax: 2, yMin: -2, yMax: 2, grid: 80);
      expect(segs, isNotEmpty);
      for (final s in segs) {
        expect(math.sqrt(s.x1 * s.x1 + s.y1 * s.y1), closeTo(1.0, 0.05));
        expect(math.sqrt(s.x2 * s.x2 + s.y2 * s.y2), closeTo(1.0, 0.05));
      }
    });

    test('line y - x = 0 lies on the diagonal', () {
      final segs = PlotTypes.implicit('y - x',
          xMin: -2, xMax: 2, yMin: -2, yMax: 2, grid: 40);
      expect(segs, isNotEmpty);
      for (final s in segs) {
        expect((s.x1 - s.y1).abs(), lessThan(0.06));
        expect((s.x2 - s.y2).abs(), lessThan(0.06));
      }
    });

    test('no crossing → no segments (x^2 + y^2 + 1)', () {
      final segs = PlotTypes.implicit('x^2 + y^2 + 1',
          xMin: -2, xMax: 2, yMin: -2, yMax: 2, grid: 40);
      expect(segs, isEmpty);
    });

    test('ellipse x^2/4 + y^2 - 1 = 0 spans the expected x-extent', () {
      final segs = PlotTypes.implicit('x^2/4 + y^2 - 1',
          xMin: -3, xMax: 3, yMin: -2, yMax: 2, grid: 100);
      expect(segs, isNotEmpty);
      final maxX =
          segs.expand((s) => [s.x1, s.x2]).reduce((a, b) => a > b ? a : b);
      expect(maxX, closeTo(2.0, 0.1)); // semi-major axis = 2
    });
  });
}

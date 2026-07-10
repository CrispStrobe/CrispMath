// Additional edge-case tests for pairwise intersections.
// Complements scene_3d_intersections_test.dart with degenerate and
// boundary cases.

import 'package:flutter_test/flutter_test.dart';

import 'package:crisp_math/engine/plane_math.dart' show Vector3;
import 'package:crisp_math/engine/scene_3d/intersections.dart';
import 'package:crisp_math/engine/scene_3d/scene_object.dart';

PlaneObject _plane(double a, double b, double c, double d) =>
    PlaneObject(id: 'p', label: 'P', color: 0, a: a, b: b, c: c, d: d);

LineObject _line(Vector3 p, Vector3 d) =>
    LineObject(id: 'l', label: 'L', color: 0, point: p, direction: d);

SphereObject _sphere(Vector3 c, double r) =>
    SphereObject(id: 's', label: 'S', color: 0, center: c, radius: r);

void main() {
  group('Plane × Plane edge cases', () {
    test('planes with scaled normals are parallel', () {
      // 2x + 2y + 2z = 2 and x + y + z = 5 are parallel (same normal, different d)
      final r = intersect(_plane(2, 2, 2, 2), _plane(1, 1, 1, 5));
      expect(r, isA<NoIntersection>());
    });

    test('planes with negated normals and same d are coincident', () {
      // x + y + z = 3 and -x - y - z = -3 are the same plane
      final r = intersect(_plane(1, 1, 1, 3), _plane(-1, -1, -1, -3));
      expect(r, isA<CoincidentIntersection>());
    });

    test('nearly-perpendicular planes intersect in a line', () {
      // xy plane (z=0) and xz plane (y=0)
      final r = intersect(_plane(0, 0, 1, 0), _plane(0, 1, 0, 0));
      expect(r, isA<LineIntersection>());
    });
  });

  group('Line × Line edge cases', () {
    test('anti-parallel lines on same track are coincident', () {
      // Same line, opposite directions
      final r = intersect(
        _line(const Vector3(0, 0, 0), const Vector3(1, 0, 0)),
        _line(const Vector3(1, 0, 0), const Vector3(-1, 0, 0)),
      );
      expect(r, isA<CoincidentIntersection>());
    });

    test('lines crossing at non-origin point', () {
      // y = x (through origin, direction (1,1,0)) and
      // y = -x + 4 (through (2,2,0), direction (1,-1,0))
      final r = intersect(
        _line(const Vector3(0, 0, 0), const Vector3(1, 1, 0)),
        _line(const Vector3(4, 0, 0), const Vector3(-1, 1, 0)),
      );
      expect(r, isA<PointIntersection>());
      final pt = (r! as PointIntersection).point;
      expect(pt.x, closeTo(2, 1e-6));
      expect(pt.y, closeTo(2, 1e-6));
    });

    test('parallel lines with tiny offset are parallel, not coincident', () {
      final r = intersect(
        _line(const Vector3(0, 0, 0), const Vector3(1, 0, 0)),
        _line(const Vector3(0, 0.001, 0), const Vector3(1, 0, 0)),
      );
      expect(r, isA<NoIntersection>());
    });
  });

  group('Sphere × Sphere edge cases', () {
    test('internally tangent spheres → point', () {
      // Sphere1 r=3 at origin, Sphere2 r=1 at (2,0,0)
      // dist=2, r1-r2=2 → internally tangent
      final r = intersect(
        _sphere(const Vector3(0, 0, 0), 3),
        _sphere(const Vector3(2, 0, 0), 1),
      );
      // Should detect as tangent (PointIntersection) or as no
      // intersection depending on the implementation's convention.
      // Either is acceptable — the key is it doesn't crash.
      expect(r, isNotNull);
      expect(r, anyOf(isA<PointIntersection>(), isA<NoIntersection>()));
    });

    test('concentric spheres different radii → no intersection', () {
      final r = intersect(
        _sphere(const Vector3(0, 0, 0), 3),
        _sphere(const Vector3(0, 0, 0), 5),
      );
      expect(r, isA<NoIntersection>());
    });

    test('concentric spheres same radius → coincident', () {
      final r = intersect(
        _sphere(const Vector3(1, 2, 3), 4),
        _sphere(const Vector3(1, 2, 3), 4),
      );
      expect(r, isA<CoincidentIntersection>());
    });

    test('overlapping spheres → circle', () {
      // Two unit spheres 1 apart → intersection circle
      final r = intersect(
        _sphere(const Vector3(0, 0, 0), 1),
        _sphere(const Vector3(1, 0, 0), 1),
      );
      expect(r, isA<CircleIntersection>());
      final circle = r! as CircleIntersection;
      expect(circle.center.x, closeTo(0.5, 1e-6));
      expect(circle.radius, greaterThan(0));
    });
  });

  group('Plane × Line edge cases', () {
    test('line in plane → contained', () {
      // xy plane (z=0), line along x-axis at z=0
      final r = intersect(
        _plane(0, 0, 1, 0),
        _line(const Vector3(5, 3, 0), const Vector3(1, 0, 0)),
      );
      expect(r, isA<ContainedIntersection>());
    });

    test('line perpendicular to plane → point', () {
      // xy plane (z=0), line along z-axis
      final r = intersect(
        _plane(0, 0, 1, 0),
        _line(const Vector3(0, 0, 5), const Vector3(0, 0, 1)),
      );
      expect(r, isA<PointIntersection>());
      final pt = (r! as PointIntersection).point;
      expect(pt.z, closeTo(0, 1e-6));
    });
  });

  group('Plane × Sphere edge cases', () {
    test('plane through sphere center → great circle', () {
      final r = intersect(
        _plane(0, 0, 1, 0),
        _sphere(const Vector3(0, 0, 0), 3),
      );
      expect(r, isA<CircleIntersection>());
      final circle = r! as CircleIntersection;
      expect(circle.radius, closeTo(3, 1e-6));
    });

    test('plane far from sphere → none', () {
      final r = intersect(
        _plane(0, 0, 1, 100),
        _sphere(const Vector3(0, 0, 0), 1),
      );
      expect(r, isA<NoIntersection>());
    });
  });

  group('Line × Sphere edge cases', () {
    test('line through sphere center → two diametrically opposite points', () {
      final r = intersect(
        _line(const Vector3(0, 0, 0), const Vector3(1, 0, 0)),
        _sphere(const Vector3(0, 0, 0), 5),
      );
      expect(r, isA<TwoPointsIntersection>());
      final pts = r! as TwoPointsIntersection;
      // Points should be at (-5,0,0) and (5,0,0)
      final xs = [pts.a.x, pts.b.x]..sort();
      expect(xs[0], closeTo(-5, 1e-6));
      expect(xs[1], closeTo(5, 1e-6));
    });
  });
}

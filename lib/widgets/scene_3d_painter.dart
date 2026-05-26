// P9-A2: CustomPainter for the 3D Scene module.
//
// Iterates [Scene3D.objects] and dispatches by kind. A2 implements
// plane rendering only; later rounds add line (A3), sphere (A3),
// quadric (A5), parametric surface / curve (A6).
//
// Projection: hand-rolled rotation matrix + orthographic projection,
// same shape as Graphing3DScreen's _Surface3DPainter (rounds 33+).
// Factoring out a shared helper is on the table once A3 has landed
// and we've seen the rendering APIs settle.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../engine/plane_math.dart' show Vector3;
import '../engine/scene_3d/scene_object.dart';
import '../engine/scene_3d/scene_state.dart';

class Scene3DPainter extends CustomPainter {
  final Scene3D scene;

  Scene3DPainter({required this.scene});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;
    final range = scene.range;
    final scale = math.min(w, h) * 0.4 * scene.zoom / range;

    final cosA = math.cos(scene.azimuth);
    final sinA = math.sin(scene.azimuth);
    final cosE = math.cos(scene.elevation);
    final sinE = math.sin(scene.elevation);

    // World (x, y, z) → screen offset. Orthographic — depth is
    // dropped, so back-to-front sorting would be a future enhancement
    // (A3 / A4 will need it for proper occlusion).
    Offset project(double x, double y, double z) {
      final x1 = x * cosA - y * sinA;
      final y1 = x * sinA + y * cosA;
      final y2 = y1 * cosE - z * sinE;
      return Offset(cx + x1 * scale, cy - y2 * scale);
    }

    _drawAxes(canvas, project, range);

    for (final obj in scene.objects) {
      if (!obj.visible) continue;
      switch (obj) {
        case PlaneObject p:
          _drawPlane(canvas, p, project, range);
        case LineObject _:
        case SphereObject _:
        case QuadricObject _:
        case ParametricSurfaceObject _:
        case ParametricCurveObject _:
          // Rendering for these kinds lands in A3 / A5 / A6.
          break;
      }
    }
  }

  // ----------------------------------------------------------------
  // Axes
  // ----------------------------------------------------------------

  void _drawAxes(Canvas canvas, Offset Function(double, double, double) project,
      double r) {
    final paint = Paint()..strokeWidth = 1.2;
    paint.color = Colors.red;
    canvas.drawLine(project(-r, 0, 0), project(r, 0, 0), paint);
    paint.color = Colors.green;
    canvas.drawLine(project(0, -r, 0), project(0, r, 0), paint);
    paint.color = Colors.blue;
    canvas.drawLine(project(0, 0, -r), project(0, 0, r), paint);
  }

  // ----------------------------------------------------------------
  // Plane rendering — sample a [range × range] patch in the plane's
  // local (u, v) frame around its closest-to-origin point, draw the
  // outline + a few interior cross-lines for depth.
  // ----------------------------------------------------------------

  void _drawPlane(
    Canvas canvas,
    PlaneObject plane,
    Offset Function(double, double, double) project,
    double range,
  ) {
    final normal = plane.normal;
    final nLen2 = normal.dot(normal);
    if (nLen2 == 0) return;
    final nLen = math.sqrt(nLen2);

    // Closest point on the plane to origin = (d / |n|²) · n.
    final t = plane.d / nLen2;
    final center = Vector3(normal.x * t, normal.y * t, normal.z * t);

    // Two orthonormal vectors spanning the plane. Pick any axis
    // that's not (nearly) parallel to the normal to seed the
    // Gram-Schmidt step.
    final seed = (normal.x.abs() < 0.9)
        ? const Vector3(1, 0, 0)
        : const Vector3(0, 1, 0);
    // u = seed − (seed·n / |n|²) · n, then normalise.
    final proj = seed.dot(normal) / nLen2;
    final uRaw = Vector3(
      seed.x - proj * normal.x,
      seed.y - proj * normal.y,
      seed.z - proj * normal.z,
    );
    final uLen = math.sqrt(uRaw.dot(uRaw));
    if (uLen == 0) return;
    final u = Vector3(uRaw.x / uLen, uRaw.y / uLen, uRaw.z / uLen);
    final vRaw = normal.cross(u);
    final v = Vector3(vRaw.x / nLen, vRaw.y / nLen, vRaw.z / nLen);

    // Sample a square patch in (s, t) ∈ [-range, +range]. 4 boundary
    // edges + a couple of interior cross-lines makes the plane
    // legible after rotation without becoming visual noise.
    Offset cornerAt(double s, double tt) {
      final p3 = Vector3(
        center.x + u.x * s + v.x * tt,
        center.y + u.y * s + v.y * tt,
        center.z + u.z * s + v.z * tt,
      );
      return project(p3.x, p3.y, p3.z);
    }

    final color = Color(plane.color);
    final fill = Paint()
      ..style = PaintingStyle.fill
      ..color = color.withValues(alpha: 0.12);
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = color;
    final faint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = color.withValues(alpha: 0.4);

    final r = range;
    final c00 = cornerAt(-r, -r);
    final c10 = cornerAt(r, -r);
    final c11 = cornerAt(r, r);
    final c01 = cornerAt(-r, r);

    // Filled quad (translucent) so the plane has visual weight even
    // when seen edge-on.
    final path = Path()
      ..moveTo(c00.dx, c00.dy)
      ..lineTo(c10.dx, c10.dy)
      ..lineTo(c11.dx, c11.dy)
      ..lineTo(c01.dx, c01.dy)
      ..close();
    canvas.drawPath(path, fill);

    // 3 interior cross-lines per axis — drawn first so the outline
    // sits on top.
    for (var i = 1; i < 4; i++) {
      final s = -r + (2 * r) * i / 4;
      canvas.drawLine(cornerAt(s, -r), cornerAt(s, r), faint);
      canvas.drawLine(cornerAt(-r, s), cornerAt(r, s), faint);
    }

    // Outline + light label dot at the centroid so the user can tell
    // which plane is which when several overlap.
    canvas.drawPath(path, edge);
    final cDot = cornerAt(0, 0);
    canvas.drawCircle(cDot, 3.5, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant Scene3DPainter old) =>
      old.scene != scene ||
      old.scene.azimuth != scene.azimuth ||
      old.scene.elevation != scene.elevation ||
      old.scene.zoom != scene.zoom ||
      old.scene.range != scene.range;
}

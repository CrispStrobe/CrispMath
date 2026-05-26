// lib/screens/conic_section_screen.dart
//
// Classifies a conic section given as
//   A x² + B x y + C y² + D x + E y + F = 0
// using the discriminant Δ = B² - 4AC and the standard reductions:
//   - Δ <  0 → ellipse (circle when A == C and B == 0; degenerate point if no
//     real solutions)
//   - Δ == 0 → parabola (or degenerate line)
//   - Δ >  0 → hyperbola (or degenerate pair of lines)
//
// We also recover the center for central conics (Δ != 0), and the
// rotation angle when B != 0. The math lives in engine/conic_math.dart so
// it can be unit tested without spinning up a widget tree.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../engine/app_state.dart';
import '../engine/conic_math.dart';
import '../engine/plane_math.dart' show Vector3;
import '../engine/scene_3d/scene_object.dart';
import '../localization/app_localizations.dart';
import 'scene_3d_screen.dart';

class ConicSectionScreen extends StatefulWidget {
  const ConicSectionScreen({super.key});

  @override
  State<ConicSectionScreen> createState() => _ConicSectionScreenState();
}

class _ConicSectionScreenState extends State<ConicSectionScreen> {
  final _a = TextEditingController(text: '1');
  final _b = TextEditingController(text: '0');
  final _c = TextEditingController(text: '1');
  final _d = TextEditingController(text: '-4');
  final _e = TextEditingController(text: '-6');
  final _f = TextEditingController(text: '4');

  String? _output;

  @override
  void dispose() {
    for (final c in [_a, _b, _c, _d, _e, _f]) {
      c.dispose();
    }
    super.dispose();
  }

  double _parse(TextEditingController c) => double.tryParse(c.text.trim()) ?? 0;

  void _analyze() {
    final result = analyzeConic(
      _parse(_a),
      _parse(_b),
      _parse(_c),
      _parse(_d),
      _parse(_e),
      _parse(_f),
    );

    if (result.kind == ConicKind.notAConic) {
      setState(() => _output = result.notes ?? 'Not a conic.');
      return;
    }

    final buf = StringBuffer();
    buf.writeln('Equation:');
    buf.writeln(
        '  ${_fmtConic(result.a, result.b, result.c, result.d, result.e, result.f)} = 0');
    buf.writeln();
    buf.writeln('Discriminant Δ = B² − 4AC = ${_fmt(result.discriminant)}');
    buf.writeln();
    buf.writeln('Type: ${_kindLabel(result.kind)}');
    buf.writeln();

    if (result.rotationRadians != null) {
      buf.writeln('Rotation angle θ = ${_fmt(result.rotationRadians!)} rad '
          '(${_fmt(result.rotationRadians! * 180 / math.pi)}°)');
    }

    final c = result.center;
    if (c != null) {
      buf.writeln('Center: (${_fmt(c.x)}, ${_fmt(c.y)})');
    } else if (result.kind == ConicKind.parabola) {
      buf.writeln('Parabola — axis along the eigenvector of [A B/2; B/2 C] '
          'with eigenvalue 0.');
    }

    if (result.notes != null) {
      buf.writeln(result.notes);
    }

    if (result.semiMajor != null && result.semiMinor != null) {
      if (result.kind == ConicKind.hyperbola) {
        buf.writeln('Semi-transverse axis a = ${_fmt(result.semiMajor!)}');
        buf.writeln('Semi-conjugate axis b = ${_fmt(result.semiMinor!)}');
      } else {
        buf.writeln('Semi-major axis a = ${_fmt(result.semiMajor!)}');
        buf.writeln('Semi-minor axis b = ${_fmt(result.semiMinor!)}');
      }
    }
    if (result.eccentricity != null) {
      buf.writeln('Eccentricity e = ${_fmt(result.eccentricity!)}');
    }

    setState(() => _output = buf.toString());
  }

  static String _kindLabel(ConicKind k) {
    switch (k) {
      case ConicKind.circle:
        return 'Circle';
      case ConicKind.ellipse:
        return 'Ellipse';
      case ConicKind.parabola:
        return 'Parabola';
      case ConicKind.hyperbola:
        return 'Hyperbola';
      case ConicKind.degenerate:
        return 'Degenerate conic';
      case ConicKind.notAConic:
        return 'Not a conic';
    }
  }

  static String _fmt(double v) {
    if ((v - v.roundToDouble()).abs() < 1e-9) return v.toInt().toString();
    return v
        .toStringAsPrecision(6)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  String _fmtConic(double A, double B, double C, double D, double E, double F) {
    final parts = <String>[];
    void add(double v, String label) {
      if (v == 0) return;
      final signed =
          parts.isEmpty ? (v < 0 ? '-' : '') : (v < 0 ? ' - ' : ' + ');
      final abs = v.abs();
      final coef = (abs == 1 && label.isNotEmpty) ? '' : _fmt(abs);
      parts.add('$signed$coef$label');
    }

    add(A, 'x²');
    add(B, 'xy');
    add(C, 'y²');
    add(D, 'x');
    add(E, 'y');
    add(F, '');
    return parts.isEmpty ? '0' : parts.join('');
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.moduleConics)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('A·x² + B·xy + C·y² + D·x + E·y + F = 0'),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: _num(_a, 'A')),
                      const SizedBox(width: 8),
                      Expanded(child: _num(_b, 'B')),
                      const SizedBox(width: 8),
                      Expanded(child: _num(_c, 'C')),
                    ]),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(child: _num(_d, 'D')),
                      const SizedBox(width: 8),
                      Expanded(child: _num(_e, 'E')),
                      const SizedBox(width: 8),
                      Expanded(child: _num(_f, 'F')),
                    ]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.calculate),
                  label: Text(t.buttonClassify),
                  onPressed: _analyze,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.deblur),
                  label: Text(t.conicOpenIn3DScene),
                  onPressed: _openIn3DScene,
                ),
              ),
            ]),
            const SizedBox(height: 16),
            if (_output != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(
                    _output!,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      height: 1.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// P9-A5c.3: lift the user's 2D conic into a 3D quadric that
  /// — when intersected with `z = 0` in the new 3D Scene module —
  /// reproduces a 3D analogue of the conic. The mapping classifies
  /// the user's conic and picks a matching quadric preset:
  ///
  /// - Circle      → Sphere
  /// - Ellipse     → Ellipsoid with the analyzer's semi-axes
  /// - Parabola    → Elliptic Paraboloid
  /// - Hyperbola   → Hyperboloid (1 sheet)
  /// - Degenerate / notAConic → fall back to an ellipsoid placeholder
  ///   the user can edit in the scene.
  ///
  /// The lift isn't a 1:1 reproduction (a 2D ellipse can be the
  /// equator of an ellipsoid, the boundary of a cylinder, or many
  /// other 3D shapes); it's a useful "starting scene" the user can
  /// rotate, edit, and explore. The z = 0 plane is added alongside
  /// so the original conic shows up as the highlighted intersection.
  Future<void> _openIn3DScene() async {
    final t = AppLocalizations.of(context);
    final result = analyzeConic(
      _parse(_a),
      _parse(_b),
      _parse(_c),
      _parse(_d),
      _parse(_e),
      _parse(_f),
    );
    if (result.kind == ConicKind.notAConic) {
      _toast(t.conicLiftNotAConic);
      return;
    }

    final preset = _liftToQuadricPreset(result);
    final quadric = QuadricObject.fromPreset(
      id: generateSceneObjectId(),
      label: _quadricLabelFor(result.kind, t),
      color: 0xFF8E24AA, // purple
      preset: preset,
    );
    const planeColor = 0xFF1E88E5;
    final plane = PlaneObject(
      id: generateSceneObjectId(),
      label: 'z = 0',
      color: planeColor,
      a: 0,
      b: 0,
      c: 1,
      d: 0,
    );
    AppState()
      ..addOrUpdateSceneObject(quadric)
      ..addOrUpdateSceneObject(plane);

    if (!mounted) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => const Scene3DScreen(),
    ));
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      duration: const Duration(seconds: 3),
    ));
  }

  String _quadricLabelFor(ConicKind k, AppLocalizations t) {
    switch (k) {
      case ConicKind.circle:
      case ConicKind.ellipse:
        return t.quadricKindEllipsoid;
      case ConicKind.parabola:
        return t.quadricKindParaboloid;
      case ConicKind.hyperbola:
        return t.quadricKindHyperboloid1;
      case ConicKind.degenerate:
      case ConicKind.notAConic:
        return t.quadricKindEllipsoid;
    }
  }

  QuadricPreset _liftToQuadricPreset(ConicAnalysis a) {
    // Use the analyzer's center when available (central conics).
    final cx = a.center?.x ?? 0.0;
    final cy = a.center?.y ?? 0.0;
    final center = Vector3(cx, cy, 0);
    // Semi-axes: use major/minor from the analyzer when set; pick
    // sensible defaults otherwise. The third axis is the geometric
    // mean of the two so the lifted 3D shape has roughly the same
    // visual scale on each side.
    final sa = a.semiMajor ?? 2.0;
    final sb = a.semiMinor ?? sa;
    final sc = math.sqrt(sa * sb);

    switch (a.kind) {
      case ConicKind.circle:
      case ConicKind.ellipse:
        return QuadricPreset(
          kind: QuadricKind.ellipsoid,
          center: center,
          a: sa,
          b: sb,
          c: sc,
        );
      case ConicKind.parabola:
        return QuadricPreset(
          kind: QuadricKind.ellipticParaboloid,
          center: center,
          a: sa,
          b: sb,
          c: 1.0,
          tExtent: math.max(sa, sb) * 2,
        );
      case ConicKind.hyperbola:
        return QuadricPreset(
          kind: QuadricKind.hyperboloid1Sheet,
          center: center,
          a: sa,
          b: sb,
          c: sc,
        );
      case ConicKind.degenerate:
      case ConicKind.notAConic:
        return const QuadricPreset(
          kind: QuadricKind.ellipsoid,
          center: Vector3(0, 0, 0),
          a: 2,
          b: 2,
          c: 2,
        );
    }
  }

  Widget _num(TextEditingController c, String label) {
    return TextField(
      controller: c,
      keyboardType:
          const TextInputType.numberWithOptions(signed: true, decimal: true),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}

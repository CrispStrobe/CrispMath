// P9-A2: the 3D Scene module screen.
//
// User-facing entry point for the new 3D Scene module described in
// PLAN P9. V1 shows the (single global) [Scene3D] from AppState in
// a rotatable viewport, with an object-list panel for editing.
// A2 ships the Plane object only; A3 wires line + sphere; A4 adds
// pairwise intersections; A5 quadrics; A6 parametrics.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../engine/app_state.dart';
import '../engine/scene_3d/scene_object.dart';
import '../localization/app_localizations.dart';
import '../widgets/scene_3d_object_dialogs.dart';
import '../widgets/scene_3d_painter.dart';

class Scene3DScreen extends StatefulWidget {
  const Scene3DScreen({super.key});

  @override
  State<Scene3DScreen> createState() => _Scene3DScreenState();
}

class _Scene3DScreenState extends State<Scene3DScreen> {
  final AppState _appState = AppState();

  @override
  void initState() {
    super.initState();
    _appState.addListener(_onStateChange);
  }

  @override
  void dispose() {
    _appState.removeListener(_onStateChange);
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  Future<void> _addPlane() async {
    final added = await showPlaneEditorDialog(context);
    if (added != null) {
      _appState.addOrUpdateSceneObject(added);
    }
  }

  Future<void> _editPlane(PlaneObject existing) async {
    final updated = await showPlaneEditorDialog(context, existing: existing);
    if (updated != null) {
      _appState.addOrUpdateSceneObject(updated);
    }
  }

  void _toggleVisibility(SceneObject obj) {
    switch (obj) {
      case PlaneObject p:
        _appState.addOrUpdateSceneObject(PlaneObject(
          id: p.id,
          label: p.label,
          color: p.color,
          visible: !p.visible,
          a: p.a,
          b: p.b,
          c: p.c,
          d: p.d,
        ));
      // Other kinds get the toggle wiring in A3 / A5 / A6.
      case LineObject _:
      case SphereObject _:
      case QuadricObject _:
      case ParametricSurfaceObject _:
      case ParametricCurveObject _:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final scene = _appState.scene3D;
    final wide = MediaQuery.of(context).size.width >= 720;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.module3DScene),
        actions: [
          IconButton(
            icon: const Icon(Icons.center_focus_strong),
            tooltip: t.resetView,
            onPressed: _appState.resetSceneViewport,
          ),
        ],
      ),
      body: wide
          ? Row(
              children: [
                Expanded(flex: 3, child: _buildViewport(context, t)),
                SizedBox(
                  width: 320,
                  child: _buildObjectPanel(context, t, scene.objects),
                ),
              ],
            )
          : Column(
              children: [
                Expanded(child: _buildViewport(context, t)),
                SizedBox(
                  height: 240,
                  child: _buildObjectPanel(context, t, scene.objects),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: Text(t.scene3DAddPlane),
        onPressed: _addPlane,
      ),
    );
  }

  Widget _buildViewport(BuildContext context, AppLocalizations t) {
    final scene = _appState.scene3D;
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: GestureDetector(
        onScaleStart: (_) {},
        onScaleUpdate: (d) {
          final newAz = scene.azimuth - d.focalPointDelta.dx * 0.01;
          final newEl = (scene.elevation + d.focalPointDelta.dy * 0.01)
              .clamp(-math.pi / 2 + 0.01, math.pi / 2 - 0.01);
          final newZoom = d.scale != 1.0
              ? (scene.zoom * d.scale).clamp(0.2, 5.0)
              : scene.zoom;
          _appState.updateSceneViewport(
            azimuth: newAz,
            elevation: newEl,
            zoom: newZoom,
          );
        },
        child: CustomPaint(
          painter: Scene3DPainter(scene: scene),
          size: Size.infinite,
          child: scene.objects.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      t.scene3DEmpty,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildObjectPanel(
    BuildContext context,
    AppLocalizations t,
    List<SceneObject> objects,
  ) {
    if (objects.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            t.scene3DPanelEmpty,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: objects.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (ctx, i) {
        final obj = objects[i];
        return ListTile(
          leading: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: Color(obj.color),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: obj.visible ? Colors.transparent : Colors.grey,
                width: 1.5,
              ),
            ),
          ),
          title: Text(obj.label),
          subtitle: Text(
            _subtitleFor(obj),
            style: const TextStyle(
              fontSize: 11,
              fontFamily: 'monospace',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  obj.visible ? Icons.visibility : Icons.visibility_off,
                  size: 20,
                ),
                tooltip: obj.visible ? t.scene3DHide : t.scene3DShow,
                onPressed: () => _toggleVisibility(obj),
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                tooltip: t.scene3DEdit,
                onPressed: () {
                  if (obj is PlaneObject) _editPlane(obj);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                tooltip: t.scene3DDelete,
                onPressed: () => _appState.removeSceneObject(obj.id),
              ),
            ],
          ),
        );
      },
    );
  }

  String _subtitleFor(SceneObject obj) {
    switch (obj) {
      case PlaneObject p:
        final parts = <String>[];
        void add(double v, String letter) {
          if (v == 0) return;
          final sign =
              parts.isEmpty ? (v < 0 ? '-' : '') : (v < 0 ? ' - ' : ' + ');
          final abs = v.abs();
          final coef = (abs == 1 && letter.isNotEmpty) ? '' : _fmt(abs);
          parts.add('$sign$coef$letter');
        }
        add(p.a, 'x');
        add(p.b, 'y');
        add(p.c, 'z');
        return '${parts.isEmpty ? '0' : parts.join('')} = ${_fmt(p.d)}';
      case LineObject l:
        return '${_pt(l.point)} + t·${_pt(l.direction)}';
      case SphereObject s:
        return '|x − ${_pt(s.center)}| = ${_fmt(s.radius)}';
      case QuadricObject _:
        return 'Quadric';
      case ParametricSurfaceObject _:
        return 'Parametric surface';
      case ParametricCurveObject _:
        return 'Parametric curve';
    }
  }

  static String _pt(dynamic v) {
    // Vector3 from plane_math, but typed dynamic here so this method
    // doesn't have to import it just for formatting.
    return '(${_fmt(v.x as double)}, ${_fmt(v.y as double)}, ${_fmt(v.z as double)})';
  }

  static String _fmt(double v) {
    if ((v - v.roundToDouble()).abs() < 1e-9) return v.toInt().toString();
    return v
        .toStringAsPrecision(6)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }
}

import 'dart:math' as math;

import 'numeric_fallback.dart';
import 'plot_types.dart';

typedef GraphMarker = ({double x, double y, String kind});
typedef GraphFallback = double? Function(String, Map<String, double>);

/// Geometry in mathematical coordinates. No UI objects cross worker boundaries.
class GraphSamples {
  final List<List<PlotPt>> curves;
  final List<List<GraphMarker>> markers;
  final List<PlotPt> special;
  final List<PlotSeg> segments;
  const GraphSamples({
    this.curves = const [],
    this.markers = const [],
    this.special = const [],
    this.segments = const [],
  });

  Map<String, dynamic> toJson() => {
        'curves':
            curves.map((c) => c.map((p) => [p.x, p.y, p.ok]).toList()).toList(),
        'markers': markers
            .map((c) => c.map((p) => [p.x, p.y, p.kind]).toList())
            .toList(),
        'special': special.map((p) => [p.x, p.y, p.ok]).toList(),
        'segments': segments.map((s) => [s.x1, s.y1, s.x2, s.y2]).toList(),
      };

  factory GraphSamples.fromJson(Map<String, dynamic> json) {
    List<PlotPt> points(dynamic list) => (list as List)
        .map(
          (p) => (
            x: (p[0] as num).toDouble(),
            y: (p[1] as num).toDouble(),
            ok: p[2] as bool,
          ),
        )
        .toList();
    return GraphSamples(
      curves: (json['curves'] as List).map(points).toList(),
      markers: (json['markers'] as List)
          .map(
            (c) => (c as List)
                .map(
                  (p) => (
                    x: (p[0] as num).toDouble(),
                    y: (p[1] as num).toDouble(),
                    kind: p[2] as String,
                  ),
                )
                .toList(),
          )
          .toList(),
      special: points(json['special']),
      segments: (json['segments'] as List)
          .map(
            (s) => (
              x1: (s[0] as num).toDouble(),
              y1: (s[1] as num).toDouble(),
              x2: (s[2] as num).toDouble(),
              y2: (s[3] as num).toDouble(),
            ),
          )
          .toList(),
    );
  }
}

GraphSamples sampleGraph(
  Map<String, dynamic> request, {
  GraphFallback? fallback,
}) {
  final xMin = (request['xMin'] as num).toDouble();
  final xMax = (request['xMax'] as num).toDouble();
  final yMin = (request['yMin'] as num).toDouble();
  final yMax = (request['yMax'] as num).toDouble();
  final coarse = request['coarse'] == true;
  final steps = ((request['width'] as num) / (coarse ? 4 : 1)).ceil().clamp(
        80,
        2400,
      );
  final curves = <List<PlotPt>>[];
  final markers = <List<GraphMarker>>[];
  for (final expression in (request['functions'] as List).cast<String>()) {
    final compiled = NumericFallbackEvaluator.compile(expression);
    double? eval(double x) => compiled != null
        ? compiled.evaluate({'x': x})
        : fallback?.call(expression, {'x': x});
    final points = <PlotPt>[];
    for (var i = 0; i <= steps; i++) {
      final x = xMin + (xMax - xMin) * i / steps;
      final y = eval(x);
      points.add((
        x: x,
        y: y != null && y.isFinite ? y : 0,
        ok: y != null && y.isFinite
      ));
    }
    curves.add(points);
    markers.add(
      request['annotations'] == true && !coarse
          ? _markers(points, eval, (request['scale'] as num).toDouble())
          : [],
    );
  }
  var special = <PlotPt>[];
  var segments = <PlotSeg>[];
  switch (request['mode']) {
    case 'parametric':
      special = PlotTypes.parametric(
        request['parametricX'],
        request['parametricY'],
        tMin: request['tMin'],
        tMax: request['tMax'],
        steps: coarse ? 100 : 400,
      );
    case 'polar':
      special = PlotTypes.polar(
        request['polarR'],
        thMax: request['thetaMax'],
        steps: coarse ? 180 : 720,
      );
    case 'implicit':
      segments = PlotTypes.implicit(
        request['implicitF'],
        xMin: xMin,
        xMax: xMax,
        yMin: yMin,
        yMax: yMax,
        grid: coarse ? 35 : 110,
      );
    case 'vectorField':
      segments = PlotTypes.vectorField(
        request['vfU'],
        request['vfV'],
        xMin: xMin,
        xMax: xMax,
        yMin: yMin,
        yMax: yMax,
        grid: coarse ? 10 : 20,
      );
  }
  return GraphSamples(
    curves: curves,
    markers: markers,
    special: special,
    segments: segments,
  );
}

List<GraphMarker> _markers(
  List<PlotPt> points,
  double? Function(double) eval,
  double scale,
) {
  final result = <GraphMarker>[];
  final tolerance =
      (points.last.x - points.first.x).abs() / points.length / 100;
  for (var i = 1; i < points.length; i++) {
    final a = points[i - 1], b = points[i];
    if (!a.ok || !b.ok || (a.y - b.y).abs() > 50 / scale) continue;
    if (a.y == 0 || a.y.sign != b.y.sign) {
      var lo = a.x, hi = b.x, yl = a.y;
      double? root;
      if (a.y == 0) {
        root = a.x;
      } else if (b.y == 0) {
        root = b.x;
      } else {
        for (var n = 0; n < 40; n++) {
          final mid = (lo + hi) / 2;
          final ym = eval(mid);
          if (ym == null || !ym.isFinite) break;
          if (ym.abs() < 1e-8) {
            root = mid;
            break;
          }
          if ((hi - lo).abs() < tolerance) {
            // A sign change across a pole must never become a root marker.
            if (ym.abs() < math.max(a.y.abs(), b.y.abs()) * 0.01) root = mid;
            break;
          }
          if (ym.sign == yl.sign) {
            lo = mid;
            yl = ym;
          } else {
            hi = mid;
          }
        }
      }
      if (root != null &&
          (result.isEmpty || (result.last.x - root).abs() > tolerance)) {
        result.add((x: root, y: 0, kind: 'root'));
      }
    }
    if (i + 1 >= points.length) continue;
    final c = points[i + 1];
    if (!c.ok || (c.y - b.y).abs() > 50 / scale) continue;
    final left = b.y - a.y, right = c.y - b.y;
    if (left == 0 || right == 0 || left.sign == right.sign) continue;
    final denominator = a.y - 2 * b.y + c.y;
    final x = b.x + 0.5 * (a.y - c.y) / denominator * (b.x - a.x);
    final y = eval(x);
    if (y != null && y.isFinite && x >= a.x && x <= c.x) {
      result.add((x: x, y: y, kind: denominator > 0 ? 'min' : 'max'));
    }
  }
  if (points.last.ok && points.last.y == 0) {
    result.add((x: points.last.x, y: 0, kind: 'root'));
  }
  return result;
}

List<List<double>> sampleSurface(
  Map<String, dynamic> request, {
  GraphFallback? fallback,
}) {
  final expression = request['expression'] as String;
  final range = (request['range'] as num).toDouble();
  final grid = request['grid'] as int;
  final compiled = NumericFallbackEvaluator.compile(expression);
  return List.generate(
    grid + 1,
    (i) => List.generate(grid + 1, (j) {
      final vars = {
        'x': -range + 2 * range * i / grid,
        'y': -range + 2 * range * j / grid,
      };
      return (compiled != null
              ? compiled.evaluate(vars)
              : fallback?.call(expression, vars)) ??
          double.nan;
    }),
  );
}

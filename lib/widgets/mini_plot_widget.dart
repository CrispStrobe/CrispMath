// lib/widgets/mini_plot_widget.dart
//
// Notepad V2: compact inline plot for `plot(expr)` notepad lines.
//
// Samples the expression at ~100 points and draws a simple polyline.
// No interactivity — tap opens the full graphing screen.

import 'package:flutter/material.dart';

import '../engine/calculator_engine.dart';

/// Parse a `__plot__:expr|var|lo|hi` sentinel string.
class PlotSpec {
  final String expression;
  final String variable;
  final double lo;
  final double hi;

  PlotSpec({
    required this.expression,
    required this.variable,
    required this.lo,
    required this.hi,
  });

  static PlotSpec? tryParse(String? s) {
    if (s == null || !s.startsWith('__plot__:')) return null;
    final body = s.substring('__plot__:'.length);
    final parts = body.split('|');
    if (parts.length < 4) return null;
    final lo = double.tryParse(parts[2]);
    final hi = double.tryParse(parts[3]);
    if (lo == null || hi == null || lo >= hi) return null;
    return PlotSpec(
      expression: parts[0],
      variable: parts[1],
      lo: lo,
      hi: hi,
    );
  }
}

class MiniPlotWidget extends StatelessWidget {
  final PlotSpec spec;
  final CalculatorEngine engine;

  const MiniPlotWidget({
    super.key,
    required this.spec,
    required this.engine,
  });

  @override
  Widget build(BuildContext context) {
    final samples = _sample();
    return SizedBox(
      height: 80,
      child: CustomPaint(
        painter: _MiniPlotPainter(
          samples: samples,
          lineColor: Theme.of(context).colorScheme.primary,
          axisColor: Theme.of(context).colorScheme.onSurface.withValues(
                alpha: 0.2,
              ),
        ),
        size: Size.infinite,
      ),
    );
  }

  List<Offset> _sample() {
    const n = 100;
    final dx = (spec.hi - spec.lo) / n;
    final points = <Offset>[];
    for (var i = 0; i <= n; i++) {
      final x = spec.lo + i * dx;
      try {
        final substituted = engine.substitute(
          spec.expression,
          spec.variable,
          x.toString(),
        );
        if (substituted.startsWith('Error')) continue;
        final result = engine.evaluate(substituted);
        if (result.startsWith('Error')) continue;
        final y = double.tryParse(result.trim());
        if (y != null && y.isFinite) {
          points.add(Offset(x, y));
        }
      } catch (_) {}
    }
    return points;
  }
}

class _MiniPlotPainter extends CustomPainter {
  final List<Offset> samples;
  final Color lineColor;
  final Color axisColor;

  _MiniPlotPainter({
    required this.samples,
    required this.lineColor,
    required this.axisColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (samples.isEmpty) return;

    // Compute data bounds.
    double xMin = samples.first.dx, xMax = samples.first.dx;
    double yMin = samples.first.dy, yMax = samples.first.dy;
    for (final p in samples) {
      if (p.dx < xMin) xMin = p.dx;
      if (p.dx > xMax) xMax = p.dx;
      if (p.dy < yMin) yMin = p.dy;
      if (p.dy > yMax) yMax = p.dy;
    }
    if (xMax == xMin) xMax = xMin + 1;
    if (yMax == yMin) {
      yMax = yMin + 1;
      yMin = yMin - 1;
    }

    // Add 5% padding.
    final yPad = (yMax - yMin) * 0.05;
    yMin -= yPad;
    yMax += yPad;

    double tx(double x) => (x - xMin) / (xMax - xMin) * size.width;
    double ty(double y) =>
        size.height - (y - yMin) / (yMax - yMin) * size.height;

    // Draw x-axis if in range.
    if (yMin <= 0 && yMax >= 0) {
      final y0 = ty(0);
      canvas.drawLine(
        Offset(0, y0),
        Offset(size.width, y0),
        Paint()
          ..color = axisColor
          ..strokeWidth = 0.5,
      );
    }

    // Draw the curve.
    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    var first = true;
    for (final p in samples) {
      final sx = tx(p.dx);
      final sy = ty(p.dy);
      if (first) {
        path.moveTo(sx, sy);
        first = false;
      } else {
        path.lineTo(sx, sy);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_MiniPlotPainter old) =>
      old.samples != samples || old.lineColor != lineColor;
}

// Compact, live worksheet plots. Sampling uses the same worker as full graphs;
// rebuilding a row never evaluates an expression on the UI thread.

import 'dart:async';

import 'package:flutter/material.dart';

import '../engine/calculator_engine.dart';
import '../engine/graph_sampling.dart';
import '../engine/graph_viewport.dart';
import '../engine/notepad_plot.dart';
import '../engine/plot_types.dart';
import '../localization/app_localizations.dart';
import '../localization/workflow_localizations.dart';
import '../services/graph_sampling_service.dart';

export '../engine/notepad_plot.dart' show PlotSpec;

class MiniPlotWidget extends StatefulWidget {
  final PlotSpec spec;

  // Kept for existing callers. Evaluation belongs to GraphSamplingService,
  // whose worker/isolate has its own engine.
  final CalculatorEngine engine;
  final VoidCallback? onOpenGraph;

  /// Allows deterministic worker completions in widget tests.
  final Future<GraphSamples> Function(Map<String, dynamic>)? sampler;

  const MiniPlotWidget({
    super.key,
    required this.spec,
    required this.engine,
    this.onOpenGraph,
    this.sampler,
  });

  @override
  State<MiniPlotWidget> createState() => _MiniPlotWidgetState();
}

class _MiniPlotWidgetState extends State<MiniPlotWidget> {
  int _generation = 0;
  bool _enabled = false;
  bool _needsSample = true;
  bool _busy = true;
  bool _failed = false;
  List<PlotPt> _points = const [];
  GraphBounds? _bounds;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final enabled = TickerMode.valuesOf(context).enabled;
    if (!enabled) {
      if (_busy && _enabled) {
        // Keep completed geometry, but do not publish a result from a request
        // that was superseded while this worksheet was hidden.
        _generation++;
        _needsSample = true;
      }
      _busy = false;
    }
    _enabled = enabled;
    if (_enabled && _needsSample) unawaited(_sample());
  }

  @override
  void didUpdateWidget(covariant MiniPlotWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final before = oldWidget.spec;
    final after = widget.spec;
    if (before.expression != after.expression ||
        before.variable != after.variable ||
        before.lo != after.lo ||
        before.hi != after.hi ||
        oldWidget.sampler != widget.sampler) {
      _generation++;
      _needsSample = true;
      _busy = false;
      _failed = false;
      _points = const [];
      _bounds = null;
      // A tab change and source update can arrive in the same frame, before
      // didChangeDependencies has refreshed the cached visibility.
      _enabled = TickerMode.valuesOf(context).enabled;
      if (_enabled) unawaited(_sample());
    }
  }

  Future<void> _sample() async {
    if (!_enabled) {
      _needsSample = true;
      return;
    }
    final generation = ++_generation;
    final spec = widget.spec;
    _needsSample = false;
    _busy = true;
    _failed = false;
    _points = const [];
    _bounds = null;
    try {
      if (!spec.isValid) throw const FormatException('Invalid plot interval.');
      final samples = await (widget.sampler ?? GraphSamplingService.graph)({
        'functions': [spec.graphExpression],
        'xMin': spec.lo,
        'xMax': spec.hi,
        'yMin': -10.0,
        'yMax': 10.0,
        'width': 160.0,
        'scale': 1.0,
        'mode': 'cartesian',
        'annotations': false,
      });
      if (!mounted || generation != _generation) return;
      final points = samples.curves.isEmpty
          ? const <PlotPt>[]
          : samples.curves.first;
      final finite = points
          .where((point) => point.ok && point.y.isFinite && point.y.abs() <= 1e12)
          .map((point) => point.y)
          .toList();
      final bounds = finite.isEmpty
          ? null
          : fittedGraphBounds(spec.lo, spec.hi, finite);
      setState(() {
        _points = points;
        _bounds = bounds;
        _busy = false;
      });
    } catch (_) {
      if (!mounted || generation != _generation) return;
      setState(() {
        _busy = false;
        _failed = true;
      });
    }
  }

  void _retry() => setState(() => unawaited(_sample()));

  String _number(double value) =>
      value == value.truncateToDouble() ? value.toStringAsFixed(0) : '$value';

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final range =
        '${_number(widget.spec.lo)} ≤ ${widget.spec.variable} ≤ ${_number(widget.spec.hi)}';
    final openLabel = WorkflowLocalizations.of(context)
        .text(WorkflowLabel.worksheetGraph);
    Widget body;
    if (_busy) {
      body = Semantics(
        liveRegion: true,
        label: t.graphSampling,
        child: Stack(children: [
          const LinearProgressIndicator(minHeight: 2),
          Center(child: Text(t.graphSampling, style: const TextStyle(fontSize: 12))),
        ]),
      );
    } else if (_bounds == null) {
      body = Semantics(
        liveRegion: true,
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(
                  _failed ? t.graphSamplingFailed : t.graphNoRealValues,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
                if (_failed)
                  TextButton(onPressed: _retry, child: Text(t.graphRetry)),
              ]),
            ),
          ),
        ),
      );
    } else {
      body = Semantics(
        image: true,
        label: '${t.navGraphing}: ${widget.spec.expression}; $range',
        child: RepaintBoundary(
          key: const ValueKey('notepad-mini-plot-canvas'),
          child: CustomPaint(
            painter: _MiniPlotPainter(
              samples: _points,
              bounds: _bounds!,
              lineColor: scheme.primary,
              axisColor: scheme.onSurface.withValues(alpha: 0.2),
            ),
            size: Size.infinite,
          ),
        ),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 96,
          child: Material(
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(6),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              // The labelled button below is the keyboard/assistive entry point.
              canRequestFocus: false,
              excludeFromSemantics: true,
              onTap: widget.onOpenGraph,
              child: body,
            ),
          ),
        ),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          children: [
            Text(range, style: const TextStyle(fontSize: 11)),
            if (widget.onOpenGraph != null)
              TextButton.icon(
                key: const ValueKey('notepad-mini-plot-open'),
                onPressed: widget.onOpenGraph,
                icon: const Icon(Icons.open_in_full, size: 14),
                label: Text(openLabel, style: const TextStyle(fontSize: 11)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _MiniPlotPainter extends CustomPainter {
  final List<PlotPt> samples;
  final GraphBounds bounds;
  final Color lineColor;
  final Color axisColor;

  _MiniPlotPainter({
    required this.samples,
    required this.bounds,
    required this.lineColor,
    required this.axisColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double tx(double x) => (x - bounds.xMin) * bounds.unitX(size.width);
    double ty(double y) => (bounds.yMax - y) * bounds.unitY(size.height);
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    final axes = Paint()
      ..color = axisColor
      ..strokeWidth = 0.5;
    if (bounds.yMin <= 0 && bounds.yMax >= 0) {
      canvas.drawLine(Offset(0, ty(0)), Offset(size.width, ty(0)), axes);
    }
    if (bounds.xMin <= 0 && bounds.xMax >= 0) {
      canvas.drawLine(Offset(tx(0), 0), Offset(tx(0), size.height), axes);
    }

    final path = Path();
    var pen = false;
    double? previousY;
    for (final point in samples) {
      final sy = ty(point.y);
      if (!point.ok ||
          !point.x.isFinite ||
          !sy.isFinite ||
          sy < -size.height * 2 ||
          sy > size.height * 3) {
        pen = false;
        previousY = null;
        continue;
      }
      // A large jump near a pole must not become a vertical stroke. Undefined
      // samples remain in the sequence and always lift the pen, just as in the
      // full graph painter.
      if (previousY != null && (sy - previousY).abs() > size.height * 2) {
        pen = false;
      }
      final sx = tx(point.x);
      if (pen) {
        path.lineTo(sx, sy);
      } else {
        path.moveTo(sx, sy);
      }
      pen = true;
      previousY = sy;
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MiniPlotPainter old) =>
      old.samples != samples ||
      old.bounds != bounds ||
      old.lineColor != lineColor ||
      old.axisColor != axisColor;
}

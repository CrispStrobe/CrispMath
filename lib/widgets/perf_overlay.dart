// lib/widgets/perf_overlay.dart
//
// Developer performance overlay — UI/raster timings and vsync budgets.
//
// Toggle via Settings or the debug shortcut Ctrl+Shift+P.
// Shows a compact bar at the top with:
//   - UI and raster p95 work times over the last 60 frames
//   - Jank count against the display refresh-rate budget
//   - Worst frame time
//
// Lightweight: uses SchedulerBinding.addTimingsCallback which is
// zero-cost when no callback is registered. The overlay itself is
// a single Text widget — no custom painting or expensive layout.

import 'dart:collection';
import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Frame-timing collector. Singleton — register once, read anywhere.
class PerfStats {
  PerfStats._();
  static final PerfStats instance = PerfStats._();

  static const int _windowSize = 60;
  double _refreshRate = 60;
  double get refreshRate => _refreshRate;
  Duration get frameBudget =>
      Duration(microseconds: (1e6 / _refreshRate).round());
  void setRefreshRate(double hz) {
    if (hz.isFinite && hz > 0) _refreshRate = hz;
  }

  final Queue<Duration> _frameTimes = Queue();
  final Queue<Duration> _buildTimes = Queue();
  final Queue<Duration> _rasterTimes = Queue();
  int _jankCount = 0;
  Duration _worstFrame = Duration.zero;
  bool _listening = false;

  int get jankCount => _jankCount;
  Duration get worstFrame => _worstFrame;
  int get frameCount => _frameTimes.length;

  /// Estimated processing capacity, retained for compatibility. This is not
  /// presentation FPS: idle intervals and missed vsyncs are not represented.
  double get fps {
    if (_frameTimes.isEmpty) return 0;
    final total = _frameTimes.fold<int>(0, (sum, d) => sum + d.inMicroseconds);
    if (total == 0) return 0;
    return _frameTimes.length * 1e6 / total;
  }

  double get avgFrameMs {
    if (_frameTimes.isEmpty) return 0;
    final total = _frameTimes.fold<int>(0, (sum, d) => sum + d.inMicroseconds);
    return total / _frameTimes.length / 1000;
  }

  double get buildP95Ms => _percentile(_buildTimes);
  double get rasterP95Ms => _percentile(_rasterTimes);

  double _percentile(Queue<Duration> values) {
    if (values.isEmpty) return 0;
    final sorted = values.map((d) => d.inMicroseconds).toList()..sort();
    return sorted[(sorted.length * 0.95).ceil() - 1] / 1000;
  }

  void start() {
    if (_listening) return;
    _listening = true;
    SchedulerBinding.instance.addTimingsCallback(_onTimings);
  }

  void stop() {
    if (!_listening) return;
    _listening = false;
    SchedulerBinding.instance.removeTimingsCallback(_onTimings);
  }

  void reset() {
    _frameTimes.clear();
    _buildTimes.clear();
    _rasterTimes.clear();
    _jankCount = 0;
    _worstFrame = Duration.zero;
  }

  void _onTimings(List<FrameTiming> timings) {
    for (final t in timings) {
      recordFrame(t.buildDuration, t.rasterDuration);
    }
  }

  /// UI and raster have separate vsync budgets; totalSpan includes pipeline
  /// latency and must not be used as a proxy for either phase's workload.
  void recordFrame(Duration build, Duration raster) {
    final work = build > raster ? build : raster;
    _frameTimes.addLast(work);
    _buildTimes.addLast(build);
    _rasterTimes.addLast(raster);
    while (_frameTimes.length > _windowSize) {
      _frameTimes.removeFirst();
      _buildTimes.removeFirst();
      _rasterTimes.removeFirst();
    }
    if (build > frameBudget || raster > frameBudget) _jankCount++;
    if (work > _worstFrame) _worstFrame = work;
  }
}

/// Compact performance overlay widget. Rebuilds every ~500ms via a
/// periodic timer to avoid scheduling unnecessary animation frames.
class PerfOverlay extends StatefulWidget {
  const PerfOverlay({super.key});

  @override
  State<PerfOverlay> createState() => _PerfOverlayState();
}

class _PerfOverlayState extends State<PerfOverlay> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    PerfStats.instance.start();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    PerfStats.instance.setRefreshRate(View.of(context).display.refreshRate);
  }

  @override
  void dispose() {
    _timer?.cancel();
    PerfStats.instance.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stats = PerfStats.instance;
    final ui = stats.buildP95Ms.toStringAsFixed(1);
    final raster = stats.rasterP95Ms.toStringAsFixed(1);
    final hz = stats.refreshRate.toStringAsFixed(0);
    final worst = (stats.worstFrame.inMicroseconds / 1000).toStringAsFixed(1);
    final janks = stats.jankCount;
    final cs = Theme.of(context).colorScheme;
    final jankColor = janks > 10
        ? cs.error
        : janks > 0
            ? Colors.orange
            : cs.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: cs.surfaceContainerHighest.withValues(alpha: 0.9),
      child: Text(
        'UI p95 ${ui}ms  |  raster p95 ${raster}ms  |  ${hz}Hz  |  worst ${worst}ms  |  janks: $janks',
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 11,
          color: jankColor,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

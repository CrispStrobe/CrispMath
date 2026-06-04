// lib/widgets/perf_overlay.dart
//
// Developer performance overlay — frame timing + jank detection.
//
// Toggle via Settings or the debug shortcut Ctrl+Shift+P.
// Shows a compact bar at the top with:
//   - Current FPS (rolling average over 60 frames)
//   - Jank count (frames > 16.67ms since last reset)
//   - Worst frame time
//
// Lightweight: uses SchedulerBinding.addTimingsCallback which is
// zero-cost when no callback is registered. The overlay itself is
// a single Text widget — no custom painting or expensive layout.

import 'dart:collection';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Frame-timing collector. Singleton — register once, read anywhere.
class PerfStats {
  PerfStats._();
  static final PerfStats instance = PerfStats._();

  static const int _windowSize = 60;
  static const Duration _jankThreshold = Duration(microseconds: 16667);

  final Queue<Duration> _frameTimes = Queue();
  int _jankCount = 0;
  Duration _worstFrame = Duration.zero;
  bool _listening = false;

  int get jankCount => _jankCount;
  Duration get worstFrame => _worstFrame;
  int get frameCount => _frameTimes.length;

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
    _jankCount = 0;
    _worstFrame = Duration.zero;
  }

  void _onTimings(List<FrameTiming> timings) {
    for (final t in timings) {
      final total = t.totalSpan;
      _frameTimes.addLast(total);
      while (_frameTimes.length > _windowSize) {
        _frameTimes.removeFirst();
      }
      if (total > _jankThreshold) _jankCount++;
      if (total > _worstFrame) _worstFrame = total;
    }
  }
}

/// Compact performance overlay widget. Rebuilds every ~500ms via a
/// periodic ticker to avoid per-frame rebuilds.
class PerfOverlay extends StatefulWidget {
  const PerfOverlay({super.key});

  @override
  State<PerfOverlay> createState() => _PerfOverlayState();
}

class _PerfOverlayState extends State<PerfOverlay> {
  late final Ticker _ticker;
  int _tickCount = 0;

  @override
  void initState() {
    super.initState();
    PerfStats.instance.start();
    _ticker = Ticker((_) {
      _tickCount++;
      // Rebuild every ~30 ticks (~500ms at 60fps).
      if (_tickCount % 30 == 0 && mounted) {
        setState(() {});
      }
    })
      ..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stats = PerfStats.instance;
    final fps = stats.fps.toStringAsFixed(0);
    final avg = stats.avgFrameMs.toStringAsFixed(1);
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
        '$fps fps  |  avg ${avg}ms  |  worst ${worst}ms  |  janks: $janks',
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

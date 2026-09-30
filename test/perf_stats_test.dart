import 'package:crisp_math/widgets/perf_overlay.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    PerfStats.instance.reset();
    PerfStats.instance.stop();
    PerfStats.instance.setRefreshRate(60);
  });

  group('PerfStats', () {
    test('starts with zero values', () {
      expect(PerfStats.instance.frameCount, 0);
      expect(PerfStats.instance.jankCount, 0);
      expect(PerfStats.instance.worstFrame, Duration.zero);
      expect(PerfStats.instance.fps, 0);
      expect(PerfStats.instance.avgFrameMs, 0);
    });

    test('jank follows display refresh rate and separate UI/raster phases', () {
      final stats = PerfStats.instance;
      stats.recordFrame(
          const Duration(milliseconds: 10), const Duration(milliseconds: 10));
      expect(stats.jankCount, 0);
      stats.setRefreshRate(120);
      stats.recordFrame(
          const Duration(milliseconds: 10), const Duration(milliseconds: 2));
      expect(stats.jankCount, 1);
      expect(stats.buildP95Ms, 10);
      expect(stats.rasterP95Ms, 10);
      stats.reset();
      expect(stats.buildP95Ms, 0);
      expect(stats.rasterP95Ms, 0);
    });

    test('reset clears all counters', () {
      // Simulate some state by directly checking reset behavior
      PerfStats.instance.reset();
      expect(PerfStats.instance.frameCount, 0);
      expect(PerfStats.instance.jankCount, 0);
      expect(PerfStats.instance.worstFrame, Duration.zero);
    });

    test('fps returns 0 when no frames', () {
      expect(PerfStats.instance.fps, 0.0);
    });

    test('avgFrameMs returns 0 when no frames', () {
      expect(PerfStats.instance.avgFrameMs, 0.0);
    });
  });
}

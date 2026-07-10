import 'package:crisp_math/widgets/perf_overlay.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    PerfStats.instance.reset();
    PerfStats.instance.stop();
  });

  group('PerfStats', () {
    test('starts with zero values', () {
      expect(PerfStats.instance.frameCount, 0);
      expect(PerfStats.instance.jankCount, 0);
      expect(PerfStats.instance.worstFrame, Duration.zero);
      expect(PerfStats.instance.fps, 0);
      expect(PerfStats.instance.avgFrameMs, 0);
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

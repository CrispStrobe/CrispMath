import 'dart:math' as math;

class GraphBounds {
  final double xMin, xMax, yMin, yMax;
  GraphBounds(this.xMin, this.xMax, this.yMin, this.yMax) {
    final values = [xMin, xMax, yMin, yMax];
    if (values.any((v) => !v.isFinite || v.abs() > 1e12) ||
        xMax - xMin < 1e-9 ||
        yMax - yMin < 1e-9) {
      throw ArgumentError(
          'Use finite, increasing bounds between -1e12 and 1e12, with a range of at least 1e-9.');
    }
  }
  double unitX(double width) => width / (xMax - xMin);
  double unitY(double height) => height / (yMax - yMin);
}

GraphBounds fittedGraphBounds(
    double xMin, double xMax, Iterable<double?> values) {
  final finite = values
      .whereType<double>()
      .where((v) => v.isFinite && v.abs() <= 1e12)
      .toList()
    ..sort();
  if (finite.isEmpty) {
    throw StateError('No finite values in this x interval.');
  }
  final trim = finite.length >= 50 ? (finite.length * .02).floor() : 0;
  final lo = finite[trim], hi = finite[finite.length - 1 - trim];
  final padding = math.max((hi - lo) * .1, math.max(1, hi.abs()) * .01);
  return GraphBounds(
      xMin, xMax, math.max(-1e12, lo - padding), math.min(1e12, hi + padding));
}

double graphGridStep(double pixelsPerUnit) {
  final ideal = 80 / pixelsPerUnit;
  final power = math.pow(10, (math.log(ideal) / math.ln10).floor()).toDouble();
  final normalized = ideal / power;
  return (normalized <= 1
          ? 1
          : normalized <= 2
              ? 2
              : normalized <= 5
                  ? 5
                  : 10) *
      power;
}

class GraphUndoHistory<T> {
  final int capacity;
  final List<T> _entries = [];
  GraphUndoHistory({this.capacity = 20});
  bool get canUndo => _entries.isNotEmpty;
  void record(T value) {
    _entries.add(value);
    if (_entries.length > capacity) {
      _entries.removeAt(0);
    }
  }

  T? undo() => _entries.isEmpty ? null : _entries.removeLast();
}

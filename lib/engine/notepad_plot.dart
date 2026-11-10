/// A resolved worksheet plot. The expression and interval already include the
/// document's current bindings; [variable] remains the independent coordinate.
///
/// The text encoding stays compatible with saved worksheet result caches. It is
/// transport data, not an ordinary answer or a document-scope value.
class PlotSpec {
  final String expression;
  final String variable;
  final double lo;
  final double hi;

  const PlotSpec({
    required this.expression,
    required this.variable,
    required this.lo,
    required this.hi,
  });

  static const prefix = '__plot__:';
  static final _identifier = RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$');
  static final _tokens = RegExp(
      r'(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?|[A-Za-z_][A-Za-z0-9_]*');

  bool get isValid =>
      expression.trim().isNotEmpty &&
      !expression.contains('|') &&
      _identifier.hasMatch(variable) &&
      lo.isFinite &&
      hi.isFinite &&
      lo.abs() <= 1e12 &&
      hi.abs() <= 1e12 &&
      hi - lo >= 1e-9;

  /// Match the graph sampler's x-coordinate without replacing the exponent in
  /// a scientific number or a substring inside another identifier.
  String get graphExpression => expression.replaceAllMapped(
      _tokens, (match) => match[0] == variable ? 'x' : match[0]!);

  String toSentinel() => '$prefix$expression|$variable|$lo|$hi';

  static PlotSpec? tryParse(String? value) {
    if (value == null || !value.startsWith(prefix)) return null;
    final parts = value.substring(prefix.length).split('|');
    if (parts.length != 4) return null;
    final lo = double.tryParse(parts[2]);
    final hi = double.tryParse(parts[3]);
    if (lo == null || hi == null) return null;
    final spec = PlotSpec(
        expression: parts[0], variable: parts[1], lo: lo, hi: hi);
    return spec.isValid ? spec : null;
  }
}

/// Resolved values retain their source scope for the linked graph inspector.
class NotepadPlotResolution {
  final PlotSpec spec;
  final Map<String, String> scope;
  const NotepadPlotResolution(this.spec, this.scope);
}

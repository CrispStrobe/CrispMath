/// Tag + args for a generic worker dispatch. Held minimal (5 strings)
/// so it transports cleanly across the isolate boundary.
class EngineOp {
  final String kind;
  final String arg1;
  final String? arg2;
  final String? arg3;
  final String? arg4;
  const EngineOp(this.kind, this.arg1, [this.arg2, this.arg3, this.arg4]);

  EngineOp withArg1(String newArg1) =>
      EngineOp(kind, newArg1, arg2, arg3, arg4);
}

/// Raised when the native or browser worker is cancelled with work pending.
class EngineCancelled implements Exception {
  const EngineCancelled();
  @override
  String toString() => 'EngineCancelled';
}

import 'package:flutter/foundation.dart';

import '../engine/calculator_engine.dart';

/// Flutter's observable view of the engine status.
///
/// The engine uses a plain Dart signal in workers and a Flutter ValueNotifier
/// when dart:ui is available. Keep that conditional type behind the UI boundary
/// so the analyzer and widgets share an explicit Flutter listenable contract.
ValueListenable<NativeBridgeStatus> get nativeBridgeStatusListenable =>
    nativeBridgeStatus as ValueListenable<NativeBridgeStatus>;

// lib/engine/model_license_consent.dart
//
// Persisted per-license user consent for restrictive model weights.
// Platform-independent (shared_preferences works on native and web).

import 'package:shared_preferences/shared_preferences.dart';

import 'model_license_terms.dart';

class ModelLicenseConsent {
  static const String _keyPrefix = 'model_license_consent.v1.';

  static final Set<String> _granted = {};
  static bool _loaded = false;

  /// Hook for the native runtime gate (set by ocr_providers_init.dart on
  /// native platforms). Called with (envVar, accepted).
  static void Function(String envVar, bool accepted)? runtimeGateSetter;

  /// Loads persisted consents. Safe to call repeatedly.
  static Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    _granted
      ..clear()
      ..addAll(_tagsFrom(prefs));
    _loaded = true;
  }

  static Iterable<String> _tagsFrom(SharedPreferences prefs) => prefs
      .getKeys()
      .where((k) => k.startsWith(_keyPrefix))
      .map((k) => k.substring(_keyPrefix.length));

  /// Whether the user has consented to [terms]. Unrestricted (null) terms
  /// are always allowed. Requires [load] to have completed; before that,
  /// restricted terms are reported as not granted (fail closed).
  static bool allows(ModelLicenseTerms? terms) =>
      terms == null || _granted.contains(terms.tag);

  /// Records consent with a timestamp and enables the runtime gate.
  static Future<void> grant(ModelLicenseTerms terms) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_keyPrefix${terms.tag}',
      DateTime.now().toUtc().toIso8601String(),
    );
    _granted.add(terms.tag);
    applyRuntimeGate(terms);
  }

  /// Withdraws consent and disables the runtime gate.
  static Future<void> revoke(ModelLicenseTerms terms) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_keyPrefix${terms.tag}');
    _granted.remove(terms.tag);
    final gate = terms.runtimeEnvGate;
    if (gate != null) runtimeGateSetter?.call(gate, false);
  }

  /// Sets the CrispEmbed env gate for [terms] when consent is recorded.
  static void applyRuntimeGate(ModelLicenseTerms terms) {
    final gate = terms.runtimeEnvGate;
    if (gate != null && allows(terms)) runtimeGateSetter?.call(gate, true);
  }

  /// Test-only: forget the in-memory cache so [load] re-reads prefs.
  static void resetForTest() {
    _granted.clear();
    _loaded = false;
    runtimeGateSetter = null;
  }
}

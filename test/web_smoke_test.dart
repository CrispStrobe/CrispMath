// test/web_smoke_test.dart
//
// Opt-in browser smoke test. Normal `flutter test` and CI run on the Dart
// VM and can't load the SymEngine WASM module, so this test is SKIPPED
// unless CRISPCALC_WEB_SMOKE is set. When enabled it shells out to
// `tool/web_smoke.mjs`, which drives a headless Chromium against the
// deployed web build and asserts the in-browser CAS computes.
//
// Run it:
//   CRISPCALC_WEB_SMOKE=1 flutter test test/web_smoke_test.dart
//   CRISPCALC_WEB_SMOKE=1 CRISPCALC_WEB_SMOKE_URL=http://localhost:8099/ \
//     flutter test test/web_smoke_test.dart
//
// Requires: Node >= 21 on PATH and a Chromium-family browser (Chrome /
// Chromium / Edge / Brave; override with CHROME_PATH).

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final enabled = Platform.environment['CRISPCALC_WEB_SMOKE'] == '1' ||
      Platform.environment['CRISPCALC_WEB_SMOKE']?.toLowerCase() == 'true';
  final url = Platform.environment['CRISPCALC_WEB_SMOKE_URL'] ??
      'https://crisp-calc.vercel.app/';

  test(
    'deployed web build: SymEngine WASM CAS computes in a real browser',
    () async {
      // tool/web_smoke.mjs lives at the repo root; tests run from there.
      final harness = File('tool/web_smoke.mjs');
      expect(harness.existsSync(), isTrue,
          reason: 'tool/web_smoke.mjs missing (run from repo root)');

      final result = await Process.run(
        'node',
        ['tool/web_smoke.mjs', url],
        environment: {
          ...Platform.environment,
          'WEB_SMOKE_TIMEOUT_MS': '40000',
        },
      );

      final out = '${result.stdout}\n${result.stderr}';
      // Exit code 3 = no browser available on this machine — treat as skip-
      // worthy rather than a hard failure so the gate is portable.
      if (result.exitCode == 3) {
        markTestSkipped('no Chromium-family browser found on this machine');
        return;
      }

      // Parse the structured summary the harness emits.
      final line = const LineSplitter()
          .convert(out)
          .firstWhere((l) => l.startsWith('WEB_SMOKE_JSON='),
              orElse: () => '');
      expect(line, isNotEmpty,
          reason: 'harness produced no WEB_SMOKE_JSON summary:\n$out');

      final summary =
          jsonDecode(line.substring('WEB_SMOKE_JSON='.length))
              as Map<String, dynamic>;

      expect(summary['ready'], isTrue,
          reason: 'WASM module never became ready:\n$out');
      expect(summary['rendered'], isTrue,
          reason: 'Flutter view did not render:\n$out');

      final results = (summary['results'] as List).cast<Map<String, dynamic>>();
      final byName = {for (final r in results) r['name'] as String: r};

      // Spot-check the headline CAS operations resolved correctly.
      for (final name in const ['version', 'expand', 'differentiate', 'solve']) {
        expect(byName[name]?['pass'], isTrue,
            reason: 'WASM case "$name" failed: ${byName[name]}\n$out');
      }

      expect(summary['allPass'], isTrue,
          reason: 'one or more in-browser CAS checks failed:\n$out');
      expect(result.exitCode, 0, reason: out);
    },
    skip: enabled
        ? false
        : 'browser smoke is opt-in — set CRISPCALC_WEB_SMOKE=1 to run',
    timeout: const Timeout(Duration(minutes: 2)),
  );
}

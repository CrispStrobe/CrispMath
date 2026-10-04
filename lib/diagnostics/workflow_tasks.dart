import 'workflow_modules.dart';
import '../engine/unit_expression.dart';
import '../engine/calculator_engine.dart';
import '../engine/result_evidence.dart';
import '../engine/graph_sampling.dart';
import '../engine/notepad.dart';
import '../engine/notepad_evaluator.dart';
import '../engine/notepad_export.dart';
import '../engine/numeric_fallback.dart';
import '../engine/rational_domain.dart';
import '../services/engine_dispatch.dart';
import '../services/engine_op.dart';
import '../services/integral_arguments.dart';

/// Runs app code with explicit expectations, without touching saved documents.
class WorkflowTasks {
  WorkflowTasks(this.engine, {this.documentDispatcher, this.onTaskStart});
  final CalculatorEngine engine;
  final void Function(String id)? onTaskStart;
  final Future<String> Function(String)? documentDispatcher;

  Future<Map<String, dynamic>> run(List<dynamic> tasks) async {
    final ids = <String>{};
    for (final raw in tasks) {
      if (raw is! Map || raw['id'] is! String || !ids.add(raw['id'])) {
        throw const FormatException('Tasks need unique string IDs');
      }
      if (!['engine', 'document', 'graph', 'export', 'module']
          .contains(raw['kind'])) {
        throw FormatException('Unknown task kind: ${raw['kind']}');
      }
    }
    final results = <Map<String, dynamic>>[];
    for (final raw in tasks) {
      final task = Map<String, dynamic>.from(raw as Map);
      onTaskStart?.call(task['id'] as String);
      final timer = Stopwatch()..start();
      try {
        final actual = await _execute(task);
        results.add({
          'id': task['id'],
          'kind': task['kind'],
          'title': task['title'],
          ...actual,
          'milliseconds': timer.elapsedMicroseconds / 1000
        });
      } catch (e) {
        results.add({
          'id': task['id'],
          'kind': task['kind'],
          'status': 'failed',
          'error': e.toString(),
          'milliseconds': timer.elapsedMicroseconds / 1000
        });
      }
    }
    return _diagnosticValue(<String, dynamic>{
      'schemaVersion': 2,
      'nativeBridge': nativeBridgeReady,
      'total': results.length,
      'expectedRejections': results
          .where((r) =>
              r['status'] == 'passed' && r['expectedErrorContains'] != null)
          .length,
      'featureGaps':
          results.where((r) => r['unsupportedReason'] != null).length,
      for (final status in ['passed', 'failed', 'unsupported'])
        status: results.where((r) => r['status'] == status).length,
      'results': results
    }) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> _execute(Map<String, dynamic> task) async {
    switch (task['kind']) {
      case 'module':
        final actual = await runWorkflowModule(engine, task);
        final pass = task['errorContains'] != null
            ? actual is String && actual.startsWith('Error') &&
                actual.contains(task['errorContains'])
            : _structuredMatches(actual, task['expected'],
                unordered: task['unordered'] == true);
        return {
          'status': pass ? 'passed' : 'failed',
          'actual': actual,
          'expected': task['expected'] ?? task['errorContains'],
          if (task['errorContains'] != null)
            'expectedErrorContains': task['errorContains']
        };
      case 'engine':
        final args = task['call'] != null && task['operation'] == 'integrate'
            ? parseIntegralArguments(task['call'] as String) ??
                (throw const FormatException('Invalid integral call'))
            : (task['args'] as List).cast<String>();
        final result = runEngineOpDetailed(
            engine,
            EngineOp(
                task['operation'],
                args[0],
                args.length > 1 ? args[1] : null,
                args.length > 2 ? args[2] : null,
                args.length > 3 ? args[3] : null));
        final unsupported = RegExp(
                r'requires (?:a newer )?native|not available|not implemented',
                caseSensitive: false)
            .hasMatch(result.value);
        var pass = task['errorContains'] != null
            ? result.value.startsWith('Error') &&
                result.value.contains(task['errorContains'])
            : task['exact'] == true
                ? result.value == task['expected']
                : _matches(result.value, task['expected']);
        if (task['resultPattern'] != null) {
          pass = pass &&
              RegExp(task['resultPattern'] as String).hasMatch(result.value);
        }
        return {
          'status': unsupported
              ? 'unsupported'
              : pass
                  ? 'passed'
                  : 'failed',
          'actual': result.value,
          'expected': task['expected'] ?? task['errorContains'],
          if (task['errorContains'] != null)
            'expectedErrorContains': task['errorContains'],
          if (result.evidence != null) 'evidence': result.evidence!.toJson()
        };
      case 'document':
      case 'export':
        final doc =
            NotepadDocument.fresh(name: task['name'] ?? 'CLI worksheet');
        doc.lines.clear();
        doc.lines.addAll((task['lines'] as List)
            .cast<String>()
            .map((s) => NotepadLine.fresh(source: s)));
        final evaluator = NotepadEvaluator(
            dispatcher: documentDispatcher ?? (s) async => engine.evaluate(s),
            detailedDispatcher: documentDispatcher == null
                ? (source) async {
                    var unit = UnitExpressionEvaluator.tryEvaluate(source);
                    if (unit == null && source.contains('(')) {
                      // Worksheet substitutions wrap scalar quantities; mirror
                      // the application's unit route without importing Flutter.
                      unit = UnitExpressionEvaluator.tryEvaluate(
                          source.replaceAll('(', '').replaceAll(')', ''));
                    }
                    if (unit != null) {
                      return ComputedResult(unit, const ResultEvidence(
                          ResultAccuracy.unknown, ComputationMethod.unitConversion));
                    }
                    final integral = parseIntegralArguments(source.trim());
                    final limit = parseLimitArguments(source.trim());
                    final solve = parseSolveArguments(source.trim());
                    final derivative = parseDifferentiationArguments(source.trim());
                    final series = parseSeriesArguments(source.trim());
                    final EngineOp operation;
                    if (integral != null) {
                      operation = EngineOp('integrate', integral[0], integral[1],
                          integral.length == 4 ? integral[2] : null,
                          integral.length == 4 ? integral[3] : null);
                    } else if (limit != null) {
                      operation = EngineOp('limit', limit[0], limit[1], limit[2]);
                    } else if (solve != null) {
                      operation = EngineOp('solve', solve[0], solve[1]);
                    } else if (derivative != null) {
                      operation = EngineOp('differentiate', derivative[0], derivative[1]);
                    } else if (series != null) {
                      final order = parseSeriesOrder(series[3]);
                      if (order == null) {
                        return const ComputedResult(
                            'Error: series order must be an integer in 1..64', null);
                      }
                      operation = EngineOp('series', series[0], series[1],
                          series[2], '$order');
                    } else if ((source.trim().startsWith('series(') ||
                            source.trim().startsWith('taylor(')) &&
                        source.trim().endsWith(')')) {
                      return const ComputedResult('Error: invalid series arguments', null);
                    } else {
                      operation = EngineOp('evaluate', source);
                    }
                    final computed = runEngineOpDetailed(engine, operation);
                    final raw = computed.value;
                    // The UI removes a purely zero imaginary suffix before
                    // caching scalar values. Keep this CLI path pure Dart.
                    final scalar = task['normalizeRealScalars'] == true
                        ? RegExp(r'^\s*([+-]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?)\s*[+-]\s*0(?:\.0*)?\s*\*?\s*I\s*$')
                            .firstMatch(raw)
                        : null;
                    return ComputedResult(scalar?[1] ?? raw, computed.evidence);
                  }
                : null);
        await evaluator.evaluateAll(doc);
        if (task['edit'] != null) {
          final edit = task['edit'] as Map;
          doc.lines[edit['index'] as int].source = edit['source'] as String;
          await evaluator.evaluateFrom(doc, edit['index'] as int);
        }
        if (task['kind'] == 'document') {
          final expected = (task['expected'] as List).cast<String?>();
          final actual =
              doc.lines.map((l) => l.cachedError ?? l.cachedResult).toList();
          final expectedErrors = task['expectedErrorContains'] as List?;
          final expectedAccuracy = task['expectedAccuracy'] as List?;
          final expectedPatterns = task['expectedResultPatterns'] as List?;
          final expectedFreeVars = task['expectedFreeVars'] as List?;
          final freeVars = doc.lines.map((line) {
            final names = line.cachedFreeVars.toList()..sort();
            return names;
          }).toList();
          final pass = (expectedFreeVars == null ||
                  _structuredMatches(freeVars, expectedFreeVars)) &&
              expected.length == actual.length &&
              List.generate(
                      expected.length,
                      (i) => expectedErrors != null && expectedErrors[i] != null
                          ? doc.lines[i].cachedError != null &&
                              doc.lines[i].cachedError!
                                  .contains(expectedErrors[i] as String)
                          : expected[i] == null
                              ? actual[i] == null
                              : _matches(actual[i] ?? '', expected[i]))
                  .every((v) => v) &&
              (expectedAccuracy == null ||
                  (expectedAccuracy.length == doc.lines.length &&
                      List.generate(doc.lines.length, (i) {
                        final allowed = expectedAccuracy[i];
                        final accuracy = doc.lines[i].resultEvidence?.accuracy.name;
                        return allowed is List
                            ? allowed.contains(accuracy)
                            : allowed == accuracy;
                      }).every((v) => v))) &&
              (expectedPatterns == null ||
                  (expectedPatterns.length == doc.lines.length &&
                      List.generate(doc.lines.length, (i) =>
                          expectedPatterns[i] == null ||
                          RegExp(expectedPatterns[i] as String)
                              .hasMatch(doc.lines[i].cachedResult ?? ''))
                          .every((v) => v)));
          return {
            'status': pass ? 'passed' : 'failed',
            'actual': actual,
            'expected': expected,
            'evidence': doc.lines.map((line) => line.resultEvidence?.toJson()).toList(),
            if (expectedFreeVars != null) ...{
              'freeVars': freeVars,
              'expectedFreeVars': expectedFreeVars,
            },
            if (expectedAccuracy != null) 'expectedAccuracy': expectedAccuracy,
            if (expectedPatterns != null) 'expectedResultPatterns': expectedPatterns,
            if (expectedErrors != null) 'expectedErrorContains': expectedErrors,
            if (task['unsupportedReason'] != null)
              'unsupportedReason': task['unsupportedReason'],
            if (task['originalRequestedResults'] != null)
              'originalRequestedResults': task['originalRequestedResults']
          };
        }
        final expectedResults = task['expectedResults'] as List?;
        if (doc.lines.any((line) => line.cachedError != null) ||
            (expectedResults != null &&
                (expectedResults.length != doc.lines.length ||
                    !List.generate(
                        doc.lines.length,
                        (i) => _matches(doc.lines[i].cachedResult ?? '',
                            expectedResults[i])).every((v) => v)))) {
          return {
            'status': 'failed',
            'actual':
                doc.lines.map((l) => l.cachedError ?? l.cachedResult).toList(),
            'expected': expectedResults,
            'error': 'Export source calculations did not match expectations'
          };
        }
        final format = task['format'];
        if (!['markdown', 'latex', 'json', 'pdf'].contains(format)) {
          throw FormatException('Unknown export format: $format');
        }
        if (format == 'pdf') {
          final bytes = await (await exportToPdf(doc)).save();
          final pass = String.fromCharCodes(bytes.take(5)) == '%PDF-' &&
              bytes.length > 500;
          return {
            'status': pass ? 'passed' : 'failed',
            'actual': {'bytes': bytes.length}
          };
        }
        if (format == 'json') {
          final restored = NotepadDocument.fromJson(doc.toJson());
          final pass =
              restored.lines.last.cachedResult == doc.lines.last.cachedResult &&
                  restored.lines.last.source == doc.lines.last.source;
          return {
            'status': pass ? 'passed' : 'failed',
            'actual': restored.lines.last.cachedResult
          };
        }
        final value =
            format == 'latex' ? exportToLatex(doc) : exportToMarkdown(doc);
        final pass =
            (task['contains'] as List).cast<String>().every(value.contains);
        return {
          'status': pass ? 'passed' : 'failed',
          'actual': value,
          'expected': task['contains']
        };
      case 'graph':
        final samples = sampleGraph({
          'mode': 'cartesian',
          'functions': [task['expression']],
          'width': 100,
          'scale': 1,
          'xMin': -2,
          'xMax': 2,
          'yMin': -10,
          'yMax': 10,
          'annotations': false,
          'coarse': false
        });
        final points = samples.curves.single;
        var pass = true;
        for (final check in (task['checks'] as List)) {
          final p = points.reduce((a, b) =>
              (a.x - check['x']).abs() < (b.x - check['x']).abs() ? a : b);
          pass = pass &&
              (check['y'] == null
                  ? !p.ok
                  : p.ok && _numericClose(p.y, check['y'], relativeTolerance: 1e-8));
        }
        return {
          'status': pass ? 'passed' : 'failed',
          'actual': samples.toJson(),
          'expected': task['checks']
        };
    }
    throw StateError('Unhandled task');
  }

  // Compare original values first. Explicit diagnostic strings preserve a
  // failed NaN/infinite result without aborting JSON serialization of the rest
  // of the independently drafted corpus.
  dynamic _diagnosticValue(dynamic value) {
    if (value is num && !value.isFinite) {
      if (value.isNaN) return 'NaN';
      return value.isNegative ? '-Infinity' : 'Infinity';
    }
    if (value is List) return value.map(_diagnosticValue).toList();
    if (value is Map) {
      return value.map(
          (key, item) => MapEntry(key.toString(), _diagnosticValue(item)));
    }
    return value;
  }

  // Nonzero references require relative agreement even far below one. Scale
  // before subtraction to avoid underflowing a tolerance or overflowing a
  // difference. Only an explicitly zero reference permits absolute noise.
  bool _numericClose(num actual, num expected,
      {required double relativeTolerance}) {
    if (!actual.isFinite || !expected.isFinite) return false;
    if (actual == expected) return true;
    if (expected == 0) return actual.abs() <= relativeTolerance;
    final scale = actual.abs() > expected.abs() ? actual.abs() : expected.abs();
    return (actual / scale - expected / scale).abs() <=
        relativeTolerance * (expected.abs() / scale);
  }

  bool _structuredMatches(dynamic actual, dynamic expected,
      {bool unordered = false}) {
    if (actual == null || expected == null) return actual == expected;
    if (actual is num && expected is num) {
      return _numericClose(actual, expected, relativeTolerance: 1e-7);
    }
    if (actual is String && expected is String) {
      if (actual.startsWith('Matrix(') && expected.startsWith('Matrix(')) {
        final a = actual.replaceAll(RegExp(r'\s+'), '');
        final b = expected.replaceAll(RegExp(r'\s+'), '');
        return a == b;
      }
      return _matches(actual, expected);
    }
    if (actual is Map && expected is Map) {
      return actual.length == expected.length &&
          expected.keys.every((key) =>
              actual.containsKey(key) &&
              _structuredMatches(actual[key], expected[key]));
    }
    if (actual is List && expected is List) {
      if (actual.length != expected.length) return false;
      if (!unordered) {
        return List.generate(actual.length,
            (i) => _structuredMatches(actual[i], expected[i])).every((v) => v);
      }
      final remaining = List.of(actual);
      for (final value in expected) {
        final index =
            remaining.indexWhere((item) => _structuredMatches(item, value));
        if (index < 0) return false;
        remaining.removeAt(index);
      }
      return remaining.isEmpty;
    }
    return actual == expected;
  }

  bool _matches(String actual, dynamic expected) {
    if (expected is! String) {
      throw const FormatException('Expected result must be a string');
    }
    // Error text and undefined values must never pass by exact-string equality
    // or by an assignment embedded inside an error message.
    final invalid = RegExp(r'\b(?:Error|NaN|Infinity|Inf|zoo|undefined|null)\b',
        caseSensitive: false);
    if (invalid.hasMatch(actual) || invalid.hasMatch(expected)) return false;
    if (actual == expected) {
      // Identical arithmetic strings such as 0/0 still represent no answer.
      if (RegExp(r'^[0-9eE.+*/()^\s-]+$').hasMatch(actual)) {
        final value = NumericFallbackEvaluator.evalNumeric(actual);
        return value != null && value.isFinite;
      }
      return true;
    }

    if (actual.startsWith('Matrix(') && expected.startsWith('Matrix(')) {
      return actual.replaceAll(RegExp(r'\s+'), '') ==
          expected.replaceAll(RegExp(r'\s+'), '');
    }
    if (actual.contains('=') || expected.contains('=')) {
      final assignments =
          RegExp(r'([A-Za-z]+)\s*=\s*(.*?)(?=,\s*[A-Za-z]+\s*=|$)');
      Map<String, String> parse(String value) =>
          {for (final m in assignments.allMatches(value)) m[1]!: m[2]!.trim()};
      final a = parse(actual), b = parse(expected);
      return a.isNotEmpty &&
          a.length == b.length &&
          a.keys
              .every((key) => b.containsKey(key) && _matches(a[key]!, b[key]!));
    }
    if (actual.startsWith('{') && expected.startsWith('{')) {
      final a = actual
          .substring(1, actual.length - 1)
          .split(',')
          .map((s) => s.trim())
          .toList();
      final b = expected
          .substring(1, expected.length - 1)
          .split(',')
          .map((s) => s.trim())
          .toList();
      if (a.length != b.length) return false;
      // Printed order is not a mathematical order, particularly for complex
      // roots. Match each equivalent element once, preserving multiplicity.
      for (final value in a) {
        final index = b.indexWhere((candidate) => _matches(value, candidate));
        if (index < 0) return false;
        b.removeAt(index);
      }
      return b.isEmpty;
    }
    String normalize(String value) {
      var v = value.trim().replaceAll('**', '^');
      // Matrix eigensolvers print numeric imaginary suffixes ("1i"). Bare
      // lowercase i remains an ordinary symbol; never globally rename it.
      v = v.replaceAllMapped(
          RegExp(
              r'(?<![A-Za-z_0-9])([+-]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?)\s*i\b'),
          (match) => '${match[1]}*I');
      // Antiderivative pretty-printing uses rational coefficients such as
      // "1/3x^3". Group that coefficient before adding explicit multiplication
      // so the numeric parser cannot interpret it as 1/(3*x^3).
      v = v.replaceAllMapped(
          RegExp(r'(?<![A-Za-z_0-9.])(\d+)/(\d+)(?=[A-Za-z_(])(?![eE][+-]?\d)'),
          (match) => '(${match[1]}/${match[2]})*');
      final complex =
          RegExp(
              r'^([+-]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?)\s*([+-])\s*((?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?)\s*\*\s*I$')
          .firstMatch(v);
      if (complex != null) {
        final real = double.tryParse(complex[1]!.trim());
        final imaginary = double.tryParse(complex[3]!);
        if (imaginary != null &&
            imaginary.isFinite &&
            (imaginary == 0 ||
                (real != null &&
                    real.isFinite &&
                    real != 0 &&
                    imaginary.abs() / real.abs() < 1e-12))) {
          v = complex[1]!.trim();
        }
      }
      v = v.replaceAll(RegExp(r'[+\-]\s*0(?:\.0+)?\s*\*\s*I'), '');
      return v;
    }

    final normalizedActual = normalize(actual);
    final normalizedExpected = normalize(expected);
    // CAS cancellation proves an identity only on its common domain. Preserve
    // the bounded rational-domain evidence the app can actually establish.
    final actualDomain = RationalDomain.inspect(normalizedActual);
    final expectedDomain = RationalDomain.inspect(normalizedExpected);
    final actualExcluded = actualDomain?.excluded.toSet() ?? <String>{};
    final expectedExcluded = expectedDomain?.excluded.toSet() ?? <String>{};
    if (actualExcluded.length != expectedExcluded.length ||
        !actualExcluded.containsAll(expectedExcluded)) {
      return false;
    }

    final a = NumericFallbackEvaluator.compile(normalizedActual);
    final b = NumericFallbackEvaluator.compile(normalizedExpected);
    // The real parser accepts unknown identifiers, including I, as variables.
    // Explicitly reserve I for complex arithmetic instead of binding it to a
    // real probe coordinate and accidentally testing a different expression.
    final hasImaginaryUnit =
        RegExp(r'\bI\b').hasMatch('$normalizedActual $normalizedExpected');
    if (hasImaginaryUnit || a == null || b == null) {
      // This path includes complex results. Never project onto the real part:
      // prove the full identity, or measure the full complex residual for
      // numeric constants whose printed representation may be approximate.
      if (!engine.isNativeAvailable) return false;
      final difference =
          engine.simplify('($normalizedActual)-($normalizedExpected)');
      if (!invalid.hasMatch(difference) &&
          RegExp(r'^0(?:\.0+)?$').hasMatch(difference.trim())) {
        return true;
      }
      if (!hasImaginaryUnit) return false;
      bool numericConstant(String value) {
        const constants = {'I', 'pi', 'PI', 'e', 'E', 'tau'};
        for (final identifier
            in RegExp(r'[A-Za-z_][A-Za-z_0-9]*').allMatches(value)) {
          if (!constants.contains(identifier[0]) &&
              !value.substring(identifier.end).trimLeft().startsWith('(')) {
            return false;
          }
        }
        return true;
      }

      if (!numericConstant(normalizedActual) ||
          !numericConstant(normalizedExpected)) {
        return false;
      }
      // Prefer a real parsed reference: computing abs() through complex
      // squaring can underflow even when a tiny real number is representable.
      final realReference =
          NumericFallbackEvaluator.evalNumeric(normalizedExpected);
      final magnitudeText = realReference == null
          ? engine.evaluate('abs($normalizedExpected)')
          : realReference.abs().toString();
      if (invalid.hasMatch(magnitudeText)) return false;
      final magnitude = realReference?.abs() ??
          NumericFallbackEvaluator.evalNumeric(normalize(magnitudeText));
      if (magnitude == null || !magnitude.isFinite || magnitude < 0) {
        return false;
      }
      // A magnitude rounded down to zero is not proof of a zero reference.
      if (magnitude == 0 &&
          !RegExp(r'^0(?:\.0+)?$')
              .hasMatch(engine.simplify(normalizedExpected).trim())) {
        return false;
      }
      final residualText = magnitude == 0
          ? engine.evaluate('abs(($normalizedActual)-($normalizedExpected))')
          : engine.evaluate(
              'abs(($normalizedActual)/($magnitude)-($normalizedExpected)/($magnitude))');
      if (invalid.hasMatch(residualText)) return false;
      // Scale components before abs(), so tiny complex residuals cannot
      // disappear while squaring. No unresolved symbol may pass as a number.
      final residual =
          NumericFallbackEvaluator.evalNumeric(normalize(residualText));
      return residual != null &&
          residual.isFinite &&
          residual >= 0 &&
          residual <= 1e-8;
    }
    final identifiers = RegExp(r'[A-Za-z_][A-Za-z_0-9]*')
        .allMatches('$normalizedActual $normalizedExpected')
        .map((m) => m[0]!)
        .toSet()
        .toList()
      ..sort();
    var finiteChecks = 0;
    final probes = [0.0, 1.0, -1.0, 2.0, -1.73, -0.41, 0.23, 1.37, 2.61, 4.19];
    for (var probe = 0; probe < probes.length; probe++) {
      final x = probes[probe];
      // Shared zero/one anchors catch common holes. Subsequent coordinates are
      // independent, so u/v or missing integration C cannot alias accidentally.
      final scope = <String, double>{
        for (var i = 0; i < identifiers.length; i++)
          identifiers[i]: probe < 3 ? x : x + i * 0.379 + i * i * 0.113
      };
      final av = a.evaluate(scope);
      final bv = b.evaluate(scope);
      final aFinite = av != null && av.isFinite;
      final bFinite = bv != null && bv.isFinite;
      if (!aFinite || !bFinite) {
        if (aFinite != bFinite) return false;
        continue;
      }
      finiteChecks++;
      if (!_numericClose(av, bv, relativeTolerance: 1e-8)) {
        return false;
      }
    }
    return finiteChecks >= 3;
  }
}

import 'workflow_modules.dart';
import '../engine/calculator_engine.dart';
import '../engine/graph_sampling.dart';
import '../engine/notepad.dart';
import '../engine/notepad_evaluator.dart';
import '../engine/notepad_export.dart';
import '../engine/numeric_fallback.dart';
import '../services/engine_dispatch.dart';
import '../services/engine_op.dart';
import '../services/integral_arguments.dart';

/// Runs app code with explicit expectations, without touching saved documents.
class WorkflowTasks {
  WorkflowTasks(this.engine, {this.documentDispatcher});
  final CalculatorEngine engine;
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
    return {
      'schemaVersion': 2,
      'nativeBridge': nativeBridgeReady,
      'total': results.length,
      for (final status in ['passed', 'failed', 'unsupported'])
        status: results.where((r) => r['status'] == status).length,
      'results': results
    };
  }

  Future<Map<String, dynamic>> _execute(Map<String, dynamic> task) async {
    switch (task['kind']) {
      case 'module':
        final actual = await runWorkflowModule(engine, task);
        final pass = _structuredMatches(actual, task['expected'],
            unordered: task['unordered'] == true);
        return {
          'status': pass ? 'passed' : 'failed',
          'actual': actual,
          'expected': task['expected']
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
            dispatcher: documentDispatcher ?? (s) async => engine.evaluate(s));
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
          final pass = expected.length == actual.length &&
              List.generate(
                  expected.length,
                  (i) => expected[i] == null
                      ? actual[i] == null
                      : _matches(actual[i] ?? '', expected[i])).every((v) => v);
          return {
            'status': pass ? 'passed' : 'failed',
            'actual': actual,
            'expected': expected
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
                  : p.ok && (p.y - check['y']).abs() < 1e-8);
        }
        return {
          'status': pass ? 'passed' : 'failed',
          'actual': samples.toJson(),
          'expected': task['checks']
        };
    }
    throw StateError('Unhandled task');
  }

  bool _structuredMatches(dynamic actual, dynamic expected,
      {bool unordered = false}) {
    if (actual == null || expected == null) return actual == expected;
    if (actual is num && expected is num) {
      return actual.isFinite &&
          (actual - expected).abs() <= 1e-7 * (1 + expected.abs());
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
    if (actual == expected) return true;
    if (actual.startsWith('Error') || actual.contains('Error:')) return false;

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
          .toList()
        ..sort();
      final b = expected
          .substring(1, expected.length - 1)
          .split(',')
          .map((s) => s.trim())
          .toList()
        ..sort();
      return a.length == b.length &&
          List.generate(a.length, (i) => _matches(a[i], b[i])).every((v) => v);
    }
    String normalize(String value) {
      var v = value.trim().replaceAll('**', '^');
      final complex =
          RegExp(r'^(.+?)\s*([+-])\s*([0-9.eE+-]+)\*I$').firstMatch(v);
      if (complex != null) {
        final imaginary = double.tryParse(complex[3]!);
        if (imaginary != null && imaginary.abs() < 1e-12) {
          v = complex[1]!.trim();
        }
      }
      v = v.replaceAll(RegExp(r'[+\-]\s*0(?:\.0+)?\s*\*\s*I'), '');
      return v;
    }

    final a = NumericFallbackEvaluator.compile(normalize(actual));
    final b = NumericFallbackEvaluator.compile(normalize(expected));
    if (a == null || b == null) return false;
    for (final x in [-1.73, -0.41, 0.23, 1.37, 2.61, 4.19]) {
      final scope = {
        'x': x,
        'y': x * x + 0.37,
        't': x * x + 0.73,
        'C': x * x * x + 0.91
      };
      final av = a.evaluate(scope);
      final bv = b.evaluate(scope);
      if (av == null ||
          bv == null ||
          !av.isFinite ||
          !bv.isFinite ||
          (av - bv).abs() > 1e-8 * (1 + bv.abs())) {
        return false;
      }
    }
    return true;
  }
}

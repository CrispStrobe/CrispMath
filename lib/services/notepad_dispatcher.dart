import 'package:dart_csp/dart_csp.dart';
import '../engine/calculator_engine.dart';
import '../engine/currency_evaluator.dart';
import '../engine/date_time_evaluator.dart';
import '../engine/notepad_evaluator.dart';
import '../engine/numeric_fallback.dart';
import '../engine/unit_expression.dart';
import '../utils/expression_preprocessing_utils.dart';
import '../utils/latex_conversion_utils.dart';
import 'engine_service.dart';

/// Shared routing/formatting for document evaluation, independent of screen UI.
/// Worker callbacks are injectable so CAS routing is testable without native FFI.
class NotepadDispatcher {
  NotepadDispatcher(
      {required this.formatNumber,
      CalculatorEngine? engine,
      Future<String> Function(String)? evaluateExpression,
      Future<String> Function(EngineOp)? runOperation})
      : _engine = engine ?? CalculatorEngine(),
        evaluateExpression = evaluateExpression ?? EngineService.evaluateAsync,
        runOperation = runOperation ?? EngineService.runOpAsync;
  final CalculatorEngine _engine;
  final String Function(String) formatNumber;
  final Future<String> Function(String) evaluateExpression;
  final Future<String> Function(EngineOp) runOperation;
  final Stopwatch _localWorkBudget = Stopwatch();

  /// Engine dispatcher injected into [NotepadEvaluator]. Receives a
  /// notepad-preprocessed body (scope names + Ans already
  /// substituted by Phase 2) and returns either a formatted result
  /// string or an `Error: ...` string the evaluator wraps with
  /// [NotepadErrorPrefix.fromEngine].
  ///
  /// Phase 6 wiring:
  ///   - Try [UnitExpressionEvaluator.tryEvaluate] first so
  ///     `5 km + 3 m`, `100 km/h in mph` etc. parse inline, mirroring
  ///     `calculator_screen.dart:745-753`.
  ///   - Otherwise route through `EngineService.evaluateAsync` after
  ///     `preprocessNativeExpression` (same native-format step the
  ///     calculator uses).
  ///   - Pass the resulting string through `AppState.formatNumber`
  ///     so the global `NumberDisplayFormat` setting (decision #19)
  ///     applies consistently — same display semantics as the
  ///     calculator's history rows.
  Future<String> evaluate(String preprocessed) async {
    if (preprocessed.trim().isEmpty) return '';

    // Calendar operators depend on whitespace that LaTeX normalization
    // removes. Recognize them before interpreting digit/minus-only input.
    final calendar = DateTimeEvaluator.tryEvaluate(preprocessed);
    if (calendar != null) return calendar;

    final integerSum = _smallIntegerSum(preprocessed);
    if (integerSum != null) {
      // Bound main-thread work while avoiding a browser timer per cheap row.
      // The budget includes scope construction between dispatcher calls.
      if (!_localWorkBudget.isRunning ||
          _localWorkBudget.elapsedMilliseconds >= 8) {
        await Future<void>.delayed(Duration.zero);
        _localWorkBudget
          ..reset()
          ..start();
      }
      return formatNumber(integerSum);
    }

    // LaTeX-friendly input — convert `x^{3}`, `\cdot`, `\frac{a}{b}`,
    // etc. into engine syntax. The calculator screen runs the same
    // pass before evaluating; without it, anyone pasting or typing
    // LaTeX (e.g. `diff(x^{3} - 4\cdot x + 7, x)`) gets a parse
    // failure that SymEngine can't recover from.
    // Also collapse whitespace between a function name and its
    // `(` so `solve (x, y)` matches the CAS dispatch the same as
    // `solve(x, y)`.
    var preNative = ExpressionPreprocessingUtils.preprocessLogicalOperators(
        LatexConversionUtils.fromLatex(preprocessed).replaceAllMapped(
            RegExp(r'\b([a-zA-Z/]+)\s+\('), (m) => '${m[1]}('));

    // Round 111b (P7): fold `if(cond, then, else)` when the
    // condition evaluates to a known boolean. Routes the
    // condition through the worker isolate.
    final ifFolded = await ExpressionPreprocessingUtils.tryFoldIfConditional(
      preNative,
      (cond) async => await evaluateExpression(cond),
    );
    if (ifFolded != null) {
      preNative = ifFolded;
    }

    // Round 91 (P6): precision-arc top-level calls — `pi(100)`,
    // `factorint(360)`, `isprime(2027)`, etc. Runs before the unit
    // evaluator since `e(50)` would tokenize as the symbol `e`
    // followed by `(50)` and unit eval would refuse it. Also
    // before the CAS dispatcher since `factorint` isn't a CAS
    // function name. Bypasses SymEngine entirely.
    final precisionResult = _engine.tryEvaluatePrecisionCall(preNative);
    if (precisionResult != null) return formatNumber(precisionResult);

    // Notepad V2: date/time arithmetic.
    final dateResult = DateTimeEvaluator.tryEvaluate(preNative);
    if (dateResult != null) return dateResult;

    // Notepad V2 Tier C: currency conversion.
    final currencyResult = CurrencyEvaluator.tryEvaluate(preNative);
    if (currencyResult != null) return currencyResult;

    // Try the unit evaluator first against the LaTeX-stripped
    // body and again with all parens stripped — Phase 2's Ans
    // substitution wraps the previous-line result in parens (so
    // `Ans + 1` binds correctly for arithmetic), but the unit
    // tokenizer doesn't grok parens (PLAN V6 deferred), so
    // `(8 km) in miles` would otherwise fail. Stripping all parens
    // is safe for the unit fallback since unit expressions don't
    // use parens for grouping in V1.
    var unitResult = UnitExpressionEvaluator.tryEvaluate(preNative);
    if (unitResult == null && preNative.contains('(')) {
      final stripped = preNative.replaceAll('(', '').replaceAll(')', '');
      unitResult = UnitExpressionEvaluator.tryEvaluate(stripped);
    }
    if (unitResult != null) return formatNumber(unitResult);

    // CAS function calls — route to the dedicated specialized
    // handlers in the worker isolate (engine_service.dart's
    // `runOpAsync`) rather than the generic evaluate. Mirrors the
    // calculator's dispatch table at calculator_screen.dart:756-795
    // so `diff(x^3, x)`, `integrate(x^2, x)`, `solve(2x+3, x)`,
    // `factor(x^2-1)`, `expand((x+1)^2)`, `simplify(...)`,
    // `limit(...)` all produce the same result the calculator would.
    final casResult = await _maybeDispatchCas(preNative);
    if (casResult != null) return casResult;

    final native =
        ExpressionPreprocessingUtils.preprocessNativeExpression(preNative);

    // If preprocessing already produced a bare integer literal
    // (typical case: `100!` → 158-digit BigInt string), don't
    // round-trip through SymEngine — the parser converts integers
    // past ~15 digits to RealDouble and returns scientific notation.
    // Return the literal as-is; exact-integer-mode display picks it
    // up via the digit-count guard in `AppState.formatNumber`.
    if (RegExp(r'^[+-]?\d+$').hasMatch(native.trim())) {
      return formatNumber(native.trim());
    }

    try {
      final raw = await evaluateExpression(native);
      if (raw.startsWith('Error')) return raw;
      var normalized = ExpressionPreprocessingUtils.normalizeBooleanResult(
          ExpressionPreprocessingUtils.normalizeComplexResult(raw));
      // normalizeComplexResult inserts spaces around `-` for binary
      // operands, but for a unary-minus result like `-5` that turns
      // it into `- 5` which `double.tryParse` can't read — and
      // `formatNumber` then silently bails, so the NumberDisplayFormat
      // setting goes ignored on negative results. Compact a leading
      // "- " back into "-" before formatting.
      if (normalized.startsWith('- ') &&
          normalized.length > 2 &&
          (normalized[2] == '.' ||
              (normalized.codeUnitAt(2) >= 0x30 &&
                  normalized.codeUnitAt(2) <= 0x39))) {
        normalized = '-${normalized.substring(2)}';
      }
      return formatNumber(normalized);
    } on EngineCancelled {
      return 'Error: cancelled';
    } catch (e) {
      return 'Error: $e';
    }
  }

  /// Reuse the numeric parser only where IEEE doubles are provably exact.
  /// At most 40 operands fit in 80 characters; each is <= 2^31 - 1.
  /// Addition/subtraction intermediate results therefore stay well below 2^53.
  /// All other arithmetic continues through the existing engine dispatcher.
  static String? _smallIntegerSum(String source) {
    if (source.length > 80 ||
        !RegExp(r'^[\d\s()+-]+$').hasMatch(source) ||
        RegExp(r'\d\s+\d|\)\s*[\d(]|\d\s*\(').hasMatch(source)) {
      return null;
    }
    for (final token in RegExp(r'\d+').allMatches(source)) {
      final value = int.tryParse(token.group(0)!);
      if (value == null || value > 2147483647) return null;
    }
    final value = NumericFallbackEvaluator.evalNumeric(source);
    if (value == null || !value.isFinite) return null;
    return value.toInt().toString();
  }

  /// FlatZinc dispatcher for `fzn:` lines (Round E.4). Calls
  /// dart_csp's FlatZinc frontend directly. The returned
  /// [NotepadFlatZincResult.formatted] is the standard FlatZinc
  /// output (suitable for the result-column render) and the
  /// scalar bindings populate `cachedExports` so downstream
  /// notepad lines can reference the solved values by name.
  Future<NotepadFlatZincResult> solveFlatZinc(String source) async {
    final formatted = await FlatZinc.solve(source);
    return NotepadFlatZincResult(
      formatted: formatted,
      scalarBindings: parseFlatZincScalarOutputs(formatted),
    );
  }

  /// Detect a single CAS function call like `diff(x^3, x)` or
  /// `integrate(sin(x), x)` and route it to the corresponding
  /// `runOperation(EngineOp(...))` path. Returns null
  /// when [src] isn't a recognized CAS function so the dispatcher
  /// can fall through to generic `evaluate`. Mirrors the dispatch
  /// table in `calculator_screen.dart:756-795`.
  Future<String?> _maybeDispatchCas(String src) async {
    final trimmed = src.trim();
    EngineOp? op;

    if (_isCasCall(trimmed, 'diff') || _isCasCall(trimmed, 'd/dx')) {
      final args = _splitCasArgs(trimmed);
      if (args.length != 2) return null;
      op = EngineOp('differentiate', _native(args[0]), args[1].trim());
    } else if (_isCasCall(trimmed, 'integrate')) {
      final args = _splitCasArgs(trimmed);
      if (args.length < 2 || args.length > 4) return null;
      op = EngineOp(
        'integrate',
        _native(args[0]),
        args[1].trim(),
        args.length > 2 ? args[2].trim() : null,
        args.length > 3 ? args[3].trim() : null,
      );
    } else if (_isCasCall(trimmed, 'solve')) {
      final args = _splitCasArgs(trimmed);
      if (args.isEmpty || args.length > 2) return null;
      var equation = args[0].trim();
      final variable = args.length == 2
          ? args[1].trim()
          : ExpressionPreprocessingUtils.detectVariable(equation);
      // `solve(x^2 = 4, x)` — fold the `=` into a standard
      // `LHS - (RHS)` form before sending to the engine. Mirrors
      // calculator_screen.dart:1014-1023.
      if (equation.contains('=')) {
        final eqParts = equation.split('=');
        if (eqParts.length == 2) {
          final leftSide = eqParts[0].trim();
          final rightSide = eqParts[1].trim();
          equation = rightSide == '0' || rightSide.isEmpty
              ? leftSide
              : '$leftSide - ($rightSide)';
        }
      }
      op = EngineOp('solve', _native(equation), variable);
    } else if (_isCasCall(trimmed, 'limit')) {
      final args = _splitCasArgs(trimmed);
      if (args.length != 3) return null;
      op = EngineOp('limit', _native(args[0]), args[1].trim(), args[2].trim());
    } else if (_isCasCall(trimmed, 'factor')) {
      final args = _splitCasArgs(trimmed);
      if (args.length != 1) return null;
      op = EngineOp('factor', _native(args[0]));
    } else if (_isCasCall(trimmed, 'expand')) {
      final args = _splitCasArgs(trimmed);
      if (args.length != 1) return null;
      op = EngineOp('expand', _native(args[0]));
    } else if (_isCasCall(trimmed, 'simplify')) {
      final args = _splitCasArgs(trimmed);
      if (args.length != 1) return null;
      op = EngineOp('simplify', _native(args[0]));
    }

    if (op == null) return null;
    try {
      final raw = await runOperation(op);
      if (raw.startsWith('Error')) return raw;
      final normalized =
          ExpressionPreprocessingUtils.normalizeComplexResult(raw);
      return formatNumber(normalized);
    } on EngineCancelled {
      return 'Error: cancelled';
    } catch (e) {
      return 'Error: $e';
    }
  }

  bool _isCasCall(String src, String name) {
    return src.startsWith('$name(') && src.endsWith(')');
  }

  /// Comma-split with paren/bracket-depth awareness so
  /// `integrate(f(x), x)` splits into `[f(x), x]` rather than
  /// `[f(x, x)]`.
  List<String> _splitCasArgs(String src) {
    final open = src.indexOf('(');
    if (open < 0) return const [];
    final body = src.substring(open + 1, src.length - 1);
    final out = <String>[];
    var depth = 0;
    var start = 0;
    for (var i = 0; i < body.length; i++) {
      final ch = body[i];
      if (ch == '(' || ch == '[') {
        depth++;
      } else if (ch == ')' || ch == ']') {
        depth--;
      } else if (ch == ',' && depth == 0) {
        out.add(body.substring(start, i));
        start = i + 1;
      }
    }
    if (start <= body.length) {
      out.add(body.substring(start));
    }
    return out;
  }

  String _native(String s) =>
      ExpressionPreprocessingUtils.preprocessNativeExpression(s);
}

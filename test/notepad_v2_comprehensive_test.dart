// test/notepad_v2_comprehensive_test.dart
//
// Comprehensive tests for all Notepad V2 + session features.

import 'package:flutter_test/flutter_test.dart';
import 'package:crisp_calc/engine/notepad.dart';
import 'package:crisp_calc/engine/notepad_evaluator.dart';
import 'package:crisp_calc/engine/notepad_undo.dart';
import 'package:crisp_calc/engine/notepad_templates.dart';
import 'package:crisp_calc/engine/date_time_evaluator.dart';
import 'package:crisp_calc/engine/currency_evaluator.dart';
import 'package:crisp_calc/engine/symbolic_limit.dart';
import 'package:crisp_calc/utils/expression_preprocessing_utils.dart';
import 'package:crisp_calc/widgets/mini_plot_widget.dart';

void main() {
  // =========================================================================
  // Cross-document references
  // =========================================================================
  group('Cross-document references', () {
    test('resolves {doc:name}.variable from another doc', () {
      final taxes = NotepadDocument(
        id: 'taxes',
        name: 'Taxes',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        lines: [
          NotepadLine(id: 'a', source: 'rate = 0.085')
            ..cachedResult = '0.085',
        ],
      );
      final allDocs = {'taxes': taxes};
      final result = resolveCrossDocRefs(
        '100 * {doc:Taxes}.rate',
        allDocs,
      );
      expect(result, '100 * (0.085)');
    });

    test('resolves {doc:name}.lineN positional alias', () {
      final other = NotepadDocument(
        id: 'other',
        name: 'Other',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        lines: [
          NotepadLine(id: 'x', source: '42')..cachedResult = '42',
          NotepadLine(id: 'y', source: '100')..cachedResult = '100',
        ],
      );
      final allDocs = {'other': other};
      final result = resolveCrossDocRefs(
        '{doc:Other}.line2 + 1',
        allDocs,
      );
      expect(result, '(100) + 1');
    });

    test('unresolved doc name passes through', () {
      final result = resolveCrossDocRefs(
        '{doc:Missing}.x',
        {},
      );
      expect(result, '{doc:Missing}.x');
    });

    test('unresolved variable passes through', () {
      final doc = NotepadDocument(
        id: 'd',
        name: 'D',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        lines: [],
      );
      final result = resolveCrossDocRefs('{doc:D}.missing', {'d': doc});
      expect(result, '{doc:D}.missing');
    });

    test('case insensitive doc name match', () {
      final doc = NotepadDocument(
        id: 'd',
        name: 'My Budget',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        lines: [
          NotepadLine(id: 'a', source: 'total_cost = 500')
            ..cachedResult = '500',
        ],
      );
      final result = resolveCrossDocRefs(
        '{doc:my budget}.total_cost',
        {'d': doc},
      );
      expect(result, '(500)');
    });
  });

  // =========================================================================
  // Date/time evaluator — thorough
  // =========================================================================
  group('DateTimeEvaluator — thorough', () {
    test('ISO date with slashes', () {
      final r = DateTimeEvaluator.tryEvaluate('2026/01/15');
      expect(r, isNotNull);
      expect(r, contains('January'));
    });

    test('yesterday', () {
      final r = DateTimeEvaluator.tryEvaluate('yesterday');
      expect(r, isNotNull);
    });

    test('date + 2 weeks', () {
      final r = DateTimeEvaluator.tryEvaluate('2026-01-01 + 2 weeks');
      expect(r, '2026-01-15');
    });

    test('date + 1 months', () {
      final r = DateTimeEvaluator.tryEvaluate('2026-03-15 + 1 months');
      expect(r, '2026-04-15');
    });

    test('date - date gives days', () {
      final r = DateTimeEvaluator.tryEvaluate('2026-01-31 - 2026-01-01');
      expect(r, '30 days');
    });

    test('today - yesterday = 1 day', () {
      final r = DateTimeEvaluator.tryEvaluate('today - yesterday');
      expect(r, '1 days');
    });

    test('days between two dates', () {
      final r =
          DateTimeEvaluator.tryEvaluate('days between 2026-01-01 and 2026-12-31');
      expect(r, isNotNull);
      expect(r, '364 days');
    });

    test('non-date arithmetic returns null', () {
      expect(DateTimeEvaluator.tryEvaluate('x^2 + 1'), isNull);
      expect(DateTimeEvaluator.tryEvaluate('solve(x, x)'), isNull);
      expect(DateTimeEvaluator.tryEvaluate(''), isNull);
    });
  });

  // =========================================================================
  // Currency evaluator — thorough
  // =========================================================================
  group('CurrencyEvaluator — thorough', () {
    test('100 GBP in JPY', () {
      final r = CurrencyEvaluator.tryEvaluate('100 GBP in JPY');
      expect(r, isNotNull);
      expect(r!.endsWith('JPY'), true);
      // 100 / 0.79 * 157.5 ≈ 19937 JPY
      final val = int.tryParse(r.split(' ')[0]);
      expect(val, isNotNull);
      expect(val!, greaterThan(19000));
    });

    test('decimal amounts', () {
      final r = CurrencyEvaluator.tryEvaluate('99.99 USD in EUR');
      expect(r, isNotNull);
      expect(r, contains('EUR'));
    });

    test('same currency', () {
      final r = CurrencyEvaluator.tryEvaluate('100 USD in USD');
      expect(r, '100.00 USD');
    });

    test('all known codes are 3 uppercase letters', () {
      for (final code in CurrencyEvaluator.knownCodes) {
        expect(code.length, 3);
        expect(code, code.toUpperCase());
      }
    });

    test('at least 40 currencies', () {
      expect(CurrencyEvaluator.knownCodes.length, greaterThanOrEqualTo(40));
    });
  });

  // =========================================================================
  // Percentage preprocessor — edge cases
  // =========================================================================
  group('Percentage preprocessor — edge cases', () {
    String pct(String s) =>
        ExpressionPreprocessingUtils.preprocessPercentage(s);

    test('100%', () {
      expect(pct('100%'), '(100)/100');
    });

    test('0%', () {
      expect(pct('0%'), '(0)/100');
    });

    test('nested expression not matched as percentage', () {
      // sin(x) has no % so passes through.
      expect(pct('sin(x)'), 'sin(x)');
    });

    test('M + 0% is markup with 0', () {
      expect(pct('200 + 0%'), '(200)*(1+(0)/100)');
    });

    test('what % of 100 is 100 gives 100', () {
      // (100)/(100)*100 = 100
      expect(pct('what % of 100 is 100'), '(100)/(100)*100');
    });
  });

  // =========================================================================
  // Symbolic limit — ratio parser edge cases
  // =========================================================================
  group('SymbolicLimit — additional tests', () {
    test('nested parens in numerator', () {
      final r = SymbolicLimit.parseRatioForTest('((x+1)*(x-1)) / (x^2)');
      expect(r, isNotNull);
      expect(r!.numerator, '(x+1)*(x-1)');
      expect(r.denominator, 'x^2');
    });

    test('single character operands', () {
      final r = SymbolicLimit.parseRatioForTest('a / b');
      expect(r, isNotNull);
      expect(r!.numerator, 'a');
      expect(r.denominator, 'b');
    });
  });

  // =========================================================================
  // Undo/redo — comprehensive
  // =========================================================================
  group('UndoHistory — comprehensive', () {
    test('multiple undo steps', () {
      final h = UndoHistory();
      h.record(const UndoOp(kind: UndoOpKind.edit, index: 0, lineId: 'a',
          previousValue: 'v1'));
      h.record(const UndoOp(kind: UndoOpKind.edit, index: 0, lineId: 'a',
          previousValue: 'v2'));
      h.record(const UndoOp(kind: UndoOpKind.edit, index: 0, lineId: 'a',
          previousValue: 'v3'));
      expect(h.undoCount, 3);

      final op3 = h.undo()!;
      expect(op3.previousValue, 'v3');
      final op2 = h.undo()!;
      expect(op2.previousValue, 'v2');
      final op1 = h.undo()!;
      expect(op1.previousValue, 'v1');
      expect(h.undo(), isNull);
    });

    test('redo after multiple undos', () {
      final h = UndoHistory();
      h.record(const UndoOp(kind: UndoOpKind.edit, index: 0));
      h.record(const UndoOp(kind: UndoOpKind.edit, index: 1));
      h.undo();
      h.undo();
      expect(h.redoCount, 2);
      final r1 = h.redo()!;
      expect(r1.index, 0);
      final r2 = h.redo()!;
      expect(r2.index, 1);
      expect(h.redo(), isNull);
    });

    test('clear empties both stacks', () {
      final h = UndoHistory();
      h.record(const UndoOp(kind: UndoOpKind.edit, index: 0));
      h.undo();
      h.clear();
      expect(h.canUndo, false);
      expect(h.canRedo, false);
    });

    test('applyUndo reorder reverses the move', () {
      final doc = NotepadDocument.fresh(name: 'T');
      doc.lines.clear();
      doc.lines.addAll([
        NotepadLine(id: 'a', source: 'first'),
        NotepadLine(id: 'b', source: 'second'),
        NotepadLine(id: 'c', source: 'third'),
      ]);
      // Simulate reorder: moved from index 0 to index 2.
      final op = UndoOp(
        kind: UndoOpKind.reorder,
        index: 0,
        newIndex: 2,
        lineId: 'a',
      );
      // Apply redo first (the forward move).
      applyRedo(doc, op);
      expect(doc.lines.map((l) => l.id).toList(), ['b', 'c', 'a']);

      // Now undo should reverse it.
      applyUndo(doc, op);
      // After undo of reorder(0→2), line at index 2 should move back to 0.
      expect(doc.lines.map((l) => l.id).toList(), ['a', 'b', 'c']);
    });
  });

  // =========================================================================
  // Notepad line kind classification — comprehensive
  // =========================================================================
  group('classifyNotepadLine — comprehensive', () {
    ParsedNotepadLine classify(String src, {int lineIndex = 5}) =>
        classifyNotepadLine(src, lineIndex: lineIndex, firstCodeLineIndex: 0);

    test('blank line', () {
      expect(classify('').kind, NotepadLineKind.blank);
      expect(classify('   ').kind, NotepadLineKind.blank);
    });

    test('comment with //', () {
      expect(classify('// hello').kind, NotepadLineKind.comment);
    });

    test('comment with #', () {
      expect(classify('# comment').kind, NotepadLineKind.comment);
    });

    test('heading', () {
      final p = classify('## Section 1');
      expect(p.kind, NotepadLineKind.heading);
      expect(p.body, 'Section 1');
    });

    test('divider', () {
      expect(classify('---').kind, NotepadLineKind.divider);
      expect(classify('-----').kind, NotepadLineKind.divider);
    });

    test('plot with single arg', () {
      final p = classify('plot(x^2)');
      expect(p.kind, NotepadLineKind.plot);
      expect(p.body, 'x^2');
    });

    test('plot with four args', () {
      final p = classify('plot(sin(x), x, -3.14, 3.14)');
      expect(p.kind, NotepadLineKind.plot);
      expect(p.body, 'sin(x)');
      expect(p.name, 'x');
      expect(p.imports, ['-3.14', '3.14']);
    });

    test('aggregate total', () {
      expect(classify('total').kind, NotepadLineKind.aggregate);
      expect(classify('TOTAL').kind, NotepadLineKind.aggregate);
    });

    test('aggregate subtotal', () {
      expect(classify('subtotal').kind, NotepadLineKind.aggregate);
    });

    test('aggregate average', () {
      expect(classify('average').kind, NotepadLineKind.aggregate);
    });

    test('aggregate count', () {
      expect(classify('count').kind, NotepadLineKind.aggregate);
    });

    test('fzn: line', () {
      expect(classify('fzn: var int: x :: output_var;').kind,
          NotepadLineKind.flatzinc);
    });

    test('assignment', () {
      final p = classify('x = 42');
      expect(p.kind, NotepadLineKind.assignment);
      expect(p.name, 'x');
      expect(p.body, '42');
    });

    test('expression', () {
      expect(classify('2 + 3').kind, NotepadLineKind.expression);
      expect(classify('sin(x)').kind, NotepadLineKind.expression);
    });

    test('use directive on first code line', () {
      final p = classifyNotepadLine('use myvar',
          lineIndex: 0, firstCodeLineIndex: 0);
      expect(p.kind, NotepadLineKind.useDirective);
    });

    test('use directive NOT on first code line', () {
      final p = classifyNotepadLine('use myvar',
          lineIndex: 5, firstCodeLineIndex: 0);
      expect(p.kind, NotepadLineKind.expression);
    });
  });

  // =========================================================================
  // PlotSpec — additional
  // =========================================================================
  group('PlotSpec — additional', () {
    test('custom variable and range', () {
      final s = PlotSpec.tryParse('__plot__:sin(t)|t|0|6.28');
      expect(s, isNotNull);
      expect(s!.variable, 't');
      expect(s.lo, closeTo(0, 0.01));
      expect(s.hi, closeTo(6.28, 0.01));
    });

    test('negative range', () {
      final s = PlotSpec.tryParse('__plot__:x^3|x|-100|100');
      expect(s, isNotNull);
      expect(s!.lo, -100);
      expect(s.hi, 100);
    });
  });

  // =========================================================================
  // Line result format — additional
  // =========================================================================
  group('formatLineResult — additional', () {
    test('fraction of pi approximation', () {
      // pi ≈ 3.14159265 → 355/113 is famous
      final r = formatLineResult('3.14159265', LineResultFormat.fraction);
      expect(r, isNotNull);
      // Should be close to 355/113
      expect(r, contains('/'));
    });

    test('fraction of 0.25', () {
      expect(formatLineResult('0.25', LineResultFormat.fraction), '1/4');
    });

    test('fraction of integer', () {
      expect(formatLineResult('7', LineResultFormat.fraction), '7');
    });

    test('scientific of small number', () {
      final r = formatLineResult('0.000123', LineResultFormat.scientific);
      expect(r, isNotNull);
      expect(r!.contains('e'), true);
    });

    test('hex of 0', () {
      expect(formatLineResult('0', LineResultFormat.hex), '0x0');
    });

    test('binary of 0', () {
      expect(formatLineResult('0', LineResultFormat.binary), '0b0');
    });

    test('decimal of non-numeric returns null', () {
      expect(formatLineResult('hello', LineResultFormat.decimal), isNull);
    });
  });

  // =========================================================================
  // NotepadDocument JSON round-trip — comprehensive
  // =========================================================================
  group('NotepadDocument JSON round-trip', () {
    test('full document with all fields', () {
      final doc = NotepadDocument(
        id: 'test-id',
        name: 'Test Doc',
        createdAt: DateTime.utc(2026, 1, 1),
        updatedAt: DateTime.utc(2026, 6, 1),
        lines: [
          NotepadLine(
            id: 'l1',
            source: 'x = 42',
            cachedResult: '42',
            resultFormat: LineResultFormat.hex,
            pinned: true,
          ),
          NotepadLine(id: 'l2', source: 'x + 1'),
        ],
        useLatexInput: true,
      );

      final json = doc.toJson();
      final restored = NotepadDocument.fromJson(json);

      expect(restored.id, 'test-id');
      expect(restored.name, 'Test Doc');
      expect(restored.lines.length, 2);
      expect(restored.lines[0].resultFormat, LineResultFormat.hex);
      expect(restored.lines[0].pinned, true);
      expect(restored.lines[1].resultFormat, LineResultFormat.auto);
      expect(restored.lines[1].pinned, false);
      expect(restored.useLatexInput, true);
    });

    test('empty doc round-trips', () {
      final doc = NotepadDocument.fresh(name: 'Empty');
      final restored = NotepadDocument.fromJson(doc.toJson());
      expect(restored.name, 'Empty');
      expect(restored.useLatexInput, false);
    });
  });

  // =========================================================================
  // Welcome doc localization
  // =========================================================================
  group('Welcome doc localization', () {
    test('English welcome', () {
      final doc = buildWelcomeNotepadDocument(locale: 'en');
      expect(doc.name, 'Welcome');
      expect(doc.lines[0].source, contains('Welcome'));
    });

    test('German welcome', () {
      final doc = buildWelcomeNotepadDocument(locale: 'de');
      expect(doc.name, 'Willkommen');
      expect(doc.lines[0].source, contains('Willkommen'));
    });

    test('French welcome', () {
      final doc = buildWelcomeNotepadDocument(locale: 'fr');
      expect(doc.name, 'Bienvenue');
      expect(doc.lines[0].source, contains('Bienvenue'));
    });

    test('Spanish welcome', () {
      final doc = buildWelcomeNotepadDocument(locale: 'es');
      expect(doc.name, 'Bienvenida');
      expect(doc.lines[0].source, contains('Bienvenida'));
    });

    test('Unknown locale falls back to English', () {
      final doc = buildWelcomeNotepadDocument(locale: 'ja');
      expect(doc.name, 'Welcome');
    });

    test('Math lines are universal across locales', () {
      for (final locale in ['en', 'de', 'fr', 'es']) {
        final doc = buildWelcomeNotepadDocument(locale: locale);
        // Lines 1-4 (the math) should be identical.
        expect(doc.lines[1].source, 'tax = 0.085');
        expect(doc.lines[2].source, '142.50 * (1 + tax)');
        expect(doc.lines[3].source, '5 km + 3000 m');
        expect(doc.lines[4].source, 'Ans in miles');
      }
    });
  });

  // =========================================================================
  // Templates — comprehensive
  // =========================================================================
  group('NotepadTemplates — comprehensive', () {
    test('every template has at least 5 lines', () {
      for (final t in NotepadTemplates.all) {
        expect(t.lines.length, greaterThanOrEqualTo(5),
            reason: 'template ${t.id}');
      }
    });

    test('every template has a description', () {
      for (final t in NotepadTemplates.all) {
        expect(t.description.isNotEmpty, true, reason: 'template ${t.id}');
      }
    });

    test('budget template contains income and expenses sections', () {
      final budget = NotepadTemplates.all.firstWhere((t) => t.id == 'budget');
      expect(budget.lines.contains('## Income'), true);
      expect(budget.lines.contains('## Expenses'), true);
      expect(budget.lines.contains('## Balance'), true);
    });

    test('homework template has problem sections', () {
      final hw = NotepadTemplates.all.firstWhere((t) => t.id == 'homework');
      final headings = hw.lines.where((l) => l.startsWith('## ')).toList();
      expect(headings.length, greaterThanOrEqualTo(3));
    });

    test('physics template has constants section', () {
      final physics = NotepadTemplates.all.firstWhere((t) => t.id == 'physics');
      expect(physics.lines.contains('## Constants'), true);
      expect(physics.lines.contains('g = 9.81'), true);
    });

    test('createDocument produces unique ids', () {
      final tmpl = NotepadTemplates.all.first;
      final d1 = tmpl.createDocument();
      final d2 = tmpl.createDocument();
      expect(d1.id, isNot(d2.id));
    });
  });
}

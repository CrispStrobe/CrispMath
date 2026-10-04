import 'dart:convert';

import 'package:crisp_math/diagnostics/workflow_tasks.dart';
import 'package:crisp_math/engine/app_state.dart';
import 'package:crisp_math/engine/calculator_engine.dart';
import 'package:crisp_math/engine/statistics.dart';
import 'package:crisp_math/engine/unit_catalog.dart';
import 'package:crisp_math/engine/unit_expression.dart';
import 'package:crisp_math/screens/statistics_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('constant-response linear fit preserves coefficients but R squared is undefined', () {
    final fit = Statistics.linearFit([0, 2, 4], [5, 5, 5]);
    expect(fit.slope, 0);
    expect(fit.intercept, 5);
    expect(fit.rSquared.isNaN, isTrue);
  });

  test('degenerate explanatory variables leave every fit statistic undefined', () {
    final fit = Statistics.linearFit([2, 2, 2], [1, 3, 5]);
    expect(fit.slope.isNaN, isTrue);
    expect(fit.intercept.isNaN, isTrue);
    expect(fit.rSquared.isNaN, isTrue);
  });

  test('constant polynomial and exponential response have undefined R squared', () {
    final polynomial = Statistics.polynomialFit([-2, -1, 0, 1, 2], [5, 5, 5, 5, 5], 2);
    expect(polynomial.evaluate(3), closeTo(5, 1e-12));
    expect(polynomial.rSquared.isNaN, isTrue);
    final exponential = Statistics.expFit([0, 1, 2], [1, 1, 1]);
    expect(exponential.rSquared.isNaN, isTrue);
  });

  test('constant decimal samples remain undefined despite accumulation rounding', () {
    final ys = List<double>.filled(7, 5.1);
    final xs = List<double>.generate(7, (i) => i.toDouble());
    final fit = Statistics.linearFit(xs, ys);
    expect(fit.rSquared.isNaN, isTrue);
    expect(fit.slope, 0);
    expect(fit.intercept, 5.1);
    expect(Statistics.polynomialFit(xs, ys, 2).rSquared.isNaN, isTrue);
    expect(Statistics.linearFit(List<double>.filled(7, 0.1), xs).slope.isNaN,
        isTrue);
  });

  test('real diagnostic serialization preserves undefined R squared as null', () async {
    final report = await WorkflowTasks(CalculatorEngine()).run([
      {
        'id': 'constant-response-json', 'kind': 'module', 'operation': 'regression',
        'xs': [0, 2, 4], 'ys': [5, 5, 5],
        'expected': {'slope': 0, 'intercept': 5, 'rSquared': null},
      },
      {
        'id': 'degenerate-regression-json', 'kind': 'module', 'operation': 'regression',
        'xs': [2, 2, 2], 'ys': [1, 3, 5],
        'expected': {'slope': null, 'intercept': null, 'rSquared': null},
      },
    ]);
    expect(report['passed'], 2, reason: jsonEncode(report));
    final restored = jsonDecode(jsonEncode(report));
    expect(restored['results'][0]['actual']['rSquared'], isNull);
    expect(restored['results'][1]['actual']['slope'], isNull);
  });

  testWidgets('regression UI reports constant-response R squared as Undefined', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await AppState().load(force: true);
    AppState().consumePendingStatisticsTab();
    AppState().consumePendingStatisticsPresetId();
    await tester.binding.setSurfaceSize(const Size(1280, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(home: StatisticsScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Regression'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), '0, 2, 4');
    await tester.enterText(find.byType(TextField).at(1), '5, 5, 5');
    await tester.pumpAndSettle();
    expect(find.text('R² = Undefined'), findsOneWidget);
    expect(find.textContaining('NaN'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  group('prefixed litre conversions', () {
    for (final example in [
      ['1 mm^3 in μL', '1 μL'],
      ['1 L in μL', '1000000 μL'],
      ['2 mL in μL', '2000 μL'],
      ['250 uL in cm^3', '0.25 cm³'],
      ['1 μL in m^3', '1.000000e-9 m³'],
      ['250 µL in mL', '0.25 mL'],
      ['50 μL in mL', '0.05 mL'],
      // Cubing 10^-6 metres gives 10^-18 m³; a microlitre is 10^-9 m³.
      ['1 µm³ in µL', '1.000000e-9 µL'],
    ]) {
      test(example.first, () {
        expect(UnitExpressionEvaluator.tryEvaluate(example.first), example.last);
      });
    }
    test('microlitre prefix uses litre SI scale and volume dimension', () {
      final unit = UnitCatalog.bySymbolWithPrefixes('μL')!;
      expect(unit.dimension, UnitDimension.volume);
      expect(unit.scale, closeTo(1e-9, 1e-24));
      expect(UnitCatalog.prefixedSymbols(), contains('μL'));
      expect(UnitCatalog.bySymbolWithPrefixes('µL')!.scale, unit.scale);
    });
  });
}

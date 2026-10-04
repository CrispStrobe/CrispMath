import 'dart:convert';

import 'package:crisp_math/diagnostics/workflow_tasks.dart';
import 'package:crisp_math/engine/app_state.dart';
import 'package:crisp_math/engine/calculator_engine.dart';
import 'package:crisp_math/engine/hypothesis_tests.dart';
import 'package:crisp_math/engine/statistics.dart';
import 'package:crisp_math/engine/unit_catalog.dart';
import 'package:crisp_math/engine/unit_expression.dart';
import 'package:crisp_math/screens/statistics_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('singleton preserves undefined sample and zero population dispersion', () {
    final result = Statistics.describe([7]);
    expect(result.mean, 7);
    expect(result.sampleVariance.isNaN, isTrue);
    expect(result.sampleStddev.isNaN, isTrue);
    expect(result.populationVariance, 0);
    expect(result.populationStddev, 0);
    final repeated = Statistics.describe([7, 7]);
    expect(repeated.sampleVariance, 0);
    expect(repeated.sampleStddev, 0);
  });

  test('undefined diagnostic sample value survives JSON export as null', () async {
    final report = await WorkflowTasks(CalculatorEngine()).run([
      {
        'id': 'singleton-json',
        'kind': 'module',
        'operation': 'describe',
        'data': [7],
        'expected': {'mean': 7, 'median': 7, 'sampleStddev': null},
      }
    ]);
    expect(report['passed'], 1, reason: jsonEncode(report));
    final restored = jsonDecode(jsonEncode(report));
    expect(restored['results'][0]['actual']['sampleStddev'], isNull);
  });

  test('hypothesis tests reject undersized samples before undefined arithmetic', () {
    expect(() => HypothesisTests.oneSampleT(data: [7], hypothesizedMean: 0),
        throwsArgumentError);
    expect(() => HypothesisTests.welchT(sample1: [7], sample2: [1, 2]),
        throwsArgumentError);
  });

  testWidgets('actual statistics screen shows undefined singleton sample values',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await AppState().load(force: true);
    AppState().consumePendingStatisticsTab();
    AppState().consumePendingStatisticsPresetId();
    await tester.binding.setSurfaceSize(const Size(1280, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(home: StatisticsScreen()));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '7');
    await tester.pumpAndSettle();
    expect(find.text('Undefined'), findsNWidgets(2));
    expect(find.text('NaN'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  group('watt-hour energy and explicit derived conversion targets', () {
    for (final example in [
      ['1 Wh in J', '3600 J'],
      ['1 kWh in MJ', '3.6 MJ'],
      ['1 MJ in Wh', '277.7777777778 Wh'],
      ['500 mWh in J', '1800 J'],
      ['2 Wh + 3600 J in Wh', '3 Wh'],
      ['2500 J in kJ', '2.5 kJ'],
      ['1 W * 1 h in Wh', '1 Wh'],
      ['5 cm^2 in mm^2', '500 mm²'],
      ['3.6 km/s in m/s', '3600 m/s'],
      ['1 mm^3 in m^3', '1.000000e-9 m³'],
      ['1 m/ms in km/s', '1 km/s'],
      ['1000000 μm² in mm²', '1 mm²'],
    ]) {
      test(example.first, () {
        expect(UnitExpressionEvaluator.tryEvaluate(example.first), example.last);
      });
    }
    test('energy prefixes retain energy dimensions and correct SI scale', () {
      final energy = DerivedUnits.bySymbolWithPrefixes('kWh')!;
      expect(energy.dim, const Dimensions(mass: 1, length: 2, time: -2));
      expect(energy.toSi(1), 3600000);
      expect(DerivedUnits.matchingBaseDim(energy.dim)?.symbol, 'J');
    });
    test('requested incompatible derived targets are rejected rather than ignored', () {
      for (final expression in ['1 J in W', '1 Wh in W', '1 km in Wh']) {
        expect(UnitExpressionEvaluator.tryEvaluate(expression),
            startsWith('Error: cannot convert result'), reason: expression);
      }
    });
  });
}

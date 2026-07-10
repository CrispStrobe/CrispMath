// test/date_time_evaluator_test.dart
//
// Thorough tests for the date/time evaluator.

import 'package:flutter_test/flutter_test.dart';
import 'package:crisp_math/engine/date_time_evaluator.dart';

void main() {
  group('DateTimeEvaluator — date recognition', () {
    test('ISO date 2026-06-15', () {
      final r = DateTimeEvaluator.tryEvaluate('2026-06-15');
      expect(r, isNotNull);
      expect(r, contains('June'));
      expect(r, contains('2026'));
    });

    test('ISO date with slashes', () {
      final r = DateTimeEvaluator.tryEvaluate('2026/12/25');
      expect(r, isNotNull);
      expect(r, contains('December'));
    });

    test('today', () {
      final r = DateTimeEvaluator.tryEvaluate('today');
      expect(r, isNotNull);
      // Should contain the current year.
      final now = DateTime.now();
      expect(r, contains('${now.year}'));
    });

    test('tomorrow', () {
      final r = DateTimeEvaluator.tryEvaluate('tomorrow');
      expect(r, isNotNull);
    });

    test('yesterday', () {
      final r = DateTimeEvaluator.tryEvaluate('yesterday');
      expect(r, isNotNull);
    });
  });

  group('DateTimeEvaluator — date arithmetic', () {
    test('date + days', () {
      expect(
          DateTimeEvaluator.tryEvaluate('2026-01-01 + 10 days'), '2026-01-11');
    });

    test('date + weeks', () {
      expect(
          DateTimeEvaluator.tryEvaluate('2026-01-01 + 2 weeks'), '2026-01-15');
    });

    test('date + months', () {
      expect(
          DateTimeEvaluator.tryEvaluate('2026-01-15 + 3 months'), '2026-04-15');
    });

    test('date + years', () {
      expect(
          DateTimeEvaluator.tryEvaluate('2026-06-01 + 1 years'), '2027-06-01');
    });

    test('date - days', () {
      expect(
          DateTimeEvaluator.tryEvaluate('2026-01-11 - 10 days'), '2026-01-01');
    });

    test('date - weeks', () {
      expect(
          DateTimeEvaluator.tryEvaluate('2026-01-15 - 2 weeks'), '2026-01-01');
    });

    test('date - months', () {
      expect(
          DateTimeEvaluator.tryEvaluate('2026-04-15 - 3 months'), '2026-01-15');
    });

    test('date - years', () {
      expect(
          DateTimeEvaluator.tryEvaluate('2027-06-01 - 1 years'), '2026-06-01');
    });
  });

  group('DateTimeEvaluator — date subtraction', () {
    test('date - date', () {
      final r = DateTimeEvaluator.tryEvaluate('2026-12-31 - 2026-01-01');
      expect(r, '364 days');
    });

    test('today - today', () {
      expect(DateTimeEvaluator.tryEvaluate('today - today'), '0 days');
    });

    test('tomorrow - today', () {
      expect(DateTimeEvaluator.tryEvaluate('tomorrow - today'), '1 days');
    });

    test('days between', () {
      final r = DateTimeEvaluator.tryEvaluate(
          'days between 2026-03-01 and 2026-03-31');
      expect(r, '30 days');
    });

    test('days from to', () {
      final r =
          DateTimeEvaluator.tryEvaluate('days from 2026-06-01 to 2026-06-15');
      expect(r, '14 days');
    });

    test('date + days across a DST switch stays on the calendar day', () {
      // March 2026 crosses spring-forward in European timezones; local
      // DateTime math would land on 2026-03-30 23:00 → "2026-03-30".
      expect(
        DateTimeEvaluator.tryEvaluate('2026-03-01 + 30 days'),
        '2026-03-31',
      );
    });
  });

  group('DateTimeEvaluator — non-date fallthrough', () {
    test('plain number', () {
      expect(DateTimeEvaluator.tryEvaluate('42'), isNull);
    });

    test('arithmetic', () {
      expect(DateTimeEvaluator.tryEvaluate('2 + 3'), isNull);
    });

    test('function call', () {
      expect(DateTimeEvaluator.tryEvaluate('sin(x)'), isNull);
    });

    test('empty', () {
      expect(DateTimeEvaluator.tryEvaluate(''), isNull);
    });

    test('whitespace only', () {
      expect(DateTimeEvaluator.tryEvaluate('   '), isNull);
    });

    test('random text', () {
      expect(DateTimeEvaluator.tryEvaluate('hello world'), isNull);
    });
  });
}

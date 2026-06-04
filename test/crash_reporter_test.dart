import 'package:crisp_calc/services/crash_reporter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() => CrashReporter.instance.clear());

  group('CrashReporter', () {
    test('starts with no reports', () {
      expect(CrashReporter.instance.hasReports, isFalse);
      expect(CrashReporter.instance.count, 0);
      expect(CrashReporter.instance.reports, isEmpty);
    });

    test('recordZoneError adds a report', () {
      CrashReporter.instance.recordZoneError(
        Exception('test error'),
        StackTrace.current,
      );
      expect(CrashReporter.instance.hasReports, isTrue);
      expect(CrashReporter.instance.count, 1);
      expect(CrashReporter.instance.reports.first.source, 'zone');
      expect(
          CrashReporter.instance.reports.first.error, contains('test error'));
    });

    test('ring buffer caps at 20 reports', () {
      for (var i = 0; i < 25; i++) {
        CrashReporter.instance.recordZoneError(
          Exception('error $i'),
          StackTrace.current,
        );
      }
      expect(CrashReporter.instance.count, 20);
      // Oldest (0-4) dropped, newest (24) survives.
      expect(CrashReporter.instance.reports.first.error, contains('error 24'));
      expect(CrashReporter.instance.reports.last.error, contains('error 5'));
    });

    test('clear() removes all reports', () {
      CrashReporter.instance.recordZoneError(
        Exception('x'),
        StackTrace.current,
      );
      expect(CrashReporter.instance.hasReports, isTrue);
      CrashReporter.instance.clear();
      expect(CrashReporter.instance.hasReports, isFalse);
      expect(CrashReporter.instance.count, 0);
    });

    test('buildReportText includes header and report content', () {
      CrashReporter.instance.recordZoneError(
        Exception('sample'),
        StackTrace.current,
      );
      final text = CrashReporter.instance.buildReportText();
      expect(text, contains('CrispCalc Crash Report'));
      expect(text, contains('Reports: 1'));
      expect(text, contains('sample'));
      expect(text, contains('[zone]'));
    });

    test('reports are newest-first', () {
      CrashReporter.instance.recordZoneError(
        Exception('first'),
        StackTrace.current,
      );
      CrashReporter.instance.recordZoneError(
        Exception('second'),
        StackTrace.current,
      );
      final reports = CrashReporter.instance.reports;
      expect(reports[0].error, contains('second'));
      expect(reports[1].error, contains('first'));
    });
  });

  group('CrashReport', () {
    test('toReportString includes all fields', () {
      final r = CrashReport(
        timestamp: DateTime(2026, 6, 4, 12, 0),
        error: 'NullPointerException',
        stackTrace: '#0 main',
        source: 'flutter',
      );
      final s = r.toReportString();
      expect(s, contains('[flutter]'));
      expect(s, contains('2026-06-04'));
      expect(s, contains('NullPointerException'));
      expect(s, contains('#0 main'));
    });

    test('toReportString without stack trace', () {
      final r = CrashReport(
        timestamp: DateTime(2026, 6, 4),
        error: 'SomeError',
        source: 'zone',
      );
      final s = r.toReportString();
      expect(s, contains('SomeError'));
      expect(s, isNot(contains('null')));
    });
  });
}

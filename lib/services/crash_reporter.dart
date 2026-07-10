// lib/services/crash_reporter.dart
//
// Opt-in crash reporting. Collects Flutter framework errors and
// unhandled Dart exceptions, stores them in a ring buffer, and
// provides a "Send crash report" action that opens the user's email
// client with a pre-filled bug report. No data leaves the device
// without explicit user action.

import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Maximum number of crash reports kept in memory.
const int _kMaxReports = 20;

/// A single captured error event.
class CrashReport {
  final DateTime timestamp;
  final String error;
  final String? stackTrace;
  final String source; // 'flutter' or 'zone'

  CrashReport({
    required this.timestamp,
    required this.error,
    this.stackTrace,
    required this.source,
  });

  String toReportString() {
    final buf = StringBuffer();
    buf.writeln('[$source] ${timestamp.toIso8601String()}');
    buf.writeln(error);
    if (stackTrace != null && stackTrace!.isNotEmpty) {
      buf.writeln(stackTrace);
    }
    return buf.toString();
  }
}

/// App-wide crash collector. Call [install] once at startup to hook
/// into Flutter's error reporting. Errors are stored in [reports] and
/// can be sent via [launchEmailReport].
class CrashReporter {
  CrashReporter._();
  static final CrashReporter instance = CrashReporter._();

  final Queue<CrashReport> _reports = Queue();

  /// All captured reports, newest first.
  List<CrashReport> get reports => _reports.toList().reversed.toList();

  /// Whether any crashes have been captured since last clear.
  bool get hasReports => _reports.isNotEmpty;

  int get count => _reports.length;

  /// Hook into FlutterError.onError. Preserves the existing handler.
  /// Call once from main() before runApp.
  void install() {
    final previous = FlutterError.onError;
    FlutterError.onError = (details) {
      final msg = details.exception.toString();
      // Still swallow the known HardwareKeyboard false positive.
      if (msg.contains('physical key is already pressed') ||
          msg.contains('physical key is not pressed')) {
        return;
      }
      _add(CrashReport(
        timestamp: DateTime.now(),
        error: msg,
        stackTrace: details.stack?.toString(),
        source: 'flutter',
      ));
      previous?.call(details);
    };
  }

  /// Record an unhandled zone error (call from runZonedGuarded).
  void recordZoneError(Object error, StackTrace stack) {
    _add(CrashReport(
      timestamp: DateTime.now(),
      error: error.toString(),
      stackTrace: stack.toString(),
      source: 'zone',
    ));
  }

  void _add(CrashReport r) {
    _reports.addLast(r);
    while (_reports.length > _kMaxReports) {
      _reports.removeFirst();
    }
  }

  void clear() => _reports.clear();

  /// Build a text summary of all reports for email/issue body.
  String buildReportText() {
    final buf = StringBuffer();
    buf.writeln('CrispMath Crash Report');
    buf.writeln('Reports: ${_reports.length}');
    buf.writeln('Generated: ${DateTime.now().toIso8601String()}');
    buf.writeln('---');
    for (final r in reports) {
      buf.writeln(r.toReportString());
      buf.writeln('---');
    }
    return buf.toString();
  }

  /// Open the user's email client with a pre-filled crash report.
  Future<bool> launchEmailReport({
    String recipient = 'support@crispstrobe.com',
  }) async {
    final body = Uri.encodeComponent(buildReportText());
    final subject = Uri.encodeComponent(
        'CrispMath crash report (${_reports.length} errors)');
    final uri = Uri.parse('mailto:$recipient?subject=$subject&body=$body');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      return true;
    }
    return false;
  }

  /// Open a GitHub issue with the crash report.
  Future<bool> launchGitHubIssue() async {
    final body = Uri.encodeComponent(buildReportText());
    final title =
        Uri.encodeComponent('Crash report (${_reports.length} errors)');
    final uri = Uri.parse('https://github.com/CrispStrobe/CrispMath/issues/new'
        '?title=$title&body=$body&labels=bug');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return true;
    }
    return false;
  }
}

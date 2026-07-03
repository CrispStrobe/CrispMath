// lib/engine/date_time_evaluator.dart
//
// Notepad V2: date and time arithmetic.
//
// Recognizes ISO dates (2026-06-01), relative dates (today, tomorrow,
// yesterday), and durations (3 weeks, 2h30m, 45 min). Operations:
//
//   date2 - date1         → "N days" (integer difference)
//   date + duration       → resulting date (ISO format)
//   date - duration       → resulting date
//   duration + duration   → combined duration
//
// Returns null for expressions that don't match, so the caller can
// fall through to the normal engine.

class DateTimeEvaluator {
  /// Try to evaluate [input] as a date/time expression.
  /// Returns a result string or null if not a date/time expression.
  static String? tryEvaluate(String input) {
    final trimmed = input.trim();

    // --- "days between A and B" / "days from A to B" ---
    final betweenMatch = _daysBetweenRe.firstMatch(trimmed);
    if (betweenMatch != null) {
      final a = _parseDate(betweenMatch.group(1)!.trim());
      final b = _parseDate(betweenMatch.group(2)!.trim());
      if (a != null && b != null) {
        final diff = b.difference(a).inDays;
        return '$diff days';
      }
    }

    // --- date - date → days ---
    final subMatch = _dateSubRe.firstMatch(trimmed);
    if (subMatch != null) {
      final a = _parseDate(subMatch.group(1)!.trim());
      final b = _parseDate(subMatch.group(2)!.trim());
      if (a != null && b != null) {
        final diff = a.difference(b).inDays;
        return '$diff days';
      }
    }

    // --- date +/- duration → date ---
    final addMatch = _dateAddRe.firstMatch(trimmed);
    if (addMatch != null) {
      final date = _parseDate(addMatch.group(1)!.trim());
      final op = addMatch.group(2)!;
      final durStr = addMatch.group(3)!.trim();
      if (date != null) {
        // Try month/year offset first (can't express as Duration).
        final monthYear = _parseMonthYearOffset(durStr);
        if (monthYear != null) {
          final sign = op == '+' ? 1 : -1;
          final result = DateTime.utc(
            date.year + sign * monthYear.years,
            date.month + sign * monthYear.months,
            date.day,
          );
          return _formatDate(result);
        }
        final dur = _parseDuration(durStr);
        if (dur != null) {
          final result = op == '+' ? date.add(dur) : date.subtract(dur);
          return _formatDate(result);
        }
      }
    }

    // --- duration + duration ---
    final durAddMatch = _durAddRe.firstMatch(trimmed);
    if (durAddMatch != null) {
      final a = _parseDuration(durAddMatch.group(1)!.trim());
      final b = _parseDuration(durAddMatch.group(2)!.trim());
      if (a != null && b != null) {
        return _formatDuration(a + b);
      }
    }

    // --- bare date → formatted ---
    final bareDate = _parseDate(trimmed);
    if (bareDate != null && _looksLikeDateLiteral(trimmed)) {
      return _formatDateLong(bareDate);
    }

    return null;
  }

  // --- Date parsing ---

  static DateTime? _parseDate(String s) {
    final lower = s.toLowerCase();

    // Relative dates. All dates in this evaluator are built as UTC
    // midnights (local y/m/d, UTC construction): calendar-day math on
    // local DateTimes breaks across DST switches — a spring-forward
    // month is 23 hours short, so `days between 2026-03-01 and
    // 2026-03-31` truncated to 29 and `date + 30 days` could land on
    // the previous calendar day.
    final now = DateTime.now();
    final today = DateTime.utc(now.year, now.month, now.day);
    if (lower == 'today') return today;
    if (lower == 'tomorrow') return today.add(const Duration(days: 1));
    if (lower == 'yesterday') return today.subtract(const Duration(days: 1));

    // "N days/weeks/months/years from now" / "in N days"
    final fromNowMatch = _fromNowRe.firstMatch(lower);
    if (fromNowMatch != null) {
      final n = int.tryParse(fromNowMatch.group(1)!) ?? 0;
      final unit = fromNowMatch.group(2)!;
      return _addUnits(today, n, unit);
    }

    final inNMatch = _inNRe.firstMatch(lower);
    if (inNMatch != null) {
      final n = int.tryParse(inNMatch.group(1)!) ?? 0;
      final unit = inNMatch.group(2)!;
      return _addUnits(today, n, unit);
    }

    // "N days/weeks ago"
    final agoMatch = _agoRe.firstMatch(lower);
    if (agoMatch != null) {
      final n = int.tryParse(agoMatch.group(1)!) ?? 0;
      final unit = agoMatch.group(2)!;
      return _addUnits(today, -n, unit);
    }

    // ISO date: 2026-06-01 or 2026/06/01.
    final isoMatch = _isoDateRe.firstMatch(s);
    if (isoMatch != null) {
      final y = int.tryParse(isoMatch.group(1)!);
      final m = int.tryParse(isoMatch.group(2)!);
      final d = int.tryParse(isoMatch.group(3)!);
      if (y != null &&
          m != null &&
          d != null &&
          m >= 1 &&
          m <= 12 &&
          d >= 1 &&
          d <= 31) {
        return DateTime.utc(y, m, d);
      }
    }

    return null;
  }

  static DateTime _addUnits(DateTime base, int n, String unit) {
    if (unit.startsWith('day')) return base.add(Duration(days: n));
    if (unit.startsWith('week')) return base.add(Duration(days: n * 7));
    if (unit.startsWith('month')) {
      return DateTime.utc(base.year, base.month + n, base.day);
    }
    if (unit.startsWith('year')) {
      return DateTime.utc(base.year + n, base.month, base.day);
    }
    return base.add(Duration(days: n)); // fallback
  }

  static bool _looksLikeDateLiteral(String s) {
    return _isoDateRe.hasMatch(s) ||
        RegExp(r'^(today|tomorrow|yesterday)$', caseSensitive: false)
            .hasMatch(s.trim());
  }

  // --- Duration parsing ---

  static Duration? _parseDuration(String s) {
    final lower = s.toLowerCase().trim();

    // "N days/weeks/hours/minutes/seconds"
    final simpleMatch = _simpleDurRe.firstMatch(lower);
    if (simpleMatch != null) {
      final n = int.tryParse(simpleMatch.group(1)!) ?? 0;
      final unit = simpleMatch.group(2)!;
      return _durationFromUnit(n, unit);
    }

    // "NhMm" or "Nh Mm" compact format.
    final hmMatch = _hmDurRe.firstMatch(lower);
    if (hmMatch != null) {
      final h = int.tryParse(hmMatch.group(1)!) ?? 0;
      final m = int.tryParse(hmMatch.group(2)!) ?? 0;
      return Duration(hours: h, minutes: m);
    }

    return null;
  }

  static Duration? _durationFromUnit(int n, String unit) {
    if (unit.startsWith('day')) return Duration(days: n);
    if (unit.startsWith('week')) return Duration(days: n * 7);
    if (unit.startsWith('month')) return null; // Can't express as Duration.
    if (unit.startsWith('year')) return null;
    if (unit.startsWith('hour') || unit == 'h') return Duration(hours: n);
    if (unit.startsWith('min') || unit == 'm') return Duration(minutes: n);
    if (unit.startsWith('sec') || unit == 's') return Duration(seconds: n);
    return Duration(days: n);
  }

  // --- Formatting ---

  static String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static String _formatDateLong(DateTime d) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${weekdays[d.weekday - 1]}, ${d.day} ${months[d.month - 1]} ${d.year}';
  }

  static String _formatDuration(Duration d) {
    if (d.inDays > 0 && d.inHours % 24 == 0) return '${d.inDays} days';
    if (d.inHours > 0 && d.inMinutes % 60 == 0) return '${d.inHours} hours';
    if (d.inMinutes > 0) return '${d.inMinutes} minutes';
    return '${d.inSeconds} seconds';
  }

  // --- Patterns ---

  static final _isoDateRe = RegExp(r'^(\d{4})[/-](\d{1,2})[/-](\d{1,2})$');

  static final _daysBetweenRe = RegExp(
    r'days?\s+(?:between|from)\s+(.+?)\s+(?:and|to)\s+(.+)',
    caseSensitive: false,
  );

  // Match: <ISO date or keyword> - <ISO date or keyword>
  // Both sides must look like dates. Spaces around `-` required.
  static final _dateSubRe = RegExp(
    r'^(\d{4}[/-]\d{1,2}[/-]\d{1,2}|today|tomorrow|yesterday)\s+-\s+(\d{4}[/-]\d{1,2}[/-]\d{1,2}|today|tomorrow|yesterday)$',
    caseSensitive: false,
  );

  // Match: <ISO date or keyword> <+/-> <duration>
  // The date part must look like an ISO date or a keyword; the
  // operator must be surrounded by spaces to avoid matching the
  // hyphens inside an ISO date.
  static final _dateAddRe = RegExp(
    r'^(\d{4}[/-]\d{1,2}[/-]\d{1,2}|today|tomorrow|yesterday)\s+([+-])\s+(.+)$',
    caseSensitive: false,
  );

  static final _durAddRe = RegExp(
    r'^(.+?)\s*\+\s*(.+)$',
  );

  static final _fromNowRe = RegExp(
    r'(\d+)\s+(days?|weeks?|months?|years?)\s+from\s+now',
  );

  static final _inNRe = RegExp(
    r'in\s+(\d+)\s+(days?|weeks?|months?|years?)',
  );

  static final _agoRe = RegExp(
    r'(\d+)\s+(days?|weeks?|months?|years?)\s+ago',
  );

  static final _simpleDurRe = RegExp(
    r'^(\d+)\s*(days?|weeks?|months?|years?|hours?|minutes?|mins?|seconds?|secs?|h|m|s)$',
  );

  static final _hmDurRe = RegExp(r'^(\d+)h\s*(\d+)m$');

  /// Parse "N months" or "N years" as a structured offset (not a Duration).
  static ({int months, int years})? _parseMonthYearOffset(String s) {
    final lower = s.toLowerCase().trim();
    final match = RegExp(r'^(\d+)\s*(months?|years?)$').firstMatch(lower);
    if (match == null) return null;
    final n = int.tryParse(match.group(1)!) ?? 0;
    final unit = match.group(2)!;
    if (unit.startsWith('month')) return (months: n, years: 0);
    if (unit.startsWith('year')) return (months: 0, years: n);
    return null;
  }
}

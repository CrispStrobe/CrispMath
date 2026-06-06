import 'package:flutter_test/flutter_test.dart';
import 'package:crisp_calc/engine/app_state.dart';

void main() {
  group('CSV export helpers', () {
    test('csvEscape handles quotes', () {
      expect(_csvEscape('hello'), '"hello"');
      expect(_csvEscape('say "hi"'), '"say ""hi"""');
      expect(_csvEscape('a,b'), '"a,b"');
      expect(_csvEscape(''), '""');
    });

    test('CSV header row', () {
      final csv = _buildCsv([]);
      expect(csv, 'Expression,Result,Type\n');
    });

    test('CSV with entries', () {
      final entries = [
        CalculationEntry(expression: '2+2', result: '4'),
        CalculationEntry(
            expression: 'solve(x^2-1,x)',
            result: '{-1, 1}',
            type: HistoryEntryType.solve),
      ];
      final csv = _buildCsv(entries);
      final lines = csv.split('\n');
      expect(lines[0], 'Expression,Result,Type');
      expect(lines[1], '"2+2","4",calculation');
      expect(lines[2], '"solve(x^2-1,x)","{-1, 1}",solve');
    });

    test('CSV escapes double quotes in expressions', () {
      final entries = [
        CalculationEntry(expression: 'x "special"', result: 'ok'),
      ];
      final csv = _buildCsv(entries);
      expect(csv, contains('"x ""special"""'));
    });
  });
}

// Mirror the logic from export_data_dialog.dart for testing
String _buildCsv(List<CalculationEntry> entries) {
  final buf = StringBuffer('Expression,Result,Type\n');
  for (final e in entries) {
    buf.writeln(
        '${_csvEscape(e.expression)},${_csvEscape(e.result)},${e.type.name}');
  }
  return buf.toString();
}

String _csvEscape(String s) => '"${s.replaceAll('"', '""')}"';

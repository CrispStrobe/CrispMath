// Tests for the portable Calculator-history file codec.
//
// The history file is a *separate* portable artifact from the whole-state
// backup: one file = the user's calculation history only. Decoding is
// all-or-nothing so a bad file can never be applied to AppState partially.

import 'dart:convert';
import 'dart:typed_data';

import 'package:crisp_math/engine/app_state.dart';
import 'package:crisp_math/engine/result_evidence.dart';
import 'package:crisp_math/services/calculator_history_file.dart';
import 'package:flutter_test/flutter_test.dart';

Uint8List _bytes(Object? payload) =>
    Uint8List.fromList(utf8.encode(jsonEncode(payload)));

Map<String, dynamic> _entry({
  Object? expression = '1+1',
  Object? result = '2',
  Object? raw,
  Object? evidence,
  Object? type = 'calculation',
  Object? lastModified = '2026-10-30T10:00:00.000Z',
  bool includeRaw = false,
  bool includeEvidence = false,
  bool includeTimestamp = true,
  bool includeExpression = true,
  bool includeResult = true,
  bool includeType = true,
}) =>
    {
      if (includeExpression) 'e': expression,
      if (includeResult) 'r': result,
      if (includeRaw) 'raw': raw,
      if (includeEvidence) 'evidence': evidence,
      if (includeType) 't': type,
      if (includeTimestamp) 'lm': lastModified,
    };

Uint8List _file(List<Object?> entries,
        {Object? version = 1,
        Object? format = 'crispmath.calculatorHistory'}) =>
    _bytes({'format': format, 'version': version, 'entries': entries});

void main() {
  group('codec round trip', () {
    test('preserves order, raw precision, evidence and timestamps', () {
      final newest = CalculationEntry(
        expression: '8/3',
        result: '2.66666666667',
        rawResult: '2.6666666666666665',
        resultEvidence: const ResultEvidence(
            ResultAccuracy.exact, ComputationMethod.simplification),
        lastModified: DateTime.utc(2026, 10, 30, 12, 0, 0, 123, 456),
      );
      final oldest = CalculationEntry(
        expression: 'solve(x^2-4, x)',
        result: 'x = -2, 2',
        type: HistoryEntryType.solve,
        lastModified: DateTime.utc(2026, 1, 2, 3, 4, 5),
      );

      final decoded = CalculatorHistoryFile.decode(
          CalculatorHistoryFile.encode([newest, oldest]));

      expect(decoded, hasLength(2));
      // Order is file order; index 0 is the newest entry.
      expect(decoded[0].expression, '8/3');
      expect(decoded[0].result, '2.66666666667');
      expect(decoded[0].rawResult, '2.6666666666666665');
      expect(decoded[0].ansValue, '2.6666666666666665');
      expect(decoded[0].type, HistoryEntryType.calculation);
      expect(decoded[0].lastModified, newest.lastModified);
      expect(decoded[0].lastModified.isUtc, isTrue);
      expect(decoded[0].resultEvidence?.accuracy, ResultAccuracy.exact);
      expect(
          decoded[0].resultEvidence?.method, ComputationMethod.simplification);
      expect(decoded[0].resultEvidence?.unchanged, isFalse);
      expect(decoded[0].resultEvidence?.sourceDomain, isNull);

      expect(decoded[1].expression, 'solve(x^2-4, x)');
      expect(decoded[1].type, HistoryEntryType.solve);
      expect(decoded[1].rawResult, isNull);
      expect(decoded[1].resultEvidence, isNull);
      expect(decoded[1].lastModified, DateTime.utc(2026, 1, 2, 3, 4, 5));
    });

    test('round-trips an empty history', () {
      final decoded = CalculatorHistoryFile.decode(
          CalculatorHistoryFile.encode(const <CalculationEntry>[]));
      expect(decoded, isEmpty);
    });

    test('round-trips optional evidence fields', () {
      final entry = CalculationEntry(
        expression: '2+2',
        result: '4',
        resultEvidence: const ResultEvidence(
            ResultAccuracy.approximate, ComputationMethod.numericFallback,
            unchanged: true, sourceDomain: 'units'),
      );
      final decoded = CalculatorHistoryFile.decode(
          CalculatorHistoryFile.encode([entry])).single;
      expect(decoded.resultEvidence?.unchanged, isTrue);
      expect(decoded.resultEvidence?.sourceDomain, 'units');
    });

    test('encode refuses more than the history cap instead of truncating', () {
      final entries = List<CalculationEntry>.generate(
        201,
        (i) => CalculationEntry(expression: 'n=$i', result: '$i'),
      );
      expect(() => CalculatorHistoryFile.encode(entries),
          throwsA(isA<ArgumentError>()));
    });

    test('encode refuses an entry field it would have to truncate', () {
      final entries = [
        CalculationEntry(
          expression: 'x' * (CalculatorHistoryFile.maxFieldLength + 1),
          result: '1',
        ),
      ];
      expect(() => CalculatorHistoryFile.encode(entries),
          throwsA(isA<ArgumentError>()));
    });

    test('accepts exactly the cap of 200 entries and keeps file order', () {
      final entries = List<CalculationEntry>.generate(
        200,
        (i) => CalculationEntry(
          expression: 'n=$i',
          result: '$i',
          lastModified: DateTime.utc(2026, 1, 1).add(Duration(minutes: i)),
        ),
      );
      final decoded =
          CalculatorHistoryFile.decode(CalculatorHistoryFile.encode(entries));
      expect(decoded, hasLength(200));
      expect(decoded.first.expression, 'n=0');
      expect(decoded.last.expression, 'n=199');
    });

    test('file name uses the history extension', () {
      final name = CalculatorHistoryFile.fileName();
      expect(name, endsWith('.crisphistory'));
      expect(name, isNot(contains('/')));
    });
  });

  group('decode rejects invalid files', () {
    Object? errorFor(Uint8List bytes) {
      try {
        CalculatorHistoryFile.decode(bytes);
        return null;
      } catch (error) {
        return error;
      }
    }

    test('rejects a payload that is not a history file', () {
      expect(errorFor(_bytes('not json')), isA<FormatException>());
      expect(errorFor(_bytes([1, 2, 3])), isA<FormatException>());
      expect(errorFor(_file([_entry()], format: 'crispmath.worksheet')),
          isA<FormatException>());
      expect(errorFor(_bytes({'format': 'crispmath.calculatorHistory'})),
          isA<FormatException>());
      expect(
          errorFor(_bytes(
              {'format': 'crispmath.calculatorHistory', 'version': 1})),
          isA<FormatException>());
      expect(
          errorFor(_bytes({
            'format': 'crispmath.calculatorHistory',
            'version': 1,
            'entries': 'nope',
          })),
          isA<FormatException>());
      expect(
          errorFor(_bytes({
            'format': 'crispmath.calculatorHistory',
            'version': 1,
            'entries': [],
            'extra': true,
          })),
          isA<FormatException>());
    });

    test('rejects unsupported versions', () {
      for (final version in [0, 2, 99, '1', 1.5, true, null]) {
        expect(errorFor(_file([_entry()], version: version)),
            isA<FormatException>(),
            reason: 'version $version should be rejected');
      }
    });

    test('rejects more than 200 entries without truncating', () {
      final entries = List<Object?>.generate(
          201, (i) => _entry(expression: 'n=$i', result: '$i'));
      final error = errorFor(_file(entries));
      expect(error, isA<FormatException>());
      expect((error! as FormatException).message, contains('200'));
    });

    test('rejects malformed entry fields', () {
      final cases = <String, Object?>{
        'missing expression': _entry(includeExpression: false),
        'numeric expression': _entry(expression: 42),
        'missing result': _entry(includeResult: false),
        'null result': _entry(result: null),
        'unknown type': _entry(type: 'integral'),
        'missing type': _entry(includeType: false),
        'missing timestamp': _entry(includeTimestamp: false),
        'unparseable timestamp': _entry(lastModified: 'yesterday'),
        'numeric timestamp': _entry(lastModified: 1761828000000),
        'timestamp out of range':
            _entry(lastModified: '1066-01-01T00:00:00.000Z'),
        'raw not a string': _entry(includeRaw: true, raw: 2.5),
        'evidence not a map': _entry(includeEvidence: true, evidence: 'exact'),
        'evidence unknown accuracy': _entry(
            includeEvidence: true,
            evidence: {'accuracy': 'probably', 'method': 'simplification'}),
        'evidence missing method': _entry(
            includeEvidence: true, evidence: {'accuracy': 'exact'}),
        'evidence bad sourceDomain': _entry(
            includeEvidence: true,
            evidence: {
              'accuracy': 'exact',
              'method': 'simplification',
              'sourceDomain': 7,
            }),
        'unknown entry key': {..._entry(), 'resultEvidence': 'x'},
        'entry is not an object': 'nope',
      };
      cases.forEach((label, entry) {
        expect(errorFor(_file([_entry(), entry])), isA<FormatException>(),
            reason: 'case "$label" should be rejected');
      });
    });

    test('rejects oversized bytes before parsing', () {
      final oversized = Uint8List(CalculatorHistoryFile.maxBytes + 1);
      // Not valid JSON at all: the size check has to fire first.
      final error = errorFor(oversized);
      expect(error, isA<FormatException>());
      expect((error! as FormatException).message, contains('limit'));
    });

    test('rejects field values above the length limit', () {
      final long = 'x' * (CalculatorHistoryFile.maxFieldLength + 1);
      expect(
          errorFor(_file([_entry(expression: long)])), isA<FormatException>());
      expect(errorFor(_file([_entry(result: long)])), isA<FormatException>());
      expect(errorFor(_file([_entry(includeRaw: true, raw: long)])),
          isA<FormatException>());
    });

    test('rejects invalid UTF-8', () {
      expect(errorFor(Uint8List.fromList([0xff, 0xfe, 0xfd])),
          isA<FormatException>());
    });
  });
}

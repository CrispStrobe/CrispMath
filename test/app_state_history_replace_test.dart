// Tests for AppState.replaceHistory — the only supported way to apply an
// imported Calculator-history file. Replacing must be exact, persisted before
// the returned future completes, and it must not touch unrelated state.

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:crisp_math/engine/app_state.dart';
import 'package:crisp_math/engine/result_evidence.dart';
import 'package:crisp_math/services/calculator_history_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
// The fake exercises the actual platform persistence boundary.
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

class _HistoryStore extends SharedPreferencesStorePlatform {
  _HistoryStore(this.delegate);

  final SharedPreferencesStorePlatform delegate;
  Completer<bool>? nextResult;
  Completer<void>? started;
  bool failHistoryWrites = false;
  final historyWrites = <String>[];

  @override
  Future<bool> setValue(String valueType, String key, Object value) async {
    if (key == 'flutter.crisp.history') historyWrites.add(value as String);
    if (key == 'flutter.crisp.history' && nextResult != null) {
      final result = nextResult!;
      nextResult = null;
      started?.complete();
      if (!await result.future) return false;
    }
    if (key == 'flutter.crisp.history' && failHistoryWrites) return false;
    return delegate.setValue(valueType, key, value);
  }

  @override
  Future<Map<String, Object>> getAll() => delegate.getAll();
  @override
  Future<bool> remove(String key) => delegate.remove(key);
  @override
  Future<bool> clear() => delegate.clear();
}

CalculationEntry _entry(
  String expression,
  String result, {
  String? raw,
  HistoryEntryType type = HistoryEntryType.calculation,
  DateTime? lastModified,
  ResultEvidence? evidence,
}) =>
    CalculationEntry(
      expression: expression,
      result: result,
      rawResult: raw,
      type: type,
      lastModified: lastModified,
      resultEvidence: evidence,
    );

List<Map<String, dynamic>> _storedHistory(SharedPreferences prefs) =>
    (jsonDecode(prefs.getString('crisp.history') ?? '[]') as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

void main() {
  setUp(() {
    final s = AppState();
    s.history.clear();
    s.userVariables.clear();
    for (var i = 0; i < s.graphFunctions.length; i++) {
      s.graphFunctions[i] = '';
    }
  });

  test('failed replacement preserves history and cannot leak into later writes',
      () async {
    SharedPreferences.setMockInitialValues({});
    final s = AppState();
    await s.load(force: true);
    await s.replaceHistory([_entry('old', '1')]);
    final store = _HistoryStore(SharedPreferencesStorePlatform.instance);
    SharedPreferencesStorePlatform.instance = store;
    addTearDown(() => SharedPreferencesStorePlatform.instance = store.delegate);
    store.nextResult = Completer<bool>();
    store.started = Completer<void>();
    final result = store.nextResult!;

    final replacement = s.replaceHistory([_entry('imported', '2')]);
    final failure = expectLater(replacement, throwsStateError);
    await store.started!.future;
    result.complete(false);
    await failure;

    expect(s.history.map((e) => e.expression), ['old']);
    expect(_storedHistory(await SharedPreferences.getInstance()).map((e) => e['e']),
        ['old']);
    s.addHistoryEntry('new', '3');
    await Future<void>.delayed(Duration.zero);
    await s.flushPersistence();
    final backend = await store.getAll();
    final stored = jsonDecode(backend['flutter.crisp.history'] as String) as List;
    expect(stored.map((e) => e['e']), ['new', 'old']);
  });

  test('failed pending replacement preserves concurrent addition on disk',
      () async {
    SharedPreferences.setMockInitialValues({});
    final s = AppState();
    await s.load(force: true);
    await s.replaceHistory([_entry('old', '1')]);
    final store = _HistoryStore(SharedPreferencesStorePlatform.instance);
    SharedPreferencesStorePlatform.instance = store;
    addTearDown(() => SharedPreferencesStorePlatform.instance = store.delegate);
    store.nextResult = Completer<bool>();
    store.started = Completer<void>();
    final result = store.nextResult!;
    final replacement = s.replaceHistory([_entry('imported', '2')]);
    final failure = expectLater(replacement, throwsStateError);
    await store.started!.future;
    s.addHistoryEntry('new', '3');
    await Future<void>.delayed(Duration.zero);
    result.complete(false);
    await failure;
    await s.flushPersistence();
    expect(s.history.map((e) => e.expression), ['new', 'old']);
    final backend = await store.getAll();
    final stored = jsonDecode(backend['flutter.crisp.history'] as String) as List;
    expect(stored.map((e) => e['e']), ['new', 'old']);
    await s.load(force: true);
    expect(s.history.map((e) => e.expression), ['new', 'old']);
  });

  test('replacement fails if persisting a concurrent edit fails', () async {
    SharedPreferences.setMockInitialValues({});
    final s = AppState();
    await s.load(force: true);
    await s.replaceHistory([_entry('old', '1')]);
    final store = _HistoryStore(SharedPreferencesStorePlatform.instance);
    SharedPreferencesStorePlatform.instance = store;
    addTearDown(() => SharedPreferencesStorePlatform.instance = store.delegate);
    final first = Completer<bool>();
    store.nextResult = first;
    store.started = Completer<void>();
    var completed = false;
    final replacement = s.replaceHistory([_entry('imported', '2')]).then(
      (_) {
        completed = true;
        return true;
      },
      onError: (Object _) {
        completed = true;
        return false;
      },
    );
    await store.started!.future;
    s.addHistoryEntry('new', '3');
    await Future<void>.delayed(Duration.zero);
    final second = Completer<bool>();
    store.nextResult = second;
    store.started = Completer<void>();
    first.complete(true);
    await store.started!.future;
    s.addHistoryEntry('newer', '4');
    await Future<void>.delayed(Duration.zero);
    final completedBeforeSecondWrite = completed;
    second.complete(false);
    final success = await replacement;
    await s.flushPersistence();
    expect(completedBeforeSecondWrite, isFalse);
    expect(success, isFalse);
    expect(s.history.map((e) => e.expression), ['newer', 'new', 'old']);
    final backend = await store.getAll();
    final stored = jsonDecode(backend['flutter.crisp.history'] as String) as List;
    expect(stored.map((e) => e['e']), ['newer', 'new', 'old']);
    await s.load(force: true);
    expect(s.history.map((e) => e.expression), ['newer', 'new', 'old']);
  });

  test('failed queued replacement does not replay pre-snapshot edits twice',
      () async {
    SharedPreferences.setMockInitialValues({});
    final s = AppState();
    await s.load(force: true);
    final old = List.generate(197, (i) => _entry('old-$i', '$i'));
    await s.replaceHistory(old);
    final store = _HistoryStore(SharedPreferencesStorePlatform.instance);
    SharedPreferencesStorePlatform.instance = store;
    addTearDown(() => SharedPreferencesStorePlatform.instance = store.delegate);

    final blockingWrite = Completer<bool>();
    store.nextResult = blockingWrite;
    store.started = Completer<void>();
    s.addHistoryEntry('blocker', '1');
    await store.started!.future;

    final listenerWrite = Completer<bool>();
    final listenerStarted = Completer<void>();
    var listenerEdited = false;
    final channel = s.changesFor(AppStateDomain.history);
    void onHistory() {
      if (!listenerEdited && s.history.any((e) => e.expression == 'imported')) {
        listenerEdited = true;
        store.nextResult = listenerWrite;
        store.started = listenerStarted;
        s.addHistoryEntry('late', '3');
      }
    }
    channel.addListener(onHistory);
    addTearDown(() => channel.removeListener(onHistory));

    final replacement = s.replaceHistory([_entry('imported', '2')]);
    final failure = expectLater(replacement, throwsStateError);
    s.addHistoryEntry('early', '2');
    blockingWrite.complete(true);
    await listenerStarted.future;
    expect(listenerEdited, isTrue);
    expect(s.history.map((e) => e.expression), ['late', 'early', 'imported']);
    listenerWrite.complete(false);
    await failure;

    final expected = [
      'late',
      'early',
      'blocker',
      ...old.map((e) => e.expression),
    ];
    expect(expected, hasLength(AppState.historyCap));
    expect(s.history.map((e) => e.expression), expected);
    final backend = await store.getAll();
    final stored = jsonDecode(backend['flutter.crisp.history'] as String) as List;
    expect(stored.map((e) => e['e']), expected);
    await s.flushPersistence();
    await s.load(force: true);
    expect(s.history.map((e) => e.expression), expected);
  });

  test('persistent backend failure keeps edits in memory and permits retry',
      () async {
    SharedPreferences.setMockInitialValues({});
    final s = AppState();
    await s.load(force: true);
    await s.replaceHistory([_entry('old', '1')]);
    final store = _HistoryStore(SharedPreferencesStorePlatform.instance);
    SharedPreferencesStorePlatform.instance = store;
    addTearDown(() => SharedPreferencesStorePlatform.instance = store.delegate);
    final first = Completer<bool>();
    store.nextResult = first;
    store.started = Completer<void>();
    final replacement = s.replaceHistory([_entry('imported', '2')]);
    final failure = expectLater(replacement, throwsStateError);
    await store.started!.future;
    s.addHistoryEntry('new', '3');
    final second = Completer<bool>();
    store.nextResult = second;
    store.started = Completer<void>();
    first.complete(true);
    await store.started!.future;
    store.failHistoryWrites = true;
    second.complete(false);
    await failure;
    await s.flushPersistence();
    expect(s.history.map((e) => e.expression), ['new', 'old']);
    final failedBackend = await store.getAll();
    final failedStored =
        jsonDecode(failedBackend['flutter.crisp.history'] as String) as List;
    expect(failedStored.map((e) => e['e']), ['imported']);
    store.failHistoryWrites = false;
    s.addHistoryEntry('retry', '4');
    await s.flushPersistence();
    final backend = await store.getAll();
    final stored = jsonDecode(backend['flutter.crisp.history'] as String) as List;
    expect(stored.map((e) => e['e']), ['retry', 'new', 'old']);
  });

  test('successful pending replacement replays concurrent addition', () async {
    SharedPreferences.setMockInitialValues({});
    final s = AppState();
    await s.load(force: true);
    await s.replaceHistory([_entry('old', '1')]);
    final store = _HistoryStore(SharedPreferencesStorePlatform.instance);
    SharedPreferencesStorePlatform.instance = store;
    addTearDown(() => SharedPreferencesStorePlatform.instance = store.delegate);
    store.nextResult = Completer<bool>();
    store.started = Completer<void>();
    final result = store.nextResult!;
    final replacement = s.replaceHistory([_entry('imported', '2')]);
    await store.started!.future;
    s.addHistoryEntry('new', '3');
    expect(s.history.map((e) => e.expression), ['new', 'old']);
    await Future<void>.delayed(Duration.zero);
    result.complete(true);
    await replacement;
    await s.flushPersistence();
    expect(s.history.map((e) => e.expression), ['new', 'imported']);
    final backend = await store.getAll();
    final stored = jsonDecode(backend['flutter.crisp.history'] as String) as List;
    expect(stored.map((e) => e['e']), ['new', 'imported']);
  });

  test('rapid edits across successive replacement writes are durable', () async {
    SharedPreferences.setMockInitialValues({});
    final s = AppState();
    await s.load(force: true);
    await s.replaceHistory([_entry('old', '1')]);
    final store = _HistoryStore(SharedPreferencesStorePlatform.instance);
    SharedPreferencesStorePlatform.instance = store;
    addTearDown(() => SharedPreferencesStorePlatform.instance = store.delegate);
    final first = Completer<bool>();
    store.nextResult = first;
    store.started = Completer<void>();
    var completed = false;
    final replacement = s.replaceHistory([_entry('imported', '2')])
        .then((_) => completed = true);
    await store.started!.future;
    s.addHistoryEntry('early', '3');
    final second = Completer<bool>();
    store.nextResult = second;
    store.started = Completer<void>();
    first.complete(true);
    await store.started!.future;
    s.addHistoryEntry('before-clear', '4');
    s.clearHistory();
    s.addHistoryEntry('after-clear', '5');
    s.addHistoryEntry('latest', '6');
    final third = Completer<bool>();
    store.nextResult = third;
    store.started = Completer<void>();
    second.complete(true);
    await store.started!.future;
    await Future<void>.delayed(Duration.zero);
    final completedBeforeFinalWrite = completed;
    third.complete(true);
    await replacement;
    expect(completedBeforeFinalWrite, isFalse);
    expect(s.history.map((e) => e.expression), ['latest', 'after-clear']);
    final backend = await store.getAll();
    final stored = jsonDecode(backend['flutter.crisp.history'] as String) as List;
    expect(stored.map((e) => e['e']), ['latest', 'after-clear']);
    await s.flushPersistence();
    await s.load(force: true);
    expect(s.history.map((e) => e.expression), ['latest', 'after-clear']);
  });

  test('clear during a pending replacement wins over the import', () async {
    SharedPreferences.setMockInitialValues({});
    final s = AppState();
    await s.load(force: true);
    await s.replaceHistory([_entry('old', '1')]);
    final store = _HistoryStore(SharedPreferencesStorePlatform.instance);
    SharedPreferencesStorePlatform.instance = store;
    addTearDown(() => SharedPreferencesStorePlatform.instance = store.delegate);
    store.nextResult = Completer<bool>();
    store.started = Completer<void>();
    final result = store.nextResult!;
    final replacement = s.replaceHistory([_entry('imported', '2')]);
    await store.started!.future;
    s.clearHistory();
    s.addHistoryEntry('after-clear', '3');
    await Future<void>.delayed(Duration.zero);
    result.complete(true);
    await replacement;
    await s.flushPersistence();
    expect(s.history.map((e) => e.expression), ['after-clear']);
    final backend = await store.getAll();
    final stored = jsonDecode(backend['flutter.crisp.history'] as String) as List;
    expect(stored.map((e) => e['e']), ['after-clear']);
  });

  test('thrown backend error rolls back before a later replacement', () async {
    SharedPreferences.setMockInitialValues({});
    final s = AppState();
    await s.load(force: true);
    await s.replaceHistory([_entry('old', '1')]);
    final store = _HistoryStore(SharedPreferencesStorePlatform.instance);
    SharedPreferencesStorePlatform.instance = store;
    addTearDown(() => SharedPreferencesStorePlatform.instance = store.delegate);
    store.nextResult = Completer<bool>();
    store.started = Completer<void>();
    final result = store.nextResult!;
    final first = s.replaceHistory([_entry('failed', '2')]);
    final failure = expectLater(first, throwsA(isA<Exception>()));
    await store.started!.future;
    s.addHistoryEntry('before-second', '3');
    final second = s.replaceHistory([_entry('second', '4')]);
    s.addHistoryEntry('after-second', '5');
    await Future<void>.delayed(Duration.zero);
    result.completeError(Exception('platform failure'));
    await failure;
    await second;
    await s.flushPersistence();
    expect(s.history.map((e) => e.expression), ['after-second', 'second']);
    final backend = await store.getAll();
    final stored = jsonDecode(backend['flutter.crisp.history'] as String) as List;
    expect(stored.map((e) => e['e']), ['after-second', 'second']);
  });

  test('whole-state history import during pending replacement is not lost',
      () async {
    SharedPreferences.setMockInitialValues({});
    final s = AppState();
    await s.load(force: true);
    await s.replaceHistory([_entry('old', '1')]);
    final store = _HistoryStore(SharedPreferencesStorePlatform.instance);
    SharedPreferencesStorePlatform.instance = store;
    addTearDown(() => SharedPreferencesStorePlatform.instance = store.delegate);
    store.nextResult = Completer<bool>();
    store.started = Completer<void>();
    final result = store.nextResult!;
    final replacement = s.replaceHistory([_entry('first', '2')]);
    await store.started!.future;
    s.importFromJson({
      'history': [_entry('later', '3').toJson()]
    });
    result.complete(true);
    await replacement;
    await s.flushPersistence();
    expect(s.history.map((e) => e.expression), ['later']);
    final backend = await store.getAll();
    final stored = jsonDecode(backend['flutter.crisp.history'] as String) as List;
    expect(stored.map((e) => e['e']), ['later']);
  });

  test('whole-state merge during pending replacement merges against it',
      () async {
    SharedPreferences.setMockInitialValues({});
    final s = AppState();
    await s.load(force: true);
    await s.replaceHistory([_entry('old', '1')]);
    final store = _HistoryStore(SharedPreferencesStorePlatform.instance);
    SharedPreferencesStorePlatform.instance = store;
    addTearDown(() => SharedPreferencesStorePlatform.instance = store.delegate);
    store.nextResult = Completer<bool>();
    store.started = Completer<void>();
    final result = store.nextResult!;
    final replacement = s.replaceHistory([
      _entry('first', '2', lastModified: DateTime.utc(2026, 1, 1))
    ]);
    await store.started!.future;
    s.importFromJson({
      'history': [
        _entry('later', '3', lastModified: DateTime.utc(2026, 2, 1)).toJson()
      ]
    }, merge: true);
    result.complete(true);
    await replacement;
    await s.flushPersistence();
    expect(s.history.map((e) => e.expression), ['later', 'first']);
    final backend = await store.getAll();
    final stored = jsonDecode(backend['flutter.crisp.history'] as String) as List;
    expect(stored.map((e) => e['e']), ['later', 'first']);
  });

  test('flush waits for a just-scheduled history addition', () async {
    SharedPreferences.setMockInitialValues({});
    final s = AppState();
    await s.load(force: true);
    await s.replaceHistory([_entry('old', '1')]);
    final store = _HistoryStore(SharedPreferencesStorePlatform.instance);
    SharedPreferencesStorePlatform.instance = store;
    addTearDown(() => SharedPreferencesStorePlatform.instance = store.delegate);
    store.nextResult = Completer<bool>();
    store.started = Completer<void>();
    final result = store.nextResult!;
    s.addHistoryEntry('new', '2');
    var flushed = false;
    final flush = s.flushPersistence().then((_) => flushed = true);
    await store.started!.future;
    await Future<void>.delayed(Duration.zero);
    expect(flushed, isFalse);
    result.complete(true);
    await flush;
    final backend = await store.getAll();
    final stored = jsonDecode(backend['flutter.crisp.history'] as String) as List;
    expect(stored.map((e) => e['e']), ['new', 'old']);
  });

  test('an older pending calculation writes before a replacement', () async {
    SharedPreferences.setMockInitialValues({});
    final s = AppState();
    await s.load(force: true);
    await s.replaceHistory([_entry('old', '1')]);
    final store = _HistoryStore(SharedPreferencesStorePlatform.instance);
    SharedPreferencesStorePlatform.instance = store;
    addTearDown(() => SharedPreferencesStorePlatform.instance = store.delegate);
    store.nextResult = Completer<bool>();
    store.started = Completer<void>();
    final result = store.nextResult!;
    s.addHistoryEntry('calculation', '2');
    await store.started!.future;
    final replacement = s.replaceHistory([_entry('imported', '3')]);
    await Future<void>.delayed(Duration.zero);
    expect(store.historyWrites, hasLength(1));
    result.complete(true);
    await replacement;
    await s.flushPersistence();
    expect(store.historyWrites.map((write) =>
        (jsonDecode(write) as List).map((e) => e['e']).toList()), [
      ['calculation', 'old'],
      ['imported']
    ]);
    final backend = await store.getAll();
    final stored = jsonDecode(backend['flutter.crisp.history'] as String) as List;
    expect(stored.map((e) => e['e']), ['imported']);
    expect(s.history.map((e) => e.expression), ['imported']);
  });

  test('history cap shared with the file format', () {
    // The file format must be able to carry exactly one full history.
    expect(AppState.historyCap, CalculatorHistoryFile.maxEntries);
  });

  test('replaces an existing history exactly and persists it', () async {
    SharedPreferences.setMockInitialValues({});
    final s = AppState();
    await s.load(force: true);
    s.addHistoryEntry('old+1', '1');
    s.addHistoryEntry('old+2', '2');
    expect(s.history, hasLength(2));

    final imported = [
      _entry('8/3', '2.66666666667',
          raw: '2.6666666666666665',
          evidence: const ResultEvidence(
              ResultAccuracy.approximate, ComputationMethod.numericFallback),
          lastModified: DateTime.utc(2026, 10, 30, 12)),
      _entry('solve(x^2-4, x)', 'x = -2, 2',
          type: HistoryEntryType.solve,
          lastModified: DateTime.utc(2026, 10, 29, 8)),
    ];

    await s.replaceHistory(imported);

    // Memory: exactly the imported list, in file order, no leftovers.
    expect(s.history.map((e) => e.expression), ['8/3', 'solve(x^2-4, x)']);
    expect(s.history.first.resultEvidence?.accuracy, ResultAccuracy.approximate);
    expect(s.history.last.type, HistoryEntryType.solve);
    expect(s.history.last.lastModified, DateTime.utc(2026, 10, 29, 8));

    // Disk: already written when the future completes (awaited, not deferred).
    final prefs = await SharedPreferences.getInstance();
    final stored = _storedHistory(prefs);
    expect(stored.map((e) => e['e']), ['8/3', 'solve(x^2-4, x)']);
    expect(stored.first['raw'], '2.6666666666666665');
    expect(stored.first['evidence'],
        {'accuracy': 'approximate', 'method': 'numericFallback'});
    expect(stored.first['lm'], '2026-10-30T12:00:00.000Z');
  });

  test('reload after replaceHistory restores the same entries', () async {
    SharedPreferences.setMockInitialValues({});
    final s = AppState();
    await s.load(force: true);

    final imported = [
      _entry('2+2', '4', lastModified: DateTime.utc(2026, 5, 1)),
      _entry('3*3', '9', lastModified: DateTime.utc(2026, 4, 1)),
    ];
    await s.replaceHistory(imported);

    s.history.clear(); // simulate a relaunch losing memory
    await s.load(force: true);

    expect(s.history.map((e) => e.expression), ['2+2', '3*3']);
    expect(s.history.first.lastModified, DateTime.utc(2026, 5, 1));
  });

  test('preserves Ans full precision through file and persistence', () async {
    SharedPreferences.setMockInitialValues({});
    final s = AppState();
    await s.load(force: true);

    final source = _entry('8/3', '2.66666666667',
        raw: '2.6666666666666665',
        lastModified: DateTime.utc(2026, 10, 30, 10));
    final roundTripped =
        CalculatorHistoryFile.decode(CalculatorHistoryFile.encode([source]));
    expect(roundTripped.single.ansValue, '2.6666666666666665');

    await s.replaceHistory(roundTripped);
    expect(s.history.single.result, '2.66666666667');
    expect(s.history.single.rawResult, '2.6666666666666665');
    expect(s.history.single.ansValue, '2.6666666666666665');

    // Still full precision after a reload from prefs.
    await s.load(force: true);
    expect(s.history.single.result, '2.66666666667');
    expect(s.history.single.ansValue, '2.6666666666666665');
  });

  test('rejects more than the cap without mutating anything', () async {
    SharedPreferences.setMockInitialValues({});
    final s = AppState();
    await s.load(force: true);
    s.addHistoryEntry('keep', '1');
    final before = (await SharedPreferences.getInstance())
        .getString('crisp.history');

    final tooMany =
        List<CalculationEntry>.generate(201, (i) => _entry('n=$i', '$i'));

    await expectLater(s.replaceHistory(tooMany), throwsA(isA<ArgumentError>()));

    expect(s.history.map((e) => e.expression), ['keep']);
    expect((await SharedPreferences.getInstance()).getString('crisp.history'),
        before);
  });

  test('an invalid imported file leaves the current history untouched',
      () async {
    SharedPreferences.setMockInitialValues({});
    final s = AppState();
    await s.load(force: true);
    s.addHistoryEntry('keep', '1');
    final before =
        (await SharedPreferences.getInstance()).getString('crisp.history');

    // A structurally valid file whose entry carries an unknown field.
    final valid = CalculatorHistoryFile.encode([_entry('ok', '1')]);
    final corrupted = Uint8List.fromList(
        utf8.encode(utf8.decode(valid).replaceFirst('"t"', '"type"')));
    expect(() => CalculatorHistoryFile.decode(corrupted),
        throwsA(isA<FormatException>()));

    // Caller pattern: decode first, replace only with a fully valid list.
    List<CalculationEntry>? decoded;
    try {
      decoded = CalculatorHistoryFile.decode(corrupted);
    } on FormatException {
      decoded = null;
    }
    if (decoded != null) await s.replaceHistory(decoded);

    expect(decoded, isNull);
    expect(s.history.map((e) => e.expression), ['keep']);
    expect((await SharedPreferences.getInstance()).getString('crisp.history'),
        before);
  });

  test('notifies history listeners once and touches no unrelated state',
      () async {
    SharedPreferences.setMockInitialValues({});
    final s = AppState();
    await s.load(force: true);
    s.setLocale(const Locale('de'));
    s.setVariable('a', '5');
    s.updateFunction(0, 'cos(x)');
    s.setThemeMode(ThemeMode.light);

    var historyNotifications = 0;
    var settingsNotifications = 0;
    var allNotifications = 0;
    void onHistory() => historyNotifications++;
    void onSettings() => settingsNotifications++;
    void onAny() => allNotifications++;
    final historyChanges = s.changesFor(AppStateDomain.history);
    final settingsChanges = s.changesFor(AppStateDomain.settings);
    historyChanges.addListener(onHistory);
    settingsChanges.addListener(onSettings);
    s.addListener(onAny);
    addTearDown(() {
      historyChanges.removeListener(onHistory);
      settingsChanges.removeListener(onSettings);
      s.removeListener(onAny);
    });

    await s.replaceHistory([_entry('9*9', '81')]);

    expect(historyNotifications, 1);
    expect(settingsNotifications, 0);
    expect(allNotifications, 1);

    // Unrelated state is untouched.
    expect(s.locale.languageCode, 'de');
    expect(s.getVariable('a'), '5');
    expect(s.getGraphFunction(0), 'cos(x)');
    expect(s.themeMode, ThemeMode.light);
  });

  test('listeners see the replaced list before the future completes', () async {
    SharedPreferences.setMockInitialValues({});
    final s = AppState();
    await s.load(force: true);

    List<String>? seenAtNotify;
    void onHistory() =>
        seenAtNotify = s.history.map((e) => e.expression).toList();
    final channel = s.changesFor(AppStateDomain.history);
    channel.addListener(onHistory);
    addTearDown(() => channel.removeListener(onHistory));

    await s.replaceHistory([_entry('first', '1')]);

    expect(seenAtNotify, ['first']);
  });

  test('overlapping replacements persist in call order', () async {
    SharedPreferences.setMockInitialValues({});
    final s = AppState();
    await s.load(force: true);

    final first = s.replaceHistory([_entry('a', '1')]);
    final second = s.replaceHistory([_entry('b', '2')]);
    await Future.wait([first, second]);

    final prefs = await SharedPreferences.getInstance();
    expect(_storedHistory(prefs).map((e) => e['e']), ['b']);
    expect(s.history.map((e) => e.expression), ['b']);
  });

  test('replaceHistory before load() still updates memory and notifies',
      () async {
    SharedPreferences.setMockInitialValues({});
    final s = AppState();
    // No load(): persistence is a no-op, but nothing may throw.
    await s.replaceHistory([_entry('1+1', '2')]);
    expect(s.history.map((e) => e.expression), ['1+1']);
  });

  test('an empty import clears the history and the stored list', () async {
    SharedPreferences.setMockInitialValues({});
    final s = AppState();
    await s.load(force: true);
    s.addHistoryEntry('1+1', '2');

    await s.replaceHistory(const []);

    expect(s.history, isEmpty);
    expect((await SharedPreferences.getInstance()).getString('crisp.history'),
        '[]');
  });
}

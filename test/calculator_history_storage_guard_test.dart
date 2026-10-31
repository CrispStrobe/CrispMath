import 'dart:async';
import 'dart:convert';

import 'package:crisp_math/engine/app_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

class _GatedStore extends SharedPreferencesStorePlatform {
  _GatedStore(this.delegate);
  final SharedPreferencesStorePlatform delegate;
  final gate = Completer<bool>();
  bool block = false;
  @override
  Future<bool> setValue(String type, String key, Object value) async {
    if (block && key == 'flutter.crisp.history') {
      block = false;
      if (!await gate.future) return false;
    }
    return delegate.setValue(type, key, value);
  }

  @override
  Future<Map<String, Object>> getAll() => delegate.getAll();
  @override
  Future<bool> remove(String key) => delegate.remove(key);
  @override
  Future<bool> clear() => delegate.clear();
}

void main() {
  test('history replacement refuses to succeed without storage', () async {
    final state = AppState.forTesting();
    state.history.clear();
    state.addHistoryEntry('old', '1');
    await expectLater(
      state.replaceHistory([CalculationEntry(expression: 'new', result: '2')]),
      throwsStateError,
    );
    expect(state.history.map((e) => e.expression), ['old']);
  });

  test('listener edits use a separate queued save after import commits',
      () async {
    SharedPreferences.setMockInitialValues({});
    final state = AppState.forTesting();
    await state.load(force: true);
    final store = _GatedStore(SharedPreferencesStorePlatform.instance);
    SharedPreferencesStorePlatform.instance = store;
    addTearDown(() => SharedPreferencesStorePlatform.instance = store.delegate);
    var changed = false;
    void listener() {
      if (!changed && state.history.any((e) => e.expression == 'new')) {
        changed = true;
        store.block = true;
        state.addHistoryEntry('listener', '3');
      }
    }
    state.calculatorChanges.addListener(listener);
    addTearDown(() => state.calculatorChanges.removeListener(listener));
    var completed = false;
    final replacement = state
        .replaceHistory([CalculationEntry(expression: 'new', result: '2')])
        .then((_) => completed = true);
    await replacement;
    expect(completed, isTrue);
    expect(state.history.map((e) => e.expression), ['listener', 'new']);
    store.gate.complete(true);
    await state.flushPersistence();
    final prefs = await SharedPreferences.getInstance();
    final stored = jsonDecode(prefs.getString('crisp.history')!) as List;
    expect(stored.map((e) => e['e']), ['listener', 'new']);
  });

  test('failed listener save preserves committed import and live edit', () async {
    SharedPreferences.setMockInitialValues({});
    final state = AppState.forTesting();
    await state.load(force: true);
    await state.replaceHistory([CalculationEntry(expression: 'old', result: '1')]);
    final store = _GatedStore(SharedPreferencesStorePlatform.instance);
    SharedPreferencesStorePlatform.instance = store;
    addTearDown(() => SharedPreferencesStorePlatform.instance = store.delegate);
    var changed = false;
    void listener() {
      if (!changed && state.history.any((e) => e.expression == 'new')) {
        changed = true;
        store.block = true;
        state.addHistoryEntry('listener', '3');
      }
    }
    state.calculatorChanges.addListener(listener);
    addTearDown(() => state.calculatorChanges.removeListener(listener));
    final replacement = state.replaceHistory(
        [CalculationEntry(expression: 'new', result: '2')]);
    await replacement;
    store.gate.complete(false);
    await state.flushPersistence();
    expect(state.history.map((e) => e.expression), ['listener', 'new']);
    final prefs = await SharedPreferences.getInstance();
    final stored = jsonDecode(prefs.getString('crisp.history')!) as List;
    expect(stored.map((e) => e['e']), ['new']);
  });
}

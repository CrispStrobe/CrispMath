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
    final state = AppState();
    state.history.clear();
    state.addHistoryEntry('old', '1');
    await expectLater(
      state.replaceHistory([CalculationEntry(expression: 'new', result: '2')]),
      throwsStateError,
    );
    expect(state.history.map((e) => e.expression), ['old']);
  });

  test('synchronous listener changes are persisted before import succeeds',
      () async {
    SharedPreferences.setMockInitialValues({});
    final state = AppState();
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
    await Future<void>.delayed(Duration.zero);
    expect(completed, isFalse,
        reason: 'the listener edit has not yet been durably written');
    store.gate.complete(true);
    await replacement;
    final prefs = await SharedPreferences.getInstance();
    final stored = jsonDecode(prefs.getString('crisp.history')!) as List;
    expect(stored.map((e) => e['e']), ['listener', 'new']);
  });

  test('failed listener edit write restores old history and the edit', () async {
    SharedPreferences.setMockInitialValues({});
    final state = AppState();
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
    final failure = expectLater(replacement, throwsStateError);
    await Future<void>.delayed(Duration.zero);
    store.gate.complete(false);
    await failure;
    await state.flushPersistence();
    expect(state.history.map((e) => e.expression), ['listener', 'old']);
    final prefs = await SharedPreferences.getInstance();
    final stored = jsonDecode(prefs.getString('crisp.history')!) as List;
    expect(stored.map((e) => e['e']), ['listener', 'old']);
  });
}

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../engine/app_state.dart';

class SyncService {
  static final SyncService instance = SyncService._();
  SyncService._();

  bool _configured = false;
  bool get isConfigured => _configured;

  SupabaseClient get _client => Supabase.instance.client;
  User? get currentUser => isConfigured ? _client.auth.currentUser : null;

  Future<void> init() async {
    const url = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
    const key = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
    if (url.isNotEmpty && key.isNotEmpty) {
      await Supabase.initialize(url: url, anonKey: key);
      _configured = true;
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    if (!isConfigured) throw Exception('Supabase not configured');
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signUp(String email, String password) async {
    if (!isConfigured) throw Exception('Supabase not configured');
    await _client.auth.signUp(email: email, password: password);
  }

  Future<void> signOut() async {
    if (!isConfigured) return;
    await _client.auth.signOut();
  }

  Future<void> pushState(AppState state) async {
    if (!isConfigured || currentUser == null) return;

    final data = state.exportToJson();
    final jsonStr = jsonEncode(data);

    await _client.from('user_sync_data').upsert({
      'user_id': currentUser!.id,
      'app_state': jsonStr,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<bool> pullState(AppState state) async {
    if (!isConfigured || currentUser == null) return false;

    final response = await _client
        .from('user_sync_data')
        .select()
        .eq('user_id', currentUser!.id)
        .maybeSingle();

    if (response == null || response['app_state'] == null) {
      return false;
    }

    final data = jsonDecode(response['app_state'] as String);
    state.importFromJson(data, merge: true);
    return true;
  }
}

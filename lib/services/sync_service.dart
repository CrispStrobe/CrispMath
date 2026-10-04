import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../engine/app_state.dart';
import 'cloud_backup_store.dart';

enum SyncStatus { uninitialized, initializing, ready, unavailable, failed }

class SyncService extends ChangeNotifier {
  static final SyncService instance = SyncService();

  /// Uses the saved/build configuration and the application's Supabase instance.
  SyncService() : _providedClient = null;

  /// Integrates an already configured SDK client. Its owner controls its lifetime.
  SyncService.withClient(SupabaseClient client) : _providedClient = client {
    _configured = true;
    _status = SyncStatus.ready;
    _initialization = Future<void>.value();
  }

  final SupabaseClient? _providedClient;

  bool _configured = false;
  bool get isConfigured => _configured;

  SupabaseClient get _client => _providedClient ?? Supabase.instance.client;
  User? get currentUser => isConfigured ? _client.auth.currentUser : null;

  SyncStatus _status = SyncStatus.uninitialized;
  SyncStatus get status => _status;
  Future<void>? _initialization;

  Future<void> init() => _initialization ??= _initialize();

  Future<void> _initialize() async {
    _status = SyncStatus.initializing;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    const buildUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
    const buildKey =
        String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
    final url = buildUrl.isNotEmpty
        ? buildUrl
        : prefs.getString('crisp.syncProjectUrl') ?? '';
    final key = buildKey.isNotEmpty
        ? buildKey
        : prefs.getString('crisp.syncPublicKey') ?? '';
    if (url.isEmpty || key.isEmpty) {
      _status = SyncStatus.unavailable;
      notifyListeners();
      return;
    }
    try {
      await Supabase.initialize(url: url, publishableKey: key);
      _configured = true;
      _status = SyncStatus.ready;
    } catch (e) {
      _status = SyncStatus.failed;
      _initialization = null;
      debugPrint('Sync initialization failed: $e');
    }
    notifyListeners();
  }

  static void validatePublicConfiguration(String url, String key) {
    final uri = Uri.tryParse(url);
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment) {
      throw const FormatException('Enter an HTTPS project URL');
    }
    if (key.startsWith('sb_publishable_') && key.length > 20) return;
    try {
      final parts = key.split('.');
      if (parts.length == 3 &&
          jsonDecode(utf8.decode(
                  base64Url.decode(base64Url.normalize(parts[1]))))['role'] ==
              'anon') {
        return;
      }
    } catch (_) {}
    throw const FormatException('Use the public publishable or anon key');
  }

  Future<void> configure(String url, String publicKey) async {
    if (isConfigured) throw StateError('Cloud sync is already configured');
    url = url.trim();
    publicKey = publicKey.trim();
    validatePublicConfiguration(url, publicKey);
    _status = SyncStatus.initializing;
    notifyListeners();
    try {
      await Supabase.initialize(url: url, publishableKey: publicKey);
      _configured = true;
      _status = SyncStatus.ready;
      final prefs = await SharedPreferences.getInstance();
      if (!await prefs.setString('crisp.syncProjectUrl', url) ||
          !await prefs.setString('crisp.syncPublicKey', publicKey)) {
        throw StateError(
            'Cloud settings could not be saved for the next launch');
      }
    } catch (_) {
      if (!_configured) _status = SyncStatus.failed;
      rethrow;
    } finally {
      notifyListeners();
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

  CloudBackupStore _store() {
    if (!isConfigured) throw StateError('Cloud sync is not configured');
    final user = currentUser;
    if (user == null) throw StateError('Sign in before syncing');
    return SupabaseBackupStore(_client, user.id);
  }

  Future<void> pushState(AppState state) async {
    final store = _store();
    final current = await store.read();
    await store.write(state.exportToJson(),
        expectedRevision: current?.revision);
  }

  Future<CloudBackupSnapshot?> readBackup() async => _store().read();
}

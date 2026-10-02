import 'dart:convert';

import 'package:crisp_math/engine/notepad.dart';
import 'package:crisp_math/services/cloud_backup_store.dart';
import 'package:crisp_math/services/document_history.dart';
import 'package:crisp_math/services/sync_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  final doc = NotepadDocument.fresh(name: 'Cloud');
  final state = {
    'notepadDocuments': [worksheetSource(doc)]
  };
  test('real Supabase client reads and validates the user-scoped backup',
      () async {
    final client = SupabaseClient('https://fixture.invalid', 'public-test',
        httpClient: MockClient((request) async {
      expect(request.method, 'GET');
      expect(request.url.path, '/rest/v1/user_sync_data');
      expect(request.url.queryParameters['user_id'], 'eq.test-user');
      return http.Response(
          jsonEncode({
            'user_id': 'test-user',
            'updated_at': '2000-01-01T00:00:00Z',
            'revision': 1,
            'app_state': jsonEncode(state)
          }),
          200,
          request: request,
          headers: {'content-type': 'application/json'});
    }));
    addTearDown(client.dispose);
    final snapshot = await SupabaseBackupStore(client, 'test-user').read();
    expect(snapshot!.revision, 1);
    expect(snapshot.backup.documents.single.id, doc.id);
  });
  test('conditional update rejects a concurrent cloud edit', () async {
    final client = SupabaseClient('https://fixture.invalid', 'public-test',
        httpClient: MockClient((request) async {
      expect(request.method, 'PATCH');
      expect(request.url.queryParameters['revision'], 'eq.1');
      expect(request.url.queryParameters['user_id'], 'eq.test-user');
      return http.Response('[]', 200,
          request: request, headers: {'content-type': 'application/json'});
    }));
    addTearDown(client.dispose);
    await expectLater(
        SupabaseBackupStore(client, 'test-user')
            .write(state, expectedRevision: 1),
        throwsStateError);
  });
  test(
      'first upload uses insert and cannot overwrite a concurrent first upload',
      () async {
    final client = SupabaseClient('https://fixture.invalid', 'public-test',
        httpClient: MockClient((request) async {
      expect(request.method, 'POST');
      expect(request.headers['prefer'] ?? '',
          isNot(contains('resolution=merge-duplicates')));
      return http.Response(
          jsonEncode({
            'code': '23505',
            'message': 'duplicate user_id',
            'details': null,
            'hint': null
          }),
          409,
          request: request,
          headers: {'content-type': 'application/json'});
    }));
    addTearDown(client.dispose);
    await expectLater(
        SupabaseBackupStore(client, 'test-user')
            .write(state, expectedRevision: null),
        throwsA(isA<PostgrestException>()));
  });
  test('runtime configuration accepts public keys and rejects private keys',
      () {
    expect(
        () => SyncService.validatePublicConfiguration(
            'https://project.supabase.co', 'sb_publishable_public_fixture'),
        returnsNormally);
    final payload = base64Url.encode(utf8.encode(jsonEncode({'role': 'anon'})));
    expect(
        () => SyncService.validatePublicConfiguration(
            'https://project.supabase.co', 'header.$payload.signature'),
        returnsNormally);
    expect(
        () => SyncService.validatePublicConfiguration(
            'https://project.supabase.co', 'sb_secret_fixture'),
        throwsFormatException);
    expect(
        () => SyncService.validatePublicConfiguration(
            'http://project.supabase.co', 'sb_publishable_public_fixture'),
        throwsFormatException);
  });

  test('unconfigured cloud sync reports an error instead of a false success',
      () async {
    await SyncService.instance.init();
    expect(SyncService.instance.isConfigured, isFalse);
    await expectLater(SyncService.instance.readBackup(), throwsStateError);
  });
}

import 'dart:convert';
import 'dart:io';

import 'package:crisp_math/engine/notepad.dart';
import 'package:crisp_math/services/cloud_backup_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// A real, disposable Auth/PostgREST/PostgreSQL stack is required. Never run
/// this fixture-administration test against a user's configured project.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final environment = Platform.environment;
  final uri = Uri.parse(environment['CRISPMATH_SYNC_API_URL'] ?? '');
  if (environment['CRISPMATH_SYNC_LIVE'] != 'disposable' ||
      uri.scheme != 'http' ||
      !{'localhost', '127.0.0.1'}.contains(uri.host)) {
    throw StateError('Cloud live tests require the disposable loopback CI stack');
  }
  final publicKey = environment['CRISPMATH_SYNC_PUBLIC_KEY']!;
  final admin = SupabaseClient(
      uri.toString(), environment['CRISPMATH_SYNC_FIXTURE_ADMIN_KEY']!);
  final clients = <SupabaseClient>[];
  final userIds = <String>[];
  final checks = <Map<String, dynamic>>[];
  final report = File(environment['CRISPMATH_SYNC_REPORT'] ??
      '.dart_tool/sync-live/report.json');
  var sequence = 0;

  SupabaseClient client() {
    final result = SupabaseClient(uri.toString(), publicKey);
    clients.add(result);
    return result;
  }

  Future<(String, String)> account() async {
    final suffix = '${DateTime.now().microsecondsSinceEpoch}-${sequence++}';
    final email = 'sync-$suffix@example.test';
    const password = 'Disposable-CrispMath-42!';
    final created = await admin.auth.admin.createUser(AdminUserAttributes(
        email: email, password: password, emailConfirm: true));
    userIds.add(created.user!.id);
    return (email, password);
  }

  Future<SupabaseClient> signIn((String, String) credentials) async {
    final result = client();
    await result.auth.signInWithPassword(
        email: credentials.$1, password: credentials.$2);
    expect(result.auth.currentUser, isNotNull);
    return result;
  }

  SupabaseBackupStore store(SupabaseClient client, {String? userId}) =>
      SupabaseBackupStore(client, userId ?? client.auth.currentUser!.id);

  Map<String, dynamic> source(String name) {
    final document = NotepadDocument.fresh(name: name);
    document.lines.first.source = 'a=3';
    document.lines.add(NotepadLine.fresh(source: 'f(t)=t^2+a'));
    document.lines.add(
        NotepadLine.fresh(source: 'f(4)')..cachedResult = '999');
    return {
      'notepadDocuments': [document.toJson()],
      'apiKey': 'never-upload-this-secret',
      'authSession': 'never-upload-this-session',
      'aiSettings': {'key': 'never-upload-this-secret'},
    };
  }

  Future<Object?> attempt(CloudBackupStore target, Map<String, dynamic> state,
      {required int? revision}) async {
    try {
      await target.write(state, expectedRevision: revision);
      return null;
    } catch (error) {
      return error;
    }
  }

  void liveTest(String name, Future<void> Function() body) {
    test(name, () async {
      final record = <String, dynamic>{'name': name, 'passed': false};
      checks.add(record);
      try {
        await body();
        record['passed'] = true;
      } finally {
        report.parent.createSync(recursive: true);
        report.writeAsStringSync(const JsonEncoder.withIndent('  ').convert({
          'source': environment['GITHUB_SHA'],
          'backend': 'disposable Supabase Auth/PostgREST/PostgreSQL',
          'cliVersion': environment['CRISPMATH_SYNC_CLI_VERSION'],
          'physicalDeviceTest': false,
          'deployedUserProjectTest': false,
          'passed': checks.length == 5 && checks.every((c) => c['passed'] == true),
          'checks': checks,
        }));
      }
    }, timeout: const Timeout(Duration(minutes: 2)));
  }

  tearDownAll(() async {
    for (final id in userIds) {
      await admin.auth.admin.deleteUser(id);
    }
    for (final current in clients) {
      await current.dispose();
    }
    await admin.dispose();
  });

  liveTest('independent authenticated sessions round-trip source and filter secrets',
      () async {
    final credentials = await account();
    final first = await signIn(credentials);
    final second = await signIn(credentials);
    expect(first.auth.currentUser!.id, second.auth.currentUser!.id);
    expect(first.auth.currentSession!.accessToken ==
        second.auth.currentSession!.accessToken, isFalse);
    expect(await store(second).read(), isNull);
    await store(first).write(source('Device A worksheet'), expectedRevision: null);
    final snapshot = (await store(second).read())!;
    expect(snapshot.revision, 0);
    final document = snapshot.backup.documents.single;
    expect(document.name, 'Device A worksheet');
    expect(document.lines.map((r) => r.source), ['a=3', 'f(t)=t^2+a', 'f(4)']);
    expect(document.lines.every((r) => r.cachedResult == null), isTrue);
    final raw = await second.from('user_sync_data').select('app_state').single();
    expect(raw['app_state'], isNot(contains('never-upload')));
    await store(second).write(source('Device B worksheet'), expectedRevision: 0);
    expect((await store(first).read())!.backup.documents.single.name,
        'Device B worksheet');
    expect((await store(first).read())!.revision, 1);
  });

  liveTest('concurrent first uploads preserve exactly one complete winner', () async {
    final credentials = await account();
    final first = store(await signIn(credentials));
    final second = store(await signIn(credentials));
    final outcomes = await Future.wait([
      attempt(first, source('First candidate'), revision: null),
      attempt(second, source('Second candidate'), revision: null),
    ]);
    expect(outcomes.where((value) => value == null), hasLength(1));
    expect(outcomes.whereType<PostgrestException>().single.code, '23505');
    final winner = (await first.read())!;
    expect(winner.revision, 0);
    expect(winner.backup.documents.single.name,
        outcomes.first == null ? 'First candidate' : 'Second candidate');
  });

  liveTest('concurrent revision updates reject the stale writer without losing work',
      () async {
    final credentials = await account();
    final first = store(await signIn(credentials));
    final second = store(await signIn(credentials));
    await first.write(source('Original'), expectedRevision: null);
    final firstRevision = (await first.read())!.revision;
    final secondRevision = (await second.read())!.revision;
    final outcomes = await Future.wait([
      attempt(first, source('First edit'), revision: firstRevision),
      attempt(second, source('Second edit'), revision: secondRevision),
    ]);
    expect(outcomes.where((value) => value == null), hasLength(1));
    expect(outcomes.whereType<StateError>(), hasLength(1));
    final winner = (await second.read())!;
    expect(winner.revision, 1);
    expect(winner.backup.documents.single.name,
        outcomes.first == null ? 'First edit' : 'Second edit');
    await expectLater(first.write(source('Stale retry'), expectedRevision: 0),
        throwsStateError);
    expect((await first.read())!.backup.documents.single.id,
        winner.backup.documents.single.id);
  });

  liveTest('real JWT row policies isolate owners and reject anonymous access', () async {
    final owner = await signIn(await account());
    final stranger = await signIn(await account());
    final ownerId = owner.auth.currentUser!.id;
    await store(owner).write(source('Private worksheet'), expectedRevision: null);
    expect(await store(stranger, userId: ownerId).read(), isNull);
    await expectLater(
        store(stranger, userId: ownerId)
            .write(source('Unauthorized insert'), expectedRevision: null),
        throwsA(isA<PostgrestException>().having((e) => e.code, 'code', '42501')));
    await expectLater(
        store(stranger, userId: ownerId)
            .write(source('Unauthorized update'), expectedRevision: 0),
        throwsStateError);
    await expectLater(
        store(client(), userId: ownerId).read(),
        throwsA(isA<PostgrestException>().having((e) => e.code, 'code', '42501')));
    expect((await store(owner).read())!.revision, 0);
    expect((await store(owner).read())!.backup.documents.single.name,
        'Private worksheet');
  });

  liveTest('session refresh restores a backup and sign-out removes access', () async {
    final original = await signIn(await account());
    await store(original).write(source('Saved before restart'), expectedRevision: null);
    final restarted = client();
    await restarted.auth.setSession(original.auth.currentSession!.refreshToken!);
    final userId = restarted.auth.currentUser!.id;
    expect(userId, original.auth.currentUser!.id);
    expect((await store(restarted).read())!.backup.documents.single.name,
        'Saved before restart');
    await restarted.auth.signOut();
    expect(restarted.auth.currentUser, isNull);
    await expectLater(store(restarted, userId: userId).read(),
        throwsA(isA<PostgrestException>().having((e) => e.code, 'code', '42501')));
  });
}

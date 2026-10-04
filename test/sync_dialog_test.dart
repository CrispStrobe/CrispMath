import 'dart:async';
import 'dart:convert';

import 'package:crisp_math/engine/app_state.dart';
import 'package:crisp_math/engine/notepad.dart';
import 'package:crisp_math/services/sync_service.dart';
import 'package:crisp_math/widgets/sync_dialog.dart';
import 'package:crisp_math/widgets/workspace_backup_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _email = 'fixture@example.test';
const _password = 'password-canary-never-show';
const _unsafeError = 'server-secret-canary-never-show';
const _loginSuccess = 'Signed in. You can now pull or upload a cloud backup.';
const _loginFailure = 'Sign in failed. Check your email and password, then try again.';

class _Backend {
  bool loginFails = false;
  bool readFails = false;
  bool writeFails = false;
  bool logoutFails = false;
  bool signupConfirmation = false;
  int writes = 0;
  Map<String, dynamic>? row;
  Completer<http.Response>? delayedLogin;
  late final SupabaseClient client = SupabaseClient(
    'https://fixture.invalid', 'public-fixture',
    authOptions: const AuthClientOptions(autoRefreshToken: false),
    httpClient: MockClient(handle),
  );
  late final SyncService service = SyncService.withClient(client);

  Map<String, dynamic> get user => {
    'id': 'fixture-user', 'aud': 'authenticated', 'role': 'authenticated',
    'email': _email, 'app_metadata': {'provider': 'email'}, 'user_metadata': {},
    'created_at': '2026-10-04T00:00:00Z',
  };
  Map<String, dynamic> get session {
    String part(Object value) => base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
    final token = '${part({'alg': 'HS256', 'typ': 'JWT'})}.${part({'sub': 'fixture-user', 'exp': DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600})}.fixture';
    return {'access_token': token, 'refresh_token': 'fixture-refresh',
      'expires_in': 3600, 'token_type': 'bearer', 'user': user};
  }
  http.Response response(Object data, int status) => http.Response(jsonEncode(data), status,
      headers: {'content-type': 'application/json'});
  Future<http.Response> handle(http.Request request) async {
    if (request.url.path == '/auth/v1/token') {
      if (delayedLogin != null) return delayedLogin!.future;
      return loginFails ? response({'msg': _unsafeError, 'error_code': 'invalid_credentials'}, 400)
          : response(session, 200);
    }
    if (request.url.path == '/auth/v1/signup') {
      return response(signupConfirmation ? {'user': user} : session, 200);
    }
    if (request.url.path == '/auth/v1/logout') {
      return logoutFails ? response({'msg': _unsafeError}, 500) : http.Response('', 204);
    }
    if (request.url.path == '/rest/v1/user_sync_data') {
      if (request.method == 'GET') {
        return readFails ? response({'code': '42501', 'message': _unsafeError}, 403)
            : response(row ?? [], 200);
      }
      if (request.method == 'POST') {
        writes++;
        if (writeFails) return response({'code': '23505', 'message': _unsafeError}, 409);
        row = Map<String, dynamic>.from(jsonDecode(request.body));
        return response({}, 201);
      }
    }
    throw StateError('Unexpected SDK request: ${request.method} ${request.url.path}');
  }
}

Future<void> _show(WidgetTester tester, SyncService service, {bool phone = false}) async {
  await tester.binding.setSurfaceSize(phone ? const Size(390, 844) : const Size(1280, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(MaterialApp(
    builder: phone ? (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(2),
        viewInsets: const EdgeInsets.only(bottom: 280)), child: child!) : null,
    home: Scaffold(body: Builder(builder: (context) => TextButton(
      onPressed: () => showDialog<void>(context: context,
        builder: (_) => SyncDialog(appState: AppState(), service: service)),
      child: const Text('Open sync')))),
  ));
  await tester.tap(find.text('Open sync'));
  await tester.pumpAndSettle();
}

Future<void> _credentials(WidgetTester tester) async {
  final fields = find.byType(TextField);
  await tester.ensureVisible(fields.at(0));
  await tester.enterText(fields.at(0), _email);
  await tester.ensureVisible(fields.at(1));
  await tester.enterText(fields.at(1), _password);
}

Future<void> _tap(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text));
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

void _accessible(WidgetTester tester, String message) {
  expect(find.text(message), findsOneWidget);
  expect(tester.getSemantics(find.text(message)), matchesSemantics(
    label: message, isLiveRegion: true, textDirection: TextDirection.ltr));
  expect(find.text(_unsafeError), findsNothing);
  expect(find.byType(SnackBar), findsNothing);
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppState().load(force: true);
    AppState().notepadDocuments.removeWhere((id, _) => id != kWelcomeNotepadDocId);
    final doc = NotepadDocument.fresh(name: 'Local worksheet');
    doc.lines.first.source = '2+3';
    AppState().setNotepadDocument(doc);
  });

  Future<_Backend> backend(WidgetTester tester, {bool signedIn = false}) async {
    final fixture = _Backend();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      fixture.service.dispose();
      // Native SDK JSON-isolate shutdown requires real event-loop progress.
      await tester.runAsync(() => fixture.client.dispose());
    });
    if (signedIn) {
      await tester.runAsync(() => fixture.client.auth.signInWithPassword(email: _email, password: _password));
    }
    return fixture;
  }

  testWidgets('bad credentials announce safe inline error; retry clears it and signs in', (tester) async {
    final fixture = await backend(tester);
    fixture.loginFails = true;
    await _show(tester, fixture.service);
    await _credentials(tester);
    await _tap(tester, 'Log In');
    _accessible(tester, _loginFailure);
    fixture.loginFails = false;
    await _tap(tester, 'Log In');
    _accessible(tester, _loginSuccess);
    expect(find.text(_loginFailure), findsNothing);
    expect(fixture.service.currentUser!.email, _email);
    await _tap(tester, 'Close');
    expect(find.byType(SyncDialog), findsNothing);
  });

  testWidgets('pull reports empty backup and safe read failure inside its dialog', (tester) async {
    final fixture = await backend(tester, signedIn: true);
    await _show(tester, fixture.service);
    await _tap(tester, 'Pull');
    _accessible(tester, 'No cloud backup is available.');
    fixture.readFails = true;
    await _tap(tester, 'Pull');
    _accessible(tester, 'Cloud backup could not be read. Check your connection and try again.');
    expect(find.text('No cloud backup is available.'), findsNothing);
    fixture.readFails = false;
    final doc = AppState().notepadDocuments.values
        .singleWhere((document) => document.name == 'Local worksheet');
    fixture.row = {'user_id': 'fixture-user', 'revision': 0,
      'app_state': jsonEncode({'notepadDocuments': [doc.toJson()]})};
    await _tap(tester, 'Pull');
    expect(find.byType(WorkspaceBackupDialog), findsOneWidget);
    expect(find.text('Local worksheet: 1 rows'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    await tester.tap(find.descendant(of: find.byType(WorkspaceBackupDialog),
        matching: find.text('Close')));
    await tester.pumpAndSettle();
    _accessible(tester, 'Cloud backup loaded for review.');
  });

  testWidgets('upload confirmation cancellation is harmless; failure and success are announced', (tester) async {
    final fixture = await backend(tester, signedIn: true);
    await _show(tester, fixture.service);
    await _tap(tester, 'Push');
    await _tap(tester, 'Cancel');
    expect(fixture.writes, 0);
    fixture.writeFails = true;
    await _tap(tester, 'Push');
    await _tap(tester, 'Upload backup');
    _accessible(tester, 'Cloud upload failed. Check your connection, then pull and review the latest backup before trying again.');
    fixture.writeFails = false;
    await _tap(tester, 'Push');
    await _tap(tester, 'Upload backup');
    _accessible(tester, 'Cloud backup uploaded.');
    expect(fixture.writes, 2);
    final state = jsonDecode(fixture.row!['app_state'] as String);
    final uploaded = (state['notepadDocuments'] as List)
        .where((document) => document['n'] == 'Local worksheet').single;
    expect(uploaded['l'][0]['s'], '2+3');
  });

  testWidgets('sign out announces local preservation and keeps a normal Close action', (tester) async {
    final fixture = await backend(tester, signedIn: true);
    await _show(tester, fixture.service);
    await _tap(tester, 'Sign Out');
    _accessible(tester, 'Signed out. Your workspace remains saved on this device.');
    expect(fixture.service.currentUser, isNull);
    expect(find.text('Log In'), findsOneWidget);
    expect(AppState().notepadDocuments.values.any((d) => d.name == 'Local worksheet'), isTrue);
    await _tap(tester, 'Close');
    expect(find.byType(SyncDialog), findsNothing);
  });

  testWidgets('server sign-out failure truthfully distinguishes the already removed local session', (tester) async {
    final fixture = await backend(tester, signedIn: true);
    fixture.logoutFails = true;
    await _show(tester, fixture.service);
    await _tap(tester, 'Sign Out');
    _accessible(tester, 'Signed out on this device. The server could not confirm sign out; check your connection before signing in again.');
    expect(fixture.service.currentUser, isNull);
    expect(find.text('Log In'), findsOneWidget);
  });

  testWidgets('closing during real SDK login completion never updates disposed widget state', (tester) async {
    final fixture = await backend(tester);
    fixture.delayedLogin = Completer<http.Response>();
    await _show(tester, fixture.service);
    await _credentials(tester);
    await tester.tap(find.text('Log In'));
    await tester.pump();
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    fixture.delayedLogin!.complete(fixture.response(fixture.session, 200));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
    expect(find.byType(SyncDialog), findsNothing);
  });

  testWidgets('phone keyboard and enlarged text keep authentication and feedback reachable without overflow', (tester) async {
    final fixture = await backend(tester);
    fixture.loginFails = true;
    await _show(tester, fixture.service, phone: true);
    await _credentials(tester);
    await _tap(tester, 'Log In');
    await tester.ensureVisible(find.text(_loginFailure));
    expect(find.text(_loginFailure).hitTestable(), findsOneWidget);
    await _tap(tester, 'Close');
    expect(tester.takeException(), isNull);
  });

  testWidgets('invalid public configuration is explained inline without exposing supplied private key', (tester) async {
    final service = SyncService();
    addTearDown(service.dispose);
    await _show(tester, service);
    await tester.enterText(find.byType(TextField).at(0), 'http://fixture.invalid');
    await tester.enterText(find.byType(TextField).at(1), 'sb_secret_private_canary');
    await _tap(tester, 'Configure cloud sync');
    _accessible(tester, 'Enter an HTTPS project URL and a public publishable or anon key.');
    expect(service.isConfigured, isFalse);
  });

  testWidgets('signup requiring confirmation does not claim an authenticated session', (tester) async {
    final fixture = await backend(tester);
    fixture.signupConfirmation = true;
    await _show(tester, fixture.service);
    await _credentials(tester);
    await _tap(tester, 'Sign Up');
    _accessible(tester, 'Account created. Check your email to confirm it before signing in.');
    expect(fixture.service.currentUser, isNull);
    expect(find.text('Log In'), findsOneWidget);
  });
}

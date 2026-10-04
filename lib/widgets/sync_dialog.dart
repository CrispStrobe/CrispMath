import 'package:flutter/material.dart';
import '../services/sync_service.dart';
import '../engine/app_state.dart';
import 'workspace_backup_dialog.dart';

class SyncDialog extends StatefulWidget {
  final AppState appState;
  final VoidCallback? onRestored;
  final SyncService? service;
  const SyncDialog({super.key, required this.appState, this.onRestored,
    this.service});

  @override
  State<SyncDialog> createState() => _SyncDialogState();
}

class _SyncDialogState extends State<SyncDialog> {
  final _urlCtl = TextEditingController();
  final _keyCtl = TextEditingController();
  final _emailCtl = TextEditingController();
  final _passwordCtl = TextEditingController();
  bool _isLoading = false;
  String? _feedback;
  bool _feedbackIsError = false;
  SyncService get _service => widget.service ?? SyncService.instance;

  @override
  void initState() {
    super.initState();
    _service.init();
  }

  @override
  void dispose() {
    _urlCtl.dispose();
    _keyCtl.dispose();
    _emailCtl.dispose();
    _passwordCtl.dispose();
    super.dispose();
  }

  Future<void> _run(Future<String?> Function() action,
      {required String failureMessage,
      String Function(Object error)? describeError}) async {
    if (_isLoading || !mounted) return;
    setState(() {
      _isLoading = true;
      _feedback = null;
      _feedbackIsError = false;
    });
    try {
      final message = await action();
      if (mounted) setState(() => _feedback = message);
    } catch (error) {
      if (mounted) {
        setState(() {
          _feedback = describeError?.call(error) ?? failureMessage;
          _feedbackIsError = true;
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sync(bool push) => _run(() async {
    if (push) {
      final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
                scrollable: true,
                title: const Text('Replace cloud backup?'),
                content: const Text(
                    'Upload this device’s workspace as the cloud backup. Pull first to review work from another device.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Upload backup'))
                ],
              ));
      if (confirmed != true || !mounted) return null;
      await _service.pushState(widget.appState);
      return 'Cloud backup uploaded.';
    }
    final snapshot = await _service.readBackup();
    if (!mounted) return null;
    if (snapshot == null) return 'No cloud backup is available.';
    await showDialog<void>(
        context: context,
        builder: (_) => WorkspaceBackupDialog(
            initialBackup: snapshot.backup, onRestored: widget.onRestored));
    return 'Cloud backup loaded for review.';
  }, failureMessage: push
      ? 'Cloud upload failed. Check your connection, then pull and review the latest backup before trying again.'
      : 'Cloud backup could not be read. Check your connection and try again.');

  Future<void> _auth(bool signUp) => _run(() async {
    if (signUp) {
      await _service.signUp(_emailCtl.text.trim(), _passwordCtl.text);
      return _service.currentUser == null
          ? 'Account created. Check your email to confirm it before signing in.'
          : 'Account created. You are signed in.';
    }
    await _service.signInWithEmail(_emailCtl.text.trim(), _passwordCtl.text);
    return 'Signed in. You can now pull or upload a cloud backup.';
  }, failureMessage: signUp
      ? 'Sign up failed. Check your details and connection, then try again.'
      : 'Sign in failed. Check your email and password, then try again.');

  Future<void> _configure() => _run(() async {
    await _service.configure(_urlCtl.text, _keyCtl.text);
    return 'Cloud sync is configured. Sign in to transfer your workspace.';
  }, failureMessage: 'Cloud sync could not be configured. Check your connection and try again.',
  describeError: (error) => error is FormatException
      ? 'Enter an HTTPS project URL and a public publishable or anon key.'
      : _service.isConfigured
          ? 'Cloud sync is connected, but its settings could not be saved. Configure it again after restarting.'
          : 'Cloud sync could not be configured. Check your connection and try again.');

  Future<void> _signOut() => _run(() async {
    try {
      await _service.signOut();
      return 'Signed out. Your workspace remains saved on this device.';
    } finally {
      if (mounted) _passwordCtl.clear();
    }
  }, failureMessage: 'Sign out failed. Check your connection and try again.',
  describeError: (_) => _service.currentUser == null
      ? 'Signed out on this device. The server could not confirm sign out; check your connection before signing in again.'
      : 'Sign out failed. Check your connection and try again.');

  Widget _notice(String message, {bool error = false}) => Semantics(
    container: true, liveRegion: true,
    child: Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(message, style: TextStyle(
        color: error ? Theme.of(context).colorScheme.error : null)),
    ),
  );

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _service,
    builder: (context, _) {
      final status = _service.status;
      final initializing = status == SyncStatus.uninitialized ||
          status == SyncStatus.initializing;
      final failed = status == SyncStatus.failed;
      final user = _service.currentUser;
      return AlertDialog(
        scrollable: true,
        title: const Text('Cloud Sync'),
        content: SizedBox(width: 440, child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_feedback != null) _notice(_feedback!, error: _feedbackIsError),
            if (initializing || _isLoading) ...[
              Semantics(label: 'Cloud sync is working', liveRegion: true,
                child: const LinearProgressIndicator()),
              const SizedBox(height: 16),
            ],
            if (failed) ...[
              if (_feedback == null) _notice(
                'Cloud sync could not connect. Try again when you are online.', error: true),
              TextButton(onPressed: _isLoading ? null : () => _run(() async {
                await _service.init();
                if (_service.status == SyncStatus.failed) throw StateError('Connection failed');
                return _service.isConfigured ? 'Cloud sync is ready.' :
                    'Cloud sync is not configured. Enter public project settings to continue.';
              }, failureMessage: 'Cloud sync could not connect. Try again when you are online.'),
                child: const Text('Retry')),
            ] else if (!initializing && !_service.isConfigured) ...[
              const Text('Cloud sync is unavailable until a backend is configured. Your work is saved on this device. You can transfer a workspace backup through Files.'),
              const SizedBox(height: 16),
              TextField(controller: _urlCtl, enabled: !_isLoading,
                decoration: const InputDecoration(labelText: 'Supabase project URL')),
              TextField(controller: _keyCtl, enabled: !_isLoading,
                decoration: const InputDecoration(labelText: 'Public publishable or anon key')),
              const SizedBox(height: 16),
              FilledButton(onPressed: _isLoading ? null : _configure,
                child: const Text('Configure cloud sync')),
            ] else if (!initializing && user == null) ...[
              TextField(controller: _emailCtl, enabled: !_isLoading,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email')),
              TextField(controller: _passwordCtl, enabled: !_isLoading,
                decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
              const SizedBox(height: 16),
              Wrap(spacing: 12, runSpacing: 8, alignment: WrapAlignment.center, children: [
                TextButton(onPressed: _isLoading ? null : () => _auth(false), child: const Text('Log In')),
                FilledButton(onPressed: _isLoading ? null : () => _auth(true), child: const Text('Sign Up')),
              ]),
            ] else if (!initializing) ...[
              Text('Logged in as ${user!.email}'),
              const SizedBox(height: 24),
              Wrap(spacing: 12, runSpacing: 8, alignment: WrapAlignment.center, children: [
                ElevatedButton.icon(onPressed: _isLoading ? null : () => _sync(false),
                  icon: const Icon(Icons.download), label: const Text('Pull')),
                ElevatedButton.icon(onPressed: _isLoading ? null : () => _sync(true),
                  icon: const Icon(Icons.upload), label: const Text('Push')),
              ]),
              const SizedBox(height: 24),
              TextButton(onPressed: _isLoading ? null : _signOut, child: const Text('Sign Out')),
            ],
          ],
        )),
        actions: [
          if (!initializing && !_service.isConfigured)
            TextButton(onPressed: _isLoading ? null : () => showDialog<void>(
              context: context, builder: (_) => WorkspaceBackupDialog(onRestored: widget.onRestored)),
              child: const Text('Workspace backups')),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      );
    },
  );
}

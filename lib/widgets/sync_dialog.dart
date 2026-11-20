import 'package:flutter/material.dart';
import '../services/sync_service.dart';
import '../services/cloud_backup_store.dart';
import '../engine/app_state.dart';
import '../localization/app_localizations.dart';
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
  AppLocalizations get _t => AppLocalizations.of(context);

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

  Future<void> _sync(bool push) async {
    if (_isLoading || !mounted) return;
    if (push) {
      // Confirmation is a decision, not a network operation. Clear stale
      // feedback without animating a progress indicator beneath its modal.
      setState(() {
        _feedback = null;
        _feedbackIsError = false;
      });
      final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
                scrollable: true,
                title: Text(_t.syncReplaceTitle),
                content: Text(_t.syncReplaceBody),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(_t.cancel)),
                  FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(_t.syncUploadBackup))
                ],
              ));
      if (confirmed != true || !mounted) return;
    }
    if (push) {
      await _run(() async {
        await _service.pushState(widget.appState);
        return _t.syncUploaded;
      }, failureMessage: _t.syncUploadFailed);
      return;
    }
    CloudBackupSnapshot? incoming;
    await _run(() async {
      incoming = await _service.readBackup();
      return incoming == null
          ? _t.syncNoBackup : _t.syncBackupLoaded;
    }, failureMessage: _t.syncReadFailed);
    // The fetch has finished. Reviewing a backup is a user decision, so it
    // must not leave a progress animation running beneath the review dialog.
    if (incoming != null && mounted) {
      await showDialog<void>(context: context, builder: (_) => WorkspaceBackupDialog(
        initialBackup: incoming!.backup, onRestored: widget.onRestored));
    }
  }

  Future<void> _auth(bool signUp) => _run(() async {
    if (signUp) {
      await _service.signUp(_emailCtl.text.trim(), _passwordCtl.text);
      return _service.currentUser == null
          ? _t.syncAccountCreatedConfirm
          : _t.syncAccountCreatedSignedIn;
    }
    await _service.signInWithEmail(_emailCtl.text.trim(), _passwordCtl.text);
    return _t.syncSignedIn;
  }, failureMessage: signUp
      ? _t.syncSignUpFailed
      : _t.syncSignInFailed);

  Future<void> _configure() => _run(() async {
    await _service.configure(_urlCtl.text, _keyCtl.text);
    return _t.syncConfigured;
  }, failureMessage: _t.syncConfigureFailed,
  describeError: (error) => error is FormatException
      ? _t.syncConfigureFormatError
      : _service.isConfigured
          ? _t.syncConfigureSaveFailed
          : _t.syncConfigureFailed);

  Future<void> _signOut() => _run(() async {
    try {
      await _service.signOut();
      return _t.syncSignedOut;
    } finally {
      if (mounted) _passwordCtl.clear();
    }
  }, failureMessage: _t.syncSignOutFailed,
  describeError: (_) => _service.currentUser == null
      ? _t.syncSignedOutLocally
      : _t.syncSignOutFailed);

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
        title: Text(_t.syncDialogTitle),
        content: SizedBox(width: 440, child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_feedback != null) _notice(_feedback!, error: _feedbackIsError),
            if (initializing || _isLoading) ...[
              Semantics(label: _t.syncWorking, liveRegion: true,
                child: const LinearProgressIndicator()),
              const SizedBox(height: 16),
            ],
            if (failed) ...[
              if (_feedback == null) _notice(
                _t.syncConnectFailed, error: true),
              TextButton(onPressed: _isLoading ? null : () => _run(() async {
                await _service.init();
                if (_service.status == SyncStatus.failed) throw StateError('Connection failed');
                return _service.isConfigured ? _t.syncReady :
                    _t.syncNotConfigured;
              }, failureMessage: _t.syncConnectFailed),
                child: Text(_t.graphRetry)),
            ] else if (!initializing && !_service.isConfigured) ...[
              Text(_t.syncOffBody),
              const SizedBox(height: 16),
              TextField(controller: _urlCtl, enabled: !_isLoading,
                decoration: InputDecoration(labelText: _t.syncProjectUrl)),
              TextField(controller: _keyCtl, enabled: !_isLoading,
                decoration: InputDecoration(labelText: _t.syncPublicKey)),
              const SizedBox(height: 16),
              FilledButton(onPressed: _isLoading ? null : _configure,
                child: Text(_t.syncConfigureButton)),
            ] else if (!initializing && user == null) ...[
              TextField(controller: _emailCtl, enabled: !_isLoading,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: _t.syncEmail)),
              TextField(controller: _passwordCtl, enabled: !_isLoading,
                decoration: InputDecoration(labelText: _t.syncPassword), obscureText: true),
              const SizedBox(height: 16),
              Wrap(spacing: 12, runSpacing: 8, alignment: WrapAlignment.center, children: [
                TextButton(onPressed: _isLoading ? null : () => _auth(false), child: Text(_t.syncLogIn)),
                FilledButton(onPressed: _isLoading ? null : () => _auth(true), child: Text(_t.syncSignUp)),
              ]),
            ] else if (!initializing) ...[
              Text(_t.syncLoggedInAs('${user!.email}')),
              const SizedBox(height: 24),
              Wrap(spacing: 12, runSpacing: 8, alignment: WrapAlignment.center, children: [
                ElevatedButton.icon(onPressed: _isLoading ? null : () => _sync(false),
                  icon: const Icon(Icons.download), label: Text(_t.syncPull)),
                ElevatedButton.icon(onPressed: _isLoading ? null : () => _sync(true),
                  icon: const Icon(Icons.upload), label: Text(_t.syncPush)),
              ]),
              const SizedBox(height: 24),
              TextButton(onPressed: _isLoading ? null : _signOut, child: Text(_t.syncSignOut)),
            ],
          ],
        )),
        actions: [
          if (!initializing && !_service.isConfigured)
            TextButton(onPressed: _isLoading ? null : () => showDialog<void>(
              context: context, builder: (_) => WorkspaceBackupDialog(onRestored: widget.onRestored)),
              child: Text(_t.backupDialogTitle)),
          TextButton(onPressed: () => Navigator.pop(context), child: Text(_t.dialogClose)),
        ],
      );
    },
  );
}

import 'package:flutter/material.dart';
import '../services/sync_service.dart';
import '../engine/app_state.dart';
import 'workspace_backup_dialog.dart';

class SyncDialog extends StatefulWidget {
  final AppState appState;
  final VoidCallback? onRestored;
  const SyncDialog({super.key, required this.appState, this.onRestored});

  @override
  State<SyncDialog> createState() => _SyncDialogState();
}

class _SyncDialogState extends State<SyncDialog> {
  final _urlCtl = TextEditingController();
  final _keyCtl = TextEditingController();
  final _emailCtl = TextEditingController();
  final _passwordCtl = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    SyncService.instance.init();
  }

  @override
  void dispose() {
    _urlCtl.dispose();
    _keyCtl.dispose();
    _emailCtl.dispose();
    _passwordCtl.dispose();
    super.dispose();
  }

  void _syncState(BuildContext context, bool push) async {
    if (push) {
      final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
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
      if (confirmed != true || !context.mounted) return;
    }
    setState(() => _isLoading = true);
    try {
      if (push) {
        await SyncService.instance.pushState(widget.appState);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cloud backup uploaded.')));
        }
      } else {
        final snapshot = await SyncService.instance.readBackup();
        if (!context.mounted) return;
        if (snapshot == null) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No cloud backup is available.')));
        } else {
          await showDialog<void>(
              context: context,
              builder: (_) => WorkspaceBackupDialog(
                  initialBackup: snapshot.backup,
                  onRestored: widget.onRestored));
        }
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Sync failed: $error')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _auth(BuildContext context, bool isSignUp) async {
    setState(() => _isLoading = true);
    try {
      if (isSignUp) {
        await SyncService.instance.signUp(_emailCtl.text, _passwordCtl.text);
      } else {
        await SyncService.instance
            .signInWithEmail(_emailCtl.text, _passwordCtl.text);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  isSignUp ? 'Sign up successful!' : 'Sign in successful!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Auth Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: SyncService.instance,
        builder: (context, _) => _buildDialog(context),
      );

  Widget _buildDialog(BuildContext context) {
    final status = SyncService.instance.status;
    if (status == SyncStatus.uninitialized ||
        status == SyncStatus.initializing) {
      return const AlertDialog(
          title: Text('Cloud Sync'),
          content: SizedBox(
              height: 80, child: Center(child: CircularProgressIndicator())));
    }
    if (status == SyncStatus.failed) {
      return AlertDialog(
          title: const Text('Cloud Sync'),
          content: const Text(
              'Cloud sync could not connect. Try again when you are online.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close')),
            TextButton(
                onPressed: SyncService.instance.init,
                child: const Text('Retry'))
          ]);
    }
    if (!SyncService.instance.isConfigured) {
      return AlertDialog(
        title: const Text('Cloud Sync'),
        content: SizedBox(
            width: 440,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text(
                  'Cloud sync is unavailable until a backend is configured. Your work is saved on this device. You can transfer a workspace backup through Files.'),
              TextField(
                  controller: _urlCtl,
                  decoration:
                      const InputDecoration(labelText: 'Supabase project URL')),
              TextField(
                  controller: _keyCtl,
                  decoration: const InputDecoration(
                      labelText: 'Public publishable or anon key')),
              FilledButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          setState(() => _isLoading = true);
                          try {
                            await SyncService.instance
                                .configure(_urlCtl.text, _keyCtl.text);
                          } catch (error) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Setup failed: $error')));
                            }
                          } finally {
                            if (mounted) setState(() => _isLoading = false);
                          }
                        },
                  child: const Text('Configure cloud sync')),
            ])),
        actions: [
          TextButton(
              onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) =>
                      WorkspaceBackupDialog(onRestored: widget.onRestored)),
              child: const Text('Workspace backups')),
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close')),
        ],
      );
    }

    final user = SyncService.instance.currentUser;
    return AlertDialog(
      title: const Text('Cloud Sync'),
      content: _isLoading
          ? const SizedBox(
              height: 100, child: Center(child: CircularProgressIndicator()))
          : user == null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                        controller: _emailCtl,
                        decoration: const InputDecoration(labelText: 'Email')),
                    TextField(
                        controller: _passwordCtl,
                        decoration:
                            const InputDecoration(labelText: 'Password'),
                        obscureText: true),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                            onPressed: () => _auth(context, false),
                            child: const Text('Log In')),
                        FilledButton(
                            onPressed: () => _auth(context, true),
                            child: const Text('Sign Up')),
                      ],
                    )
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Logged in as ${user.email}'),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _syncState(context, false),
                          icon: const Icon(Icons.download),
                          label: const Text('Pull'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _syncState(context, true),
                          icon: const Icon(Icons.upload),
                          label: const Text('Push'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () async {
                        await SyncService.instance.signOut();
                        setState(() {});
                      },
                      child: const Text('Sign Out'),
                    )
                  ],
                ),
    );
  }
}

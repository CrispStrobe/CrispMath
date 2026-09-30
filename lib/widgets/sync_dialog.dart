import 'package:flutter/material.dart';
import '../services/sync_service.dart';
import '../engine/app_state.dart';

class SyncDialog extends StatefulWidget {
  final AppState appState;
  const SyncDialog({super.key, required this.appState});

  @override
  State<SyncDialog> createState() => _SyncDialogState();
}

class _SyncDialogState extends State<SyncDialog> {
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
    _emailCtl.dispose();
    _passwordCtl.dispose();
    super.dispose();
  }

  void _syncState(BuildContext context, bool push) async {
    setState(() => _isLoading = true);
    try {
      if (push) {
        await SyncService.instance.pushState(widget.appState);
      } else {
        await SyncService.instance.pullState(widget.appState);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(push ? 'Pushed successfully!' : 'Pulled successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  isSignUp ? 'Sign up successful!' : 'Sign in successful!')),
        );
      }
    } catch (e) {
      if (mounted) {
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
        content: const Text(
            'Cloud sync is unavailable in this version. Your work is saved on this device.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'))
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

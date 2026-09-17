import 'package:flutter/material.dart';
import '../services/sync_service.dart';
import '../engine/app_state.dart';
import 'package:provider/provider.dart';

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
          SnackBar(content: Text(push ? 'Pushed successfully!' : 'Pulled successfully!')),
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
        await SyncService.instance.signInWithEmail(_emailCtl.text, _passwordCtl.text);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isSignUp ? 'Sign up successful!' : 'Sign in successful!')),
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
  Widget build(BuildContext context) {
    if (!SyncService.instance.isConfigured) {
      return AlertDialog(
        title: const Text('Cloud Sync'),
        content: const Text('Supabase is not configured. Please build with SUPABASE_URL and SUPABASE_ANON_KEY dart-defines.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))
        ],
      );
    }

    final user = SyncService.instance.currentUser;
    return AlertDialog(
      title: const Text('Cloud Sync'),
      content: _isLoading 
        ? const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()))
        : user == null
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: _emailCtl, decoration: const InputDecoration(labelText: 'Email')),
                TextField(controller: _passwordCtl, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(onPressed: () => _auth(context, false), child: const Text('Log In')),
                    FilledButton(onPressed: () => _auth(context, true), child: const Text('Sign Up')),
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

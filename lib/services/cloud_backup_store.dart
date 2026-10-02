import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'workspace_backup.dart';

class CloudBackupSnapshot {
  final int revision;
  final WorkspaceBackup backup;
  const CloudBackupSnapshot(this.revision, this.backup);
}

abstract interface class CloudBackupStore {
  Future<CloudBackupSnapshot?> read();
  Future<void> write(Map<String, dynamic> state,
      {required int? expectedRevision});
}

/// Updates are conditional on the previously observed server revision.
class SupabaseBackupStore implements CloudBackupStore {
  final SupabaseClient client;
  final String userId;
  SupabaseBackupStore(this.client, this.userId);
  @override
  Future<CloudBackupSnapshot?> read() async {
    final response = await client
        .from('user_sync_data')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    if (response == null) return null;
    if (response['revision'] is! int ||
        response['revision'] < 0 ||
        response['app_state'] is! String ||
        utf8.encode(response['app_state'] as String).length >
            WorkspaceBackup.maxBytes) {
      throw const FormatException('Invalid cloud backup');
    }
    final decoded = jsonDecode(response['app_state']);
    return CloudBackupSnapshot(response['revision'],
        WorkspaceBackup.fromState(Map<String, dynamic>.from(decoded)));
  }

  @override
  Future<void> write(Map<String, dynamic> state,
      {required int? expectedRevision}) async {
    final data = {
      'user_id': userId,
      'app_state': jsonEncode(WorkspaceBackup.normalize(state)),
      'revision': (expectedRevision ?? -1) + 1,
      'updated_at': DateTime.now().toUtc().toIso8601String()
    };
    if (expectedRevision == null) {
      // A concurrent first upload hits the unique user_id constraint, rather
      // than overwriting another device's newly created backup.
      await client.from('user_sync_data').insert(data);
    } else {
      final changed = await client
          .from('user_sync_data')
          .update(data)
          .eq('user_id', userId)
          .eq('revision', expectedRevision)
          .select('user_id');
      if (changed.isEmpty) {
        throw StateError(
            'Cloud backup changed on another device. Pull and review it before retrying.');
      }
    }
  }
}

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../engine/notepad.dart';
import 'worksheet_file.dart';

/// Shared, bounded parsing for Shortcuts URLs and web workflow links.
class AppleWorkflowAction {
  final String? expression;
  final NotepadDocument? document;
  const AppleWorkflowAction({this.expression, this.document});

  static AppleWorkflowAction? fromUri(Uri uri) {
    final action =
        uri.scheme == 'crispmath' ? uri.host : uri.queryParameters['action'];
    if (action == 'calculate') {
      final expression = uri.queryParameters['expression'];
      if (expression == null ||
          expression.isEmpty ||
          expression.length > 10000) {
        throw const FormatException('Invalid calculation link');
      }
      return AppleWorkflowAction(expression: expression);
    }
    if (action == 'worksheet') {
      final name = uri.queryParameters['name'] ?? 'Shortcut worksheet';
      final text = uri.queryParameters['lines'] ?? '';
      if (name.length > 200 || text.length > 100000) {
        throw const FormatException('Worksheet link is too large');
      }
      final sources = text.split('\n');
      if (sources.length > 1000) {
        throw const FormatException('Too many worksheet rows');
      }
      final doc = NotepadDocument.fresh(name: name);
      doc.lines.clear();
      doc.lines.addAll(sources.map((s) => NotepadLine.fresh(source: s)));
      return AppleWorkflowAction(document: doc);
    }
    return null;
  }

  static AppleWorkflowAction? fromNative(Map<dynamic, dynamic> payload) {
    if (payload['file'] is String) {
      return AppleWorkflowAction(
          document:
              WorksheetFile.decode(base64Decode(payload['file'] as String)));
    }
    if (payload['url'] is String) {
      return fromUri(Uri.parse(payload['url'] as String));
    }
    throw const FormatException('Unsupported workflow action');
  }
}

class AppleWorkflowBridge {
  static const channel = MethodChannel('crispmath/workflows');

  static Future<void> listen(
      Future<void> Function(AppleWorkflowAction) onAction,
      void Function(Object) onError) async {
    Future<void> receive(dynamic payload) async {
      try {
        if (payload is! Map) {
          throw const FormatException('Invalid workflow action');
        }
        if (payload['error'] is String) throw FormatException(payload['error']);
        final action = AppleWorkflowAction.fromNative(payload);
        if (action != null) await onAction(action);
      } catch (error) {
        onError(error);
      }
    }

    if (kIsWeb) {
      try {
        final action = AppleWorkflowAction.fromUri(Uri.base);
        if (action != null) await onAction(action);
      } catch (error) {
        onError(error);
      }
      return;
    }
    if (defaultTargetPlatform != TargetPlatform.iOS) return;
    channel.setMethodCallHandler((call) async {
      if (call.method == 'incoming') await receive(call.arguments);
    });
    try {
      final pending = await channel.invokeListMethod<dynamic>('takePending');
      for (final action in pending ?? const []) {
        await receive(action);
      }
    } on MissingPluginException {
      // Widget tests and hosts without the iOS workflow plugin.
    } catch (error) {
      onError(error);
    }
  }

  static void stop() {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      channel.setMethodCallHandler(null);
    }
  }
}

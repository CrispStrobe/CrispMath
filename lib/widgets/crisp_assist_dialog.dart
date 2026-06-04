// lib/widgets/crisp_assist_dialog.dart
//
// Streaming AI explanation dialog. Shows CrispAssist's response
// as it arrives, with a cancel button and error handling.

import 'dart:async';

import 'package:flutter/material.dart';

import '../engine/app_state.dart';
import '../engine/step_engine.dart';
import '../services/crisp_assist_service.dart';

/// Shows a dialog that streams an AI explanation of a computation result.
Future<void> showCrispAssistExplainDialog(
  BuildContext context, {
  required String expression,
  required String result,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _CrispAssistExplainDialog(
      expression: expression,
      result: result,
    ),
  );
}

/// Shows a dialog that streams an AI narration of step-by-step traces.
Future<void> showCrispAssistNarrateDialog(
  BuildContext context, {
  required String expression,
  required List<MathStep> steps,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _CrispAssistNarrateDialog(
      expression: expression,
      steps: steps,
    ),
  );
}

// ---------------------------------------------------------------------------
// Explain dialog
// ---------------------------------------------------------------------------

class _CrispAssistExplainDialog extends StatefulWidget {
  final String expression;
  final String result;

  const _CrispAssistExplainDialog({
    required this.expression,
    required this.result,
  });

  @override
  State<_CrispAssistExplainDialog> createState() => _CrispAssistExplainDialogState();
}

class _CrispAssistExplainDialogState extends State<_CrispAssistExplainDialog> {
  final _service = CrispAssistService();
  final _cancel = CrispAssistCancelToken();
  final _buffer = StringBuffer();
  String? _error;
  bool _done = false;
  StreamSubscription<String>? _sub;

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _start() {
    final appState = AppState();
    final config = CrispAssistConfig(
      apiUrl: appState.crispAssistApiUrl,
      apiKey: appState.crispAssistApiKey,
      model: appState.crispAssistModel,
    );

    _sub = _service
        .streamExplain(
          expression: widget.expression,
          result: widget.result,
          config: config,
          cancel: _cancel,
        )
        .listen(
          (chunk) {
            if (mounted) {
              setState(() => _buffer.write(chunk));
            }
          },
          onError: (e) {
            if (mounted) {
              setState(() {
                _error = e.toString();
                _done = true;
              });
            }
          },
          onDone: () {
            if (mounted) setState(() => _done = true);
          },
        );
  }

  @override
  void dispose() {
    _cancel.cancel();
    _sub?.cancel();
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.auto_awesome, color: cs.primary, size: 20),
          const SizedBox(width: 8),
          const Text('CrispAssist'),
        ],
      ),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${widget.expression} = ${widget.result}',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: cs.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 12),
              if (_error != null)
                Text(
                  _error!,
                  style: TextStyle(color: cs.error),
                )
              else if (_buffer.isEmpty && !_done)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                SelectableText(
                  _buffer.toString(),
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
              if (!_done && _buffer.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: SizedBox(
                    height: 2,
                    child: LinearProgressIndicator(color: cs.primary),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        if (!_done)
          TextButton(
            onPressed: () {
              _cancel.cancel();
              setState(() => _done = true);
            },
            child: const Text('Stop'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(_done ? 'Close' : 'Dismiss'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Narrate dialog
// ---------------------------------------------------------------------------

class _CrispAssistNarrateDialog extends StatefulWidget {
  final String expression;
  final List<MathStep> steps;

  const _CrispAssistNarrateDialog({
    required this.expression,
    required this.steps,
  });

  @override
  State<_CrispAssistNarrateDialog> createState() => _CrispAssistNarrateDialogState();
}

class _CrispAssistNarrateDialogState extends State<_CrispAssistNarrateDialog> {
  final _service = CrispAssistService();
  String _content = '';
  String? _error;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    final appState = AppState();
    final config = CrispAssistConfig(
      apiUrl: appState.crispAssistApiUrl,
      apiKey: appState.crispAssistApiKey,
      model: appState.crispAssistModel,
    );
    try {
      final result = await _service.narrateSteps(
        expression: widget.expression,
        steps: widget.steps,
        config: config,
      );
      if (mounted) setState(() { _content = result; _done = true; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _done = true; });
    }
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.auto_awesome, color: cs.primary, size: 20),
          const SizedBox(width: 8),
          const Text('CrispAssist — Step Narration'),
        ],
      ),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_error != null)
                Text(_error!, style: TextStyle(color: cs.error))
              else if (!_done)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                SelectableText(
                  _content,
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

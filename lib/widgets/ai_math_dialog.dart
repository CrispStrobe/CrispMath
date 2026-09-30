import 'package:flutter/material.dart';
import '../engine/app_state.dart';
import '../services/ai_provider_service.dart';

class AiMathDialog extends StatefulWidget {
  final ProviderAiService? service;
  const AiMathDialog({super.key, this.service});
  @override
  State<AiMathDialog> createState() => _AiMathDialogState();
}

class _AiMathDialogState extends State<AiMathDialog> {
  late final ProviderAiService _service = widget.service ?? ProviderAiService();
  final _question = TextEditingController();
  final _expression = TextEditingController();
  bool _busy = false, _hasResult = false;
  int _generation = 0;
  String? _error;
  @override
  void dispose() {
    _generation++;
    _service.cancel();
    _question.dispose();
    _expression.dispose();
    super.dispose();
  }

  Future<void> _translate() async {
    final generation = ++_generation;
    setState(() {
      _busy = true;
      _error = null;
      _hasResult = false;
    });
    try {
      final expression = await _service.processMathNLP(_question.text);
      if (mounted && generation == _generation) {
        setState(() {
          _expression.text = expression;
          _hasResult = true;
        });
      }
    } catch (e) {
      if (mounted && generation == _generation) {
        setState(() => _error = e is AiRequestCancelled
            ? 'Request cancelled. You can retry.'
            : e.toString());
      }
    } finally {
      if (mounted && generation == _generation) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _service.config();
    return AlertDialog(
      title: const Text('Math assistance'),
      content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                Text(config.configured
                    ? 'Configured: ${config.model}. Connection is verified after a successful request.'
                    : 'Configure a provider endpoint and model in CrispAssist settings.'),
                const SizedBox(height: 12),
                TextField(
                    controller: _question,
                    minLines: 2,
                    maxLines: 4,
                    enabled: !_busy,
                    decoration: const InputDecoration(
                        labelText: 'Math question',
                        hintText: 'e.g. Integrate x squared')),
                const SizedBox(height: 12),
                const Text(
                    'This sends your question to the configured provider. Review its translation; the calculator computes the result.'),
                if (_busy)
                  const Padding(
                      padding: EdgeInsets.all(12),
                      child: LinearProgressIndicator()),
                if (_error != null)
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(_error!,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error))),
                if (_hasResult) ...[
                  const SizedBox(height: 12),
                  const Text(
                      'Provider responded. Review or edit this expression:'),
                  TextField(
                      controller: _expression,
                      maxLines: 3,
                      minLines: 1,
                      decoration: const InputDecoration(
                          labelText: 'Translated expression')),
                ],
              ]))),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close')),
        if (_busy)
          TextButton(
              onPressed: _service.cancel, child: const Text('Cancel request')),
        if (!_busy)
          FilledButton(
              onPressed: config.configured ? _translate : null,
              child: Text(_error == null ? 'Translate' : 'Retry')),
        if (_hasResult && !_busy)
          FilledButton(
              onPressed: () {
                if (_expression.text.trim().isEmpty) {
                  return;
                }
                AppState().requestInsertExpression(_expression.text.trim());
                Navigator.pop(context);
              },
              child: const Text('Use in calculator')),
      ],
    );
  }
}

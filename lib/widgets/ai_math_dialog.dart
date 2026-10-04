import 'package:flutter/material.dart';
import '../engine/app_state.dart';
import '../services/ai_provider_service.dart';
import '../localization/workflow_localizations.dart';

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
  String? _clarification;
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
      _clarification = null;
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
    } on AiClarificationRequired catch (e) {
      if (mounted && generation == _generation) {
        setState(() => _clarification = e.question);
      }
    } catch (e) {
      if (mounted && generation == _generation) {
        setState(() => _error = e is AiRequestCancelled
            ? WorkflowLocalizations.of(context).text(WorkflowLabel.cancelled)
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
    final t = WorkflowLocalizations.of(context);
    return AlertDialog(
      title: Text(t.text(WorkflowLabel.mathAssistance)),
      content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                Text(config.configured
                    ? t.text(WorkflowLabel.configured, config.model)
                    : t.text(WorkflowLabel.configureProvider)),
                const SizedBox(height: 12),
                TextField(
                    controller: _question,
                    minLines: 2,
                    maxLines: 4,
                    enabled: !_busy,
                    decoration: InputDecoration(
                        labelText: t.text(WorkflowLabel.mathQuestion),
                        hintText: t.text(WorkflowLabel.questionHint))),
                const SizedBox(height: 12),
                Text(t.text(WorkflowLabel.providerNotice)),
                if (_busy)
                  const Padding(
                      padding: EdgeInsets.all(12),
                      child: LinearProgressIndicator()),
                if (_clarification != null)
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Semantics(
                          liveRegion: true,
                          child: Text(t.text(
                              WorkflowLabel.clarification, _clarification!)))),
                if (_error != null)
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Semantics(
                          liveRegion: true,
                          child: Text(_error!,
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.error)))),
                if (_hasResult) ...[
                  const SizedBox(height: 12),
                  Text(t.text(WorkflowLabel.reviewExpression)),
                  TextField(
                      controller: _expression,
                      maxLines: 3,
                      minLines: 1,
                      decoration: InputDecoration(
                          labelText:
                              t.text(WorkflowLabel.translatedExpression))),
                ],
              ]))),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.text(WorkflowLabel.close))),
        if (_busy)
          TextButton(
              onPressed: _service.cancel,
              child: Text(t.text(WorkflowLabel.cancelRequest))),
        if (!_busy)
          FilledButton(
              onPressed: config.configured ? _translate : null,
              child: Text(t.text(_error == null
                  ? WorkflowLabel.translate
                  : WorkflowLabel.retry))),
        if (_hasResult && !_busy)
          FilledButton(
              onPressed: () {
                if (_expression.text.trim().isEmpty) {
                  return;
                }
                AppState().requestInsertExpression(_expression.text.trim());
                Navigator.pop(context);
              },
              child: Text(t.text(WorkflowLabel.useCalculator))),
      ],
    );
  }
}

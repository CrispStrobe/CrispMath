import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../engine/ocr_provider.dart';
import '../localization/app_localizations.dart';
import '../services/ocr_initialization.dart';
import 'drawing_canvas.dart';
import 'ocr_capture_dialog.dart';
import 'ocr_settings_dialog_stub.dart'
    if (dart.library.io) 'ocr_settings_dialog.dart';

Future<String?> showHandwritingInputDialog(BuildContext context) =>
    showDialog<String>(
        context: context, builder: (_) => const HandwritingInputDialog());

class HandwritingInputDialog extends StatefulWidget {
  /// Inject providers for an explicit fixture; production discovers native/WASM models.
  final List<OcrProvider>? providers;
  const HandwritingInputDialog({super.key, this.providers});
  @override
  State<HandwritingInputDialog> createState() => _HandwritingInputDialogState();
}

class _HandwritingInputDialogState extends State<HandwritingInputDialog> {
  final GlobalKey<DrawingCanvasState> _canvasKey = GlobalKey();
  final Set<String> _acceptedLicenses = {};
  OcrProvider? _provider;
  bool _recognizing = false;
  bool _runningInference = false;
  bool _loading = true;
  String? _error;
  AppLocalizations get _t => AppLocalizations.of(context);
  List<OcrProvider> get _available =>
      handwritingProviders(widget.providers ?? OcrProviders.available);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  Future<void> _initialize() async {
    try {
      if (widget.providers == null) await ensureOcrProviders();
      if (!mounted) return;
      setState(() {
        _provider = selectHandwritingProvider(
            widget.providers ?? OcrProviders.available,
            preferred: _provider ?? OcrProviders.active);
        _loading = false;
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = _t.handwritingInitFailed('$error');
          _loading = false;
        });
      }
    }
  }

  Future<void> _models() async {
    await showDialog<void>(
        context: context, builder: (_) => const OcrSettingsDialog());
    if (mounted) await _initialize();
  }

  Future<bool> _confirm(String title, String message, String action) async =>
      await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
                title: Text(title),
                content: Text(message),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(_t.cancel)),
                  FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(action)),
                ],
              )) ??
      false;

  Future<void> _recognize() async {
    final canvas = _canvasKey.currentState;
    final provider = _provider;
    if (canvas == null ||
        canvas.isEmpty ||
        provider == null ||
        !provider.isAvailable ||
        _recognizing) {
      return;
    }
    setState(() {
      _recognizing = true;
      _error = null;
    });
    try {
      final terms = (provider as HandwritingOcrProvider).licenseToAccept;
      if (terms != null && !_acceptedLicenses.contains(provider.name)) {
        if (!await _confirm(
            _t.handwritingTermsTitle,
            _t.handwritingTermsBody(provider.name, terms),
            _t.handwritingAcceptTerms)) {
          return;
        }
        _acceptedLicenses.add(provider.name);
      }
      if (!mounted) return;
      if (provider.requiresNetwork &&
          !await _confirm(
              _t.handwritingSendTitle,
              _t.handwritingSendBody(provider.name),
              _t.handwritingSendAction)) {
        return;
      }
      if (!mounted) return;
      setState(() => _runningInference = true);
      final bytes = await canvas.toGrayscaleBytes(384, 384);
      if (bytes == null) throw StateError('Drawing is empty');
      final result = await provider.recognize(bytes, 384, 384);
      if (!mounted) return;
      setState(() => _runningInference = false);
      if (result == null || result.text.trim().isEmpty) {
        setState(() => _error = _t.handwritingNotRecognized);
        return;
      }
      final expression = await showOcrCaptureDialog(context, result);
      if (expression != null && expression.isNotEmpty && mounted) {
        Navigator.pop(context, expression);
      }
    } catch (error) {
      if (mounted) setState(() => _error = _t.handwritingRecognitionFailed('$error'));
    } finally {
      if (mounted) {
        setState(() {
          _recognizing = false;
          _runningInference = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final providers = _available;
    return Dialog(
        child: SizedBox(
      width: math.min(720, screen.width * .9),
      height: math.min(900, screen.height * .85),
      child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(_t.handwritingTitle, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            if (_loading) const LinearProgressIndicator(),
            if (providers.isNotEmpty)
              DropdownButton<OcrProvider>(
                isExpanded: true,
                value: providers.contains(_provider) ? _provider : null,
                hint: Text(_t.handwritingChooseModel),
                onChanged:
                    _recognizing ? null : (p) => setState(() => _provider = p),
                items: [
                  for (final provider in providers)
                    DropdownMenuItem(
                        value: provider,
                        child: Text(provider.name,
                            maxLines: 1, overflow: TextOverflow.ellipsis))
                ],
              ),
            Text(_provider == null
                ? _t.handwritingNoModel
                : _provider!.requiresNetwork
                    ? _t.handwritingCloudNote
                    : _t.handwritingLocalNote),
            Text(_t.handwritingReviewNote),
            const SizedBox(height: 8),
            Expanded(
                child: Semantics(
                    container: true,
                    label: _t.handwritingCanvas,
                    child: LayoutBuilder(
                      builder: (context, constraints) => DrawingCanvas(
                          key: _canvasKey,
                          width: constraints.maxWidth,
                          height: constraints.maxHeight,
                          strokeWidth: 4,
                          strokeColor: Colors.black,
                          backgroundColor: Colors.white),
                    ))),
            if (_error != null)
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(_error!, maxLines: 3)),
            if (_runningInference) const LinearProgressIndicator(),
            Wrap(alignment: WrapAlignment.end, spacing: 8, children: [
              TextButton(
                  onPressed: _recognizing ? null : _models,
                  child: Text(_t.handwritingModels)),
              TextButton(
                  onPressed: _recognizing
                      ? null
                      : () => _canvasKey.currentState?.undo(),
                  child: Text(_t.notepadUndo)),
              TextButton(
                  onPressed: _recognizing
                      ? null
                      : () => _canvasKey.currentState?.clear(),
                  child: Text(_t.sudokuClearCell)),
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(_t.cancel)),
              FilledButton(
                  onPressed:
                      _recognizing || _provider == null ? null : _recognize,
                  child: Text(_t.handwritingRecognize)),
            ]),
          ])),
    ));
  }
}

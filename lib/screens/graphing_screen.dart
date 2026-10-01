// lib/screens/graphing_screen.dart - with LaTeX Input & Keypad

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../engine/graph_inspection.dart';
import '../engine/graph_viewport.dart';
import '../widgets/graph_value_table_dialog.dart';
import 'dart:math' as math;
import 'dart:async';
import 'dart:convert';
import '../engine/graph_sampling.dart';
import '../engine/plot_types.dart' show PlotPt;
import '../services/graph_sampling_service.dart';
import '../controllers/latex_controller.dart';
import '../engine/app_state.dart';
import '../localization/app_localizations.dart';
import '../utils/expression_preprocessing_utils.dart';
import '../utils/keyboard_input_handler.dart';
import '../utils/latex_conversion_utils.dart';
import '../screens/curve_analysis_input_screen.dart';
import '../widgets/calculator_keypad.dart';
import '../widgets/latex_input_field.dart';

/// 2D plot modes (roadmap C5.2).
enum PlotMode { cartesian, parametric, polar, implicit, vectorField }

class GraphingScreen extends StatefulWidget {
  const GraphingScreen({super.key});

  @override
  State<GraphingScreen> createState() => GraphingScreenState();
}

class GraphingScreenState extends State<GraphingScreen>
    with SingleTickerProviderStateMixin {
  final AppState _appState = AppState();
  final LatexController _latexController = LatexController();
  final FocusNode _screenFocusNode = FocusNode(); // For keyboard listener
  late final TabController _tabController;

  // FIX: Start with input unfocused. Focus will be given by MainScreen on tab switch.
  bool _isInputFocused = false;
  // The on-screen keypad starts hidden so the plot has the full graph area.
  // It expands when the user taps the input field, or via the toolbar toggle.
  bool _showKeypad = false;

  // Graph view controls
  double _yRatio = 1;
  Size _plotSize = const Size(600, 400);
  final _undo = GraphUndoHistory<Map<String, dynamic>>();
  bool _fitting = false;
  double _scale = 1.0;
  Offset _offset = Offset.zero;
  double _startScale = 1.0;
  Offset _startOffset = Offset.zero;
  Offset _focalStart = Offset.zero;

  // When true, the painter overlays root and extremum markers on each curve.
  bool _showAnnotations = false;
  bool _interacting = false;
  bool _tracing = false;
  int _traceSlot = 0;

  // Plot mode (roadmap C5.2) + its expressions. Sensible defaults so
  // switching modes immediately shows a recognizable curve.
  PlotMode _plotMode = PlotMode.cartesian;
  final _paramXCtrl = TextEditingController(text: 'cos(t)');
  final _paramYCtrl = TextEditingController(text: 'sin(t)');
  final _polarCtrl = TextEditingController(text: '1 + cos(theta)');
  final _implicitCtrl = TextEditingController(text: 'x^2 + y^2 - 4');
  final _vfUCtrl = TextEditingController(text: '-y');
  final _vfVCtrl = TextEditingController(text: 'x');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    debugPrint("DEBUG: GraphingScreen initState - Screen initialized.");
    // FIX: Removed focus logic from here to prevent it from running at app startup.
  }

  // FIX: Public method for the parent widget (MainScreen) to call.
  void requestFocus() {
    debugPrint("DEBUG: GraphingScreen - requestFocus() called by parent.");
    if (mounted) {
      setState(() => _isInputFocused = true);
      _screenFocusNode.requestFocus();
    }
  }

  /// Plot-mode selector (roadmap C5.2) + expression inputs for the
  /// active non-cartesian mode. Cartesian keeps the classic Y1..Y10 UI.
  Widget _buildPlotModeBar() {
    InputDecoration dec(String label) => InputDecoration(
          labelText: label,
          isDense: true,
          border: const OutlineInputBorder(),
        );
    Widget field(TextEditingController c, String label) => Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: TextField(
              controller: c,
              decoration: dec(label),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
              onChanged: (_) => setState(() {}),
            ),
          ),
        );

    final inputs = switch (_plotMode) {
      PlotMode.cartesian => const SizedBox.shrink(),
      PlotMode.parametric => Row(
          children: [field(_paramXCtrl, 'x(t)'), field(_paramYCtrl, 'y(t)')],
        ),
      PlotMode.polar => Row(children: [field(_polarCtrl, 'r(θ)')]),
      PlotMode.implicit => Row(children: [field(_implicitCtrl, 'F(x, y) = 0')]),
      PlotMode.vectorField => Row(
          children: [
            field(_vfUCtrl, 'dx/dt = u(x,y)'),
            field(_vfVCtrl, 'dy/dt = v(x,y)'),
          ],
        ),
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<PlotMode>(
              showSelectedIcon: false,
              style: const ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              segments: const [
                ButtonSegment(
                  value: PlotMode.cartesian,
                  label: Text('y = f(x)'),
                ),
                ButtonSegment(
                  value: PlotMode.parametric,
                  label: Text('Parametric'),
                ),
                ButtonSegment(value: PlotMode.polar, label: Text('Polar')),
                ButtonSegment(
                  value: PlotMode.implicit,
                  label: Text('Implicit'),
                ),
                ButtonSegment(
                  value: PlotMode.vectorField,
                  label: Text('Vector Field'),
                ),
              ],
              selected: {_plotMode},
              onSelectionChanged: (sel) =>
                  setState(() => _plotMode = sel.first),
            ),
          ),
          if (_plotMode != PlotMode.cartesian)
            Padding(padding: const EdgeInsets.only(top: 6), child: inputs),
        ],
      ),
    );
  }

  @override
  void dispose() {
    debugPrint("DEBUG: GraphingScreen disposing.");
    _latexController.dispose();
    _screenFocusNode.dispose();
    _paramXCtrl.dispose();
    _paramYCtrl.dispose();
    _polarCtrl.dispose();
    _implicitCtrl.dispose();
    _vfUCtrl.dispose();
    _vfVCtrl.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onButtonPressed(String value) {
    if (!_isInputFocused) {
      debugPrint(
        "DEBUG: Input field not focused. Focusing now via button press.",
      );
      setState(() => _isInputFocused = true);
      _screenFocusNode.requestFocus();
    }

    switch (value) {
      case 'C':
        _latexController.clear();
        break;
      case '⌫':
        _latexController.backspace();
        break;
      case 'EXE':
        _addFunction();
        break;
      case '◀':
        _latexController.moveCursor(-1);
        break;
      case '▶':
        _latexController.moveCursor(1);
        break;
      case '/':
        _latexController.insert(r'\frac{}{}', cursorOffsetFromEnd: -3);
        break;
      case 'sqrt':
        _latexController.insert(r'\sqrt{}', cursorOffsetFromEnd: -1);
        break;
      case '^':
        _latexController.insert(r'^{}', cursorOffsetFromEnd: -1);
        break;
      case 'π':
        _latexController.insert(r'\pi');
        break;
      default:
        _latexController.insert(value);
        break;
    }
  }

  bool _handleKeyboardInput(KeyEvent event) {
    if (HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed) {
      return false;
    }
    debugPrint(
      "DEBUG: GraphingScreen _handleKeyboardInput | isFocused: $_isInputFocused",
    );
    if (!_isInputFocused) {
      debugPrint("DEBUG: Input not focused, ignoring key event.");
      return false;
    }

    return KeyboardInputHandler.handleKeyboardInput(
      event,
      (text) => _onButtonPressed(text),
      () => _onButtonPressed('⌫'),
      () => _onButtonPressed('C'),
      () => _addFunction(),
      (amount) => _onButtonPressed(amount > 0 ? '▶' : '◀'),
    );
  }

  void _showAnalysisOptions() {
    final activeFunctions = <String>[];
    final activeFunctionIndices = <int>[];

    for (int i = 0; i < _appState.graphFunctions.length; i++) {
      if (_appState.graphFunctions[i].isNotEmpty) {
        activeFunctions.add(_appState.graphFunctions[i]);
        activeFunctionIndices.add(i);
      }
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppLocalizations.of(context).selectFunctionToAnalyze,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...activeFunctionIndices.map(
              (index) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getColorForFunction(
                    index,
                  ).withValues(alpha: 0.2),
                  child: Text(
                    'Y${index + 1}',
                    style: TextStyle(
                      color: _getColorForFunction(index),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text('Y${index + 1}(x)'),
                subtitle: Text(
                  _appState.graphFunctions[index],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _analyzeFunction(index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _analyzeFunction(int index) {
    final function = _appState.graphFunctions[index];
    if (function.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              CurveAnalysisInputScreen(initialFunction: function),
        ),
      );
    }
  }

  void _addFunction() {
    final t = AppLocalizations.of(context);
    final latexInput = _latexController.text.trim();
    final textToAdd = LatexConversionUtils.fromLatex(latexInput);

    if (textToAdd.isEmpty) return;

    // Reject obviously-malformed input before it lands in a graph
    // slot. The plot painter would otherwise silently render
    // nothing for an unparseable expression like `tan(x` or
    // `1/(x-` and the user gets no feedback. This is a cheap
    // syntactic gate; expressions that parse but evaluate to NaN
    // at every sample point still slip through (e.g.
    // `sqrt(-x^2 - 1)`) — that case is handled by the plot
    // painter's empty-curve render.
    final validationError = _validateGraphInput(textToAdd, t);
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationError),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    final emptySlotIndex = _appState.graphFunctions.indexWhere(
      (f) => f.isEmpty,
    );
    if (emptySlotIndex != -1) {
      _recordGraph();
      _appState.updateFunction(emptySlotIndex, textToAdd);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.functionAdded(emptySlotIndex + 1)),
          duration: const Duration(seconds: 2),
        ),
      );
      _latexController.clear();
      setState(() => _isInputFocused = true);
      _screenFocusNode.requestFocus();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.allSlotsFull),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Cheap syntactic validation for a graph-function string. Returns
  /// a localized error message when the input is obviously broken
  /// (unbalanced parens / brackets / braces, leftover binary
  /// operators), or `null` if the input looks well-formed enough
  /// to attempt plotting. Cosmetic prefix `y=` is allowed.
  String? _validateGraphInput(String input, AppLocalizations t) {
    var src = input.trim();
    if (src.toLowerCase().startsWith('y=')) {
      src = src.substring(2).trim();
    } else if (src.toLowerCase().startsWith('y =')) {
      src = src.substring(3).trim();
    }
    if (src.isEmpty) return t.graphErrorEmpty;

    // Paren / bracket / brace balance.
    var parens = 0, brackets = 0, braces = 0;
    for (var i = 0; i < src.length; i++) {
      final ch = src[i];
      if (ch == '(') parens++;
      if (ch == ')') parens--;
      if (ch == '[') brackets++;
      if (ch == ']') brackets--;
      if (ch == '{') braces++;
      if (ch == '}') braces--;
      if (parens < 0 || brackets < 0 || braces < 0) {
        return t.graphErrorUnbalanced;
      }
    }
    if (parens != 0 || brackets != 0 || braces != 0) {
      return t.graphErrorUnbalanced;
    }

    // Trailing binary operator (`x +`, `x -`, `x *`, `x /`, `x ^`).
    final lastTok = src.replaceAll(RegExp(r'\s+$'), '');
    if (lastTok.isNotEmpty && '+-*/^'.contains(lastTok[lastTok.length - 1])) {
      return t.graphErrorTrailingOperator;
    }

    return null;
  }

  void _removeFunction(String functionToRemove) {
    final t = AppLocalizations.of(context);
    final index = _appState.graphFunctions.indexOf(functionToRemove);
    if (index != -1) {
      _recordGraph();
      _appState.clearFunction(index);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.functionRemoved(index + 1)),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _showLinkedSource(int slot) {
    final source = _appState.linkedGraphResolution(slot);
    showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
                title: Text('Linked source for Y${slot + 1}'),
                content: SizedBox(
                    width: 420,
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SelectableText(source.source),
                          const Text(
                              'x is the graph variable. Other values come from the source document.'),
                          for (final entry in source.scope.entries)
                            Text('${entry.key} = ${entry.value}'),
                          if (source.error != null)
                            Text(source.error!,
                                style: TextStyle(
                                    color: Theme.of(ctx).colorScheme.error)),
                        ])),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _appState.detachGraphSource(slot);
                      },
                      child: const Text('Detach source')),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _appState.requestOpenNotepadSource(slot);
                      },
                      child: const Text('Open source')),
                  TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Close')),
                ]));
  }

  void _recordGraph() {
    _undo.record({
      ..._appState.captureGraphWorkspace(),
      'scale': _scale,
      'yRatio': _yRatio,
      'offset': _offset
    });
  }

  void _undoGraph() {
    final previous = _undo.undo();
    if (previous == null) return;
    _appState.restoreGraphWorkspace(previous);
    setState(() {
      _scale = previous['scale'] as double;
      _yRatio = previous['yRatio'] as double;
      _offset = previous['offset'] as Offset;
    });
  }

  GraphBounds _bounds() {
    final ux = 25 * _scale, uy = ux * _yRatio;
    final cx = _plotSize.width / 2 + _offset.dx,
        cy = _plotSize.height / 2 + _offset.dy;
    return GraphBounds(-cx / ux, (_plotSize.width - cx) / ux,
        (cy - _plotSize.height) / uy, cy / uy);
  }

  void _applyBounds(GraphBounds bounds) {
    _recordGraph();
    setState(() {
      final ux = bounds.unitX(_plotSize.width),
          uy = bounds.unitY(_plotSize.height);
      _scale = ux / 25;
      _yRatio = uy / ux;
      _offset = Offset(-bounds.xMin * ux - _plotSize.width / 2,
          bounds.yMax * uy - _plotSize.height / 2);
    });
  }

  Future<void> _editBounds() async {
    final current = _bounds();
    final controllers = [current.xMin, current.xMax, current.yMin, current.yMax]
        .map((v) => TextEditingController(text: v.toStringAsPrecision(8)))
        .toList();
    String? error;
    final result = await showDialog<GraphBounds>(
        context: context,
        builder: (ctx) => StatefulBuilder(
            builder: (ctx, update) => AlertDialog(
                  title: const Text('Graph bounds'),
                  content: SizedBox(
                      width: 360,
                      child: SingleChildScrollView(
                          child:
                              Column(mainAxisSize: MainAxisSize.min, children: [
                        for (final entry in const [
                          'x minimum',
                          'x maximum',
                          'y minimum',
                          'y maximum'
                        ].indexed)
                          TextField(
                              controller: controllers[entry.$1],
                              decoration: InputDecoration(labelText: entry.$2)),
                        if (error != null)
                          Text(error!,
                              style: TextStyle(
                                  color: Theme.of(ctx).colorScheme.error)),
                      ]))),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel')),
                    FilledButton(
                        onPressed: () {
                          try {
                            final v = controllers
                                .map((c) => double.parse(c.text))
                                .toList();
                            Navigator.pop(
                                ctx, GraphBounds(v[0], v[1], v[2], v[3]));
                          } catch (_) {
                            update(() => error =
                                'Enter finite, increasing x and y bounds.');
                          }
                        },
                        child: const Text('Apply bounds'))
                  ],
                )));
    // Wait for the route animation before releasing its text controllers.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    for (final c in controllers) {
      c.dispose();
    }
    if (mounted && result != null) _applyBounds(result);
  }

  Future<void> _fitGraph() async {
    if (_fitting) return;
    setState(() => _fitting = true);
    try {
      final current = _bounds();
      final xs = List.generate(
          201, (i) => current.xMin + (current.xMax - current.xMin) * i / 200);
      final values = <double?>[];
      for (final slot
          in _appState.graphFunctions.indexed.where((e) => e.$2.isNotEmpty)) {
        final expression = ExpressionPreprocessingUtils.substituteParameters(
            slot.$2, _appState.functionParameters[slot.$1] ?? {});
        values.addAll((await GraphSamplingService.values(expression, xs))
            .map((row) => row[1]));
      }
      final bounds = fittedGraphBounds(current.xMin, current.xMax, values);
      if (mounted) _applyBounds(bounds);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not fit graph: $e')));
      }
    } finally {
      if (mounted) setState(() => _fitting = false);
    }
  }

  void _resetView() {
    _recordGraph();
    setState(() {
      _scale = 1.0;
      _yRatio = 1;
      _offset = Offset.zero;
    });
  }

  void _zoomIn() {
    _recordGraph();
    setState(() {
      _scale = (_scale * 1.4).clamp(1e-12, 1e12);
    });
  }

  void _zoomOut() {
    _recordGraph();
    setState(() {
      _scale = (_scale / 1.4).clamp(1e-12, 1e12);
    });
  }

  void _clearAllFunctions() {
    final t = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.clearAllFunctions),
        content: Text(t.clearAllFunctionsConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(t.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              _recordGraph();
              for (int i = 0; i < _appState.graphFunctions.length; i++) {
                _appState.clearFunction(i);
              }
              Navigator.of(context).pop();
            },
            child: Text(t.clearAll),
          ),
        ],
      ),
    );
  }

  Color _getColorForFunction(int index) {
    const colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.pink,
      Colors.brown,
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _screenFocusNode,
      // autofocus off — let MainScreen drive focus explicitly so we don't have
      // multiple panes fighting for primary focus on the wide-screen layout.
      onKeyEvent: _handleKeyboardInput,
      child: ListenableBuilder(
        listenable: _appState.graphChanges,
        builder: (context, child) {
          final activeFunctions = <String>[];
          final activeFunctionIndices = <int>[];

          for (int i = 0; i < _appState.graphFunctions.length; i++) {
            if (_appState.graphFunctions[i].isNotEmpty) {
              activeFunctions.add(_appState.graphFunctions[i]);
              activeFunctionIndices.add(i);
            }
          }

          return Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              title: Text(
                AppLocalizations.of(
                  context,
                ).graphingTitle(activeFunctions.length),
              ),
              actions: [
                SizedBox(
                    width: MediaQuery.sizeOf(context).width < 720 ? 160 : 540,
                    child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(children: [
                          IconButton(
                              tooltip: 'Graph bounds',
                              icon: const Icon(Icons.crop_free),
                              onPressed: _editBounds),
                          IconButton(
                              tooltip: 'Fit graph',
                              icon: const Icon(Icons.fit_screen),
                              onPressed: _plotMode == PlotMode.cartesian &&
                                      activeFunctions.isNotEmpty &&
                                      !_fitting
                                  ? _fitGraph
                                  : null),
                          IconButton(
                              tooltip: 'Undo graph change',
                              icon: const Icon(Icons.undo),
                              onPressed: _undo.canUndo ? _undoGraph : null),
                          if (_plotMode == PlotMode.cartesian &&
                              activeFunctions.isNotEmpty)
                            IconButton(
                                tooltip: 'Trace curve',
                                icon: Icon(_tracing
                                    ? Icons.gps_fixed
                                    : Icons.gps_not_fixed),
                                onPressed: () =>
                                    setState(() => _tracing = !_tracing)),
                          if (_plotMode == PlotMode.cartesian &&
                              activeFunctions.isNotEmpty)
                            IconButton(
                                tooltip: 'Value table',
                                icon: const Icon(Icons.table_chart_outlined),
                                onPressed: () => showDialog<void>(
                                    context: context,
                                    builder: (_) =>
                                        GraphValueTableDialog(functions: {
                                          for (final i in activeFunctionIndices)
                                            i: ExpressionPreprocessingUtils
                                                .substituteParameters(
                                                    _appState.graphFunctions[i],
                                                    _appState.functionParameters[
                                                            i] ??
                                                        {}),
                                        }))),
                          IconButton(
                            onPressed: _zoomOut,
                            icon: const Icon(Icons.zoom_out),
                            tooltip: AppLocalizations.of(context).zoomOut,
                          ),
                          IconButton(
                            onPressed: _zoomIn,
                            icon: const Icon(Icons.zoom_in),
                            tooltip: AppLocalizations.of(context).zoomIn,
                          ),
                          IconButton(
                            onPressed: _resetView,
                            icon: const Icon(Icons.center_focus_strong),
                            tooltip: AppLocalizations.of(context).resetView,
                          ),
                          if (activeFunctions.isNotEmpty)
                            IconButton(
                              onPressed: _showAnalysisOptions,
                              icon: const Icon(Icons.analytics),
                              tooltip:
                                  AppLocalizations.of(context).analyzeFunctions,
                            ),
                          if (activeFunctions.isNotEmpty)
                            IconButton(
                              onPressed: () => setState(
                                  () => _showAnnotations = !_showAnnotations),
                              icon: Icon(
                                _showAnnotations
                                    ? Icons.bubble_chart
                                    : Icons.bubble_chart_outlined,
                              ),
                              tooltip: _showAnnotations
                                  ? AppLocalizations.of(context).hideAnnotations
                                  : AppLocalizations.of(context)
                                      .showAnnotations,
                            ),
                          IconButton(
                            onPressed: () {
                              setState(() => _showKeypad = !_showKeypad);
                            },
                            icon: Icon(
                              _showKeypad
                                  ? Icons.keyboard_hide_outlined
                                  : Icons.keyboard_outlined,
                            ),
                            tooltip: _showKeypad
                                ? AppLocalizations.of(context).hideKeypad
                                : AppLocalizations.of(context).showKeypad,
                          ),
                          if (activeFunctions.isNotEmpty)
                            IconButton(
                              onPressed: _clearAllFunctions,
                              icon: const Icon(Icons.clear_all),
                              tooltip: AppLocalizations.of(context)
                                  .clearAllFunctions,
                            ),
                        ])))
              ],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  if (_appState.graphLinks.isNotEmpty)
                    SizedBox(
                        height: 38,
                        child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              for (final entry in _appState.graphLinks.entries)
                                TextButton.icon(
                                    icon: const Icon(Icons.link, size: 16),
                                    label: Text(
                                        'Linked Y${entry.key + 1}: ${_appState.notepadDocuments[entry.value.documentId]?.name ?? 'Missing document'}'),
                                    onPressed: () =>
                                        _showLinkedSource(entry.key)),
                            ])),
                  _buildPlotModeBar(),
                  if (_tracing &&
                      activeFunctionIndices.isNotEmpty &&
                      _plotMode == PlotMode.cartesian)
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(children: [
                          DropdownButton<int>(
                              value: activeFunctionIndices.contains(_traceSlot)
                                  ? _traceSlot
                                  : activeFunctionIndices.first,
                              items: [
                                for (final i in activeFunctionIndices)
                                  DropdownMenuItem(
                                      value: i, child: Text('Trace Y${i + 1}'))
                              ],
                              onChanged: (v) =>
                                  setState(() => _traceSlot = v!)),
                          const Expanded(
                              child: Text(
                                  'Tap or drag a curve. Use ← / → to step.',
                                  style: TextStyle(fontSize: 12))),
                        ])),
                  // --- Graph display area ---
                  Expanded(
                    flex: 3,
                    child: GestureDetector(
                      // The plot's raw pointer handlers own tracing and panning.
                      // A semantic tap button over the entire plot consumes web
                      // touch events before they reach those handlers.
                      excludeFromSemantics: true,
                      onTap: () {
                        if (_tracing) return;
                        debugPrint(
                          "DEBUG: Graph area tapped. Unfocusing input field.",
                        );
                        setState(() => _isInputFocused = false);
                        _screenFocusNode.unfocus();
                      },
                      onScaleStart: (details) {
                        if (_tracing) return;
                        _recordGraph();
                        setState(() => _interacting = true);
                        _focalStart = details.localFocalPoint;
                        _startScale = _scale;
                        _startOffset = _offset;
                      },
                      onScaleUpdate: (details) {
                        if (_tracing) return;
                        setState(() {
                          _scale = (_startScale * details.scale).clamp(
                            1e-12,
                            1e12,
                          );
                          _offset = _startOffset +
                              (details.localFocalPoint - _focalStart);
                        });
                      },
                      onScaleEnd: (_) => setState(() => _interacting = false),
                      // FIX: Wrap the CustomPaint with ClipRect to prevent drawing out of bounds.
                      child: ClipRect(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey.shade800,
                              width: 1,
                            ),
                          ),
                          child: LayoutBuilder(builder: (context, constraints) {
                            _plotSize = constraints.biggest;
                            return _SampledGraph(
                              interacting: _interacting,
                              traceIndex: _tracing &&
                                      _plotMode == PlotMode.cartesian &&
                                      activeFunctionIndices.isNotEmpty
                                  ? math.max(0,
                                      activeFunctionIndices.indexOf(_traceSlot))
                                  : null,
                              painter: GraphPainter(
                                functions: _plotMode == PlotMode.cartesian
                                    ? activeFunctions
                                    : const [],
                                functionIndices: _plotMode == PlotMode.cartesian
                                    ? activeFunctionIndices
                                    : const [],
                                plotMode: _plotMode,
                                parametricX: _paramXCtrl.text,
                                parametricY: _paramYCtrl.text,
                                polarR: _polarCtrl.text,
                                implicitF: _implicitCtrl.text,
                                vfU: _vfUCtrl.text,
                                vfV: _vfVCtrl.text,
                                yRatio: _yRatio,
                                scale: _scale,
                                offset: _offset,
                                getColorForFunction: _getColorForFunction,
                                showAnnotations: _showAnnotations,
                                parameters: {
                                  for (final i in activeFunctionIndices)
                                    if (_appState.functionParameters[i] !=
                                            null &&
                                        _appState
                                            .functionParameters[i]!.isNotEmpty)
                                      i: Map<String, double>.from(
                                        _appState.functionParameters[i]!,
                                      ),
                                },
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ),

                  // --- CONTROLS AREA ---
                  const Divider(height: 1),
                  _buildActiveFunctionsList(
                    activeFunctionIndices,
                    activeFunctions,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              debugPrint(
                                "DEBUG: Input field tapped. Focusing for keyboard input.",
                              );
                              setState(() {
                                _isInputFocused = true;
                                _showKeypad = true;
                              });
                              _screenFocusNode.requestFocus();
                            },
                            child: Container(
                              height: 50,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _isInputFocused
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey.shade700,
                                  width: _isInputFocused ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Row(
                                children: [
                                  const Text(
                                    "y = ",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  Expanded(
                                    child: LatexInputField(
                                      controller: _latexController,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add_chart),
                          label: Text(AppLocalizations.of(context).plotButton),
                          onPressed: _addFunction,
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: _showKeypad,
                    child: Expanded(
                      // Smaller flex than the plot so graphed functions still
                      // dominate vertically when the keypad is open.
                      flex: 2,
                      child: CalculatorKeypad(
                        tabController: _tabController,
                        onButtonPressed: _onButtonPressed,
                        localizations: AppLocalizations.of(context),
                        appState: _appState,
                        onVariableTap: (name) => _latexController.insert(name),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActiveFunctionsList(
    List<int> activeFunctionIndices,
    List<String> activeFunctions,
  ) {
    if (activeFunctions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Text(
          AppLocalizations.of(context).enterFunctionPrompt,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
        ),
      );
    }

    // Detect parameters per function. Empty list means no sliders for
    // that function — chip-only rendering keeps the layout compact.
    final paramsPerSlot = <int, List<String>>{};
    for (var i = 0; i < activeFunctionIndices.length; i++) {
      final params = ExpressionPreprocessingUtils.detectParameters(
        activeFunctions[i],
        'x',
      );
      paramsPerSlot[activeFunctionIndices[i]] = params;
      // Drop stale slider state.
      final slot = activeFunctionIndices[i];
      final expression = activeFunctions[i];
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _appState.graphFunctions[slot] == expression) {
          _appState.pruneParameters(slot, params.toSet());
        }
      });
    }

    final anyParams = paramsPerSlot.values.any((p) => p.isNotEmpty);
    final maxHeight = anyParams ? 130.0 : 56.0; // 56 avoids a 6px chip overflow

    return SizedBox(
      height: maxHeight,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        scrollDirection: Axis.horizontal,
        itemCount: activeFunctionIndices.length,
        itemBuilder: (context, index) {
          final funcText = activeFunctions[index];
          final originalIndex = activeFunctionIndices[index];
          final yLabel = 'Y${originalIndex + 1}';
          final color = _getColorForFunction(originalIndex);
          final params = paramsPerSlot[originalIndex] ?? const <String>[];
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Chip(
                  avatar: CircleAvatar(backgroundColor: color, radius: 8),
                  label: SizedBox(
                    width: 140,
                    child: Text(
                      '$yLabel = $funcText',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  backgroundColor: color.withValues(alpha: 0.1),
                  side: BorderSide(color: color, width: 1),
                  onDeleted: () => _removeFunction(funcText),
                  deleteIcon: const Icon(Icons.close, size: 16),
                ),
                if (params.isNotEmpty)
                  SizedBox(
                    width: 180,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final p in params)
                          _ParameterSlider(
                            name: p,
                            value: _appState.getParameter(originalIndex, p),
                            color: color,
                            onChanged: (v) {
                              _recordGraph();
                              _appState.setParameter(originalIndex, p, v);
                            },
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Pre-compiled RegExps for implicit multiplication (hoisted out of hot loop).

class GraphPainter extends CustomPainter {
  final GraphSamples samples;
  final PlotPt? tracePoint;
  final List<String> functions;
  final List<int> functionIndices;
  final double scale;
  final double yRatio;
  final Offset offset;
  final Color Function(int) getColorForFunction;
  final bool showAnnotations;

  /// Per-function parameter values, keyed by the *original* function
  /// slot index (the same indices that live in `functionIndices`).
  /// Empty when no function has any parameters. Substituted in
  /// before `x` when evaluating, so `a*sin(b*x)` plots correctly.
  final Map<int, Map<String, double>> parameters;

  /// Non-cartesian plot mode (roadmap C5.2) and its expressions. In
  /// [PlotMode.cartesian] these are ignored and the Y1..Y10 [functions]
  /// are plotted as before. Sampling is owned by [_SampledGraph], and the
  /// painter only transforms cached geometry for the current viewport.
  final PlotMode plotMode;
  final String parametricX;
  final String parametricY;
  final double tMin;
  final double tMax;
  final String polarR;
  final double thetaMax;
  final String implicitF;
  final String vfU;
  final String vfV;
  final Color specialColor;

  GraphPainter({
    this.samples = const GraphSamples(),
    this.tracePoint,
    required this.functions,
    required this.functionIndices,
    required this.scale,
    this.yRatio = 1,
    required this.offset,
    required this.getColorForFunction,
    this.showAnnotations = false,
    this.parameters = const {},
    this.plotMode = PlotMode.cartesian,
    this.parametricX = '',
    this.parametricY = '',
    this.tMin = 0,
    this.tMax = 6.283185307179586,
    this.polarR = '',
    this.thetaMax = 6.283185307179586,
    this.implicitF = '',
    this.vfU = '',
    this.vfV = '',
    this.specialColor = const Color(0xFF26A69A),
  });

  GraphPainter withSamples(GraphSamples geometry, {PlotPt? tracePoint}) =>
      GraphPainter(
        samples: geometry,
        tracePoint: tracePoint,
        functions: functions,
        functionIndices: functionIndices,
        scale: scale,
        yRatio: yRatio,
        offset: offset,
        getColorForFunction: getColorForFunction,
        showAnnotations: showAnnotations,
        parameters: parameters,
        plotMode: plotMode,
        parametricX: parametricX,
        parametricY: parametricY,
        tMin: tMin,
        tMax: tMax,
        polarR: polarR,
        thetaMax: thetaMax,
        implicitF: implicitF,
        vfU: vfU,
        vfV: vfV,
        specialColor: specialColor,
      );

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2 + offset.dx;
    final centerY = size.height / 2 + offset.dy;
    final double unit = 25 * scale;

    // Draw grid and axes
    _drawGrid(canvas, size, centerX, centerY, unit);
    _drawAxes(canvas, size, centerX, centerY);
    _drawAxisLabels(canvas, size, centerX, centerY, unit);
    _drawSpecialPlots(canvas, size, centerX, centerY, unit);

    // Draw functions
    for (int i = 0; i < functions.length; i++) {
      final func = functions[i];
      final originalIndex = functionIndices[i];
      final color = getColorForFunction(originalIndex);
      final paint = Paint()
        ..color = color
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      try {
        _plotFunction(canvas, size, i, centerX, centerY, unit, paint);
        if (showAnnotations) {
          _drawAnnotations(canvas, size, i, centerX, centerY, unit, color);
        }
      } catch (e) {
        debugPrint('Error plotting function $func: $e');
      }
    }
    final trace = tracePoint;
    if (trace != null && trace.ok) {
      final point =
          Offset(centerX + trace.x * unit, centerY - trace.y * unit * yRatio);
      canvas.drawCircle(point, 5, Paint()..color = Colors.white);
      canvas.drawCircle(
          point,
          5,
          Paint()
            ..color = Colors.black
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2);
    }
  }

  /// Substitute every parameter in [func] for slot [slot] with its
  /// current numeric value. Returns the original string when this slot
  /// has no parameters.
  String _withParameters(String func, int slot) {
    final params = parameters[slot];
    if (params == null || params.isEmpty) return func;
    return ExpressionPreprocessingUtils.substituteParameters(func, params);
  }

  void _drawGrid(
    Canvas canvas,
    Size size,
    double centerX,
    double centerY,
    double unit,
  ) {
    final gridPaint = Paint()
      ..color = Colors.grey.shade700
      ..strokeWidth = 0.5;

    final sx = graphGridStep(unit) * unit;
    final sy = graphGridStep(unit * yRatio) * unit * yRatio;
    for (double x = centerX % sx; x < size.width; x += sx) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = centerY % sy; y < size.height; y += sy) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  void _drawAxes(Canvas canvas, Size size, double centerX, double centerY) {
    final axisPaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 2.0;

    // X-axis
    canvas.drawLine(Offset(0, centerY), Offset(size.width, centerY), axisPaint);
    // Y-axis
    canvas.drawLine(
      Offset(centerX, 0),
      Offset(centerX, size.height),
      axisPaint,
    );
  }

  void _drawAxisLabels(
    Canvas canvas,
    Size size,
    double centerX,
    double centerY,
    double unit,
  ) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final textStyle = TextStyle(color: Colors.grey.shade300, fontSize: 10);

    double getNiceStep(double idealStep) {
      if (idealStep <= 0) return 1.0;
      final double powerOf10 =
          math.pow(10, (math.log(idealStep) / math.ln10).floor()).toDouble();
      final double normalized = idealStep / powerOf10;

      if (normalized < 1.5) return 1.0 * powerOf10;
      if (normalized < 3.5) return 2.0 * powerOf10;
      if (normalized < 7.5) return 5.0 * powerOf10;
      return 10.0 * powerOf10;
    }

    const double pixelsPerLabel = 80.0;
    final double idealStep = pixelsPerLabel / unit;
    final double step = getNiceStep(idealStep);
    final int precision =
        ((step < 1) ? (-math.log(step) / math.ln10).ceil() : 0).clamp(0, 15);

    // X-axis labels
    final double startX = -centerX / unit;
    final double endX = (size.width - centerX) / unit;

    for (double i = (startX / step).floor() * step; i <= endX; i += step) {
      if (i.abs() < step / 100) continue; // Skip origin

      final x = centerX + i * unit;
      if (x < 15 || x > size.width - 15) continue;

      textPainter.text = TextSpan(
        text: i.toStringAsFixed(precision),
        style: textStyle,
      );
      textPainter.layout();

      double labelY = centerY + 8;
      if (labelY > size.height - 20) labelY = centerY - 20;

      textPainter.paint(canvas, Offset(x - textPainter.width / 2, labelY));
    }

    // Y-axis labels
    final unitY = unit * yRatio;
    final stepY = getNiceStep(pixelsPerLabel / unitY);
    final precisionY =
        ((stepY < 1) ? (-math.log(stepY) / math.ln10).ceil() : 0).clamp(0, 15);
    final double startY = -(size.height - centerY) / unitY;
    final double endY = centerY / unitY;

    for (double i = (startY / stepY).floor() * stepY; i <= endY; i += stepY) {
      if (i.abs() < step / 100) continue; // Skip origin

      final y = centerY - i * unitY;
      if (y < 15 || y > size.height - 15) continue;

      textPainter.text = TextSpan(
        text: i.toStringAsFixed(precisionY),
        style: textStyle,
      );
      textPainter.layout();

      double labelX = centerX + 8;
      if (labelX > size.width - 30) labelX = centerX - textPainter.width - 8;

      textPainter.paint(canvas, Offset(labelX, y - textPainter.height / 2));
    }
  }

  void _plotFunction(
    Canvas canvas,
    Size size,
    int index,
    double centerX,
    double centerY,
    double unit,
    Paint paint,
  ) {
    if (index >= samples.curves.length) return;
    final path = Path();
    var pen = false;
    double? lastY;
    for (final pt in samples.curves[index]) {
      final sy = centerY - pt.y * unit * yRatio;
      if (!pt.ok || sy < -size.height * 2 || sy > size.height * 3) {
        pen = false;
        lastY = null;
        continue;
      }
      if (lastY != null && (pt.y - lastY).abs() > 50 / (scale * yRatio)) {
        pen = false;
      }
      final sx = centerX + pt.x * unit;
      if (pen) {
        path.lineTo(sx, sy);
      } else {
        path.moveTo(sx, sy);
      }
      pen = true;
      lastY = pt.y;
    }
    canvas.drawPath(path, paint);
  }

  void _drawAnnotations(
    Canvas canvas,
    Size size,
    int index,
    double centerX,
    double centerY,
    double unit,
    Color color,
  ) {
    // Step 3: draw markers + labels.
    final fillPaint = Paint()..color = color;
    final outlinePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final tp = TextPainter(textDirection: TextDirection.ltr);

    void drawMarker(double mx, double my, String label) {
      final sx = centerX + mx * unit;
      final sy = centerY - my * unit * yRatio;
      if (sx < 0 || sx > size.width || sy < 0 || sy > size.height) return;

      canvas.drawCircle(Offset(sx, sy), 5, fillPaint);
      canvas.drawCircle(Offset(sx, sy), 5, outlinePaint);

      tp.text = TextSpan(
        text: label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          backgroundColor: Colors.black.withValues(alpha: 0.55),
        ),
      );
      tp.layout();
      // Position label above-right of the marker, with a small offset; flip
      // if it would clip the canvas edge.
      double lx = sx + 8;
      double ly = sy - tp.height - 8;
      if (lx + tp.width > size.width - 4) lx = sx - tp.width - 8;
      if (ly < 4) ly = sy + 8;
      tp.paint(canvas, Offset(lx, ly));
    }

    if (index >= samples.markers.length) return;
    for (final marker in samples.markers[index]) {
      final label = marker.kind == 'root'
          ? '(${_fmt(marker.x)}, 0)'
          : '${marker.kind} (${_fmt(marker.x)}, ${_fmt(marker.y)})';
      drawMarker(marker.x, marker.y, label);
    }
  }

  String _fmt(double v) {
    if (v.abs() < 1e-9) return '0';
    final abs = v.abs();
    if (abs >= 1000 || abs < 0.01) return v.toStringAsExponential(2);
    return v.toStringAsFixed(abs >= 10 ? 1 : (abs >= 1 ? 2 : 3));
  }

  /// Draw prepared geometry for the active non-cartesian plot. Math point (mx, my)
  /// maps to screen (centerX + mx*unit, centerY - my*unit).
  void _drawSpecialPlots(
    Canvas canvas,
    Size size,
    double centerX,
    double centerY,
    double unit,
  ) {
    if (plotMode == PlotMode.cartesian) return;
    final paint = Paint()
      ..color = specialColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    Offset toScreen(double mx, double my) =>
        Offset(centerX + mx * unit, centerY - my * unit * yRatio);

    void drawPolyline(List<PlotPt> poly) {
      final path = Path();
      var pen = false;
      for (final pt in poly) {
        if (!pt.ok) {
          pen = false;
          continue;
        }
        final o = toScreen(pt.x, pt.y);
        if (!pen) {
          path.moveTo(o.dx, o.dy);
          pen = true;
        } else {
          path.lineTo(o.dx, o.dy);
        }
      }
      canvas.drawPath(path, paint);
    }

    drawPolyline(samples.special);
    if (plotMode == PlotMode.vectorField) paint.strokeWidth = 1.5;
    for (final seg in samples.segments) {
      canvas.drawLine(
        toScreen(seg.x1, seg.y1),
        toScreen(seg.x2, seg.y2),
        paint,
      );
    }
  }

  Map<String, dynamic> sampleRequest(Size size, bool coarse) {
    final unit = 25 * scale;
    final cx = size.width / 2 + offset.dx;
    final cy = size.height / 2 + offset.dy;
    return {
      'functions': [
        for (var i = 0; i < functions.length; i++)
          _withParameters(functions[i], functionIndices[i]),
      ],
      'mode': plotMode.name,
      'width': size.width,
      'scale': scale,
      'xMin': -cx / unit,
      'xMax': (size.width - cx) / unit,
      'yMin': (cy - size.height) / (unit * yRatio),
      'yMax': cy / (unit * yRatio),
      'coarse': coarse,
      'annotations': showAnnotations,
      'parametricX': parametricX,
      'parametricY': parametricY,
      'tMin': tMin,
      'tMax': tMax,
      'polarR': polarR,
      'thetaMax': thetaMax,
      'implicitF': implicitF,
      'vfU': vfU,
      'vfV': vfV,
    };
  }

  @override
  bool shouldRepaint(covariant GraphPainter oldDelegate) {
    return oldDelegate.tracePoint != tracePoint ||
        !identical(oldDelegate.samples, samples) ||
        oldDelegate.scale != scale ||
        oldDelegate.yRatio != yRatio ||
        oldDelegate.offset != offset ||
        oldDelegate.showAnnotations != showAnnotations ||
        !listEquals(oldDelegate.functions, functions) ||
        !listEquals(oldDelegate.functionIndices, functionIndices) ||
        oldDelegate.plotMode != plotMode ||
        oldDelegate.parametricX != parametricX ||
        oldDelegate.parametricY != parametricY ||
        oldDelegate.polarR != polarR ||
        oldDelegate.thetaMax != thetaMax ||
        oldDelegate.tMin != tMin ||
        oldDelegate.tMax != tMax ||
        oldDelegate.implicitF != implicitF ||
        oldDelegate.vfU != vfU ||
        oldDelegate.vfV != vfV ||
        !_parametersEqual(oldDelegate.parameters, parameters);
  }

  static bool _parametersEqual(
    Map<int, Map<String, double>> a,
    Map<int, Map<String, double>> b,
  ) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      final va = a[key];
      final vb = b[key];
      if (vb == null || !mapEquals(va, vb)) return false;
    }
    return true;
  }
}

/// Compact one-line slider for a single function parameter. Range is
/// fixed at [-10, 10] for V1 — wide enough for typical textbook
/// parameters, narrow enough to feel responsive. The current value is
/// shown inline next to the name; tapping the value would open a
/// numeric input (deferred).
class _ParameterSlider extends StatelessWidget {
  final String name;
  final double value;
  final Color color;
  final ValueChanged<double> onChanged;

  const _ParameterSlider({
    required this.name,
    required this.value,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 18,
          child: Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              activeTrackColor: color,
              thumbColor: color,
            ),
            child: Slider(
              value: value.clamp(-10.0, 10.0),
              min: -10,
              max: 10,
              onChanged: onChanged,
            ),
          ),
        ),
        SizedBox(
          width: 36,
          child: Text(
            value.toStringAsFixed(1),
            style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

/// Owns sampling, throttles gestures, and discards superseded completions.
/// Cached math coordinates remain usable while the viewport changes.
class _SampledGraph extends StatefulWidget {
  final GraphPainter painter;
  final bool interacting;
  final int? traceIndex;
  const _SampledGraph(
      {required this.painter, required this.interacting, this.traceIndex});
  @override
  State<_SampledGraph> createState() => _SampledGraphState();
}

class _SampledGraphState extends State<_SampledGraph> {
  final _traceFocus = FocusNode();
  int? _traceSample;
  final _cache = <String, GraphSamples>{};
  GraphSamples _samples = const GraphSamples();
  String? _key;
  String? _contentKey;
  Timer? _timer;
  int _generation = 0;
  bool _busy = false;
  bool _running = false;
  Map<String, dynamic>? _latestRequest;
  bool _error = false;
  bool _noRealValues = false;

  @override
  void didUpdateWidget(covariant _SampledGraph oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.traceIndex != widget.traceIndex) {
      _traceSample = null;
      if (widget.traceIndex != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted &&
              TickerMode.valuesOf(context).enabled &&
              (ModalRoute.of(context)?.isCurrent ?? true)) {
            _traceFocus.requestFocus();
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _traceFocus.dispose();
    _generation++;
    super.dispose();
  }

  void _schedule(Size size) {
    if (!TickerMode.valuesOf(context).enabled) {
      _timer?.cancel();
      _timer = null;
      _key = null;
      _busy = false;
      _generation++;
      return;
    }
    final request = widget.painter.sampleRequest(size, widget.interacting);
    final key = jsonEncode(request);
    if (key == _key) return;
    _key = key;
    final contentKey = jsonEncode([
      request['functions'],
      request['mode'],
      request['parametricX'],
      request['parametricY'],
      request['polarR'],
      request['implicitF'],
      request['vfU'],
      request['vfV'],
    ]);
    if (_contentKey != contentKey) _samples = const GraphSamples();
    _contentKey = contentKey;
    ++_generation;
    _latestRequest = request;
    _error = false;
    _noRealValues = false;
    final hit = _cache.remove(key);
    if (hit != null) {
      _cache[key] = hit;
      _samples = hit;
      _noRealValues = hit.curves.isNotEmpty &&
          hit.curves.every((c) => c.every((p) => !p.ok));
      _busy = false;
      _timer?.cancel();
      _timer = null;
      return;
    }
    _busy = true;
    // Throttle rather than debounce: continuous drags still get coarse
    // updates. Only one job runs; edits during it replace the pending job.
    if (_timer == null && !_running) {
      _timer = Timer(
          Duration(milliseconds: widget.interacting ? 40 : 0), _runLatest);
    }
  }

  Future<void> _runLatest() async {
    _timer = null;
    if (!mounted || !_busy || _running) return;
    final generation = _generation;
    final key = _key!;
    final request = _latestRequest!;
    _running = true;
    try {
      final samples = await GraphSamplingService.graph(request);
      if (!mounted) return;
      _cache[key] = samples;
      if (_cache.length > 8) _cache.remove(_cache.keys.first);
      if (generation == _generation) {
        setState(() {
          _samples = samples;
          _busy = false;
          _noRealValues = samples.curves.isNotEmpty &&
              samples.curves.every((c) => c.every((p) => !p.ok));
        });
      }
    } catch (_) {
      if (mounted && generation == _generation) {
        setState(() {
          _busy = false;
          _error = true;
        });
      }
    } finally {
      _running = false;
      if (mounted && _busy && generation != _generation) {
        _timer = Timer(
            Duration(milliseconds: widget.interacting ? 40 : 0), _runLatest);
      }
    }
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          _schedule(constraints.biggest);
          final t = AppLocalizations.of(context);
          final points = widget.traceIndex != null &&
                  widget.traceIndex! < _samples.curves.length
              ? _samples.curves[widget.traceIndex!]
              : const <PlotPt>[];
          final index = points.isEmpty
              ? null
              : (_traceSample ?? traceSampleIndex(points, 0) ?? 0)
                  .clamp(0, points.length - 1);
          final trace = index == null ? null : points[index];
          final painter =
              widget.painter.withSamples(_samples, tracePoint: trace);
          void locate(Offset local) {
            if (points.isEmpty) return;
            _traceFocus.requestFocus();
            final x =
                (local.dx - constraints.maxWidth / 2 - painter.offset.dx) /
                    (25 * painter.scale);
            setState(() => _traceSample = traceSampleIndex(points, x));
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              Focus(
                  includeSemantics: false,
                  focusNode: _traceFocus,
                  onKeyEvent: (_, event) {
                    if (event is! KeyDownEvent || index == null) {
                      return KeyEventResult.ignored;
                    }
                    final delta =
                        event.logicalKey == LogicalKeyboardKey.arrowRight
                            ? 1
                            : event.logicalKey == LogicalKeyboardKey.arrowLeft
                                ? -1
                                : 0;
                    if (delta == 0) return KeyEventResult.ignored;
                    setState(() => _traceSample =
                        (index + delta).clamp(0, points.length - 1));
                    return KeyEventResult.handled;
                  },
                  child: Listener(
                      onPointerDown: widget.traceIndex == null
                          ? null
                          : (e) => locate(e.localPosition),
                      onPointerMove: widget.traceIndex == null
                          ? null
                          : (e) => locate(e.localPosition),
                      child: RepaintBoundary(
                          child: CustomPaint(painter: painter)))),
              if (widget.traceIndex != null)
                Positioned(
                    top: 6,
                    left: 8,
                    child: IgnorePointer(
                        child: Material(
                            color: Theme.of(context).colorScheme.surface,
                            child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Text(
                                    trace == null
                                        ? 'Trace: waiting for samples'
                                        : 'x = ${trace.x.toStringAsPrecision(6)}, y = ${trace.ok ? trace.y.toStringAsPrecision(6) : 'undefined'}',
                                    key: const ValueKey(
                                        'graph-trace-readout')))))),
              if (_error || _noRealValues)
                Positioned(
                    bottom: 8,
                    left: 8,
                    right: 8,
                    child: Material(
                        color: Theme.of(context).colorScheme.surface,
                        child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(_error
                                      ? t.graphSamplingFailed
                                      : t.graphNoRealValues),
                                  if (_error)
                                    TextButton(
                                        onPressed: () => setState(() {
                                              _key = null;
                                              _error = false;
                                            }),
                                        child: Text(t.graphRetry)),
                                ])))),
              if (_busy)
                Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Semantics(
                        label: t.graphSampling,
                        child: ColoredBox(
                            color: Theme.of(context).colorScheme.primary,
                            child: const SizedBox(height: 2)))),
            ],
          );
        },
      );
}

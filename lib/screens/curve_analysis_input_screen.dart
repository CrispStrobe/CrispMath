/// lib/screens/curve_analysis_input_screen.dart
/// Input screen for the curve sketching module (Kurvendiskussion).

import 'package:flutter/material.dart';
import '../engine/calculator_engine.dart';
import '../engine/analysis_engine.dart';
import '../engine/app_state.dart';
import 'curve_analysis_results_screen.dart';

class CurveAnalysisInputScreen extends StatefulWidget {
  final String? initialFunction;
  
  const CurveAnalysisInputScreen({super.key, this.initialFunction});

  @override
  State<CurveAnalysisInputScreen> createState() => _CurveAnalysisInputScreenState();
}

class _CurveAnalysisInputScreenState extends State<CurveAnalysisInputScreen> {
  late final TextEditingController _controller;
  final AppState _appState = AppState();
  
  // The input screen needs both engines to perform the analysis.
  final _calculatorEngine = CalculatorEngine();
  late final AnalysisEngine _analysisEngine;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialFunction ?? 'x^3 - 3*x');
    _analysisEngine = AnalysisEngine(_calculatorEngine);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Runs the analysis and navigates to the results screen.
  Future<void> _runAnalysis() async {
    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a function.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Call the main Dart-based analysis method.
      final results = await _analysisEngine.performCurveAnalysis(_controller.text);
      
      if (mounted) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => CurveAnalysisResultsScreen(
            results: results,
            onSaveAsFunction: _saveAsFunction,
            onSaveResultAsVariable: _saveResultAsVariable,
          ),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error during analysis: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _saveAsFunction() {
    final function = _controller.text.trim();
    if (function.isEmpty) return;

    // Find first empty function slot
    for (int i = 0; i < _appState.graphFunctions.length; i++) {
      if (_appState.graphFunctions[i].isEmpty) {
        _appState.updateFunction(i, function);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved as Y${i + 1}')),
        );
        return;
      }
    }
    
    // If no empty slots, ask user to confirm overwrite
    _showOverwriteFunctionDialog(function);
  }

  void _saveResultAsVariable(String name, String value) {
    _appState.setVariable(name, value);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved $name = $value')),
    );
  }

  void _showOverwriteFunctionDialog(String function) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('All function slots are full'),
        content: const Text('Which function would you like to replace?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ...List.generate(_appState.graphFunctions.length, (i) => TextButton(
            onPressed: () {
              _appState.updateFunction(i, function);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Replaced Y${i + 1}')),
              );
            },
            child: Text('Y${i + 1}${_appState.graphFunctions[i].isNotEmpty ? ' (${_appState.graphFunctions[i]})' : ''}'),
          )),
        ],
      ),
    );
  }

  void _selectFromFunctions() {
    final nonEmptyFunctions = _appState.graphFunctions.asMap().entries
        .where((entry) => entry.value.isNotEmpty)
        .toList();

    if (nonEmptyFunctions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No saved functions available')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Select Function to Analyze',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...nonEmptyFunctions.map((entry) => ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.withOpacity(0.2),
                child: Text('Y${entry.key + 1}'),
              ),
              title: Text('Y${entry.key + 1}(x)'),
              subtitle: Text(entry.value, maxLines: 1, overflow: TextOverflow.ellipsis),
              onTap: () {
                _controller.text = entry.value;
                Navigator.of(context).pop();
              },
            )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Curve Sketching'),
        actions: [
          IconButton(
            icon: const Icon(Icons.functions),
            tooltip: 'Select from saved functions',
            onPressed: _selectFromFunctions,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Enter a function to analyze:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    style: const TextStyle(fontSize: 18),
                    decoration: const InputDecoration(
                      labelText: 'Function f(x)',
                      border: OutlineInputBorder(),
                      prefixText: 'f(x) = ',
                    ),
                    onSubmitted: (_) => _runAnalysis(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.save),
                  tooltip: 'Save as function',
                  onPressed: _saveAsFunction,
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton.icon(
                onPressed: _runAnalysis,
                icon: const Icon(Icons.analytics_outlined),
                label: const Text('Analyze'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
/// lib/screens/function_editor_screen.dart
import 'package:flutter/material.dart';
import '../engine/app_state.dart';
import '../widgets/variable_viewer.dart';
import 'curve_analysis_input_screen.dart';

class FunctionEditorScreen extends StatefulWidget {
  const FunctionEditorScreen({super.key});

  @override
  State<FunctionEditorScreen> createState() => _FunctionEditorScreenState();
}

class _FunctionEditorScreenState extends State<FunctionEditorScreen> {
  final AppState _appState = AppState();
  late final List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      _appState.graphFunctions.length,
      (index) => TextEditingController(text: _appState.graphFunctions[index]),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _analyzeFunction(int index) {
    final function = _appState.graphFunctions[index];
    if (function.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CurveAnalysisInputScreen(initialFunction: function),
        ),
      );
    }
  }

  void _insertVariable(String name) {
    // Get the currently focused text field and insert the variable name
    final currentFocus = FocusScope.of(context).focusedChild;
    if (currentFocus != null) {
      for (int i = 0; i < _controllers.length; i++) {
        if (_controllers[i].selection.isValid) {
          final controller = _controllers[i];
          final selection = controller.selection;
          final newText = controller.text.replaceRange(
            selection.start,
            selection.end,
            name,
          );
          controller.value = TextEditingValue(
            text: newText,
            selection: TextSelection.collapsed(offset: selection.start + name.length),
          );
          _appState.updateFunction(i, newText.trim());
          break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _appState,
      builder: (context, child) {
        // Ensure controllers are in sync with the model if changed elsewhere
        for (int i = 0; i < _controllers.length; i++) {
          if (_controllers[i].text != _appState.graphFunctions[i]) {
            _controllers[i].text = _appState.graphFunctions[i];
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Function Editor (Y=)'),
            actions: [
              IconButton(
                icon: const Icon(Icons.analytics),
                tooltip: 'Analyze Functions',
                onPressed: () {
                  // Show list of functions to analyze
                  _showAnalysisOptions();
                },
              ),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              // Responsive layout - use column on narrow screens
              final isNarrow = constraints.maxWidth < 800;
              
              if (isNarrow) {
                return Column(
                  children: [
                    // Function list (top)
                    Expanded(
                      flex: 2,
                      child: _buildFunctionList(),
                    ),
                    
                    // Variable viewer (bottom)
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: Colors.grey.shade300)),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            color: Colors.grey.shade100,
                            child: const Row(
                              children: [
                                Icon(Icons.storage, size: 16),
                                SizedBox(width: 8),
                                Text('Variables & Functions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              ],
                            ),
                          ),
                          Expanded(
                            child: VariableViewer(
                              appState: _appState,
                              onVariableTap: _insertVariable,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              } else {
                return Row(
                  children: [
                    // Function list (left side)
                    Expanded(
                      flex: 2,
                      child: _buildFunctionList(),
                    ),
                    
                    // Variable viewer (right side)
                    SizedBox(
                      width: 300,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(left: BorderSide(color: Colors.grey.shade300)),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              color: Colors.grey.shade100,
                              child: const Row(
                                children: [
                                  Icon(Icons.storage, size: 20),
                                  SizedBox(width: 8),
                                  Text('Variables & Functions', style: TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            Expanded(
                              child: VariableViewer(
                                appState: _appState,
                                onVariableTap: _insertVariable,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildFunctionList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12.0),
      itemCount: _controllers.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controllers[index],
                  decoration: InputDecoration(
                    prefixIcon: Container(
                      width: 60,
                      alignment: Alignment.center,
                      child: Text(
                        'Y${index + 1}',
                        style: TextStyle(
                          color: _getColorForFunction(index),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    labelText: 'Y${index + 1}(x)',
                    hintText: 'Enter a function of x',
                    border: const OutlineInputBorder(),
                    suffixIcon: _controllers[index].text.isNotEmpty 
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.analytics, size: 20),
                              tooltip: 'Analyze this function',
                              onPressed: () => _analyzeFunction(index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              onPressed: () => _appState.clearFunction(index),
                            ),
                          ],
                        )
                      : null,
                  ),
                  onChanged: (value) => _appState.updateFunction(index, value.trim()),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAnalysisOptions() {
    final nonEmptyFunctions = _appState.graphFunctions.asMap().entries
        .where((entry) => entry.value.isNotEmpty)
        .toList();

    if (nonEmptyFunctions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No functions defined to analyze')),
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
                backgroundColor: _getColorForFunction(entry.key).withOpacity(0.2),
                child: Text(
                  'Y${entry.key + 1}',
                  style: TextStyle(
                    color: _getColorForFunction(entry.key),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text('Y${entry.key + 1}(x)'),
              subtitle: Text(entry.value, maxLines: 1, overflow: TextOverflow.ellipsis),
              onTap: () {
                Navigator.of(context).pop();
                _analyzeFunction(entry.key);
              },
            )),
          ],
        ),
      ),
    );
  }

  Color _getColorForFunction(int index) {
    const colors = [
      Colors.blue, Colors.red, Colors.green, Colors.purple,
      Colors.orange, Colors.teal, Colors.pink, Colors.brown,
    ];
    return colors[index % colors.length];
  }
}
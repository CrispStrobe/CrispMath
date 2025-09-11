/// lib/widgets/function_picker_dialogs.dart
/// Dialogs for selecting and managing functions

import 'package:flutter/material.dart';
import '../engine/app_state.dart';
import '../utils/keyboard_input_handler.dart';

class FunctionPickerDialogs {
  static void showSolveFunctionPicker(
    BuildContext context,
    AppState appState,
    Function(String) onInsert,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Select equation or continue typing:', 
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.keyboard_return),
                title: const Text('Continue Typing'),
                onTap: () => Navigator.of(context).pop(),
              ),
              const Divider(),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: appState.graphFunctions.asMap().entries
                    .where((e) => e.value.isNotEmpty)
                    .map((e) => ListTile(
                      title: Text('Solve Y${e.key + 1} = 0'),
                      subtitle: Text('where Y${e.key + 1} = ${e.value}'),
                      onTap: () {
                        Navigator.of(context).pop();
                        final textToInsert = 'Y${e.key+1}=0, x';
                        onInsert(textToInsert);
                      },
                    )).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static void showFunctionPicker(
    BuildContext context,
    AppState appState,
    Function(String) onInsert,
  ) {
    final List<Widget> options = appState.graphFunctions.asMap().entries
      .where((entry) => entry.value.isNotEmpty)
      .map((entry) {
        int index = entry.key;
        String func = entry.value;
        return ListTile(
          title: Text('Y${index + 1} = $func'),
          onTap: () {
            Navigator.of(context).pop();
            onInsert('Y${index+1}()');
          },
        );
      }).toList();

    _showPicker(
      context: context,
      title: 'Select function or continue typing:',
      options: options,
    );
  }

  static void _showPicker({
    required BuildContext context,
    required String title,
    required List<Widget> options,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(title, style: Theme.of(context).textTheme.titleMedium),
              ),
              ListTile(
                leading: const Icon(Icons.keyboard_return),
                title: const Text('Continue Typing'),
                subtitle: const Text('Dismiss this panel'),
                onTap: () => Navigator.of(context).pop(),
              ),
              const Divider(),
              Flexible(child: ListView(shrinkWrap: true, children: options)),
            ],
          ),
        );
      },
    );
  }

  static Future<String?> showIntegralDialog(BuildContext context) async {
    return await showDialog<String>(
      context: context,
      builder: (context) => IntegralDialog(),
    );
  }

  static Future<String?> showNthRootDialog(BuildContext context) async {
    return await showDialog<String>(
      context: context,
      builder: (context) => NthRootDialog(),
    );
  }

  static Future<String?> showLimitDialog(BuildContext context) async {
    return await showDialog<String>(
      context: context,
      builder: (context) => LimitDialog(),
    );
  }
}

class IntegralDialog extends StatefulWidget {
  @override
  State<IntegralDialog> createState() => _IntegralDialogState();
}

class _IntegralDialogState extends State<IntegralDialog> {
  final _functionController = TextEditingController();
  final _variableController = TextEditingController(text: 'x');
  final _lowerController = TextEditingController();
  final _upperController = TextEditingController();
  bool _isDefinite = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Integral'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _functionController,
            decoration: const InputDecoration(labelText: 'Function f(x)'),
            autofocus: true,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _variableController,
            decoration: const InputDecoration(labelText: 'Variable'),
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            title: const Text('Definite Integral'),
            value: _isDefinite,
            onChanged: (value) => setState(() => _isDefinite = value!),
          ),
          if (_isDefinite) ...[
            TextField(
              controller: _lowerController,
              decoration: const InputDecoration(labelText: 'Lower Bound'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _upperController,
              decoration: const InputDecoration(labelText: 'Upper Bound'),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final func = _functionController.text;
            final variable = _variableController.text;
            
            String result;
            if (_isDefinite && _lowerController.text.isNotEmpty && _upperController.text.isNotEmpty) {
              result = r'\int_{' + _lowerController.text + r'}^{' + _upperController.text + r'} ' + func + r' d' + variable;
            } else {
              result = r'\int ' + func + r' d' + variable;
            }
            
            Navigator.of(context).pop(result);
          },
          child: const Text('Insert'),
        ),
      ],
    );
  }
}

class NthRootDialog extends StatefulWidget {
  @override
  State<NthRootDialog> createState() => _NthRootDialogState();
}

class _NthRootDialogState extends State<NthRootDialog> {
  final _expressionController = TextEditingController();
  final _rootController = TextEditingController(text: '3');

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nth Root'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _expressionController,
            decoration: const InputDecoration(labelText: 'Expression'),
            autofocus: true,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _rootController,
            decoration: const InputDecoration(labelText: 'Root (n)'),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final expr = _expressionController.text;
            final root = _rootController.text;
            final result = r'\sqrt[' + root + r']{' + expr + r'}';
            Navigator.of(context).pop(result);
          },
          child: const Text('Insert'),
        ),
      ],
    );
  }
}

class LimitDialog extends StatefulWidget {
  @override
  State<LimitDialog> createState() => _LimitDialogState();
}

class _LimitDialogState extends State<LimitDialog> {
  final _functionController = TextEditingController();
  final _variableController = TextEditingController(text: 'x');
  final _approachesController = TextEditingController(text: '0');

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Limit'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _functionController,
            decoration: const InputDecoration(labelText: 'Function f(x)'),
            autofocus: true,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _variableController,
            decoration: const InputDecoration(labelText: 'Variable'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _approachesController,
            decoration: const InputDecoration(labelText: 'Approaches'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final func = _functionController.text;
            final variable = _variableController.text;
            final approaches = _approachesController.text;
            final result = r'\lim_{' + variable + r' \to ' + approaches + r'} ' + func;
            Navigator.of(context).pop(result);
          },
          child: const Text('Insert'),
        ),
      ],
    );
  }
}
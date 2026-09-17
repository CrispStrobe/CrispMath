import 'dart:io';

void main() {
  final file = File('lib/main.dart');
  var content = file.readAsStringSync();
  
  if (!content.contains('_OnnxSettingsCard')) {
    content = content.replaceFirst("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:crisp_math/services/ai_service.dart' deferred as ai;");
    
    final onnxCardCode = '''
class _OnnxSettingsCard extends StatefulWidget {
  @override
  State<_OnnxSettingsCard> createState() => _OnnxSettingsCardState();
}

class _OnnxSettingsCardState extends State<_OnnxSettingsCard> {
  bool _isLoading = false;
  String _status = "Not loaded (Optional AI)";

  void _loadOnnx() async {
    setState(() {
      _isLoading = true;
      _status = "Loading ONNX Runtime...";
    });
    
    await ai.loadLibrary();
    final aiService = ai.aiService;
    
    await aiService.initializeOptionalAi();
    
    setState(() {
      _isLoading = false;
      _status = aiService.isReady ? "Ready (CoreML / NNAPI available)" : "Failed to load";
    });
  }

  void _showNlpDialog() {
    final ctl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Test Math NLP"),
          content: TextField(
            controller: ctl,
            decoration: const InputDecoration(hintText: "e.g. Integrate x squared"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                final aiService = ai.aiService;
                final result = await aiService.processMathNLP(ctl.text);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result ?? '')));
                }
              },
              child: const Text("Solve"),
            )
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.memory, semanticLabel: 'AI Engine'),
        title: const Text('Local Math AI Engine (ONNX)'),
        subtitle: Text(_status),
        trailing: _isLoading 
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
            : OutlinedButton(
                onPressed: _status.contains("Ready") ? _showNlpDialog : _loadOnnx,
                child: Text(_status.contains("Ready") ? 'Test' : 'Initialize'),
              ),
      ),
    );
  }
}
''';

    // Insert before _CrispAssistSettingsCard
    content = content.replaceFirst('class _CrispAssistSettingsCard', onnxCardCode + '\nclass _CrispAssistSettingsCard');
    
    // Add the card to the list view right before CrispAssist
    content = content.replaceFirst('_CrispAssistSettingsCard(appState: appState),', 
                                  '_OnnxSettingsCard(),\n              const SizedBox(height: 16),\n              _CrispAssistSettingsCard(appState: appState),');
    
    file.writeAsStringSync(content);
    print("Added _OnnxSettingsCard to lib/main.dart with proper syntax");
  } else {
    print("Already added.");
  }
}

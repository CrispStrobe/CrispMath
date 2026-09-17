import 'dart:io';

void main() {
  final file = File('lib/main.dart');
  var content = file.readAsStringSync();
  
  if (!content.contains('_showNlpDialog')) {
    final methodCode = '''
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
                final aiService = (await import('package:crisp_math/services/ai_service.dart' deferred as ai)).aiService;
                final result = await aiService.processMathNLP(ctl.text);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result ?? '')));
              },
              child: const Text("Solve"),
            )
          ],
        );
      }
    );
  }
''';

    // Insert method inside _OnnxSettingsCardState
    content = content.replaceFirst('  @override\n  Widget build(BuildContext context) {', methodCode + '\n  @override\n  Widget build(BuildContext context) {');
    
    // Replace the trailing button to show "Test" if ready
    content = content.replaceFirst(
      "onPressed: _status.contains(\"Ready\") ? null : _loadOnnx,",
      "onPressed: _status.contains(\"Ready\") ? _showNlpDialog : _loadOnnx,"
    );
    content = content.replaceFirst(
      "child: const Text('Initialize'),",
      "child: Text(_status.contains(\"Ready\") ? 'Test' : 'Initialize'),"
    );
    
    // Fix the duplicate import syntax issue again in the dialog
    content = content.replaceAll(
      "final aiService = (await import('package:crisp_math/services/ai_service.dart' deferred as ai)).aiService;",
      "final aiService = ai.aiService;"
    );
    
    file.writeAsStringSync(content);
    print("Patched lib/main.dart with test dialog");
  } else {
    print("Already patched.");
  }
}

import 'dart:io';

void main() {
  final file = File('lib/main.dart');
  var content = file.readAsStringSync();
  
  if (!content.contains("import 'package:crisp_math/services/ai_service.dart' deferred as ai;")) {
    content = content.replaceFirst("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:crisp_math/services/ai_service.dart' deferred as ai;");
  }
  
  content = content.replaceAll(
    "final aiService = (await import('package:crisp_math/services/ai_service.dart' deferred as ai)).aiService;", 
    "await ai.loadLibrary();\n    final aiService = ai.aiService;"
  );
  
  file.writeAsStringSync(content);
}

import 'dart:io';

/// Resolve desktop OCR libraries beside the installed application. Returning
/// null preserves the plugin's normal Android/iOS and development lookup.
String? findBundledOcrLibrary({String? executable, String? operatingSystem}) {
  final directory = File(executable ?? Platform.resolvedExecutable).parent;
  switch (operatingSystem ?? Platform.operatingSystem) {
    case 'linux':
      final library = File('${directory.path}/lib/libcrispembed.so');
      return library.existsSync() ? library.path : null;
    case 'windows':
      final library = File('${directory.path}/crispembed.dll');
      return library.existsSync() ? library.path : null;
    case 'macos':
      final frameworks = Directory('${directory.parent.path}/Frameworks');
      if (!frameworks.existsSync()) return null;
      final libraries = frameworks
          .listSync()
          .whereType<File>()
          .where((file) => RegExp(r'^libcrispembed(\.\d+)*\.dylib$')
              .hasMatch(file.uri.pathSegments.last))
          .toList()
        ..sort((a, b) => a.path.length.compareTo(b.path.length));
      return libraries.isEmpty ? null : libraries.first.path;
    default:
      return null;
  }
}

final String? bundledOcrLibraryPath = findBundledOcrLibrary();

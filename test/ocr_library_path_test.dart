import 'dart:io';

import 'package:crisp_math/services/ocr_library_path.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory root;
  setUp(() => root = Directory.systemTemp.createTempSync('crispmath-library-'));
  tearDown(() => root.deleteSync(recursive: true));

  void create(String relative) {
    final file = File('${root.path}/$relative');
    file.parent.createSync(recursive: true);
    file.writeAsStringSync('library');
  }

  test('Linux resolves the library inside the application bundle', () {
    create('bundle/lib/libcrispembed.so');
    expect(
        findBundledOcrLibrary(
            executable: '${root.path}/bundle/crisp_math',
            operatingSystem: 'linux'),
        '${root.path}/bundle/lib/libcrispembed.so');
  });

  test('Windows resolves the DLL beside the application', () {
    create('bundle/crispembed.dll');
    expect(
        findBundledOcrLibrary(
            executable: '${root.path}/bundle/crisp_math.exe',
            operatingSystem: 'windows'),
        '${root.path}/bundle/crispembed.dll');
  });

  test('macOS resolves the versioned CocoaPods library', () {
    create('App.app/Contents/Frameworks/libcrispembed.0.dylib');
    create('App.app/Contents/Frameworks/libggml.0.dylib');
    expect(
        findBundledOcrLibrary(
            executable: '${root.path}/App.app/Contents/MacOS/crisp_math',
            operatingSystem: 'macos'),
        '${root.path}/App.app/Contents/Frameworks/libcrispembed.0.dylib');
  });

  test('macOS prefers the unversioned library when it is provided', () {
    create('App.app/Contents/Frameworks/libcrispembed.dylib');
    create('App.app/Contents/Frameworks/libcrispembed.0.dylib');
    expect(
        findBundledOcrLibrary(
            executable: '${root.path}/App.app/Contents/MacOS/crisp_math',
            operatingSystem: 'macos'),
        '${root.path}/App.app/Contents/Frameworks/libcrispembed.dylib');
  });

  for (final os in ['linux', 'windows', 'macos', 'android', 'ios']) {
    test('$os preserves default lookup when no desktop library is present', () {
      expect(
          findBundledOcrLibrary(
              executable: '${root.path}/crisp_math', operatingSystem: os),
          isNull);
    });
  }
}

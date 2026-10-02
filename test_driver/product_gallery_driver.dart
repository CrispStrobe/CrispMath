import 'dart:io';
import '../tool/screenshot_png.dart';
import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  final directory = Directory(
      Platform.environment['CRISPMATH_GALLERY_OUTPUT'] ?? 'native-gallery');
  await directory.create(recursive: true);
  await integrationDriver(onScreenshot: (name, bytes, [args]) async {
    await Directory('${directory.path}/raw').create(recursive: true);
    await File('${directory.path}/raw/$name.png').writeAsBytes(bytes);
    await File('${directory.path}/$name.png')
        .writeAsBytes(encodeOpaqueScreenshot(bytes));
    return bytes.isNotEmpty;
  }, responseDataCallback: (data) async {
    await writeResponseData(
        data == null
            ? null
            : {
                for (final e in data.entries)
                  if (e.key != 'screenshots') e.key: e.value
              },
        destinationDirectory: directory.path,
        testOutputFilename: 'native-evidence');
  });
}

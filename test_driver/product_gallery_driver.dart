import 'dart:io';
import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  final directory = Directory(
      Platform.environment['CRISPMATH_GALLERY_OUTPUT'] ?? 'native-gallery');
  await directory.create(recursive: true);
  await integrationDriver(onScreenshot: (name, bytes, [args]) async {
    await File('${directory.path}/$name.png').writeAsBytes(bytes);
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

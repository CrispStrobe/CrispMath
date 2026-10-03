import 'dart:io';
import 'screenshot_png.dart';

void main(List<String> args) {
  if (args.length != 1) {
    stderr.writeln('Usage: dart run tool/encode_native_gallery.dart DIRECTORY');
    exitCode = 2;
    return;
  }
  final directory = Directory(args.single);
  for (final profile in ['iphone', 'ipad']) {
    final folder = Directory('${directory.path}/$profile');
    for (final file in folder
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.png'))) {
      final original = file.readAsBytesSync();
      final encoded = encodeOpaqueScreenshot(original);
      final raw = Directory('${folder.path}/raw')..createSync();
      File('${raw.path}/${file.uri.pathSegments.last}')
          .writeAsBytesSync(original);
      file.writeAsBytesSync(encoded);
      stdout.writeln(file.path);
    }
  }
}

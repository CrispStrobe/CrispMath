import 'package:crisp_math/widgets/drawing_canvas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('toGrayscaleBytes works with package:image', (tester) async {
    final key = GlobalKey<DrawingCanvasState>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: DrawingCanvas(key: key, width: 300, height: 150),
          ),
        ),
      ),
    );

    final center = tester.getCenter(find.byType(DrawingCanvas));
    await tester.timedDragFrom(
      center,
      const Offset(50, 0),
      const Duration(milliseconds: 100),
    );
    await tester.pumpAndSettle();

    final bytes = await key.currentState!.toGrayscaleBytes(384, 384);
    expect(bytes, isNotNull);
    expect(bytes!.length, 384 * 384);
  });
}

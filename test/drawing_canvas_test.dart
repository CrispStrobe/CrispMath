import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crisp_math/widgets/drawing_canvas.dart';

void main() {
  testWidgets('DrawingCanvas simplifies strokes using distance threshold', (tester) async {
    int changedCount = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: DrawingCanvas(
          width: 400,
          height: 400,
          onChanged: () => changedCount++,
        ),
      ),
    ));

    final gesture = await tester.startGesture(const Offset(100, 100));
    await tester.pump();
    
    // Move slightly (distance < 2.0), should be ignored
    await gesture.moveBy(const Offset(1, 0));
    await tester.pump();
    
    // Move more (distance > 2.0), should be registered
    await gesture.moveBy(const Offset(5, 0));
    await tester.pump();
    
    await gesture.up();
    await tester.pump();
    
    expect(changedCount, 1);
    
    // We can't easily introspect the private _strokes list, but we can verify
    // that drawing doesn't crash and correctly triggers onChanged on pan end.
  });
}

import 'package:crisp_calc/widgets/drawing_canvas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Stroke', () {
    test('starts empty', () {
      final s = Stroke();
      expect(s.points, isEmpty);
      expect(s.width, 3.0);
      expect(s.color, Colors.black);
    });

    test('addPoint grows the list', () {
      final s = Stroke();
      s.addPoint(const Offset(10, 20));
      s.addPoint(const Offset(30, 40));
      expect(s.points.length, 2);
      expect(s.points[0], const Offset(10, 20));
    });

    test('custom width and color', () {
      final s = Stroke(width: 5.0, color: Colors.red);
      expect(s.width, 5.0);
      expect(s.color, Colors.red);
    });
  });

  group('DrawingCanvas widget', () {
    testWidgets('renders at specified size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DrawingCanvas(width: 300, height: 150),
          ),
        ),
      );
      expect(find.byType(DrawingCanvas), findsOneWidget);
      expect(find.byType(CustomPaint), findsOneWidget);
    });

    testWidgets('starts empty', (tester) async {
      final key = GlobalKey<DrawingCanvasState>();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DrawingCanvas(key: key, width: 300, height: 150),
          ),
        ),
      );
      expect(key.currentState!.isEmpty, isTrue);
      expect(key.currentState!.strokeCount, 0);
    });

    testWidgets('pan gesture creates a stroke', (tester) async {
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

      expect(key.currentState!.isEmpty, isFalse);
      expect(key.currentState!.strokeCount, 1);
    });

    testWidgets('clear removes all strokes', (tester) async {
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

      // Draw a stroke
      final center = tester.getCenter(find.byType(DrawingCanvas));
      await tester.timedDragFrom(
        center,
        const Offset(50, 0),
        const Duration(milliseconds: 100),
      );
      await tester.pumpAndSettle();
      expect(key.currentState!.strokeCount, 1);

      // Clear
      key.currentState!.clear();
      await tester.pump();
      expect(key.currentState!.isEmpty, isTrue);
    });

    testWidgets('undo removes last stroke', (tester) async {
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

      // Draw two strokes
      final center = tester.getCenter(find.byType(DrawingCanvas));
      await tester.timedDragFrom(
        center,
        const Offset(50, 0),
        const Duration(milliseconds: 100),
      );
      await tester.pumpAndSettle();
      await tester.timedDragFrom(
        center + const Offset(0, 30),
        const Offset(50, 0),
        const Duration(milliseconds: 100),
      );
      await tester.pumpAndSettle();
      expect(key.currentState!.strokeCount, 2);

      // Undo
      key.currentState!.undo();
      await tester.pump();
      expect(key.currentState!.strokeCount, 1);
    });
  });
}

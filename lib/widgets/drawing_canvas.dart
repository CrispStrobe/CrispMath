// lib/widgets/drawing_canvas.dart
//
// Cross-platform drawing canvas for handwritten math input.
// Uses Flutter's CustomPainter — works on all platforms including web.
// Captured strokes are rendered to a bitmap that feeds into the OCR
// pipeline (CrispEmbed on-device or Cloud LLM).

import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// A single stroke — a list of points with a pen width.
class Stroke {
  final List<Offset> points;
  final double width;
  final Color color;

  Stroke({
    List<Offset>? points,
    this.width = 3.0,
    this.color = Colors.black,
  }) : points = points ?? [];

  void addPoint(Offset p) => points.add(p);
}

/// Drawing canvas widget. Collects pen strokes and renders them.
/// Call [toImage] to export the canvas as a bitmap for OCR.
class DrawingCanvas extends StatefulWidget {
  final double width;
  final double height;
  final Color backgroundColor;
  final Color strokeColor;
  final double strokeWidth;
  final VoidCallback? onChanged;

  const DrawingCanvas({
    super.key,
    this.width = 384,
    this.height = 200,
    this.backgroundColor = Colors.white,
    this.strokeColor = Colors.black,
    this.strokeWidth = 3.0,
    this.onChanged,
  });

  @override
  DrawingCanvasState createState() => DrawingCanvasState();
}

class DrawingCanvasState extends State<DrawingCanvas> {
  final List<Stroke> _strokes = [];
  Stroke? _current;

  bool get isEmpty => _strokes.isEmpty && _current == null;
  int get strokeCount => _strokes.length;

  void clear() {
    setState(() {
      _strokes.clear();
      _current = null;
    });
    widget.onChanged?.call();
  }

  void undo() {
    if (_strokes.isNotEmpty) {
      setState(() => _strokes.removeLast());
      widget.onChanged?.call();
    }
  }

  /// Export the canvas as a grayscale image suitable for OCR.
  /// Returns raw pixel bytes (width × height, 1 channel, 0-255).
  Future<Uint8List?> toGrayscaleBytes(int targetWidth, int targetHeight) async {
    if (isEmpty) return null;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, targetWidth.toDouble(), targetHeight.toDouble()),
    );

    // White background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, targetWidth.toDouble(), targetHeight.toDouble()),
      Paint()..color = Colors.white,
    );

    // Scale strokes to target size
    final sx = targetWidth / widget.width;
    final sy = targetHeight / widget.height;

    for (final stroke in _strokes) {
      _drawStroke(canvas, stroke, sx, sy);
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(targetWidth, targetHeight);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) return null;

    // Convert RGBA to grayscale
    final rgba = byteData.buffer.asUint8List();
    final gray = Uint8List(targetWidth * targetHeight);
    for (int i = 0; i < gray.length; i++) {
      final r = rgba[i * 4];
      final g = rgba[i * 4 + 1];
      final b = rgba[i * 4 + 2];
      gray[i] = (0.299 * r + 0.587 * g + 0.114 * b).round();
    }
    return gray;
  }

  void _drawStroke(Canvas canvas, Stroke stroke, double sx, double sy) {
    if (stroke.points.length < 2) return;
    final paint = Paint()
      ..color = stroke.color
      ..strokeWidth = stroke.width * min(sx, sy)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(stroke.points[0].dx * sx, stroke.points[0].dy * sy);
    for (int i = 1; i < stroke.points.length; i++) {
      path.lineTo(stroke.points[i].dx * sx, stroke.points[i].dy * sy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (d) {
        setState(() {
          _current = Stroke(
            width: widget.strokeWidth,
            color: widget.strokeColor,
          );
          _current!.addPoint(d.localPosition);
        });
      },
      onPanUpdate: (d) {
        if (_current != null) {
          setState(() => _current!.addPoint(d.localPosition));
        }
      },
      onPanEnd: (_) {
        if (_current != null) {
          setState(() {
            _strokes.add(_current!);
            _current = null;
          });
          widget.onChanged?.call();
        }
      },
      child: ClipRect(
        child: CustomPaint(
          size: Size(widget.width, widget.height),
          painter: _CanvasPainter(
            strokes: _strokes,
            current: _current,
            backgroundColor: widget.backgroundColor,
          ),
        ),
      ),
    );
  }
}

class _CanvasPainter extends CustomPainter {
  final List<Stroke> strokes;
  final Stroke? current;
  final Color backgroundColor;

  _CanvasPainter({
    required this.strokes,
    this.current,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = backgroundColor,
    );

    // Draw all completed strokes
    for (final stroke in strokes) {
      _paintStroke(canvas, stroke);
    }

    // Draw current in-progress stroke
    if (current != null) {
      _paintStroke(canvas, current!);
    }
  }

  void _paintStroke(Canvas canvas, Stroke stroke) {
    if (stroke.points.length < 2) return;
    final paint = Paint()
      ..color = stroke.color
      ..strokeWidth = stroke.width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(stroke.points[0].dx, stroke.points[0].dy);
    for (int i = 1; i < stroke.points.length; i++) {
      path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CanvasPainter old) => true;
}

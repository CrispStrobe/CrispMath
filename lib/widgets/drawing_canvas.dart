// lib/widgets/drawing_canvas.dart
//
// Cross-platform drawing canvas for handwritten math input.
// Uses Flutter's CustomPainter — works on all platforms including web.
// Captured strokes are rendered to a bitmap that feeds into the OCR
// pipeline (CrispEmbed on-device or Cloud LLM).

import 'dart:math';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

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

  /// Render strokes to a raw RGBA image at the given size using package:image.
  /// This avoids Flutter web's Picture.toImage() issues (e.g. on HTML renderer).
  Future<Uint8List?> _renderRgba(int targetWidth, int targetHeight) async {
    if (isEmpty) return null;

    final image = img.Image(width: targetWidth, height: targetHeight, numChannels: 4);
    img.fill(image, color: img.ColorRgba8(255, 255, 255, 255));

    final sx = targetWidth / widget.width;
    final sy = targetHeight / widget.height;

    for (final stroke in _strokes) {
      if (stroke.points.length < 2) continue;
      
      // Calculate color and thickness
      final c = stroke.color;
      final color = img.ColorRgba8(
        (c.r * 255.0).round().clamp(0, 255),
        (c.g * 255.0).round().clamp(0, 255),
        (c.b * 255.0).round().clamp(0, 255),
        (c.a * 255.0).round().clamp(0, 255),
      );
      final thickness = (stroke.width * min(sx, sy)).round();
      
      for (int i = 0; i < stroke.points.length - 1; i++) {
        final p1 = stroke.points[i];
        final p2 = stroke.points[i + 1];
        
        img.drawLine(
          image,
          x1: (p1.dx * sx).round(),
          y1: (p1.dy * sy).round(),
          x2: (p2.dx * sx).round(),
          y2: (p2.dy * sy).round(),
          color: color,
          thickness: thickness > 0 ? thickness : 1,
        );
      }
    }
    return image.getBytes(order: img.ChannelOrder.rgba);
  }

  /// Export the canvas as a grayscale image suitable for OCR.
  /// Returns raw pixel bytes (width × height, 1 channel, 0-255).
  Future<Uint8List?> toGrayscaleBytes(int targetWidth, int targetHeight) async {
    final rgba = await _renderRgba(targetWidth, targetHeight);
    if (rgba == null) return null;

    final nPixels = targetWidth * targetHeight;
    final gray = Uint8List(nPixels);
    for (int i = 0; i < nPixels; i++) {
      final r = rgba[i * 4];
      final g = rgba[i * 4 + 1];
      final b = rgba[i * 4 + 2];
      gray[i] = (0.299 * r + 0.587 * g + 0.114 * b).round();
    }
    return gray;
  }

  /// Export the canvas as an RGBA image (width × height × 4 channels).
  /// Useful for VLM providers that benefit from color input.
  Future<Uint8List?> toRgbaBytes(int targetWidth, int targetHeight) async {
    return _renderRgba(targetWidth, targetHeight);
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
  bool shouldRepaint(_CanvasPainter old) =>
      !identical(old.strokes, strokes) ||
      old.current != current ||
      old.backgroundColor != backgroundColor;
}

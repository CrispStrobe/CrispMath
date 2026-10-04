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
  final Path path = Path();

  Stroke({
    List<Offset>? points,
    this.width = 3.0,
    this.color = Colors.black,
  }) : points = points ?? [] {
    if (this.points.isNotEmpty) {
      path.moveTo(this.points[0].dx, this.points[0].dy);
      for (var i = 1; i < this.points.length; i++) {
        path.lineTo(this.points[i].dx, this.points[i].dy);
      }
    }
  }

  void addPoint(Offset p) {
    if (points.isEmpty) {
      path.moveTo(p.dx, p.dy);
    } else {
      path.lineTo(p.dx, p.dy);
    }
    points.add(p);
  }
}

/// Normalize ink independently of theme, retaining aspect ratio and decimal dots.
Uint8List renderDrawingRgba(List<Stroke> strokes, int width, int height) {
  if (width < 1 || height < 1 || width > 2048 || height > 2048) {
    throw ArgumentError('Drawing output dimensions must be between 1 and 2048');
  }
  final points = strokes
      .expand((s) => s.points)
      .where((p) => p.dx.isFinite && p.dy.isFinite)
      .toList();
  final image = img.Image(width: width, height: height, numChannels: 4);
  img.fill(image, color: img.ColorRgba8(255, 255, 255, 255));
  if (points.isEmpty) return image.getBytes(order: img.ChannelOrder.rgba);
  final left = points.map((p) => p.dx).reduce(min);
  final right = points.map((p) => p.dx).reduce(max);
  final top = points.map((p) => p.dy).reduce(min);
  final bottom = points.map((p) => p.dy).reduce(max);
  final spanX = max(32.0, right - left), spanY = max(32.0, bottom - top);
  final padding = min(12.0, min(width, height) / 4);
  final scale =
      min((width - 2 * padding) / spanX, (height - 2 * padding) / spanY);
  final centerX = (left + right) / 2, centerY = (top + bottom) / 2;
  int x(Offset p) => ((p.dx - centerX) * scale + width / 2).round();
  int y(Offset p) => ((p.dy - centerY) * scale + height / 2).round();
  final ink = img.ColorRgba8(0, 0, 0, 255);
  for (final stroke in strokes) {
    final valid =
        stroke.points.where((p) => p.dx.isFinite && p.dy.isFinite).toList();
    if (valid.isEmpty) continue;
    final thickness = (stroke.width * scale).round().clamp(1, 4);
    for (final point in valid) {
      img.fillCircle(image,
          x: x(point), y: y(point), radius: max(1, thickness ~/ 2), color: ink);
    }
    for (var i = 1; i < valid.length; i++) {
      img.drawLine(image,
          x1: x(valid[i - 1]),
          y1: y(valid[i - 1]),
          x2: x(valid[i]),
          y2: y(valid[i]),
          color: ink,
          thickness: thickness);
    }
  }
  return image.getBytes(order: img.ChannelOrder.rgba);
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
  int _revision = 0;

  bool get isEmpty => _strokes.isEmpty && _current == null;
  int get strokeCount => _strokes.length;

  void clear() {
    setState(() {
      _revision++;
      _strokes.clear();
      _current = null;
    });
    widget.onChanged?.call();
  }

  void undo() {
    if (_strokes.isNotEmpty) {
      setState(() {
        _strokes.removeLast();
        _revision++;
      });
      widget.onChanged?.call();
    }
  }

  /// Render strokes to a raw RGBA image at the given size using package:image.
  /// This avoids Flutter web's Picture.toImage() issues (e.g. on HTML renderer).
  Future<Uint8List?> _renderRgba(int targetWidth, int targetHeight) async {
    if (isEmpty) return null;
    return renderDrawingRgba([..._strokes, if (_current != null) _current!],
        targetWidth, targetHeight);
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
  /// Normalized black ink on white paper for VLM providers.
  Future<Uint8List?> toRgbaBytes(int targetWidth, int targetHeight) async {
    return _renderRgba(targetWidth, targetHeight);
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
        child: GestureDetector(
      onTapUp: (d) {
        setState(() {
          _strokes.add(Stroke(
              points: [d.localPosition],
              width: widget.strokeWidth,
              color: widget.strokeColor));
          _revision++;
        });
        widget.onChanged?.call();
      },
      onPanStart: (d) {
        setState(() {
          _revision++;
          _current = Stroke(
            width: widget.strokeWidth,
            color: widget.strokeColor,
          );
          _current!.addPoint(d.localPosition);
        });
      },
      onPanUpdate: (d) {
        if (_current != null) {
          final last = _current!.points.last;
          if ((d.localPosition - last).distance > 2.0) {
            // Simple stroke point reduction
            setState(() {
              _current!.addPoint(d.localPosition);
              _revision++;
            });
          }
        }
      },
      onPanEnd: (_) {
        if (_current != null) {
          setState(() {
            _revision++;
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
            revision: _revision,
            strokes: _strokes,
            current: _current,
            backgroundColor: widget.backgroundColor,
          ),
        ),
      ),
    ));
  }
}

class _CanvasPainter extends CustomPainter {
  final List<Stroke> strokes;
  final int revision;
  final Stroke? current;
  final Color backgroundColor;

  _CanvasPainter({
    required this.strokes,
    required this.revision,
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
    if (stroke.points.isEmpty) return;
    if (stroke.points.length == 1) {
      canvas.drawCircle(stroke.points.single, stroke.width / 2,
          Paint()..color = stroke.color);
      return;
    }
    final paint = Paint()
      ..color = stroke.color
      ..strokeWidth = stroke.width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    canvas.drawPath(stroke.path, paint);
  }

  @override
  bool shouldRepaint(_CanvasPainter old) =>
      old.revision != revision ||
      old.current != current ||
      old.backgroundColor != backgroundColor;
}

import 'dart:ui' as ui;

import 'package:crisp_math/engine/graph_sampling.dart';
import 'package:crisp_math/screens/graphing_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('completed sampling repaints an existing graph canvas',
      (tester) async {
    final boundaryKey = GlobalKey();
    final base = GraphPainter(
      functions: ['1'],
      functionIndices: [0],
      scale: 1,
      offset: Offset.zero,
      getColorForFunction: (_) => Colors.red,
    );
    Future<void> show(GraphSamples samples) => tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Center(
              child: RepaintBoundary(
                key: boundaryKey,
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: CustomPaint(painter: base.withSamples(samples)),
                ),
              ),
            ),
          ),
        );
    Future<List<int>> pixel() async {
      final boundary = boundaryKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      return (await tester.runAsync(() async {
        final image = await boundary.toImage();
        final bytes =
            (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
        const offset = (15 * 80 + 40) * 4;
        final result = bytes.buffer.asUint8List().sublist(offset, offset + 4);
        image.dispose();
        return result.toList();
      }))!;
    }

    await show(const GraphSamples());
    final before = await pixel();
    await show(const GraphSamples(curves: [
      [(x: -1, y: 1, ok: true), (x: 1, y: 1, ok: true)]
    ]));
    final after = await pixel();
    expect(after, isNot(before));
    expect(after[0], greaterThan(after[1]));
    expect(after[0], greaterThan(after[2]));
  });
}

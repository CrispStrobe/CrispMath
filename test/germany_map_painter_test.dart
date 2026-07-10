// Coverage for the Germany map-coloring visualization that the DSL
// result panel shows for the `mapColoringGermany` gallery program.

import 'package:crisp_math/widgets/germany_map_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // A valid 4-coloring of the 16 Bundesländer (used by several tests).
  const coloring = {
    'sh': 1,
    'hh': 2,
    'mv': 2,
    'ni': 3,
    'hb': 1,
    'bb': 1,
    'be': 2,
    'st': 2,
    'nw': 1,
    'he': 2,
    'th': 4,
    'sn': 3,
    'rp': 3,
    'sl': 1,
    'bw': 2,
    'by': 1,
  };

  group('GermanyMapView.matches', () {
    test('accepts exactly the sixteen region keys', () {
      expect(GermanyMapView.matches(coloring), isTrue);
    });

    test('rejects a subset of the region keys', () {
      expect(GermanyMapView.matches({'bw': 1, 'by': 2, 'be': 3}), isFalse);
    });

    test('rejects the Australia key-set (different names, smaller size)', () {
      expect(
        GermanyMapView.matches(
            {'wa': 1, 'nt': 2, 'sa': 3, 'q': 1, 'nsw': 2, 'v': 1, 't': 1}),
        isFalse,
      );
    });

    test('rejects a superset (extra variable)', () {
      expect(GermanyMapView.matches({...coloring, 'extra': 1}), isFalse);
    });
  });

  group('region geometry', () {
    final polys = GermanyMapView.regionPolygons;

    test('all sixteen regions have a polygon over the 0..100 grid', () {
      expect(polys.keys.toSet(), GermanyMapView.regionKeys);
      expect(polys.length, 16);
      for (final entry in polys.entries) {
        expect(entry.value.length, greaterThanOrEqualTo(3),
            reason: '${entry.key} must be a polygon');
        for (final p in entry.value) {
          expect(p.dx, inInclusiveRange(0, 100), reason: '${entry.key} x');
          expect(p.dy, inInclusiveRange(0, 100), reason: '${entry.key} y');
        }
      }
    });
  });

  testWidgets('renders without error for a valid 4-coloring', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: GermanyMapView(assignment: coloring)),
      ),
    );
    expect(find.byType(GermanyMapView), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
  });
}

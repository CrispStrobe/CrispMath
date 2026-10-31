import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import '../integration_test/gallery_geometry.dart';

/// The published gallery must show a scene, not merely build one. These cases
/// pin the difference between "mounted" and "in frame" for a solver grid whose
/// explanation sits below the fold.
void main() {
  const screen = Rect.fromLTWH(0, 0, 390, 844);
  const grid = Rect.fromLTWH(12, 96, 366, 366);

  test('board and caption in one viewport are visible together', () {
    const caption = Rect.fromLTWH(12, 470, 366, 28);
    expect(allVisibleTogether([grid, caption], [screen]), isTrue);
    expect(visibleFrame(caption, [screen]), caption);
  });

  test('caption below the viewport is not part of the picture', () {
    const caption = Rect.fromLTWH(12, 1500, 366, 28);
    expect(allVisibleTogether([grid, caption], [screen]), isFalse);
    expect(fullyVisible(grid, [screen]), isTrue);
    expect(visibleFrame(caption, [screen]).height, lessThan(0));
  });

  test('grid scrolled out of a lazy list is not part of the picture', () {
    const listViewport = Rect.fromLTWH(0, 96, 390, 748);
    const scrolledGrid = Rect.fromLTWH(12, 900, 366, 366);
    const caption = Rect.fromLTWH(12, 500, 366, 28);
    expect(fullyVisible(scrolledGrid, [screen, listViewport]), isFalse);
    expect(fullyVisible(caption, [screen, listViewport]), isTrue);
  });

  test('a clipped edge rejects even when most of the target is drawn', () {
    // The board bottom falls past the viewport: the capture would show a
    // board that stops mid-row, which is not the scene either.
    const clippedGrid = Rect.fromLTWH(12, 700, 366, 366);
    expect(visibleFrame(clippedGrid, [screen]).height, closeTo(144, 0.001));
    expect(fullyVisible(clippedGrid, [screen]), isFalse);
  });

  test('boundary contact counts as visible', () {
    const caption = Rect.fromLTWH(12, 816, 366, 28);
    expect(caption.bottom, 844);
    expect(fullyVisible(caption, [screen]), isTrue);
  });

  test('no clip means nothing is hidden', () {
    expect(fullyVisible(grid, const []), isTrue);
    expect(allVisibleTogether([grid], const []), isTrue);
  });
}

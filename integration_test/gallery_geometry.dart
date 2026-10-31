import 'dart:ui';

/// Geometry the gallery harness needs to tell "the widget exists" apart from
/// "the widget is inside the picture we are about to publish".
///
/// A widget can be built, laid out and mounted while sitting entirely outside
/// the viewport that clips it, and a render-tree capture then simply omits it.
/// That is how a screenshot of a solver grid shipped with no explanation on
/// it, and how a caption can be present in the tree while absent from frame.

/// How much of [target] survives every rect in [clips].
///
/// Disjoint rects intersect to a negative-extent rect, which is exactly what a
/// caller wants to see: nothing of the target is drawn.
Rect visibleFrame(Rect target, Iterable<Rect> clips) =>
    clips.fold(target, (visible, clip) => visible.intersect(clip));

/// Whether all of [target] is drawn inside every clip, within [tolerance].
///
/// Used only for capture assertions, so a sub-pixel tolerance keeps the check
/// from failing on rounding while still rejecting a clipped edge.
bool fullyVisible(Rect target, Iterable<Rect> clips, {double tolerance = 0.5}) {
  final visible = visibleFrame(target, clips);
  return visible.width >= target.width - tolerance &&
      visible.height >= target.height - tolerance;
}

/// Whether all of [targets] share one frame: each is fully visible in [clips].
bool allVisibleTogether(Iterable<Rect> targets, Iterable<Rect> clips) =>
    targets.every((target) => fullyVisible(target, clips));

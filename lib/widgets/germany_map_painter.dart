import 'package:flutter/material.dart';

/// Map of Germany's 16 Bundesländer, colored from a solution to the
/// `mapColoringGermany` DSL gallery program.
///
/// Like the Australia map, this is a *teaching* visualization rather than
/// a survey-grade map: the 16 states are drawn as stylized blocks in
/// their true relative positions (north on top, the Berlin/Bremen
/// enclaves inset within Brandenburg/Niedersachsen) so the four-color
/// property — no two bordering states share a color — is visible at a
/// glance.
///
/// The pedagogical point is that Germany, unlike 3-colorable Australia,
/// *requires four colors*: Thüringen (th) borders five states that form
/// a 5-cycle (a 5-wheel, chromatic number 4). The gallery program's
/// domain is therefore `1..4`.
class GermanyMapView extends StatelessWidget {
  /// The solved assignment: region variable name → color index (1-based).
  final Map<String, int> assignment;

  const GermanyMapView({super.key, required this.assignment});

  /// The 16 ISO 3166-2:DE codes the `mapColoringGermany` program declares.
  static const Set<String> regionKeys = {
    'bw', 'by', 'be', 'bb', 'hb', 'hh', 'he', 'mv', //
    'ni', 'nw', 'rp', 'sl', 'sn', 'st', 'sh', 'th',
  };

  /// True when [solution] is an assignment over exactly the German
  /// Bundesländer variables — the signal for the DSL result panel to
  /// render this map. The exact key-set match keeps it from firing on
  /// unrelated problems that merely declare a similar number of variables.
  static bool matches(Map<String, int> solution) =>
      solution.length == regionKeys.length &&
      solution.keys.toSet().containsAll(regionKeys);

  /// Region boundary polygons keyed by variable name, on the same
  /// 0..100 logical grid the painter uses. Exposed for the test that
  /// verifies all 16 regions are present and in-grid.
  @visibleForTesting
  static Map<String, List<Offset>> get regionPolygons => {
        for (final r in _regions) r.varName: r.points,
      };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: AspectRatio(
        aspectRatio: 0.82, // Germany is taller than wide.
        child: CustomPaint(
          painter: _GermanyMapPainter(
            assignment: assignment,
            labelStyle: (Theme.of(context).textTheme.labelSmall ??
                    const TextStyle(fontSize: 10))
                .copyWith(fontWeight: FontWeight.w600, fontSize: 9),
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

/// One region: its variable name, display label, polygon (in a 0..100
/// logical grid), and the offset (also 0..100) at which to place the
/// label.
class _Region {
  final String varName;
  final String label;
  final List<Offset> points;
  final Offset labelAt;
  const _Region(this.varName, this.label, this.points, this.labelAt);
}

// Stylized region blocks on a 100×100 logical grid (x → right, y → down),
// positioned to read as Germany: Schleswig-Holstein at the top,
// Bayern/Baden-Württemberg across the south, the eastern states (MV, BB,
// SN) on the right, and the Berlin/Bremen enclaves inset within their
// surrounding states. This is a recognizability-first layout; borders
// are visually adjacent rather than surveyed. The map needs four colors
// regardless of geometry — the `!=` constraints in the gallery program
// are the source of truth for adjacency, not these polygons.
const List<_Region> _regions = [
  // Northern tier.
  _Region(
      'sh',
      'SH',
      [
        Offset(34, 2), Offset(52, 2), Offset(52, 14), Offset(34, 14), //
      ],
      Offset(43, 8)),
  _Region(
      'hh',
      'HH',
      [
        Offset(40, 14), Offset(50, 14), Offset(50, 20), Offset(40, 20), //
      ],
      Offset(45, 17)),
  _Region(
      'mv',
      'MV',
      [
        Offset(52, 6), Offset(74, 6), Offset(74, 22), Offset(52, 22), //
      ],
      Offset(63, 14)),
  // Niedersachsen — large north-west, wraps the Bremen enclave.
  _Region(
      'ni',
      'NI',
      [
        Offset(18, 14), Offset(52, 14), Offset(52, 36), Offset(40, 38), //
        Offset(22, 36), Offset(16, 26),
      ],
      Offset(32, 24)),
  // Bremen enclave, inside Niedersachsen.
  _Region(
      'hb',
      'HB',
      [
        Offset(33, 21), Offset(39, 21), Offset(39, 27), Offset(33, 27), //
      ],
      Offset(36, 24)),
  // Brandenburg — east, wraps the Berlin enclave.
  _Region(
      'bb',
      'BB',
      [
        Offset(58, 22), Offset(78, 22), Offset(78, 42), Offset(58, 42), //
      ],
      Offset(64, 38)),
  // Berlin enclave, inside Brandenburg.
  _Region(
      'be',
      'BE',
      [
        Offset(67, 28), Offset(73, 28), Offset(73, 33), Offset(67, 33), //
      ],
      Offset(70, 30)),
  _Region(
      'st',
      'ST',
      [
        Offset(48, 36), Offset(58, 30), Offset(58, 50), Offset(48, 52), //
      ],
      Offset(53, 43)),
  // Nordrhein-Westfalen — west.
  _Region(
      'nw',
      'NW',
      [
        Offset(12, 36), Offset(30, 36), Offset(32, 52), Offset(16, 54), //
        Offset(10, 46),
      ],
      Offset(21, 45)),
  _Region(
      'he',
      'HE',
      [
        Offset(30, 38), Offset(44, 40), Offset(44, 58), Offset(30, 58), //
      ],
      Offset(37, 49)),
  _Region(
      'th',
      'TH',
      [
        Offset(44, 50), Offset(58, 50), Offset(58, 60), Offset(44, 60), //
      ],
      Offset(51, 55)),
  _Region(
      'sn',
      'SN',
      [
        Offset(58, 44), Offset(80, 44), Offset(78, 60), Offset(58, 60), //
      ],
      Offset(68, 53)),
  // Western-south.
  _Region(
      'rp',
      'RP',
      [
        Offset(14, 54), Offset(30, 54), Offset(30, 70), Offset(20, 72), //
        Offset(14, 64),
      ],
      Offset(22, 62)),
  _Region(
      'sl',
      'SL',
      [
        Offset(12, 72), Offset(22, 72), Offset(22, 80), Offset(12, 80), //
      ],
      Offset(17, 76)),
  // Southern tier.
  _Region(
      'bw',
      'BW',
      [
        Offset(20, 64), Offset(44, 62), Offset(46, 86), Offset(28, 94), //
        Offset(22, 80),
      ],
      Offset(33, 76)),
  _Region(
      'by',
      'BY',
      [
        Offset(46, 58), Offset(72, 60), Offset(74, 80), Offset(56, 96), //
        Offset(46, 86), Offset(44, 62),
      ],
      Offset(58, 74)),
];

/// Color-index → fill color. The DSL program's domain is `1..4`, but the
/// palette carries an extra entry so a hand-edited program with more
/// colors still renders distinctly. Indexing is `(value - 1) % length`.
const List<Color> _palette = [
  Color(0xFFEF9A9A), // red 200
  Color(0xFF90CAF9), // blue 200
  Color(0xFFA5D6A7), // green 200
  Color(0xFFFFE082), // amber 200
  Color(0xFFCE93D8), // purple 200
];

class _GermanyMapPainter extends CustomPainter {
  final Map<String, int> assignment;
  final TextStyle labelStyle;

  _GermanyMapPainter({required this.assignment, required this.labelStyle});

  Offset _scale(Offset p, Size size) =>
      Offset(p.dx / 100 * size.width, p.dy / 100 * size.height);

  @override
  void paint(Canvas canvas, Size size) {
    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = const Color(0xFF424242);

    for (final region in _regions) {
      final value = assignment[region.varName];
      final fill = Paint()
        ..style = PaintingStyle.fill
        ..color = value == null
            ? const Color(0xFFE0E0E0)
            : _palette[(value - 1) % _palette.length];

      final path = Path()
        ..moveTo(_scale(region.points.first, size).dx,
            _scale(region.points.first, size).dy);
      for (final p in region.points.skip(1)) {
        final s = _scale(p, size);
        path.lineTo(s.dx, s.dy);
      }
      path.close();
      canvas.drawPath(path, fill);
      canvas.drawPath(path, border);

      // Label centered at the region's anchor point.
      final tp = TextPainter(
        text: TextSpan(text: region.label, style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      final at = _scale(region.labelAt, size);
      tp.paint(canvas, at - Offset(tp.width / 2, tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(_GermanyMapPainter old) =>
      old.assignment != assignment || old.labelStyle != labelStyle;
}

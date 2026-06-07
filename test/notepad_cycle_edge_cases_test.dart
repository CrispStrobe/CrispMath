// Additional edge-case tests for notepad dependency graph and cycle
// detection. Complements notepad_evaluator_test.dart with deeper
// cycles, diamonds, and aggregate interactions.

import 'package:crisp_calc/engine/notepad.dart';
import 'package:crisp_calc/engine/notepad_evaluator.dart';
import 'package:flutter_test/flutter_test.dart';

NotepadDocument docOf(List<({String source, String? cached})> spec) {
  return NotepadDocument(
    id: 'test-doc',
    name: 'Test',
    createdAt: DateTime.utc(2026, 6, 7),
    updatedAt: DateTime.utc(2026, 6, 7),
    lines: [
      for (var i = 0; i < spec.length; i++)
        NotepadLine(
          id: 'l$i',
          source: spec[i].source,
          cachedResult: spec[i].cached,
        ),
    ],
  );
}

void main() {
  group('Deep cycles (3+ nodes)', () {
    test('3-node cycle a→b→c→a', () {
      final g = buildDependencyGraph(docOf([
        (source: 'a = c + 1', cached: null),
        (source: 'b = a + 1', cached: null),
        (source: 'c = b + 1', cached: null),
      ]));
      expect(findCycleParticipants(g), {0, 1, 2});
    });

    test('4-node cycle a→b→c→d→a', () {
      final g = buildDependencyGraph(docOf([
        (source: 'a = d + 1', cached: null),
        (source: 'b = a + 1', cached: null),
        (source: 'c = b + 1', cached: null),
        (source: 'd = c + 1', cached: null),
      ]));
      expect(findCycleParticipants(g), {0, 1, 2, 3});
    });

    test('5-node cycle with one innocent bystander', () {
      final g = buildDependencyGraph(docOf([
        (source: 'p = t + 1', cached: null),
        (source: 'q = p + 1', cached: null),
        (source: 'r = q + 1', cached: null),
        (source: 's = r + 1', cached: null),
        (source: 't = s + 1', cached: null),
        (source: 'z = 42', cached: null), // innocent
      ]));
      expect(findCycleParticipants(g), {0, 1, 2, 3, 4});
      final order = kahnTopologicalOrder(g);
      expect(order, contains(5)); // z should be ordered
      expect(order.length, 1); // only z
    });
  });

  group('Diamond dependencies', () {
    test('diamond a→(b,c)→d is acyclic', () {
      final g = buildDependencyGraph(docOf([
        (source: 'a = 1', cached: null),
        (source: 'b = a + 1', cached: null),
        (source: 'c = a + 2', cached: null),
        (source: 'd = b + c', cached: null),
      ]));
      expect(findCycleParticipants(g), isEmpty);
      final order = kahnTopologicalOrder(g);
      // a must come before b, c; b and c before d
      expect(order.indexOf(0), lessThan(order.indexOf(1)));
      expect(order.indexOf(0), lessThan(order.indexOf(2)));
      expect(order.indexOf(1), lessThan(order.indexOf(3)));
      expect(order.indexOf(2), lessThan(order.indexOf(3)));
    });

    test('diamond with back-edge creates cycle', () {
      // a→b→d, a→c→d, d→a (back-edge)
      final g = buildDependencyGraph(docOf([
        (source: 'a = d + 1', cached: null), // back-edge d→a
        (source: 'b = a + 1', cached: null),
        (source: 'c = a + 2', cached: null),
        (source: 'd = b + c', cached: null),
      ]));
      expect(findCycleParticipants(g), {0, 1, 2, 3});
    });
  });

  group('Aggregates and cycles', () {
    test('aggregate does not participate in variable cycles', () {
      // aggregate (total) scans previous lines but does not create
      // a dependency edge — it's a special line type
      final g = buildDependencyGraph(docOf([
        (source: 'x = 5', cached: null),
        (source: 'y = 10', cached: null),
        (source: 'total', cached: null),
      ]));
      expect(findCycleParticipants(g), isEmpty);
    });

    test('expression referencing line after aggregate is fine', () {
      final g = buildDependencyGraph(docOf([
        (source: 'a = 1', cached: null),
        (source: 'b = a + 1', cached: null),
        (source: 'total', cached: null),
        (source: 'c = b + 1', cached: null),
      ]));
      expect(findCycleParticipants(g), isEmpty);
      final order = kahnTopologicalOrder(g);
      expect(order.indexOf(0), lessThan(order.indexOf(1)));
      expect(order.indexOf(1), lessThan(order.indexOf(3)));
    });
  });

  group('Mixed line types with cycles', () {
    test('comments and blanks are excluded from dependency graph', () {
      final g = buildDependencyGraph(docOf([
        (source: '// this is a comment', cached: null),
        (source: '', cached: null),
        (source: 'a = 1', cached: null),
        (source: '## heading', cached: null),
        (source: 'b = a + 1', cached: null),
      ]));
      expect(findCycleParticipants(g), isEmpty);
      final order = kahnTopologicalOrder(g);
      // Only lines 2 and 4 should participate
      expect(order, containsAll([2, 4]));
    });

    test('FlatZinc lines are independent of assignment scope', () {
      final g = buildDependencyGraph(docOf([
        (source: 'a = 5', cached: null),
        (source: 'fzn: var 1..10: x; constraint x > 3; solve satisfy;',
            cached: null),
        (source: 'b = a + 1', cached: null),
      ]));
      expect(findCycleParticipants(g), isEmpty);
    });

    test('cycle in middle does not affect tail', () {
      final g = buildDependencyGraph(docOf([
        (source: 'x = y + 1', cached: null), // cycle
        (source: 'y = x + 1', cached: null), // cycle
        (source: 'z = 42', cached: null), // independent
        (source: 'w = z + 1', cached: null), // depends on z
      ]));
      expect(findCycleParticipants(g), {0, 1});
      final order = kahnTopologicalOrder(g);
      expect(order, containsAll([2, 3]));
      expect(order.indexOf(2), lessThan(order.indexOf(3)));
    });
  });

  group('Self-reference patterns', () {
    test('x = x is a self-loop', () {
      final g = buildDependencyGraph(docOf([
        (source: 'x = x', cached: null),
      ]));
      expect(findCycleParticipants(g), {0});
    });

    test('x = x * 2 is a self-loop', () {
      final g = buildDependencyGraph(docOf([
        (source: 'x = x * 2', cached: null),
      ]));
      expect(findCycleParticipants(g), {0});
    });

    test('two independent self-loops', () {
      final g = buildDependencyGraph(docOf([
        (source: 'x = x + 1', cached: null),
        (source: 'y = y + 1', cached: null),
        (source: 'z = 5', cached: null),
      ]));
      expect(findCycleParticipants(g), {0, 1});
      expect(kahnTopologicalOrder(g), [2]);
    });
  });
}

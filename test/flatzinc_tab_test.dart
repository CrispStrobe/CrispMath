// Lock the FlatZinc tab's gallery snippets against the dart_csp
// FlatZinc frontend. Round E.1 ships two gallery entries; if either
// stops producing a sensible result (whether because of a dart_csp
// API drift or a typo in the snippet itself), this test fails first
// and the broken textarea default never lands.
//
// We assert on the structural shape of the FlatZinc output (every
// solution block ends with `----------`, the exhaustive marker is
// `==========`) plus a couple of value-level invariants per puzzle
// (4-Queens: all 4 columns distinct; bin-packing: load[1] + load[2]
// == sum of item sizes = 10). Full equality of the output text would
// be fragile against future dart_csp formatter tweaks.

import 'package:dart_csp/dart_csp.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FlatZinc tab gallery (Round E.1)', () {
    test('4-Queens snippet returns a valid 4-tuple', () async {
      const source = '''array[1..4] of var 1..4: q :: output_array([1..4]);
constraint all_different_int(q);
constraint int_lin_ne([1, -1], [q[1], q[2]], 1);
constraint int_lin_ne([1, -1], [q[1], q[2]], -1);
constraint int_lin_ne([1, -1], [q[1], q[3]], 2);
constraint int_lin_ne([1, -1], [q[1], q[3]], -2);
constraint int_lin_ne([1, -1], [q[1], q[4]], 3);
constraint int_lin_ne([1, -1], [q[1], q[4]], -3);
constraint int_lin_ne([1, -1], [q[2], q[3]], 1);
constraint int_lin_ne([1, -1], [q[2], q[3]], -1);
constraint int_lin_ne([1, -1], [q[2], q[4]], 2);
constraint int_lin_ne([1, -1], [q[2], q[4]], -2);
constraint int_lin_ne([1, -1], [q[3], q[4]], 1);
constraint int_lin_ne([1, -1], [q[3], q[4]], -1);
solve satisfy;
''';
      final out = await FlatZinc.solve(source);
      expect(out, contains('q = array1d(1..4, ['));
      expect(out, contains('----------'));
      // Extract the 4 numbers from `q = array1d(1..4, [a, b, c, d]);`
      final m = RegExp(r'array1d\(1\.\.4, \[(\d+), (\d+), (\d+), (\d+)\]\)')
          .firstMatch(out);
      expect(m, isNotNull, reason: 'output should contain array1d body: $out');
      final vals = [
        int.parse(m!.group(1)!),
        int.parse(m.group(2)!),
        int.parse(m.group(3)!),
        int.parse(m.group(4)!),
      ];
      // All distinct (allDifferent) and no two queens on the same diagonal.
      expect(vals.toSet().length, 4, reason: 'columns must be distinct');
      for (var i = 0; i < 4; i++) {
        for (var j = i + 1; j < 4; j++) {
          expect((vals[i] - vals[j]).abs(), isNot(j - i),
              reason: 'queens at rows $i,$j on a diagonal');
        }
      }
    });

    test('bin-packing snippet loads sum to the item-size total', () async {
      const source = '''array[1..2] of var 0..5: load :: output_array([1..2]);
array[1..3] of var 1..2: bin :: output_array([1..3]);
constraint bin_packing_load(load, bin, [2, 3, 5]);
solve satisfy;
''';
      final out = await FlatZinc.solve(source);
      expect(out, contains('load = array1d(1..2, ['));
      expect(out, contains('bin = array1d(1..3, ['));
      // Item sizes [2, 3, 5] sum to 10 — must equal the total load.
      final m =
          RegExp(r'load = array1d\(1\.\.2, \[(\d+), (\d+)\]\)').firstMatch(out);
      expect(m, isNotNull, reason: 'load array missing: $out');
      final l1 = int.parse(m!.group(1)!);
      final l2 = int.parse(m.group(2)!);
      expect(l1 + l2, 10);
    });

    test('all-solutions mode terminates with ==========', () async {
      // Tiny 2-variable model with 6 satisfying assignments.
      const source = '''var 1..3: x :: output_var;
var 1..2: y :: output_var;
solve satisfy;
''';
      final out = await FlatZinc.solve(source, all: true);
      expect(out.trim().endsWith('=========='), isTrue);
      // 3 × 2 = 6 solutions, each ending in a `----------` separator.
      final sepCount = '\n${out.trim()}'.split('\n----------').length - 1;
      expect(sepCount, 6);
    });

    test('unsatisfiable model reports =====UNSATISFIABLE=====', () async {
      const source = '''var 1..1: x :: output_var;
var 2..2: y :: output_var;
constraint int_eq(x, y);
solve satisfy;
''';
      final out = await FlatZinc.solve(source);
      expect(out, contains('=====UNSATISFIABLE====='));
    });
  });
}

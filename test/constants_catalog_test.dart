// test/constants_catalog_test.dart
//
// Sanity checks for the constants catalog. Verifies coverage,
// well-known textbook values, search behavior, and that we ship
// at least a few entries in every category.

import 'package:crisp_math/engine/constants_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

PhysicalConstant _find(String symbol) =>
    ConstantsCatalog.all.firstWhere((c) => c.symbol == symbol,
        orElse: () => throw StateError('missing constant: $symbol'));

void main() {
  group('coverage', () {
    test('catalog ships at least 25 constants', () {
      expect(ConstantsCatalog.all.length, greaterThanOrEqualTo(25));
    });

    test('every category has at least three entries', () {
      for (final cat in ConstantCategory.values) {
        expect(ConstantsCatalog.byCategory(cat).length, greaterThanOrEqualTo(3),
            reason: 'category=$cat');
      }
    });

    test('every constant has a non-empty symbol and name', () {
      for (final c in ConstantsCatalog.all) {
        expect(c.symbol.trim(), isNotEmpty);
        expect(c.name.trim(), isNotEmpty);
      }
    });
  });

  group('well-known values', () {
    test('π ≈ 3.14159…', () {
      expect(_find('π').value, closeTo(3.141592653589793, 1e-12));
    });
    test("e ≈ 2.71828… (math)", () {
      expect(_find('e').value, closeTo(2.718281828459045, 1e-12));
    });
    test('c = 299792458 m/s exactly', () {
      // After the 2019 SI redefinition the speed of light is defined.
      final c = ConstantsCatalog.all
          .firstWhere((k) => k.symbol == 'c' && k.unit == 'm/s');
      expect(c.value, equals(299792458.0));
    });
    test('elementary charge e = 1.602176634e-19 C exactly', () {
      final e = ConstantsCatalog.all
          .firstWhere((k) => k.symbol == 'e' && k.unit == 'C');
      expect(e.value, equals(1.602176634e-19));
    });
    test('Avogadro N_A = 6.02214076e23 /mol exactly', () {
      expect(_find('N_A').value, equals(6.02214076e23));
    });
    test('Boltzmann k_B = 1.380649e-23 J/K exactly', () {
      expect(_find('k_B').value, equals(1.380649e-23));
    });
    test('Planck h = 6.62607015e-34 J·s exactly', () {
      expect(_find('h').value, equals(6.62607015e-34));
    });
    test('Gas constant R ≈ N_A · k_B', () {
      final r = _find('R');
      final na = _find('N_A');
      final kb = _find('k_B');
      expect(r.value, closeTo(na.value * kb.value, 1e-7));
    });
    test('Faraday constant F ≈ N_A · e (elementary)', () {
      final f = _find('F');
      final na = _find('N_A');
      final e = ConstantsCatalog.all
          .firstWhere((k) => k.symbol == 'e' && k.unit == 'C');
      expect(f.value, closeTo(na.value * e.value, 1e-3));
    });
    test('ℏ ≈ h / (2π)', () {
      final hbar = _find('ℏ');
      final h = _find('h');
      final pi = _find('π');
      expect(hbar.value, closeTo(h.value / (2 * pi.value), 1e-39));
    });
  });

  group('search', () {
    test('empty query returns everything', () {
      expect(ConstantsCatalog.search('').length,
          equals(ConstantsCatalog.all.length));
    });
    test('substring on name finds it', () {
      final hits = ConstantsCatalog.search('Avogadro');
      expect(hits.map((c) => c.symbol), contains('N_A'));
    });
    test('substring on symbol finds it', () {
      final hits = ConstantsCatalog.search('k_B');
      expect(hits.length, equals(1));
      expect(hits.first.symbol, equals('k_B'));
    });
    test('substring on unit finds it', () {
      final hits = ConstantsCatalog.search('m/s');
      // c (speed of light), Standard gravity (m/s²) both match.
      expect(hits.length, greaterThanOrEqualTo(2));
    });
    test('case-insensitive', () {
      expect(
        ConstantsCatalog.search('PLANCK').map((c) => c.symbol),
        contains('h'),
      );
    });
    test('no matches returns empty', () {
      expect(ConstantsCatalog.search('absolutelynothing'), isEmpty);
    });
  });
}

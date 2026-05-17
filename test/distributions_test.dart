// test/distributions_test.dart
//
// Numerical correctness for the normal and binomial distributions.
// Reference values come from standard statistical tables (z-tables,
// binomial CDF tables) and known closed-form relationships.

import 'package:crisp_calc/engine/distributions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Normal — basic properties', () {
    test('PDF integrates to ~1 over [-5, 5] (Simpson)', () {
      // Simple sanity check: not a proof of normalization but catches
      // grossly wrong PDFs.
      double simpson(double Function(double) f, double a, double b, int n) {
        final h = (b - a) / n;
        var s = f(a) + f(b);
        for (var i = 1; i < n; i++) {
          s += (i.isOdd ? 4 : 2) * f(a + i * h);
        }
        return s * h / 3;
      }

      final area = simpson(standardNormal.pdf, -5, 5, 200);
      expect(area, closeTo(1.0, 1e-4));
    });

    test('PDF peaks at the mean', () {
      const n = Normal(mean: 3, stddev: 2);
      expect(n.pdf(3) > n.pdf(2), isTrue);
      expect(n.pdf(3) > n.pdf(4), isTrue);
    });

    test('PDF is symmetric around the mean', () {
      const n = Normal(mean: 5, stddev: 1.5);
      expect(n.pdf(5 - 2.3), closeTo(n.pdf(5 + 2.3), 1e-12));
    });
  });

  group('Normal — CDF', () {
    test('CDF at the mean is 0.5', () {
      expect(standardNormal.cdf(0), closeTo(0.5, 1e-6));
    });

    test('z=1 cumulative ≈ 0.8413 (textbook)', () {
      expect(standardNormal.cdf(1), closeTo(0.8413, 1e-3));
    });

    test('z=-1 ≈ 0.1587 (textbook)', () {
      expect(standardNormal.cdf(-1), closeTo(0.1587, 1e-3));
    });

    test('z=1.96 ≈ 0.975 (the 95% z-score)', () {
      expect(standardNormal.cdf(1.96), closeTo(0.975, 1e-3));
    });

    test('z=2.58 ≈ 0.995 (the 99% z-score)', () {
      expect(standardNormal.cdf(2.58), closeTo(0.995, 1e-3));
    });

    test('CDF tails approach 0 and 1', () {
      expect(standardNormal.cdf(-5), lessThan(1e-6));
      expect(standardNormal.cdf(5), greaterThan(1 - 1e-6));
    });

    test('non-standard normal CDF — N(100, 15) at 115', () {
      // 115 is 1σ above mean → ≈ 0.8413.
      const n = Normal(mean: 100, stddev: 15);
      expect(n.cdf(115), closeTo(0.8413, 1e-3));
    });
  });

  group('Normal — quantile (inverse CDF)', () {
    test('median is at 0.5', () {
      expect(standardNormal.quantile(0.5), closeTo(0.0, 1e-6));
    });

    test('quantile(0.975) ≈ 1.96', () {
      expect(standardNormal.quantile(0.975), closeTo(1.96, 1e-3));
    });

    test('quantile(0.995) ≈ 2.576', () {
      expect(standardNormal.quantile(0.995), closeTo(2.576, 1e-3));
    });

    test('quantile and CDF are inverses', () {
      for (final p in const [0.1, 0.25, 0.5, 0.75, 0.9, 0.99]) {
        final x = standardNormal.quantile(p);
        expect(standardNormal.cdf(x), closeTo(p, 1e-6), reason: 'p=$p');
      }
    });

    test('endpoints return ±infinity', () {
      expect(standardNormal.quantile(0).isNegative, isTrue);
      expect(standardNormal.quantile(0).isInfinite, isTrue);
      expect(standardNormal.quantile(1).isInfinite, isTrue);
    });

    test('non-standard normal quantile', () {
      const n = Normal(mean: 100, stddev: 15);
      expect(n.quantile(0.5), closeTo(100, 1e-6));
      // 1σ above → ~115.
      expect(n.quantile(0.8413), closeTo(115, 0.1));
    });
  });

  group('Binomial — PMF', () {
    test('coin flip P(X=k) for n=10, p=0.5', () {
      // Symmetric: PMF(0) = PMF(10) = 1/1024.
      const b = Binomial(n: 10, p: 0.5);
      expect(b.pmf(0), closeTo(1.0 / 1024.0, 1e-12));
      expect(b.pmf(10), closeTo(1.0 / 1024.0, 1e-12));
      expect(b.pmf(5), closeTo(252.0 / 1024.0, 1e-12));
    });

    test('PMFs sum to 1 over the full support', () {
      const b = Binomial(n: 12, p: 0.3);
      var s = 0.0;
      for (var k = 0; k <= 12; k++) {
        s += b.pmf(k);
      }
      expect(s, closeTo(1.0, 1e-10));
    });

    test('p=0 puts all mass at k=0', () {
      const b = Binomial(n: 5, p: 0);
      expect(b.pmf(0), closeTo(1.0, 1e-12));
      expect(b.pmf(1), closeTo(0.0, 1e-12));
    });

    test('p=1 puts all mass at k=n', () {
      const b = Binomial(n: 5, p: 1);
      expect(b.pmf(5), closeTo(1.0, 1e-12));
      expect(b.pmf(4), closeTo(0.0, 1e-12));
    });

    test('out-of-range k returns 0', () {
      const b = Binomial(n: 10, p: 0.5);
      expect(b.pmf(-1), equals(0.0));
      expect(b.pmf(11), equals(0.0));
    });
  });

  group('Binomial — CDF and moments', () {
    test('CDF at n is 1', () {
      const b = Binomial(n: 20, p: 0.4);
      expect(b.cdf(20), closeTo(1.0, 1e-10));
    });

    test('CDF below 0 is 0', () {
      const b = Binomial(n: 20, p: 0.4);
      expect(b.cdf(-1), equals(0.0));
    });

    test('CDF is monotone non-decreasing', () {
      const b = Binomial(n: 15, p: 0.6);
      var prev = -1.0;
      for (var k = -2; k <= 16; k++) {
        final c = b.cdf(k);
        expect(c, greaterThanOrEqualTo(prev));
        prev = c;
      }
    });

    test('mean = n*p', () {
      const b = Binomial(n: 100, p: 0.3);
      expect(b.mean, closeTo(30.0, 1e-12));
    });

    test('variance = n*p*(1-p)', () {
      const b = Binomial(n: 100, p: 0.3);
      expect(b.variance, closeTo(21.0, 1e-12));
    });

    test('large n PMFs are still finite (log-domain protects)', () {
      const b = Binomial(n: 200, p: 0.5);
      final pmf100 = b.pmf(100);
      expect(pmf100.isFinite, isTrue);
      expect(pmf100, greaterThan(0));
    });
  });
}

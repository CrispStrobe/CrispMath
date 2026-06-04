// lib/engine/multivariate_poly.dart
//
// Pure-Dart multivariate polynomial factoring for the web/native-less path.
//
// Provides a MultivariatePolynomial class (exponent-vector representation)
// and a MultivariateFactoring class that factors bivariate/multivariate
// polynomials over Q using pattern matching + Kronecker substitution.

import 'polynomial.dart';

/// A multivariate polynomial with rational coefficients.
///
/// Stored as a map from exponent vectors to coefficients.
/// The exponent vector is ordered according to [variables].
class MultivariatePolynomial {
  /// Ordered variable names.
  final List<String> variables;

  /// Exponent vector -> coefficient. Zero coefficients are not stored.
  final Map<String, Rational> _terms;

  MultivariatePolynomial(this.variables, Map<List<int>, Rational> terms)
      : _terms = {} {
    for (final entry in terms.entries) {
      if (!entry.value.isZero) {
        _terms[_key(entry.key)] = entry.value;
      }
    }
  }

  MultivariatePolynomial._(this.variables, this._terms);

  static String _key(List<int> exps) => exps.join(',');
  static List<int> _parseKey(String key) =>
      key.isEmpty ? [] : key.split(',').map(int.parse).toList();

  bool get isZero => _terms.isEmpty;

  int get numVars => variables.length;

  /// Total degree of the polynomial.
  int get totalDegree {
    var max = 0;
    for (final k in _terms.keys) {
      final exps = _parseKey(k);
      final sum = exps.fold<int>(0, (a, b) => a + b);
      if (sum > max) max = sum;
    }
    return max;
  }

  /// Degree in a specific variable (by index).
  int degreeIn(int varIdx) {
    var max = 0;
    for (final k in _terms.keys) {
      final exps = _parseKey(k);
      if (varIdx < exps.length && exps[varIdx] > max) {
        max = exps[varIdx];
      }
    }
    return max;
  }

  /// Get all terms as (exponent vector, coefficient) pairs.
  Iterable<(List<int>, Rational)> get terms sync* {
    for (final entry in _terms.entries) {
      yield (_parseKey(entry.key), entry.value);
    }
  }

  /// Number of terms.
  int get termCount => _terms.length;

  MultivariatePolynomial operator +(MultivariatePolynomial other) {
    assert(_sameVars(other));
    final result = Map<String, Rational>.from(_terms);
    for (final entry in other._terms.entries) {
      final existing = result[entry.key];
      if (existing != null) {
        final sum = existing + entry.value;
        if (sum.isZero) {
          result.remove(entry.key);
        } else {
          result[entry.key] = sum;
        }
      } else {
        result[entry.key] = entry.value;
      }
    }
    return MultivariatePolynomial._(variables, result);
  }

  MultivariatePolynomial operator -(MultivariatePolynomial other) {
    assert(_sameVars(other));
    final result = Map<String, Rational>.from(_terms);
    for (final entry in other._terms.entries) {
      final existing = result[entry.key];
      if (existing != null) {
        final diff = existing - entry.value;
        if (diff.isZero) {
          result.remove(entry.key);
        } else {
          result[entry.key] = diff;
        }
      } else {
        result[entry.key] = -entry.value;
      }
    }
    return MultivariatePolynomial._(variables, result);
  }

  MultivariatePolynomial operator *(MultivariatePolynomial other) {
    assert(_sameVars(other));
    final result = <String, Rational>{};
    for (final e1 in _terms.entries) {
      final exp1 = _parseKey(e1.key);
      for (final e2 in other._terms.entries) {
        final exp2 = _parseKey(e2.key);
        final newExp =
            List<int>.generate(variables.length, (i) => exp1[i] + exp2[i]);
        final key = _key(newExp);
        final prod = e1.value * e2.value;
        final existing = result[key];
        if (existing != null) {
          final sum = existing + prod;
          if (sum.isZero) {
            result.remove(key);
          } else {
            result[key] = sum;
          }
        } else {
          if (!prod.isZero) result[key] = prod;
        }
      }
    }
    return MultivariatePolynomial._(variables, result);
  }

  /// Scale by a rational constant.
  MultivariatePolynomial scale(Rational k) {
    if (k.isZero) return MultivariatePolynomial._(variables, {});
    final result = <String, Rational>{};
    for (final entry in _terms.entries) {
      result[entry.key] = entry.value * k;
    }
    return MultivariatePolynomial._(variables, result);
  }

  @override
  bool operator ==(Object other) {
    if (other is! MultivariatePolynomial) return false;
    if (!_sameVars(other)) return false;
    if (_terms.length != other._terms.length) return false;
    for (final entry in _terms.entries) {
      if (other._terms[entry.key] != entry.value) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(variables, _terms.length);

  bool _sameVars(MultivariatePolynomial other) {
    if (variables.length != other.variables.length) return false;
    for (var i = 0; i < variables.length; i++) {
      if (variables[i] != other.variables[i]) return false;
    }
    return true;
  }

  /// Format as string. Terms sorted by total degree descending, then
  /// lexicographic on exponent vector.
  @override
  String toString() {
    if (isZero) return '0';
    final sorted = _terms.entries.toList()
      ..sort((a, b) {
        final ea = _parseKey(a.key);
        final eb = _parseKey(b.key);
        final da = ea.fold<int>(0, (s, v) => s + v);
        final db = eb.fold<int>(0, (s, v) => s + v);
        if (da != db) return db.compareTo(da);
        // Lexicographic on exponent vector (higher first var first).
        for (var i = 0; i < ea.length; i++) {
          if (ea[i] != eb[i]) return eb[i].compareTo(ea[i]);
        }
        return 0;
      });

    final buf = StringBuffer();
    for (final entry in sorted) {
      final exps = _parseKey(entry.key);
      final c = entry.value;
      final isFirst = buf.isEmpty;

      // Determine the monomial part.
      final monBuf = StringBuffer();
      for (var i = 0; i < variables.length; i++) {
        if (exps[i] == 0) continue;
        monBuf.write(variables[i]);
        if (exps[i] > 1) monBuf.write('^${exps[i]}');
      }
      final mon = monBuf.toString();

      final mag = c.abs;
      if (isFirst) {
        if (c.sign < 0) buf.write('-');
        if (mon.isEmpty || mag != Rational.one) buf.write(mag);
        if (mon.isNotEmpty && mag != Rational.one && !mag.isInteger) {
          buf.write('*');
        }
        buf.write(mon);
      } else {
        buf.write(c.sign < 0 ? ' - ' : ' + ');
        if (mon.isEmpty || mag != Rational.one) buf.write(mag);
        if (mon.isNotEmpty && mag != Rational.one && !mag.isInteger) {
          buf.write('*');
        }
        buf.write(mon);
      }
    }
    return buf.toString();
  }

  /// Create a monomial: coefficient * prod(var_i^exp_i).
  factory MultivariatePolynomial.monomial(
      List<String> vars, List<int> exps, Rational coeff) {
    return MultivariatePolynomial(vars, {exps: coeff});
  }

  /// Create zero polynomial.
  factory MultivariatePolynomial.zero(List<String> vars) {
    return MultivariatePolynomial(vars, {});
  }

  /// Create constant polynomial.
  factory MultivariatePolynomial.constant(List<String> vars, Rational c) {
    return MultivariatePolynomial(vars, {List.filled(vars.length, 0): c});
  }
}

// ---------------------------------------------------------------------------
// Multivariate factoring
// ---------------------------------------------------------------------------

class MultivariateFactoring {
  /// Factor a multivariate polynomial expression string.
  /// Returns the factored form as a string, or null if factoring fails
  /// or is not applicable.
  static String? factor(String input) {
    final parsed = _parse(input);
    if (parsed == null) return null;
    if (parsed.isZero) return '0';
    if (parsed.termCount == 1) return null; // monomial, already factored

    final vars = parsed.variables;
    if (vars.length < 2) return null; // univariate — handled elsewhere

    // 1. Extract common monomial factor (GCD of all terms).
    final (content, primitive) = _extractCommonFactor(parsed);

    // 2. Try pattern-based shortcuts on the primitive part.
    final patternResult = _tryPatterns(primitive);
    if (patternResult != null) {
      return _formatResult(content, patternResult, vars);
    }

    // 3. Kronecker substitution for bivariate polynomials.
    if (vars.length == 2) {
      final kroResult = _kroneckerFactor(primitive);
      if (kroResult != null) {
        return _formatResult(content, kroResult, vars);
      }
    }

    // If we extracted a common factor but couldn't factor the rest further,
    // still report the common factor extraction.
    if (content != null) {
      return _formatResult(content, [primitive], vars);
    }

    return null;
  }

  // -------------------------------------------------------------------------
  // Common factor extraction
  // -------------------------------------------------------------------------

  /// Extract the GCD monomial factor from all terms.
  /// Returns (common_monomial_or_null, primitive_part).
  static (MultivariatePolynomial?, MultivariatePolynomial) _extractCommonFactor(
      MultivariatePolynomial p) {
    if (p.termCount <= 1) return (null, p);

    final vars = p.variables;
    final nVars = vars.length;

    // Find min exponent for each variable across all terms.
    final minExps = List<int>.filled(nVars, 999999);
    Rational? gcdCoeff;

    for (final (exps, coeff) in p.terms) {
      for (var i = 0; i < nVars; i++) {
        if (exps[i] < minExps[i]) minExps[i] = exps[i];
      }
      if (gcdCoeff == null) {
        gcdCoeff = coeff.abs;
      } else {
        gcdCoeff = _rationalGcd(gcdCoeff, coeff.abs);
      }
    }

    final hasCommonVar = minExps.any((e) => e > 0);
    final hasCommonCoeff = gcdCoeff != null && gcdCoeff != Rational.one;

    if (!hasCommonVar && !hasCommonCoeff) return (null, p);

    // Build the common factor and divide it out.
    final commonCoeff = hasCommonCoeff ? gcdCoeff : Rational.one;
    final commonExps = hasCommonVar ? minExps : List<int>.filled(nVars, 0);

    // Check if common factor is trivial (just "1").
    final isTrivial =
        commonCoeff == Rational.one && commonExps.every((e) => e == 0);
    if (isTrivial) return (null, p);

    final common =
        MultivariatePolynomial.monomial(vars, commonExps, commonCoeff);

    // Divide each term by the common factor.
    final newTerms = <List<int>, Rational>{};
    for (final (exps, coeff) in p.terms) {
      final newExps = List<int>.generate(nVars, (i) => exps[i] - commonExps[i]);
      newTerms[newExps] = coeff / commonCoeff;
    }

    return (common, MultivariatePolynomial(vars, newTerms));
  }

  static Rational _rationalGcd(Rational a, Rational b) {
    // GCD of two positive rationals: gcd(p/q, r/s) = gcd(p,r) / lcm(q,s)
    final gn = a.numerator.gcd(b.numerator);
    final ld = _lcm(a.denominator, b.denominator);
    return Rational(gn, ld);
  }

  static BigInt _lcm(BigInt a, BigInt b) => (a * b).abs() ~/ a.gcd(b);

  // -------------------------------------------------------------------------
  // Pattern-based shortcuts
  // -------------------------------------------------------------------------

  /// Try to factor using common algebraic patterns.
  /// Returns list of factors or null.
  static List<MultivariatePolynomial>? _tryPatterns(MultivariatePolynomial p) {
    final result = _tryDifferenceOfSquares(p) ??
        _trySumDifferenceCubes(p) ??
        _tryPerfectSquare(p) ??
        _tryGrouping(p);
    return result;
  }

  /// a^2 - b^2 = (a+b)(a-b) where a,b are monomials.
  static List<MultivariatePolynomial>? _tryDifferenceOfSquares(
      MultivariatePolynomial p) {
    if (p.termCount != 2) return null;
    final termList = p.terms.toList();
    final (exp1, c1) = termList[0];
    final (exp2, c2) = termList[1];

    // One positive, one negative coefficient.
    Rational posC, negC;
    List<int> posExp, negExp;
    if (c1.sign > 0 && c2.sign < 0) {
      posC = c1;
      negC = -c2;
      posExp = exp1;
      negExp = exp2;
    } else if (c2.sign > 0 && c1.sign < 0) {
      posC = c2;
      negC = -c1;
      posExp = exp2;
      negExp = exp1;
    } else {
      return null;
    }

    // Check all exponents are even.
    if (posExp.any((e) => e.isOdd) || negExp.any((e) => e.isOdd)) return null;

    // Check coefficients are perfect squares.
    final sqrtPosC = _rationalSqrt(posC);
    final sqrtNegC = _rationalSqrt(negC);
    if (sqrtPosC == null || sqrtNegC == null) return null;

    final vars = p.variables;
    final halfPosExp = posExp.map((e) => e ~/ 2).toList();
    final halfNegExp = negExp.map((e) => e ~/ 2).toList();

    // (a + b)
    final aPlusB = MultivariatePolynomial(vars, {
      halfPosExp: sqrtPosC,
      halfNegExp: sqrtNegC,
    });
    // (a - b)
    final aMinusB = MultivariatePolynomial(vars, {
      halfPosExp: sqrtPosC,
      halfNegExp: -sqrtNegC,
    });

    // Verify.
    if (aPlusB * aMinusB == p) return [aPlusB, aMinusB];
    return null;
  }

  /// a^3 + b^3 = (a+b)(a^2 - ab + b^2)
  /// a^3 - b^3 = (a-b)(a^2 + ab + b^2)
  static List<MultivariatePolynomial>? _trySumDifferenceCubes(
      MultivariatePolynomial p) {
    if (p.termCount != 2) return null;
    final termList = p.terms.toList();
    final (exp1, c1) = termList[0];
    final (exp2, c2) = termList[1];

    // All exponents must be divisible by 3.
    if (exp1.any((e) => e % 3 != 0) || exp2.any((e) => e % 3 != 0)) {
      return null;
    }

    // Coefficients must be perfect cubes.
    final cbrt1 = _rationalCbrt(c1.abs);
    final cbrt2 = _rationalCbrt(c2.abs);
    if (cbrt1 == null || cbrt2 == null) return null;

    final vars = p.variables;
    final thirdExp1 = exp1.map((e) => e ~/ 3).toList();
    final thirdExp2 = exp2.map((e) => e ~/ 3).toList();

    // Determine if sum or difference of cubes.
    // We want a^3 +/- b^3 where a,b are positive monomials.
    // Identify which term is positive and which is negative (or both positive).
    final sameSign = c1.sign == c2.sign;

    // Build a and b as positive monomials (cube roots of absolute values).
    final a = MultivariatePolynomial.monomial(vars, thirdExp1, cbrt1);
    final b = MultivariatePolynomial.monomial(vars, thirdExp2, cbrt2);

    MultivariatePolynomial linear, quadratic;
    if (sameSign && c1.sign > 0) {
      // a^3 + b^3 = (a+b)(a^2 - ab + b^2)
      linear = a + b;
      quadratic = a * a - a * b + b * b;
    } else if (sameSign && c1.sign < 0) {
      // -a^3 - b^3 = -(a^3 + b^3) — factor out -1 conceptually
      // Actually this means -(a+b)(a^2-ab+b^2), handle via negation.
      // For simplicity, return null and let other methods handle it.
      return null;
    } else if (c1.sign > 0 && c2.sign < 0) {
      // a^3 - b^3 = (a-b)(a^2 + ab + b^2)
      linear = a - b;
      quadratic = a * a + a * b + b * b;
    } else {
      // c1 < 0, c2 > 0: -a^3 + b^3 = b^3 - a^3 = (b-a)(b^2+ab+a^2)
      linear = b - a;
      quadratic = b * b + a * b + a * a;
    }

    if (linear * quadratic == p) return [linear, quadratic];
    return null;
  }

  /// a^2 + 2ab + b^2 = (a+b)^2
  /// a^2 - 2ab + b^2 = (a-b)^2
  static List<MultivariatePolynomial>? _tryPerfectSquare(
      MultivariatePolynomial p) {
    if (p.termCount != 3) return null;
    final termList = p.terms.toList();

    // Find the two "square" terms and the "cross" term.
    // Square terms have even exponents and positive coefficients that are
    // perfect squares. The cross term's exponent vector is the average of
    // the two square terms' vectors.
    for (var i = 0; i < 3; i++) {
      for (var j = i + 1; j < 3; j++) {
        final k = 3 - i - j; // the remaining index
        final (expI, cI) = termList[i];
        final (expJ, cJ) = termList[j];
        final (expK, cK) = termList[k];

        // Both i,j must have positive coeffs and even exponents.
        if (cI.sign <= 0 || cJ.sign <= 0) continue;
        if (expI.any((e) => e.isOdd) || expJ.any((e) => e.isOdd)) continue;

        final sqrtCI = _rationalSqrt(cI);
        final sqrtCJ = _rationalSqrt(cJ);
        if (sqrtCI == null || sqrtCJ == null) continue;

        // Cross term exponent should be average of i and j exponents.
        final vars = p.variables;
        final expectedCrossExp =
            List<int>.generate(vars.length, (v) => (expI[v] + expJ[v]) ~/ 2);
        // Check sum is actually even for each var.
        bool valid = true;
        for (var v = 0; v < vars.length; v++) {
          if ((expI[v] + expJ[v]).isOdd) {
            valid = false;
            break;
          }
        }
        if (!valid) continue;

        // Check cross term exponent matches.
        bool expsMatch = true;
        for (var v = 0; v < vars.length; v++) {
          if (expK[v] != expectedCrossExp[v]) {
            expsMatch = false;
            break;
          }
        }
        if (!expsMatch) continue;

        // Cross term coefficient should be +/- 2*sqrt(cI)*sqrt(cJ).
        final expectedCross = sqrtCI * sqrtCJ * Rational.fromInt(2);
        if (cK != expectedCross && cK != -expectedCross) continue;

        // Build factor (sqrt(cI)*a^(expI/2) +/- sqrt(cJ)*b^(expJ/2))
        final halfExpI = expI.map((e) => e ~/ 2).toList();
        final halfExpJ = expJ.map((e) => e ~/ 2).toList();
        final sign = cK.sign > 0 ? Rational.one : -Rational.one;

        final factor = MultivariatePolynomial(vars, {
          halfExpI: sqrtCI,
          halfExpJ: sqrtCJ * sign,
        });

        if (factor * factor == p) return [factor, factor];
      }
    }
    return null;
  }

  /// Try factoring by grouping: split terms into two groups, extract common
  /// factor from each, check if the remaining parts are equal.
  static List<MultivariatePolynomial>? _tryGrouping(MultivariatePolynomial p) {
    if (p.termCount < 4 || p.termCount > 6) return null;

    final termList = p.terms.toList();
    final vars = p.variables;
    final n = termList.length;

    // Try all ways to split terms into two equal groups.
    final halfSize = n ~/ 2;
    if (n != halfSize * 2) return null; // odd number of terms

    // Generate combinations of indices for the first group.
    final indices = List.generate(n, (i) => i);
    for (final group1Idx in _combinations(indices, halfSize)) {
      final group2Idx = indices.where((i) => !group1Idx.contains(i)).toList();

      final group1Terms = <List<int>, Rational>{};
      for (final i in group1Idx) {
        group1Terms[termList[i].$1] = termList[i].$2;
      }
      final group2Terms = <List<int>, Rational>{};
      for (final i in group2Idx) {
        group2Terms[termList[i].$1] = termList[i].$2;
      }

      final g1 = MultivariatePolynomial(vars, group1Terms);
      final g2 = MultivariatePolynomial(vars, group2Terms);

      final (common1, rem1) = _extractCommonFactor(g1);
      final (common2, rem2) = _extractCommonFactor(g2);

      if (common1 == null || common2 == null) continue;
      if (rem1.isZero || rem2.isZero) continue;

      // Check if remainders are equal or negatives.
      if (rem1 == rem2) {
        // g1 + g2 = common1*rem1 + common2*rem2 = (common1+common2)*rem1
        final combinedFactor = common1 + common2;
        if (combinedFactor.isZero) continue;
        if (combinedFactor * rem1 == p) {
          return [combinedFactor, rem1];
        }
      }
      // Check negative: rem1 == -rem2
      final negRem2 = rem2.scale(Rational.fromInt(-1));
      if (rem1 == negRem2) {
        final combinedFactor = common1 - common2;
        if (combinedFactor.isZero) continue;
        if (combinedFactor * rem1 == p) {
          return [combinedFactor, rem1];
        }
      }
    }
    return null;
  }

  // -------------------------------------------------------------------------
  // Kronecker substitution (bivariate -> univariate -> factor -> reverse)
  // -------------------------------------------------------------------------

  /// Factor a bivariate polynomial using Kronecker substitution.
  static List<MultivariatePolynomial>? _kroneckerFactor(
      MultivariatePolynomial p) {
    if (p.variables.length != 2) return null;

    final vars = p.variables;
    final degX = p.degreeIn(0);
    // Choose substitution: y = x^(degX + 1)
    final shift = degX + 1;

    // Convert to univariate by substituting y = x^shift.
    final univCoeffs = <int, Rational>{};
    for (final (exps, coeff) in p.terms) {
      final power = exps[0] + exps[1] * shift;
      univCoeffs[power] = (univCoeffs[power] ?? Rational.zero) + coeff;
    }

    final maxPower = univCoeffs.keys.fold<int>(0, (a, b) => a > b ? a : b);

    // Cap the degree to avoid blowup.
    if (maxPower > 200) return null;

    final coeffList = List<Rational>.generate(
        maxPower + 1, (i) => univCoeffs[i] ?? Rational.zero);
    final univPoly = Polynomial.fromCoeffs(coeffList, 'x');
    if (univPoly.isZero) return null;

    // Factor the univariate polynomial using RRT approach.
    final factors = _factorUnivariate(univPoly);
    if (factors == null || factors.length <= 1) return null;

    // Reverse substitution on each factor.
    final multiFactors = <MultivariatePolynomial>[];
    for (final f in factors) {
      final mf = _reverseSubstitution(f, vars, shift);
      if (mf == null) return null;
      multiFactors.add(mf);
    }

    // Verify: product of factors should equal the original.
    var product = multiFactors[0];
    for (var i = 1; i < multiFactors.length; i++) {
      product = product * multiFactors[i];
    }
    if (product == p) return multiFactors;

    return null;
  }

  /// Reverse Kronecker substitution: given a univariate polynomial where
  /// y was substituted as x^shift, recover the bivariate polynomial.
  static MultivariatePolynomial? _reverseSubstitution(
      Polynomial f, List<String> vars, int shift) {
    final terms = <List<int>, Rational>{};
    for (var i = 0; i <= f.degree; i++) {
      if (f.coeffs[i].isZero) continue;
      final yExp = i ~/ shift;
      final xExp = i % shift;
      terms[[xExp, yExp]] = f.coeffs[i];
    }
    return MultivariatePolynomial(vars, terms);
  }

  /// Factor a univariate polynomial over Q using the Rational Root Theorem.
  /// Returns list of irreducible factors (each factor is a Polynomial), or
  /// null if the polynomial is already irreducible.
  static List<Polynomial>? _factorUnivariate(Polynomial p) {
    if (p.degree <= 1) return null;

    final factors = <Polynomial>[];
    var remaining = p.monic();
    final variable = p.variable;

    // Extract leading coefficient.
    final lc = p.leading;

    // Find rational roots and extract linear factors.
    final candidates = _rationalRootCandidates(remaining);
    if (candidates == null) return null;

    for (final r in candidates) {
      while (remaining.degree >= 1 && _evalAt(remaining, r).isZero) {
        final lin =
            Polynomial.variable(variable) - Polynomial.constant(r, variable);
        final qr = remaining.divmod(lin);
        if (!qr.remainder.isZero) break;
        remaining = qr.quotient;
        factors.add(lin);
      }
    }

    if (remaining.degree >= 1) {
      factors.add(remaining);
    }

    if (factors.length <= 1 && lc == Rational.one) return null;
    if (factors.isEmpty) return null;

    // Scale the first factor by lc if needed.
    if (lc != Rational.one) {
      factors[0] = factors[0].scale(lc);
    }

    return factors.length > 1 ? factors : null;
  }

  static Rational _evalAt(Polynomial p, Rational r) {
    var acc = Rational.zero;
    for (var i = p.coeffs.length - 1; i >= 0; i--) {
      acc = acc * r + p.coeffs[i];
    }
    return acc;
  }

  static Set<Rational>? _rationalRootCandidates(Polynomial p) {
    final ints = _integerize(p);
    final an = ints.last.abs();
    final lowIdx = ints.indexWhere((v) => v != BigInt.zero);
    if (lowIdx < 0) return null;
    final aLow = ints[lowIdx].abs();

    final numDivs = _divisors(aLow);
    final denDivs = _divisors(an);
    if (numDivs == null || denDivs == null) return null;

    final out = <Rational>{};
    if (lowIdx > 0) out.add(Rational.zero);
    for (final num in numDivs) {
      for (final den in denDivs) {
        final r = Rational(num, den);
        out.add(r);
        out.add(-r);
      }
    }
    return out;
  }

  static List<BigInt> _integerize(Polynomial p) {
    var l = BigInt.one;
    for (final c in p.coeffs) {
      l = _lcm(l, c.denominator);
    }
    return [for (final c in p.coeffs) c.numerator * (l ~/ c.denominator)];
  }

  static Set<BigInt>? _divisors(BigInt n) {
    if (n <= BigInt.zero) return {BigInt.one};
    if (n > BigInt.from(1000000000000)) return null;
    final divs = <BigInt>{};
    var i = BigInt.one;
    while (i * i <= n) {
      if (n % i == BigInt.zero) {
        divs.add(i);
        divs.add(n ~/ i);
      }
      i += BigInt.one;
    }
    return divs;
  }

  // -------------------------------------------------------------------------
  // Formatting
  // -------------------------------------------------------------------------

  /// Format the factored result.
  static String _formatResult(MultivariatePolynomial? common,
      List<MultivariatePolynomial> factors, List<String> vars) {
    final parts = <String>[];

    if (common != null && !_isOne(common)) {
      parts.add(_formatFactor(common));
    }

    for (final f in factors) {
      if (_isOne(f)) continue;
      parts.add(_formatFactor(f));
    }

    if (parts.isEmpty) return '1';
    return parts.join('*');
  }

  static bool _isOne(MultivariatePolynomial p) {
    if (p.termCount != 1) return false;
    for (final (exps, coeff) in p.terms) {
      if (exps.any((e) => e != 0)) return false;
      if (coeff != Rational.one) return false;
    }
    return true;
  }

  static String _formatFactor(MultivariatePolynomial f) {
    final s = f.toString();
    // Wrap in parens if it has more than one term.
    if (f.termCount > 1) return '($s)';
    return s;
  }

  // -------------------------------------------------------------------------
  // Parsing
  // -------------------------------------------------------------------------

  /// Parse a multivariate polynomial expression string.
  static MultivariatePolynomial? _parse(String input) {
    try {
      return _MultiPolyParser(input).parse();
    } catch (_) {
      return null;
    }
  }

  // -------------------------------------------------------------------------
  // Utilities
  // -------------------------------------------------------------------------

  static Rational? _rationalSqrt(Rational r) {
    final ns = _intSqrt(r.numerator);
    if (ns == null) return null;
    final ds = _intSqrt(r.denominator);
    if (ds == null) return null;
    return Rational(ns, ds);
  }

  static BigInt? _intSqrt(BigInt n) {
    if (n < BigInt.zero) return null;
    if (n == BigInt.zero) return BigInt.zero;
    if (n == BigInt.one) return BigInt.one;
    var x = n;
    var y = (x + BigInt.one) >> 1;
    while (y < x) {
      x = y;
      y = (x + n ~/ x) >> 1;
    }
    return x * x == n ? x : null;
  }

  static Rational? _rationalCbrt(Rational r) {
    final nc = _intCbrt(r.numerator);
    if (nc == null) return null;
    final dc = _intCbrt(r.denominator);
    if (dc == null) return null;
    return Rational(nc, dc);
  }

  static BigInt? _intCbrt(BigInt n) {
    if (n == BigInt.zero) return BigInt.zero;
    if (n == BigInt.one) return BigInt.one;
    if (n < BigInt.zero) {
      final r = _intCbrt(-n);
      return r != null ? -r : null;
    }
    // Newton's method for integer cube root.
    var x = BigInt.one;
    // Initial estimate.
    var bits = n.bitLength;
    x = BigInt.one << ((bits + 2) ~/ 3);
    for (var i = 0; i < 100; i++) {
      final x2 = x * x;
      final next = (BigInt.two * x + n ~/ x2) ~/ BigInt.from(3);
      if (next >= x) break;
      x = next;
    }
    // Check x and x+1.
    if (x * x * x == n) return x;
    x += BigInt.one;
    if (x * x * x == n) return x;
    return null;
  }

  /// Generate all combinations of [k] elements from [items].
  static Iterable<List<int>> _combinations(List<int> items, int k) sync* {
    if (k == 0) {
      yield [];
      return;
    }
    if (k > items.length) return;
    if (k == items.length) {
      yield List.from(items);
      return;
    }
    for (var i = 0; i <= items.length - k; i++) {
      for (final rest in _combinations(items.sublist(i + 1), k - 1)) {
        yield [items[i], ...rest];
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Multivariate polynomial parser
// ---------------------------------------------------------------------------

class _MultiPolyParser {
  _MultiPolyParser(String input)
      : src = input.replaceAll('**', '^').replaceAll(' ', '');
  final String src;
  int _pos = 0;
  final _vars = <String>{};

  bool get _atEnd => _pos >= src.length;
  String? get _peek => _pos < src.length ? src[_pos] : null;

  MultivariatePolynomial? parse() {
    final terms = _parseExpr();
    if (!_atEnd) return null;
    if (_vars.isEmpty) return null; // no variables → not multivariate
    if (_vars.length < 2) return null; // univariate → handled elsewhere

    final sortedVars = _vars.toList()..sort();
    // Re-map terms to use sorted variable indices.
    final mapped = <List<int>, Rational>{};
    for (final entry in terms.entries) {
      final expVec = List<int>.filled(sortedVars.length, 0);
      for (final ve in entry.key.entries) {
        final idx = sortedVars.indexOf(ve.key);
        expVec[idx] = ve.value;
      }
      // Accumulate (in case the mapping merges terms).
      mapped[expVec] = (mapped[expVec] ?? Rational.zero) + entry.value;
    }
    return MultivariatePolynomial(sortedVars, mapped);
  }

  /// Parse additive expression. Returns map of {var->exp} -> coeff.
  Map<Map<String, int>, Rational> _parseExpr() {
    var negate = false;
    if (_peek == '+') {
      _pos++;
    } else if (_peek == '-') {
      _pos++;
      negate = true;
    }
    var result = _parseTerm();
    if (negate) {
      result = _negateTerms(result);
    }
    while (!_atEnd) {
      if (_peek == '+') {
        _pos++;
        result = _addTerms(result, _parseTerm());
      } else if (_peek == '-') {
        _pos++;
        result = _addTerms(result, _negateTerms(_parseTerm()));
      } else {
        break;
      }
    }
    return result;
  }

  /// Parse multiplicative term.
  Map<Map<String, int>, Rational> _parseTerm() {
    var result = _parsePower();
    while (!_atEnd) {
      if (_peek == '*') {
        _pos++;
        result = _mulTerms(result, _parsePower());
      } else if (_peek == '/') {
        _pos++;
        final divisor = _parsePower();
        // Only allow division by constant.
        if (divisor.length != 1) throw FormatException('non-constant divisor');
        final entry = divisor.entries.first;
        if (entry.key.values.any((v) => v != 0)) {
          throw FormatException('non-constant divisor');
        }
        final inv = Rational.one / entry.value;
        result = _scaleTerms(result, inv);
      } else if (_startsAtom()) {
        // Implicit multiplication: 2xy, x(x+1)
        result = _mulTerms(result, _parsePower());
      } else {
        break;
      }
    }
    return result;
  }

  bool _startsAtom() {
    final c = _peek;
    if (c == null) return false;
    return _isDigit(c) || c == '.' || c == '(' || _isLetter(c);
  }

  /// Parse power: atom ('^' int)?
  Map<Map<String, int>, Rational> _parsePower() {
    var base = _parseAtom();
    if (_peek == '^') {
      _pos++;
      final exp = _parseInt();
      base = _powTerms(base, exp);
    }
    return base;
  }

  /// Parse atom: number, variable, or (expr).
  Map<Map<String, int>, Rational> _parseAtom() {
    final c = _peek;
    if (c == null) throw FormatException('unexpected end');
    if (c == '(') {
      _pos++;
      final result = _parseExpr();
      if (_peek != ')') throw FormatException('missing )');
      _pos++;
      return result;
    }
    if (_isDigit(c) || c == '.') {
      return _parseNumber();
    }
    if (_isLetter(c)) {
      return _parseVariable();
    }
    throw FormatException('unexpected char: $c');
  }

  Map<Map<String, int>, Rational> _parseNumber() {
    final start = _pos;
    while (_pos < src.length && _isDigit(src[_pos])) _pos++;
    if (_pos < src.length && src[_pos] == '.') {
      _pos++;
      while (_pos < src.length && _isDigit(src[_pos])) _pos++;
    }
    // Check for fraction: digits/digits
    if (_pos < src.length && src[_pos] == '/' && _pos > start) {
      final numStr = src.substring(start, _pos);
      _pos++; // skip /
      final denStart = _pos;
      while (_pos < src.length && _isDigit(src[_pos])) _pos++;
      if (_pos > denStart) {
        final denStr = src.substring(denStart, _pos);
        final r = Rational(BigInt.parse(numStr), BigInt.parse(denStr));
        return {<String, int>{}: r};
      }
      _pos = denStart - 1; // backtrack
    }
    final text = src.substring(start, _pos);
    final r = _rationalFromDecimal(text);
    if (r == null) throw FormatException('bad number: $text');
    return {<String, int>{}: r};
  }

  Map<Map<String, int>, Rational> _parseVariable() {
    final c = src[_pos];
    // Multi-letter identifiers (sin, cos, etc.) are not supported.
    if (_pos + 1 < src.length && _isLetter(src[_pos + 1])) {
      throw FormatException('multi-letter name');
    }
    _pos++;
    _vars.add(c);
    return {
      {c: 1}: Rational.one
    };
  }

  int _parseInt() {
    if (_peek == '(') {
      _pos++;
      final v = _parseInt();
      if (_peek != ')') throw FormatException('missing )');
      _pos++;
      return v;
    }
    final start = _pos;
    while (_pos < src.length && _isDigit(src[_pos])) _pos++;
    if (_pos == start) throw FormatException('expected int');
    return int.parse(src.substring(start, _pos));
  }

  // Term-map operations.

  Map<Map<String, int>, Rational> _negateTerms(
      Map<Map<String, int>, Rational> t) {
    return {for (final e in t.entries) e.key: -e.value};
  }

  Map<Map<String, int>, Rational> _scaleTerms(
      Map<Map<String, int>, Rational> t, Rational k) {
    return {for (final e in t.entries) e.key: e.value * k};
  }

  Map<Map<String, int>, Rational> _addTerms(
      Map<Map<String, int>, Rational> a, Map<Map<String, int>, Rational> b) {
    final result = Map<Map<String, int>, Rational>.from(a);
    for (final e in b.entries) {
      final key = e.key;
      // Need to find matching key by content, not identity.
      final matchKey = _findKey(result, key);
      if (matchKey != null) {
        final sum = result[matchKey]! + e.value;
        if (sum.isZero) {
          result.remove(matchKey);
        } else {
          result[matchKey] = sum;
        }
      } else {
        result[Map.from(key)] = e.value;
      }
    }
    return result;
  }

  Map<Map<String, int>, Rational> _mulTerms(
      Map<Map<String, int>, Rational> a, Map<Map<String, int>, Rational> b) {
    final result = <Map<String, int>, Rational>{};
    for (final ea in a.entries) {
      for (final eb in b.entries) {
        final newExp = <String, int>{};
        for (final ve in ea.key.entries) {
          newExp[ve.key] = (newExp[ve.key] ?? 0) + ve.value;
        }
        for (final ve in eb.key.entries) {
          newExp[ve.key] = (newExp[ve.key] ?? 0) + ve.value;
        }
        // Remove zero exponents.
        newExp.removeWhere((k, v) => v == 0);
        final prod = ea.value * eb.value;
        final matchKey = _findKey(result, newExp);
        if (matchKey != null) {
          final sum = result[matchKey]! + prod;
          if (sum.isZero) {
            result.remove(matchKey);
          } else {
            result[matchKey] = sum;
          }
        } else {
          if (!prod.isZero) result[Map.from(newExp)] = prod;
        }
      }
    }
    return result;
  }

  Map<Map<String, int>, Rational> _powTerms(
      Map<Map<String, int>, Rational> base, int exp) {
    if (exp == 0) return {<String, int>{}: Rational.one};
    var result = base;
    for (var i = 1; i < exp; i++) {
      result = _mulTerms(result, base);
    }
    return result;
  }

  /// Find a key in the map that is content-equal to [target].
  Map<String, int>? _findKey(
      Map<Map<String, int>, Rational> map, Map<String, int> target) {
    for (final k in map.keys) {
      if (_mapsEqual(k, target)) return k;
    }
    return null;
  }

  bool _mapsEqual(Map<String, int> a, Map<String, int> b) {
    if (a.length != b.length) return false;
    for (final e in a.entries) {
      if (b[e.key] != e.value) return false;
    }
    return true;
  }

  static Rational? _rationalFromDecimal(String s) {
    if (RegExp(r'^\d+$').hasMatch(s)) {
      return Rational(BigInt.parse(s), BigInt.one);
    }
    final dec = RegExp(r'^(\d*)\.(\d+)$').firstMatch(s);
    if (dec != null) {
      final intPart = dec.group(1)!.isEmpty ? '0' : dec.group(1)!;
      final frac = dec.group(2)!;
      final digits = BigInt.parse('$intPart$frac');
      final den = BigInt.from(10).pow(frac.length);
      return Rational(digits, den);
    }
    return null;
  }

  static bool _isDigit(String c) {
    final u = c.codeUnitAt(0);
    return u >= 48 && u <= 57;
  }

  static bool _isLetter(String c) {
    final u = c.codeUnitAt(0);
    return (u >= 65 && u <= 90) || (u >= 97 && u <= 122);
  }
}

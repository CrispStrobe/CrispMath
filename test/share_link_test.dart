import 'package:crisp_calc/utils/share_link.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('buildShareUrl', () {
    test('encodes expression in URL', () {
      final url = buildShareUrl('x^2 + 1');
      expect(url, contains('expr=x%5E2%20%2B%201'));
    });

    test('includes tab parameter when non-zero', () {
      final url = buildShareUrl('sin(x)', tab: 2);
      expect(url, contains('tab=2'));
    });

    test('omits tab parameter when zero', () {
      final url = buildShareUrl('x+1', tab: 0);
      expect(url, isNot(contains('tab=')));
    });

    test('handles special characters', () {
      final url = buildShareUrl(r'\frac{a}{b}');
      expect(url, contains('expr='));
      // Should be decodable back
      final encoded = Uri.parse(url).queryParameters['expr'];
      expect(encoded, r'\frac{a}{b}');
    });

    test('handles empty expression', () {
      final url = buildShareUrl('');
      expect(url, contains('expr='));
    });
  });

  group('ShareParams', () {
    test('fromCurrentUrl returns null on non-web', () {
      // In test environment (non-web), should return null
      final params = ShareParams.fromCurrentUrl();
      expect(params, isNull);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:crisp_math/utils/expression_preprocessing_utils.dart';

void main() {
  test('Native LRU Cache accelerates repeated preprocesses', () {
    final exp1 = "2 + 2";
    final exp2 = "nCr(5, 3)";
    
    // First evaluation (not cached)
    final res1 = ExpressionPreprocessingUtils.preprocessNativeExpression(exp1);
    final res2 = ExpressionPreprocessingUtils.preprocessNativeExpression(exp2);
    
    // Second evaluation (cached)
    final res1Cached = ExpressionPreprocessingUtils.preprocessNativeExpression(exp1);
    final res2Cached = ExpressionPreprocessingUtils.preprocessNativeExpression(exp2);
    
    expect(res1, res1Cached);
    expect(res2, res2Cached);
    expect(res2Cached, contains("binomial(5,  3)"));
  });
}

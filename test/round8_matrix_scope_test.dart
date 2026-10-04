import 'package:crisp_math/engine/matrix_operation_names.dart';
import 'package:crisp_math/engine/notepad_evaluator.dart';
import 'package:flutter_test/flutter_test.dart';

ParsedNotepadLine _parse(String source) => classifyNotepadLine(
    source, lineIndex: 0, firstCodeLineIndex: 0);

void main() {
  test('every supported matrix call is registered without hiding its arguments', () {
    for (final operation in kMatrixUnaryOperationNames) {
      final parsed = _parse('$operation(Matrix([[a,1],[0,b]]))');
      expect(freeVariablesOfLine(parsed, {}), {'a', 'b'}, reason: operation);
      expect(dependenciesOfLine(parsed, {'a', 'b'}), {'a', 'b'}, reason: operation);
      expect(freeVariablesOfLine(parsed, {'a'}), {'b'}, reason: operation);
      expect(_parse('$operation=7').kind, NotepadLineKind.expression,
          reason: 'Matrix builtins cannot be shadowed by assignments');
    }
  });

  test('trace constant cells have no badge while unknown calls stay visible', () {
    expect(freeVariablesOfLine(_parse('trace(Matrix([[-2,1],[0,3]]))'), {}),
        isEmpty);
    expect(freeVariablesOfLine(_parse('inspect(Matrix([[a,1],[0,b]]))'), {}),
        {'inspect', 'a', 'b'});
    expect(dependenciesOfLine(_parse('trace(Matrix([[a,1],[0,3]]))'), {'a'}),
        {'a'});
  });
}

/// Bounded public linsolve forms: ([equations],[symbols]) or (eq;eq,x,y).
/// Commas inside nested calls never become equation or symbol separators.
({List<String> equations, List<String> symbols})? parseLinearSystemArguments(
    String source) {
  final call = source.trim();
  if (call.length > 2048 ||
      !call.startsWith('linsolve(') ||
      !call.endsWith(')')) {
    return null;
  }
  final args = _split(call.substring(9, call.length - 1), ',');
  if (args == null || args.length < 2) {
    return null;
  }
  List<String>? equations;
  List<String>? symbols;
  if (args[0].startsWith('[')) {
    if (args.length != 2 ||
        !args[0].endsWith(']') ||
        !args[1].startsWith('[') ||
        !args[1].endsWith(']')) {
      return null;
    }
    equations = _split(args[0].substring(1, args[0].length - 1), ',');
    symbols = _split(args[1].substring(1, args[1].length - 1), ',');
  } else {
    equations = _split(args[0], ';');
    symbols = args.sublist(1);
  }
  if (equations == null || symbols == null ||
      equations.isEmpty || equations.length > 32 ||
      symbols.isEmpty || symbols.length > 16 ||
      symbols.toSet().length != symbols.length ||
      symbols.any((s) => !RegExp(r'^[A-Za-z][A-Za-z0-9_]*$').hasMatch(s)) ||
      equations.any((e) => e.length > 512 || e.split('=').length > 2 ||
          e.split('=').any((side) => side.trim().isEmpty))) {
    return null;
  }
  return (equations: equations, symbols: symbols);
}

List<String>? _split(String body, String separator) {
  final stack = <String>[];
  final parts = <String>[];
  const pairs = {')': '(', ']': '[', '}': '{'};
  var start = 0;
  for (var i = 0; i < body.length; i++) {
    final c = body[i];
    if ('([{'.contains(c)) {
      stack.add(c);
    } else if (pairs.containsKey(c)) {
      if (stack.isEmpty || stack.removeLast() != pairs[c]) {
        return null;
      }
    } else if (c == separator && stack.isEmpty) {
      parts.add(body.substring(start, i).trim());
      start = i + 1;
    }
  }
  if (stack.isNotEmpty) {
    return null;
  }
  parts.add(body.substring(start).trim());
  return parts.any((p) => p.isEmpty) ? null : parts;
}

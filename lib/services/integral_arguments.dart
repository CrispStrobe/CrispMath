/// Both worksheet and calculator forms, with nested commas kept in arguments.
/// Returns [expression, variable] or [expression, variable, lower, upper].
List<String>? parseIntegralArguments(String source) {
  final call = source.trim();
  if (!call.startsWith('integrate(') || !call.endsWith(')')) return null;
  var args = _split(call.substring(10, call.length - 1));
  if (args == null) return null;
  if (args.length == 2 && args[1].startsWith('(') && args[1].endsWith(')')) {
    final bounds = _split(args[1].substring(1, args[1].length - 1));
    if (bounds == null || bounds.length != 3) return null;
    args = [args[0], ...bounds];
  }
  if (args.length != 2 && args.length != 4) return null;
  if (!RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$').hasMatch(args[1])) return null;
  return args;
}

/// A limit binds its variable in the expression, with an unbound approach point.
/// Nested argument commas are retained; malformed declarations decline.
List<String>? parseLimitArguments(String source) {
  final call = source.trim();
  if (!call.startsWith('limit(') || !call.endsWith(')')) return null;
  final args = _split(call.substring(6, call.length - 1));
  if (args == null || args.length != 3 ||
      !RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$').hasMatch(args[1])) return null;
  return args;
}

List<String>? _split(String body) {
  final stack = <String>[];
  final args = <String>[];
  var start = 0;
  const pairs = {')': '(', ']': '[', '}': '{'};
  for (var i = 0; i < body.length; i++) {
    final ch = body[i];
    if ('([{'.contains(ch)) {
      stack.add(ch);
    } else if (pairs.containsKey(ch)) {
      if (stack.isEmpty || stack.removeLast() != pairs[ch]) return null;
    } else if (ch == ',' && stack.isEmpty) {
      args.add(body.substring(start, i).trim());
      start = i + 1;
    }
  }
  if (stack.isNotEmpty) return null;
  args.add(body.substring(start).trim());
  return args.any((a) => a.isEmpty) ? null : args;
}

import 'function_reference.dart';

class AppCommand {
  final String id, title, description, target;
  const AppCommand(this.id, this.title, this.description, this.target);
}

final appCommands = <AppCommand>[
  for (final entry in const [
    'Calculator',
    'Notepad',
    'Graphing',
    'Functions',
    'Analysis',
    'Settings'
  ].indexed)
    AppCommand(
        'tab-${entry.$1}', entry.$2, 'Open ${entry.$2}', 'tab:${entry.$1}'),
  const AppCommand('units', 'Unit converter',
      'Convert length, mass, temperature and more', 'units'),
  const AppCommand('reference', 'Function reference',
      'Browse functions and runnable examples', 'reference:'),
  const AppCommand('statistics', 'Statistics',
      'Distributions, regression and hypothesis tests', 'open:statistics'),
  const AppCommand('constraints', 'Constraints',
      'Solve constraints and logic puzzles', 'open:constraints'),
  const AppCommand(
      'sudoku', 'Sudoku', 'Solve and explore Sudoku puzzles', 'open:sudoku'),
  for (final ref in FunctionReferences.all)
    AppCommand('function-${ref.id}', ref.signature, ref.shortDescription,
        'reference:${ref.id}'),
];

List<AppCommand> searchCommands(String query, {List<AppCommand>? catalog}) {
  final words = query
      .trim()
      .toLowerCase()
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .toList();
  final matches = (catalog ?? appCommands)
      .where((c) => words.every((w) =>
          '${c.title} ${c.description} ${c.id}'.toLowerCase().contains(w)))
      .toList();
  int score(AppCommand c) => words.isEmpty
      ? 0
      : c.title.toLowerCase() == query.trim().toLowerCase()
          ? 0
          : c.title.toLowerCase().startsWith(words.first)
              ? 1
              : 2;
  matches.sort((a, b) {
    final rank = score(a).compareTo(score(b));
    return rank == 0
        ? (catalog ?? appCommands)
            .indexOf(a)
            .compareTo((catalog ?? appCommands).indexOf(b))
        : rank;
  });
  return matches;
}

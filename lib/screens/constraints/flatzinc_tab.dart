// lib/screens/constraints/flatzinc_tab.dart
//
// Constraints → FlatZinc tab.

part of '../constraints_screen.dart';

class _FlatZincTab extends StatefulWidget {
  const _FlatZincTab();
  @override
  State<_FlatZincTab> createState() => _FlatZincTabState();
}

class _FlatZincTabState extends State<_FlatZincTab> {
  // Gallery of canonical FlatZinc snippets. Hand-written to be
  // small enough to read in the textarea; the dart_csp HEAD's
  // FlatZinc parser handles the full spec, so users can paste
  // anything mzn2fzn produces.
  static const List<({String id, String source})> _gallery = [
    (
      // 4-queens: row index implicit, queen[i] = column. Pairwise
      // diagonals via int_lin_ne (queen[i] - queen[j] != ±(i-j)).
      id: 'nqueens4',
      source: '''array[1..4] of var 1..4: q :: output_array([1..4]);
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
''',
    ),
    (
      // Bin-packing: 3 items of sizes [2, 3, 5] across 2 bins of
      // capacity 5. bin_packing_load propagates load[b] = sum of
      // sizes of items assigned to bin b.
      id: 'binPacking',
      source: '''array[1..2] of var 0..5: load :: output_array([1..2]);
array[1..3] of var 1..2: bin :: output_array([1..3]);
constraint bin_packing_load(load, bin, [2, 3, 5]);
solve satisfy;
''',
    ),
  ];

  final _ctl = TextEditingController(text: _gallery.first.source);
  bool _allSolutions = false;
  bool _solving = false;
  String? _output;
  String? _error;
  CspMusResult? _mus;
  bool _explaining = false;

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  void _loadExample(String source) {
    setState(() {
      _ctl.text = source;
      _output = null;
      _error = null;
      _mus = null;
    });
  }

  Future<void> _solve() async {
    final source = _ctl.text;
    setState(() {
      _solving = true;
      _output = null;
      _error = null;
      _mus = null;
    });
    String? out;
    String? err;
    try {
      out = await FlatZinc.solve(source, all: _allSolutions);
    } catch (e) {
      err = e.toString();
    }
    if (!mounted) return;
    setState(() {
      _solving = false;
      _output = out;
      _error = err;
    });
  }

  Future<void> _explain() async {
    setState(() => _explaining = true);
    final r = await CspSolver.explainFlatZinc(_ctl.text);
    if (!mounted) return;
    setState(() {
      _explaining = false;
      _mus = r;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(t.constraintsFlatZincIntro,
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          TextField(
            controller: _ctl,
            minLines: 8,
            maxLines: 20,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            decoration: InputDecoration(
              labelText: t.constraintsFlatZincInputLabel,
              border: const OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: _solving ? null : _solve,
                icon: _solving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.play_arrow),
                label: Text(t.constraintsSolveButton),
              ),
              FilterChip(
                label: Text(t.constraintsFlatZincAllSolutions),
                selected: _allSolutions,
                onSelected: (v) => setState(() => _allSolutions = v),
              ),
              PopupMenuButton<String>(
                tooltip: t.constraintsDslExamplesTooltip,
                onSelected: _loadExample,
                itemBuilder: (context) => [
                  for (final entry in _gallery)
                    PopupMenuItem<String>(
                      value: entry.source,
                      child: Text(t.constraintsFlatZincExampleTitle(entry.id)),
                    ),
                ],
                child: OutlinedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.menu_book_outlined, size: 18),
                  label: Text(t.constraintsDslExamplesButton),
                ),
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            _FlatZincErrorBlock(message: _error!),
          ],
          if (_output != null) ...[
            const SizedBox(height: 16),
            _FlatZincOutputBlock(text: _output!),
            if (_output!.contains('=====UNSATISFIABLE=====')) ...[
              const SizedBox(height: 12),
              _ExplainSection(
                isLoading: _explaining,
                result: _mus,
                onExplain: _explain,
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _FlatZincErrorBlock extends StatelessWidget {
  final String message;
  const _FlatZincErrorBlock({required this.message});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: scheme.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: SelectableText(
              message,
              style: TextStyle(
                color: scheme.onErrorContainer,
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FlatZincOutputBlock extends StatelessWidget {
  final String text;
  const _FlatZincOutputBlock({required this.text});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    // Standard FlatZinc output ends with `==========` when search
    // is exhaustive (every solution found, or optimization proven
    // optimal), or `=====UNSATISFIABLE=====` when no solution exists.
    final trimmed = text.trim();
    final isUnsat = trimmed.contains('=====UNSATISFIABLE=====');
    final isExhaustive = trimmed.endsWith('==========');
    final solCount = '\n$trimmed'.split('\n----------').length - 1;
    final header = isUnsat
        ? t.constraintsFlatZincUnsatisfiable
        : isExhaustive
            ? (solCount == 1
                ? t.constraintsFlatZincExhaustiveOne
                : t.constraintsFlatZincExhaustiveN(solCount))
            : t.constraintsFlatZincFirstSolution;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(header, style: Theme.of(context).textTheme.titleSmall),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.copy, size: 18),
              tooltip: t.constraintsCopyResult,
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: text));
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(t.constraintsCopiedToast),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(6),
          ),
          child: SelectableText(
            text,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
      ],
    );
  }
}

// === Round E.2 — shared "Explain failure" / MUS rendering =================

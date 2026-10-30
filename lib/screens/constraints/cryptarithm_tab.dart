// lib/screens/constraints/cryptarithm_tab.dart
//
// Constraints → Cryptarithm tab.

part of '../constraints_screen.dart';

class _CryptarithmTab extends StatefulWidget {
  const _CryptarithmTab();
  @override
  State<_CryptarithmTab> createState() => _CryptarithmTabState();
}

class _CryptarithmTabState extends State<_CryptarithmTab> {
  final _ctl = TextEditingController(text: 'SEND + MORE = MONEY');
  CryptarithmResult? _result;
  bool _solving = false;
  CspMusResult? _mus;
  bool _explaining = false;
  // Round 115 (C9): AC-3 propagation trace for the cryptarithm model,
  // reusing the DSL tab's PropagationVisualizer.
  CspTraceResult? _trace;
  bool _tracing = false;

  @override
  void initState() {
    super.initState();
    // Drain a pending `open:constraints?cryptarithm=<puzzle>` request
    // (set by the worked-examples / Function Reference dispatcher). The
    // sentinel carries the puzzle without spaces; prettify it back to
    // the tab's `WORD op WORD = WORD` display style.
    final puzzle = AppState().consumePendingCryptarithmPuzzle();
    if (puzzle != null && puzzle.trim().isNotEmpty) {
      _ctl.text = _prettifyCryptarithm(puzzle);
    }
  }

  /// Re-inserts spaces around the operators of a compact cryptarithm
  /// string (`SEND+MORE=MONEY` → `SEND + MORE = MONEY`) so a sentinel-
  /// supplied puzzle matches the field's hand-typed style. The solver
  /// strips whitespace anyway, so this is purely cosmetic.
  static String _prettifyCryptarithm(String raw) => raw
      .replaceAll(' ', '')
      .replaceAllMapped(RegExp(r'[+\-=]'), (m) => ' ${m[0]} ')
      .trim();

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  Future<void> _solve() async {
    setState(() {
      _solving = true;
      _mus = null;
      _trace = null;
    });
    final r = await CspSolver.solveCryptarithm(_ctl.text);
    if (!mounted) return;
    setState(() {
      _solving = false;
      _result = r;
    });
  }

  // Round 115 (C9): trace the cryptarithm's AC-3 propagation.
  Future<void> _visualize() async {
    setState(() => _tracing = true);
    final tr = await CspSolver.traceCryptarithm(_ctl.text);
    if (!mounted) return;
    setState(() {
      _tracing = false;
      _trace = tr;
    });
  }

  Future<void> _explain() async {
    setState(() => _explaining = true);
    final r = await CspSolver.explainCryptarithm(_ctl.text);
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
          Text(t.constraintsCryptarithmIntro,
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          TextField(
            controller: _ctl,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
            decoration: InputDecoration(
              labelText: t.constraintsCryptarithmInputLabel,
              hintText: 'SEND + MORE = MONEY',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
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
              // Round 115 (C9): AC-3 propagation step-visualizer over the
              // cryptarithm model.
              OutlinedButton.icon(
                onPressed: _tracing ? null : _visualize,
                icon: _tracing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.slideshow_outlined, size: 18),
                label: Text(t.constraintsVisualizeButton),
              ),
            ],
          ),
          if (_result != null) ...[
            const SizedBox(height: 16),
            _CryptarithmResultBlock(result: _result!),
            // Surface Explain only on the "no assignment" case, not
            // on shape-parse errors where the model wasn't built.
            if (!_result!.ok && _result!.error!.contains('No assignment')) ...[
              const SizedBox(height: 12),
              _ExplainSection(
                isLoading: _explaining,
                result: _mus,
                onExplain: _explain,
              ),
            ],
          ],
          if (_trace != null) ...[
            const SizedBox(height: 16),
            if (_trace!.ok)
              PropagationVisualizer(trace: _trace!)
            else
              _TraceErrorBlock(message: _trace!.error!),
          ],
        ],
      ),
    );
  }
}

// === DSL tab (CSP Round C) ==============================================

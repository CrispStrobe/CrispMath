// lib/screens/constraints/magic_square_tab.dart
//
// Constraints → Magic square tab: generate a square and replay the solver.

part of '../constraints_screen.dart';

class _MagicSquareTab extends StatefulWidget {
  const _MagicSquareTab({this.solveForTesting});

  /// Overrides the CSP solve boundary in deterministic widget tests.
  final MagicSquareSolve? solveForTesting;

  @override
  State<_MagicSquareTab> createState() => _MagicSquareTabState();
}

class _MagicSquareTabState extends State<_MagicSquareTab> {
  int _n = 3;
  List<int>? _square;
  bool _solving = false;
  final _rng = Random();
  CspTraceResult? _trace;
  bool _tracing = false;

  /// Set when a Generate attempt produced no square, so the tab can say why
  /// instead of appearing to ignore the tap.
  String? _error;

  /// Larger squares exceed the trace cap before a readable replay: a 5×5
  /// trace needs more than 20,000 events and would replay only a truncated
  /// prefix.
  static const _maxTracedOrder = 4;

  Future<void> _visualize() async {
    final n = _n;
    setState(() {
      _tracing = true;
      _trace = null;
      _square = null;
      _error = null;
    });
    final tr = await CspSolver.traceDsl(MagicSquare.buildProgram(n));
    if (!mounted || n != _n) return;
    setState(() {
      _tracing = false;
      _trace = tr;
      if (tr.solved && tr.solution != null) {
        _square = MagicSquare.gridFromSolution(tr.solution!, n);
      }
    });
  }

  Future<void> _generate() async {
    final n = _n;
    setState(() {
      _solving = true;
      _square = null;
      _trace = null;
      _error = null;
    });
    final solve = widget.solveForTesting ?? CspSolver.solveDsl;
    DiophantineResult r;
    try {
      r = await solve(MagicSquare.buildProgram(n), maxSolutions: 1);
    } catch (e) {
      // A thrown solve must not leave the button spinning forever with no
      // visible outcome.
      r = DiophantineResult.failure('Magic-square solve failed: $e');
    }
    if (!mounted) return;
    if (n != _n) {
      setState(() => _solving = false);
      return;
    }
    final error = r.ok && r.solutions.isNotEmpty
        ? null
        : (r.error ?? AppLocalizations.of(context).constraintsNoSolutions);
    setState(() {
      _solving = false;
      _error = error;
      if (error == null) {
        final grid = MagicSquare.gridFromSolution(r.solutions.first, n);
        _square = MagicSquare.randomVariant(grid, n, _rng);
      }
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
          Text(
            t.constraintsMagicIntro,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('${t.constraintsMagicSize}:  '),
              const SizedBox(width: 4),
              ...MagicSquare.supportedSizes.map(
                (n) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text('$n×$n'),
                    selected: _n == n,
                    onSelected: _solving || _tracing
                        ? null
                        : (sel) {
                            if (sel && n != _n) {
                              setState(() {
                                _n = n;
                                _square = null;
                                _trace = null;
                                _error = null;
                                _tracing = false;
                              });
                            }
                          },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            t.constraintsMagicConstant(MagicSquare.constantFor(_n)),
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: _solving || _tracing ? null : _generate,
                icon: _solving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.casino_outlined),
                label: Text(t.constraintsMagicGenerate),
              ),
              if (_n <= _maxTracedOrder)
                OutlinedButton.icon(
                  key: const ValueKey('magic-visualize'),
                  onPressed: _tracing || _solving ? null : _visualize,
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
          const SizedBox(height: 8),
          Text(
            t.constraintsMagicVisualizeHint,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            _TraceErrorBlock(message: _error!),
          ],
          if (_square != null) ...[
            const SizedBox(height: 20),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: _MagicSquareGrid(
                  key: const ValueKey('magic-square-grid'),
                  values: _square!,
                  n: _n,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              t.constraintsMagicHint,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
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

/// Renders an N×N magic square as a bordered grid of centered numbers.
class _MagicSquareGrid extends StatelessWidget {
  final List<int> values;
  final int n;
  const _MagicSquareGrid({super.key, required this.values, required this.n});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: scheme.outline, width: 1.5),
        ),
        child: Column(
          children: [
            for (var r = 0; r < n; r++)
              Expanded(
                child: Row(
                  children: [
                    for (var c = 0; c < n; c++)
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: scheme.outlineVariant),
                            color: scheme.surfaceContainerHighest,
                          ),
                          alignment: Alignment.center,
                          child: FittedBox(
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Text(
                                '${values[r * n + c]}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// === Diophantine tab ====================================================

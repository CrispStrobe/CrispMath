// lib/screens/constraints/diophantine_tab.dart
//
// Constraints → Diophantine tab: variables, constraints, solve and trace.

part of '../constraints_screen.dart';

class _DiophantineTab extends StatefulWidget {
  const _DiophantineTab();
  @override
  State<_DiophantineTab> createState() => _DiophantineTabState();
}

class _DiophantineTabState extends State<_DiophantineTab> {
  final _varsCtl = TextEditingController(text: 'x in 0..50\ny in 0..50');
  final _constraintsCtl =
      TextEditingController(text: '2*x + 3*y == 30\nx <= y');
  DiophantineResult? _result;
  bool _solving = false;
  // Round E.2: MUS state. Cleared whenever a fresh solve runs so the
  // user doesn't see a stale conflict tied to inputs that have since
  // changed. Populated by `_explain`.
  CspMusResult? _mus;
  bool _explaining = false;
  // Round 115 (C9): AC-3 propagation trace for this tab, reusing the DSL
  // tab's PropagationVisualizer. Cleared on every fresh solve.
  CspTraceResult? _trace;
  bool _tracing = false;

  @override
  void dispose() {
    _varsCtl.dispose();
    _constraintsCtl.dispose();
    super.dispose();
  }

  /// Parses one variable line. Accepts:
  ///   `name in min..max`
  /// Returns null on shape mismatch — caller surfaces an error per line.
  ({String name, int min, int max})? _parseVarLine(String line) {
    final m =
        RegExp(r'^([A-Za-z_][A-Za-z0-9_]*)\s+in\s+(-?\d+)\s*\.\.\s*(-?\d+)$')
            .firstMatch(line.trim());
    if (m == null) return null;
    return (
      name: m.group(1)!,
      min: int.parse(m.group(2)!),
      max: int.parse(m.group(3)!),
    );
  }

  Future<void> _solve() async {
    final t = AppLocalizations.of(context);
    final varLines = _varsCtl.text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    final variables = <String, ({int min, int max})>{};
    final parseErrors = <String>[];
    for (final line in varLines) {
      final v = _parseVarLine(line);
      if (v == null) {
        parseErrors.add('${t.constraintsBadVarLine}: $line');
        continue;
      }
      variables[v.name] = (min: v.min, max: v.max);
    }
    if (parseErrors.isNotEmpty) {
      setState(() => _result = DiophantineResult.failure(parseErrors.first));
      return;
    }
    final constraints = _constraintsCtl.text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    setState(() {
      _solving = true;
      _mus = null;
      _trace = null;
    });
    final r = await CspSolver.solveDiophantine(
        variables: variables, constraints: constraints);
    if (!mounted) return;
    setState(() {
      _solving = false;
      _result = r;
    });
  }

  // Round 115 (C9): AC-3 propagation trace. Re-parse the live inputs
  // (same shape as `_solve`) into an equivalent DSL program — one
  // `vars:` line per variable so per-variable ranges survive — and reuse
  // the DSL tracer + PropagationVisualizer.
  Future<void> _visualize() async {
    final t = AppLocalizations.of(context);
    final variables = <String, ({int min, int max})>{};
    for (final line in _varsCtl.text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)) {
      final v = _parseVarLine(line);
      if (v == null) {
        setState(() => _trace =
            CspTraceResult.failure('${t.constraintsBadVarLine}: $line'));
        return;
      }
      variables[v.name] = (min: v.min, max: v.max);
    }
    final constraints = _constraintsCtl.text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    final dsl = StringBuffer();
    variables
        .forEach((name, r) => dsl.writeln('vars: $name in ${r.min}..${r.max}'));
    for (final c in constraints) {
      dsl.writeln(c);
    }
    setState(() => _tracing = true);
    final tr = await CspSolver.traceDsl(dsl.toString());
    if (!mounted) return;
    setState(() {
      _tracing = false;
      _trace = tr;
    });
  }

  Future<void> _explain() async {
    // Re-parse the live inputs so the MUS reflects whatever's in the
    // textareas right now (which may differ from the last solve if
    // the user edited but hasn't re-solved). Parse errors fall
    // through to a no-op — the user has a stale result and the
    // standard solve-time error path will take over on next Solve.
    final variables = <String, ({int min, int max})>{};
    for (final line in _varsCtl.text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)) {
      final v = _parseVarLine(line);
      if (v == null) return;
      variables[v.name] = (min: v.min, max: v.max);
    }
    final constraints = _constraintsCtl.text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    setState(() => _explaining = true);
    final r = await CspSolver.explainDiophantine(
      variables: variables,
      constraints: constraints,
    );
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
          Text(t.constraintsDiophantineIntro,
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          TextField(
            controller: _varsCtl,
            maxLines: 4,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            decoration: InputDecoration(
              labelText: t.constraintsVariablesLabel,
              helperText: t.constraintsVariablesHint,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _constraintsCtl,
            maxLines: 6,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            decoration: InputDecoration(
              labelText: t.constraintsConstraintsLabel,
              helperText: t.constraintsConstraintsHint,
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
              // Round 115 (C9): AC-3 propagation step-visualizer, same
              // widget the DSL tab uses.
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
            _ResultBlock(result: _result!),
            if (_result!.ok && _result!.solutions.isEmpty) ...[
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

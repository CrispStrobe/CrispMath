// lib/screens/constraints/dsl_tab.dart
//
// Constraints → free-form DSL tab, its operator help and FlatZinc export.

part of '../constraints_screen.dart';

class _DslTab extends StatefulWidget {
  const _DslTab();
  @override
  State<_DslTab> createState() => _DslTabState();
}

class _DslTabState extends State<_DslTab> {
  // Round 72 gallery: each entry's `program` is a complete DSL
  // text that replaces the TextField on pick. The `id` doubles as
  // the i18n key for the localized title.
  static const List<({String id, String program})> _gallery = [
    (
      id: 'magicSum',
      program: '''vars: x, y, z in 1..9
allDifferent(x, y, z)
x + y + z == 15''',
    ),
    (
      // Classic 3×3 magic square: 9 distinct digits 1..9 with
      // every row, column, and main diagonal summing to 15.
      id: 'magicSquare3',
      program: '''vars: a, b, c, d, e, f, g, h, i in 1..9
allDifferent(a, b, c, d, e, f, g, h, i)
a + b + c == 15
d + e + f == 15
g + h + i == 15
a + d + g == 15
b + e + h == 15
c + f + i == 15
a + e + i == 15
c + e + g == 15''',
    ),
    (
      // 4×4 magic square: 16 distinct values 1..16 with every
      // row, column, and main diagonal summing to the magic
      // constant M = N(N²+1)/2 = 4·17/2 = 34. Solving the
      // program is itself a generator — there are 7040 distinct
      // 4×4 magic squares (ignoring symmetry), so the solver
      // returns one of them.
      id: 'magicSquare4',
      program: '''vars: a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p in 1..16
allDifferent(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p)
a + b + c + d == 34
e + f + g + h == 34
i + j + k + l == 34
m + n + o + p == 34
a + e + i + m == 34
b + f + j + n == 34
c + g + k + o == 34
d + h + l + p == 34
a + f + k + p == 34
d + g + j + m == 34''',
    ),
    (
      // Four mutually-adjacent regions colored with 3 colors.
      // Adjacency: 1-2, 1-3, 1-4, 2-3, 2-4, 3-4 — a complete
      // K4 graph, which is NOT 3-colorable, so this enumerates
      // zero solutions. Edit to drop one edge for solutions.
      id: 'mapColoring',
      program: '''vars: r1, r2, r3, r4 in 1..3
r1 != r2
r1 != r3
r2 != r3
r3 != r4
r2 != r4''',
    ),
    (
      // The canonical map-coloring CSP (Russell & Norvig): color
      // the seven Australian states/territories so that no two
      // adjacent regions share a color. Three colors suffice
      // (the map is planar). Variables: wa=Western Australia,
      // nt=Northern Territory, sa=South Australia, q=Queensland,
      // nsw=New South Wales, v=Victoria, t=Tasmania. Tasmania is
      // an island with no land border, so it carries no
      // adjacency constraint and is freely colorable.
      id: 'mapColoringAustralia',
      program: '''vars: wa, nt, sa, q, nsw, v, t in 1..3
wa != nt
wa != sa
nt != sa
nt != q
sa != q
sa != nsw
sa != v
q != nsw
nsw != v''',
    ),
    (
      // Germany's 16 Bundesländer (ISO 3166-2:DE codes as variable
      // names: bw=Baden-Württemberg, by=Bayern, be=Berlin,
      // bb=Brandenburg, hb=Bremen, hh=Hamburg, he=Hessen,
      // mv=Mecklenburg-Vorpommern, ni=Niedersachsen,
      // nw=Nordrhein-Westfalen, rp=Rheinland-Pfalz, sl=Saarland,
      // sn=Sachsen, st=Sachsen-Anhalt, sh=Schleswig-Holstein,
      // th=Thüringen). Unlike Australia (3-colorable), this map needs
      // FOUR colors: Thüringen borders five states (ni, st, sn, by,
      // he) that themselves form a 5-cycle — a 5-wheel, whose
      // chromatic number is 4. So the domain here is 1..4; with only
      // three colors the program is unsatisfiable. Berlin (be) sits
      // entirely inside Brandenburg (bb); Bremen (hb) inside
      // Niedersachsen (ni) — both classic enclaves.
      id: 'mapColoringGermany',
      program:
          '''vars: bw, by, be, bb, hb, hh, he, mv, ni, nw, rp, sl, sn, st, sh, th in 1..4
sh != hh
sh != ni
sh != mv
hh != ni
mv != ni
mv != bb
ni != hb
ni != st
ni != bb
ni != th
ni != he
ni != nw
st != bb
st != sn
st != th
bb != be
bb != sn
nw != he
nw != rp
he != rp
he != by
he != th
th != sn
th != by
sn != by
rp != sl
rp != bw
rp != by
sl != bw
bw != by''',
    ),
    (
      // Triples of strictly-increasing positive integers summing
      // to 20: a < b < c, a+b+c=20, with a,b,c in 1..20.
      id: 'orderedTriples',
      program: '''vars: a, b, c in 1..20
a + b + c == 20
a < b
b < c''',
    ),
    (
      // Set partitioning / equal-sum split. Given the multiset
      // {4, 3, 2, 3, 2, 2} (total 16), split it into two groups
      // of equal sum (8 each). One 0/1 indicator per number
      // selects it into group A; the linear constraint forces
      // group A's weighted sum to half the total. The unselected
      // numbers form group B, whose sum is then also 8. A 1 in
      // the solution means "this number goes in group A".
      id: 'equalSumSplit',
      program: '''vars: b1, b2, b3, b4, b5, b6 in 0..1
4*b1 + 3*b2 + 2*b3 + 3*b4 + 2*b5 + 2*b6 == 8''',
    ),
    (
      // Round 74: textbook coin-change. Pay 17 cents with the
      // fewest coins drawn from {1, 5, 10, 25}. The minimize
      // directive returns the unique optimum (one 10 + one 5 +
      // two 1s = four coins) plus the objective value.
      id: 'coinChangeMin',
      program: '''vars: pennies in 0..17
vars: nickels in 0..3
vars: dimes in 0..1
vars: quarters in 0..0
pennies + 5*nickels + 10*dimes + 25*quarters == 17
minimize pennies + nickels + dimes + quarters''',
    ),
    (
      // 0/1 knapsack: four items with weights {2,3,4,5} and values
      // {3,4,5,6}, knapsack capacity 5. One 0/1 indicator per item;
      // the linear constraint caps total weight, and `maximize`
      // (branch-and-bound) returns the optimal-value subset. Optimum:
      // items 1+2 (weight 5, value 7).
      id: 'knapsack',
      program: '''vars: x1, x2, x3, x4 in 0..1
2*x1 + 3*x2 + 4*x3 + 5*x4 <= 5
maximize 3*x1 + 4*x2 + 5*x3 + 6*x4''',
    ),
    (
      // Linear production planning: make `a` units of product A and
      // `b` of product B to maximize profit (3 per A, 5 per B) subject
      // to two shared resources — machine hours (2·A + B ≤ 10) and
      // labour (A + 3·B ≤ 15). Integer branch-and-bound. Optimum:
      // a=3, b=4 → profit 29 (both resources fully consumed).
      id: 'productionPlanning',
      program: '''vars: a, b in 0..10
2*a + b <= 10
a + 3*b <= 15
maximize 3*a + 5*b''',
    ),
    (
      // Assignment problem: assign 3 workers to 3 tasks at minimum
      // total cost. x_ij = 1 iff worker i does task j. Each worker
      // takes exactly one task (row sums = 1) and each task is taken
      // by exactly one worker (column sums = 1). The objective sums
      // the chosen cells of the cost matrix
      //   [[9,2,7],[6,4,3],[5,8,1]].
      // Optimum cost 9: w1→t2 (2), w2→t1 (6), w3→t3 (1).
      id: 'assignmentMinCost',
      program: '''vars: x11, x12, x13, x21, x22, x23, x31, x32, x33 in 0..1
x11 + x12 + x13 == 1
x21 + x22 + x23 == 1
x31 + x32 + x33 == 1
x11 + x21 + x31 == 1
x12 + x22 + x32 == 1
x13 + x23 + x33 == 1
minimize 9*x11 + 2*x12 + 7*x13 + 6*x21 + 4*x22 + 3*x23 + 5*x31 + 8*x32 + 1*x33''',
    ),
    (
      // Balanced transportation problem (min-cost distribution).
      // Two warehouses with supplies S1=4, S2=6 ship to three
      // customers with demands D1=3, D2=3, D3=4. Supply == demand,
      // so every warehouse row and customer column is an equality.
      // x_ij is the integer number of units shipped from warehouse i
      // to customer j; the unit-cost matrix is
      //   [[4, 6, 8], [9, 5, 3]].
      // Branch-and-bound returns the unique min-cost plan, total 40:
      //   x11=3, x12=1, x22=2, x23=4 (every other route unused).
      id: 'transportation',
      program: '''vars: x11, x12, x13, x21, x22, x23 in 0..6
x11 + x12 + x13 == 4
x21 + x22 + x23 == 6
x11 + x21 == 3
x12 + x22 == 3
x13 + x23 == 4
minimize 4*x11 + 6*x12 + 8*x13 + 9*x21 + 5*x22 + 3*x23''',
    ),
    (
      // Round 77: single-machine scheduling with minimum makespan.
      // Three tasks of durations 4, 3, 2 must run without overlap;
      // the `noOverlap` overlay enforces pairwise disjointness on
      // the half-open intervals [start, start+duration). The
      // makespan variable bounds each task's end and is what we
      // minimize. Optimal makespan = 4+3+2 = 9; in this instance
      // the solver returns one of the equally-good orderings.
      id: 'schedulingMakespan',
      program: '''vars: s1, s2, s3 in 0..9
vars: makespan in 0..9
noOverlap(s1=4, s2=3, s3=2)
s1 + 4 <= makespan
s2 + 3 <= makespan
s3 + 2 <= makespan
minimize makespan''',
    ),
    (
      // Round 80: parallel-resource scheduling. Three tasks share a
      // renewable resource of capacity 2: task s1 alone consumes the
      // whole resource (demand 2, duration 2), while s2 and s3 each
      // demand 1 and so can run in parallel with each other. Total
      // work = 2·2 + 3·1 + 4·1 = 11; with capacity 2 the makespan
      // lower bound is ⌈11/2⌉ = 6. Achieved e.g. by running s2 + s3
      // parallel from t=0..3, s3 alone t=3..4, then s1 from t=4..6.
      id: 'cumulativeScheduling',
      program: '''vars: s1, s2, s3 in 0..6
vars: makespan in 0..6
cumulative(s1=2@2, s2=3@1, s3=4@1; capacity=2)
s1 + 2 <= makespan
s2 + 3 <= makespan
s3 + 4 <= makespan
minimize makespan''',
    ),
    (
      // Round 84: multi-resource project scheduling (RCPSP — the
      // classical resource-constrained project scheduling
      // problem). Four tasks share two renewable resources, each
      // of capacity 3 — interpret as a crew of 3 and an
      // equipment pool of 3.
      //
      //   Task | dur | crew | equip
      //     s1 |  3  |   2  |   1
      //     s2 |  4  |   1  |   2
      //     s3 |  2  |   2  |   2
      //     s4 |  3  |   1  |   1
      //
      // s2 + s3 together demand equip = 4 > 3 capacity, so they
      // cannot overlap on equipment — that constraint is the
      // binding resource. Lower bound on makespan is
      // max(⌈17/3⌉, ⌈18/3⌉, dur(s2)+dur(s3)) = 6. Achieved by
      // s1=0, s2=0, s3=4, s4=3 → makespan 6.
      id: 'rcpsp',
      program: '''vars: s1, s2, s3, s4 in 0..6
vars: makespan in 0..6
cumulative(s1=3@2, s2=4@1, s3=2@2, s4=3@1; capacity=3)
cumulative(s1=3@1, s2=4@2, s3=2@2, s4=3@1; capacity=3)
s1 + 3 <= makespan
s2 + 4 <= makespan
s3 + 2 <= makespan
s4 + 3 <= makespan
minimize makespan''',
    ),
    (
      // Round 108: logic-grid deduction. `implies` and `exactly` over
      // `name=value` conditions are the vocabulary logic-grid riddles
      // ("Einstein"/"zebra" puzzles) are built from. Ann, Bob and Cy
      // each pick a different pet; two clues prune the permutations.
      id: 'logicGrid',
      program: '''# Ann, Bob, Cy each pick a different pet.
# 1 = cat, 2 = dog, 3 = fish.
vars: ann, bob, cy in 1..3
allDifferent(ann, bob, cy)
ann != 3
implies(bob=1, cy=2)
exactly(1, ann=1, bob=1)''',
    ),
    (
      // Round 108: nurse rostering. `atMostInARow` compiles to a small
      // regular-language (DFA) automaton — the natural way to express
      // "no more than k of a shift back-to-back"; `gcc` pins the exact
      // number of days off across the week.
      id: 'nurseRostering',
      program: '''# One nurse's 5-day plan. 0 = off, 1 = day, 2 = night.
vars: d1, d2, d3, d4, d5 in 0..2
atMostInARow(d1, d2, d3, d4, d5; value=1; max=2)
atMostInARow(d1, d2, d3, d4, d5; value=2; max=1)
gcc(d1, d2, d3, d4, d5; 0=2)''',
    ),
    (
      // Round 108: chromatic number. `nvalue` counts the distinct
      // values (colours); minimizing it finds the fewest colours a
      // graph needs. An odd cycle (here a 5-cycle) needs 3.
      id: 'chromaticNumber',
      program: '''# Fewest colours for a 5-cycle (odd cycle => 3).
vars: a, b, c, d, e in 1..5
vars: colors in 1..5
a != b
b != c
c != d
d != e
e != a
nvalue(a, b, c, d, e; count=colors)
minimize colors''',
    ),
    (
      // Round 108: the `table` constraint — restrict a tuple to an
      // explicit set of allowed rows (a compatibility matrix). Here a
      // café only offers certain (main, side) pairings; enumerating the
      // program lists exactly the menu.
      id: 'menuPairing',
      program: '''# Café menu — only these (main, side) pairings are offered.
# main: 1 soup / 2 salad / 3 pasta   side: 1 bread / 2 fries / 3 fruit
vars: main, side in 1..3
table(main, side; (1,1), (1,3), (2,2), (2,3), (3,1), (3,2))''',
    ),
    (
      // Round 108 (C8): 2D packing with `diffN`. Three differently
      // shaped tiles are placed without overlap inside a 4×4 box; the
      // result renders as a scaled floor-plan layout. Each tuple is
      // (xVar, yVar, width, height) with the lower-left at (x, y).
      id: 'packing',
      program: '''# Pack three tiles into a 4×4 box — no overlaps.
# Each tuple is (xVar, yVar, width, height).
vars: ax, ay, bx, by, cx, cy in 0..2
diffN((ax,ay,2,2), (bx,by,2,1), (cx,cy,1,2))''',
    ),
    (
      // Round 109 (C8): a single tour over successor variables with the
      // `circuit` constraint — a TSP / delivery-routing skeleton. Each
      // variable is the index of the stop visited next; enumerating the
      // program lists every Hamiltonian tour, drawn as a directed
      // node-graph in the DSL tab.
      id: 'deliveryRoute',
      program: '''# Delivery route — visit all four stops once, back to depot.
# next[i] = index of the stop visited after stop i (0=depot … 3=park).
vars: depot, shop, bank, park in 0..3
circuit(depot, shop, bank, park; labels=Depot, Shop, Bank, Park)''',
    ),
    (
      // Round 110 (C8): over-constrained scheduling with soft
      // preferences. The hard constraint forces two shifts apart; three
      // weighted preferences pull in conflicting directions, so the
      // MaxCSP solver keeps the heaviest satisfiable set.
      id: 'shiftPrefs',
      program: '''# Two people, three time slots (0,1,2). They must differ.
# Weighted preferences — the solver keeps the best satisfiable set.
vars: alex, bo in 0..2
alex != bo
soft(3): alex = 0     # Alex strongly prefers the early slot
soft(2): bo = 0       # Bo also wants it (they can't both have it)
soft(1): alex = bo    # a nice-to-have that the hard rule forbids''',
    ),
    (
      // Round 111 (C8): set-variable committee selection. Pick a 3-member
      // committee and a disjoint 2-member reserve bench from a pool of 5,
      // with one member pinned. Solutions render as chip clusters.
      id: 'committee',
      program: '''# Pick a committee + a disjoint reserve bench from 5 people.
# Universe 1..5 = the five candidates; member 1 must be on the committee.
set Committee, Bench from 1..5
card(Committee) = 3
card(Bench) = 2
disjoint(Committee, Bench)
Committee contains 1''',
    ),
  ];

  final _ctl = TextEditingController(text: _gallery.first.program);
  DiophantineResult? _result;
  bool _solving = false;
  CspMusResult? _mus;
  bool _explaining = false;
  // Round E.3: FlatZinc export state. Cleared on every fresh
  // solve / example load so a stale translation can't linger
  // after the user has edited the program.
  FlatZincExportResult? _export;
  // Round F: propagation step-trace for the visualizer. Cleared on
  // every fresh solve / example load / export so a stale replay can't
  // linger after the program changed.
  CspTraceResult? _trace;
  bool _tracing = false;
  // Round 113 (C9): constraint-network structure graph. Computed
  // synchronously from the program text; cleared on every fresh
  // solve / example load / export so it can't outlive its program.
  DslStructure? _structure;
  // Round 118 (C9): non-null while an off-thread solve is in flight;
  // calling it kills the worker isolate.
  void Function()? _cancelSolve;

  @override
  void initState() {
    super.initState();
    // Round 73: if the user got here via a `dsl:<id>` worked-
    // example sentinel, AppState carries the pending gallery id.
    // Drain it and load the matching program.
    final pendingId = AppState().consumePendingDslProgramId();
    if (pendingId != null) {
      for (final entry in _gallery) {
        if (entry.id == pendingId) {
          _ctl.text = entry.program;
          break;
        }
      }
    }
  }

  void _loadExample(String programText) {
    setState(() {
      _ctl.text = programText;
      _result = null;
      _mus = null;
      _export = null;
      _trace = null;
      _structure = null;
    });
  }

  void _doExport() {
    setState(() {
      _export = DslToFlatZinc.export(_ctl.text);
      _trace = null;
      _structure = null;
    });
  }

  // Round 113 (C9): compute + reveal the constraint-network graph. A
  // synchronous structural parse — no solving — so no spinner needed.
  void _showStructure() {
    setState(() {
      _structure = CspSolver.analyzeDslStructure(_ctl.text);
      _export = null;
      _trace = null;
    });
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  Future<void> _solve({bool compareStrategies = false}) async {
    setState(() {
      _solving = true;
      _mus = null;
      _export = null;
      _trace = null;
      _structure = null;
    });
    // Round 118 (C9): solve on a worker isolate so a heavy program never
    // freezes the UI; the handle's `cancel` kills the worker outright.
    final handle = CspSolver.solveDslInBackground(_ctl.text,
        maxSolutions: 100, compareStrategies: compareStrategies);
    _cancelSolve = handle.cancel;
    final r = await handle.result;
    if (!mounted) return;
    setState(() {
      _solving = false;
      _cancelSolve = null;
      // A null result means the solve was cancelled — leave the previous
      // result (if any) untouched rather than blanking the panel.
      if (r != null) _result = r;
    });
  }

  void _cancel() {
    _cancelSolve?.call();
    _cancelSolve = null;
  }

  // Round F: build a propagation step-trace and reveal the AC-3
  // replay visualizer. Independent of the Solve result block — the
  // user can visualize without first solving.
  Future<void> _visualize() async {
    setState(() {
      _tracing = true;
      _export = null;
    });
    final r = await CspSolver.traceDsl(_ctl.text);
    if (!mounted) return;
    setState(() {
      _tracing = false;
      _trace = r;
    });
  }

  Future<void> _explain() async {
    setState(() => _explaining = true);
    final r = await CspSolver.explainDsl(_ctl.text);
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
          Text(t.constraintsDslIntro,
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          TextField(
            controller: _ctl,
            minLines: 6,
            maxLines: 16,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            decoration: InputDecoration(
              labelText: t.constraintsDslInputLabel,
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
              // Round 118 (C9): cancel an in-flight off-thread solve.
              if (_solving && _cancelSolve != null)
                OutlinedButton.icon(
                  onPressed: _cancel,
                  icon: const Icon(Icons.close, size: 18),
                  label: Text(t.constraintsCancelButton),
                ),
              // Round 72: pre-built example programs. Selecting a
              // menu item replaces the TextField with that program.
              PopupMenuButton<String>(
                tooltip: t.constraintsDslExamplesTooltip,
                onSelected: _loadExample,
                itemBuilder: (context) => [
                  for (final entry in _gallery)
                    PopupMenuItem<String>(
                      value: entry.program,
                      child: Text(t.constraintsDslExampleTitle(entry.id)),
                    ),
                ],
                child: OutlinedButton.icon(
                  // The PopupMenuButton's child handles taps; the
                  // button's own onPressed is intentionally null.
                  onPressed: null,
                  icon: const Icon(Icons.menu_book_outlined, size: 18),
                  label: Text(t.constraintsDslExamplesButton),
                ),
              ),
              // Round E.3: emit a FlatZinc translation of the
              // currently-typed program. Sits next to Examples so
              // the cluster of "what to do with this DSL"
              // affordances stays in one place.
              OutlinedButton.icon(
                onPressed: _doExport,
                icon: const Icon(Icons.code, size: 18),
                label: Text(t.constraintsExportFlatZinc),
              ),
              // Round F: AC-3 propagation step-trace visualizer.
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
              // Round 112 (C8): run the same program under several
              // search heuristics and show a solver-stats comparison.
              OutlinedButton.icon(
                onPressed:
                    _solving ? null : () => _solve(compareStrategies: true),
                icon: const Icon(Icons.speed_outlined, size: 18),
                label: Text(t.constraintsCompareStrategies),
              ),
              // Round 113 (C9): draw the constraint-network graph.
              OutlinedButton.icon(
                onPressed: _showStructure,
                icon: const Icon(Icons.hub_outlined, size: 18),
                label: Text(t.constraintsStructureButton),
              ),
            ],
          ),
          // Round 105b (P6): in help mode, reveal a reference row of
          // the DSL operators. The DSL operators have no standing UI
          // (they live in the program text), so this row IS their
          // per-element help surface — each chip opens the Function
          // Reference popover for that operator.
          const _DslOperatorHelpRow(),
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
          if (_export != null) ...[
            const SizedBox(height: 16),
            _FlatZincExportBlock(result: _export!),
          ],
          if (_trace != null) ...[
            const SizedBox(height: 16),
            if (_trace!.ok)
              PropagationVisualizer(trace: _trace!)
            else
              _TraceErrorBlock(message: _trace!.error!),
          ],
          if (_structure != null) ...[
            const SizedBox(height: 16),
            if (_structure!.ok)
              _ConstraintGraph(structure: _structure!)
            else
              _TraceErrorBlock(message: _structure!.error!),
          ],
        ],
      ),
    );
  }
}

/// Round F: friendly error surface when a program can't be traced
/// (parse error, no variables, etc.). Mirrors the export error block.
class _TraceErrorBlock extends StatelessWidget {
  final String message;
  const _TraceErrorBlock({required this.message});

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
            child:
                Text(message, style: TextStyle(color: scheme.onErrorContainer)),
          ),
        ],
      ),
    );
  }
}

/// Round 105b (P6): operator reference + help row for the DSL tab.
/// Hidden outside help mode (the tab's normal UX is unchanged); in
/// help mode it shows one chip per mini-DSL operator, each opening
/// that operator's Function Reference popover. This is the DSL's
/// per-element help surface, since the operators otherwise live only
/// inside the free-form program text.
/// (chip label, FunctionRef id) for every mini-DSL operator surfaced as
/// a help-mode chip. Public so a test can assert the row is exhaustive
/// (every operator present) and each refId resolves to a catalogue
/// entry. Keep in sync with the keywords `CspSolver.solveDsl` accepts.
const dslOperatorHelpChips = <(String, String)>[
  ('vars:', 'vars'),
  ('allDifferent', 'all_different'),
  ('noOverlap', 'no_overlap'),
  ('cumulative', 'cumulative'),
  // Round 108 globals.
  ('atLeast', 'at_least'),
  ('atMost', 'at_most'),
  ('exactly', 'exactly'),
  ('implies', 'implies'),
  ('gcc', 'gcc'),
  ('among', 'among'),
  ('nvalue', 'nvalue'),
  ('atMostInARow', 'at_most_in_a_row'),
  ('valuePrecedence', 'value_precedence'),
  ('table', 'table'),
  ('element', 'element'),
  ('diffN', 'diff_n'),
  ('circuit', 'circuit'),
  ('soft', 'soft'),
  ('set', 'set_var'),
  ('card', 'set_var'),
  ('subset', 'set_var'),
  ('disjoint', 'set_var'),
  ('minimize', 'minimize'),
  ('maximize', 'maximize'),
];

class _DslOperatorHelpRow extends StatelessWidget {
  const _DslOperatorHelpRow();

  static const _operators = dslOperatorHelpChips;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState(),
      builder: (context, _) {
        if (!AppState().helpMode) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              for (final (label, refId) in _operators)
                HelpTarget(
                  onHelpTap: () => showFunctionRefHelpPopover(context, refId),
                  child: ActionChip(
                    label: Text(
                      label,
                      style: const TextStyle(
                          fontFamily: 'monospace', fontSize: 12),
                    ),
                    onPressed: () => showFunctionRefHelpPopover(context, refId),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Renders a [FlatZincExportResult]: either a copyable monospace
/// block with the translated FlatZinc text, or a friendly error
/// when the DSL didn't translate cleanly. Round E.3.
class _FlatZincExportBlock extends StatelessWidget {
  final FlatZincExportResult result;
  const _FlatZincExportBlock({required this.result});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    if (!result.ok) {
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
              child: Text(result.error!,
                  style: TextStyle(color: scheme.onErrorContainer)),
            ),
          ],
        ),
      );
    }
    final src = result.source!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(t.constraintsExportedHeader,
                style: Theme.of(context).textTheme.titleSmall),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.copy, size: 18),
              tooltip: t.constraintsCopyResult,
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: src));
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
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(6),
          ),
          child: SelectableText(
            src,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
      ],
    );
  }
}

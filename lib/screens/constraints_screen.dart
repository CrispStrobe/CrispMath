// lib/screens/constraints_screen.dart
//
// Analysis-hub module for Constraint Satisfaction Problems. Four tabs:
//
//   1. Diophantine — enumerate integer solutions to a system of
//      bounded linear/inequality constraints. The variable list
//      drives a Map<String, (min, max)> and the constraints list is
//      passed through CspSolver.solveDiophantine.
//
//   2. Cryptarithm — solve `WORD1 + WORD2 = WORD3` puzzles via
//      CspSolver.solveCryptarithm.
//
//   3. Free-form DSL — the round-72 mini-DSL with `allDifferent`,
//      arithmetic comparators, `minimize` / `maximize`, `noOverlap`,
//      `cumulative` directives.
//
//   4. FlatZinc — paste a `.fzn` source string (typically produced
//      by `mzn2fzn` from a MiniZinc model) and call dart_csp's
//      FlatZinc frontend directly. Output is the standard FlatZinc
//      output format. Round E.1.
//
// Each tab shows the result in a copyable read-only block. Long-
// running solves are not yet routed through the persistent worker —
// typical CSP problems at this scale finish in milliseconds.

import 'dart:math';

import 'package:dart_csp/dart_csp.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../engine/app_state.dart';
import '../engine/csp_solver.dart';
import '../engine/magic_square.dart';
import '../localization/app_localizations.dart';
import '../widgets/australia_map_painter.dart';
import '../widgets/germany_map_painter.dart';
import '../widgets/propagation_visualizer.dart';
import '../widgets/function_ref_help_popover.dart';
import '../widgets/help_target.dart';
import '../widgets/module_help_dialog.dart';

part 'constraints/magic_square_tab.dart';
part 'constraints/diophantine_tab.dart';
part 'constraints/result_views.dart';
part 'constraints/cryptarithm_tab.dart';
part 'constraints/dsl_tab.dart';
part 'constraints/cryptarithm_result.dart';
part 'constraints/flatzinc_tab.dart';
part 'constraints/explain.dart';

class ConstraintsScreen extends StatefulWidget {
  const ConstraintsScreen({super.key});

  @override
  State<ConstraintsScreen> createState() => _ConstraintsScreenState();
}

class _ConstraintsScreenState extends State<ConstraintsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 5, vsync: this);
    // Round 73: if a DSL worked-example was tapped, the AppState
    // slot will be populated. Jump directly to the Free-form tab
    // so the user lands on the editor (the _DslTab itself drains
    // the slot + sets the program text in its own initState).
    if (AppState().pendingDslProgramId != null) {
      _tabs.index = 2;
    }
    // A pending cryptarithm puzzle lands the user on the Cryptarithm
    // tab (index 1), which drains the slot + fills the field in its
    // own initState. Peeked (not consumed) here so the tab still sees
    // it.
    if (AppState().pendingCryptarithmPuzzle != null) {
      _tabs.index = 1;
    }
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.moduleConstraintsTitle),
        actions: const [ModuleHelpButton(kind: ModuleHelpKind.constraints)],
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          tabs: [
            Tab(text: t.constraintsTabDiophantine),
            Tab(text: t.constraintsTabCryptarithm),
            Tab(text: t.constraintsTabDsl),
            Tab(text: t.constraintsTabFlatZinc),
            Tab(text: t.constraintsTabMagicSquare),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: const [
          _DiophantineTab(),
          _CryptarithmTab(),
          _DslTab(),
          _FlatZincTab(),
          _MagicSquareTab(),
        ],
      ),
    );
  }
}

// === Magic-square generator tab ========================================

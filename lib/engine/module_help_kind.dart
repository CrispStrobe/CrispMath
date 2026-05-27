// lib/engine/module_help_kind.dart
//
// Round 105 (P6): pure enum identifying each Analyze-hub module
// for help-dialog dispatch. Lives in `engine/` so both
// `app_localizations.dart` and `widgets/module_help_dialog.dart`
// can depend on it without forming a cycle.

enum ModuleHelpKind {
  curveSketching,
  planes,
  conicSections,
  statistics,
  graphing3D,
  scene3D,
  constraints,
  sudoku,
}

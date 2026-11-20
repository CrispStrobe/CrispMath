// lib/localization/app_localizations.dart
//
// Centralized i18n. Each locale lives in its own part file under
// locales/. Add a new locale by implementing AppLocalizations there and
// wiring it into the delegate at the bottom. Strings are grouped by feature
// so it's easy to spot what's missing when adding a language.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../engine/module_help_kind.dart';
import '../engine/step_engine.dart' show StepNote;
import '../engine/sudoku.dart' show SudokuError, SudokuErrorKind;
import 'worked_example_translations.dart';

export '../engine/module_help_kind.dart' show ModuleHelpKind;

part 'locales/en.dart';
part 'locales/de.dart';
part 'locales/fr.dart';
part 'locales/es.dart';

abstract class AppLocalizations {
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        const EnLocalizations();
  }

  // -- Nav destinations --
  String get navCalculator;
  String get navNotepad;
  String get navGraphing;
  String get navFunctions;
  String get navAnalysis;
  String get navSettings;

  // -- Notepad screen --
  String get notepadDefaultDocName;
  String get notepadAddLine;
  String get notepadDeleteLine;
  String get notepadDocumentMenu;
  String get notepadNewDocument;
  String get notepadOpenWelcomeSample;
  String get notepadRecalculateAll;
  String get notepadRename;
  String get notepadDuplicate;
  String get notepadCopyAsMarkdown;
  String get notepadDeleteDocument;
  String get notepadUndo;
  String get notepadLineDeleted;
  String get menuAboutApp;
  String get menuSettingsEllipsis;
  String get menuFile;
  String get menuView;
  String get menuTools;
  String get menuHelp;
  String get menuCommandPalette;
  String get menuWorkspaceBackups;
  String get menuSync;
  /// Calculator history status for `x = 2`; [what] is e.g. `x = 2` or `Y1`.
  String historyStored(String what);
  /// Calculator history status for `f(x) = …`; [what] is e.g. `f(x)`.
  String historyDefined(String what);
  String notepadDocumentDeleted(String name);
  String get notepadCopiedAsMarkdown;
  String get notepadCopyResult;
  String get notepadCopyAsLatex;
  String get notepadCopiedResult;
  String get notepadCopiedAsLatex;
  String get notepadEmptyTitle;
  String get notepadEmptyBody;
  String notepadFreeVars(String names);
  String notepadBlockedBy(String alias);
  String notepadCycle(String path);
  String notepadUnknownImport(String name);
  String notepadInvalidImport(String name);
  String get notepadEmptyImportList;
  String notepadUseDirective(String code);
  String get notepadManageTitle;
  String get notepadManageNotepads;
  String get notepadOpenDocument;
  String get notepadExportAsJson;
  String get notepadOpenFile;
  String get notepadSaveFile;
  String get notepadFileSaved;
  String get notepadFileOpenFailed;
  String get notepadFileSaveFailed;

  String get notepadImportFromJson;
  String get notepadImport;
  String get notepadImportJsonHint;
  String get notepadJsonCopied;
  String notepadJsonImported(String name);
  String get notepadJsonImportFailed;

  // -- Calculator screen --
  String get historyHere;
  String get historyLabel;
  String get clearButton;
  String get clearHistory;
  String get clearHistoryConfirm;
  String get searchHistory;
  String get searchHistoryHint;
  String get historyNoMatches;

  // -- Graphing screen --
  String get graphErrorEmpty;
  String get graphErrorUnbalanced;
  String get graphErrorTrailingOperator;
  String get graphSampling;
  String get graphSamplingFailed;
  String get graphNoRealValues;
  String get graphRetry;
  String graphingTitle(int count);
  String functionAdded(int slot);
  String functionRemoved(int slot);
  String functionUpdated(int slot);
  String functionEditing(int slot);
  String get functionActions;
  String get functionEdit;
  String get functionRemove;
  String get allSlotsFull;
  String get clearAllFunctions;
  String get clearAllFunctionsConfirm;
  String get cancel;
  String get clearAll;
  String get zoomIn;
  String get zoomOut;
  String get resetView;
  String get showKeypad;
  String get hideKeypad;
  String get showAnnotations;
  String get hideAnnotations;
  String get analyzeFunctions;
  String get selectFunctionToAnalyze;
  String get plotButton;
  String get enterFunctionPrompt;

  // -- Analysis hub --
  String get analysisModulesTitle;
  String get moduleCurveSketching;
  String get moduleCurveSketchingSubtitle;
  String get modulePlanes;
  String get modulePlanesSubtitle;
  String get moduleConics;
  String get moduleConicsSubtitle;
  String get moduleStatistics;
  String get moduleStatisticsSubtitle;
  String get module3DTitle;
  String get module3DSubtitle;
  String get module3DFunctionLabel;
  String get module3DRangeLabel;
  String get module3DResample;
  String get module3DTapPlot;

  // -- P9-A2: 3D Scene module --
  String get module3DScene;
  String get module3DSceneSubtitle;
  String get scene3DAddPlane;
  String get scene3DEditPlane;
  String get scene3DEmpty;
  String get scene3DPanelEmpty;
  String get scene3DObjectLabel;
  String get scene3DColor;
  String get scene3DAdd;
  String get scene3DSave;
  String get scene3DEdit;
  String get scene3DDelete;
  String get scene3DHide;
  String get scene3DShow;
  String get scene3DLabelRequired;
  String get scene3DCoefRequired;
  String get scene3DCoefInvalid;
  String get scene3DPlaneZeroNormal;

  // -- P9-A3: lines + spheres --
  String get scene3DAddObject;
  String get scene3DAddLine;
  String get scene3DEditLine;
  String get scene3DAddSphere;
  String get scene3DEditSphere;
  String get scene3DLinePointDir;
  String get scene3DLineTwoPoints;
  String get scene3DLinePoint;
  String get scene3DLineDirection;
  String get scene3DLineFirstPoint;
  String get scene3DLineSecondPoint;
  String get scene3DLineZeroDirection;
  String get scene3DSphereCenter;
  String get scene3DSphereRadius;
  String get scene3DSpherePositiveRadius;

  // -- P9-A4: intersections panel --
  String get scene3DIntersectionsEmpty;
  String scene3DIntersectionsTitle(int n);
  String get intersectionPoint;
  String get intersectionTwoPoints;
  String get intersectionLine;
  String get intersectionCircle;
  String intersectionReason(String key);

  // -- P9-A5: quadrics --
  String get scene3DAddQuadric;
  String get scene3DEditQuadric;
  String get scene3DQuadricKind;
  String get scene3DQuadricSemiAxes;
  String get scene3DQuadricPositiveSemiAxes;
  String get quadricKindEllipsoid;
  String get quadricKindCone;
  String get quadricKindCylinder;
  String get quadricKindParaboloid;
  String get quadricKindHyperboloid1;
  String get quadricKindHyperboloid2;

  // -- P9-A5c.3: Conic Section → 3D Scene bridge --
  String get conicOpenIn3DScene;
  String get conicLiftNotAConic;

  // -- P9-A6: parametric surfaces + curves --
  String get scene3DAddParametricSurface;
  String get scene3DEditParametricSurface;
  String get scene3DAddParametricCurve;
  String get scene3DEditParametricCurve;
  String get scene3DParametricSurface;
  String get scene3DParametricCurve;

  String get moduleUnitConverterTitle;
  String get moduleUnitConverterSubtitle;
  // -- Variable / function panel --
  String get sectionVariables;
  String get sectionGraphFunctions;
  String get sectionMemorySlots;
  // -- Function context menu (long-press / right-click on a function tile) --
  String get funcCtxShowOnGraph;
  String get funcCtxAnalyze;
  String get funcCtxDifferentiate;
  String get funcCtxIntegrate;
  String get funcCtxSolve;
  String get funcCtxCopy;
  // -- Function editor --
  String get funcEditorTitle;
  String get funcEditorDone;
  String get funcEditorSelectFirst;
  String get funcEditorAnalyzeTooltip;
  String get funcEditorGraphTooltip;
  // -- Unit dimension labels (used in the Unit Converter dialog) --
  String get unitDimLength;
  String get unitDimTime;
  String get unitDimMass;
  String get unitDimTemperature;
  String get unitDimVelocity;
  String get unitDimAngle;
  // -- Plane analysis --
  String get planeAnalysisTitle;
  String get planeRepCoordinate;
  String get planeRepParametric;
  // -- Generic action buttons --
  String get buttonAnalyze;
  String get buttonClassify;
  // -- Curve analysis input + results --
  String get curveAnalysisEnterFunction;
  String get curveResultWarnings;
  String get curveResultDerivatives;
  String get curveResultKeyPoints;
  String get curveResultYIntercept;
  String get curveResultRoots;
  String get curveResultExtrema;
  String get curveResultInflectionPoints;
  String get curveResultNoExtrema;
  String get curveResultNoInflection;
  String curveAnalysisOfFunction(String function);
  String curveResultPointPrefix(String point);
  // -- Classifications from the analysis engine (rendered via the
  //    `translateClassification` helper below) --
  String get extremumLocalMinimum;
  String get extremumLocalMaximum;
  String get extremumCriticalPoint;
  String get extremumInflectionPoint;
  String get extremumNoCriticalPoints;
  String get extremumConstantConcavity;
  // -- Statistics screen --
  String get statisticsTitle;
  String get statsTabDescriptive;
  String get statsTabRegression;
  String get statsTabDistributions;
  String get statsTabTests;
  String get statsDescCount;
  String get statsDescSum;
  String get statsDescMean;
  String get statsDescMedian;
  String get statsDescMode;
  String get statsDescMin;
  String get statsDescMax;
  String get statsDescRange;
  String get statsDescVariance;
  String get statsDescStddev;
  String get statsDescQ1;
  String get statsDescQ3;
  String get statsDescIqr;
  // -- Help screen pieces --
  String get helpGroupProbability;
  String get helpFnRrefDescription;

  // -- Settings --
  String get settingsTitle;
  String get settingsNumberFormat;
  String get settingsNumberFormatAuto;
  String get settingsNumberFormatInteger;
  String get settingsNumberFormatOneDecimal;
  String get settingsNumberFormatTwoDecimal;
  String settingsNumberFormatDecimalPlaces(int n);
  String get settingsAutoBindSolve;
  String get settingsAutoBindSolveSubtitle;
  String get settingsLanguage;
  String get settingsLanguageEnglish;
  String get settingsLanguageGerman;
  String get settingsLanguageFrench;
  String get settingsLanguageSpanish;
  String get settingsTheme;
  String get settingsThemeSystem;
  String get settingsThemeLight;
  String get settingsThemeDark;
  String get settingsLayoutTitle;
  String get settingsLayoutBody;

  // -- About screen --
  String get aboutTitle;
  String get aboutTagline;
  String aboutVersion(String version);
  String get aboutServiceProvider;
  String get aboutContact;
  String get aboutPrivacy;
  String get aboutPrivacyText;
  String get aboutDisclaimer;
  String get aboutDisclaimerText;
  String get aboutLicense;
  String get aboutLicenseText;
  String get aboutOpenSourceLicenses;
  String get settingsAbout;
  String get matrixDiagnosticsTitle;
  String get matrixDiagnosticsSubtitle;
  String matrixDiagnosticsSummary(int passed, int total);
  String get unitConverterTitle;
  String get unitConverterSubtitle;

  // -- Picker dialogs --
  String get selectEquation;
  String get continueTyping;
  String get selectFunction;
  String get dismissPanel;
  String solveFor(int n);
  String whereY(int n, String func);

  // -- Shared dialog actions / labels --
  String get dialogInsert;
  String get dialogClose;
  String get dialogShowSteps;
  String get dialogVariable;
  String get dialogExpression;
  String get dialogValue;
  String get dialogFunction;

  // -- Integral / NthRoot / Limit / Substitute dialogs --
  String get integralTitle;
  String get integralLowerBound;
  String get integralUpperBound;
  String get integralDefinite;
  String get nthRootTitle;
  String get nthRootBase;
  String get limitTitle;
  String get limitApproaches;
  String get substituteTitle;
  String get substituteUseStoredVariable;

  // -- Step-by-step dialogs (entry-prompt + headlines) --
  String get differentiationStepsTitle;
  String differentiationStepsHeader(String variable);
  String get solveStepsTitle;
  String get odeStepsTitle;
  String get solveStepsEquationLabel;
  String get solveStepsSolveFor;
  String get solveStepsHint;
  String solveStepsHeader(String variable);
  String get integrationStepsTitle;
  String get integrationStepsIntegrandLabel;
  String get integrationStepsWrt;
  String get integrationStepsHint;
  String integrationStepsHeader(String variable);

  // -- Calculator errors --
  String get errorSolveFormat;
  String get errorInvalidSolve;
  String get errorInvalidDiff;
  String get errorInvalidFactor;
  String get errorInvalidExpand;
  String get errorInvalidSimplify;
  String get errorGcdArgs;
  String get errorInvalidGcd;
  String get errorLcmArgs;
  String get errorInvalidLcm;

  // -- Friendly errors (shown in history when an op fails) --
  String get errorMissingAns;
  String get errorParse;

  /// A closing bracket with nothing open — `2+3)`.
  String get errorUnbalancedParen;

  /// Division by an exact zero.
  String get errorDivisionByZero;

  /// [name] isn't a function this build knows.
  String errorUnknownFunction(String name);

  /// [name] was called with the wrong number of arguments.
  String errorWrongArity(String name);

  String get errorNativeRequired;

  /// Web-specific variant of [errorNativeRequired]: the browser build
  /// has no native CAS, so point the user at the desktop/mobile app.
  String get errorNativeRequiredWeb;

  /// Banner shown on the web build while the SymEngine WASM module is
  /// still loading — full CAS will light up once it finishes.
  String get webBannerCasLoading;

  /// Banner shown on the web build once the WASM CAS is live: symbolic math
  /// works in the browser, but the GMP/MPFR/FLINT-only functions still need
  /// the native app.
  String get webBannerCasPartial;

  /// Banner shown on the web build when the WASM module failed to load:
  /// symbolic features need the native app.
  String get webBannerCasUnavailable;

  /// Short CTA label linking to the downloadable desktop/mobile apps.
  String get webDownloadApp;

  String get errorIntegrateNotImplemented;
  String get errorMatrixLiteral;
  String get errorInternalMatrixDisposed;
  String errorInvalidSyntax(String op);

  // -- Export + share --
  String get exportDataTitle;
  String get exportDataSubtitle;
  String get exportDataCopy;
  String get exportDataCopied;
  String get historyEntryCopyResult;
  String get historyEntryCopyLatex;
  String get historyEntryCopyLatexSubtitle;
  String get historyEntryReuse;
  String get historyEntryCopied;

  // Round 91: Store result as variable / function (right-click /
  // long-press on a Calculator history row or a Notepad result).
  String get storeAsVariable;
  String get storeAsFunction;
  String get storeVariableTitle;
  String get storeFunctionTitle;
  String get storeNameLabel;
  String get storeFunctionParamLabel;
  String get storeButton;
  String get storeNameReserved;
  String storeSavedAs(String name);

  // -- R91b: overwrite confirmation --
  String storeOverwriteTitle(String name);
  String storeOverwriteCurrent(String existing);
  String get storeOverwriteConfirm;

  // -- Settings tile labels for the new entries --
  String get settingsExportData;
  String get settingsExportDataSubtitle;
  String get settingsHelp;
  String get settingsHelpSubtitle;

  // -- High contrast + text scale --
  String get settingsHighContrast;
  String get settingsHighContrastSubtitle;
  String get settingsTextScale;

  // -- Exact integer mode (arbitrary-precision results) --
  String get settingsExactIntegerMode;
  String get settingsExactIntegerModeSubtitle;
  String exactIntegerBadge(int digits);
  String get exactIntegerTapToCopy;

  // -- Long-evaluation progress overlay (V2) --
  String get calculating;

  // -- Sudoku module (Analysis hub / CSP Round B) --
  String get moduleSudokuTitle;
  String get moduleSudokuSubtitle;
  String get sudokuSolveButton;
  String get sudokuClearCell;
  // Round 87: Sudoku UI overhaul (clear-to-start + win chip).
  String get sudokuClearToStart;
  String get sudokuSolvedCorrectly;
  String get sudokuFilledWithErrors;
  // Round 87b: dismissable win celebration overlay.
  String get sudokuWinOverlayTapHint;
  String get sudokuPresetLabelChooser;
  String get sudokuPresetCustom;
  String sudokuPresetLabel(String id);
  String get sudokuVisualizerHeader;
  String get sudokuPlay;
  String get sudokuPause;
  String get sudokuRestart;
  String get sudokuSpeedSlow;
  String get sudokuSpeedMed;
  String get sudokuSpeedFast;
  String get sudokuGenerateButton;

  /// Heading of the generator block. The difficulty chips below it are
  /// a setting for the *next* generated puzzle, not a description of the
  /// preset currently loaded.
  String get sudokuGenerateSection;
  String get sudokuDifficultyEasy;
  String get sudokuDifficultyMedium;
  String get sudokuDifficultyHard;
  String get sudokuVariantRegular;
  String get sudokuVariantX;
  String get sudokuVariantKiller;
  String get sudokuVariantDisjoint;
  String get sudokuCheckUnique;
  String get sudokuUniqueSolution;
  String get sudokuMultipleSolutions;
  String get sudokuShowHints;
  String get sudokuShowHintsSubtitle;
  String get sudokuHintLevelOff;
  String get sudokuHintLevelBasic;
  String get sudokuHintLevelAdvanced;
  String get sudokuHintLevelAdvancedHelp;
  String get sudokuHintLevelComputing;

  // Round 81: step-trace constraint-context captions. Each
  // visualizer frame can name the row / column / box / cage /
  // diagonal / disjoint-group `allDifferent` overlays the
  // just-assigned cell sits in. Variant-specific overlays only
  // appear when the puzzle's variant uses them.
  String sudokuConstraintRow(int row);
  String sudokuConstraintCol(int col);
  String sudokuConstraintBox(int box);
  String sudokuConstraintCage(int cage, int sum);
  String get sudokuConstraintMainDiagonal;
  String get sudokuConstraintAntiDiagonal;
  String sudokuConstraintDisjointGroup(int group);

  /// Caption shown on the very first visualizer frame (no cell has
  /// changed yet — the displayed grid is the user's starting input).
  String sudokuStepStart(int clues);
  String sudokuStepNakedSingle(String cell, int value, int eliminated);
  String sudokuStepHiddenSingle(String unit, int value, String cell);
  String sudokuStepGuess(String cell, int value, String alternatives);
  String sudokuStepLastOption(String cell, int value);
  String sudokuStepContradictionCell(String cell);
  String sudokuStepContradictionUnit(String unit, int value);
  String sudokuStepBacktrack(String cell);
  String get sudokuStepSolved;
  /// Placement techniques that actually occurred. Zero counts are
  /// omitted (`''` when none occurred) so an easy solve does not read
  /// "Guesses 0 · Backtracks 0".
  String sudokuExplainStats(
      int naked, int hidden, int guesses, int backtracks, int depth);
  String get sudokuExplainLogicOnly;
  String sudokuExplainTruncated(int shown);
  String sudokuStepCage(int sum, int size, String combos, int removed);
  String sudokuStepLocked(int digit, String unit, String other, int removed);
  String sudokuStepNakedSubset(
      int size, String cells, String digits, String unit, int removed);
  String sudokuStepHiddenSubset(
      int size, String digits, String unit, String cells, int removed);
  String sudokuStepContradictionCage(int sum);
  /// Candidate-elimination techniques that actually occurred. Zero
  /// counts are omitted (`''` when none occurred).
  String sudokuExplainEliminations(
      int cages, int locked, int nakedSubsets, int hiddenSubsets);
  String get sudokuSearchTreeTitle;
  String get sudokuSearchTreeHint;
  String sudokuSearchTreeTruncated(int shown);
  String get sudokuStepPrevious;
  String get sudokuStepNext;
  String get sudokuEnterClues;
  String get sudokuConstraintStartingPosition;

  /// Renders a solver failure; the limit travels in [SudokuError], so
  /// callers never parse the previously rendered English prose.
  String sudokuError(SudokuError error);

  // -- Constraints module (Analysis hub / CSP Round A) --
  String get moduleConstraintsTitle;
  String get moduleConstraintsSubtitle;
  String get constraintsTabDiophantine;
  String get constraintsTabCryptarithm;
  String get constraintsTabDsl;
  String get constraintsTabFlatZinc;
  String get constraintsTabMagicSquare;
  String get constraintsMagicIntro;
  String get constraintsMagicSize;
  String constraintsMagicConstant(int m);
  String constraintsSoftScore(int satisfied, int total);
  String get constraintsMagicGenerate;
  String get constraintsMagicHint;
  String get constraintsDslIntro;
  String get constraintsDslInputLabel;
  String get constraintsDslExamplesButton;
  String get constraintsDslExamplesTooltip;
  String constraintsDslExampleTitle(String id);
  String get constraintsFlatZincIntro;
  String get constraintsFlatZincInputLabel;
  String get constraintsFlatZincAllSolutions;
  String get constraintsFlatZincFirstSolution;
  String get constraintsFlatZincExhaustiveOne;
  String constraintsFlatZincExhaustiveN(int n);
  String get constraintsFlatZincUnsatisfiable;
  String constraintsFlatZincExampleTitle(String id);
  String get constraintsExplainFailure;
  String get constraintsExplainHeader;
  String get constraintsExplainSatisfiable;
  String constraintsExplainEntryCount(int n);
  String constraintsExplainAltHeader(int n);
  String get constraintsExportFlatZinc;
  // Round F — propagation step-trace visualizer (AC-3 replay).
  String get constraintsVisualizeButton;
  String get constraintsCompareStrategies;
  String get constraintsStrategyHeader;
  String get constraintsStrategyCol;
  String get constraintsStrategyDecisions;
  String get constraintsStrategyBacktracks;
  String get constraintsStrategyPropagations;
  String get constraintsStrategyIterations;
  String get constraintsStrategyTime;
  String get constraintsStructureButton;
  String constraintsStructureHeader(int vars, int constraints);
  String constraintsColorGraphHeader(int nodes, int colours);
  String get constraintsTraceHeader;
  String get constraintsTraceIntro;
  String constraintsTraceStepCounter(int current, int total);
  String get constraintsTraceInitial;
  String constraintsTraceDecision(String variable, int value);
  String constraintsTracePrune(String values, String variable, String cause);
  String constraintsTraceWipeout(String variable, String cause);
  String get constraintsTraceBacktrack;
  String constraintsTraceBackjump(int from, int to);
  String get constraintsTraceSolutionStep;
  String constraintsTraceStats(
      int decisions, int prunes, int wipeouts, int backtracks);
  String get constraintsTracePropagationOnly;
  String get constraintsTraceTopConstraints;
  String constraintsTraceConstraintWork(int removed, int prunes, int wipeouts);
  String get constraintsMagicVisualizeHint;
  String get constraintsTraceSolved;
  String get constraintsTraceUnsat;
  String constraintsTraceTruncatedNote(int n);
  String get constraintsTraceObjectiveNote;
  String get constraintsTracePlay;
  String get constraintsTracePause;
  String get constraintsTraceRestart;
  String get constraintsTraceStepBack;
  String get constraintsTraceStepForward;
  String get constraintsExportedHeader;
  String get constraintsDiophantineIntro;
  String get constraintsCryptarithmIntro;
  String get constraintsVariablesLabel;
  String get constraintsVariablesHint;
  String get constraintsConstraintsLabel;
  String get constraintsConstraintsHint;
  String get constraintsCryptarithmInputLabel;
  String get constraintsSolveButton;
  String get constraintsCancelButton;
  String get constraintsBadVarLine;
  String get constraintsNoSolutions;
  String get constraintsCryptarithmFoundHeader;
  String constraintsSolutionsHeader(int n);
  String constraintsTruncatedHeader(int n);
  String get constraintsCopyResult;
  String get constraintsCopiedToast;
  String constraintsOptimalHeader(num objective);

  // -- Accessibility tooltips (V1 a11y pass) --
  String get clearSearchTooltip;
  String get clearFunctionSlotTooltip;
  String get deleteMemorySlotTooltip;

  // -- Help mode (Round 101 / P6) --
  /// Tooltip on the AppBar `(?)` toggle when help mode is off.
  String get helpModeEnableTooltip;

  /// Tooltip on the AppBar `(?)` toggle when help mode is on.
  String get helpModeDisableTooltip;

  /// Round 102: action-button label on the keypad help popover
  /// that deep-links into the full Function Reference dialog.
  String get keypadHelpLearnMore;

  /// Round 103: title of the history-row help modal — "How this was
  /// computed".
  String get historyHelpTitle;

  /// Round 103: "Computed via {engine}" — `engine` is a literal label
  /// like `SymEngine.solve`, `MPFR`, `FLINT.ntheory`, or `Dart`.
  String historyHelpComputedVia(String engine);

  /// Round 103: fallback line for bare arithmetic rows that don't
  /// route through any named engine call.
  String get historyHelpDirectEvaluation;

  /// Round 103: action-button label on the history help modal that
  /// opens the step-by-step trace dialog (only shown when the call
  /// has a step trace — solve / diff / integrate).
  String get historyHelpShowSteps;

  /// Round 105: tooltip on the `(?)` AppBar button rendered on every
  /// Analyze-hub module screen.
  String get moduleHelpTooltip;

  /// Round 105: title shown in the [ModuleHelpDialog] for a given
  /// module. Caller passes the enum value; localizations dispatch
  /// per locale.
  String moduleHelpTitle(ModuleHelpKind kind);

  /// Round 105: body text — what the module does, the inputs, the
  /// outputs. 2-3 sentences each.
  String moduleHelpDescription(ModuleHelpKind kind);

  // -- Worked examples library --
  String get workedExamplesTitle;
  String get workedExamplesSearchHint;
  String get workedExamplesEmpty;
  String get workedExamplesCopy;
  String get workedExamplesCopied;
  String get workedExamplesInsert;

  /// Localized title for the worked example with the given [id].
  /// Returns null when the locale doesn't have a translation — caller
  /// falls back to the English string in `WorkedExamples.all`.
  String? workedExampleTitle(String id);

  /// Same as [workedExampleTitle] for the description line.
  String? workedExampleDescription(String id);

  String get workedExamplesCatAll;
  String get workedExamplesCatCalculus;
  String get workedExamplesCatAlgebra;
  String get workedExamplesCatLinearAlgebra;
  String get workedExamplesCatNumberTheory;
  String get workedExamplesCatStatistics;
  String get workedExamplesCatUnits;
  String get workedExamplesCatConstraints;
  String get settingsWorkedExamples;
  String get settingsWorkedExamplesSubtitle;

  // -- Function reference (Round 96 P6) --
  String get functionRefTitle;
  String get functionRefSearchHint;
  String get functionRefEmpty;
  String get functionRefSeeAlso;
  String get functionRefTryInCalculator;
  String get functionRefOpenModule;
  String get functionRefSeeWorkedExample;

  /// Round 100: localized override for a [FunctionRef]'s
  /// `shortDescription`, keyed by the entry `id`. Returns null when
  /// this locale has no translation for the entry yet; the dialog
  /// then falls back to the English string baked into the catalog.
  /// EN always returns null (the catalog is the English source of
  /// truth). Signatures and example input/expected stay untranslated
  /// (they're code), so only the prose flows through here.
  String? functionRefDescription(String id);

  /// Round 100: localized override for the `hint` on the example at
  /// [index] of the [FunctionRef] with the given `id`. Null → the
  /// dialog falls back to the catalog hint. EN always returns null.
  String? functionRefExampleHint(String id, int index);
  String get functionRefCatCas;
  String get functionRefCatNumberTheory;
  String get functionRefCatPrecision;
  String get functionRefCatMatrix;
  String get functionRefCatGraphing;
  String get functionRefCatStatistics;
  String get functionRefCatConstraints;
  String get functionRefCatSudoku;
  String get functionRefCatUnits;
  String get functionRefCatLogic;
  String get settingsFunctionRef;
  String get settingsFunctionRefSubtitle;

  // -- Import data --
  String get importDataTitle;
  String get importDataSubtitle;
  String get importDataWarning;
  String get importDataApply;
  String get importDataEmpty;
  String get importDataNotObject;
  String get importDataApplied;
  String get settingsImportData;
  String get settingsImportDataSubtitle;

  // -- User-defined functions --
  String get userFunctionsTitle;
  String get userFunctionsHelp;
  String get userFunctionsEmpty;
  String get userFunctionsAdd;
  String get userFunctionsEdit;
  String get userFunctionsDelete;
  String get userFunctionsName;
  String get userFunctionsNameHelp;
  String get userFunctionsNameRequired;
  String get userFunctionsNameInvalid;
  String get userFunctionsParam;
  String get userFunctionsBody;
  String get userFunctionsBodyRequired;
  String get settingsUserFunctions;
  String get settingsUserFunctionsSubtitle;

  // -- Onboarding tour (first-launch overlay) --
  String get onboardingSkip;
  String get onboardingNext;
  String get onboardingDone;
  String onboardingPage(int current, int total);
  String get onboardingKeypadTitle;
  String get onboardingKeypadBody;
  String get onboardingHistoryTitle;
  String get onboardingHistoryBody;
  String get onboardingFunctionsTitle;
  String get onboardingFunctionsBody;
  String get onboardingAnalysisTitle;
  String get onboardingAnalysisBody;
  String get onboardingNotepadTitle;
  String get onboardingNotepadBody;
  String get onboardingWorksheetTitle;
  String get onboardingWorksheetBody;
  String get onboardingTryWorksheet;
  String get analysisLabsTitle;
  String get analysisLabsSubtitle;
  String get aboutOurApps;
  String get aboutOurAppsIntro;
  String get aboutAppStore;
  String get aboutMacAppStore;
  String get aboutTestFlight;
  String get aboutComingSoon;
  String get aboutThisApp;
  String get settingsReplayTour;
  String get settingsReplayTourSubtitle;

  // -- Step-engine plain-language notes (V2). Returns a localized
  //    sentence for the given key, interpolating `note.params`.
  //    Returns null when the locale doesn't carry a translation for
  //    the key — the caller should fall back to the English `note`
  //    field carried alongside `noteI18n` on each MathStep.
  String? stepNote(StepNote note);

  // -- Help screen --
  String get helpTitle;
  String get helpFunctionsHeading;
  String get helpMatrixHeading;
  String get helpStepsHeading;
  String get helpMatrixBody;
  String get helpStepsBody;

  // -- Constants library --
  String get constantsTitle;
  String get constantsSearchHint;
  String get constantsNoMatches;
  String get constantsAllCategory;
  String get constantsCategoryMathematical;
  String get constantsCategoryPhysical;
  String get constantsCategoryChemistry;
  String get constantsCategoryAstronomy;
  String get constantsCopyValue;
  String constantsCopiedToast(String symbol);
  String get settingsConstants;
  String get settingsConstantsSubtitle;

  // -- Keypad tab labels --
  String get tabNum;
  String get tabTrig;
  String get tabCas;
  String get tabAdvanced;
  String get tabVars;
  String get tabBasic;
  String get tabSymbolic;
  // i18n sweep 2026-11-20
  String get helpGroupArithmetic;
  String get helpGroupAlgebraicCas;
  String get helpGroupCalculus;
  String get helpGroupTrigElementary;
  String get helpGroupVectorTensor;
  String get helpGroupMatrix;
  String get helpFnArithmeticDesc;
  String get helpFnPowerDesc;
  String get helpFnFactorialDesc;
  String get helpFnAbsDesc;
  String get helpFnSolveDesc;
  String get helpFnFactorDesc;
  String get helpFnExpandDesc;
  String get helpFnSimplifyDesc;
  String get helpFnSubstDesc;
  String get helpFnAnsDesc;
  String get helpFnDiffDesc;
  String get helpFnDiffStepsDesc;
  String get helpFnIntegralDesc;
  String get helpFnDefiniteIntegralDesc;
  String get helpFnIntegralStepsDesc;
  String get helpFnLimitDesc;
  String get helpFnTrigDesc;
  String get helpFnInverseTrigDesc;
  String get helpFnHyperbolicDesc;
  String get helpFnLnDesc;
  String get helpFnRootDesc;
  String get helpFnConstantsDesc;
  String get helpFnDotDesc;
  String get helpFnCrossDesc;
  String get helpFnNormDesc;
  String get helpFnUnitDesc;
  String get helpFnDetDesc;
  String get helpFnInvDesc;
  String get helpFnTransposeDesc;
  String get helpFnMatrixOpsDesc;
  String get helpFnStatisticsDesc;
  String get helpFnNormalDesc;
  String get helpFnBinomialDesc;
  String get helpFnStatisticsName;
  String get helpFnNormalName;
  String get helpFnBinomialName;
  String get calcIconCamera;
  String get calcIconPhotoLibrary;
  String get calcOcrTakePhoto;
  String get calcOcrSingleFormula;
  String get calcOcrChooseFromGallery;
  String get calcOcrDocumentPage;
  String get calcOcrDocumentPageSubtitle;
  String get calcOcrNoProviderConfiguredYet;
  String get calcOcrNoProviderConfigured;
  String get calcOcrRecognizing;
  String get calcOcrFailedClearer;
  String calcMemoryEmpty(int slot);
  String get calcIconAnalyze;
  String get calcIconSolve;
  String get calcIconCopy;
  String get calcIconStoreAsVariable;
  String get calcShareLink;
  String get calcLinkCopied;
  String get calcScanMath;
  String get calcWriteMath;
  String get calcIconHelpMode;
  String get calcIconDisableHelpMode;
  String get calcIconPlainText;
  String get calcIconContinueTyping;
  String get varViewerStorageIcon;
  String get varViewerEmptyTitle;
  String get varViewerEmptyBody;
  String varViewerClearAllTitle(String section);
  String varViewerClearAllConfirm(String section);
  String get varViewerClearAllIcon;
  String varViewerClearAllTooltip(String section);
  String get varViewerDeleteVariable;
  String get varViewerDeleteFunction;
  String get memoryNoResultToStore;
  String get memoryStoreResultTitle;
  String memoryStorePreview(String value);
  String get memorySaveAsVariable;
  String get memorySaveToMemory;
  String get memoryVariableNameLabel;
  String get memoryVariableNameHint;
  String memoryValuePreview(String value);
  String memorySavedVariable(String name, String value);
  String memorySavePreview(String value);
  String get memoryEmptySlot;
  String memorySavedToSlot(int slot);
  String get memoryDeleteTitle;
  String get memoryAllCleared;
  String get stepsNarrate;
  String get stepsNarrateWithAi;
  String get stepsResult;
  String get stepsStep;
  String get stepsBecomes;
  String get stepsSolution;
  String get stepsOdeFallbackNote;
  String get historyExplain;
  String get historyExplainWithAi;
  String get historyIntegrationMethodNotRecorded;
  String get cmdPaletteFindCommand;
  String get cmdPaletteHint;
  String get cmdPaletteNoResults;
  String get unitConvError;
  String get unitConvSwap;
  String get unitConvSwapUnits;
  String get unitConvConvertsTo;
  String get unitConvDimArea;
  String get unitConvDimVolume;
  String get userFunctionsAddFunction;
  String get graphModeParametric;
  String get graphModePolar;
  String get graphModeImplicit;
  String get graphModeVectorField;
  String get graphBounds;
  String get graphBoundsXMin;
  String get graphBoundsXMax;
  String get graphBoundsYMin;
  String get graphBoundsYMax;
  String get graphBoundsInvalid;
  String get graphApplyBounds;
  String graphFitFailed(String error);
  String get graphFit;
  String get graphUndoChange;
  String get graphTraceCurve;
  String get graphValueTable;
  String graphLinkedSlot(int slot, String document);
  String get graphMissingDocument;
  String graphTraceSlot(int slot);
  String get graphTraceHint;
  String get graphTraceWaiting;
  String get graphUndefined;
  /// Screen-reader label for glyph-only keypad buttons; null = read the visible text.
  String? keypadSpokenLabel(String key);
  /// Hover/long-press hint for keypad keys without a FunctionRef entry; null = no tooltip.
  String? keypadKeyHint(String key);
  String keypadTooltipExample(String example);
  String keypadTooltipShortcut(String keys);
  String get keypadTabNumHint;
  String get keypadTabTrigHint;
  String get keypadTabCasHint;
  String get keypadTabAdvancedHint;
  String get keypadTabVarsHint;
  String get statsDataLabel;
  String get statsPaste;
  String get statsPasteFromClipboard;
  String statsError(String error);
  String get statsFullPrecision;
  String get statsFullPrecisionTitle;
  String statsFullPrecisionBody(String mean, String median, String stddev);
  String get statsEnterAtLeastOne;
  String get statsBestFitLine;
  String statsSlopeA(String value);
  String statsInterceptB(String value);
  String statsBestFitPolynomial(int degree);
  String get statsBestFitExponential;
  String statsRSquaredLogSpace(String value);
  String get statsModelLinear;
  String get statsModelPolynomial;
  String get statsModelExponential;
  String get statsDegreeLabel;
  String get statsXValues;
  String get statsYValues;
  String get statsNormalDistribution;
  String get statsMeanMu;
  String get statsStddevSigma;
  String get statsXForCdf;
  String get statsPForQuantile;
  String get statsNormalPrompt;
  String get statsQuantileP;
  String get statsStudentTDistribution;
  String get statsDegreesOfFreedomNu;
  String get statsIntervalLowerBound;
  String get statsIntervalUpperBound;
  String get statsTIntervalProbability;
  String get statsTPrompt;
  String get statsBinomialDistribution;
  String get statsTrialsN;
  String get statsSuccessP;
  String get statsBinomialPrompt;
  String get statsStddevShort;
  String get statsRejectH0;
  String get statsFailToRejectH0;
  String get statsSampleData;
  String get statsHypothesizedMeanLabel;
  String get statsSampleMean;
  String get statsSampleStddev;
  String get statsSampleSize;
  String get statsHypothesizedMu;
  String get statsTStatistic;
  String get statsDegreesOfFreedom;
  String get statsPValueTwoSided;
  String get statsPValueUpperTail;
  String get statsPValueLowerTail;
  String get statsPValueUpper;
  String get statsPValueLower;
  String statsSampleN(int n);
  String get statsMean1;
  String get statsMean2;
  String get statsStddev1;
  String get statsStddev2;
  String get statsSizes;
  String get statsTStatisticWelch;
  String get statsDfWelch;
  String get statsBefore;
  String get statsAfter;
  String get statsMeanDifference;
  String get statsStddevOfDiffs;
  String get statsPairsN;
  String get statsGroupsLabel;
  String get statsGroupsHelper;
  String statsGroupLabel(int index, int size);
  String statsGroupMean(String value);
  String get statsGrandMean;
  String get statsSsBetween;
  String get statsSsWithin;
  String get statsDfBetweenWithin;
  String get statsMsBetween;
  String get statsMsWithin;
  String get statsFStatistic;
  String get statsContingencyLabel;
  String get statsContingencyHelper;
  String get statsChiSquareStatistic;
  String get statsGrandTotal;
  String get statsFisherCellsLabel;
  String get statsFisherCellsHelper;
  String statsCell(String cell, int row, int col);
  String get statsPObserved;
  String get statsSignHelper;
  String get statsPositives;
  String get statsNegatives;
  String get statsTies;
  String get statsEffectiveN;
  String get statsWilcoxonHelper;
  String get statsRankSum;
  String get statsZStatistic;
  String get statsObservedCounts;
  String get statsExpectedCounts;
  String get statsTestOneSampleT;
  String get statsTestTwoSampleT;
  String get statsTestPairedT;
  String get statsTestAnova;
  String get statsTestChiSquareGof;
  String get statsTestChiSquareIndependence;
  String get statsTestFisherExact;
  String get statsTestPairedSign;
  String get statsTestWilcoxon;
  String get statsSignificanceLevel;
  String get conicNotAConicSentence;
  String get conicEquationHeading;
  String conicDiscriminant(String value);
  String conicType(String kind);
  String conicRotationAngle(String radians, String degrees);
  String conicCenter(String x, String y);
  String get conicParabolaAxisNote;
  String conicSemiTransverseAxis(String value);
  String conicSemiConjugateAxis(String value);
  String conicSemiMajorAxis(String value);
  String conicSemiMinorAxis(String value);
  String conicEccentricity(String value);
  String get conicKindCircle;
  String get conicKindEllipse;
  String get conicKindParabola;
  String get conicKindHyperbola;
  String get conicKindDegenerate;
  String get conicKindNotAConic;
  String planeError(String error);
  String get planeCoordinateFormHeading;
  String planeNormalVector(String vector);
  String planeUnitNormal(String vector);
  String planeHessianNormalForm(String value);
  String planeSignedDistance(String value);
  String planePointOnPlane(String point);
  String get planeAxisIntercepts;
  String planeAxisIntercept(String axis, String point);
  String planeAxisParallel(String axis);
  String get planePointP;
  String get planeDirectionU;
  String get planeDirectionV;
  String get curvePleaseEnterFunction;
  String curveAnalysisError(String error);
  String curveSavedVariable(String name, String value);
  String get curveAllSlotsFullTitle;
  String get curveWhichFunctionReplace;
  String curveReplacedSlot(int slot);
  String get curveNoSavedFunctions;
  String get curveSelectFromSaved;
  String get curveSaveAsFunction;
  String get valueTableTitle;
  String get valueTableFunction;
  String get valueTableFrom;
  String get valueTableTo;
  String get valueTableStep;
  String get valueTableGenerate;
  String get valueTableGenerateFailed;
  String get valueTableChooseInterval;
  String get valueTableCopied;
  String get valueTableCopyTable;
  String get valueTableCsvCopied;
  String get valueTableCopyCsv;
  String get matrixEdTitle;
  String get matrixEdUseInCalculator;
  String get matrixEdValues;
  String get matrixEdQuickOperations;
  String get matrixEdRows;
  String get matrixEdColumns;
  String get scene3DQuadricCustom;
  String get scene3DShortCone;
  String get scene3DShortCylinder;
  String get scene3DShortParaboloid;
  String get scene3DShortHyperboloid1;
  String get scene3DShortHyperboloid2;
  String scene3DParamSteps(String param);
  String get scene3DCurveSteps;
  String constraintsMagicSolveFailed(String error);
  String constraintsPackingHeader(int width, int height);
  String constraintsSubcircuitHeader(int count);
  String constraintsTourHeader(int count);
  String constraintsMoreSolutions(int count);
  String get graph3DNoFiniteValues;
  String get moduleHelpIconLabel;
  /// Display name for a worksheet: the persisted English default `Untitled`/`Untitled N` is shown in the UI language; other names pass through.
  String notepadDisplayDocName(String name);
  String notepadCopyName(String name);
  /// Localized template name by template id; [fallback] is the English catalog name.
  String notepadTemplateName(String id, String fallback);
  /// Localized prose of template `## heading` / `// comment` lines (math lines are never passed here).
  String notepadTemplateText(String text);
  String notepadLineCount(int n);
  String get notepadWelcomeSample;
  String get notepadAdd;
  String get notepadNew;
  String get notepadSearchHint;
  String notepadSearchShownHidden(int shown, int hidden);
  String notepadSearchMatches(int n);
  String get notepadCloseSearch;
  String get notepadCamera;
  String get notepadTakePhoto;
  String get notepadSingleFormula;
  String get notepadPhotoLibrary;
  String get notepadChooseFromGallery;
  String get notepadDocumentPage;
  String get notepadDocumentPageSubtitle;
  String get notepadNoOcrProvider;
  String get notepadOcrFailed;
  String get notepadAiTranslate;
  String get notepadAiDescribePrompt;
  String get notepadAiHint;
  String get notepadScanMath;
  String get notepadWriteMath;
  String get notepadExportPdf;
  String get notepadExportAsPdf;
  String get notepadLatexInput;
  String get notepadChecked;
  String get notepadUnchecked;
  String get notepadNotes;
  String get notepadPinned;
  String get notepadExpandSection;
  String get notepadCollapseSection;
  String get notepadExpand;
  String get notepadCollapse;
  String notepadHiddenLines(int n);
  String get notepadLinkToGraph;
  String notepadLineHint(int n);
  String get notepadDragToReorder;
  String get notepadCopy;
  String get notepadExplainWithAi;
  String get notepadBlocked;
  String get notepadCircularReference;
  String get notepadCurrentDocument;
  String get notepadDocument;
  String get notepadConfirmRename;
  String get notepadCancelRename;
  String get notepadKindVariable;
  String get notepadKindFunction;
  String get notepadKindConstant;
  String settingsWorkflowOpenFailed(String error);
  String get settingsHighContrastSemantic;
  String get settingsTextScaleSemantic;
  String get settingsExactIntegersSemantic;
  String get settingsAutoBindSolveSemantic;
  String get settingsTourSemantic;
  String get settingsStartTourSemantic;
  String get settingsUserFunctionsSemantic;
  String get settingsOpenSemantic;
  String get settingsWorkedExamplesSemantic;
  String get settingsFunctionReferenceSemantic;
  String get settingsExportSemantic;
  String get settingsBackupSemantic;
  String get settingsBackupsSubtitle;
  String get settingsOcrModelsTitle;
  String get settingsOcrModelsSubtitle;
  String get settingsDiagnosticsSemantic;
  String get settingsRunDiagnosticsSemantic;
  String get settingsDiagnosticPassed;
  String get settingsDiagnosticFailed;
  String get settingsSyncSemantic;
  String get settingsAboutSemantic;
  String get bannerDownloadAppSemantic;
  String get actionCopy;
  String get examplesSearchSemantic;
  String resultEvidenceOriginalDomain(String domain);
  String get aboutFullPrivacyPolicy;
  String get aboutSourceCode;
  String get crashReportsSemantic;
  String get crashReportsTitle;
  String crashReportsCount(int count);
  String get crashReportsSubtitle;
  String get crashReportOnGitHub;
  String get crashSendEmail;
  String get assistMathTitle;
  String get assistMathSubtitle;
  String get assistOpenAssistant;
  String get assistSettingsSaved;
  String assistConfigured(String model);
  String get assistNotConfigured;
  String get assistCollapse;
  String get assistExpand;
  String get assistDescription;
  String get assistApiKey;
  String get assistModel;
  String get assistStop;
  String get assistDismiss;
  String get assistStepNarration;
  String get syncDialogTitle;
  String get syncSettingsConfigured;
  String get syncSettingsOff;
  String get syncReplaceTitle;
  String get syncReplaceBody;
  String get syncUploadBackup;
  String get syncUploaded;
  String get syncUploadFailed;
  String get syncNoBackup;
  String get syncBackupLoaded;
  String get syncReadFailed;
  String get syncAccountCreatedConfirm;
  String get syncAccountCreatedSignedIn;
  String get syncSignedIn;
  String get syncSignUpFailed;
  String get syncSignInFailed;
  String get syncConfigured;
  String get syncConfigureFailed;
  String get syncConfigureFormatError;
  String get syncConfigureSaveFailed;
  String get syncSignedOut;
  String get syncSignOutFailed;
  String get syncSignedOutLocally;
  String get syncWorking;
  String get syncConnectFailed;
  String get syncReady;
  String get syncNotConfigured;
  String get syncOffBody;
  String get syncProjectUrl;
  String get syncPublicKey;
  String get syncConfigureButton;
  String get syncEmail;
  String get syncPassword;
  String get syncLogIn;
  String get syncSignUp;
  String syncLoggedInAs(String email);
  String get syncPull;
  String get syncPush;
  String get syncSignOut;
  String get backupDialogTitle;
  String backupFailed(String error);
  String get backupWorksheetsImported;
  String get backupWorkspaceRestored;
  String get backupIntro;
  String backupContents(int worksheets, int checkpoints);
  String get backupRestoreExplanation;
  String backupDocRows(String name, int rows);
  String get backupSave;
  String get backupOpen;
  String get backupNoRecovery;
  String get backupPreviousWorkspace;
  String get backupImportWorksheets;
  String get backupReplaceWorkspace;
  String handwritingInitFailed(String error);
  String get handwritingTermsTitle;
  String handwritingTermsBody(String model, String terms);
  String get handwritingAcceptTerms;
  String get handwritingSendTitle;
  String handwritingSendBody(String model);
  String get handwritingSendAction;
  String get handwritingNotRecognized;
  String handwritingRecognitionFailed(String error);
  String get handwritingTitle;
  String get handwritingChooseModel;
  String get handwritingNoModel;
  String get handwritingCloudNote;
  String get handwritingLocalNote;
  String get handwritingReviewNote;
  String get handwritingCanvas;
  String get handwritingModels;
  String get handwritingRecognize;
  String get ocrRecognizedExpression;
  String get ocrCamera;
  String get ocrEditBeforeInsert;
  String get ocrHideRawOutput;
  String get ocrShowRawOutput;
  String get ocrRawOutput;
  String get ocrLicenseTermsTitle;
  String ocrLicenseTermsBody(String license);
  String get ocrLicenseAppNotRestricted;
  String get ocrAcceptDownload;
  String ocrModelDownloaded(String name);
  String ocrDownloadFailed(String name);
  String get ocrModelsTitle;
  String get ocrModelsWebTitle;
  String get ocrWebCacheNote;
  String get ocrAvailableModels;
  String get ocrDiskUsageSemantic;
  String ocrDiskUsage(String mb);
  String get ocrActiveProvider;
  String get ocrActive;
  String get ocrInactive;
  String get ocrTagCloud;
  String get ocrTagApiKey;
  String get ocrTagOnDevice;
  String get ocrNoModelActiveSemantic;
  String get ocrNoModelActive;
  String get ocrCatPrintedMath;
  String get ocrCatHandwrittenMath;
  String get ocrCatTextDetection;
  String get ocrCatTextRecognition;
  String get ocrCatLayoutDetection;
  String get ocrCatVisionLanguage;
  String get ocrQualBestQuality;
  String get ocrQualChineseEnglish;
  String get ocrQual91Langs;
  String get ocrQualRecommended;
  String get ocrQualNonCommercialOptional;
  String get ocrQualFast1B;
  String get ocrDownloaded;
  String get ocrNotDownloaded;
  String get ocrCached;
  String get ocrNotCached;
  String get ocrWithdrawLicense;
  String get ocrReviewLicenseToEnable;
  String get ocrReviewLicense;
  String get ocrPauseDownload;
  String get ocrDeleteModel;
  String get ocrResumeDownload;
  String get ocrDownloadModel;
  String get licenseNonCommercialTitle;
  String get licenseTermsTitle;
  String get licenseOpen;
  String get licenseRead;
  String get licenseDecline;
  String get licenseAccept;
  // end i18n sweep 2026-11-20
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      const ['en', 'de', 'fr', 'es'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    final AppLocalizations resolved;
    switch (locale.languageCode) {
      case 'de':
        resolved = const DeLocalizations();
        break;
      case 'fr':
        resolved = const FrLocalizations();
        break;
      case 'es':
        resolved = const EsLocalizations();
        break;
      default:
        resolved = const EnLocalizations();
    }
    return SynchronousFuture<AppLocalizations>(resolved);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

extension AppLocalizationsExtensions on AppLocalizations {
  /// Best-effort translation of engine-emitted classification strings
  /// (e.g. "Local Minimum: (x, y)" → "Lokales Minimum: (x, y)"). Patterns
  /// match case-sensitively against the well-known English markers the
  /// analysis engine produces; unrecognized text passes through.
  ///
  /// Long markers (sentences) are tried before short labels so a string
  /// like "No inflection points found" doesn't get partially clobbered
  /// by the short labels.
  String translateClassification(String raw) {
    // Round 71: the analysis engine sometimes emits
    // "No inflection points (f''(x) = <value> ≠ 0)" — the
    // parenthetical value is dynamic, so a literal map entry
    // can't catch it. Reduce the whole sentence to the
    // translated "no inflection points" before falling through
    // to the literal-replacement table below.
    if (raw.startsWith("No inflection points (f''(x)") ||
        raw.startsWith('No inflection points (f\'\'(x)')) {
      return curveResultNoInflection;
    }
    if (raw.startsWith(
        'Error: Cannot find inflection points without second derivative')) {
      return curveResultNoInflection;
    }
    final replacements = <String, String>{
      'Function has constant concavity (f\'\'(x) = 0 everywhere)':
          extremumConstantConcavity,
      'No critical points found': extremumNoCriticalPoints,
      'No inflection points found': curveResultNoInflection,
      'Local Minimum': extremumLocalMinimum,
      'Local Maximum': extremumLocalMaximum,
      'Critical Point': extremumCriticalPoint,
      'Inflection Point': extremumInflectionPoint,
    };
    var out = raw;
    for (final entry in replacements.entries) {
      if (out.contains(entry.key)) out = out.replaceAll(entry.key, entry.value);
    }
    return out;
  }
}

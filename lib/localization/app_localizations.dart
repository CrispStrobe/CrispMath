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

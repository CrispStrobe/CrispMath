// lib/localization/locales/en.dart
//
// English strings for [AppLocalizations].

part of '../app_localizations.dart';

class EnLocalizations implements AppLocalizations {
  const EnLocalizations();

  @override
  String get navCalculator => 'Calculator';
  @override
  String get navNotepad => 'Notepad';
  @override
  String get notepadDefaultDocName => 'Untitled';
  @override
  String get notepadAddLine => 'Add line';
  @override
  String get notepadDeleteLine => 'Delete line';
  @override
  String get notepadDocumentMenu => 'Document menu';
  @override
  String get notepadNewDocument => 'New document';
  @override
  String get notepadOpenWelcomeSample => 'Open Welcome sample';
  @override
  String get notepadRecalculateAll => 'Recalculate all';
  @override
  String get notepadRename => 'Rename';
  @override
  String get notepadDuplicate => 'Duplicate';
  @override
  String get notepadCopyAsMarkdown => 'Copy as Markdown';
  @override
  String get notepadDeleteDocument => 'Delete document';
  @override
  String get notepadUndo => 'Undo';
  @override
  String get notepadLineDeleted => 'Line deleted';
  @override
  String get menuAboutApp => 'About CrispMath';
  @override
  String get menuSettingsEllipsis => 'Settings…';
  @override
  String get menuFile => 'File';
  @override
  String get menuEdit => 'Edit';
  @override
  String get menuUndo => 'Undo';
  @override
  String get menuRedo => 'Redo';
  @override
  String get menuCut => 'Cut';
  @override
  String get menuCopy => 'Copy';
  @override
  String get menuPaste => 'Paste';
  @override
  String get menuSelectAll => 'Select All';
  @override
  String get menuView => 'View';
  @override
  String get menuTools => 'Tools';
  @override
  String get menuHelp => 'Help';
  @override
  String get menuCommandPalette => 'Command Palette…';
  @override
  String get menuWorkspaceBackups => 'Workspace Backups…';
  @override
  String get menuSync => 'Sync…';
  @override
  String historyStored(String what) => 'Stored $what';
  @override
  String historyDefined(String what) => 'Defined $what';
  @override
  String notepadDocumentDeleted(String name) => 'Document "$name" deleted';
  @override
  String get notepadCopiedAsMarkdown => 'Copied as Markdown';
  @override
  String get notepadCopyResult => 'Copy result';
  @override
  String get notepadCopyAsLatex => 'Copy as LaTeX';
  @override
  String get notepadCopiedResult => 'Copied result';
  @override
  String get notepadCopiedAsLatex => 'Copied as LaTeX';
  @override
  String get notepadEmptyTitle => 'No documents yet';
  @override
  String get notepadEmptyBody =>
      'Create a new document or open the Welcome sample to get started.';
  @override
  String notepadFreeVars(String names) => 'free: $names';
  @override
  String notepadBlockedBy(String alias) => 'Blocked by $alias';
  @override
  String notepadCycle(String path) => 'Cycle: $path';
  @override
  String notepadUnknownImport(String name) =>
      'Unknown import: "$name" not in global variables';
  @override
  String notepadInvalidImport(String name) => 'Invalid import name: "$name"';
  @override
  String get notepadEmptyImportList => 'Empty import list';
  @override
  String notepadUseDirective(String code) => 'Use directive: $code';
  @override
  String get notepadManageTitle => 'Manage notepads';
  @override
  String get notepadManageNotepads => 'Manage notepads…';
  @override
  String get notepadOpenDocument => 'Open';
  @override
  String get notepadOpenFile => 'Open worksheet file';
  @override
  String get notepadSaveFile => 'Save worksheet file';
  @override
  String get notepadFileSaved => 'Worksheet saved';
  @override
  String get notepadFileOpenFailed => 'Could not open worksheet';
  @override
  String get notepadFileSaveFailed => 'Could not save worksheet';
  @override
  String get notepadExportAsJson => 'Export as JSON';
  @override
  String get notepadImportFromJson => 'Import from JSON';
  @override
  String get notepadImport => 'Import';
  @override
  String get notepadImportJsonHint => 'Paste a notepad JSON payload here…';
  @override
  String get notepadJsonCopied => 'Notepad JSON copied to clipboard';
  @override
  String notepadJsonImported(String name) => 'Imported "$name"';
  @override
  String get notepadJsonImportFailed =>
      'Import failed: payload is not valid notepad JSON';
  @override
  String get graphErrorEmpty => 'Function is empty';
  @override
  String get graphErrorUnbalanced =>
      'Unbalanced parentheses or brackets — the function can\'t be plotted';
  @override
  String get graphErrorTrailingOperator =>
      'Function ends with an operator — add the right-hand side';
  @override
  String get navGraphing => 'Graphing';
  @override
  String get navFunctions => 'Functions';
  @override
  String get navAnalysis => 'Analysis';
  @override
  String get navSettings => 'Settings';

  @override
  String get historyHere => 'Calculation history will appear here.';
  @override
  String get historyLabel => 'History:';
  @override
  String get clearButton => 'C';
  @override
  String get clearHistory => 'Clear History';
  @override
  String get clearHistoryConfirm =>
      'Remove all calculation entries from history?';
  @override
  String get searchHistory => 'Search history';
  @override
  String get searchHistoryHint => 'Filter history…';
  @override
  String get historyNoMatches => 'No matching entries.';

  @override
  String get graphSampling => 'Updating graph';
  @override
  String get graphSamplingFailed => 'Could not update the graph.';
  @override
  String get graphNoRealValues =>
      'No real values in this range. Check the expression or try another range.';
  @override
  String get graphRetry => 'Retry';
  @override
  String graphingTitle(int count) => 'Graphing ($count functions)';
  @override
  String functionAdded(int slot) => 'Function added to Y$slot';
  @override
  String functionRemoved(int slot) => 'Removed Y$slot';
  @override
  String functionUpdated(int slot) => 'Updated Y$slot';
  @override
  String functionEditing(int slot) =>
      'Editing Y$slot: press Enter to save';
  @override
  String get functionActions => 'Function actions';
  @override
  String get functionEdit => 'Edit';
  @override
  String get functionRemove => 'Remove';
  @override
  String get allSlotsFull =>
      'All function slots are full. Clear a function first.';
  @override
  String get clearAllFunctions => 'Clear All Functions';
  @override
  String get clearAllFunctionsConfirm =>
      'Are you sure you want to clear all graphed functions?';
  @override
  String get cancel => 'Cancel';
  @override
  String get clearAll => 'Clear All';
  @override
  String get zoomIn => 'Zoom In';
  @override
  String get zoomOut => 'Zoom Out';
  @override
  String get resetView => 'Reset View';
  @override
  String get showKeypad => 'Show Keypad';
  @override
  String get hideKeypad => 'Hide Keypad';
  @override
  String get showAnnotations => 'Show roots & extrema';
  @override
  String get hideAnnotations => 'Hide roots & extrema';
  @override
  String get analyzeFunctions => 'Analyze Functions';
  @override
  String get selectFunctionToAnalyze => 'Select Function to Analyze';
  @override
  String get plotButton => 'Plot';
  @override
  String get enterFunctionPrompt => 'Enter a function below to start graphing.';

  @override
  String get analysisModulesTitle => 'Analysis Modules';
  @override
  String get moduleCurveSketching => 'Curve Sketching';
  @override
  String get moduleCurveSketchingSubtitle => 'Full analysis of a function f(x)';
  @override
  String get modulePlanes => 'Planes';
  @override
  String get modulePlanesSubtitle =>
      'Analyze 3D planes in coordinate or parametric form';
  @override
  String get moduleConics => 'Conic Sections';
  @override
  String get moduleConicsSubtitle =>
      'Classify Ax² + Bxy + Cy² + Dx + Ey + F = 0';
  @override
  String get moduleStatistics => 'Statistics';
  @override
  String get moduleStatisticsSubtitle =>
      'Descriptive stats, linear regression, normal & binomial distributions';
  @override
  String get module3DTitle => '3D Graphing';
  @override
  String get module3DSubtitle =>
      'Plot z = f(x, y) as a rotatable wireframe surface';
  @override
  String get module3DFunctionLabel => 'f(x, y)';
  @override
  String get module3DRangeLabel => 'Range';
  @override
  String get module3DResample => 'Re-sample grid';
  @override
  String get module3DTapPlot => 'Enter a function of x and y, then tap Plot.';

  // -- P9-A2 --
  @override
  String get module3DScene => '3D Scene';
  @override
  String get module3DSceneSubtitle =>
      'Render multiple 3D objects together — planes, lines, spheres, quadrics';
  @override
  String get scene3DAddPlane => 'Add plane';
  @override
  String get scene3DEditPlane => 'Edit plane';
  @override
  String get scene3DEmpty =>
      'Drag to rotate · pinch to zoom · tap the + button to add a plane';
  @override
  String get scene3DPanelEmpty => 'No objects yet';
  @override
  String get scene3DObjectLabel => 'Label';
  @override
  String get scene3DColor => 'Color';
  @override
  String get scene3DAdd => 'Add';
  @override
  String get scene3DSave => 'Save';
  @override
  String get scene3DEdit => 'Edit';
  @override
  String get scene3DDelete => 'Delete';
  @override
  String get scene3DHide => 'Hide';
  @override
  String get scene3DShow => 'Show';
  @override
  String get scene3DLabelRequired => 'Label required';
  @override
  String get scene3DCoefRequired => 'Required';
  @override
  String get scene3DCoefInvalid => 'Not a number';
  @override
  String get scene3DPlaneZeroNormal =>
      'Normal vector (a, b, c) must be non-zero';

  // -- P9-A3 --
  @override
  String get scene3DAddObject => 'Add object';
  @override
  String get scene3DAddLine => 'Add line';
  @override
  String get scene3DEditLine => 'Edit line';
  @override
  String get scene3DAddSphere => 'Add sphere';
  @override
  String get scene3DEditSphere => 'Edit sphere';
  @override
  String get scene3DLinePointDir => 'Point + direction';
  @override
  String get scene3DLineTwoPoints => 'Two points';
  @override
  String get scene3DLinePoint => 'Point';
  @override
  String get scene3DLineDirection => 'Direction';
  @override
  String get scene3DLineFirstPoint => 'First point';
  @override
  String get scene3DLineSecondPoint => 'Second point';
  @override
  String get scene3DLineZeroDirection =>
      'Direction vector must be non-zero (or pick two distinct points)';
  @override
  String get scene3DSphereCenter => 'Center';
  @override
  String get scene3DSphereRadius => 'Radius';
  @override
  String get scene3DSpherePositiveRadius => 'Radius must be greater than zero';

  // -- P9-A4 --
  @override
  String get scene3DIntersectionsEmpty =>
      'Add two or more objects to see their intersections';
  @override
  String scene3DIntersectionsTitle(int n) =>
      n == 1 ? '1 intersection' : '$n intersections';
  @override
  String get intersectionPoint => 'Point';
  @override
  String get intersectionTwoPoints => 'Two points';
  @override
  String get intersectionLine => 'Line';
  @override
  String get intersectionCircle => 'Circle';
  @override
  String intersectionReason(String key) {
    switch (key) {
      case 'parallelPlanes':
        return 'Planes are parallel (no intersection)';
      case 'coincidentPlanes':
        return 'Planes are coincident';
      case 'lineParallelToPlane':
        return 'Line is parallel to plane (no intersection)';
      case 'lineInPlane':
        return 'Line lies in the plane';
      case 'sphereMissesPlane':
        return 'Plane does not touch the sphere';
      case 'degeneratePlane':
        return 'Degenerate plane (zero normal)';
      case 'parallelLines':
        return 'Lines are parallel (no intersection)';
      case 'coincidentLines':
        return 'Lines are coincident';
      case 'skewLines':
        return 'Lines are skew (do not meet)';
      case 'lineMissesSphere':
        return 'Line does not touch the sphere';
      case 'degenerateLine':
        return 'Degenerate line (zero direction)';
      case 'spheresApart':
        return 'Spheres are too far apart';
      case 'sphereInsideSphere':
        return 'One sphere lies inside the other';
      case 'coincidentSpheres':
        return 'Spheres are identical';
      case 'numericalFailure':
        return 'Numerical edge case (try slightly different values)';
      // P9-A5b: plane × quadric → conic.
      case 'circle':
        return 'Circle';
      case 'ellipse':
        return 'Ellipse';
      case 'parabola':
        return 'Parabola';
      case 'hyperbola':
        return 'Hyperbola';
      case 'degenerateConic':
        return 'Degenerate conic (pair of lines or a point)';
      case 'noConic':
        return 'Plane misses the quadric';
      case 'planeOnQuadric':
        return 'Plane lies on the quadric';
      default:
        return key;
    }
  }

  // -- P9-A5 --
  @override
  String get scene3DAddQuadric => 'Add quadric';
  @override
  String get scene3DEditQuadric => 'Edit quadric';
  @override
  String get scene3DQuadricKind => 'Type';
  @override
  String get scene3DQuadricSemiAxes => 'Semi-axes';
  @override
  String get scene3DQuadricPositiveSemiAxes =>
      'Semi-axes must be positive (a, b, c > 0)';
  @override
  String get quadricKindEllipsoid => 'Ellipsoid';
  @override
  String get quadricKindCone => 'Elliptic cone';
  @override
  String get quadricKindCylinder => 'Elliptic cylinder';
  @override
  String get quadricKindParaboloid => 'Elliptic paraboloid';
  @override
  String get quadricKindHyperboloid1 => 'Hyperboloid (1 sheet)';
  @override
  String get quadricKindHyperboloid2 => 'Hyperboloid (2 sheets)';

  // -- P9-A5c.3 --
  @override
  String get conicOpenIn3DScene => 'Open in 3D Scene';
  @override
  String get conicLiftNotAConic =>
      'Not a conic — nothing to lift. Add quadratic terms first.';

  // -- P9-A6 --
  @override
  String get scene3DAddParametricSurface => 'Add parametric surface';
  @override
  String get scene3DEditParametricSurface => 'Edit parametric surface';
  @override
  String get scene3DAddParametricCurve => 'Add parametric curve';
  @override
  String get scene3DEditParametricCurve => 'Edit parametric curve';
  @override
  String get scene3DParametricSurface => 'Parametric surface';
  @override
  String get scene3DParametricCurve => 'Parametric curve';

  @override
  String get moduleUnitConverterTitle => 'Unit Converter';
  @override
  String get moduleUnitConverterSubtitle =>
      'Convert across length, time, mass, temperature, velocity, angle';
  @override
  String get sectionVariables => 'Variables';
  @override
  String get sectionGraphFunctions => 'Graph Functions';
  @override
  String get sectionMemorySlots => 'Memory Slots';
  @override
  String get funcCtxShowOnGraph => 'Show on graph';
  @override
  String get funcCtxAnalyze => 'Analyze (curve sketching)';
  @override
  String get funcCtxDifferentiate => 'Differentiate';
  @override
  String get funcCtxIntegrate => 'Integrate';
  @override
  String get funcCtxSolve => 'Solve f(x) = 0';
  @override
  String get funcCtxCopy => 'Copy expression';
  @override
  String get funcEditorTitle => 'Function Editor (Y=)';
  @override
  String get funcEditorDone => 'Done';
  @override
  String get funcEditorSelectFirst => 'Please select a function field to edit.';
  @override
  String get funcEditorAnalyzeTooltip => 'Analyze this function';
  @override
  String get funcEditorGraphTooltip => 'Graph this function';
  @override
  String get unitDimLength => 'Length';
  @override
  String get unitDimTime => 'Time';
  @override
  String get unitDimMass => 'Mass';
  @override
  String get unitDimTemperature => 'Temperature';
  @override
  String get unitDimVelocity => 'Velocity';
  @override
  String get unitDimAngle => 'Angle';
  @override
  String get planeAnalysisTitle => 'Plane Analysis';
  @override
  String get planeRepCoordinate => 'Coordinate';
  @override
  String get planeRepParametric => 'Parametric';
  @override
  String get buttonAnalyze => 'Analyze';
  @override
  String get buttonClassify => 'Classify';
  @override
  String get curveAnalysisEnterFunction => 'Enter a function to analyze:';
  @override
  String get curveResultWarnings => 'Warnings';
  @override
  String get curveResultDerivatives => 'Derivatives';
  @override
  String get curveResultKeyPoints => 'Key Points';
  @override
  String get curveResultYIntercept => 'Y-Intercept';
  @override
  String get curveResultRoots => 'Roots';
  @override
  String get curveResultExtrema => 'Extrema (Minima/Maxima)';
  @override
  String get curveResultInflectionPoints => 'Inflection Points';
  @override
  String get curveResultNoExtrema => 'No extrema found.';
  @override
  String get curveResultNoInflection => 'No inflection points found.';
  @override
  String curveAnalysisOfFunction(String function) =>
      'Analysis of f(x) = $function';
  @override
  String curveResultPointPrefix(String point) => 'Point: $point';
  @override
  String get extremumLocalMinimum => 'Local Minimum';
  @override
  String get extremumLocalMaximum => 'Local Maximum';
  @override
  String get extremumCriticalPoint => 'Critical Point';
  @override
  String get extremumInflectionPoint => 'Inflection Point';
  @override
  String get extremumNoCriticalPoints => 'No critical points found';
  @override
  String get extremumConstantConcavity =>
      'Function has constant concavity (f\'\'(x) = 0 everywhere)';
  @override
  String get statisticsTitle => 'Statistics';
  @override
  String get statsTabDescriptive => 'Descriptive';
  @override
  String get statsTabRegression => 'Regression';
  @override
  String get statsTabDistributions => 'Distributions';
  @override
  String get statsTabTests => 'Tests';
  @override
  String get statsDescCount => 'Count';
  @override
  String get statsDescSum => 'Sum';
  @override
  String get statsDescMean => 'Mean';
  @override
  String get statsDescMedian => 'Median';
  @override
  String get statsDescMode => 'Mode';
  @override
  String get statsDescMin => 'Min';
  @override
  String get statsDescMax => 'Max';
  @override
  String get statsDescRange => 'Range';
  @override
  String get statsDescVariance => 'Variance';
  @override
  String get statsDescStddev => 'Std. deviation';
  @override
  String get statsDescQ1 => 'Q1';
  @override
  String get statsDescQ3 => 'Q3';
  @override
  String get statsDescIqr => 'IQR';
  @override
  String get helpGroupProbability => 'Probability';
  @override
  String get helpFnRrefDescription => 'Reduced row echelon form (Gauss-Jordan)';

  @override
  String get settingsTitle => 'Settings';
  @override
  String get settingsNumberFormat => 'Number Display Format';
  @override
  String get settingsNumberFormatAuto => 'Auto (129, 129.5)';
  @override
  String settingsNumberFormatDecimalPlaces(int n) => 'Decimal places: $n';
  @override
  String get settingsAutoBindSolve => 'Auto-bind solve results';
  @override
  String get settingsAutoBindSolveSubtitle =>
      'When on, solve(eq, x) also assigns the solution to x.';
  @override
  String get settingsNumberFormatInteger => 'Integer (129)';
  @override
  String get settingsNumberFormatOneDecimal => 'One Decimal (129.0)';
  @override
  String get settingsNumberFormatTwoDecimal => 'Two Decimals (129.00)';
  @override
  String get settingsLanguage => 'Language';
  @override
  String get settingsLanguageEnglish => 'English';
  @override
  String get settingsLanguageGerman => 'Deutsch';
  @override
  String get settingsLanguageFrench => 'Français';
  @override
  String get settingsLanguageSpanish => 'Español';
  @override
  String get settingsTheme => 'Theme';
  @override
  String get settingsThemeSystem => 'Follow system';
  @override
  String get settingsThemeLight => 'Light';
  @override
  String get settingsThemeDark => 'Dark';
  @override
  String get settingsLayoutTitle => 'Layout';
  @override
  String get settingsLayoutBody =>
      'CrispMath adapts to window width: bottom nav on phones, a side rail on '
      'tablets and desktop. Above ~760 px the calculator keypad drops its tab '
      'bar and shows every function key at once.';

  @override
  String get aboutTitle => 'About CrispMath';
  @override
  String get aboutTagline => 'Symbolic CAS calculator powered by SymEngine';
  @override
  String aboutVersion(String version) => 'Version $version';
  @override
  String get aboutServiceProvider => 'Service provider';
  @override
  String get aboutContact => 'Contact';
  @override
  String get aboutPrivacy => 'Privacy';
  @override
  String get aboutPrivacyText =>
      'CrispMath runs entirely on-device. No calculation, history entry, '
      'or user variable is ever sent to a server. The app does not collect '
      'analytics or contact remote services.';
  @override
  String get aboutDisclaimer => 'Disclaimer';
  @override
  String get aboutDisclaimerText =>
      'CrispMath is provided "as is", without warranty of any kind. The '
      'symbolic engine may return imprecise results for ill-conditioned '
      'numeric inputs or unsupported symbolic constructs. Verify critical '
      'computations independently.';
  @override
  String get aboutLicense => 'License';
  @override
  String get aboutLicenseText =>
      'CrispMath is free software, distributed under the GNU Affero '
      'General Public License version 3 or later, with an App Store '
      'permission. Bundled GMP/MPFR/MPC/FLINT libraries keep their own '
      'LGPL-family licenses; source, build, and relink details are listed '
      'under Open-source licenses.';
  @override
  String get aboutOpenSourceLicenses => 'Open-source licenses';
  @override
  String get settingsAbout => 'About CrispMath';
  @override
  String get matrixDiagnosticsTitle => 'Matrix self-test';
  @override
  String get matrixDiagnosticsSubtitle =>
      'Verify det / inv / transpose / + / * through the native bridge.';
  @override
  String matrixDiagnosticsSummary(int passed, int total) =>
      '$passed of $total checks passed';
  @override
  String get unitConverterTitle => 'Unit converter';
  @override
  String get unitConverterSubtitle =>
      'Length / time / mass / temperature / velocity / angle.';

  @override
  String get selectEquation => 'Select equation or continue typing:';
  @override
  String get continueTyping => 'Continue Typing';
  @override
  String get selectFunction => 'Select function or continue typing:';
  @override
  String get dismissPanel => 'Dismiss this panel';
  @override
  String solveFor(int n) => 'Solve Y$n = 0';
  @override
  String whereY(int n, String func) => 'where Y$n = $func';

  @override
  String get dialogInsert => 'Insert';
  @override
  String get dialogClose => 'Close';
  @override
  String get dialogShowSteps => 'Show steps';
  @override
  String get dialogVariable => 'Variable';
  @override
  String get dialogExpression => 'Expression';
  @override
  String get dialogValue => 'Value';
  @override
  String get dialogFunction => 'Function f(x)';

  @override
  String get integralTitle => 'Integral';
  @override
  String get integralLowerBound => 'Lower bound';
  @override
  String get integralUpperBound => 'Upper bound';
  @override
  String get integralDefinite => 'Definite Integral';
  @override
  String get nthRootTitle => 'Nth Root';
  @override
  String get nthRootBase => 'Base';
  @override
  String get limitTitle => 'Limit';
  @override
  String get limitApproaches => 'Approaches';
  @override
  String get substituteTitle => 'Substitute';
  @override
  String get substituteUseStoredVariable => 'Use a stored variable as value:';

  @override
  String get differentiationStepsTitle => 'Differentiation steps';
  @override
  String differentiationStepsHeader(String variable) =>
      'Differentiating with respect to $variable:';
  @override
  String get solveStepsTitle => 'Solve steps';
  @override
  String get odeStepsTitle => 'ODE solution steps';
  @override
  String get solveStepsEquationLabel => 'Equation or expression';
  @override
  String get solveStepsSolveFor => 'Solve for';
  @override
  String get solveStepsHint => 'e.g. 2x + 3 = 7  or  x^2 - 5x + 6';
  @override
  String solveStepsHeader(String variable) => 'Solving for $variable:';
  @override
  String get integrationStepsTitle => 'Integration steps';
  @override
  String get integrationStepsIntegrandLabel => 'Integrand';
  @override
  String get integrationStepsWrt => 'Integrate with respect to';
  @override
  String get integrationStepsHint => 'e.g. x^2  or  sin(x) + 2x';
  @override
  String integrationStepsHeader(String variable) =>
      'Integrating with respect to $variable:';

  @override
  String get errorSolveFormat =>
      'Error: solve() format is solve(equation, variable)';
  @override
  String get errorInvalidSolve => 'Error: Invalid solve() syntax';
  @override
  String get errorInvalidDiff => 'Error: Invalid d/dx() syntax';
  @override
  String get errorInvalidFactor => 'Error: Invalid factor() syntax';
  @override
  String get errorInvalidExpand => 'Error: Invalid expand() syntax';
  @override
  String get errorInvalidSimplify => 'Error: Invalid simplify() syntax';
  @override
  String get errorGcdArgs => 'Error: gcd() requires exactly 2 arguments';
  @override
  String get errorInvalidGcd => 'Error: Invalid gcd() syntax';
  @override
  String get errorLcmArgs => 'Error: lcm() requires exactly 2 arguments';
  @override
  String get errorInvalidLcm => 'Error: Invalid lcm() syntax';

  @override
  String get errorMissingAns => 'No Ans in memory.';
  @override
  String get errorParse =>
      'Couldn\'t understand the expression. Check for unmatched parentheses, typos, or missing operators.';
  @override
  String get errorUnbalancedParen =>
      'There\'s a closing parenthesis with nothing to close.';
  @override
  String get errorDivisionByZero => 'Division by zero.';
  @override
  String errorUnknownFunction(String name) =>
      '\u0022$name\u0022 isn\'t a function this app knows. Check the spelling.';
  @override
  String errorWrongArity(String name) =>
      '\u0022$name\u0022 was given the wrong number of arguments.';
  @override
  String get errorNativeRequired =>
      'This operation needs the native math library, which isn\'t loaded on this platform.';
  @override
  String get errorNativeRequiredWeb =>
      'Symbolic math (solve, factor, integrate, …) needs the desktop or mobile app — it can\'t run in the browser.';
  @override
  String get webBannerCasLoading =>
      'Loading the in-browser symbolic engine… solve, factor and integrate light up once it finishes.';
  @override
  String get webBannerCasPartial =>
      'The full symbolic CAS — including high-precision and number-theory functions (isprime, factorint, evalf, Bessel) — runs right here in your browser. Only multivariate factoring still needs the desktop or mobile app.';
  @override
  String get webBannerCasUnavailable =>
      'Browser build: symbolic CAS, high-precision and number-theory features need the desktop or mobile app. Statistics, matrices, Sudoku/CSP, units and the calculator all work here.';
  @override
  String get webDownloadApp => 'Get the app';
  @override
  String get errorIntegrateNotImplemented =>
      'Symbolic integration isn\'t available in this build. Use the ∫ button with bounds for a numerical (definite) result.';
  @override
  String get errorMatrixLiteral =>
      'The matrix literal looks malformed. Use the format [a,b; c,d] or build it with the matrix editor.';
  @override
  String get errorInternalMatrixDisposed =>
      'Internal matrix reference is no longer valid. Please run the operation again.';
  @override
  String errorInvalidSyntax(String op) =>
      'The arguments to $op() weren\'t in the expected shape. Check the example in the help / About screen.';

  @override
  String get exportDataTitle => 'Export data';
  @override
  String get exportDataSubtitle =>
      'JSON below contains everything CrispMath has stored on this device — history, variables, graph functions, parameters, settings. Copy it to a notes app or cloud doc before reinstalling.';
  @override
  String get exportDataCopy => 'Copy to clipboard';
  @override
  String get exportDataCopied => 'Copied to clipboard';
  @override
  String get historyEntryCopyResult => 'Copy result';
  @override
  String get historyEntryCopyLatex => 'Copy as LaTeX';
  @override
  String get historyEntryCopyLatexSubtitle =>
      'Paste into a Word/Notion/Markdown editor for typeset math';
  @override
  String get historyEntryReuse => 'Reuse expression';
  @override
  String get historyEntryCopied => 'Copied';

  // -- Round 91: Store result as variable / function --
  @override
  String get storeAsVariable => 'Store result as variable';
  @override
  String get storeAsFunction => 'Store as function';
  @override
  String get storeVariableTitle => 'Save as variable';
  @override
  String get storeFunctionTitle => 'Save as function';
  @override
  String get storeNameLabel => 'Name';
  @override
  String get storeFunctionParamLabel => 'Parameter';
  @override
  String get storeButton => 'Save';
  @override
  String get storeNameReserved => 'Reserved by a built-in';
  @override
  String storeSavedAs(String name) => 'Saved as $name';

  // -- R91b --
  @override
  String storeOverwriteTitle(String name) => 'Overwrite "$name"?';
  @override
  String storeOverwriteCurrent(String existing) => 'Currently: $existing';
  @override
  String get storeOverwriteConfirm => 'Overwrite';

  @override
  String get settingsExportData => 'Export data';
  @override
  String get settingsExportDataSubtitle =>
      'Copy everything stored on this device (history, variables, settings).';
  @override
  String get settingsHelp => 'Help & function reference';
  @override
  String get settingsHelpSubtitle =>
      'Supported functions, matrix syntax, and step-by-step triggers.';

  @override
  String get settingsHighContrast => 'High contrast';
  @override
  String get settingsHighContrastSubtitle =>
      'Stronger colors and borders for accessibility.';
  @override
  String get settingsTextScale => 'Text size';

  @override
  String get settingsShowExactFraction =>
      'Also show exact fractions';
  @override
  String get settingsShowExactFractionSubtitle =>
      'Results are shown as decimals (19/2 = 9.5). Also show the exact fraction underneath.';
  @override
  String get settingsExactIntegerMode => 'Exact integer mode';
  @override
  String get settingsExactIntegerModeSubtitle =>
      'Show full digit string for arbitrary-precision integer results '
      '(e.g. 100! = 158 digits). Off: round to double precision.';
  @override
  String exactIntegerBadge(int digits) => 'Exact integer · $digits digits';
  @override
  String get exactIntegerTapToCopy => 'Tap to copy';

  @override
  String get calculating => 'Calculating…';

  @override
  String get moduleSudokuTitle => 'Sudoku solver';
  @override
  String get moduleSudokuSubtitle =>
      'See how a solver reasons: singles, guesses and backtracking, step by step.';
  @override
  String get sudokuSolveButton => 'Solve';
  @override
  String get sudokuClearCell => 'Clear';
  @override
  String get sudokuClearToStart => 'Reset puzzle';
  @override
  String get sudokuSolvedCorrectly => 'Solved!';
  @override
  String get sudokuFilledWithErrors => 'Has errors';
  @override
  String get sudokuWinOverlayTapHint => 'Tap to dismiss';
  @override
  String get sudokuPresetLabelChooser => 'Puzzle';
  @override
  String get sudokuPresetCustom => 'Custom';
  @override
  String sudokuPresetLabel(String id) {
    switch (id) {
      case 'small4x4Easy':
        return '4×4 easy';
      case 'small4x4Medium':
        return '4×4 medium';
      case 'small4x4Hard':
        return '4×4 hard';
      case 'medium6x6':
        return '6×6 medium';
      case 'eight8x8':
        return '8×8 medium';
      case 'eight8x8X':
        return '8×8 Sudoku-X medium';
      case 'eight8x8Disjoint':
        return '8×8 Disjoint medium';
      case 'eight8x8Killer':
        return '8×8 Killer';
      case 'ten10x10':
        return '10×10 medium';
      case 'twelve12x12':
        return '12×12 medium';
      case 'fifteen15x15':
        return '15×15 medium';
      case 'standard9x9Easy':
        return '9×9 easy';
      case 'standard9x9Medium':
        return '9×9 medium';
      case 'standard9x9Hard':
        return '9×9 hard (AI Escargot)';
      case 'standard9x9XEasy':
        return '9×9 Sudoku-X easy';
      case 'killer4x4':
        return '4×4 Killer';
      case 'killer9x9':
        return '9×9 Killer';
    }
    return id;
  }

  @override
  String get sudokuVisualizerHeader => 'Search visualizer';
  @override
  String get sudokuPlay => 'Play';
  @override
  String get sudokuPause => 'Pause';
  @override
  String get sudokuRestart => 'Restart';
  @override
  String get sudokuSpeedSlow => 'Slow';
  @override
  String get sudokuSpeedMed => 'Med';
  @override
  String get sudokuSpeedFast => 'Fast';
  @override
  String get sudokuGenerateButton => 'Generate';
  @override
  String get sudokuGenerateSection => 'New puzzle difficulty';
  @override
  String get sudokuDifficultyEasy => 'Easy';
  @override
  String get sudokuDifficultyMedium => 'Medium';
  @override
  String get sudokuDifficultyHard => 'Hard';
  @override
  String get sudokuVariantRegular => 'Regular';
  @override
  String get sudokuVariantX => 'Sudoku-X';
  @override
  String get sudokuVariantKiller => 'Killer';
  @override
  String get sudokuVariantDisjoint => 'Disjoint';
  @override
  String get sudokuCheckUnique => 'Check uniqueness';
  @override
  String get sudokuUniqueSolution => 'Unique solution';
  @override
  String get sudokuMultipleSolutions => 'Multiple solutions';
  @override
  String get sudokuShowHints => 'Show hints';
  @override
  String get sudokuShowHintsSubtitle =>
      'Pencil-marks: for each empty cell, the digits not yet '
      'eliminated by row, column, box, or diagonal.';
  @override
  String get sudokuHintLevelOff => 'Off';
  @override
  String get sudokuHintLevelBasic => 'Basic';
  @override
  String get sudokuHintLevelAdvanced => 'Advanced';
  @override
  String get sudokuHintLevelAdvancedHelp =>
      'Advanced runs the full CSP solver on every candidate, so it '
      'also catches hidden singles and naked pairs. Slower — takes '
      'a few seconds on hard 9×9 puzzles.';
  @override
  String get sudokuHintLevelComputing => 'Computing advanced hints…';

  @override
  String sudokuConstraintRow(int row) => 'Row $row';
  @override
  String sudokuConstraintCol(int col) => 'Column $col';
  @override
  String sudokuConstraintBox(int box) => 'Box $box';
  @override
  String sudokuConstraintCage(int cage, int sum) => 'Cage $cage (sum $sum)';
  @override
  String get sudokuConstraintMainDiagonal => 'Main diagonal';
  @override
  String get sudokuConstraintAntiDiagonal => 'Anti diagonal';
  @override
  String sudokuConstraintDisjointGroup(int group) => 'Disjoint group $group';
  @override
  String sudokuStepStart(int clues) =>
      'Start: $clues clues. Pencil marks show the digits each empty cell '
      'can still take: a digit is ruled out when a peer in the same row, '
      'column or box already holds it.';
  @override
  String sudokuStepNakedSingle(String cell, int value, int eliminated) =>
      'Naked single: $cell has only one candidate left, so it must be '
      '$value. That removes $value from $eliminated peer cells.';
  @override
  String sudokuStepHiddenSingle(String unit, int value, String cell) =>
      'Hidden single: in $unit, $value fits only in $cell, so it goes '
      'there even though $cell has other candidates.';
  @override
  String sudokuStepGuess(String cell, int value, String alternatives) =>
      'No logical step applies, so the solver guesses. It picks $cell '
      'because it has the fewest candidates and tries $value, keeping '
      '$alternatives for backtracking.';
  @override
  String sudokuStepLastOption(String cell, int value) =>
      'Last option: every other choice at $cell failed, so it must be '
      '$value (given the earlier guesses).';
  @override
  String sudokuStepContradictionCell(String cell) =>
      'Contradiction: $cell has no candidates left.';
  @override
  String sudokuStepContradictionUnit(String unit, int value) =>
      'Contradiction: $value has no place left in $unit.';
  @override
  String sudokuStepBacktrack(String cell) =>
      'Backtrack: undo everything since the guess at $cell and try its '
      'next option.';
  @override
  String get sudokuStepSolved =>
      'Solved: every cell is filled and every rule holds.';
  @override
  String sudokuExplainStats(
          int naked, int hidden, int guesses, int backtracks, int depth) =>
      [
        if (naked > 0) 'Naked singles $naked',
        if (hidden > 0) 'Hidden singles $hidden',
        if (guesses > 0) 'Guesses $guesses',
        if (backtracks > 0) 'Backtracks $backtracks',
        if (depth > 0) 'Max depth $depth',
      ].join(' · ');
  @override
  String get sudokuExplainLogicOnly =>
      'Solved by logic alone: no guessing needed.';
  @override
  String sudokuExplainTruncated(int shown) =>
      'Showing the first $shown steps; the solve continued past them.';
  @override
  String sudokuStepCage(int sum, int size, String combos, int removed) =>
      'Cage sum: $size cells must add up to $sum with different digits. '
      'The possible digit sets are $combos. Considering their valid '
      'assignments to its cells removes $removed candidates that cannot '
      'be used in their respective cells.';
  @override
  String sudokuStepLocked(int digit, String unit, String other, int removed) =>
      'Locked candidates: in $unit, $digit can only go in cells that also '
      'belong to $other. Wherever it lands, $other gets its $digit there, '
      'so $digit is removed from $removed other cells of $other.';
  @override
  String sudokuStepNakedSubset(
          int size, String cells, String digits, String unit, int removed) =>
      'Naked ${size == 2 ? 'pair' : 'triple'}: $cells in $unit hold only '
      '$digits between them, so those digits must go in these $size cells '
      'and are removed from the rest of $unit ($removed candidates).';
  @override
  String sudokuStepHiddenSubset(
          int size, String digits, String unit, String cells, int removed) =>
      'Hidden ${size == 2 ? 'pair' : 'triple'}: in $unit, $digits fit only '
      'in $cells, so those cells must take them and drop their other '
      'candidates ($removed removed).';
  @override
  String sudokuStepContradictionCage(int sum) =>
      'Contradiction: the cage of $sum can no longer reach its sum.';
  @override
  String sudokuExplainEliminations(
          int cages, int locked, int nakedSubsets, int hiddenSubsets) =>
      [
        if (cages > 0) 'Cage sums $cages',
        if (locked > 0) 'Locked candidates $locked',
        if (nakedSubsets > 0) 'Naked pairs/triples $nakedSubsets',
        if (hiddenSubsets > 0) 'Hidden pairs/triples $hiddenSubsets',
      ].join(' · ');
  @override
  String get sudokuSearchTreeTitle => 'Search tree';
  @override
  String get sudokuSearchTreeHint =>
      'Each dot is a guess, children are guesses made after it. Red dots '
      'led to a contradiction, green ones are the path to the solution. '
      'The ringed dot is the guess in effect at the current step.';
  @override
  String sudokuSearchTreeTruncated(int shown) =>
      'Showing the first $shown guesses.';
  @override
  String get sudokuStepPrevious => 'Previous step';
  @override
  String get sudokuStepNext => 'Next step';
  @override
  String get sudokuEnterClues =>
      'Enter clues: tap a cell, then a digit, to analyse your own puzzle.';
  @override
  String get sudokuConstraintStartingPosition => 'Starting position';
  @override
  String sudokuError(SudokuError error) => switch (error.kind) {
        SudokuErrorKind.unsupported => 'Unsupported Sudoku puzzle.',
        SudokuErrorKind.clashingClues => 'The clues already break a rule.',
        SudokuErrorKind.noSolution => 'No solution exists for this puzzle.',
        SudokuErrorKind.placementLimit =>
          'Search stopped after ${error.limit} placements.',
        SudokuErrorKind.cageWorkLimit =>
          'Search stopped after reaching the cage work limit '
              '(${error.limit}).',
      };

  @override
  String get moduleConstraintsTitle => 'Constraint problems';
  @override
  String get moduleConstraintsSubtitle =>
      'Diophantine equations and cryptarithms — find integer '
      'solutions and digit assignments.';
  @override
  String get constraintsTabDiophantine => 'Diophantine';
  @override
  String get constraintsTabCryptarithm => 'Cryptarithm';
  @override
  String get constraintsTabDsl => 'Free-form';
  @override
  String get constraintsTabFlatZinc => 'FlatZinc';
  @override
  String get constraintsTabMagicSquare => 'Magic square';
  @override
  String get constraintsMagicIntro =>
      'Generate a magic square of the chosen order: the numbers 1..N² '
      'arranged so every row, column, and both diagonals share the same '
      'sum. Each "Generate" shows a different orientation of a solution.';
  @override
  String get constraintsMagicSize => 'Size';
  @override
  String constraintsMagicConstant(int m) => 'Magic constant: $m';
  @override
  String constraintsSoftScore(int satisfied, int total) =>
      'Satisfaction: $satisfied / $total';
  @override
  String get constraintsMagicGenerate => 'Generate';
  @override
  String get constraintsMagicHint =>
      'Every row, column, and diagonal sums to the magic constant.';
  @override
  String get constraintsDslIntro =>
      'Declare variables with `vars: x, y in 1..9`, '
      'use `allDifferent(x, y, z)` for distinctness, and '
      'write any other line as a constraint (e.g. `x + 2*y == 10`).';
  @override
  String get constraintsDslInputLabel => 'Constraint program';
  @override
  String get constraintsDslExamplesButton => 'Examples';
  @override
  String get constraintsDslExamplesTooltip => 'Load a pre-built example';
  @override
  String constraintsDslExampleTitle(String id) {
    switch (id) {
      case 'magicSum':
        return '3-digit magic sum';
      case 'magicSquare3':
        return '3×3 magic square';
      case 'magicSquare4':
        return '4×4 magic square (constant 34)';
      case 'mapColoring':
        return 'Map coloring (K4)';
      case 'mapColoringAustralia':
        return 'Map coloring — Australia (3 colors)';
      case 'mapColoringGermany':
        return 'Map coloring — Germany (needs 4 colors)';
      case 'orderedTriples':
        return 'Ordered triples summing to 20';
      case 'equalSumSplit':
        return 'Equal-sum split (set partitioning)';
      case 'coinChangeMin':
        return 'Coin change (minimize coins)';
      case 'knapsack':
        return '0/1 knapsack (maximize value)';
      case 'productionPlanning':
        return 'Production planning (maximize profit)';
      case 'assignmentMinCost':
        return 'Assignment problem (minimize cost)';
      case 'transportation':
        return 'Transportation (min-cost shipping)';
      case 'schedulingMakespan':
        return 'Scheduling — minimize makespan';
      case 'cumulativeScheduling':
        return 'Cumulative scheduling — capacity 2';
      case 'rcpsp':
        return 'RCPSP — crew + equipment';
      case 'logicGrid':
        return 'Logic grid — deduction riddle';
      case 'nurseRostering':
        return 'Nurse rostering (shift patterns)';
      case 'chromaticNumber':
        return 'Chromatic number (fewest colors)';
      case 'menuPairing':
        return 'Menu pairings (table constraint)';
      case 'packing':
        return '2D packing (diffN layout)';
      case 'deliveryRoute':
        return 'Delivery route (circuit / TSP)';
      case 'shiftPrefs':
        return 'Shift preferences (soft / MaxCSP)';
      case 'committee':
        return 'Committee selection (set variables)';
    }
    return id;
  }

  @override
  String get constraintsFlatZincIntro =>
      'Paste a FlatZinc model (typically produced by mzn2fzn from a '
      'MiniZinc source). The solver returns standard FlatZinc output: '
      '`name = value;` lines per `:: output_var` annotation, ended by '
      '`----------`, with `==========` after the last solution.';
  @override
  String get constraintsFlatZincInputLabel => 'FlatZinc source';
  @override
  String get constraintsFlatZincAllSolutions => 'All solutions';
  @override
  String get constraintsFlatZincFirstSolution => 'First solution';
  @override
  String get constraintsFlatZincExhaustiveOne => '1 solution (exhaustive)';
  @override
  String constraintsFlatZincExhaustiveN(int n) => '$n solutions (exhaustive)';
  @override
  String get constraintsFlatZincUnsatisfiable => 'Unsatisfiable';
  @override
  String constraintsFlatZincExampleTitle(String id) {
    switch (id) {
      case 'nqueens4':
        return '4-Queens';
      case 'binPacking':
        return 'Bin packing (3 items, 2 bins)';
    }
    return id;
  }

  @override
  String get constraintsExplainFailure => 'Explain failure';
  @override
  String get constraintsExplainHeader => 'Minimal conflict (QuickXplain)';
  @override
  String get constraintsExplainSatisfiable =>
      'No conflict — the model is actually satisfiable.';
  @override
  String constraintsExplainEntryCount(int n) =>
      n == 1 ? '1 conflicting constraint' : '$n conflicting constraints';
  @override
  String constraintsExplainAltHeader(int n) =>
      'Another minimal conflict ($n constraints)';
  @override
  String get constraintsExportFlatZinc => 'Export as FlatZinc';
  @override
  String get constraintsVisualizeButton => 'Visualize';
  @override
  String get constraintsCompareStrategies => 'Compare strategies';
  @override
  String get constraintsStrategyHeader => 'Search-strategy comparison';
  @override
  String get constraintsStrategyCol => 'Strategy';
  @override
  String get constraintsStrategyDecisions => 'Decisions';
  @override
  String get constraintsStrategyBacktracks => 'Backtracks';
  @override
  String get constraintsStrategyPropagations => 'Propagations';
  @override
  String get constraintsStrategyIterations => 'Iterations';
  @override
  String get constraintsStrategyTime => 'Time';
  @override
  String get constraintsStructureButton => 'Show structure';
  @override
  String constraintsStructureHeader(int vars, int constraints) =>
      'Constraint network · $vars variables · $constraints constraints';
  @override
  String constraintsColorGraphHeader(int nodes, int colours) =>
      'Graph colouring · $nodes nodes · $colours colours';
  @override
  String get constraintsTraceHeader => 'Propagation trace';
  @override
  String get constraintsTraceIntro =>
      'Step through the solver: each decision, each value pruned from a '
      'domain by a constraint, every dead-end and backtrack.';
  @override
  String constraintsTraceStepCounter(int current, int total) =>
      'Step $current / $total';
  @override
  String get constraintsTraceInitial => 'Initial domains — before any search.';
  @override
  String constraintsTraceDecision(String variable, int value) =>
      'Decision: try $variable = $value';
  @override
  String constraintsTracePrune(String values, String variable, String cause) =>
      'Prune $values from $variable — $cause';
  @override
  String constraintsTraceWipeout(String variable, String cause) =>
      'Dead end: $variable’s domain emptied — $cause';
  @override
  String get constraintsTraceBacktrack =>
      'Backtrack — undo the last decision and try another value.';
  @override
  String constraintsTraceBackjump(int from, int to) =>
      'Backjump from depth $from to depth $to.';
  @override
  String get constraintsTraceSolutionStep =>
      'Solution — all variables assigned.';
  @override
  String constraintsTraceStats(
          int decisions, int prunes, int wipeouts, int backtracks) =>
      'Decisions $decisions · Prunes $prunes · Dead ends $wipeouts · '
      'Backtracks $backtracks';
  @override
  String get constraintsTracePropagationOnly =>
      'Solved by propagation alone: no decision needed.';
  @override
  String get constraintsTraceTopConstraints =>
      'Constraints that removed the most values:';
  @override
  String constraintsTraceConstraintWork(
          int removed, int prunes, int wipeouts) =>
      '$removed values · $prunes prunes · $wipeouts dead ends';
  @override
  String get constraintsMagicVisualizeHint =>
      'Visualize replays how the solver builds a square: which cell it '
      'decides, which sums and the all-different rule prune, and where it '
      'backtracks. Available for 3×3 and 4×4.';
  @override
  String get constraintsTraceSolved => 'Solved';
  @override
  String get constraintsTraceUnsat => 'No solution — search space exhausted';
  @override
  String constraintsTraceTruncatedNote(int n) =>
      'Trace capped at $n steps — replay is a partial prefix.';
  @override
  String get constraintsTraceObjectiveNote =>
      'Showing the feasibility search; the objective is ignored.';
  @override
  String get constraintsTracePlay => 'Play';
  @override
  String get constraintsTracePause => 'Pause';
  @override
  String get constraintsTraceRestart => 'Restart';
  @override
  String get constraintsTraceStepBack => 'Step back';
  @override
  String get constraintsTraceStepForward => 'Step forward';
  @override
  String get constraintsExportedHeader => 'FlatZinc translation';

  @override
  String get constraintsDiophantineIntro =>
      'Declare bounded integer variables, list the constraints they '
      'must satisfy, and the solver enumerates all integer solutions '
      '(capped at 100).';
  @override
  String get constraintsCryptarithmIntro =>
      'Enter a puzzle of the form `WORD1 + WORD2 = WORD3` (or `−` '
      'instead of `+`). Each letter is a digit 0..9; leading digits '
      'are non-zero; all letters carry distinct digits.';
  @override
  String get constraintsVariablesLabel => 'Variables';
  @override
  String get constraintsVariablesHint =>
      'One per line, format: name in min..max';
  @override
  String get constraintsConstraintsLabel => 'Constraints';
  @override
  String get constraintsConstraintsHint =>
      'One per line. Comparisons, arithmetic, in/not-in sets all '
      'supported.';
  @override
  String get constraintsCryptarithmInputLabel => 'Puzzle';
  @override
  String get constraintsSolveButton => 'Solve';
  @override
  String get constraintsCancelButton => 'Cancel';
  @override
  String get constraintsBadVarLine =>
      'Could not parse variable line. Expected `name in min..max`';
  @override
  String get constraintsNoSolutions => 'No solutions.';
  @override
  String get constraintsCryptarithmFoundHeader => 'Digit assignment';
  @override
  String constraintsSolutionsHeader(int n) =>
      n == 1 ? '1 solution' : '$n solutions';
  @override
  String constraintsTruncatedHeader(int n) =>
      'Showing first $n solutions (more exist)';
  @override
  String get constraintsCopyResult => 'Copy solutions';
  @override
  String get constraintsCopiedToast => 'Copied to clipboard.';
  @override
  String constraintsOptimalHeader(num objective) =>
      'Optimal: objective = $objective';

  @override
  String get clearSearchTooltip => 'Clear search';
  @override
  String get clearFunctionSlotTooltip => 'Clear function slot';
  @override
  String get deleteMemorySlotTooltip => 'Delete memory slot';

  @override
  String get helpModeEnableTooltip =>
      'Help mode: tap any control for an explanation';
  @override
  String get helpModeDisableTooltip => 'Exit help mode';
  @override
  String get keypadHelpLearnMore => 'Learn more';
  @override
  String get historyHelpTitle => 'How this was computed';
  @override
  String historyHelpComputedVia(String engine) => 'Computed via $engine';
  @override
  String get historyHelpDirectEvaluation =>
      'Direct numerical evaluation — no symbolic call involved.';
  @override
  String get historyHelpShowSteps => 'Show steps';

  @override
  String get moduleHelpTooltip => 'What does this module do?';
  @override
  String moduleHelpTitle(ModuleHelpKind kind) {
    switch (kind) {
      case ModuleHelpKind.curveSketching:
        return 'Curve sketching';
      case ModuleHelpKind.planes:
        return 'Plane analysis';
      case ModuleHelpKind.conicSections:
        return 'Conic sections';
      case ModuleHelpKind.statistics:
        return 'Statistics';
      case ModuleHelpKind.graphing3D:
        return '3D graphing';
      case ModuleHelpKind.scene3D:
        return '3D scene';
      case ModuleHelpKind.constraints:
        return 'Constraints';
      case ModuleHelpKind.sudoku:
        return 'Sudoku';
      case ModuleHelpKind.notepad:
        return 'Notepad';
    }
  }

  @override
  String moduleHelpDescription(ModuleHelpKind kind) {
    switch (kind) {
      case ModuleHelpKind.curveSketching:
        return 'Full analysis of a single-variable function f(x): '
            'domain, intercepts, derivative + critical points, extrema, '
            'inflection points, asymptotes, and a sketch. Enter the '
            'function in the input box; results appear on tap.';
      case ModuleHelpKind.planes:
        return 'Analyze 3D planes given in coordinate form '
            '(ax + by + cz = d) or parametric form (point + two direction '
            'vectors). Computes the normal vector, intersections with the '
            'coordinate axes, and pairwise plane relationships.';
      case ModuleHelpKind.conicSections:
        return 'Classify a general conic Ax² + Bxy + Cy² + Dx + Ey + F = 0 '
            'as ellipse, hyperbola, parabola, or degenerate, and extract '
            'centre, axes, foci, and eccentricity. Uses the discriminant '
            'B² − 4AC for the classification.';
      case ModuleHelpKind.statistics:
        return 'Descriptive statistics (mean, median, variance, …), '
            'linear regression with R² and residuals, the normal and '
            'binomial distributions with PDF / CDF / quantile lookups, '
            'and hypothesis tests: Welch t, paired t, one-way ANOVA, '
            'chi-square goodness-of-fit and independence, Fisher exact, '
            'Wilcoxon signed-rank, and the sign test. Tests report the '
            'statistic, the p-value, and (where applicable) a confidence '
            'interval at the chosen α.';
      case ModuleHelpKind.graphing3D:
        return 'Plot z = f(x, y) as a rotatable wireframe surface. '
            'Drag to rotate; pinch / scroll to zoom. The resample action '
            'rebuilds the mesh at the current zoom level so detail '
            'tracks the camera distance.';
      case ModuleHelpKind.scene3D:
        return 'Render multiple 3D objects together — planes, lines, '
            'spheres, and quadrics — in a shared scene. Useful for '
            'visualizing intersections (e.g. two planes meeting along a '
            'line) and for building up geometric arguments piece by piece.';
      case ModuleHelpKind.constraints:
        return 'Solve combinatorial problems: Diophantine equations '
            '(integer solutions to ax + by = c), cryptarithms '
            '(SEND + MORE = MONEY style digit assignments), a small DSL '
            'for finite-domain constraint programming (`allDifferent`, '
            '`noOverlap`, `cumulative`, `minimize` / `maximize`), and a '
            'FlatZinc compatibility tab for problems written in the '
            'MiniZinc intermediate format.';
      case ModuleHelpKind.sudoku:
        return 'Solve 4×4 and 9×9 puzzles including X (diagonal), '
            'Killer (cage-sum), and Disjoint-Groups variants. The '
            'step-by-step solver shows the search tree so you can see '
            'how the engine narrows the candidates. Hint levels expose '
            'either the next-cell answer or a logical reason for it.';
      case ModuleHelpKind.notepad:
        return 'A multi-document scratchpad where every line is a live formula, recomputed as you type. Beyond ordinary math it supports directives: `use <doc>` imports another document\'s variables; `fzn:` solves an inline FlatZinc model; and `Ans in <unit>` reuses the previous line\'s result, optionally converting units. Export to LaTeX or Markdown.';
    }
  }

  @override
  String get workedExamplesTitle => 'Worked examples';
  @override
  String get workedExamplesSearchHint => 'Search examples…';
  @override
  String get workedExamplesEmpty => 'No examples match this filter.';
  @override
  String get workedExamplesCopy => 'Copy expression';
  @override
  String get workedExamplesCopied =>
      'Copied to clipboard. Paste into the calculator to try it.';
  @override
  String get workedExamplesInsert => 'Insert into calculator';
  @override
  String get workedExamplesCatAll => 'All';
  @override
  String get workedExamplesCatCalculus => 'Calculus';
  @override
  String get workedExamplesCatAlgebra => 'Algebra';
  @override
  String get workedExamplesCatLinearAlgebra => 'Linear algebra';
  @override
  String get workedExamplesCatNumberTheory => 'Number theory';
  @override
  String get workedExamplesCatStatistics => 'Statistics';
  @override
  String get workedExamplesCatUnits => 'Units';
  @override
  String get workedExamplesCatConstraints => 'Constraints';
  @override
  String? workedExampleTitle(String id) {
    // The English catalog has the canonical titles; the
    // fallback-to-catalog path in the dialog uses these directly.
    // Returning null for every id keeps EN behavior identical to V1.
    return null;
  }

  @override
  String? workedExampleDescription(String id) => null;
  // Round 100: EN returns null for both — the catalog holds the
  // canonical English prose and the dialog falls back to it.
  @override
  String? functionRefDescription(String id) => null;
  @override
  String? functionRefExampleHint(String id, int index) => null;
  @override
  String get settingsWorkedExamples => 'Worked examples library';
  @override
  String get settingsWorkedExamplesSubtitle =>
      'Now also reachable from the open-book icon at the top of the '
      'Calculator and Notepad screens. Tap here for the full library.';
  @override
  String get functionRefTitle => 'Function reference';
  @override
  String get functionRefSearchHint => 'Search functions…';
  @override
  String get functionRefEmpty => 'No functions match this filter.';
  @override
  String get functionRefSeeAlso => 'See also:';
  @override
  String get functionRefTryInCalculator => 'Try in Calculator';
  @override
  String get functionRefOpenModule => 'Open module';
  @override
  String get functionRefSeeWorkedExample => 'See worked example';
  @override
  String get functionRefCatCas => 'CAS';
  @override
  String get functionRefCatNumberTheory => 'Number theory';
  @override
  String get functionRefCatPrecision => 'Precision';
  @override
  String get functionRefCatMatrix => 'Matrix';
  @override
  String get functionRefCatGraphing => 'Graphing';
  @override
  String get functionRefCatStatistics => 'Statistics';
  @override
  String get functionRefCatConstraints => 'Constraints';
  @override
  String get functionRefCatSudoku => 'Sudoku';
  @override
  String get functionRefCatUnits => 'Units';
  @override
  String get functionRefCatLogic => 'Logic';
  @override
  String get settingsFunctionRef => 'Function reference';
  @override
  String get settingsFunctionRefSubtitle =>
      'Browse every CrispMath function: signature, examples, related '
      'functions, and a paste-into-calculator shortcut.';

  @override
  String get importDataTitle => 'Import data';
  @override
  String get importDataSubtitle =>
      'Paste a JSON payload from a previous Export data run to restore '
      'your history, variables, functions, and settings.';
  @override
  String get importDataWarning =>
      'This overwrites your current history, variables, and graph '
      'functions. There is no undo — copy your current state first if '
      'you want to keep it.';
  @override
  String get importDataApply => 'Apply';
  @override
  String get importDataEmpty => 'Paste a JSON payload to import.';
  @override
  String get importDataNotObject =>
      'The payload must be a JSON object (starts with `{`).';
  @override
  String get importDataApplied => 'Imported';
  @override
  String get settingsImportData => 'Import data';
  @override
  String get settingsImportDataSubtitle =>
      'Paste a JSON payload from a previous export to restore.';

  @override
  String get userFunctionsTitle => 'User-defined functions';
  @override
  String get userFunctionsHelp =>
      'Define a function once, call it from any expression. e.g. '
      '`f(x) = x^2 + 1`, then `f(3) + 1` evaluates to 11. Composition '
      '`g(f(x))` works as long as both are defined.';
  @override
  String get userFunctionsEmpty =>
      'No user-defined functions yet. Tap Add to create your first.';
  @override
  String get userFunctionsAdd => 'Add';
  @override
  String get userFunctionsEdit => 'Edit';
  @override
  String get userFunctionsDelete => 'Delete';
  @override
  String get userFunctionsName => 'Name';
  @override
  String get userFunctionsNameHelp =>
      'Single lowercase letter (a..z) that won\'t collide with built-ins.';
  @override
  String get userFunctionsNameRequired => 'Required';
  @override
  String get userFunctionsNameInvalid =>
      'Must be a single lowercase letter (a..z).';
  @override
  String get userFunctionsParam => 'Parameter';
  @override
  String get userFunctionsBody => 'Body';
  @override
  String get userFunctionsBodyRequired => 'Function body required';
  @override
  String get settingsUserFunctions => 'User-defined functions';
  @override
  String get settingsUserFunctionsSubtitle =>
      'Define named functions like f(x) = x^2 + 1 and reuse them in any '
      'expression.';

  @override
  String get onboardingSkip => 'Skip';
  @override
  String get onboardingNext => 'Next';
  @override
  String get onboardingDone => 'Got it';
  @override
  String onboardingPage(int current, int total) => '$current / $total';
  @override
  String get onboardingKeypadTitle => 'Tabbed keypad';
  @override
  String get onboardingKeypadBody =>
      'Switch between Num, Trig, CAS, and Advanced tabs to find the '
      'operation you need. On larger windows every key fits on one '
      'screen — no tabs needed.';
  @override
  String get onboardingHistoryTitle => 'Scroll your history';
  @override
  String get onboardingHistoryBody =>
      'Every calculation is saved. Scroll up to revisit, long-press to '
      'copy or reuse, tap the search icon to filter.';
  @override
  String get onboardingFunctionsTitle => 'Pick a function';
  @override
  String get onboardingFunctionsBody =>
      'The ∫⌄, d/dx⌄, and solve⌄ buttons open step-by-step pickers '
      'that walk you through the answer one rule at a time.';
  @override
  String get onboardingAnalysisTitle => 'Analysis hub';
  @override
  String get onboardingAnalysisBody =>
      'Curve sketching, planes, conics, 3D plotting, statistics, and '
      'the unit converter all live in the Analysis tab.';
  @override
  String get onboardingNotepadTitle => 'Notepad';
  @override
  String get onboardingNotepadBody =>
      'Type math like a document — one expression per line, results '
      'in the right column. Define variables (tax = 0.085), reference '
      'earlier lines, and watch everything update live as you edit.';
  @override
  String get onboardingWorksheetTitle =>
      'A calculator that remembers';
  @override
  String get onboardingWorksheetBody =>
      'Start with a worksheet: a = 3, f(x) = x² + a, f(4). Change a and every result and the linked graph recalculate. Save a checkpoint, compare, restore, and export the whole session.';
  @override
  String get onboardingTryWorksheet =>
      'Try a live worksheet';
  @override
  String get analysisLabsTitle =>
      'Labs';
  @override
  String get analysisLabsSubtitle =>
      'Constraint problems, Sudoku solver and the 3D scene composer';
  @override
  String get aboutOurApps =>
      'Our apps';
  @override
  String get aboutOurAppsIntro =>
      'More apps by the same developer. Apps in TestFlight are free betas: the link installs Apple\'s TestFlight first.';
  @override
  String get aboutAppStore =>
      'App Store';
  @override
  String get aboutMacAppStore =>
      'Mac App Store';
  @override
  String get aboutTestFlight =>
      'TestFlight';
  @override
  String get aboutComingSoon =>
      'Coming soon';
  @override
  String get aboutThisApp =>
      'this app';
  @override
  String get settingsReplayTour => 'Replay onboarding tour';
  @override
  String get settingsReplayTourSubtitle =>
      'Show the first-launch tour again next time you open the app.';

  @override
  String get helpTitle => 'Help';
  @override
  String get helpFunctionsHeading => 'Supported functions';
  @override
  String get helpMatrixHeading => 'Matrix syntax';
  @override
  String get helpStepsHeading => 'Step-by-step solutions';
  @override
  String get helpMatrixBody =>
      'Type matrices with rows separated by `;` and cells by `,`:\n\n    [1, 2; 3, 4]\n\nThe calculator converts this to `Matrix([[1, 2], [3, 4]])` internally. Operations: det, inv, transpose, rref, +, -, *.';
  @override
  String get helpStepsBody =>
      'Three keypad buttons in the CAS tab open step-by-step traces:\n\n  • d/dx⌄ for differentiation steps\n  • solve⌄ for equation solving\n  • ∫⌄ for indefinite integration\n\nEach shows the rule applied at every step plus a final answer.';

  @override
  String get constantsTitle => 'Constants reference';
  @override
  String get constantsSearchHint => 'Search by symbol, name, or unit…';
  @override
  String get constantsNoMatches => 'No constants match this filter.';
  @override
  String get constantsAllCategory => 'All';
  @override
  String get constantsCategoryMathematical => 'Mathematical';
  @override
  String get constantsCategoryPhysical => 'Physical';
  @override
  String get constantsCategoryChemistry => 'Chemistry';
  @override
  String get constantsCategoryAstronomy => 'Astronomy';
  @override
  String get constantsCopyValue => 'Copy value';
  @override
  String constantsCopiedToast(String symbol) => 'Copied $symbol to clipboard';
  @override
  String get settingsConstants => 'Constants reference';
  @override
  String get settingsConstantsSubtitle =>
      'Physical, mathematical, chemistry, and astronomy constants.';

  @override
  String get tabNum => 'Num';
  @override
  String get tabTrig => 'Trig';
  @override
  String get tabCas => 'CAS';
  @override
  String get tabAdvanced => 'Advanced';
  @override
  String get tabVars => 'Variables';
  @override
  String get tabBasic => 'Basic';
  @override
  String get tabSymbolic => 'Symbolic';

  @override
  String? stepNote(StepNote note) {
    final p = note.params;
    switch (note.key) {
      case 'startEquation':
        return 'Start with the equation as given.';
      case 'moveRightSideOver':
        return 'Subtracting the right side from both sides puts the '
            'equation in standard form `expression = 0`, which lets us '
            'apply the linear or quadratic solver.';
      case 'noEqualsSign':
        return 'No `=` in input; treating as ${p['body']} = 0.';
      case 'doesNotDependOn':
        return 'The equation does not depend on ${p['var']}.';
      case 'solveFallthroughSymbolic':
        return 'Not a standard linear or quadratic form — handing off '
            'to the symbolic solver for the answer.';
      case 'linearIdentifyCoefs':
        return 'Pick off the leading coefficient and the constant term — '
            'this is a linear equation.';
      case 'moveConstant':
        return 'Move the constant to the other side.';
      case 'divideByCoef':
        return 'Divide both sides by the leading coefficient to isolate '
            '${p['var']}.';
      case 'quadraticIdentifyCoefs':
        return 'Read the three coefficients off the polynomial. We pull '
            'a from the second derivative ÷ 2, b from the first derivative '
            'at ${p['var']} = 0, and c from the polynomial at ${p['var']} = 0.';
      case 'discriminant':
        return 'The discriminant tells us how many real roots: positive → '
            'two distinct real roots; zero → one double root; negative → '
            'two complex conjugate roots.';
      case 'quadFormulaApply':
        return 'Plug a, b, and Δ into the quadratic formula. The `±` gives '
            'both roots in one step.';
      case 'integralPullMinusOut':
        return 'Pull the leading minus sign out of the integral; the rest '
            'is just ∫f.';
      case 'exprDoesNotDependOn':
        return '${p['expr']} does not depend on ${p['var']}.';
      case 'integralIdentityPower1':
        return 'The power rule for n=1: bump the exponent up to 2 and '
            'divide by the new exponent.';
      case 'integralLinearity':
        return 'Integration is linear: the integral of a sum is the sum of '
            'the integrals.';
      case 'integralPullConstantOut':
        return 'Pull `${p['const']}` outside the integral — constants '
            'multiply through.';
      case 'integralReciprocalLog':
        return 'The integral of 1/${p['var']} is the natural log of its '
            'absolute value.';
      case 'integralPowerRule':
        return 'Bump the exponent up by 1 and divide by the new exponent. '
            'Works for any constant n ≠ −1.';
      case 'uSubLinear':
        return 'Let u = ${p['u']}; then du = (${p['slope']})·d${p['var']}.';
      case 'integralStandardAntideriv':
        return 'Use the standard antiderivative for ${p['fn']}.';
      case 'uSubLinearFn':
        return 'Let u = ${p['u']}; then du = (${p['slope']})·d${p['var']}. '
            'The antiderivative of ${p['fn']} is the standard form, '
            'evaluated at u and divided by the slope.';
      case 'ibpLnX':
        final v = p['var']!;
        return 'Let u = ln($v), dv = d$v. Then du = (1/$v)·d$v and v = $v, '
            'so ∫u·dv = u·v − ∫v·du = $v·ln($v) − ∫1 d$v.';
      case 'ibpXTimesF':
        return 'Let u = ${p['var']} (so du = d${p['var']}) and '
            'dv = ${p['right']}·d${p['var']}, giving v = ${p['v']}.';
      case 'ibpRepeated':
        return 'Let u = ${p['u']} and dv = ${p['right']}·d${p['var']}. '
            'Then du = ${p['n']}·… (one lower power of ${p['var']}) and '
            'v = ${p['v']}, so the new integrand drops a power of '
            '${p['var']} — recursing.';
      case 'uSubNonlinear':
        return 'Let u = ${p['u']}; then du = (${p['du']})·d${p['var']}. '
            'The integrand has the form f(u)·du, so substitution turns '
            'it into ∫f(u) du = standard antiderivative of ${p['fn']} '
            'evaluated at u'
            '${p['ratio'] == '1' ? '.' : ', times the constant factor ${p['ratio']}.'}';
      case 'integralLogDerivative':
        return 'The numerator is (${p['ratio']})·(d/d${p['var']}[${p['den']}]), '
            'so the integral is ${p['ratio']}·ln|${p['den']}|.';
      case 'partialFractions':
        return 'The denominator has distinct integer roots ${p['roots']}. '
            'Cover-up gives A_i = P(r_i) / Q\'(r_i) for each root.';
      case 'partialFractionsIntegrate':
        return 'Each `A/(x-r)` piece integrates to A·ln|x-r|.';
      case 'trigArctanForm':
        return 'Match a² = ${p['aSq']}, so a = ${p['a']}. The standard '
            'form gives (1/a)·arctan(${p['var']}/a).';
      case 'trigArcsinForm':
        return 'Match a² = ${p['aSq']}, so a = ${p['a']}. The standard '
            'form gives arcsin(${p['var']}/a).';
      case 'integralFallthroughSymbolic':
        return 'No standard textbook rule matched this shape — handing off '
            'to the symbolic integrator.';
      case 'diffIdentity':
        return 'Differentiating ${p['var']} with respect to itself is 1.';
      case 'diffSumDifference':
        return 'Differentiate each term on its own; the derivative '
            'distributes across `+` and `−`.';
      case 'diffQuotient':
        return 'For a quotient, the numerator gets `f′g − fg′` and the '
            'denominator gets squared.';
      case 'diffProduct':
        return 'For a product, differentiate each factor and add the pieces '
            '— `(fg)′ = f′g + fg′`.';
      case 'diffPowerSimple':
        return 'Bring the exponent down as a coefficient and reduce the '
            'exponent by 1.';
      case 'diffPowerChain':
        return 'Bring the exponent down and reduce it by 1, then multiply '
            'by the derivative of the inner base — that '
            '`d/d${p['var']}[${p['base']}]` factor is the chain rule.';
      case 'diffExponential':
        return 'When the variable is in the exponent, the derivative is the '
            'same expression times `ln(base)` times the derivative of the '
            'exponent.';
      case 'diffStandardSimple':
        return 'Apply the standard derivative for ${p['fn']}.';
      case 'diffStandardChain':
        return 'The argument depends on ${p['var']}, so multiply by its '
            'derivative (chain rule).';
      case 'diffFallthrough':
        return 'No higher-level rule pattern recognized for this shape.';
    }
    return null;
  }
  // i18n sweep 2026-11-20
  @override
  String get helpGroupArithmetic => 'Arithmetic';
  @override
  String get helpGroupAlgebraicCas => 'Algebraic CAS';
  @override
  String get helpGroupCalculus => 'Calculus';
  @override
  String get helpGroupTrigElementary => 'Trig & elementary';
  @override
  String get helpGroupVectorTensor => 'Vector & tensor';
  @override
  String get helpGroupMatrix => 'Matrix';
  @override
  String get helpFnArithmeticDesc => 'Add / subtract / multiply / divide';
  @override
  String get helpFnPowerDesc => 'Power: 2^10 = 1024';
  @override
  String get helpFnFactorialDesc => 'Factorial: 5! = 120';
  @override
  String get helpFnAbsDesc => 'Absolute value';
  @override
  String get helpFnSolveDesc => 'Solve an equation for a variable';
  @override
  String get helpFnFactorDesc => 'Factor a polynomial';
  @override
  String get helpFnExpandDesc => 'Distribute a product / expand a power';
  @override
  String get helpFnSimplifyDesc => 'Reduce e to canonical form';
  @override
  String get helpFnSubstDesc => 'Substitute v for x in e';
  @override
  String get helpFnAnsDesc => 'Last result';
  @override
  String get helpFnDiffDesc => 'Derivative of f with respect to x';
  @override
  String get helpFnDiffStepsDesc => 'Same, but show step-by-step trace';
  @override
  String get helpFnIntegralDesc => 'Indefinite integral (∫ button)';
  @override
  String get helpFnDefiniteIntegralDesc => 'Definite integral via the ∫ dialog';
  @override
  String get helpFnIntegralStepsDesc => 'Indefinite integral with step-by-step trace';
  @override
  String get helpFnLimitDesc => 'One-sided / ∞ limit (numerical)';
  @override
  String get helpFnTrigDesc => 'Standard trig';
  @override
  String get helpFnInverseTrigDesc => 'Inverse trig';
  @override
  String get helpFnHyperbolicDesc => 'Hyperbolic';
  @override
  String get helpFnLnDesc => 'Natural log';
  @override
  String get helpFnRootDesc => 'Square root and n-th root';
  @override
  String get helpFnConstantsDesc => 'Common constants';
  @override
  String get helpFnDotDesc => 'Dot product';
  @override
  String get helpFnCrossDesc => 'Cross product (3-vectors)';
  @override
  String get helpFnNormDesc => 'Euclidean length';
  @override
  String get helpFnUnitDesc => 'Unit vector';
  @override
  String get helpFnDetDesc => 'Determinant';
  @override
  String get helpFnInvDesc => 'Inverse';
  @override
  String get helpFnTransposeDesc => 'Transpose';
  @override
  String get helpFnMatrixOpsDesc => 'Element-wise add / multiply';
  @override
  String get helpFnStatisticsDesc => 'Analysis hub → Statistics';
  @override
  String get helpFnNormalDesc => 'PDF, CDF, quantile (z-score)';
  @override
  String get helpFnBinomialDesc => 'PMF, CDF, mean, variance';
  @override
  String get helpFnStatisticsName => 'Statistics screen';
  @override
  String get helpFnNormalName => 'Normal';
  @override
  String get helpFnBinomialName => 'Binomial';
  @override
  String get calcIconCamera => 'Camera';
  @override
  String get calcIconPhotoLibrary => 'Photo library';
  @override
  String get calcOcrTakePhoto => 'Take photo';
  @override
  String get calcOcrSingleFormula => 'Single formula';
  @override
  String get calcOcrChooseFromGallery => 'Choose from gallery';
  @override
  String get calcOcrDocumentPage => 'Document page';
  @override
  String get calcOcrDocumentPageSubtitle => 'Detect layout, OCR formula regions';
  @override
  String get calcOcrNoProviderConfiguredYet => 'No OCR provider configured yet.';
  @override
  String get calcOcrNoProviderConfigured => 'No OCR provider configured.';
  @override
  String get calcOcrRecognizing => 'Recognizing math…';
  @override
  String get calcOcrFailedClearer => 'OCR failed — try a clearer image.';
  @override
  String calcMemoryEmpty(int slot) => 'Memory M$slot is empty';
  @override
  String get calcIconAnalyze => 'Analyze';
  @override
  String get calcIconSolve => 'Solve';
  @override
  String get calcIconCopy => 'Copy';
  @override
  String get calcIconStoreAsVariable => 'Store as variable';
  @override
  String get calcShareLink => 'Share link';
  @override
  String get calcLinkCopied => 'Link copied';
  @override
  String get calcScanMath => 'Scan math';
  @override
  String get calcWriteMath => 'Write math';
  @override
  String get calcIconHelpMode => 'Help mode';
  @override
  String get calcIconDisableHelpMode => 'Disable help mode';
  @override
  String get calcIconPlainText => 'Plain text';
  @override
  String get calcIconContinueTyping => 'Continue typing';
  @override
  String get varViewerStorageIcon => 'Storage';
  @override
  String get varViewerEmptyTitle => 'No variables or functions defined.';
  @override
  String get varViewerEmptyBody => 'Use "name = value" on the main screen to create variables.\nDefine functions in the Function Editor.';
  @override
  String varViewerClearAllTitle(String section) => 'Clear All $section';
  @override
  String varViewerClearAllConfirm(String section) => 'Are you sure you want to clear all $section?';
  @override
  String get varViewerClearAllIcon => 'Clear all';
  @override
  String varViewerClearAllTooltip(String section) => 'Clear all $section';
  @override
  String get varViewerDeleteVariable => 'Delete variable';
  @override
  String get varViewerDeleteFunction => 'Delete function';
  @override
  String get memoryNoResultToStore => 'No result to store';
  @override
  String get memoryStoreResultTitle => 'Store Result';
  @override
  String memoryStorePreview(String value) => 'Store: $value';
  @override
  String get memorySaveAsVariable => 'Save as Variable';
  @override
  String get memorySaveToMemory => 'Save to Memory';
  @override
  String get memoryVariableNameLabel => 'Variable Name';
  @override
  String get memoryVariableNameHint => 'e.g., result1';
  @override
  String memoryValuePreview(String value) => 'Value: $value';
  @override
  String memorySavedVariable(String name, String value) => 'Saved $name = $value';
  @override
  String memorySavePreview(String value) => 'Save: $value';
  @override
  String get memoryEmptySlot => 'Empty';
  @override
  String memorySavedToSlot(int slot) => 'Saved to M$slot';
  @override
  String get memoryDeleteTitle => 'Delete Memory';
  @override
  String get memoryAllCleared => 'All memory cleared';
  @override
  String get stepsNarrate => 'Narrate';
  @override
  String get stepsNarrateWithAi => 'Narrate with AI';
  @override
  String get stepsResult => 'Result';
  @override
  String get stepsStep => 'Step';
  @override
  String get stepsBecomes => 'becomes';
  @override
  String get stepsSolution => 'Solution';
  @override
  String get stepsOdeFallbackNote => 'A full step-by-step trace is available for constant-coefficient linear ODEs; the answer is shown above.';
  @override
  String get historyExplain => 'Explain';
  @override
  String get historyExplainWithAi => 'Explain with AI';
  @override
  String get historyIntegrationMethodNotRecorded => 'Integration (method not recorded)';
  @override
  String get cmdPaletteFindCommand => 'Find a command';
  @override
  String get cmdPaletteHint => 'Functions, tools or screens';
  @override
  String get cmdPaletteNoResults => 'No commands found';
  @override
  String get unitConvError => 'Error';
  @override
  String get unitConvSwap => 'Swap';
  @override
  String get unitConvSwapUnits => 'Swap units';
  @override
  String get unitConvConvertsTo => 'converts to';
  @override
  String get unitConvDimArea => 'Area';
  @override
  String get unitConvDimVolume => 'Volume';
  @override
  String get userFunctionsAddFunction => 'Add function';
  @override
  String get graphModeParametric => 'Parametric';
  @override
  String get graphModePolar => 'Polar';
  @override
  String get graphModeImplicit => 'Implicit';
  @override
  String get graphModeVectorField => 'Vector Field';
  @override
  String get graphBounds => 'Graph bounds';
  @override
  String get graphBoundsXMin => 'x minimum';
  @override
  String get graphBoundsXMax => 'x maximum';
  @override
  String get graphBoundsYMin => 'y minimum';
  @override
  String get graphBoundsYMax => 'y maximum';
  @override
  String get graphBoundsInvalid => 'Enter finite, increasing x and y bounds.';
  @override
  String get graphApplyBounds => 'Apply bounds';
  @override
  String graphFitFailed(String error) => 'Could not fit graph: $error';
  @override
  String get graphFit => 'Fit graph';
  @override
  String get graphUndoChange => 'Undo graph change';
  @override
  String get graphTraceCurve => 'Trace curve';
  @override
  String get graphValueTable => 'Value table';
  @override
  String graphLinkedSlot(int slot, String document) => 'Linked Y$slot: $document';
  @override
  String get graphMissingDocument => 'Missing document';
  @override
  String graphTraceSlot(int slot) => 'Trace Y$slot';
  @override
  String get graphTraceHint => 'Tap or drag a curve. Use ← / → to step.';
  @override
  String get graphTraceWaiting => 'Trace: waiting for samples';
  @override
  String get graphUndefined => 'undefined';
  @override
  String? keypadSpokenLabel(String key) => switch (key) {
        '⌫' => 'backspace',
        '±' => 'plus or minus',
        '√' => 'square root',
        '∛' => 'cube root',
        'ⁿ√' => 'nth root',
        '^' => 'to the power of',
        '×' => 'times',
        '÷' => 'divided by',
        '·' => 'times',
        'π' => 'pi',
        'e' => 'Euler\'s number',
        '∞' => 'infinity',
        '°' => 'degrees',
        'φ' => 'phi',
        '∫ dx' => 'integral',
        'd/dx' => 'derivative',
        '∫⌄' => 'integral with bounds picker',
        'd/dx⌄' => 'differentiation steps picker',
        'solve⌄' => 'solve steps picker',
        'Ans' => 'last answer',
        'EXE' => 'evaluate',
        '=' => 'equals',
        'C' => 'clear',
        _ => null,
      };
  @override
  String? keypadKeyHint(String key) => switch (key) {
        'C' => 'Clear the input',
        'Ans' => 'Insert the last answer',
        '%' => 'Percent: 20% = 0.2, 50 + 10% = 55',
        '/' => 'Divide',
        '*' => 'Multiply',
        '-' => 'Subtract',
        '+' => 'Add',
        '.' => 'Decimal point',
        '(' => 'Opening parenthesis',
        ')' => 'Closing parenthesis',
        'x' => 'Insert the variable x',
        '^' => 'Power, e.g. x^2',
        'frac' => 'Fraction template (numerator over denominator)',
        'solve⌄' => 'Solve an equation step by step',
        'd/dx⌄' => 'Differentiate step by step',
        '∫⌄' => 'Integrate step by step',
        '=' => 'Equals sign for equations, e.g. x^2 = 4',
        ',' => 'Argument separator, e.g. gcd(12, 18)',
        'f(x)' => 'Insert a stored function',
        _ => null,
      };
  @override
  String keypadTooltipExample(String example) => 'e.g. $example';
  @override
  String keypadTooltipShortcut(String keys) => 'Shortcut: $keys';
  @override
  String get keypadTabNumHint => 'Digits, basic operators, powers, roots and π';
  @override
  String get keypadTabTrigHint => 'Trigonometric, hyperbolic, logarithmic and exponential functions';
  @override
  String get keypadTabCasHint => 'Computer algebra: solve, factor, expand, simplify, derivatives, integrals and limits';
  @override
  String get keypadTabAdvancedHint => 'Number theory, matrices and vectors, high precision, special functions and logic';
  @override
  String get keypadTabVarsHint => 'Stored variables, functions and memory slots';
  @override
  String get statsDataLabel => 'Data (comma, space, or newline-separated)';
  @override
  String get statsPaste => 'Paste';
  @override
  String get statsPasteFromClipboard => 'Paste from clipboard';
  @override
  String statsError(String error) => 'Error: $error';
  @override
  String get statsFullPrecision => 'Full precision';
  @override
  String get statsFullPrecisionTitle => 'Summary at full precision';
  @override
  String statsFullPrecisionBody(String mean, String median, String stddev) => 'Mean: $mean\nMedian: $median\nSample standard deviation: $stddev';
  @override
  String get statsEnterAtLeastOne => 'Enter at least one number above.';
  @override
  String get statsBestFitLine => 'Best-fit line:';
  @override
  String statsSlopeA(String value) => 'Slope a = $value';
  @override
  String statsInterceptB(String value) => 'Intercept b = $value';
  @override
  String statsBestFitPolynomial(int degree) => 'Best-fit polynomial (degree $degree):';
  @override
  String get statsBestFitExponential => 'Best-fit exponential:';
  @override
  String statsRSquaredLogSpace(String value) => 'R² (log-space) = $value';
  @override
  String get statsModelLinear => 'Linear';
  @override
  String get statsModelPolynomial => 'Polynomial';
  @override
  String get statsModelExponential => 'Exponential';
  @override
  String get statsDegreeLabel => 'Degree: ';
  @override
  String get statsXValues => 'x values';
  @override
  String get statsYValues => 'y values';
  @override
  String get statsNormalDistribution => 'Normal distribution';
  @override
  String get statsMeanMu => 'mean μ';
  @override
  String get statsStddevSigma => 'stddev σ';
  @override
  String get statsXForCdf => 'x for CDF';
  @override
  String get statsPForQuantile => 'p for quantile';
  @override
  String get statsNormalPrompt => 'Enter μ and σ > 0 to compute normal values.';
  @override
  String get statsQuantileP => 'quantile(p)';
  @override
  String get statsStudentTDistribution => 'Student t distribution';
  @override
  String get statsDegreesOfFreedomNu => 'Degrees of freedom ν';
  @override
  String get statsIntervalLowerBound => 'Interval lower bound';
  @override
  String get statsIntervalUpperBound => 'Interval upper bound';
  @override
  String get statsTIntervalProbability => 'P(lower ≤ T ≤ upper)';
  @override
  String get statsTPrompt => 'Enter a positive integer ν and finite bounds with lower ≤ upper.';
  @override
  String get statsBinomialDistribution => 'Binomial distribution';
  @override
  String get statsTrialsN => 'n (trials)';
  @override
  String get statsSuccessP => 'p (success)';
  @override
  String get statsBinomialPrompt => 'Enter n ≥ 0 and 0 ≤ p ≤ 1 to compute binomial values.';
  @override
  String get statsStddevShort => 'Stddev';
  @override
  String get statsRejectH0 => 'Reject H₀ at α (the data are inconsistent with H₀).';
  @override
  String get statsFailToRejectH0 => 'Fail to reject H₀ at α (the data are consistent with H₀).';
  @override
  String get statsSampleData => 'Sample data';
  @override
  String get statsHypothesizedMeanLabel => 'Hypothesized mean μ₀';
  @override
  String get statsSampleMean => 'Sample mean x̄';
  @override
  String get statsSampleStddev => 'Sample stddev s';
  @override
  String get statsSampleSize => 'Sample size n';
  @override
  String get statsHypothesizedMu => 'Hypothesized μ₀';
  @override
  String get statsTStatistic => 't-statistic';
  @override
  String get statsDegreesOfFreedom => 'Degrees of freedom';
  @override
  String get statsPValueTwoSided => 'p-value (two-sided)';
  @override
  String get statsPValueUpperTail => 'p-value (upper tail)';
  @override
  String get statsPValueLowerTail => 'p-value (lower tail)';
  @override
  String get statsPValueUpper => 'p-value (upper)';
  @override
  String get statsPValueLower => 'p-value (lower)';
  @override
  String statsSampleN(int n) => 'Sample $n';
  @override
  String get statsMean1 => 'Mean₁ x̄₁';
  @override
  String get statsMean2 => 'Mean₂ x̄₂';
  @override
  String get statsStddev1 => 'Stddev₁ s₁';
  @override
  String get statsStddev2 => 'Stddev₂ s₂';
  @override
  String get statsSizes => 'Sizes n₁, n₂';
  @override
  String get statsTStatisticWelch => 't-statistic (Welch)';
  @override
  String get statsDfWelch => 'df (Welch-Satterthwaite)';
  @override
  String get statsBefore => 'Before';
  @override
  String get statsAfter => 'After';
  @override
  String get statsMeanDifference => 'Mean difference';
  @override
  String get statsStddevOfDiffs => 'Stddev of diffs';
  @override
  String get statsPairsN => 'Pairs n';
  @override
  String get statsGroupsLabel => 'Groups (one per line)';
  @override
  String get statsGroupsHelper => 'Each line is one group, comma- or space-separated.';
  @override
  String statsGroupLabel(int index, int size) => 'Group $index (n=$size)';
  @override
  String statsGroupMean(String value) => 'mean $value';
  @override
  String get statsGrandMean => 'Grand mean';
  @override
  String get statsSsBetween => 'SS between';
  @override
  String get statsSsWithin => 'SS within';
  @override
  String get statsDfBetweenWithin => 'df (between, within)';
  @override
  String get statsMsBetween => 'MS between';
  @override
  String get statsMsWithin => 'MS within';
  @override
  String get statsFStatistic => 'F-statistic';
  @override
  String get statsContingencyLabel => 'Contingency table (one row per line)';
  @override
  String get statsContingencyHelper => 'Each line is a row, comma- or space-separated.';
  @override
  String get statsChiSquareStatistic => 'χ² statistic';
  @override
  String get statsGrandTotal => 'Grand total';
  @override
  String get statsFisherCellsLabel => '2×2 cells: a, b, c, d';
  @override
  String get statsFisherCellsHelper => 'Row 1 = [a, b]; row 2 = [c, d].';
  @override
  String statsCell(String cell, int row, int col) => '$cell (row$row,col$col)';
  @override
  String get statsPObserved => 'P(observed)';
  @override
  String get statsSignHelper => 'Pairs with zero difference are dropped.';
  @override
  String get statsPositives => 'Positives (before > after)';
  @override
  String get statsNegatives => 'Negatives (before < after)';
  @override
  String get statsTies => 'Ties (excluded)';
  @override
  String get statsEffectiveN => 'Effective n';
  @override
  String get statsWilcoxonHelper => 'Normal-approximation p-value; reliable for n ≳ 10.';
  @override
  String get statsRankSum => 'Rank sum R₁';
  @override
  String get statsZStatistic => 'z statistic';
  @override
  String get statsObservedCounts => 'Observed counts';
  @override
  String get statsExpectedCounts => 'Expected counts';
  @override
  String get statsTestOneSampleT => 'One-sample t';
  @override
  String get statsTestTwoSampleT => 'Two-sample t (Welch)';
  @override
  String get statsTestPairedT => 'Paired t';
  @override
  String get statsTestAnova => 'ANOVA (one-way)';
  @override
  String get statsTestChiSquareGof => 'χ² goodness-of-fit';
  @override
  String get statsTestChiSquareIndependence => 'χ² independence';
  @override
  String get statsTestFisherExact => "Fisher's exact 2×2";
  @override
  String get statsTestPairedSign => 'Paired sign';
  @override
  String get statsTestWilcoxon => 'Wilcoxon rank-sum';
  @override
  String get statsSignificanceLevel => 'Significance level α';
  @override
  String get conicNotAConicSentence => 'Not a conic.';
  @override
  String get conicEquationHeading => 'Equation:';
  @override
  String conicDiscriminant(String value) => 'Discriminant Δ = B² − 4AC = $value';
  @override
  String conicType(String kind) => 'Type: $kind';
  @override
  String conicRotationAngle(String radians, String degrees) => 'Rotation angle θ = $radians rad ($degrees°)';
  @override
  String conicCenter(String x, String y) => 'Center: ($x, $y)';
  @override
  String get conicParabolaAxisNote => 'Parabola — axis along the eigenvector of [A B/2; B/2 C] with eigenvalue 0.';
  @override
  String conicSemiTransverseAxis(String value) => 'Semi-transverse axis a = $value';
  @override
  String conicSemiConjugateAxis(String value) => 'Semi-conjugate axis b = $value';
  @override
  String conicSemiMajorAxis(String value) => 'Semi-major axis a = $value';
  @override
  String conicSemiMinorAxis(String value) => 'Semi-minor axis b = $value';
  @override
  String conicEccentricity(String value) => 'Eccentricity e = $value';
  @override
  String get conicKindCircle => 'Circle';
  @override
  String get conicKindEllipse => 'Ellipse';
  @override
  String get conicKindParabola => 'Parabola';
  @override
  String get conicKindHyperbola => 'Hyperbola';
  @override
  String get conicKindDegenerate => 'Degenerate conic';
  @override
  String get conicKindNotAConic => 'Not a conic';
  @override
  String planeError(String error) => 'Error: $error';
  @override
  String get planeCoordinateFormHeading => 'Coordinate form:';
  @override
  String planeNormalVector(String vector) => 'Normal vector n = $vector';
  @override
  String planeUnitNormal(String vector) => 'Unit normal n̂ = $vector';
  @override
  String planeHessianNormalForm(String value) => 'Hessian normal form: n̂·x = $value';
  @override
  String planeSignedDistance(String value) => 'Signed distance from origin: $value';
  @override
  String planePointOnPlane(String point) => 'Point on plane: $point';
  @override
  String get planeAxisIntercepts => 'Axis intercepts:';
  @override
  String planeAxisIntercept(String axis, String point) => '$axis-axis: $point';
  @override
  String planeAxisParallel(String axis) => '$axis-axis: parallel (no intercept)';
  @override
  String get planePointP => 'Point P';
  @override
  String get planeDirectionU => 'Direction U';
  @override
  String get planeDirectionV => 'Direction V';
  @override
  String get curvePleaseEnterFunction => 'Please enter a function.';
  @override
  String curveAnalysisError(String error) => 'Error during analysis: $error';
  @override
  String curveSavedVariable(String name, String value) => 'Saved $name = $value';
  @override
  String get curveAllSlotsFullTitle => 'All function slots are full';
  @override
  String get curveWhichFunctionReplace => 'Which function would you like to replace?';
  @override
  String curveReplacedSlot(int slot) => 'Replaced Y$slot';
  @override
  String get curveNoSavedFunctions => 'No saved functions available';
  @override
  String get curveSelectFromSaved => 'Select from saved functions';
  @override
  String get curveSaveAsFunction => 'Save as function';
  @override
  String get valueTableTitle => 'Value table';
  @override
  String get valueTableFunction => 'Function';
  @override
  String get valueTableFrom => 'From';
  @override
  String get valueTableTo => 'To';
  @override
  String get valueTableStep => 'Step';
  @override
  String get valueTableGenerate => 'Generate table';
  @override
  String get valueTableGenerateFailed => 'Could not generate values. Check the interval and expression.';
  @override
  String get valueTableChooseInterval => 'Choose an interval to inspect values.';
  @override
  String get valueTableCopied => 'Table copied';
  @override
  String get valueTableCopyTable => 'Copy table';
  @override
  String get valueTableCsvCopied => 'CSV copied';
  @override
  String get valueTableCopyCsv => 'Copy CSV';
  @override
  String get matrixEdTitle => 'Matrix Editor';
  @override
  String get matrixEdUseInCalculator => 'Use Matrix in Calculator';
  @override
  String get matrixEdValues => 'Matrix Values';
  @override
  String get matrixEdQuickOperations => 'Quick Operations';
  @override
  String get matrixEdRows => 'Rows:';
  @override
  String get matrixEdColumns => 'Columns:';
  @override
  String get scene3DQuadricCustom => 'Quadric (custom)';
  @override
  String get scene3DShortCone => 'Cone';
  @override
  String get scene3DShortCylinder => 'Cylinder';
  @override
  String get scene3DShortParaboloid => 'Paraboloid';
  @override
  String get scene3DShortHyperboloid1 => 'Hyperboloid (1)';
  @override
  String get scene3DShortHyperboloid2 => 'Hyperboloid (2)';
  @override
  String scene3DParamSteps(String param) => '$param steps';
  @override
  String get scene3DCurveSteps => 'steps';
  @override
  String constraintsMagicSolveFailed(String error) => 'Magic-square solve failed: $error';
  @override
  String constraintsPackingHeader(int width, int height) => 'Packing · $width × $height';
  @override
  String constraintsSubcircuitHeader(int count) => 'Subcircuit · $count nodes';
  @override
  String constraintsTourHeader(int count) => 'Tour · $count nodes';
  @override
  String constraintsMoreSolutions(int count) => '… +$count more';
  @override
  String get graph3DNoFiniteValues => 'No finite values in the sampled grid.';
  @override
  String get moduleHelpIconLabel => 'Help';
  @override
  String notepadDisplayDocName(String name) => name;
  @override
  String notepadCopyName(String name) => '$name (copy)';
  @override
  String notepadTemplateName(String id, String fallback) => fallback;
  @override
  String notepadTemplateText(String text) => text;
  @override
  String notepadLineCount(int n) => n == 1 ? '1 line' : '$n lines';
  @override
  String get notepadWelcomeSample => 'Welcome sample';
  @override
  String get notepadAdd => 'Add';
  @override
  String get notepadNew => 'New';
  @override
  String get notepadSearchHint => 'Search…';
  @override
  String notepadSearchShownHidden(int shown, int hidden) => '$shown shown · $hidden hidden';
  @override
  String notepadSearchMatches(int n) => '$n matches';
  @override
  String get notepadCloseSearch => 'Close search';
  @override
  String get notepadCamera => 'Camera';
  @override
  String get notepadTakePhoto => 'Take photo';
  @override
  String get notepadSingleFormula => 'Single formula';
  @override
  String get notepadPhotoLibrary => 'Photo library';
  @override
  String get notepadChooseFromGallery => 'Choose from gallery';
  @override
  String get notepadDocumentPage => 'Document page';
  @override
  String get notepadDocumentPageSubtitle => 'Detect layout, OCR formula regions';
  @override
  String get notepadNoOcrProvider => 'No OCR provider configured.';
  @override
  String get notepadOcrFailed => 'OCR failed.';
  @override
  String get notepadAiTranslate => 'AI Translate';
  @override
  String get notepadAiDescribePrompt => 'Describe the math in natural language:';
  @override
  String get notepadAiHint => 'e.g. "derivative of x cubed minus 4x"';
  @override
  String get notepadScanMath => 'Scan math';
  @override
  String get notepadWriteMath => 'Write math';
  @override
  String get notepadExportPdf => 'Export PDF';
  @override
  String get notepadExportAsPdf => 'Export as PDF';
  @override
  String get notepadLatexInput => 'LaTeX input';
  @override
  String get notepadChecked => 'Checked';
  @override
  String get notepadUnchecked => 'Unchecked';
  @override
  String get notepadNotes => 'Notes';
  @override
  String get notepadPinned => 'Pinned';
  @override
  String get notepadExpandSection => 'Expand section';
  @override
  String get notepadCollapseSection => 'Collapse section';
  @override
  String get notepadExpand => 'Expand';
  @override
  String get notepadCollapse => 'Collapse';
  @override
  String notepadHiddenLines(int n) => '$n hidden';
  @override
  String get notepadLinkToGraph => 'Link line to graph';
  @override
  String notepadLineHint(int n) => 'line $n';
  @override
  String get notepadDragToReorder => 'Drag to reorder';
  @override
  String get notepadCopy => 'Copy';
  @override
  String get notepadExplainWithAi => 'Explain with AI';
  @override
  String get notepadBlocked => 'Blocked';
  @override
  String get notepadCircularReference => 'Circular reference';
  @override
  String get notepadCurrentDocument => 'Current document';
  @override
  String get notepadDocument => 'Document';
  @override
  String get notepadConfirmRename => 'Confirm rename';
  @override
  String get notepadCancelRename => 'Cancel rename';
  @override
  String get notepadKindVariable => 'Variable';
  @override
  String get notepadKindFunction => 'Function';
  @override
  String get notepadKindConstant => 'Constant';
  @override
  String settingsWorkflowOpenFailed(String error) => 'Could not open workflow: $error';
  @override
  String get settingsHighContrastSemantic => 'High contrast';
  @override
  String get settingsTextScaleSemantic => 'Text scale';
  @override
  String get settingsExactIntegersSemantic => 'Exact integers';
  @override
  String get settingsAutoBindSolveSemantic => 'Auto bind solve';
  @override
  String get settingsTourSemantic => 'Tour';
  @override
  String get settingsStartTourSemantic => 'Start tour';
  @override
  String get settingsUserFunctionsSemantic => 'User functions';
  @override
  String get settingsOpenSemantic => 'Open';
  @override
  String get settingsWorkedExamplesSemantic => 'Worked examples';
  @override
  String get settingsFunctionReferenceSemantic => 'Function reference';
  @override
  String get settingsExportSemantic => 'Export';
  @override
  String get settingsBackupSemantic => 'Backup';
  @override
  String get settingsBackupsSubtitle => 'Files, restore and transfer between devices';
  @override
  String get settingsOcrModelsTitle => 'Math OCR Models';
  @override
  String get settingsOcrModelsSubtitle => 'Download models for equation recognition';
  @override
  String get settingsDiagnosticsSemantic => 'Diagnostics';
  @override
  String get settingsRunDiagnosticsSemantic => 'Run diagnostics';
  @override
  String get settingsDiagnosticPassed => 'Passed';
  @override
  String get settingsDiagnosticFailed => 'Failed';
  @override
  String get settingsSyncSemantic => 'Sync';
  @override
  String get settingsAboutSemantic => 'About';
  @override
  String get bannerDownloadAppSemantic => 'Download app';
  @override
  String get actionCopy => 'Copy';
  @override
  String get examplesSearchSemantic => 'Search';
  @override
  String resultEvidenceOriginalDomain(String domain) => 'Original domain: $domain';
  @override
  String get aboutFullPrivacyPolicy => 'Full privacy policy';
  @override
  String get aboutSourceCode => 'Source code:';
  @override
  String get crashReportsSemantic => 'Crash reports';
  @override
  String get crashReportsTitle => 'Crash Reports';
  @override
  String crashReportsCount(int count) => 'Crash Reports ($count)';
  @override
  String get crashReportsSubtitle => 'Review and send — no data leaves without your action';
  @override
  String get crashReportOnGitHub => 'Report on GitHub';
  @override
  String get crashSendEmail => 'Send Email';
  @override
  String get assistMathTitle => 'Math assistance';
  @override
  String get assistMathSubtitle => 'Translate a question, review the expression, then calculate.';
  @override
  String get assistOpenAssistant => 'Open assistant';
  @override
  String get assistSettingsSaved => 'CrispAssist settings saved';
  @override
  String assistConfigured(String model) => 'Configured ($model)';
  @override
  String get assistNotConfigured => 'Not configured';
  @override
  String get assistCollapse => 'Collapse';
  @override
  String get assistExpand => 'Expand';
  @override
  String get assistDescription => 'CrispAssist explains results and translates natural language to engine syntax. It never computes answers — all math goes through SymEngine. You supply your own API key.';
  @override
  String get assistApiKey => 'API Key';
  @override
  String get assistModel => 'Model';
  @override
  String get assistStop => 'Stop';
  @override
  String get assistDismiss => 'Dismiss';
  @override
  String get assistStepNarration => 'Step Narration';
  @override
  String get syncDialogTitle => 'Cloud Sync';
  @override
  String get syncSettingsConfigured => 'Configured · transfer workspace backups';
  @override
  String get syncSettingsOff => 'Off · local work needs no account';
  @override
  String get syncReplaceTitle => 'Replace cloud backup?';
  @override
  String get syncReplaceBody => 'Upload this device’s workspace as the cloud backup. Pull first to review work from another device.';
  @override
  String get syncUploadBackup => 'Upload backup';
  @override
  String get syncUploaded => 'Cloud backup uploaded.';
  @override
  String get syncUploadFailed => 'Cloud upload failed. Check your connection, then pull and review the latest backup before trying again.';
  @override
  String get syncNoBackup => 'No cloud backup is available.';
  @override
  String get syncBackupLoaded => 'Cloud backup loaded for review.';
  @override
  String get syncReadFailed => 'Cloud backup could not be read. Check your connection and try again.';
  @override
  String get syncAccountCreatedConfirm => 'Account created. Check your email to confirm it before signing in.';
  @override
  String get syncAccountCreatedSignedIn => 'Account created. You are signed in.';
  @override
  String get syncSignedIn => 'Signed in. You can now pull or upload a cloud backup.';
  @override
  String get syncSignUpFailed => 'Sign up failed. Check your details and connection, then try again.';
  @override
  String get syncSignInFailed => 'Sign in failed. Check your email and password, then try again.';
  @override
  String get syncConfigured => 'Cloud sync is configured. Sign in to transfer your workspace.';
  @override
  String get syncConfigureFailed => 'Cloud sync could not be configured. Check your connection and try again.';
  @override
  String get syncConfigureFormatError => 'Enter an HTTPS project URL and a public publishable or anon key.';
  @override
  String get syncConfigureSaveFailed => 'Cloud sync is connected, but its settings could not be saved. Configure it again after restarting.';
  @override
  String get syncSignedOut => 'Signed out. Your workspace remains saved on this device.';
  @override
  String get syncSignOutFailed => 'Sign out failed. Check your connection and try again.';
  @override
  String get syncSignedOutLocally => 'Signed out on this device. The server could not confirm sign out; check your connection before signing in again.';
  @override
  String get syncWorking => 'Cloud sync is working';
  @override
  String get syncConnectFailed => 'Cloud sync could not connect. Try again when you are online.';
  @override
  String get syncReady => 'Cloud sync is ready.';
  @override
  String get syncNotConfigured => 'Cloud sync is not configured. Enter public project settings to continue.';
  @override
  String get syncOffBody => 'Cloud sync is off. Your work stays on this device. Local worksheets, checkpoints and backup files work without an account. Configure your own project only if you want cloud backups.';
  @override
  String get syncProjectUrl => 'Supabase project URL';
  @override
  String get syncPublicKey => 'Public publishable or anon key';
  @override
  String get syncConfigureButton => 'Configure cloud sync';
  @override
  String get syncEmail => 'Email';
  @override
  String get syncPassword => 'Password';
  @override
  String get syncLogIn => 'Log In';
  @override
  String get syncSignUp => 'Sign Up';
  @override
  String syncLoggedInAs(String email) => 'Logged in as $email';
  @override
  String get syncPull => 'Pull';
  @override
  String get syncPush => 'Push';
  @override
  String get syncSignOut => 'Sign Out';
  @override
  String get backupDialogTitle => 'Workspace backups';
  @override
  String backupFailed(String error) => 'Backup failed: $error';
  @override
  String get backupWorksheetsImported => 'Worksheets imported; conflicting versions kept separately.';
  @override
  String get backupWorkspaceRestored => 'Workspace restored. Previous work is available under Previous workspace.';
  @override
  String get backupIntro => 'Save a portable backup to Files, iCloud Drive or another provider. Open it on another device to transfer your work. Automatic cloud sync requires a configured backend.';
  @override
  String backupContents(int worksheets, int checkpoints) => '$worksheets worksheets and $checkpoints checkpoints in this backup.';
  @override
  String get backupRestoreExplanation => 'Import worksheets keeps current settings and graphs and preserves both versions of changed documents. Replace workspace restores all saved settings, history, functions, graphs and worksheets. A recovery backup is saved first.';
  @override
  String backupDocRows(String name, int rows) => '$name: $rows rows';
  @override
  String get backupSave => 'Save backup';
  @override
  String get backupOpen => 'Open backup';
  @override
  String get backupNoRecovery => 'No recovery backup is available.';
  @override
  String get backupPreviousWorkspace => 'Previous workspace';
  @override
  String get backupImportWorksheets => 'Import worksheets';
  @override
  String get backupReplaceWorkspace => 'Replace workspace';
  @override
  String handwritingInitFailed(String error) => 'Model initialization failed: $error';
  @override
  String get handwritingTermsTitle => 'Model usage terms';
  @override
  String handwritingTermsBody(String model, String terms) => '$model is provided under $terms. Review its terms and confirm your use complies before downloading.';
  @override
  String get handwritingAcceptTerms => 'Accept model terms';
  @override
  String get handwritingSendTitle => 'Send drawing to cloud?';
  @override
  String handwritingSendBody(String model) => 'Your drawing will be sent to $model for recognition. Review the returned expression before using it.';
  @override
  String get handwritingSendAction => 'Send drawing';
  @override
  String get handwritingNotRecognized => 'Could not recognize this drawing. Try clearer strokes or enter the expression directly.';
  @override
  String handwritingRecognitionFailed(String error) => 'Recognition failed: $error';
  @override
  String get handwritingTitle => 'Write Math';
  @override
  String get handwritingChooseModel => 'Choose handwriting model';
  @override
  String get handwritingNoModel => 'No handwriting model is available. Open Models to configure one.';
  @override
  String get handwritingCloudNote => 'Cloud recognition sends your drawing only after confirmation.';
  @override
  String get handwritingLocalNote => 'Recognition runs on this device. An uncached model may need a download.';
  @override
  String get handwritingReviewNote => 'Recognition can be wrong. Review and edit the expression before using it.';
  @override
  String get handwritingCanvas => 'Handwriting canvas';
  @override
  String get handwritingModels => 'Models';
  @override
  String get handwritingRecognize => 'Recognize';
  @override
  String get ocrRecognizedExpression => 'Recognized Expression';
  @override
  String get ocrCamera => 'Camera';
  @override
  String get ocrEditBeforeInsert => 'Edit if needed before inserting';
  @override
  String get ocrHideRawOutput => 'Hide raw output';
  @override
  String get ocrShowRawOutput => 'Show raw output';
  @override
  String get ocrRawOutput => 'Raw output';
  @override
  String get ocrLicenseTermsTitle => 'License Terms';
  @override
  String ocrLicenseTermsBody(String license) => 'This model is licensed under $license.\n\nBy downloading, you confirm that you will use these model weights for non-commercial purposes only.';
  @override
  String get ocrLicenseAppNotRestricted => 'The app itself is not restricted — this applies only to the model weights.';
  @override
  String get ocrAcceptDownload => 'I accept — download';
  @override
  String ocrModelDownloaded(String name) => '$name downloaded';
  @override
  String ocrDownloadFailed(String name) => 'Download failed: $name';
  @override
  String get ocrModelsTitle => 'OCR Models';
  @override
  String get ocrModelsWebTitle => 'OCR Models (Web)';
  @override
  String get ocrWebCacheNote => 'Models are cached in your browser (IndexedDB).';
  @override
  String get ocrAvailableModels => 'Available Models';
  @override
  String get ocrDiskUsageSemantic => 'Disk usage';
  @override
  String ocrDiskUsage(String mb) => 'Disk usage: $mb MB';
  @override
  String get ocrActiveProvider => 'Active Provider';
  @override
  String get ocrActive => 'Active';
  @override
  String get ocrInactive => 'Inactive';
  @override
  String get ocrTagCloud => 'cloud';
  @override
  String get ocrTagApiKey => 'API key';
  @override
  String get ocrTagOnDevice => 'on-device';
  @override
  String get ocrNoModelActiveSemantic => 'No model active';
  @override
  String get ocrNoModelActive => 'No model active — download one below';
  @override
  String get ocrCatPrintedMath => 'Printed Math';
  @override
  String get ocrCatHandwrittenMath => 'Handwritten Math';
  @override
  String get ocrCatTextDetection => 'Text Detection';
  @override
  String get ocrCatTextRecognition => 'Text Recognition';
  @override
  String get ocrCatLayoutDetection => 'Layout Detection';
  @override
  String get ocrCatVisionLanguage => 'Vision-Language';
  @override
  String get ocrQualBestQuality => 'Best Quality';
  @override
  String get ocrQualChineseEnglish => 'Chinese+English';
  @override
  String get ocrQual91Langs => '91 langs';
  @override
  String get ocrQualRecommended => 'recommended';
  @override
  String get ocrQualNonCommercialOptional => 'non-commercial, optional';
  @override
  String get ocrQualFast1B => 'fast, 1B';
  @override
  String get ocrDownloaded => 'Downloaded';
  @override
  String get ocrNotDownloaded => 'Not downloaded';
  @override
  String get ocrCached => 'Cached';
  @override
  String get ocrNotCached => 'Not cached';
  @override
  String get ocrWithdrawLicense => 'Withdraw license consent';
  @override
  String get ocrReviewLicenseToEnable => 'Review license to enable';
  @override
  String get ocrReviewLicense => 'Review license';
  @override
  String get ocrPauseDownload => 'Pause download';
  @override
  String get ocrDeleteModel => 'Delete model';
  @override
  String get ocrResumeDownload => 'Resume download';
  @override
  String get ocrDownloadModel => 'Download model';
  @override
  String get licenseNonCommercialTitle => 'Non-commercial model license';
  @override
  String get licenseTermsTitle => 'Model license terms';
  @override
  String get licenseOpen => 'Open license';
  @override
  String get licenseRead => 'Read the license';
  @override
  String get licenseDecline => 'Decline';
  @override
  String get licenseAccept => 'I accept these terms';
  // end i18n sweep 2026-11-20
}

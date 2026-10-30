// lib/localization/locales/de.dart
//
// German strings for [AppLocalizations].

part of '../app_localizations.dart';

class DeLocalizations implements AppLocalizations {
  const DeLocalizations();

  @override
  String get navCalculator => 'Rechner';
  @override
  String get navNotepad => 'Rechenblock';
  @override
  String get notepadDefaultDocName => 'Unbenannt';
  @override
  String get notepadAddLine => 'Zeile hinzufügen';
  @override
  String get notepadDeleteLine => 'Zeile löschen';
  @override
  String get notepadDocumentMenu => 'Dokumentmenü';
  @override
  String get notepadNewDocument => 'Neues Dokument';
  @override
  String get notepadOpenWelcomeSample => 'Willkommen-Beispiel öffnen';
  @override
  String get notepadRecalculateAll => 'Alles neu berechnen';
  @override
  String get notepadRename => 'Umbenennen';
  @override
  String get notepadDuplicate => 'Duplizieren';
  @override
  String get notepadCopyAsMarkdown => 'Als Markdown kopieren';
  @override
  String get notepadDeleteDocument => 'Dokument löschen';
  @override
  String get notepadUndo => 'Rückgängig';
  @override
  String get notepadLineDeleted => 'Zeile gelöscht';
  @override
  String notepadDocumentDeleted(String name) => 'Dokument „$name" gelöscht';
  @override
  String get notepadCopiedAsMarkdown => 'Als Markdown kopiert';
  @override
  String get notepadCopyResult => 'Ergebnis kopieren';
  @override
  String get notepadCopyAsLatex => 'Als LaTeX kopieren';
  @override
  String get notepadCopiedResult => 'Ergebnis kopiert';
  @override
  String get notepadCopiedAsLatex => 'Als LaTeX kopiert';
  @override
  String get notepadEmptyTitle => 'Noch keine Dokumente';
  @override
  String get notepadEmptyBody =>
      'Lege ein neues Dokument an oder öffne das Willkommen-Beispiel.';
  @override
  String notepadFreeVars(String names) => 'frei: $names';
  @override
  String notepadBlockedBy(String alias) => 'Blockiert durch $alias';
  @override
  String notepadCycle(String path) => 'Zyklus: $path';
  @override
  String notepadUnknownImport(String name) =>
      'Unbekannter Import: „$name" nicht in globalen Variablen';
  @override
  String notepadInvalidImport(String name) => 'Ungültiger Importname: „$name"';
  @override
  String get notepadEmptyImportList => 'Leere Importliste';
  @override
  String notepadUseDirective(String code) => 'Use-Anweisung: $code';
  @override
  String get notepadManageTitle => 'Rechenblöcke verwalten';
  @override
  String get notepadManageNotepads => 'Rechenblöcke verwalten…';
  @override
  String get notepadOpenDocument => 'Öffnen';
  @override
  String get notepadOpenFile => 'Arbeitsblattdatei öffnen';
  @override
  String get notepadSaveFile => 'Arbeitsblattdatei speichern';
  @override
  String get notepadFileSaved => 'Arbeitsblatt gespeichert';
  @override
  String get notepadFileOpenFailed =>
      'Arbeitsblatt konnte nicht geöffnet werden';
  @override
  String get notepadFileSaveFailed =>
      'Arbeitsblatt konnte nicht gespeichert werden';
  @override
  String get notepadExportAsJson => 'Als JSON exportieren';
  @override
  String get notepadImportFromJson => 'Aus JSON importieren';
  @override
  String get notepadImport => 'Importieren';
  @override
  String get notepadImportJsonHint => 'Hier ein Rechenblock-JSON einfügen…';
  @override
  String get notepadJsonCopied =>
      'Rechenblock-JSON in die Zwischenablage kopiert';
  @override
  String notepadJsonImported(String name) => '„$name" importiert';
  @override
  String get notepadJsonImportFailed =>
      'Import fehlgeschlagen: kein gültiges Rechenblock-JSON';
  @override
  String get graphErrorEmpty => 'Funktion ist leer';
  @override
  String get graphErrorUnbalanced =>
      'Klammern unausgewogen — die Funktion kann nicht gezeichnet werden';
  @override
  String get graphErrorTrailingOperator =>
      'Funktion endet mit einem Operator — bitte rechte Seite ergänzen';
  @override
  String get navGraphing => 'Graphen';
  @override
  String get navFunctions => 'Funktionen';
  @override
  String get navAnalysis => 'Analyse';
  @override
  String get navSettings => 'Einstellungen';

  @override
  String get historyHere => 'Hier erscheint der Berechnungsverlauf.';
  @override
  String get historyLabel => 'Verlauf:';
  @override
  String get clearButton => 'C';
  @override
  String get clearHistory => 'Verlauf löschen';
  @override
  String get clearHistoryConfirm =>
      'Alle Einträge aus dem Berechnungsverlauf entfernen?';
  @override
  String get searchHistory => 'Verlauf durchsuchen';
  @override
  String get searchHistoryHint => 'Verlauf filtern…';
  @override
  String get historyNoMatches => 'Keine passenden Einträge.';

  @override
  String get graphSampling => 'Graph wird aktualisiert';
  @override
  String get graphSamplingFailed =>
      'Der Graph konnte nicht aktualisiert werden.';
  @override
  String get graphNoRealValues =>
      'Keine reellen Werte in diesem Bereich. Prüfe den Ausdruck oder wähle einen anderen Bereich.';
  @override
  String get graphRetry => 'Erneut versuchen';
  @override
  String graphingTitle(int count) => 'Graphen ($count Funktionen)';
  @override
  String functionAdded(int slot) => 'Funktion zu Y$slot hinzugefügt';
  @override
  String functionRemoved(int slot) => 'Y$slot entfernt';
  @override
  String get allSlotsFull =>
      'Alle Funktionsplätze sind belegt. Bitte erst eine Funktion löschen.';
  @override
  String get clearAllFunctions => 'Alle Funktionen löschen';
  @override
  String get clearAllFunctionsConfirm =>
      'Sind Sie sicher, dass Sie alle gezeichneten Funktionen löschen möchten?';
  @override
  String get cancel => 'Abbrechen';
  @override
  String get clearAll => 'Alle löschen';
  @override
  String get zoomIn => 'Vergrößern';
  @override
  String get zoomOut => 'Verkleinern';
  @override
  String get resetView => 'Ansicht zurücksetzen';
  @override
  String get showKeypad => 'Tastatur einblenden';
  @override
  String get hideKeypad => 'Tastatur ausblenden';
  @override
  String get showAnnotations => 'Nullstellen & Extrema einblenden';
  @override
  String get hideAnnotations => 'Nullstellen & Extrema ausblenden';
  @override
  String get analyzeFunctions => 'Funktionen analysieren';
  @override
  String get selectFunctionToAnalyze => 'Zu analysierende Funktion wählen';
  @override
  String get plotButton => 'Zeichnen';
  @override
  String get enterFunctionPrompt =>
      'Funktion unten eingeben, um sie zu zeichnen.';

  @override
  String get analysisModulesTitle => 'Analyse-Module';
  @override
  String get moduleCurveSketching => 'Kurvendiskussion';
  @override
  String get moduleCurveSketchingSubtitle =>
      'Vollständige Analyse einer Funktion f(x)';
  @override
  String get modulePlanes => 'Ebenen';
  @override
  String get modulePlanesSubtitle =>
      '3D-Ebenen in Koordinaten- oder Parameterform analysieren';
  @override
  String get moduleConics => 'Kegelschnitte';
  @override
  String get moduleConicsSubtitle =>
      'Klassifiziere Ax² + Bxy + Cy² + Dx + Ey + F = 0';
  @override
  String get moduleStatistics => 'Statistik';
  @override
  String get moduleStatisticsSubtitle =>
      'Beschreibende Statistik, lineare Regression, Normal- & Binomialverteilung';
  @override
  String get module3DTitle => '3D-Grafik';
  @override
  String get module3DSubtitle =>
      'Zeichne z = f(x, y) als drehbare Drahtgitter-Fläche';
  @override
  String get module3DFunctionLabel => 'f(x, y)';
  @override
  String get module3DRangeLabel => 'Bereich';
  @override
  String get module3DResample => 'Gitter neu abtasten';
  @override
  String get module3DTapPlot =>
      'Funktion in x und y eingeben, dann auf Zeichnen tippen.';

  // -- P9-A2 --
  @override
  String get module3DScene => '3D-Szene';
  @override
  String get module3DSceneSubtitle =>
      'Mehrere 3D-Objekte zusammen darstellen — Ebenen, Geraden, Kugeln, Quadriken';
  @override
  String get scene3DAddPlane => 'Ebene hinzufügen';
  @override
  String get scene3DEditPlane => 'Ebene bearbeiten';
  @override
  String get scene3DEmpty =>
      'Ziehen zum Drehen · Pinch zum Zoomen · + tippen, um eine Ebene hinzuzufügen';
  @override
  String get scene3DPanelEmpty => 'Noch keine Objekte';
  @override
  String get scene3DObjectLabel => 'Bezeichnung';
  @override
  String get scene3DColor => 'Farbe';
  @override
  String get scene3DAdd => 'Hinzufügen';
  @override
  String get scene3DSave => 'Speichern';
  @override
  String get scene3DEdit => 'Bearbeiten';
  @override
  String get scene3DDelete => 'Löschen';
  @override
  String get scene3DHide => 'Ausblenden';
  @override
  String get scene3DShow => 'Einblenden';
  @override
  String get scene3DLabelRequired => 'Bezeichnung erforderlich';
  @override
  String get scene3DCoefRequired => 'Erforderlich';
  @override
  String get scene3DCoefInvalid => 'Keine gültige Zahl';
  @override
  String get scene3DPlaneZeroNormal =>
      'Normalenvektor (a, b, c) darf nicht null sein';

  // -- P9-A3 --
  @override
  String get scene3DAddObject => 'Objekt hinzufügen';
  @override
  String get scene3DAddLine => 'Gerade hinzufügen';
  @override
  String get scene3DEditLine => 'Gerade bearbeiten';
  @override
  String get scene3DAddSphere => 'Kugel hinzufügen';
  @override
  String get scene3DEditSphere => 'Kugel bearbeiten';
  @override
  String get scene3DLinePointDir => 'Punkt + Richtung';
  @override
  String get scene3DLineTwoPoints => 'Zwei Punkte';
  @override
  String get scene3DLinePoint => 'Punkt';
  @override
  String get scene3DLineDirection => 'Richtung';
  @override
  String get scene3DLineFirstPoint => 'Erster Punkt';
  @override
  String get scene3DLineSecondPoint => 'Zweiter Punkt';
  @override
  String get scene3DLineZeroDirection =>
      'Richtungsvektor darf nicht null sein (oder zwei verschiedene Punkte wählen)';
  @override
  String get scene3DSphereCenter => 'Mittelpunkt';
  @override
  String get scene3DSphereRadius => 'Radius';
  @override
  String get scene3DSpherePositiveRadius => 'Radius muss größer als null sein';

  // -- P9-A4 --
  @override
  String get scene3DIntersectionsEmpty =>
      'Zwei oder mehr Objekte hinzufügen, um Schnittmengen zu sehen';
  @override
  String scene3DIntersectionsTitle(int n) =>
      n == 1 ? '1 Schnittmenge' : '$n Schnittmengen';
  @override
  String get intersectionPoint => 'Punkt';
  @override
  String get intersectionTwoPoints => 'Zwei Punkte';
  @override
  String get intersectionLine => 'Gerade';
  @override
  String get intersectionCircle => 'Kreis';
  @override
  String intersectionReason(String key) {
    switch (key) {
      case 'parallelPlanes':
        return 'Ebenen sind parallel (kein Schnitt)';
      case 'coincidentPlanes':
        return 'Ebenen fallen zusammen';
      case 'lineParallelToPlane':
        return 'Gerade verläuft parallel zur Ebene (kein Schnitt)';
      case 'lineInPlane':
        return 'Gerade liegt in der Ebene';
      case 'sphereMissesPlane':
        return 'Ebene berührt die Kugel nicht';
      case 'degeneratePlane':
        return 'Degenerierte Ebene (Nullnormalvektor)';
      case 'parallelLines':
        return 'Geraden sind parallel (kein Schnitt)';
      case 'coincidentLines':
        return 'Geraden fallen zusammen';
      case 'skewLines':
        return 'Geraden sind windschief (treffen sich nicht)';
      case 'lineMissesSphere':
        return 'Gerade berührt die Kugel nicht';
      case 'degenerateLine':
        return 'Degenerierte Gerade (Nullrichtung)';
      case 'spheresApart':
        return 'Kugeln liegen zu weit auseinander';
      case 'sphereInsideSphere':
        return 'Eine Kugel liegt in der anderen';
      case 'coincidentSpheres':
        return 'Kugeln sind identisch';
      case 'numericalFailure':
        return 'Numerischer Grenzfall (leicht andere Werte versuchen)';
      // P9-A5b: plane × quadric → conic.
      case 'circle':
        return 'Kreis';
      case 'ellipse':
        return 'Ellipse';
      case 'parabola':
        return 'Parabel';
      case 'hyperbola':
        return 'Hyperbel';
      case 'degenerateConic':
        return 'Degenerierter Kegelschnitt (Geradenpaar oder Punkt)';
      case 'noConic':
        return 'Ebene verfehlt die Quadrik';
      case 'planeOnQuadric':
        return 'Ebene liegt auf der Quadrik';
      default:
        return key;
    }
  }

  // -- P9-A5 --
  @override
  String get scene3DAddQuadric => 'Quadrik hinzufügen';
  @override
  String get scene3DEditQuadric => 'Quadrik bearbeiten';
  @override
  String get scene3DQuadricKind => 'Typ';
  @override
  String get scene3DQuadricSemiAxes => 'Halbachsen';
  @override
  String get scene3DQuadricPositiveSemiAxes =>
      'Halbachsen müssen positiv sein (a, b, c > 0)';
  @override
  String get quadricKindEllipsoid => 'Ellipsoid';
  @override
  String get quadricKindCone => 'Elliptischer Kegel';
  @override
  String get quadricKindCylinder => 'Elliptischer Zylinder';
  @override
  String get quadricKindParaboloid => 'Elliptisches Paraboloid';
  @override
  String get quadricKindHyperboloid1 => 'Einschaliges Hyperboloid';
  @override
  String get quadricKindHyperboloid2 => 'Zweischaliges Hyperboloid';

  // -- P9-A5c.3 --
  @override
  String get conicOpenIn3DScene => 'In 3D-Szene öffnen';
  @override
  String get conicLiftNotAConic =>
      'Kein Kegelschnitt — nichts anzuheben. Erst quadratische Terme hinzufügen.';

  // -- P9-A6 --
  @override
  String get scene3DAddParametricSurface => 'Parametrische Fläche hinzufügen';
  @override
  String get scene3DEditParametricSurface => 'Parametrische Fläche bearbeiten';
  @override
  String get scene3DAddParametricCurve => 'Parametrische Kurve hinzufügen';
  @override
  String get scene3DEditParametricCurve => 'Parametrische Kurve bearbeiten';
  @override
  String get scene3DParametricSurface => 'Parametrische Fläche';
  @override
  String get scene3DParametricCurve => 'Parametrische Kurve';

  @override
  String get moduleUnitConverterTitle => 'Einheitenumrechner';
  @override
  String get moduleUnitConverterSubtitle =>
      'Umrechnung zwischen Längen, Zeit, Masse, Temperatur, Geschwindigkeit, Winkel';
  @override
  String get sectionVariables => 'Variablen';
  @override
  String get sectionGraphFunctions => 'Graphfunktionen';
  @override
  String get sectionMemorySlots => 'Speicherplätze';
  @override
  String get funcCtxShowOnGraph => 'Im Graphen anzeigen';
  @override
  String get funcCtxAnalyze => 'Kurvendiskussion';
  @override
  String get funcCtxDifferentiate => 'Ableiten';
  @override
  String get funcCtxIntegrate => 'Integrieren';
  @override
  String get funcCtxSolve => 'Lösen f(x) = 0';
  @override
  String get funcCtxCopy => 'Ausdruck kopieren';
  @override
  String get funcEditorTitle => 'Funktionseditor (Y=)';
  @override
  String get funcEditorDone => 'Fertig';
  @override
  String get funcEditorSelectFirst =>
      'Bitte ein Funktionsfeld zum Bearbeiten auswählen.';
  @override
  String get funcEditorAnalyzeTooltip => 'Diese Funktion analysieren';
  @override
  String get funcEditorGraphTooltip => 'Diese Funktion zeichnen';
  @override
  String get unitDimLength => 'Länge';
  @override
  String get unitDimTime => 'Zeit';
  @override
  String get unitDimMass => 'Masse';
  @override
  String get unitDimTemperature => 'Temperatur';
  @override
  String get unitDimVelocity => 'Geschwindigkeit';
  @override
  String get unitDimAngle => 'Winkel';
  @override
  String get planeAnalysisTitle => 'Ebenenanalyse';
  @override
  String get planeRepCoordinate => 'Koordinaten';
  @override
  String get planeRepParametric => 'Parametrisch';
  @override
  String get buttonAnalyze => 'Analysieren';
  @override
  String get buttonClassify => 'Klassifizieren';
  @override
  String get curveAnalysisEnterFunction =>
      'Zu analysierende Funktion eingeben:';
  @override
  String get curveResultWarnings => 'Warnungen';
  @override
  String get curveResultDerivatives => 'Ableitungen';
  @override
  String get curveResultKeyPoints => 'Wichtige Punkte';
  @override
  String get curveResultYIntercept => 'Y-Achsenabschnitt';
  @override
  String get curveResultRoots => 'Nullstellen';
  @override
  String get curveResultExtrema => 'Extrema (Minima/Maxima)';
  @override
  String get curveResultInflectionPoints => 'Wendepunkte';
  @override
  String get curveResultNoExtrema => 'Keine Extrema gefunden.';
  @override
  String get curveResultNoInflection => 'Keine Wendepunkte gefunden.';
  @override
  String curveAnalysisOfFunction(String function) =>
      'Analyse von f(x) = $function';
  @override
  String curveResultPointPrefix(String point) => 'Punkt: $point';
  @override
  String get extremumLocalMinimum => 'Lokales Minimum';
  @override
  String get extremumLocalMaximum => 'Lokales Maximum';
  @override
  String get extremumCriticalPoint => 'Kritischer Punkt';
  @override
  String get extremumInflectionPoint => 'Wendepunkt';
  @override
  String get extremumNoCriticalPoints => 'Keine kritischen Punkte gefunden';
  @override
  String get extremumConstantConcavity =>
      'Funktion hat konstante Krümmung (f\'\'(x) = 0 überall)';
  @override
  String get statisticsTitle => 'Statistik';
  @override
  String get statsTabDescriptive => 'Deskriptiv';
  @override
  String get statsTabRegression => 'Regression';
  @override
  String get statsTabDistributions => 'Verteilungen';
  @override
  String get statsTabTests => 'Tests';
  @override
  String get statsDescCount => 'Anzahl';
  @override
  String get statsDescSum => 'Summe';
  @override
  String get statsDescMean => 'Mittelwert';
  @override
  String get statsDescMedian => 'Median';
  @override
  String get statsDescMode => 'Modus';
  @override
  String get statsDescMin => 'Min';
  @override
  String get statsDescMax => 'Max';
  @override
  String get statsDescRange => 'Spannweite';
  @override
  String get statsDescVariance => 'Varianz';
  @override
  String get statsDescStddev => 'Standardabweichung';
  @override
  String get statsDescQ1 => 'Q1';
  @override
  String get statsDescQ3 => 'Q3';
  @override
  String get statsDescIqr => 'IQR';
  @override
  String get helpGroupProbability => 'Wahrscheinlichkeit';
  @override
  String get helpFnRrefDescription => 'Reduzierte Stufenform (Gauß-Jordan)';

  @override
  String get settingsTitle => 'Einstellungen';
  @override
  String get settingsNumberFormat => 'Zahlendarstellung';
  @override
  String get settingsNumberFormatAuto => 'Auto (129, 129,5)';
  @override
  String settingsNumberFormatDecimalPlaces(int n) => 'Nachkommastellen: $n';
  @override
  String get settingsAutoBindSolve => 'Lösungen automatisch zuweisen';
  @override
  String get settingsAutoBindSolveSubtitle =>
      'Wenn aktiv, weist solve(gleichung, x) die Lösung auch x zu.';
  @override
  String get settingsNumberFormatInteger => 'Ganzzahl (129)';
  @override
  String get settingsNumberFormatOneDecimal => 'Eine Nachkommastelle (129,0)';
  @override
  String get settingsNumberFormatTwoDecimal => 'Zwei Nachkommastellen (129,00)';
  @override
  String get settingsLanguage => 'Sprache';
  @override
  String get settingsLanguageEnglish => 'English';
  @override
  String get settingsLanguageGerman => 'Deutsch';
  @override
  String get settingsLanguageFrench => 'Français';
  @override
  String get settingsLanguageSpanish => 'Español';
  @override
  String get settingsTheme => 'Erscheinungsbild';
  @override
  String get settingsThemeSystem => 'Systemeinstellung';
  @override
  String get settingsThemeLight => 'Hell';
  @override
  String get settingsThemeDark => 'Dunkel';
  @override
  String get settingsLayoutTitle => 'Layout';
  @override
  String get settingsLayoutBody =>
      'CrispMath passt sich an die Fensterbreite an: untere Navigation auf '
      'Smartphones, Seitenleiste auf Tablets und Desktop. Ab ~760 px zeigt die '
      'Tastatur alle Funktionstasten gleichzeitig (ohne Reiter).';

  @override
  String get aboutTitle => 'Über CrispMath';
  @override
  String get aboutTagline => 'Symbolischer CAS-Rechner basierend auf SymEngine';
  @override
  String aboutVersion(String version) => 'Version $version';
  @override
  String get aboutServiceProvider => 'Anbieter';
  @override
  String get aboutContact => 'Kontakt';
  @override
  String get aboutPrivacy => 'Datenschutz';
  @override
  String get aboutPrivacyText =>
      'CrispMath läuft vollständig auf dem Gerät. Keine Berechnung, kein '
      'Verlaufseintrag und keine benutzerdefinierte Variable wird je an '
      'einen Server übertragen. Die App erhebt keine Analysedaten und '
      'kontaktiert keine entfernten Dienste.';
  @override
  String get aboutDisclaimer => 'Haftungsausschluss';
  @override
  String get aboutDisclaimerText =>
      'CrispMath wird "wie besehen" bereitgestellt, ohne jegliche '
      'Gewährleistung. Die symbolische Engine kann bei schlecht '
      'konditionierten numerischen Eingaben oder nicht unterstützten '
      'symbolischen Ausdrücken ungenaue Ergebnisse liefern. Kritische '
      'Berechnungen unabhängig überprüfen.';
  @override
  String get aboutLicense => 'Lizenz';
  @override
  String get aboutLicenseText =>
      'CrispMath ist freie Software, veröffentlicht unter der GNU Affero '
      'General Public License Version 3 oder neuer, mit einer App-Store-'
      'Erlaubnis. Die mitgelieferten GMP-/MPFR-/MPC-/FLINT-Bibliotheken '
      'behalten ihre eigenen LGPL-Lizenzen; Quellcode-, Build- und Relink-'
      'Details stehen unter Open-Source-Lizenzen.';
  @override
  String get aboutOpenSourceLicenses => 'Open-Source-Lizenzen';
  @override
  String get settingsAbout => 'Über CrispMath';
  @override
  String get matrixDiagnosticsTitle => 'Matrix-Selbsttest';
  @override
  String get matrixDiagnosticsSubtitle =>
      'det / inv / transpose / + / * über die native Bridge prüfen.';
  @override
  String matrixDiagnosticsSummary(int passed, int total) =>
      '$passed von $total Prüfungen bestanden';
  @override
  String get unitConverterTitle => 'Einheitenumrechner';
  @override
  String get unitConverterSubtitle =>
      'Länge / Zeit / Masse / Temperatur / Geschwindigkeit / Winkel.';

  @override
  String get selectEquation => 'Gleichung auswählen oder weiter tippen:';
  @override
  String get continueTyping => 'Weiter tippen';
  @override
  String get selectFunction => 'Funktion auswählen oder weiter tippen:';
  @override
  String get dismissPanel => 'Dieses Panel schließen';
  @override
  String solveFor(int n) => 'Löse Y$n = 0';
  @override
  String whereY(int n, String func) => 'wobei Y$n = $func';

  @override
  String get dialogInsert => 'Einfügen';
  @override
  String get dialogClose => 'Schließen';
  @override
  String get dialogShowSteps => 'Schritte anzeigen';
  @override
  String get dialogVariable => 'Variable';
  @override
  String get dialogExpression => 'Ausdruck';
  @override
  String get dialogValue => 'Wert';
  @override
  String get dialogFunction => 'Funktion f(x)';

  @override
  String get integralTitle => 'Integral';
  @override
  String get integralLowerBound => 'Untere Grenze';
  @override
  String get integralUpperBound => 'Obere Grenze';
  @override
  String get integralDefinite => 'Bestimmtes Integral';
  @override
  String get nthRootTitle => 'n-te Wurzel';
  @override
  String get nthRootBase => 'Basis';
  @override
  String get limitTitle => 'Grenzwert';
  @override
  String get limitApproaches => 'strebt gegen';
  @override
  String get substituteTitle => 'Einsetzen';
  @override
  String get substituteUseStoredVariable =>
      'Gespeicherte Variable als Wert verwenden:';

  @override
  String get differentiationStepsTitle => 'Ableitungsschritte';
  @override
  String differentiationStepsHeader(String variable) =>
      'Ableiten nach $variable:';
  @override
  String get solveStepsTitle => 'Lösungsschritte';
  @override
  String get odeStepsTitle => 'Lösungsschritte der DGL';
  @override
  String get solveStepsEquationLabel => 'Gleichung oder Ausdruck';
  @override
  String get solveStepsSolveFor => 'Lösen nach';
  @override
  String get solveStepsHint => 'z. B. 2x + 3 = 7  oder  x^2 - 5x + 6';
  @override
  String solveStepsHeader(String variable) => 'Lösen nach $variable:';
  @override
  String get integrationStepsTitle => 'Integrationsschritte';
  @override
  String get integrationStepsIntegrandLabel => 'Integrand';
  @override
  String get integrationStepsWrt => 'Integrieren nach';
  @override
  String get integrationStepsHint => 'z. B. x^2  oder  sin(x) + 2x';
  @override
  String integrationStepsHeader(String variable) =>
      'Integrieren nach $variable:';

  @override
  String get errorSolveFormat =>
      'Fehler: solve()-Format ist solve(Gleichung, Variable)';
  @override
  String get errorInvalidSolve => 'Fehler: Ungültige solve()-Syntax';
  @override
  String get errorInvalidDiff => 'Fehler: Ungültige d/dx()-Syntax';
  @override
  String get errorInvalidFactor => 'Fehler: Ungültige factor()-Syntax';
  @override
  String get errorInvalidExpand => 'Fehler: Ungültige expand()-Syntax';
  @override
  String get errorInvalidSimplify => 'Fehler: Ungültige simplify()-Syntax';
  @override
  String get errorGcdArgs => 'Fehler: gcd() benötigt genau 2 Argumente';
  @override
  String get errorInvalidGcd => 'Fehler: Ungültige gcd()-Syntax';
  @override
  String get errorLcmArgs => 'Fehler: lcm() benötigt genau 2 Argumente';
  @override
  String get errorInvalidLcm => 'Fehler: Ungültige lcm()-Syntax';

  @override
  String get errorMissingAns => 'Kein Ans im Speicher.';
  @override
  String get errorParse =>
      'Der Ausdruck konnte nicht verstanden werden. Bitte auf unausgewogene Klammern, Tippfehler oder fehlende Operatoren prüfen.';
  @override
  String get errorUnbalancedParen =>
      'Hier steht eine schließende Klammer, zu der keine öffnende gehört.';
  @override
  String get errorDivisionByZero => 'Division durch null.';
  @override
  String errorUnknownFunction(String name) =>
      '\u0022$name\u0022 ist keine bekannte Funktion. Bitte die Schreibweise prüfen.';
  @override
  String errorWrongArity(String name) =>
      '\u0022$name\u0022 wurde mit der falschen Anzahl von Argumenten aufgerufen.';
  @override
  String get errorNativeRequired =>
      'Diese Operation benötigt die native Mathematik-Bibliothek, die auf dieser Plattform nicht geladen ist.';
  @override
  String get errorNativeRequiredWeb =>
      'Symbolische Mathematik (solve, factor, integrate, …) benötigt die Desktop- oder Mobil-App — im Browser nicht verfügbar.';
  @override
  String get webBannerCasLoading =>
      'Symbolische Engine im Browser wird geladen… solve, factor und integrate stehen gleich zur Verfügung.';
  @override
  String get webBannerCasPartial =>
      'Das vollständige symbolische CAS – einschließlich Hochpräzisions- und zahlentheoretischer Funktionen (isprime, factorint, evalf, Bessel) – läuft direkt hier im Browser. Nur die multivariate Faktorisierung benötigt weiterhin die Desktop- oder Mobil-App.';
  @override
  String get webBannerCasUnavailable =>
      'Browser-Version: symbolisches CAS, hochpräzise und zahlentheoretische Funktionen benötigen die Desktop- oder Mobil-App. Statistik, Matrizen, Sudoku/CSP, Einheiten und der Rechner funktionieren hier.';
  @override
  String get webDownloadApp => 'App holen';
  @override
  String get errorIntegrateNotImplemented =>
      'Symbolische Integration ist in diesem Build nicht verfügbar. Bitte ∫ mit Integrationsgrenzen verwenden für ein numerisches (bestimmtes) Ergebnis.';
  @override
  String get errorMatrixLiteral =>
      'Das Matrix-Literal ist fehlerhaft. Bitte Format [a,b; c,d] verwenden oder den Matrix-Editor öffnen.';
  @override
  String get errorInternalMatrixDisposed =>
      'Interne Matrix-Referenz ist nicht mehr gültig. Bitte die Operation erneut ausführen.';
  @override
  String errorInvalidSyntax(String op) =>
      'Die Argumente an $op() hatten nicht die erwartete Form. Bitte das Beispiel in Hilfe / Über prüfen.';

  @override
  String get exportDataTitle => 'Daten exportieren';
  @override
  String get exportDataSubtitle =>
      'Das JSON unten enthält alles, was CrispMath auf diesem Gerät gespeichert hat — Verlauf, Variablen, Funktionen, Parameter, Einstellungen. Vor einer Neuinstallation in eine Notiz oder Cloud-Datei kopieren.';
  @override
  String get exportDataCopy => 'In Zwischenablage kopieren';
  @override
  String get exportDataCopied => 'In Zwischenablage kopiert';
  @override
  String get historyEntryCopyResult => 'Ergebnis kopieren';
  @override
  String get historyEntryCopyLatex => 'Als LaTeX kopieren';
  @override
  String get historyEntryCopyLatexSubtitle =>
      'In Word/Notion/Markdown einfügen für gesetzte Mathematik';
  @override
  String get historyEntryReuse => 'Ausdruck wiederverwenden';
  @override
  String get historyEntryCopied => 'Kopiert';

  // -- Round 91 --
  @override
  String get storeAsVariable => 'Ergebnis als Variable speichern';
  @override
  String get storeAsFunction => 'Als Funktion speichern';
  @override
  String get storeVariableTitle => 'Als Variable speichern';
  @override
  String get storeFunctionTitle => 'Als Funktion speichern';
  @override
  String get storeNameLabel => 'Name';
  @override
  String get storeFunctionParamLabel => 'Parameter';
  @override
  String get storeButton => 'Speichern';
  @override
  String get storeNameReserved => 'Name ist von einer Funktion belegt';
  @override
  String storeSavedAs(String name) => 'Als $name gespeichert';

  // -- R91b --
  @override
  String storeOverwriteTitle(String name) => '„$name" überschreiben?';
  @override
  String storeOverwriteCurrent(String existing) => 'Aktuell: $existing';
  @override
  String get storeOverwriteConfirm => 'Überschreiben';

  @override
  String get settingsExportData => 'Daten exportieren';
  @override
  String get settingsExportDataSubtitle =>
      'Alles auf diesem Gerät Gespeicherte kopieren (Verlauf, Variablen, Einstellungen).';
  @override
  String get settingsHelp => 'Hilfe & Funktionsreferenz';
  @override
  String get settingsHelpSubtitle =>
      'Unterstützte Funktionen, Matrix-Syntax und Schritt-für-Schritt-Auslöser.';

  @override
  String get settingsHighContrast => 'Hoher Kontrast';
  @override
  String get settingsHighContrastSubtitle =>
      'Stärkere Farben und Rahmen für bessere Lesbarkeit.';
  @override
  String get settingsTextScale => 'Textgröße';

  @override
  String get settingsExactIntegerMode => 'Exakter Ganzzahl-Modus';
  @override
  String get settingsExactIntegerModeSubtitle =>
      'Vollständige Ziffernfolge für beliebig genaue Ganzzahlergebnisse '
      'anzeigen (z. B. 100! = 158 Ziffern). Aus: auf double-Genauigkeit runden.';
  @override
  String exactIntegerBadge(int digits) => 'Exakte Ganzzahl · $digits Ziffern';
  @override
  String get exactIntegerTapToCopy => 'Tippen zum Kopieren';

  @override
  String get calculating => 'Berechne …';

  @override
  String get moduleSudokuTitle => 'Sudoku-Löser';
  @override
  String get moduleSudokuSubtitle =>
      'Sehen, wie ein Solver schließt: Singles, Annahmen und Backtracking, Schritt für Schritt.';
  @override
  String get sudokuSolveButton => 'Lösen';
  @override
  String get sudokuClearCell => 'Leeren';
  @override
  String get sudokuClearToStart => 'Rätsel zurücksetzen';
  @override
  String get sudokuSolvedCorrectly => 'Gelöst!';
  @override
  String get sudokuFilledWithErrors => 'Mit Fehlern';
  @override
  String get sudokuWinOverlayTapHint => 'Zum Schließen tippen';
  @override
  String get sudokuPresetLabelChooser => 'Rätsel';
  @override
  String get sudokuPresetCustom => 'Eigen';
  @override
  String sudokuPresetLabel(String id) {
    switch (id) {
      case 'small4x4Easy':
        return '4×4 leicht';
      case 'small4x4Medium':
        return '4×4 mittel';
      case 'small4x4Hard':
        return '4×4 schwer';
      case 'medium6x6':
        return '6×6 mittel';
      case 'eight8x8':
        return '8×8 mittel';
      case 'eight8x8X':
        return '8×8 Sudoku-X mittel';
      case 'eight8x8Disjoint':
        return '8×8 Disjunkt mittel';
      case 'eight8x8Killer':
        return '8×8 Killer';
      case 'ten10x10':
        return '10×10 mittel';
      case 'twelve12x12':
        return '12×12 mittel';
      case 'fifteen15x15':
        return '15×15 mittel';
      case 'standard9x9Easy':
        return '9×9 leicht';
      case 'standard9x9Medium':
        return '9×9 mittel';
      case 'standard9x9Hard':
        return '9×9 schwer (AI Escargot)';
      case 'standard9x9XEasy':
        return '9×9 Sudoku-X leicht';
      case 'killer4x4':
        return '4×4 Killer';
      case 'killer9x9':
        return '9×9 Killer';
    }
    return id;
  }

  @override
  String get sudokuVisualizerHeader => 'Such-Visualisierung';
  @override
  String get sudokuPlay => 'Start';
  @override
  String get sudokuPause => 'Pause';
  @override
  String get sudokuRestart => 'Neu';
  @override
  String get sudokuSpeedSlow => 'Langsam';
  @override
  String get sudokuSpeedMed => 'Mittel';
  @override
  String get sudokuSpeedFast => 'Schnell';
  @override
  String get sudokuGenerateButton => 'Erzeugen';
  @override
  String get sudokuDifficultyEasy => 'Leicht';
  @override
  String get sudokuDifficultyMedium => 'Mittel';
  @override
  String get sudokuDifficultyHard => 'Schwer';
  @override
  String get sudokuVariantRegular => 'Klassisch';
  @override
  String get sudokuVariantX => 'Sudoku-X';
  @override
  String get sudokuVariantKiller => 'Killer';
  @override
  String get sudokuVariantDisjoint => 'Disjunkt';
  @override
  String get sudokuCheckUnique => 'Eindeutigkeit prüfen';
  @override
  String get sudokuUniqueSolution => 'Eindeutige Lösung';
  @override
  String get sudokuMultipleSolutions => 'Mehrere Lösungen';
  @override
  String get sudokuShowHints => 'Hinweise anzeigen';
  @override
  String get sudokuShowHintsSubtitle =>
      'Bleistift-Notizen: für jedes leere Feld die Ziffern, die noch '
      'nicht durch Zeile, Spalte, Block oder Diagonale ausgeschlossen '
      'sind.';
  @override
  String get sudokuHintLevelOff => 'Aus';
  @override
  String get sudokuHintLevelBasic => 'Einfach';
  @override
  String get sudokuHintLevelAdvanced => 'Erweitert';
  @override
  String get sudokuHintLevelAdvancedHelp =>
      'Erweitert führt für jeden Kandidaten den vollständigen '
      'CSP-Solver aus und erkennt so auch versteckte Einzelne und '
      'nackte Paare. Langsamer — dauert bei schweren 9×9-Rätseln '
      'einige Sekunden.';
  @override
  String get sudokuHintLevelComputing =>
      'Erweiterte Hinweise werden berechnet…';

  @override
  String sudokuConstraintRow(int row) => 'Zeile $row';
  @override
  String sudokuConstraintCol(int col) => 'Spalte $col';
  @override
  String sudokuConstraintBox(int box) => 'Block $box';
  @override
  String sudokuConstraintCage(int cage, int sum) => 'Käfig $cage (Summe $sum)';
  @override
  String get sudokuConstraintMainDiagonal => 'Hauptdiagonale';
  @override
  String get sudokuConstraintAntiDiagonal => 'Antidiagonale';
  @override
  String sudokuConstraintDisjointGroup(int group) => 'Disjunkte Gruppe $group';
  @override
  String sudokuStepStart(int clues) =>
      'Start: $clues Vorgaben. Die Notizen zeigen, welche Ziffern jede '
      'leere Zelle noch annehmen kann: Eine Ziffer fällt weg, sobald eine '
      'Zelle derselben Zeile, Spalte oder Box sie schon enthält.';
  @override
  String sudokuStepNakedSingle(String cell, int value, int eliminated) =>
      'Nackter Single: $cell hat nur noch einen Kandidaten, also $value. '
      'Damit fällt $value in $eliminated Nachbarzellen weg.';
  @override
  String sudokuStepHiddenSingle(String unit, int value, String cell) =>
      'Versteckter Single: In $unit passt $value nur in $cell, auch wenn '
      '$cell noch andere Kandidaten hat.';
  @override
  String sudokuStepGuess(String cell, int value, String alternatives) =>
      'Kein Logikschritt greift mehr, also nimmt der Solver etwas an. '
      'Er wählt $cell, '
      'weil sie die wenigsten Kandidaten hat, probiert $value und merkt '
      'sich $alternatives fürs Backtracking.';
  @override
  String sudokuStepLastOption(String cell, int value) =>
      'Letzte Möglichkeit: Alle anderen Werte für $cell sind gescheitert, '
      'also $value (unter den früheren Annahmen).';
  @override
  String sudokuStepContradictionCell(String cell) =>
      'Widerspruch: $cell hat keinen Kandidaten mehr.';
  @override
  String sudokuStepContradictionUnit(String unit, int value) =>
      'Widerspruch: $value hat in $unit keinen Platz mehr.';
  @override
  String sudokuStepBacktrack(String cell) =>
      'Backtracking: alles seit der Annahme in $cell zurücknehmen und '
      'deren nächste Möglichkeit probieren.';
  @override
  String get sudokuStepSolved =>
      'Gelöst: Jede Zelle ist gefüllt und jede Regel erfüllt.';
  @override
  String sudokuExplainStats(
          int naked, int hidden, int guesses, int backtracks, int depth) =>
      'Nackte Singles $naked · Versteckte Singles $hidden · Annahmen '
      '$guesses · Backtracks $backtracks · Max. Tiefe $depth';
  @override
  String get sudokuExplainLogicOnly =>
      'Allein durch Logik gelöst: keine Annahme nötig.';
  @override
  String sudokuExplainTruncated(int shown) =>
      'Die ersten $shown Schritte werden gezeigt; die Lösung lief weiter.';
  @override
  String sudokuStepCage(int sum, int size, String combos, int removed) =>
      'Käfigsumme: $size Zellen müssen mit verschiedenen Ziffern $sum '
      'ergeben. Die möglichen Ziffernmengen sind $combos. Ihre gültigen '
      'Zuordnungen zu den Zellen zeigen, dass $removed Kandidaten in ihren '
      'jeweiligen Zellen nicht möglich sind; sie werden entfernt.';
  @override
  String sudokuStepLocked(int digit, String unit, String other, int removed) =>
      'Gesperrte Kandidaten: In $unit kann $digit nur in Zellen stehen, '
      'die auch zu $other gehören. Wo immer sie landet, hat $other dort '
      'seine $digit, daher fällt $digit aus $removed weiteren Zellen von '
      '$other.';
  @override
  String sudokuStepNakedSubset(
          int size, String cells, String digits, String unit, int removed) =>
      'Nacktes ${size == 2 ? 'Paar' : 'Tripel'}: $cells in $unit enthalten '
      'zusammen nur $digits, also gehören diese Ziffern in diese $size '
      'Zellen und fallen aus dem Rest von $unit ($removed Kandidaten).';
  @override
  String sudokuStepHiddenSubset(
          int size, String digits, String unit, String cells, int removed) =>
      'Verstecktes ${size == 2 ? 'Paar' : 'Tripel'}: In $unit passen '
      '$digits nur in $cells, also müssen diese Zellen sie aufnehmen und '
      'verlieren ihre übrigen Kandidaten ($removed entfernt).';
  @override
  String sudokuStepContradictionCage(int sum) =>
      'Widerspruch: Der Käfig mit Summe $sum kann seine Summe nicht mehr '
      'erreichen.';
  @override
  String sudokuExplainEliminations(
          int cages, int locked, int nakedSubsets, int hiddenSubsets) =>
      'Käfigsummen $cages · Gesperrte Kandidaten $locked · Nackte '
      'Paare/Tripel $nakedSubsets · Versteckte Paare/Tripel $hiddenSubsets';
  @override
  String get sudokuSearchTreeTitle => 'Suchbaum';
  @override
  String get sudokuSearchTreeHint =>
      'Jeder Punkt ist eine Annahme, Kinder sind spätere Annahmen. Rote '
      'Punkte führten zu einem Widerspruch, grüne bilden den Weg zur '
      'Lösung. Der umrandete Punkt ist die Annahme im aktuellen Schritt.';
  @override
  String sudokuSearchTreeTruncated(int shown) =>
      'Die ersten $shown Annahmen werden gezeigt.';
  @override
  String get sudokuStepPrevious => 'Vorheriger Schritt';
  @override
  String get sudokuStepNext => 'Nächster Schritt';
  @override
  String get sudokuEnterClues =>
      'Vorgaben eingeben: Zelle antippen, dann Ziffer, um ein eigenes '
      'Rätsel zu analysieren.';
  @override
  String get sudokuConstraintStartingPosition => 'Ausgangsstellung';

  @override
  String get moduleConstraintsTitle => 'Bedingungsprobleme';
  @override
  String get moduleConstraintsSubtitle =>
      'Diophantische Gleichungen und Kryptarithmen — ganzzahlige '
      'Lösungen und Ziffernzuordnungen finden.';
  @override
  String get constraintsTabDiophantine => 'Diophantisch';
  @override
  String get constraintsTabCryptarithm => 'Kryptarithmus';
  @override
  String get constraintsTabDsl => 'Freitext';
  @override
  String get constraintsTabFlatZinc => 'FlatZinc';
  @override
  String get constraintsTabMagicSquare => 'Magisches Quadrat';
  @override
  String get constraintsMagicIntro =>
      'Erzeugt ein magisches Quadrat der gewählten Ordnung: die Zahlen '
      '1..N² so angeordnet, dass jede Zeile, jede Spalte und beide '
      'Diagonalen dieselbe Summe ergeben. Jedes „Erzeugen“ zeigt eine '
      'andere Ausrichtung einer Lösung.';
  @override
  String get constraintsMagicSize => 'Größe';
  @override
  String constraintsMagicConstant(int m) => 'Magische Konstante: $m';
  @override
  String constraintsSoftScore(int satisfied, int total) =>
      'Erfüllung: $satisfied / $total';
  @override
  String get constraintsMagicGenerate => 'Erzeugen';
  @override
  String get constraintsMagicHint =>
      'Jede Zeile, Spalte und Diagonale ergibt die magische Konstante.';
  @override
  String get constraintsDslIntro =>
      'Variablen deklarieren mit `vars: x, y in 1..9`, '
      'für Verschiedenheit `allDifferent(x, y, z)`, '
      'jede weitere Zeile ist eine Bedingung (z.B. `x + 2*y == 10`).';
  @override
  String get constraintsDslInputLabel => 'Bedingungsprogramm';
  @override
  String get constraintsDslExamplesButton => 'Beispiele';
  @override
  String get constraintsDslExamplesTooltip => 'Vorgefertigtes Beispiel laden';
  @override
  String constraintsDslExampleTitle(String id) {
    switch (id) {
      case 'magicSum':
        return '3-stellige magische Summe';
      case 'magicSquare3':
        return '3×3 magisches Quadrat';
      case 'magicSquare4':
        return '4×4 magisches Quadrat (Konstante 34)';
      case 'mapColoring':
        return 'Landkartenfärbung (K4)';
      case 'mapColoringAustralia':
        return 'Landkartenfärbung — Australien (3 Farben)';
      case 'mapColoringGermany':
        return 'Landkartenfärbung — Deutschland (braucht 4 Farben)';
      case 'orderedTriples':
        return 'Geordnete Tripel mit Summe 20';
      case 'equalSumSplit':
        return 'Gleichsummenteilung (Mengenpartition)';
      case 'coinChangeMin':
        return 'Wechselgeldproblem (Anzahl minimieren)';
      case 'knapsack':
        return '0/1-Rucksackproblem (Wert maximieren)';
      case 'productionPlanning':
        return 'Produktionsplanung (Gewinn maximieren)';
      case 'assignmentMinCost':
        return 'Zuordnungsproblem (Kosten minimieren)';
      case 'transportation':
        return 'Transportproblem (kostenminimaler Versand)';
      case 'schedulingMakespan':
        return 'Scheduling — Makespan minimieren';
      case 'cumulativeScheduling':
        return 'Kumulatives Scheduling — Kapazität 2';
      case 'rcpsp':
        return 'RCPSP — Crew + Ausrüstung';
      case 'logicGrid':
        return 'Logikrätsel — Deduktion';
      case 'nurseRostering':
        return 'Dienstplan (Schichtmuster)';
      case 'chromaticNumber':
        return 'Chromatische Zahl (wenigste Farben)';
      case 'menuPairing':
        return 'Menü-Kombinationen (Tabelle)';
      case 'packing':
        return '2D-Packung (diffN-Layout)';
      case 'deliveryRoute':
        return 'Lieferroute (circuit / TSP)';
      case 'shiftPrefs':
        return 'Schichtpräferenzen (soft / MaxCSP)';
      case 'committee':
        return 'Ausschusswahl (Mengenvariablen)';
    }
    return id;
  }

  @override
  String get constraintsFlatZincIntro =>
      'FlatZinc-Modell einfügen (typischerweise von mzn2fzn aus einer '
      'MiniZinc-Quelle erzeugt). Der Solver liefert die Standard-'
      'FlatZinc-Ausgabe: `name = wert;` pro `:: output_var`-Annotation, '
      'beendet mit `----------`, gefolgt von `==========` nach der '
      'letzten Lösung.';
  @override
  String get constraintsFlatZincInputLabel => 'FlatZinc-Quelltext';
  @override
  String get constraintsFlatZincAllSolutions => 'Alle Lösungen';
  @override
  String get constraintsFlatZincFirstSolution => 'Erste Lösung';
  @override
  String get constraintsFlatZincExhaustiveOne => '1 Lösung (vollständig)';
  @override
  String constraintsFlatZincExhaustiveN(int n) => '$n Lösungen (vollständig)';
  @override
  String get constraintsFlatZincUnsatisfiable => 'Unerfüllbar';
  @override
  String constraintsFlatZincExampleTitle(String id) {
    switch (id) {
      case 'nqueens4':
        return '4-Damen-Problem';
      case 'binPacking':
        return 'Bin-Packing (3 Objekte, 2 Behälter)';
    }
    return id;
  }

  @override
  String get constraintsExplainFailure => 'Konflikt erklären';
  @override
  String get constraintsExplainHeader => 'Minimaler Konflikt (QuickXplain)';
  @override
  String get constraintsExplainSatisfiable =>
      'Kein Konflikt — das Modell ist tatsächlich erfüllbar.';
  @override
  String constraintsExplainEntryCount(int n) => n == 1
      ? '1 widersprüchliche Bedingung'
      : '$n widersprüchliche Bedingungen';
  @override
  String constraintsExplainAltHeader(int n) =>
      'Ein weiterer minimaler Konflikt ($n Bedingungen)';
  @override
  String get constraintsExportFlatZinc => 'Als FlatZinc exportieren';
  @override
  String get constraintsVisualizeButton => 'Visualisieren';
  @override
  String get constraintsCompareStrategies => 'Strategien vergleichen';
  @override
  String get constraintsStrategyHeader => 'Suchstrategie-Vergleich';
  @override
  String get constraintsStrategyCol => 'Strategie';
  @override
  String get constraintsStrategyDecisions => 'Entscheidungen';
  @override
  String get constraintsStrategyBacktracks => 'Rücksprünge';
  @override
  String get constraintsStrategyPropagations => 'Propagationen';
  @override
  String get constraintsStrategyIterations => 'Iterationen';
  @override
  String get constraintsStrategyTime => 'Zeit';
  @override
  String get constraintsStructureButton => 'Struktur zeigen';
  @override
  String constraintsStructureHeader(int vars, int constraints) =>
      'Constraint-Netz · $vars Variablen · $constraints Constraints';
  @override
  String constraintsColorGraphHeader(int nodes, int colours) =>
      'Graphfärbung · $nodes Knoten · $colours Farben';
  @override
  String get constraintsTraceHeader => 'Propagierungs-Verlauf';
  @override
  String get constraintsTraceIntro =>
      'Schritt für Schritt durch den Löser: jede Entscheidung, jeder von '
      'einer Bedingung aus einem Wertebereich gestrichene Wert, jede '
      'Sackgasse und jedes Backtracking.';
  @override
  String constraintsTraceStepCounter(int current, int total) =>
      'Schritt $current / $total';
  @override
  String get constraintsTraceInitial =>
      'Anfangs-Wertebereiche — vor jeder Suche.';
  @override
  String constraintsTraceDecision(String variable, int value) =>
      'Entscheidung: versuche $variable = $value';
  @override
  String constraintsTracePrune(String values, String variable, String cause) =>
      'Streiche $values aus $variable — $cause';
  @override
  String constraintsTraceWipeout(String variable, String cause) =>
      'Sackgasse: Wertebereich von $variable geleert — $cause';
  @override
  String get constraintsTraceBacktrack =>
      'Backtracking — letzte Entscheidung zurücknehmen und einen anderen '
      'Wert versuchen.';
  @override
  String constraintsTraceBackjump(int from, int to) =>
      'Backjump von Tiefe $from zu Tiefe $to.';
  @override
  String get constraintsTraceSolutionStep => 'Lösung — alle Variablen belegt.';
  @override
  String constraintsTraceStats(
          int decisions, int prunes, int wipeouts, int backtracks) =>
      'Entscheidungen $decisions · Streichungen $prunes · Sackgassen '
      '$wipeouts · Backtracks $backtracks';
  @override
  String get constraintsTracePropagationOnly =>
      'Allein durch Propagation gelöst: keine Entscheidung nötig.';
  @override
  String get constraintsTraceTopConstraints =>
      'Bedingungen, die die meisten Werte gestrichen haben:';
  @override
  String constraintsTraceConstraintWork(
          int removed, int prunes, int wipeouts) =>
      '$removed Werte · $prunes Streichungen · $wipeouts Sackgassen';
  @override
  String get constraintsMagicVisualizeHint =>
      'Visualisieren zeigt, wie der Solver ein Quadrat aufbaut: welche '
      'Zelle er festlegt, was die Summen und die Alle-verschieden-Regel '
      'streichen und wo er zurückgeht. Für 3×3 und 4×4 verfügbar.';
  @override
  String get constraintsTraceSolved => 'Gelöst';
  @override
  String get constraintsTraceUnsat => 'Keine Lösung — Suchraum erschöpft';
  @override
  String constraintsTraceTruncatedNote(int n) =>
      'Verlauf bei $n Schritten gekappt — die Wiedergabe ist nur ein '
      'Anfangsausschnitt.';
  @override
  String get constraintsTraceObjectiveNote =>
      'Es wird die Zulässigkeitssuche gezeigt; die Zielfunktion wird '
      'ignoriert.';
  @override
  String get constraintsTracePlay => 'Abspielen';
  @override
  String get constraintsTracePause => 'Pause';
  @override
  String get constraintsTraceRestart => 'Neu starten';
  @override
  String get constraintsTraceStepBack => 'Schritt zurück';
  @override
  String get constraintsTraceStepForward => 'Schritt vor';
  @override
  String get constraintsExportedHeader => 'FlatZinc-Übersetzung';

  @override
  String get constraintsDiophantineIntro =>
      'Beschränkte ganzzahlige Variablen deklarieren, die zu '
      'erfüllenden Bedingungen auflisten — der Löser zählt alle '
      'ganzzahligen Lösungen auf (gedeckelt bei 100).';
  @override
  String get constraintsCryptarithmIntro =>
      'Ein Rätsel der Form `WORT1 + WORT2 = WORT3` eingeben (oder `−` '
      'statt `+`). Jeder Buchstabe ist eine Ziffer 0..9; führende '
      'Ziffern ungleich null; alle Buchstaben tragen verschiedene Ziffern.';
  @override
  String get constraintsVariablesLabel => 'Variablen';
  @override
  String get constraintsVariablesHint =>
      'Eine pro Zeile, Format: name in min..max';
  @override
  String get constraintsConstraintsLabel => 'Bedingungen';
  @override
  String get constraintsConstraintsHint =>
      'Eine pro Zeile. Vergleiche, Arithmetik, in/not-in Mengen alle '
      'unterstützt.';
  @override
  String get constraintsCryptarithmInputLabel => 'Rätsel';
  @override
  String get constraintsSolveButton => 'Lösen';
  @override
  String get constraintsCancelButton => 'Abbrechen';
  @override
  String get constraintsBadVarLine =>
      'Variablenzeile nicht erkannt. Erwartet: `name in min..max`';
  @override
  String get constraintsNoSolutions => 'Keine Lösungen.';
  @override
  String get constraintsCryptarithmFoundHeader => 'Ziffernzuordnung';
  @override
  String constraintsSolutionsHeader(int n) =>
      n == 1 ? '1 Lösung' : '$n Lösungen';
  @override
  String constraintsTruncatedHeader(int n) =>
      'Die ersten $n Lösungen (weitere existieren)';
  @override
  String get constraintsCopyResult => 'Lösungen kopieren';
  @override
  String get constraintsCopiedToast => 'In Zwischenablage kopiert.';
  @override
  String constraintsOptimalHeader(num objective) =>
      'Optimal: Zielfunktion = $objective';

  @override
  String get clearSearchTooltip => 'Suche leeren';
  @override
  String get clearFunctionSlotTooltip => 'Funktion löschen';
  @override
  String get deleteMemorySlotTooltip => 'Speicherplatz löschen';

  @override
  String get helpModeEnableTooltip =>
      'Hilfemodus: jedes Bedienelement antippen für eine Erklärung';
  @override
  String get helpModeDisableTooltip => 'Hilfemodus beenden';
  @override
  String get keypadHelpLearnMore => 'Mehr erfahren';
  @override
  String get historyHelpTitle => 'So wurde dies berechnet';
  @override
  String historyHelpComputedVia(String engine) => 'Berechnet über $engine';
  @override
  String get historyHelpDirectEvaluation =>
      'Direkte numerische Auswertung — kein symbolischer Aufruf.';
  @override
  String get historyHelpShowSteps => 'Schritte anzeigen';

  @override
  String get moduleHelpTooltip => 'Was macht dieses Modul?';
  @override
  String moduleHelpTitle(ModuleHelpKind kind) {
    switch (kind) {
      case ModuleHelpKind.curveSketching:
        return 'Kurvendiskussion';
      case ModuleHelpKind.planes:
        return 'Ebenenanalyse';
      case ModuleHelpKind.conicSections:
        return 'Kegelschnitte';
      case ModuleHelpKind.statistics:
        return 'Statistik';
      case ModuleHelpKind.graphing3D:
        return '3D-Diagramme';
      case ModuleHelpKind.scene3D:
        return '3D-Szene';
      case ModuleHelpKind.constraints:
        return 'Bedingungen';
      case ModuleHelpKind.sudoku:
        return 'Sudoku';
      case ModuleHelpKind.notepad:
        return 'Notizblock';
    }
  }

  @override
  String moduleHelpDescription(ModuleHelpKind kind) {
    switch (kind) {
      case ModuleHelpKind.curveSketching:
        return 'Vollständige Analyse einer Funktion f(x) einer Variablen: '
            'Definitionsbereich, Nullstellen, Ableitung und kritische '
            'Punkte, Extrema, Wendepunkte, Asymptoten sowie eine Skizze. '
            'Funktion in das Eingabefeld eingeben — Ergebnisse erscheinen '
            'bei Tipp.';
      case ModuleHelpKind.planes:
        return 'Analyse von 3D-Ebenen in Koordinatenform '
            '(ax + by + cz = d) oder Parameterform (Punkt + zwei '
            'Richtungsvektoren). Berechnet Normalenvektor, Achsen-'
            'schnittpunkte und paarweise Lagebeziehungen.';
      case ModuleHelpKind.conicSections:
        return 'Klassifiziert einen allgemeinen Kegelschnitt '
            'Ax² + Bxy + Cy² + Dx + Ey + F = 0 als Ellipse, Hyperbel, '
            'Parabel oder entartet und liefert Mittelpunkt, Achsen, '
            'Brennpunkte und Exzentrizität. Nutzt die Diskriminante '
            'B² − 4AC zur Klassifizierung.';
      case ModuleHelpKind.statistics:
        return 'Deskriptive Statistik (Mittel, Median, Varianz, …), '
            'lineare Regression mit R² und Residuen, Normal- und '
            'Binomialverteilung mit PDF / CDF / Quantilen sowie '
            'Hypothesentests: Welch-t, gepaarter t-Test, einfache '
            'ANOVA, Chi-Quadrat-Anpassungs- und Unabhängigkeitstest, '
            'Fisher-Exakt, Wilcoxon-Vorzeichen-Rang und Vorzeichentest. '
            'Die Tests liefern Teststatistik, p-Wert und (falls '
            'anwendbar) ein Konfidenzintervall zum gewählten α.';
      case ModuleHelpKind.graphing3D:
        return 'Stellt z = f(x, y) als drehbares Drahtgitter dar. '
            'Ziehen zum Drehen; Pinch / Scrollen zum Zoomen. Die '
            'Resample-Aktion baut das Netz für die aktuelle Zoomstufe '
            'neu auf, sodass das Detail der Kameradistanz folgt.';
      case ModuleHelpKind.scene3D:
        return 'Mehrere 3D-Objekte gemeinsam darstellen — Ebenen, '
            'Geraden, Kugeln und Quadriken — in einer geteilten Szene. '
            'Hilfreich zur Visualisierung von Schnitten (etwa zweier '
            'Ebenen entlang einer Geraden) und zum schrittweisen Aufbau '
            'geometrischer Argumentationen.';
      case ModuleHelpKind.constraints:
        return 'Löst kombinatorische Probleme: diophantische '
            'Gleichungen (ganzzahlige Lösungen von ax + by = c), '
            'Kryptarithmen (SEND + MORE = MONEY-Stil), eine kleine '
            'DSL für endliche Bereichsbedingungen (`allDifferent`, '
            '`noOverlap`, `cumulative`, `minimize` / `maximize`) sowie '
            'einen FlatZinc-Tab für Probleme im MiniZinc-Zwischenformat.';
      case ModuleHelpKind.sudoku:
        return 'Löst 4×4- und 9×9-Rätsel einschließlich der Varianten '
            'X (Diagonale), Killer (Käfigsummen) und Disjoint-Groups. '
            'Der schrittweise Solver zeigt den Suchbaum, sodass '
            'nachvollziehbar wird, wie der Algorithmus die Kandidaten '
            'einschränkt. Tippstufen zeigen entweder die nächste '
            'Zellantwort oder eine logische Begründung dafür.';
      case ModuleHelpKind.notepad:
        return 'Ein Mehrdokument-Notizblock, in dem jede Zeile eine lebende Formel ist, die beim Tippen neu berechnet wird. Neben gewöhnlicher Mathematik unterstützt er Direktiven: `use <Dokument>` importiert die Variablen eines anderen Dokuments; `fzn:` löst ein eingebettetes FlatZinc-Modell; und `Ans in <Einheit>` verwendet das Ergebnis der vorherigen Zeile weiter, optional mit Einheitenumrechnung. Export nach LaTeX oder Markdown.';
    }
  }

  @override
  String get workedExamplesTitle => 'Beispielaufgaben';
  @override
  String get workedExamplesSearchHint => 'Beispiele suchen…';
  @override
  String get workedExamplesEmpty => 'Keine Beispiele passen zum Filter.';
  @override
  String get workedExamplesCopy => 'Ausdruck kopieren';
  @override
  String get workedExamplesCopied =>
      'In Zwischenablage kopiert. Im Rechner einfügen zum Ausprobieren.';
  @override
  String get workedExamplesInsert => 'In Rechner einfügen';
  @override
  String get workedExamplesCatAll => 'Alle';
  @override
  String get workedExamplesCatCalculus => 'Analysis';
  @override
  String get workedExamplesCatAlgebra => 'Algebra';
  @override
  String get workedExamplesCatLinearAlgebra => 'Lineare Algebra';
  @override
  String get workedExamplesCatNumberTheory => 'Zahlentheorie';
  @override
  String get workedExamplesCatStatistics => 'Statistik';
  @override
  String get workedExamplesCatUnits => 'Einheiten';
  @override
  String get workedExamplesCatConstraints => 'Bedingungen';
  @override
  String? workedExampleTitle(String id) {
    switch (id) {
      case 'dsolveSecondOrder':
        return 'Lineare DGL zweiter Ordnung';
      case 'dsolveSeparable':
        return 'Trennbare DGL erster Ordnung';
      case 'taylorSine':
        return 'Taylor-Reihe des Sinus';
      case 'rationalLogIntegral':
        return 'Logarithmisches Integral (Rothstein–Trager)';
      case 'quadraticInequality':
        return 'Quadratische Ungleichung';
      case 'piecewiseSelect':
        return 'Abschnittsweise Auswahl';
      case 'linsolveSystem':
        return 'Lineares Gleichungssystem lösen';
      case 'killerSudoku':
        return 'Killer-Sudoku (9×9)';
      case 'constraintEditor':
        return 'Freitext-Bedingungseditor';
      case 'dslMagicSquare':
        return '3×3 magisches Quadrat (DSL)';
      case 'dslMapColoring':
        return 'Landkartenfärbung K4 (DSL)';
      case 'dslOrderedTriples':
        return 'Geordnete Tripel mit Summe 20 (DSL)';
      case 'dslMapColoringAustralia':
        return 'Landkartenfärbung — Australien, 3 Farben (DSL)';
      case 'dslMapColoringGermany':
        return 'Landkartenfärbung — Deutschland, braucht 4 Farben (DSL)';
      case 'dslKnapsack':
        return '0/1-Rucksackproblem — Wert maximieren (DSL)';
      case 'dslTransportation':
        return 'Transportproblem — kostenminimaler Versand (DSL)';
      case 'dslCoinChange':
        return 'Wechselgeldproblem — Anzahl minimieren (DSL)';
      case 'dslSchedulingMakespan':
        return 'Einzelmaschinen-Scheduling — Makespan minimieren (DSL)';
      case 'dslCumulativeScheduling':
        return 'Parallele Ressourcen-Planung — cumulative (DSL)';
      case 'dslRcpsp':
        return 'Projektplanung RCPSP — zwei Ressourcen (DSL)';
      case 'cryptSendMoreMoney':
        return 'Kryptarithmus — SEND + MORE = MONEY';
      case 'derivPoly':
        return 'Ableitung eines Polynoms';
      case 'chainRule':
        return 'Beispiel zur Kettenregel';
      case 'integralByParts':
        return 'Unbestimmtes Integral mit partieller Integration';
      case 'definiteIntegral':
        return 'Bestimmtes Integral';
      case 'sinxOverX':
        return 'Grenzwert an einer behebbaren Singularität';
      case 'partialFractions':
        return 'Partialbruchzerlegung';
      case 'quadraticFormula':
        return 'Mitternachtsformel';
      case 'factorCubic':
        return 'Polynom faktorisieren';
      case 'expandBinomial':
        return 'Binom ausmultiplizieren';
      case 'simplifyRational':
        return 'Rationalen Ausdruck vereinfachen';
      case 'polyGcdShared':
        return 'Polynom-ggT';
      case 'polyDiscriminantCubic':
        return 'Polynom-Diskriminante';
      case 'polyFactorMod':
        return 'Faktorisierung modulo p';
      case 'matrixDet':
        return 'Determinante einer Matrix';
      case 'matrixInverse':
        return 'Inverse einer Matrix';
      case 'rref':
        return 'Reduzierte Zeilenstufenform';
      case 'factorial100':
        return 'Fakultät — exakte Ganzzahl';
      case 'fibonacci50':
        return 'Fibonacci-Zahl';
      case 'gcdEuclid':
        return 'ggT mit Euklid';
      case 'isprime':
        return 'Primzahltest (kleines n)';
      case 'piPrecision':
        return 'π auf 100 Stellen';
      case 'ePrecision':
        return 'e auf 50 Stellen';
      case 'factorint360':
        return 'Primfaktorzerlegung';
      case 'nextprime1000':
        return 'Nächste Primzahl nach 1000';
      case 'mersenneM31':
        return 'Mersenne-Primzahl M31';
      case 'divisors12':
        return 'Alle Teiler';
      case 'eulerTotient':
        return 'Eulersche φ-Funktion';
      case 'modpowCrypto':
        return 'Modulare Exponentiation';
      case 'contFracPi':
        return 'Kettenbruch von π';
      case 'zetaBasel':
        return 'Riemannsche Zeta — das Basler Problem';
      case 'gammaHalf':
        return 'Gamma an einer halbzahligen Stelle';
      case 'evalfLn10':
        return 'Arbiträr-präzises evalf';
      case 'besselJZero':
        return 'Besselfunktion';
      case 'cevalfPow':
        return 'Komplexe Hochpräzision';
      case 'booleanIsprimeAnd':
        return 'Primzahl und beschränkt';
      case 'booleanEqualityFold':
        return 'Gleichheits-Auswertung';
      case 'booleanNotPrime':
        return 'Negation';
      case 'booleanOrChain':
        return 'Disjunktion über Vergleiche';
      case 'booleanIfFold':
        return 'Bedingte Auswertung';
      case 'compoundInterest':
        return 'Zinseszins';
      case 'zScore':
        return 'Z-Wert nachschlagen';
      case 'statsHypothesisTests':
        return 'Hypothesentests-Bereich';
      case 'statsWelchTwoSample':
        return 'Welch-Zweistichproben-t (vorbefüllt)';
      case 'statsAnovaThreeGroups':
        return 'Einfaktorielle ANOVA (vorbefüllt)';
      case 'statsChiSquareGof':
        return 'Chi-Quadrat-Anpassungstest (vorbefüllt)';
      case 'unitConversion':
        return 'Einheitenumrechnung inline';
      case 'compositeDim':
        return 'Arithmetik mit zusammengesetzten Dimensionen';
    }
    return additionalWorkedExampleTitle('de', id);
  }

  @override
  String? workedExampleDescription(String id) {
    switch (id) {
      case 'dsolveSecondOrder':
        return 'y\'\' + 3y\' + 2y = 0 über die charakteristischen Wurzeln −1, −2.';
      case 'dsolveSeparable':
        return 'y\' = x·y trennt sich zu ∫dy/y = ∫x dx → C·e^(x²/2).';
      case 'taylorSine':
        return 'sin(x) um 0 bis 7 Terme — ungerade Potenzen, (−1)^k/(2k+1)!.';
      case 'rationalLogIntegral':
        return '∫ (3x² + 1)/(x³ + x + 1) dx = log(x³ + x + 1) — der Zähler ist die Ableitung des Nenners.';
      case 'quadraticInequality':
        return 'x² − 4 > 0 lösen → x < −2 ∨ x > 2 (Vorzeichenanalyse zwischen den Nullstellen).';
      case 'piecewiseSelect':
        return 'piecewise(Bedingung, Wert, …) wählt den ersten wahren Zweig — Grundlage abschnittsweiser benutzerdefinierter Funktionen.';
      case 'linsolveSystem':
        return 'x + y = 3, x − y = 1 → x = 2, y = 1 (exaktes symbolisches linsolve).';
      case 'killerSudoku':
        return 'Öffnet das Sudoku-Modul mit dem 9×9-Killer-Voreinstellung.';
      case 'constraintEditor':
        return 'Öffnet das Bedingungsmodul — Variablen deklarieren, Bedingungen hinzufügen, lösen.';
      case 'dslMagicSquare':
        return 'Lädt das 9-Variablen-Programm für das magische Quadrat in den DSL-Editor.';
      case 'dslMapColoring':
        return 'Lädt eine K4-Graphfärbung mit 3 Farben — bewusst unlösbar, um den "keine Lösungen"-Pfad zu zeigen.';
      case 'dslOrderedTriples':
        return 'Lädt ein DSL-Programm, das (a, b, c) mit a < b < c und a + b + c = 20 aufzählt.';
      case 'dslMapColoringAustralia':
        return 'Lädt die 7-Regionen-Australienkarte (Russell & Norvig). Drei Farben genügen; die Lösung wird als farbige Karte dargestellt.';
      case 'dslMapColoringGermany':
        return 'Lädt die 16 Bundesländer. Anders als Australien braucht diese Karte vier Farben (ein 5-Rad um Thüringen) — ändere den Wertebereich auf 1..3, um sie unlösbar zu machen.';
      case 'dslKnapsack':
        return 'Lädt ein 0/1-Rucksackproblem mit vier Gegenständen unter Gewichtsschranke; `maximize` liefert die wertoptimale Auswahl.';
      case 'dslTransportation':
        return 'Lädt ein ausgeglichenes Transportproblem (2 Lager → 3 Kunden, Angebot = Nachfrage); `minimize` liefert den kostenminimalen Versandplan.';
      case 'dslCoinChange':
        return 'Lädt ein DSL-Programm, das 17¢ mit den wenigsten Münzen aus {1, 5, 10, 25} via `minimize` zahlt.';
      case 'dslSchedulingMakespan':
        return 'Lädt ein DSL-Programm, das drei Aufgaben (Dauern 4/3/2) auf einer Maschine via `noOverlap` plant und den Makespan minimiert.';
      case 'dslCumulativeScheduling':
        return 'Lädt ein DSL-Programm, das drei Aufgaben auf einer Ressource der Kapazität 2 via `cumulative` plant und den Makespan minimiert.';
      case 'dslRcpsp':
        return 'Lädt ein DSL-Programm mit zwei parallelen `cumulative`-Auflagen (Crew + Ausrüstung, je Kapazität 3) über vier Aufgaben; minimiert den Makespan.';
      case 'cryptSendMoreMoney':
        return 'Öffnet den Kryptarithmus-Tab mit dem klassischen Rätsel: jeder Buchstabe ist eine andere Ziffer 0–9 (keine führenden Nullen). Eindeutige Lösung 9567 + 1085 = 10652.';
      case 'derivPoly':
        return 'd/dx von x³ − 4x + 7 an beliebigem x.';
      case 'chainRule':
        return 'd/dx von sin(x²) — Kettenregel auf das innere x².';
      case 'integralByParts':
        return '∫ x·sin(x) dx — wähle u = x, dv = sin(x) dx.';
      case 'definiteIntegral':
        return '∫₀¹ x² dx = 1/3 nach dem Hauptsatz.';
      case 'sinxOverX':
        return 'lim x→0 sin(x)/x = 1 (der Klassiker).';
      case 'partialFractions':
        return '∫ 1/(x² − 1) dx mit Cover-up an x = ±1.';
      case 'quadraticFormula':
        return 'Löse 2x² + 5x − 3 = 0 über die Diskriminante.';
      case 'factorCubic':
        return 'Faktorisiere x³ − 8 — Summen-/Differenzformel.';
      case 'expandBinomial':
        return '(x + 2)⁵ ausmultiplizieren — Pascalsches Dreieck.';
      case 'simplifyRational':
        return '(x² − 4)/(x − 2) auf einfachste Form kürzen.';
      case 'polyGcdShared':
        return 'polygcd(x² − 1, x² − 2x + 1) — der gemeinsame Faktor x − 1.';
      case 'polyDiscriminantCubic':
        return 'polydiscriminant(x³ − 2) — ungleich null ⇒ verschiedene '
            'Nullstellen.';
      case 'polyFactorMod':
        return 'polyfactor(x⁴ + 1, mod=2) — über ℚ irreduzibel, '
            '(x + 1)⁴ über 𝔽₂.';
      case 'matrixDet':
        return 'det einer 3×3 — Laplace-Entwicklung oder Zeilen­reduktion.';
      case 'matrixInverse':
        return 'Inverse einer 2×2 — A⁻¹ = adj(A)/det(A).';
      case 'rref':
        return 'rref einer 2×3-erweiterten Systemmatrix.';
      case 'factorial100':
        return '100! — 158 Ziffern, im Exakt-Ganzzahl-Modus erhalten.';
      case 'fibonacci50':
        return 'fib(50) — Rekursion bis zu einem großen Glied.';
      case 'gcdEuclid':
        return 'gcd(252, 105) — die ursprüngliche Rekursion.';
      case 'isprime':
        return 'isprime(2027) — schnelle Probedivision.';
      case 'piPrecision':
        return 'pi(100) — hochpräzise Konstante über MPFR.';
      case 'ePrecision':
        return 'e(50) — gleiche MPFR-Pipeline wie pi(N).';
      case 'factorint360':
        return 'factorint(360) → 2³ · 3² · 5 mit Unicode-Hochzahlen.';
      case 'nextprime1000':
        return 'nextprime(1000) — FLINT-gestützt über SymEngine ntheory.';
      case 'mersenneM31':
        return 'factorint(2^31 − 1) — bestätigt die achte Mersenne-Primzahl '
            'als einzelnen Faktor.';
      case 'divisors12':
        return 'divisors(12) → 1, 2, 3, 4, 6, 12 — aus der '
            'Primfaktorzerlegung abgeleitet.';
      case 'eulerTotient':
        return 'totient(36) — Anzahl der zu 36 teilerfremden Reste.';
      case 'modpowCrypto':
        return 'modpow(2, 100, 1000000007) — Kern von RSA / Diffie-Hellman.';
      case 'contFracPi':
        return 'cfrac(pi, 10) — die Entwicklung [3; 7, 15, 1, 292, …] '
            'hinter 355/113.';
      case 'zetaBasel':
        return 'zeta(2) — Eulers ζ(2) = π²/6 ≈ 1,6449.';
      case 'gammaHalf':
        return 'gamma(0.5) — Γ(½) = √π ≈ 1,7725.';
      case 'evalfLn10':
        return 'evalf(ln(10), 50) — beliebiger Ausdruck auf 50 Stellen.';
      case 'besselJZero':
        return 'besselj(0, 1) — J₀(1) ≈ 0,7652, über MPFR. Zeichne '
            'besselj(0, x).';
      case 'cevalfPow':
        return 'cevalf((1+I)^10, 20) — (1+i)¹⁰ = 32i, über MPC.';
      case 'booleanIsprimeAnd':
        return 'isprime(17) und 17 < 20 — beide Teile wahr, also ist die '
            'Konjunktion wahr.';
      case 'booleanEqualityFold':
        return '2 == 2 — konstante Operanden werden zu „wahr" reduziert.';
      case 'booleanNotPrime':
        return 'not isprime(15) — 15 = 3·5, also ergibt die Verneinung wahr.';
      case 'booleanOrChain':
        return '(5 > 3) oder (1 == 2) — der erste Teil ist wahr, deshalb ist '
            'die gesamte Disjunktion wahr.';
      case 'booleanIfFold':
        return 'if(isprime(7), 100, 200) — die Bedingung wird zu „wahr" '
            'ausgewertet, also gewinnt der Then-Zweig.';
      case 'compoundInterest':
        return '1000 € zu 5 % über 10 Jahre, jährliche Verzinsung.';
      case 'zScore':
        return 'Zum Statistik-Reiter → Verteilungen wechseln, um Φ(1,96) '
            '≈ 0,975 zu berechnen.';
      case 'statsHypothesisTests':
        return 'Öffnet das Statistik-Modul direkt auf dem Tests-Reiter — '
            'Einstichproben-t, Zweistichproben-t (Welch), gepaart, ANOVA, '
            'Chi-Quadrat und Wilcoxon — mit vorbefüllten Beispieldaten.';
      case 'statsWelchTwoSample':
        return 'Öffnet den Tests-Reiter beim Welch-Zweistichproben-t mit '
            'zwei bereits eingetragenen Gruppen ungleicher Varianz.';
      case 'statsAnovaThreeGroups':
        return 'Öffnet den Tests-Reiter bei der einfaktoriellen ANOVA mit '
            'drei bereits eingetragenen, getrennten Gruppen.';
      case 'statsChiSquareGof':
        return 'Öffnet den Tests-Reiter beim Chi-Quadrat-Anpassungstest mit '
            'bereits eingetragenen beobachteten Häufigkeiten gegen eine '
            'Gleichverteilung.';
      case 'unitConversion':
        return '100 km/h in mph umgerechnet — V2 inline-Parser.';
      case 'compositeDim':
        return '100 m / 10 s ergibt eine Geschwindigkeit in m/s — V5-Parser.';
    }
    return additionalWorkedExampleDescription('de', id);
  }

  // Round 100: DE function-reference prose. CAS category translated
  // as the pilot; other categories return null and fall back to the
  // English catalog until translated.
  @override
  String? functionRefDescription(String id) {
    switch (id) {
      case 'solve':
        return 'Löst eine Gleichung symbolisch nach einer Variablen auf; '
            'gibt eine Liste von Lösungen zurück.';
      case 'expand':
        return 'Multipliziert Produkte und Potenzen zu einer Summe von '
            'Monomen aus.';
      case 'simplify':
        return 'Fasst gleichartige Terme zusammen, kürzt gemeinsame Faktoren '
            'und wendet algebraische Standardidentitäten an.';
      case 'factor':
        return 'Faktorisiert ein Polynom über den rationalen Zahlen in '
            'irreduzible Faktoren.';
      case 'diff':
        return 'Symbolische erste Ableitung nach einer Variablen.';
      case 'integrate':
        return 'Unbestimmtes Integral (3 Argumente) oder bestimmtes Integral '
            '(5 Argumente) mit numerischem Rückfall.';
      case 'subst':
        return 'Ersetzt jedes freie Vorkommen von `variable` in `expression` '
            'durch `value`. Auch als `substitute(...)` verfügbar.';
      case 'limit':
        return 'Numerischer Grenzwert, wenn `variable` gegen `point` strebt. '
            '`point` kann ein endlicher Wert oder `oo` / `-oo` sein.';
      case 'gcd':
        return 'Größter gemeinsamer Teiler zweier ganzer Zahlen oder Polynome.';
      case 'lcm':
        return 'Kleinstes gemeinsames Vielfaches zweier ganzer Zahlen oder '
            'Polynome.';
      case 'polygcd':
        return 'Normierter größter gemeinsamer Teiler zweier univariater '
            'Polynome über ℚ.';
      case 'polydiv':
        return 'Polynomdivision von `p ÷ q` über ℚ. Gibt Quotient und '
            'Rest zurück.';
      case 'polyresultant':
        return 'Resultante Res(p, q) — genau dann null, wenn `p` und `q` '
            'einen nichtkonstanten gemeinsamen Faktor haben.';
      case 'polydiscriminant':
        return 'Diskriminante eines univariaten Polynoms (Grad ≥ 1) — genau '
            'dann null, wenn `p` eine mehrfache Nullstelle besitzt.';
      case 'polyfactor':
        return 'Faktorisiert ein univariates Polynom über dem endlichen '
            'Körper 𝔽ₖ (k prim) in normierte irreduzible Faktoren. Für die '
            'Faktorisierung über ℚ dient `factor`.';
      case 'gamma':
        return 'Die Gammafunktion Γ(x) — die stetige Fortsetzung von '
            '(x − 1)! auf die reellen und komplexen Zahlen.';
      case 'zeta':
        return 'Die Riemannsche Zetafunktion ζ(s) = Σ 1/nˢ und ihre '
            'analytische Fortsetzung.';
      case 'erf':
        return 'Die Fehlerfunktion erf(x) = (2/√π) ∫₀ˣ e^(−t²) dt — zentral '
            'für die Normalverteilung.';
      case 'lambertw':
        return 'Die Lambertsche W-Funktion — die Umkehrfunktion von x·eˣ, '
            'sodass W(x)·e^(W(x)) = x.';
      case 'beta':
        return 'Die Betafunktion B(a, b) = Γ(a)·Γ(b) / Γ(a + b).';
      case 'besselj':
        return 'Besselfunktion erster Art Jₙ(x) — ganzzahlige Ordnung n, '
            'reelles x. Grafikfähig.';
      case 'bessely':
        return 'Besselfunktion zweiter Art Yₙ(x) (Weber-Funktion) — '
            'ganzzahlige Ordnung n, reelles x > 0. Grafikfähig.';
      case 'factorial':
        return 'Exakte ganzzahlige Fakultät. Kleine `n` nutzen Darts '
            '`BigInt`; große `n` werden an SymEngine übergeben.';
      case 'fibonacci':
        return 'n-te Fibonacci-Zahl. `fib(n)` ist der Kurzname.';
      case 'taylor':
        return 'Taylor-/Maclaurin-Polynom von f am Entwicklungspunkt x0 '
            '(Standard 0), abgeschnitten nach n Termen (Standard 6). '
            'SymEngine-Reihe (FLINT-gestützt); nativ und im Web verfügbar.';
      case 'linsolve':
        return 'Löst ein lineares Gleichungssystem symbolisch (exakte '
            'Brüche/Symbole). Gleichungen durch ";" getrennt, danach die '
            'Unbekannten. Nativ und im Web verfügbar.';
      case 'dsolve':
        return 'Löst eine DGL exakt. Zweiter Ordnung: linear mit konstanten '
            'Koeffizienten (homogen + Ansatz vom Typ der rechten Seite). '
            'Erster Ordnung: trennbar, linear (integrierender Faktor), '
            'Bernoulli und exakt (M dx + N dy = 0 mit dem impliziten '
            'Potenzial F(x, y) = C1).';
      // --- Zahlentheorie ---
      case 'isprime':
        return 'Probabilistischer Primzahltest für ganze Zahlen.';
      case 'nextprime':
        return 'Kleinste Primzahl, die echt größer als `n` ist.';
      case 'prevprime':
        return 'Größte Primzahl, die echt kleiner als `n` ist. Fehler, wenn '
            'keine solche Primzahl existiert (z. B. `prevprime(2)`).';
      case 'factorint':
        return 'Primfaktorzerlegung als `p₁^e₁ · p₂^e₂ · …` mit hochgestellten '
            'Unicode-Exponenten.';
      case 'divisors':
        return 'Alle positiven Teiler von `n`, aufsteigend sortiert und durch '
            'Komma getrennt.';
      case 'totient':
        return 'Eulersche φ-Funktion φ(n): Anzahl der zu `n` teilerfremden '
            'Zahlen in 1..n.';
      case 'modpow':
        return 'Modulare Exponentiation `aᵉ mod m`. Ein negativer Exponent '
            'nutzt das modulare Inverse von `a` (sofern es existiert).';
      case 'modinv':
        return 'Modulares Inverses `a⁻¹ mod m` über den erweiterten '
            'euklidischen Algorithmus. Fehler, wenn `ggT(a, m) ≠ 1`.';
      case 'jacobi':
        return 'Jacobi-Symbol (a/n) ∈ {−1, 0, 1} für ungerades positives `n`; '
            'verallgemeinert das Legendre-Symbol.';
      case 'cfrac':
        return 'Kettenbruchentwicklung `[a₀; a₁, …]` von `x` mit `n` Gliedern. '
            '`x` kann `pi` / `e` / `EulerGamma` / `sqrt(2)`, eine rationale '
            'Zahl `p/q` oder eine Dezimalzahl sein.';
      case 'convergent':
        return 'Der k-te Näherungsbruch `p/q` des Kettenbruchs von `x` — eine '
            'beste rationale Näherung für seine Nennergröße.';
      // --- Hochpräzision ---
      case 'pi_precision':
        return 'π auf N Dezimalstellen über MPFR; gibt die reine Ziffernfolge '
            'zurück.';
      case 'e_precision':
        return 'Eulersche Zahl e auf N Dezimalstellen über MPFR.';
      case 'sqrt_precision':
        return 'Quadratwurzel der ganzen Zahl `k` auf N Dezimalstellen über '
            'MPFR. Die zweiargumentige Form wählt den Hochpräzisionspfad.';
      case 'eulergamma_precision':
        return 'Euler-Mascheroni-Konstante γ ≈ 0,5772… auf N Dezimalstellen '
            'über MPFR.';
      case 'evalf':
        return 'Wertet einen beliebigen reellen Ausdruck auf N Dezimalstellen '
            'über MPFR aus — der arbiträr-präzise Zahlenwert von `expr`.';
      // --- Matrizen / Lineare Algebra ---
      case 'cevalf':
        return 'Komplexe arbiträr-präzise Auswertung — wie `evalf`, behält '
            'aber den Imaginärteil und gibt `a + b·I` auf N Stellen über '
            'MPC zurück.';
      case 'matrix_literal':
        return 'Matrix-Literal: eine Liste von Zeilen, jede Zeile eine Liste '
            'von Zellausdrücken. Zellen können Zahlen, Brüche oder symbolisch '
            'sein.';
      case 'det':
        return 'Determinante einer quadratischen Matrix. Gibt einen '
            'symbolischen Skalar zurück.';
      case 'inv':
        return 'Inverse einer quadratischen, regulären Matrix. Fehler, wenn '
            '`det = 0`.';
      case 'transpose':
        return 'Transponierte: Vertauschen von Zeilen und Spalten. '
            'Funktioniert auch für rechteckige Matrizen.';
      case 'rref':
        return 'Reduzierte Zeilenstufenform über den Gauß-Jordan-Algorithmus. '
            'Funktioniert über symbolische/rationale Einträge.';
      case 'matrix_arithmetic':
        return 'Elementweise Addition/Subtraktion und Matrizenmultiplikation '
            'auf `Matrix(...)`-Literalen.';
      case 'eigenvalues':
        return 'Eigenwerte einer quadratischen numerischen Matrix über den '
            'QR-Algorithmus. Gibt auch komplexe Eigenwerte zurück.';
      case 'eigenvectors':
        return 'Eigenwerte und Eigenvektoren einer quadratischen numerischen '
            'Matrix. Eigenvektoren für 2×2-Matrizen mit reellen Eigenwerten.';
      // --- Statistik ---
      case 'mean':
        return 'Arithmetisches Mittel einer Stichprobe als Zahlenliste. Im '
            'Reiter „Deskriptive Statistik" des Statistik-Moduls zusammen mit '
            'den üblichen Kennzahlen verfügbar.';
      case 'one_sample_t':
        return 'Einstichproben-t-Test: Weicht das Stichprobenmittel von einem '
            'angenommenen Populationsmittel μ₀ ab? Gibt t, df = n−1 und einen '
            'zweiseitigen p-Wert aus.';
      case 'welch_t':
        return 'Zweistichproben-t-Test bei ungleichen Varianzen '
            '(Welch-Satterthwaite). Robuste Standardwahl, wenn die beiden '
            'Gruppen unterschiedliche Streuungen haben können.';
      case 'paired_t':
        return 'Gepaarter t-Test auf Differenzen innerhalb der '
            'Versuchseinheiten gegen μ₀ = 0. Wird verwendet, wenn dieselben '
            'Einheiten zweimal gemessen werden (vorher/nachher).';
      case 'anova_1':
        return 'Einfaktorielle Varianzanalyse (ANOVA) über K unabhängige '
            'Gruppen. Prüft, ob sich die Gruppenmittelwerte unterscheiden; '
            'gibt eine F-Statistik und einen p-Wert aus.';
      case 'chi2_goodness':
        return 'Chi-Quadrat-Anpassungstest: Stimmen die beobachteten '
            'Häufigkeiten mit einer angenommenen Verteilung überein?';
      case 'chi2_independence':
        return 'Chi-Quadrat-Unabhängigkeitstest auf einer Kontingenztafel — '
            'sind zwei kategoriale Variablen unabhängig?';
      case 'fisher_exact':
        return 'Exakter Test nach Fisher auf einer 2×2-Kontingenztafel. '
            'Exakter hypergeometrischer p-Wert — keine Näherung für große '
            'Stichproben.';
      case 'wilcoxon':
        return 'Wilcoxon-Rangsummentest / Mann-Whitney-U — nichtparametrischer '
            'Zweistichprobentest auf Rängen. Robust gegenüber nicht '
            'normalverteilten Daten.';
      case 'sign_test':
        return 'Gepaarter Vorzeichentest — nichtparametrischer, medianbasierter '
            'Test auf gepaarten Differenzen. Zählt, wie oft `nachher > vorher` '
            'gilt.';
      case 'linreg':
        return 'Lineare Regression nach der Methode der kleinsten Quadrate '
            'y = a·x + b für gepaarte (x, y)-Daten. Gibt Steigung, '
            'Achsenabschnitt und Bestimmtheitsmaß R² aus.';
      case 'poly_fit':
        return 'Polynomiale Regression nach kleinsten Quadraten y = c₀ + c₁x + … + c_d·xᵈ eines gewählten Grades d auf gepaarten (x, y)-Daten. Gibt die Koeffizienten und R² aus.';
      case 'exp_fit':
        return 'Exponentielle Regression nach kleinsten Quadraten y = a·e^(b·x) auf gepaarten (x, y)-Daten (über eine log-lineare Transformation). Gibt a, b und R² aus.';
      case 'normal_dist':
        return 'Normalverteilung (Gauß-Verteilung) N(μ, σ): kumulierte '
            'Wahrscheinlichkeit P(X ≤ x) und das Quantil (Umkehrfunktion der '
            'Verteilungsfunktion) zu einer Wahrscheinlichkeit p.';
      case 'binomial_dist':
        return 'Binomialverteilung B(n, p) über n unabhängige Versuche mit '
            'Erfolgswahrscheinlichkeit p: Erwartungswert n·p, Varianz '
            'n·p·(1−p), die Punktwahrscheinlichkeit P(X = k) und die '
            'kumulierte P(X ≤ k).';
      // --- Constraints-DSL ---
      case 'vars':
        return 'Deklariert ganzzahlige Entscheidungsvariablen und ihren '
            'Wertebereich. Stets die erste Zeile eines CrispMath-DSL-Programms.';
      case 'all_different':
        return 'Globale Bedingung „alle Werte paarweise verschieden". Die '
            'wichtigste CP-Bedingung — deutlich stärkere Propagation als '
            'n·(n-1)/2 paarweise `!=`-Klauseln.';
      case 'no_overlap':
        return 'Disjunktive Ablaufplanung: Aufgaben mit gegebenen '
            'Startvariablen und festen Dauern dürfen sich auf einer einzelnen '
            'Maschine zeitlich nicht überlappen.';
      case 'cumulative':
        return 'Kumulative Ablaufplanung auf einer erneuerbaren Ressource '
            'fester Kapazität. Jede Aufgabe hat eine Dauer und einen '
            'Ressourcenbedarf pro Aufgabe.';
      case 'minimize':
        return 'Zielfunktion: minimiert einen linearen Ausdruck über die '
            'Entscheidungsvariablen. In Kombination mit Bedingungen lassen '
            'sich Optimierungs-CSPs lösen.';
      case 'maximize':
        return 'Zielfunktion: maximiert einen linearen Ausdruck. Spiegelbild '
            'von `minimize` — dasselbe Branch-and-Bound, in entgegengesetzter '
            'Richtung.';
      // --- Round 108 DSL-Globals ---
      case 'at_least':
        return 'Mindestens k der angegebenen `name=Wert`-Bedingungen müssen '
            'gelten. Jede Bedingung wird zu einer booleschen Variablen '
            'reifiziert und ihre Summe nach unten beschränkt.';
      case 'at_most':
        return 'Höchstens k der angegebenen `name=Wert`-Bedingungen dürfen '
            'gelten — die reifizierten Bedingungen summieren sich zu '
            'höchstens k.';
      case 'exactly':
        return 'Genau k der angegebenen `name=Wert`-Bedingungen gelten — die '
            'reifizierten Bedingungen summieren sich zu genau k.';
      case 'implies':
        return 'Materiale Implikation über zwei `name=Wert`-Bedingungen: Gilt '
            'die erste, muss auch die zweite gelten (a=1 ⇒ b=2).';
      case 'gcc':
        return 'Globale Kardinalität: Jeder aufgeführte Wert muss genau so oft '
            'unter den Variablen vorkommen (Wert 1 zweimal, Wert 2 einmal, …).';
      case 'among':
        return 'Die deklarierte Variable c ist gleich der Anzahl der '
            'aufgeführten Variablen, die einen Wert aus der angegebenen Menge '
            'annehmen.';
      case 'nvalue':
        return 'Die deklarierte Variable c ist gleich der Anzahl VERSCHIEDENER '
            'Werte der aufgeführten Variablen. Minimiere c, um möglichst wenige '
            'zu verwenden.';
      case 'at_most_in_a_row':
        return 'Keine Folge von mehr als `max` aufeinanderfolgenden `Wert`en '
            'in der Sequenz — kompiliert zu einem kleinen endlichen Automaten '
            '(regular-Bedingung).';
      case 'value_precedence':
        return 'Symmetriebrechung: Wert order[i+1] darf nicht vor order[i] '
            'erstmals auftreten. Fasst vertauschbare Werte zusammen (z. B. '
            'Kartenfarben), sodass die Aufzählung nur einen Vertreter je '
            'Klasse listet.';
      case 'table':
        return 'Das Tupel (x, y, z) muss einer der aufgeführten Zeilen '
            'entsprechen. Kodiert beliebige Relationen: Kompatibilitätsmatrizen, '
            'erlaubte Kombinationen, Hinweistabellen für Logikrätsel.';
      case 'element':
        return 'Indizierter Zugriff: list[idx] == value, mit 0-basiertem '
            'Index. Modelliert Indirektion wie „die Kosten der gewählten '
            'Option sind v".';
      case 'diff_n':
        return 'Überschneidungsfreie 2D-Rechtecke: jedes Tupel platziert ein '
            'w×h-Rechteck an der unteren linken Ecke (x, y). Modelliert '
            'Packprobleme, Parkettierungen und Grundrisse; der DSL-Tab '
            'zeichnet die gefundene Anordnung maßstabsgetreu.';
      case 'circuit':
        return 'Eine einzige Hamilton-Rundreise über Nachfolgervariablen: '
            'next[i] ist der nach Knoten i besuchte Knoten; die Tour muss '
            'jeden Knoten genau einmal erreichen und zum Start zurückkehren. '
            'Modelliert Rundreise- und Routingprobleme; der DSL-Tab zeichnet '
            'die Tour als gerichteten Knotengraphen. `subcircuit` erlaubt '
            'unbesuchte Knoten (Schleifen).';
      case 'soft':
        return 'Eine MaxCSP-Präferenz: Der Löser erfüllt sie, wenn möglich, '
            'und sie trägt ihr Gewicht (Standard 1) zur Bewertung bei. Bei '
            'widersprüchlichen Präferenzen gewinnt die Zuweisung mit dem '
            'höchsten erfüllten Gesamtgewicht. Der DSL-Tab zeigt einen '
            'Erfüllungswert und welche Präferenzen galten.';
      case 'set_var':
        return 'Mengenvariablen wählen eine Teilmenge eines ganzzahligen '
            'Universums — Team-/Ausschusswahl. Deklaration mit `set S from '
            'lo..hi`, dann formen: `card(S) = k` (auch `<=`, `in a..b`), '
            '`subset(A, B)`, `disjoint(A, B)`, `setEquals(A, B)`, `S contains '
            'e`, `S excludes e`. Lösungen erscheinen als Chip-Gruppen.';
      // --- Sudoku-Varianten ---
      case 'dot':
        return 'Skalarprodukt (Punktprodukt) zweier gleich langer Vektoren: Σ aᵢ·bᵢ. Ergibt einen Skalar.';
      case 'cross':
        return 'Kreuzprodukt zweier 3-Vektoren: der zu beiden orthogonale Vektor mit Länge |a||b|sin θ.';
      case 'norm':
        return 'Euklidische Länge (2-Norm) eines Vektors: √(Σ vᵢ²).';
      case 'unit':
        return 'Einheitsvektor in Richtung von v: v / norm(v). Gleiche Richtung, Länge 1.';
      case 'mod':
        return 'Modulo: der Rest von a ÷ n. Die `mod`-Taste fügt den Operator zwischen zwei ganze Zahlen ein.';
      case 'nth_root':
        return 'Die n-te Wurzel von x, also x^(1/n). Die Taste öffnet einen kleinen Dialog für den Grad n und den Radikanden x.';
      case 'sin':
        return 'Sinus von x (x im Bogenmaß).';
      case 'cos':
        return 'Kosinus von x (x im Bogenmaß).';
      case 'tan':
        return 'Tangens von x = sin(x)/cos(x) (x im Bogenmaß).';
      case 'asin':
        return 'Arkussinus (Umkehrfunktion des Sinus): der Winkel, dessen Sinus x ist.';
      case 'acos':
        return 'Arkuskosinus: der Winkel, dessen Kosinus x ist.';
      case 'atan':
        return 'Arkustangens: der Winkel, dessen Tangens x ist.';
      case 'sinh':
        return 'Sinus hyperbolicus: (eˣ − e⁻ˣ)/2.';
      case 'cosh':
        return 'Kosinus hyperbolicus: (eˣ + e⁻ˣ)/2.';
      case 'tanh':
        return 'Tangens hyperbolicus: sinh(x)/cosh(x).';
      case 'asinh':
        return 'Areasinus hyperbolicus (Umkehrfunktion des Sinus hyperbolicus).';
      case 'acosh':
        return 'Areakosinus hyperbolicus.';
      case 'atanh':
        return 'Areatangens hyperbolicus.';
      case 'ln':
        return 'Natürlicher Logarithmus (Basis e) von x.';
      case 'log':
        return 'Dekadischer Logarithmus (Basis 10) von x.';
      case 'exp':
        return 'Exponentialfunktion e^x.';
      case 'abs':
        return 'Betrag von x — auch der Betrag einer komplexen Zahl.';
      case 'sqrt':
        return 'Quadratwurzel von x (Hauptwert, nicht-negativer Zweig).';
      case 'pi':
        return 'Die Kreiszahl π ≈ 3,14159 — Umfang eines Kreises geteilt durch seinen Durchmesser. Die Taste fügt das Symbol ein.';
      case 'imaginary_unit':
        return 'Die imaginäre Einheit i mit i² = −1. Intern als SymEngines I dargestellt.';
      case 'euler_gamma':
        return 'Die Euler-Mascheroni-Konstante γ ≈ 0,57722 — der Grenzwert von (Σ 1/k − ln n) für n → ∞.';
      case 'infinity':
        return 'Positive Unendlichkeit ∞ — als Grenze in Grenzwerten und uneigentlichen Integralen, nicht als Rechenwert.';
      case 'sudoku_regular':
        return 'Klassische Sudoku-Regeln: Jede Zeile, Spalte und Box enthält '
            'jede Ziffer genau einmal. Vorlagen gibt es für 4×4, 6×6, 8×8, '
            '9×9, 10×10, 12×12, 15×15 und 16×16.';
      case 'sudoku_x':
        return 'Sudoku-X: reguläre Sudoku-Regeln plus die beiden '
            'Hauptdiagonalen sind ebenfalls allDifferent. Wird als '
            '8×8-Vorlage geliefert.';
      case 'sudoku_disjoint':
        return 'Disjunkte Gruppen: reguläre Regeln plus eine zusätzliche '
            'allDifferent-Bedingung über die Zellen an derselben Position '
            'innerhalb der Box über alle Boxen hinweg.';
      case 'sudoku_killer':
        return 'Killer-Sudoku: keine Vorgaben; stattdessen ist das Gitter in '
            '„Käfige" unterteilt, jeder Käfig allDifferent und mit einer '
            'gegebenen Zielsumme.';
      case 'eq_op':
        return 'Gleichheitstest — gibt true zurück, wenn beide Seiten denselben Wert ergeben.';
      case 'ne_op':
        return 'Ungleichheitstest — gibt true zurück, wenn die beiden Seiten verschieden sind.';
      case 'lt_op':
        return 'Strikter Kleiner-als-Vergleich.';
      case 'le_op':
        return 'Kleiner-gleich-Vergleich.';
      case 'gt_op':
        return 'Strikter Größer-als-Vergleich.';
      case 'ge_op':
        return 'Größer-gleich-Vergleich.';
      case 'and_op':
        return 'Logische Konjunktion — nur true, wenn beide Operanden true sind.';
      case 'or_op':
        return 'Logische Disjunktion — true, wenn mindestens ein Operand true ist.';
      case 'not_op':
        return 'Logische Negation — kehrt true zu false um und umgekehrt.';
      case 'xor_op':
        return 'Exklusives Oder — true, wenn genau ein Operand true ist.';
      case 'if_cond':
        return 'Bedingte Auswertung — wertet die Bedingung aus, gibt den then-Zweig bei true, den else-Zweig bei false zurück.';
      default:
        return null;
    }
  }

  @override
  String? functionRefExampleHint(String id, int index) {
    const hints = <String, List<String>>{
      'solve': [
        'In CrispMath liefert `solve(x^2 - 1, x)` eine Liste der Nullstellen '
            'im Python-Stil zurück. Der zugrunde liegende Aufruf ist '
            'SymEngines `solve()` (der Zweig für rationale Nullstellen bei '
            'Polynomen), von der Bridge umschlossen und zurück in eine '
            'Dart-Zeichenkette serialisiert.',
        '`=` in der Eingabe wird als Gleichungssyntax akzeptiert — der '
            'Präprozessor normalisiert `lhs = rhs` vor dem Bridge-Aufruf zu '
            '`lhs - rhs`.',
        'Komplexe Nullstellen kommen als SymEngines Literal `I` zurück. '
            'Verwendet man sie in weiteren Aufrufen (z. B. `expand((-I)*(I))`), '
            'hält die Bridge sie symbolisch.',
        'Auch polynomiale UNGLEICHUNGEN werden gelöst: Die Nullstellen teilen die Zahlengerade in Intervalle, das Vorzeichen je Intervall entscheidet. Auch ≤/≥, exakte Wurzel-Grenzen und die Fälle ≠ / Einzelpunkt / ℝ / ∅.',
      ],
      'expand': [
        'In CrispMath liefert `expand((x + 1)^2)` die binomische Entwicklung. '
            'Der zugrunde liegende Aufruf ist SymEngines `expand()`, das '
            '`Pow`- und `Mul`-Knoten auflöst und gleichartige Terme '
            'zusammenfasst.',
        'Die Koeffizienten entsprechen Zeile 5 des Pascalschen Dreiecks: '
            '1, 5, 10, 10, 5, 1, jeweils multipliziert mit der passenden '
            'Potenz von 2.',
        'Die dritte binomische Formel (Differenz von Quadraten) — nützlich im '
            'Wechselspiel mit `factor`, um zwischen den Formen zu wechseln.',
      ],
      'simplify': [
        'In CrispMath kürzt `simplify` den gemeinsamen Faktor `(x - 2)`. Der '
            'zugrunde liegende Aufruf ist SymEngines `simplify()`, das '
            '`rational_simplify` sowie eine kleine Sammlung von '
            'Umformungsregeln versucht.',
        'Zusammenfassen gleichartiger Terme bei polynomieller Eingabe — '
            'intern ist das einfach `expand`, gefolgt vom Zusammenführen der '
            'Koeffizienten.',
        'Pythagoreische Identität; SymEngine wendet die trigonometrische '
            'Umformungsregel an, bevor das Literal `1` zurückgegeben wird.',
      ],
      'factor': [
        'In CrispMath liefert `factor(x^2 - 1)` die Faktorisierung als '
            'Differenz von Quadraten. Der zugrunde liegende Aufruf ist '
            'SymEngines `factor()`, das für univariate Polynome über Q '
            'Berlekamp / Cantor–Zassenhaus verwendet.',
        'Identität für Summe/Differenz von Kuben: ein Linearfaktor mal ein '
            'über Q irreduzibles quadratisches Polynom.',
        'Die Faktorisierung endet bei der Irreduzibilität über Q — `x^2 + 1` '
            'zerfällt nicht weiter, ohne komplexe Nullstellen zuzulassen.',
      ],
      'diff': [
        'In CrispMath wendet `diff(...)` die Potenz- und Konstantenregel '
            'termweise an. Der zugrunde liegende Aufruf ist SymEngines '
            '`diff()`, das den Ausdrucksbaum durchläuft und einen neuen '
            'symbolischen `Add`-Knoten erzeugt.',
        'Kettenregel: SymEngine wendet `diff(sin(u))/du * du/dx` für das '
            'innere `u = x^2` an.',
        'Produktregel — beachte, dass SymEngine das Ergebnis unfaktorisiert '
            'lässt. Durch `factor` geleitet, wird `exp(x)` ausgeklammert.',
      ],
      'integrate': [
        'In CrispMath delegiert das unbestimmte `integrate(...)` an '
            'SymEngines `integrate()`. Partielle Integration wird automatisch '
            'angewandt, wenn ein Faktor zu einem Polynom differenziert.',
        'Bestimmte Form: Hat SymEngine eine geschlossene Stammfunktion, wendet '
            'es den Hauptsatz der Differential- und Integralrechnung an. '
            'Schlägt das symbolisch fehl, fällt CrispMath auf die Simpson-Regel '
            '(200 Streifen) zurück.',
        'Partialbruchzerlegung: 1/(x²-1) = 1/(2(x-1)) - 1/(2(x+1)). SymEngine '
            'erledigt das Abdeckverfahren automatisch.',
      ],
      'subst': [
        'In CrispMath schreibt `subst` den Ausdrucksbaum um und versucht '
            'anschließend einen Vereinfachungsdurchlauf. Der zugrunde liegende '
            'Aufruf ist SymEngines `xreplace()` (reine Variablenersetzung, '
            'kein Mustervergleich).',
        'Numerische Konstanten `pi`, `e` und die imaginäre Einheit `I` werden '
            'von SymEngine erkannt und über die trigonometrische Identität '
            'gefaltet.',
        'Die Ersetzung ist symbolisch — unbeteiligte freie Variablen `a` und '
            '`b` bleiben unverändert erhalten.',
      ],
      'limit': [
        'In CrispMath ist `limit(...)` ein numerisches Verfahren: Die Bridge '
            'wertet den Ausdruck an einer Folge von Punkten aus, die gegen '
            '`point` konvergieren, und meldet den Grenzwert, sobald '
            'aufeinanderfolgende Stichproben bis zur Arbeitsgenauigkeit '
            'übereinstimmen. Keine symbolische Reihenentwicklung.',
        'Das Literal `oo` ist SymEngines Unendlichkeits-Sentinel — der '
            'Präprozessor erkennt es vor dem Dispatch. Verwende `-oo` für '
            'negative Unendlichkeit.',
        'Strebt gegen die eulersche Zahl. Da der Weg numerisch ist, ist das '
            'Ergebnis eine Gleitkommazahl — verwende `e(N)` für die '
            'hochpräzise Konstante.',
      ],
      'gcd': [
        'In CrispMath nutzt der ganzzahlige `gcd(...)` die euklidische '
            'Rekursion gcd(a, b) = gcd(b, a mod b). Der zugrunde liegende '
            'Aufruf ist SymEngines `gcd()`, das im ganzzahligen Fall an GMPs '
            '`mpz_gcd` weiterreicht.',
        'Polynom-GGT über den Subresultanten-PRS-Algorithmus. Nützlich als '
            'Vorstufe zu `simplify` für Kürzungen.',
        'Konvention: `gcd(0, n) = |n|`. Entspricht der mathematischen '
            'Definition, die 0 als Vielfaches jeder ganzen Zahl behandelt.',
      ],
      'lcm': [
        'In CrispMath wird das ganzzahlige `lcm(...)` über die Identität '
            '`lcm(a, b) = |a*b| / gcd(a, b)` berechnet. Der zugrunde liegende '
            'Aufruf ist SymEngines `lcm()`, das an GMPs `mpz_lcm` delegiert.',
        '36 = 2²·3², die Vereinigung der Primpotenzfaktoren aus 12 = 2²·3 und '
            '18 = 2·3².',
        'Das Polynom-kgV wählt das Vielfache höheren Grades — `x^2 - 1` '
            'enthält `x + 1` bereits als Faktor.',
      ],
      'polygcd': [
        'In CrispMath führt `polygcd` den euklidischen Algorithmus mit '
            'exakten rationalen Koeffizienten aus (reines Dart). Beide '
            'Polynome teilen den Faktor `x - 1`; das Ergebnis wird normiert.',
        'Teilerfremde Polynome ergeben die normierte Konstante 1.',
      ],
      'polydiv': [
        'Exakte Division — der Rest ist null. '
            '`x² - 1 = (x + 1)(x - 1)`.',
        'Nicht-exakt: `x² + 3x + 5 = (x + 2)(x + 1) + 3`.',
      ],
      'polyresultant': [
        'Berechnet als Determinante der Sylvester-Matrix. Sie verschwindet '
            'hier, weil beide bei `x = 1` null werden.',
        'Eine von null verschiedene Resultante bestätigt, dass die beiden '
            'Polynome über ℚ teilerfremd sind.',
      ],
      'polydiscriminant': [
        'Für `x² + bx + c` ist die Diskriminante `b² − 4c` — hier 25 − 24 = '
            '1. CrispMath verwendet `(−1)^(n(n−1)/2)·Res(p, p′)/aₙ`.',
        '`(x − 2)²` hat eine doppelte Nullstelle, daher ist die Diskriminante '
            '0.',
      ],
      'polyfactor': [
        'In CrispMath reduziert `polyfactor` das Polynom modulo k, führt eine '
            'quadratfreie Zerlegung und anschließend Berlekamps Algorithmus '
            'aus (reines Dart). Koeffizienten erscheinen als Reste in [0, k), '
            'daher steht `x − 1` modulo 5 als `x + 4`.',
        '`x⁴ + 1` ist über ℚ irreduzibel, modulo 2 jedoch eine reine '
            '4. Potenz — die quadratfreie Zerlegung gewinnt die Vielfachheit '
            'zurück.',
        'Über 𝔽₂ irreduzibel — ein primitives Polynom zur Konstruktion von '
            'GF(8). Ein einzelner Faktor wird unverändert zurückgegeben.',
      ],
      'gamma': [
        'Für eine positive ganze Zahl n gilt Γ(n) = (n − 1)!, also '
            'Γ(5) = 4! = 24. Numerisch über SymEngines `basic_evalf` (MPFR) '
            'ausgewertet.',
        'Γ(½) = √π — die Konstante hinter dem Gauß-Integral. Grafikfähig: '
            'zeichne `gamma(x)`, um die Pole bei den nichtpositiven ganzen '
            'Zahlen zu sehen.',
      ],
      'zeta': [
        'Das Basler Problem: ζ(2) = π²/6 ≈ 1,6449. Numerisch über MPFR '
            'ausgewertet.',
        'ζ(4) = π⁴/90. Die Werte an geraden ganzen Zahlen sind alle '
            'rationale Vielfache von Potenzen von π.',
      ],
      'erf': [
        'erf ist ungerade, mit erf(0) = 0 und erf(x) → 1 für x → ∞. '
            'Grafikfähig: zeichne `erf(x)` für die klassische S-Kurve.',
        'Die komplementäre Fehlerfunktion erfc(x) = 1 − erf(x).',
      ],
      'lambertw': [
        'Die Omega-Konstante Ω, die Lösung von Ω·e^Ω = 1. Löst Gleichungen '
            'der Form x·eˣ = c.',
        'W(0) = 0, denn 0·e⁰ = 0.',
      ],
      'beta': [
        'B(2, 3) = 1!·2!/4! = 2/24 = 1/12. Grundlage der Beta-Verteilung in '
            'der Statistik.',
        'B(1, 1) = Γ(1)²/Γ(2) = 1 — eine gleichverteilte Beta-Verteilung.',
      ],
      'besselj': [
        'J₀ bei x = 1. Die Jₙ lösen x²y″ + xy′ + (x² − n²)y = 0 — '
            'schwingende Membranen, Wellenleiter. Über MPFRs `mpfr_jn`. '
            'Grafikfähig: zeichne `besselj(0, x)`.',
        'Jₙ(0) = 0 für n ≥ 1, während J₀(0) = 1.',
      ],
      'bessely': [
        'Die zweite unabhängige Lösung der Bessel-Gleichung; Yₙ(x) → −∞ '
            'für x → 0⁺. Über MPFRs `mpfr_yn`.',
        'Grafikfähig: zeichne `bessely(0, x)` neben `besselj(0, x)`.',
      ],
      'factorial': [
        'In CrispMath sind das Postfix `n!` und `factorial(n)` gleichwertig — '
            'der Präprozessor schreibt das Postfix in den Aufruf um. Für '
            '`n ≤ 1000` rechnen wir in Dart mit `BigInt`-Multiplikation; '
            'darüber hinaus ist der zugrunde liegende Aufruf SymEngines '
            '`factorial()`.',
        '158 Stellen, dank des BigInt-Wegs exakt erhalten — ein Wechsel zu '
            'IEEE-754 würde hier auf 1,0 × 10^157 runden.',
        'Konvention des leeren Produkts: 0! = 1. Notwendig, damit die '
            'Rekursion n! = n · (n-1)! bei 1 endet.',
      ],
      'dsolve': [
        'Charakteristische Gleichung r^2 + 3r + 2 = 0 mit den Wurzeln -1 '
            'und -2; jede Wurzel liefert einen Exponentialmodus. Komplexe '
            'Paare ergeben exp*(cos + sin), Doppelwurzeln (C1 + C2*x)*exp.',
        'Homogene Lösung plus partikuläre Polynomlösung über den Ansatz '
            'vom Typ der rechten Seite — alles in exakter rationaler '
            'Arithmetik, ohne Gleitkomma-Drift in den Koeffizienten.',
      ],
      'taylor': [
        'Nur ungerade Potenzen — der Sinus ist eine ungerade Funktion. Die '
            'Entwicklung bricht vor x^8 ab (Restglied O(x^8)); die '
            'Koeffizienten sind (-1)^k/(2k+1)!.',
        '`series(f, x, n)` ist die Kurzform der Maclaurin-Entwicklung '
            '(Entwicklungspunkt 0). Die Koeffizienten der Exponentialreihe '
            'sind 1/k!.',
      ],
      'linsolve': [
        'Jede Gleichung darf als "linke Seite = rechte Seite" oder als '
            'Ausdruck (implizit = 0) geschrieben werden. Gelöst wird exakt '
            'über SymEngines linsolve().',
        'Ergebnisse bleiben exakte Brüche — keine Gleitkomma-Rundung. '
            'Nichtlineare oder unterbestimmte Systeme liefern eine '
            'Fehlermeldung.',
      ],
      'fibonacci': [
        'In CrispMath sind `fib(n)` und `fibonacci(n)` derselbe Aufruf. Für '
            '`n ≤ 90` nutzen wir eine vorberechnete Tabelle; für größere `n` '
            'ist der zugrunde liegende Aufruf SymEngines `fibonacci()`, das '
            'Fast-Doubling verwendet (O(log n) Multiplikationen über GMP).',
        'Die 50. Fibonacci-Zahl — weit jenseits der Tabellengrenze für kleine '
            'Terme, passt aber noch in eine vorzeichenbehaftete '
            '64-Bit-Ganzzahl.',
        'Wechselt in den GMP-gestützten Weg. Fast-Doubling vermeidet die '
            'lineare Rekurrenz mit O(n), sodass selbst fib(10000) unter einer '
            'Sekunde bleibt.',
      ],
      // --- Zahlentheorie ---
      'isprime': [
        'In CrispMath gibt `isprime(n)` einen booleschen Chip zurück. Der '
            'zugrunde liegende Aufruf ist GMPs `mpz_probab_prime_p` (25 '
            'Miller-Rabin-Runden, Fehlerschranke 4^-25 ≈ 9×10^-16) über '
            'SymEngines `ntheory`-Modul. 2027 ist die 308. Primzahl.',
        '2024 = 2³·11·23.',
        'Die neunte Mersenne-Primzahl, M61. Miller-Rabin braucht selbst in '
            'dieser Größe nur Mikrosekunden — der Aufwand steckt in den '
            'modularen Potenzierungen, nicht in der Bitlänge.',
      ],
      'nextprime': [
        'In CrispMath iteriert `nextprime(n)` von `n+1` aufwärts und testet '
            'jeden Kandidaten. Der zugrunde liegende Aufruf ist SymEngines '
            '`ntheory::nextprime()`, das über kurze Fenster FLINTs Sieb '
            'verwendet, wenn die Lücke groß ist.',
        'Echt größer — `nextprime(p)` ist niemals `p` selbst, auch wenn `p` '
            'prim ist.',
      ],
      'prevprime': [
        'In CrispMath geht `prevprime(n)` von `n-1` abwärts. Der zugrunde '
            'liegende Aufruf ist SymEngines `ntheory::prevprime()`.',
        'Unter 2 existieren keine Primzahlen; die Bridge wirft einen Fehler, '
            'statt einen Sentinel-Wert zurückzugeben. CrispMath zeigt den '
            'Fehler-Chip an.',
      ],
      'factorint': [
        'In CrispMath liefert `factorint(n)` eine dargestellte '
            'Primfaktorzerlegung. Der zugrunde liegende Aufruf ist FLINTs '
            '`fmpz_factor`, vorgelagert über SymEngines ntheory-Wrapper; '
            'CrispMath wandelt die Liste aus (Primzahl, Exponent) in die '
            'Darstellung mit hochgestellten Unicode-Ziffern um.',
        'Die 8. Mersenne-Primzahl, M31. Ein einziger Faktor (sie selbst) — '
            '`factorint` bricht ab, wenn die Eingabe prim ist.',
        'Sonderfall: Per Konvention hat 1 die leere Faktorzerlegung; CrispMath '
            'stellt dies als das Literal `1` dar statt als leere Zeichenkette.',
      ],
      'divisors': [
        'In CrispMath wird `divisors(n)` rein in Dart aus `factorint(n)` '
            'abgeleitet: jedes Produkt von Primzahlpotenzen pᵏ mit '
            '0 ≤ k ≤ Exponent. Die Anzahl ist ∏(eᵢ + 1) — hier '
            '(2+1)(1+1) = 6.',
        '28 ist eine vollkommene Zahl: Die Summe ihrer echten Teiler (alle '
            'außer 28 selbst) ergibt 28.',
      ],
      'totient': [
        'Die vier zu 12 teilerfremden Reste sind {1, 5, 7, 11}. CrispMath '
            'berechnet φ aus der Primfaktorzerlegung über FLINTs '
            '`fmpz_euler_phi`.',
        'Für eine Primzahl p gilt φ(p) = p − 1, da jede kleinere positive '
            'Zahl zu p teilerfremd ist.',
      ],
      'modpow': [
        'Square-and-Multiply über GMPs `mpz_powm` — die Grundoperation '
            'modularer Arithmetik und (im Schulbuch) von RSA / '
            'Diffie-Hellman. Die riesige Zahl `2¹⁰⁰` wird nie explizit '
            'gebildet.',
        'Ein negativer Exponent invertiert zunächst die Basis, daher ist '
            '`modpow(a, -1, m)` gleich `modinv(a, m)` — hier 3⁻¹ ≡ 4 '
            '(mod 11). Fehler, wenn ggT(a, m) ≠ 1.',
      ],
      'modinv': [
        'Das eindeutige x in [0, m) mit a·x ≡ 1 (mod m), über GMPs '
            '`mpz_invert`. Probe: 3·4 = 12 ≡ 1 (mod 11).',
        'Nur Einheiten modulo m sind invertierbar. ggT(2, 4) = 2 ≠ 1, also '
            'existiert kein Inverses.',
      ],
      'jacobi': [
        'Für eine Primzahl n stimmt das Jacobi-Symbol mit dem '
            'Legendre-Symbol überein — hier ist 2 ein quadratischer Rest '
            'modulo 7 (denn 3² ≡ 2). Über GMPs `mpz_jacobi`.',
        'Das Symbol ist genau dann 0, wenn ggT(a, n) ≠ 1; hier ist '
            'ggT(6, 9) = 3.',
      ],
      'cfrac': [
        'In CrispMath führt `cfrac` eine exakte BigInt-Entwicklung über eine '
            'hochpräzise MPFR-Näherung der Konstante aus. Das große Glied 292 '
            'ist genau der Grund, warum der Näherungsbruch 355/113 π so '
            'bemerkenswert gut annähert.',
        'Für eine exakte rationale Zahl ist die Entwicklung endlich — das ist '
            'nichts anderes als der euklidische Algorithmus, der seine '
            'Quotienten protokolliert.',
      ],
      'convergent': [
        'Milü — die Näherung von π durch Zu Chongzhi (5. Jahrhundert), auf '
            'sechs Dezimalstellen genau. CrispMath faltet die ersten k+1 '
            'Teilquotienten von `cfrac` zum Bruch zusammen.',
        'Die Schulbuch-Näherung von π; `convergent(x, 0)` ist der ganzzahlige '
            'Anteil ⌊x⌋.',
      ],
      // --- Hochpräzision ---
      'pi_precision': [
        'In CrispMath ist `pi(N)` ein gesondert behandelter Aufruf, der vor '
            'SymEngine auf den Hochpräzisionspfad geleitet wird. Der zugrunde '
            'liegende Aufruf ist MPFRs `mpfr_const_pi` mit der Genauigkeit '
            '⌈N·log2(10)⌉ + 16 Schutzbits, gefolgt von der Umwandlung ins '
            'Dezimalsystem.',
        'Bei N = 100 beträgt die Arbeitsgenauigkeit ≈ 348 Bit. Die Schutzbits '
            'verhindern, dass die Basisumwandlung gerundete Endziffern '
            'anzeigt.',
      ],
      'e_precision': [
        'In CrispMath spiegelt `e(N)` die Pipeline von `pi(N)` wider: MPFRs '
            '`mpfr_const_e` (das die Taylor-Reihe Σ 1/k! verwendet) mit der '
            'Genauigkeit ⌈N·log2(10)⌉ + 16 Schutzbits, dann die Darstellung '
            'im Dezimalsystem.',
        'Kurz genug zum Merken — nützlich als schnelle Genauigkeitsprobe gegen '
            '`limit((1 + 1/n)^n, n, oo)`.',
      ],
      'sqrt_precision': [
        'In CrispMath ist das zweiargumentige `sqrt(k, N)` der '
            'Hochpräzisionsweg. Der zugrunde liegende Aufruf ist MPFRs '
            '`mpfr_sqrt_ui` mit der Genauigkeit ⌈N·log2(10)⌉ + 16 Schutzbits. '
            'Das einargumentige `sqrt(2)` gibt stattdessen das symbolische '
            '`sqrt(2)` über SymEngine zurück.',
        'Nützlich zur Überprüfung — `sqrt(3, N)` sollte mit unabhängig '
            'hergeleiteten Referenzziffern übereinstimmen.',
      ],
      'eulergamma_precision': [
        'In CrispMath verwendet `EulerGamma(N)` MPFRs `mpfr_const_euler`, das '
            'γ über die Brent-McMillan-Formel (modifizierte Bessel-Funktionen) '
            'auswertet. Die Genauigkeit beträgt ⌈N·log2(10)⌉ + 16 Schutzbits, '
            'passend zur Pipeline von `pi(N)` und `e(N)`.',
        'γ hat keine bekannte geschlossene Form. Die MPFR-Routine ist die '
            'Standard-Referenzimplementierung; CrispMath stellt lediglich die '
            'Ziffernfolge dar.',
      ],
      'evalf': [
        'In CrispMath parst `evalf` einen beliebigen Ausdruck und leitet ihn '
            'durch SymEngines `basic_evalf` mit ⌈N·log2(10)⌉ + 8 Bit. Das '
            'generische Gegenstück zu `pi(N)` / `e(N)` — funktioniert für '
            'Logarithmen, Wurzeln, Summen und die Spezialfunktionen.',
        'Mit Spezialfunktionen kombinierbar für hochpräzise Werte: '
            'ζ(2) = π²/6. Nicht-reelle Ergebnisse werden abgelehnt '
            '(hochpräzises Komplexes ist ein separater Pfad).',
      ],
      // --- Matrizen / Lineare Algebra ---
      'cevalf': [
        'In CrispMath nutzt `cevalf` SymEngines `basic_evalf` auf dem '
            'MPC-(komplexen)-Pfad. (1+i)¹⁰ = 32i. Die imaginäre Einheit ist '
            'das Literal `I`.',
        'Wo `evalf` ein nicht-reelles Ergebnis ablehnt, gibt `cevalf` den '
            'vollen komplexen Wert zurück: √(−2) = i·√2.',
      ],
      'matrix_literal': [
        'In CrispMath wird das Literal `Matrix(...)` vom Matrix-Auswerter '
            'erkannt, bevor die Engine den Ausdruck sieht. Der zugrunde '
            'liegende Aufruf ist SymEngines Konstruktor `DenseMatrix` — das '
            'Zeilen-/Spaltenlayout wird bei der Konstruktion festgelegt.',
        'Zellen bleiben symbolisch — rationale Zahlen werden nicht zu '
            'Gleitkommazahlen reduziert. Dasselbe gilt für freie Symbole: '
            '`Matrix([[a, b], [c, d]])` wird akzeptiert und durch `det` / '
            '`inv` / `rref` propagiert.',
        'Nicht-quadratische Matrizen sind für `transpose` und `rref` in '
            'Ordnung, schlagen aber bei `det` / `inv` fehl, die quadratische '
            'Eingaben erfordern.',
      ],
      'det': [
        'In CrispMath wird `det(M)` als einzelner Skalar ausgewertet. Der '
            'zugrunde liegende Aufruf ist SymEngines `DenseMatrix::det()`, das '
            'den bruchfreien Bareiss-Algorithmus verwendet — exakt für '
            'symbolische/rationale Einträge, ohne Aufblähen durch '
            'Gleitkommazahlen.',
        'Klassisches 3×3-Lehrbuchbeispiel — die Laplace-Entwicklung nach '
            'Kofaktoren liefert in 6 Termen dasselbe Ergebnis.',
        'Symbolische Einträge bleiben unverändert. Bareiss behält das Ergebnis '
            'als SymEngine-`Add` statt als Gleitkommazahl.',
      ],
      'inv': [
        'In CrispMath gibt `inv(M)` `adj(M)/det(M)` zurück. Der zugrunde '
            'liegende Aufruf ist SymEngines `DenseMatrix::inv()`, das den '
            'Gauß-Jordan-Algorithmus über den rationalen Zahlen verwendet — '
            'die Einträge kommen als exakte Brüche zurück, nicht als '
            'Gleitkommazahlen.',
        'Die Einheitsmatrix ist zu sich selbst invers — eine schnelle '
            'Funktionsprobe, dass die Bridge korrekt hin- und zurückrechnet.',
        'Singuläre Eingaben (det = 0) führen zu einem sauberen Fehler, statt '
            'unsinnig große Zahlen zurückzugeben. Der Fehler-Chip erscheint im '
            'Rechnerverlauf.',
      ],
      'transpose': [
        'In CrispMath ist `transpose(M)` auf der Dart-Seite implementiert, '
            'weil die Bridge keinen Einstiegspunkt zum Transponieren '
            'bereitstellt. Wir legen eine neue `SymEngineMatrix` mit '
            'vertauschten Dimensionen an und kopieren die Zellen Element für '
            'Element.',
        'Rechteckige Eingabe: aus einer 2×3 wird eine 3×2 — nützlich für '
            'gepaarte Datenlayouts.',
        'Idempotent bei zweimaliger Anwendung. Bestätigt, dass das Vertauschen '
            'der Zellen den symbolischen Inhalt unverändert lässt.',
      ],
      'rref': [
        'In CrispMath führt `rref` Gauß-Jordan in Dart aus und ruft bei jeder '
            'Zellaktualisierung SymEngines `simplify()` auf. Die Bridge stellt '
            '`rref` nicht direkt bereit, daher durchläuft der Algorithmus die '
            'Spalten von links nach rechts, skaliert die Pivotzeile und '
            'eliminiert dann die Spalte darüber und darunter.',
        'Rangdefiziente Eingabe: Die zweite Zeile reduziert sich zu lauter '
            'Nullen. Nützlich, um lineare Abhängigkeit visuell zu erkennen.',
        'Die Pivot-Skalierung normiert die führenden Einträge auf 1. Die '
            'Erkennung symbolischer Nicht-Null-Werte ist die Schwachstelle — '
            'siehe den Algorithmus-Hinweis in `matrix_evaluator.dart`.',
      ],
      'matrix_arithmetic': [
        'In CrispMath werden binäre Matrixoperationen vom Matrix-Auswerter '
            'verarbeitet, wenn beide Operanden als `Matrix(...)`-Literale '
            'geparst werden. Der zugrunde liegende Aufruf ist SymEngines '
            '`add_dense_dense`; die Subtraktion läuft über `add_dense_dense` '
            'mit elementweiser Negation der rechten Seite.',
        'Die Multiplikation ist das übliche Skalarprodukt Zeile mal Spalte '
            'über SymEngines `mul_dense_dense`. Die Rechtsmultiplikation mit '
            'der Einheitsmatrix ist eine Funktionsprobe.',
        'Die Subtraktion ist elementweise; eine Dimensionsabweichung führt '
            'sauber zum Fehler `Error: matrix - failed: …`.',
      ],
      'eigenvalues': [
        'Symmetrische 2×2-Matrix — geschlossene Lösung über das '
            'charakteristische Polynom. Eigenwerte sind für symmetrische '
            'Matrizen stets reell.',
        'Die Einheitsmatrix hat alle Eigenwerte gleich 1.',
        'Rotationsmatrix — die Eigenwerte sind konjugiert-komplexe Paare '
            '±i. Der QR-Algorithmus behandelt reelle 2×2-Schur-Blöcke.',
      ],
      'eigenvectors': [
        'Für 2×2-Matrizen mit reellen Eigenwerten werden Eigenvektoren '
            'über den Nullraum von (A − λI) berechnet. Für größere Matrizen '
            'oder komplexe Eigenwerte werden nur Eigenwerte zurückgegeben.',
      ],
      // --- Statistik ---
      'mean': [
        'In CrispMath wird `mean` von `DescriptiveStats.mean` berechnet (siehe '
            '`lib/engine/statistics.dart`) — eine Summe in einem Durchlauf / '
            'n. Für gepaarte oder gruppierte Daten stellt das Statistik-Modul '
            'außerdem Standardabweichung, Median, Quartile und den '
            'Interquartilsabstand bereit.',
        'Gleitkomma-Eingabe — die Implementierung summiert in `double`, daher '
            'können sehr große oder größenmäßig gemischte Listen einen stabilen '
            'Summationsalgorithmus erfordern, wenn du >15 Stellen brauchst.',
      ],
      'one_sample_t': [
        'In CrispMath liegt `oneSampleT` in `lib/engine/hypothesis_tests.dart`. '
            'Der zugrunde liegende Aufruf berechnet t = (x̄ − μ₀) / (s / √n) und '
            'liest den zweiseitigen p-Wert aus `TDistribution.cdf` mit '
            'df = n − 1 ab.',
        'Die Stichprobe liegt deutlich über μ₀ = 70, daher verwirft der Test '
            'H₀ (Mittelwert = 70) bei α = 0,05. Vergleiche mit `paired_t`, einem '
            'Einstichproben-t-Test des Differenzvektors.',
      ],
      'welch_t': [
        'In CrispMath liegt `welchT` in `lib/engine/hypothesis_tests.dart`. '
            'Der zugrunde liegende Aufruf berechnet die Teststatistik '
            't = (x̄_A − x̄_B) / √(s_A²/n_A + s_B²/n_B), nähert dann die '
            'Freiheitsgrade über Welch-Satterthwaite an und liest den p-Wert '
            'aus `TDistribution.cdf` ab.',
        'Fall mit winziger Stichprobe — der Welch-Freiheitsgrad ≈ 4, obwohl '
            'n_A + n_B = 6, weil die Zweistichproben-t-Verteilung die '
            'Unsicherheit der Varianzschätzung berücksichtigt.',
      ],
      'paired_t': [
        'In CrispMath reduziert sich `pairedT` auf einen Einstichproben-t-Test '
            'des Differenzvektors d = nachher − vorher. Der zugrunde liegende '
            'Aufruf ist derselbe `TDistribution.cdf`-Weg wie bei `welchT`, '
            'jedoch mit df = n - 1 (keine Welch-Korrektur, da nur eine '
            'Varianzschätzung vorzunehmen ist).',
        'Sonderfall: Identische Verschiebungen erzeugen eine Varianz von null '
            'in den Differenzen, was die Implementierung als Grenzfall p = 0 '
            'darstellt statt als NaN.',
      ],
      'anova_1': [
        'In CrispMath zerlegt `anovaOneWay` die Gesamt-Quadratsumme in die '
            'Quadratsumme zwischen den Gruppen und die innerhalb der Gruppen. '
            'Der zugrunde liegende Aufruf ist F = MS_zwischen / MS_innerhalb '
            'mit df1 = K - 1 und df2 = N - K, dann `FDistribution.sf` für den '
            'p-Wert des oberen Endes.',
        'Gleiche Streuung und gut getrennte Mittelwerte erzeugen ein hohes F. '
            'H₀ (alle Mittelwerte gleich) wird bei α = 0,05 verworfen.',
      ],
      'chi2_goodness': [
        'In CrispMath wertet `chiSquareGof` Σ (O - E)² / E aus und liest den '
            'p-Wert des oberen Endes aus `ChiSquaredDistribution.sf` mit '
            'df = k - 1 ab, wobei k die Anzahl der Kategorien ist. Es wird '
            'angenommen, dass die zugrunde liegenden Zellhäufigkeiten ≥ 5 '
            'sind — die Implementierung wendet keine automatische '
            'Yates-Korrektur an.',
        'Perfekte Übereinstimmung → χ² = 0 → H₀ wird bei keinem α verworfen.',
      ],
      'chi2_independence': [
        'In CrispMath berechnet `chiSquareIndependence` die erwarteten '
            'Häufigkeiten aus den Randsummen von Zeile × Spalte '
            '(E_ij = Zeile_i · Spalte_j / Gesamt), dann Σ (O - E)² / E mit '
            'df = (Zeilen - 1) · (Spalten - 1). Der zugrunde liegende p-Wert '
            'stammt aus `ChiSquaredDistribution.sf`.',
        'Starke Konzentration außerhalb der Diagonale → niedriger p-Wert. Bei '
            'dünn besetzten 2×2-Tafeln ist `fisher_exact` vorzuziehen, das '
            'nicht auf der Chi-Quadrat-Näherung für große Stichproben beruht.',
      ],
      'fisher_exact': [
        'In CrispMath zählt `fisherExact` alle 2×2-Tafeln mit denselben '
            'Randsummen auf und summiert die hypergeometrischen '
            'Wahrscheinlichkeiten der Tafeln, die mindestens so extrem wie die '
            'beobachtete sind. Der zugrunde liegende Aufruf berechnet '
            'log-Binomialterme, um einen Überlauf bei großen Summen zu '
            'vermeiden, und potenziert dann; der zweiseitige p-Wert folgt der '
            'Konvention von R (Summe der Endwahrscheinlichkeiten ≤ der '
            'beobachteten).',
        'Symmetrische Tafel → kein Hinweis auf einen Zusammenhang.',
      ],
      'wilcoxon': [
        'In CrispMath fasst `wilcoxonRankSum` beide Stichproben zusammen, '
            'vergibt mittelwertkorrigierte Ränge, summiert die Ränge der '
            'Gruppe A und gibt das z der Normalnäherung aus. Der zugrunde '
            'liegende Aufruf wendet eine Bindungskorrektur auf die Varianz an '
            'und liest den zweiseitigen p-Wert aus der Normalverteilungs-CDF '
            'ab.',
        'Fall mit winziger Stichprobe — die Normalnäherung ist bei '
            'n_A + n_B = 6 grenzwertig. Für sehr kleine Stichproben ist die '
            'exakte Permutationsverteilung vorzuziehen (noch nicht enthalten).',
      ],
      'sign_test': [
        'In CrispMath verwirft `pairedSign` Paare mit Differenz null, zählt '
            'die positiven unter den verbleibenden n und testet gegen '
            'Binomial(n, 0,5). Der zugrunde liegende p-Wert nutzt das exakte '
            'Binomialende — keine Normalnäherung, daher die richtige Wahl für '
            'sehr kleine gepaarte Stichproben.',
        'Ein gebundenes Paar (4 → 4) wird verworfen, sodass n = 3 positive von '
            '3 informativen Paaren übrig bleiben. Der zweiseitige exakte '
            'p-Wert ist 2 · min(Binom(3, 0,5).cdf(3), …).',
      ],
      'linreg': [
        'In CrispMath passt der Reiter „Regression" die Daten über die '
            'geschlossenen Kleinste-Quadrate-Schätzer a = Sxy / Sxx und '
            'b = ȳ − a·x̄ an (siehe `lib/engine/statistics.dart`). Derselbe '
            'Reiter bietet auch polynomielle und exponentielle Modelle.',
        'Punkte, die nahe an y = 2x liegen, ergeben eine Steigung ≈ 2 und ein '
            'R² nahe 1 — eine nahezu perfekte lineare Anpassung.',
      ],
      'poly_fit': [
        'Der Gradregler (2–5) im Regressions-Tab legt d fest; ein höherer Grad passt mehr Krümmung an, birgt aber Überanpassung. Basiert auf Statistics.polynomialFit.',
      ],
      'exp_fit': [
        'Passt Wachstums-/Zerfallsdaten an; intern wird ln(y) gegen x regressiert, daher müssen alle y positiv sein. Basiert auf Statistics.expFit.',
      ],
      'normal_dist': [
        'In CrispMath wertet der Reiter „Verteilungen" die '
            'Verteilungsfunktion der Normalverteilung über die Fehlerfunktion '
            'aus (`Normal.cdf` in `lib/engine/statistics.dart`); x = μ + 2σ '
            'liegt etwa beim 97,7. Perzentil.',
        'Das 0,95-Quantil ist die Umkehrfunktion der Verteilungsfunktion — der '
            'Wert, unter dem 95 % der Masse liegen (≈ μ + 1,645σ). Passt zu '
            '`erf`, das der Verteilungsfunktion zugrunde liegt.',
      ],
      'binomial_dist': [
        'In CrispMath wertet der Reiter „Verteilungen" die binomiale '
            'Wahrscheinlichkeitsfunktion C(n, k)·pᵏ·(1−p)^(n−k) aus '
            '(`Binomial.pmf` in `lib/engine/statistics.dart`); bei einer '
            'Ausschussrate von 10 % unter 20 Stücken ist die wahrscheinlichste '
            'Fehlerzahl der Erwartungswert 2.',
        'Die Verteilungsfunktion summiert die Wahrscheinlichkeitsfunktion von '
            '0 bis k. Hier zeigen ≈ 68 % der Lose höchstens zwei Fehler. Die '
            'Varianz ist n·p·(1−p) = 1,8, also die Standardabweichung ≈ 1,34.',
      ],
      // --- Constraints-DSL ---
      'vars': [
        'In CrispMath wird die Zeile `vars:` von `DslToFlatZinc` geparst '
            '(siehe `lib/engine/csp_solver.dart`) und erzeugt pro Name eine '
            'FlatZinc-Deklaration `var int: x :: …`. Die Bereichsgrenzen sind '
            'konkrete ganze Zahlen; symbolische Wertebereiche werden nicht '
            'unterstützt.',
        'Ein Wertebereich `0..1` modelliert eine boolesche Variable. FlatZinc '
            'hat einen eigenen Typ `var bool` — der Parser greift ihn nicht '
            'auf, aber der Solver verarbeitet die 0/1-Ganzzahl genauso '
            'effizient.',
      ],
      'all_different': [
        'In CrispMath wird `allDifferent` in FlatZincs '
            '`all_different_int([a, b, c])` übersetzt. Der zugrunde liegende '
            'Solver (dart_csp) implementiert die Propagation der '
            'Schrankenkonsistenz über Régins Matching-Algorithmus — bei großen '
            'Argumentlisten deutlich schneller als paarweise.',
        'Die Sudoku-Vorlagen im Sudoku-Modul bauen auf Stapeln von '
            '`allDifferent`-Bedingungen auf — eine pro Zeile, Spalte, Box und '
            'etwaige Variantenzonen.',
      ],
      'no_overlap': [
        'In CrispMath wird `noOverlap` in FlatZincs '
            '`disjunctive([s1, s2, s3], [4, 3, 2])` übersetzt. Der zugrunde '
            'liegende Solver verwendet Edge-Finding plus Vilíms '
            'θ-Baum-Propagator — derselbe Algorithmus wie in MiniZincs '
            'eingebauter Variante.',
        'Klassisches Sequenzierungsproblem auf einer Maschine. In Kombination '
            'mit `minimize` über den Makespan-Ausdruck ergibt sich der optimale '
            'Ablaufplan. Das vollständige DSL-Programm zeigt das zugehörige '
            'Beispiel.',
      ],
      'cumulative': [
        'In CrispMath wird `cumulative` in FlatZincs '
            '`cumulative([starts], [durations], [resources], capacity)` '
            'übersetzt. Der zugrunde liegende Solver verwendet '
            'Timetable-Propagation plus energetisches Schließen — '
            'kapazitätsbewusste Varianten der `noOverlap`-Propagatoren.',
        'Das ressourcenbeschränkte Projektplanungsproblem (RCPSP) stapelt '
            'mehrere `cumulative`-Bedingungen, eine pro Ressourcentyp. Das '
            'Beispiel `dslRcpsp` zeigt ein Projekt mit zwei Ressourcen.',
      ],
      'minimize': [
        'In CrispMath erzeugt `minimize` FlatZincs '
            '`solve minimize __obj__;`, nachdem die Zielvariable durch das '
            'Parsen des linearen Ausdrucks konstruiert wurde. Der zugrunde '
            'liegende Solver verwendet Branch-and-Bound — Zulässigkeitsprüfung, '
            'dann Verschärfen der oberen Schranke bei jeder verbessernden '
            'Lösung.',
        'Siehe das Beispiel `dslCoinChange` — minimiere über eine Summe von '
            'Indikatorvariablen, um die kleinste Menge an Münzen zu finden, '
            'die den Zielbetrag ergibt.',
      ],
      'maximize': [
        'In CrispMath erzeugt `maximize` FlatZincs `solve maximize __obj__;`. '
            'Der zugrunde liegende Solver führt Branch-and-Bound genau wie '
            '`minimize` aus, jedoch mit umgekehrtem Verschärfen der unteren '
            'Schranke.',
        'Klassisches 0/1-Rucksackproblem. Das DSL behandelt dies natürlich als '
            'Deklaration `vars: x_1, ... in 0..1` plus einer linearen '
            'Kapazitätsbedingung und einer linearen Zielfunktion.',
      ],
      'at_least': [
        'Bedingungen können jeden Wert betreffen, nicht nur boolesche — '
            '`atLeast(1, a=3, b=5)` bedeutet, a ist 3 oder b ist 5 (oder '
            'beides).',
      ],
      'at_most': [
        'Kombiniere mit `atLeast` über denselben Bedingungen für eine exakte '
            'Anzahl, oder verwende direkt `exactly`.',
      ],
      'exactly': [
        'Das Arbeitspferd der Logikrätsel — „genau eine Person besitzt die '
            'Katze", „genau zwei Häuser sind blau" usw.',
      ],
      'implies': [
        'Ketten von `implies` kodieren die Hinweislogik von Einstein-/'
            'Zebrarätseln. Siehe das Beispiel `logicGrid`.',
      ],
      'gcc': [
        'Klassiker für Dienstpläne und Stundenpläne — lege fest, wie oft jede '
            'Schicht bzw. jeder Wert vorkommt. Siehe das Beispiel '
            '`nurseRostering`.',
      ],
      'among': [
        'Beschränke oder minimiere c, um zu steuern, wie viele Variablen in '
            'eine Kategorie fallen.',
      ],
      'nvalue': [
        'Mit `!=`-Bedingungen der Graph-Nachbarschaft findet das Minimieren '
            'von nvalue die chromatische Zahl. Siehe das Beispiel '
            '`chromaticNumber`.',
      ],
      'at_most_in_a_row': [
        'Kodiert Ermüdungs-/Musterregeln, die reines Zählen nicht ausdrücken '
            'kann. Der Automat hat einen Zustand je Lauflänge 0..max.',
      ],
      'value_precedence': [
        'Füge es jedem Problem mit vertauschbaren Werten hinzu, um die '
            'k!-Umbenennungsduplikate aus der Lösungsmenge zu entfernen.',
      ],
      'table': [
        'Jede Relation ohne saubere Formel passt in eine Tabelle. Siehe das '
            'Beispiel `menuPairing`.',
      ],
      'element': [
        'Kombiniere mit `minimize`/`maximize` über den nachgeschlagenen Wert, '
            'um eine Auswahl unter tabellierten Kosten zu optimieren.',
      ],
      'diff_n': [
        'Koordinatenvariablen müssen deklariert sein; Breite und Höhe sind '
            'ganzzahlige Literale. Die Behältergröße ergibt sich aus den '
            'Wertebereichen der Koordinaten.',
      ],
      'circuit': [
        'Jede Nachfolgervariable muss mit einem Wertebereich deklariert sein, '
            'der 0..n-1 abdeckt. Mit `; labels=…` werden die Knoten im '
            'Diagramm benannt; `subcircuit` erlaubt übersprungene Knoten.',
      ],
      'soft': [
        'Der Rumpf ist ein einfacher Vergleich (`x = 5`, `x < 3`, `x = y`). '
            'Kann nicht mit `minimize`/`maximize` kombiniert werden — beides '
            'sind Zielfunktionen.',
      ],
      'set_var': [
        'Universumselemente sind ganze Zahlen. Kann nicht mit '
            '`minimize`/`maximize` oder `soft(…)` kombiniert werden. '
            'Mitglieder erscheinen als Chips.',
      ],
      'dot': [
        'Das Skalarprodukt ist |a||b|cos θ — genau dann null, wenn die Vektoren orthogonal sind.',
      ],
      'cross': [
        'Rechte-Hand-Regel: x × y = z. Nur für 3-Vektoren definiert.',
      ],
      'norm': [
        'Das 3-4-5-Dreieck. `norm` ist der Betrag, durch den `unit` teilt.',
      ],
      'unit': [
        'Normieren behält die Richtung, verwirft den Betrag — für den Nullvektor undefiniert.',
      ],
      'mod': [
        'Passt zu `modpow` / `modinv` für modulare Arithmetik; `a mod n` ist `a − n·⌊a/n⌋`.',
      ],
      'nth_root': [
        'Die Kubikwurzel von 27. Für n = 2 die eigene √-Taste; `ⁿ√x` deckt jeden Grad ab.',
      ],
      'sin': [
        'Periode 2π, Wertebereich [-1, 1]. Der Rechner interpretiert das Argument im Bogenmaß.',
      ],
      'cos': [
        'Periode 2π, Wertebereich [-1, 1]; cos ist sin um π/2 verschoben.',
      ],
      'tan': [
        'Periode π; undefiniert, wo cos(x)=0 (x = π/2 + kπ).',
      ],
      'asin': [
        'Definitionsbereich [-1, 1], Hauptwertebereich [-π/2, π/2].',
      ],
      'acos': [
        'Definitionsbereich [-1, 1], Hauptwertebereich [0, π].',
      ],
      'atan': [
        'Definitionsbereich alle reellen Zahlen, Hauptwertebereich (-π/2, π/2).',
      ],
      'sinh': [
        'Ungerade Funktion, unbeschränkt; die Kettenlinien-Familie.',
      ],
      'cosh': [
        'Gerade Funktion, Minimum 1 bei x=0; Form einer hängenden Kette.',
      ],
      'tanh': [
        'Ungerade, Wertebereich (-1, 1); häufige Aktivierungsfunktion in neuronalen Netzen.',
      ],
      'asinh': [
        'Definitionsbereich alle reellen Zahlen; asinh(x) = ln(x + √(x²+1)).',
      ],
      'acosh': [
        'Definitionsbereich x ≥ 1; acosh(x) = ln(x + √(x²−1)).',
      ],
      'atanh': [
        'Definitionsbereich (-1, 1); atanh(x) = ½·ln((1+x)/(1−x)).',
      ],
      'ln': [
        'Umkehrung von exp; Definitionsbereich x > 0. ln(e) = 1.',
      ],
      'log': [
        'Definitionsbereich x > 0. Für andere Basen ln(x)/ln(b).',
      ],
      'exp': [
        'Umkehrung von ln; stets positiv, eigene Ableitung.',
      ],
      'abs': [
        'abs(x) = √(x²); für a+bi ergibt √(a²+b²).',
      ],
      'sqrt': [
        'sqrt(x) = x^(1/2). Für andere Grade die Taste ⁿ√x.',
      ],
      'pi': [
        'Für π auf eine gewählte Stellenzahl die Taste π(N) (pi_precision).',
      ],
      'imaginary_unit': [
        'Komplexe Ergebnisse kommen als I zurück — z. B. solve(x² + 1 = 0) → x = ±i.',
      ],
      'euler_gamma': [
        'Fügt EulerGamma ein; für γ auf eine gewählte Stellenzahl die Taste γ(N) (eulergamma_precision).',
      ],
      'infinity': [
        'Fügt das ∞-Symbol ein; mit `lim` oder `∫` für Grenz-/uneigentliches Verhalten kombinieren.',
      ],
      // --- Sudoku-Varianten ---
      'sudoku_regular': [
        'In CrispMath liegt die reguläre Variante in `lib/engine/sudoku.dart` '
            'als `SudokuVariant.regular`. Der zugrunde liegende Solver '
            'instanziiert ein `allDifferent` pro Zeile, Spalte und Box '
            '(insgesamt 27 bei 9×9) und übergibt sie an `dart_csp`.',
      ],
      'sudoku_x': [
        'In CrispMath ist Sudoku-X `SudokuVariant.x` '
            '(`lib/engine/sudoku.dart`). Der zugrunde liegende Solver fügt '
            'zusätzlich zum regulären Trio aus Zeile/Spalte/Box zwei weitere '
            '`allDifferent`-Bedingungen hinzu — eine pro Diagonale.',
      ],
      'sudoku_disjoint': [
        'In CrispMath ist dies `SudokuVariant.disjoint`. Für ein N×N-Gitter '
            'mit √N × √N großen Boxen fügt die Bedingung N weitere '
            '`allDifferent`-Überlagerungen hinzu — eine pro Position innerhalb '
            'der Box. Die 8×8 wird als einzelne Vorlage geliefert.',
      ],
      'sudoku_killer': [
        'In CrispMath ist dies `SudokuVariant.killer`. Der zugrunde liegende '
            'Solver legt über das reguläre Trio aus Zeile/Spalte/Box je Käfig '
            'eine `allDifferent`-Bedingung und je Käfig eine Bedingung '
            '`Summe = Ziel`. Die Killer-Vorlagen für 4×4 und 9×9 werden beide '
            'geliefert.',
      ],
      'eq_op': [
        'Wird zu SymEngines Eq(2, 2) abgesenkt und zu True vereinfacht.',
        'Symbolisch — bleibt als Gleichung, wenn x frei ist.',
      ],
      'ne_op': [
        'Wird zu SymEngines Ne(3, 4) abgesenkt.',
        'Gleiche Werte ergeben false.',
      ],
      'lt_op': [
        'Wird zu SymEngines Lt(2, 5) abgesenkt.',
        'Nicht strikt kleiner — verwende <= für nicht-strikt.',
      ],
      'le_op': [
        'Wird zu SymEngines Le(5, 5) abgesenkt.',
        'Strikt größer besteht den Test nicht.',
      ],
      'gt_op': [
        'Wird zu SymEngines Gt(10, 3) abgesenkt.',
      ],
      'ge_op': [
        'Wird zu SymEngines Ge(5, 5) abgesenkt.',
      ],
      'and_op': [
        'Beide Prädikate gelten → true.',
        'Ein falscher Operand → false.',
      ],
      'or_op': [
        'Ein wahrer Operand genügt.',
      ],
      'not_op': [
        '4 ist keine Primzahl → not false → true.',
        'Negiert die Gleichheit.',
      ],
      'xor_op': [
        'Beide true → xor ist false.',
        'Genau einer true → xor ist true.',
      ],
      'if_cond': [
        '7 ist prim → Bedingung ist true → gibt 100 zurück.',
        '2 ist nicht > 5 → gibt den else-Zweig zurück.',
      ],
    };
    final list = hints[id];
    if (list == null || index < 0 || index >= list.length) return null;
    return list[index];
  }

  @override
  String get settingsWorkedExamples => 'Bibliothek mit Beispielaufgaben';
  @override
  String get settingsWorkedExamplesSubtitle =>
      'Jetzt auch über das Buchsymbol oben im Rechner und im Notizblock '
      'erreichbar. Hier tippen für die vollständige Bibliothek.';
  @override
  String get functionRefTitle => 'Funktionsreferenz';
  @override
  String get functionRefSearchHint => 'Funktionen durchsuchen…';
  @override
  String get functionRefEmpty => 'Keine Funktion entspricht diesem Filter.';
  @override
  String get functionRefSeeAlso => 'Siehe auch:';
  @override
  String get functionRefTryInCalculator => 'Im Rechner ausprobieren';
  @override
  String get functionRefOpenModule => 'Modul öffnen';
  @override
  String get functionRefSeeWorkedExample => 'Beispielaufgabe ansehen';
  @override
  String get functionRefCatCas => 'CAS';
  @override
  String get functionRefCatNumberTheory => 'Zahlentheorie';
  @override
  String get functionRefCatPrecision => 'Hochpräzision';
  @override
  String get functionRefCatMatrix => 'Matrix';
  @override
  String get functionRefCatGraphing => 'Graphen';
  @override
  String get functionRefCatStatistics => 'Statistik';
  @override
  String get functionRefCatConstraints => 'Bedingungen';
  @override
  String get functionRefCatSudoku => 'Sudoku';
  @override
  String get functionRefCatUnits => 'Einheiten';
  @override
  String get functionRefCatLogic => 'Logik';
  @override
  String get settingsFunctionRef => 'Funktionsreferenz';
  @override
  String get settingsFunctionRefSubtitle =>
      'Jede CrispMath-Funktion durchstöbern: Signatur, Beispiele, '
      'verwandte Funktionen und ein Schnellzugriff in den Rechner.';

  @override
  String get importDataTitle => 'Daten importieren';
  @override
  String get importDataSubtitle =>
      'Füge ein JSON aus einem früheren Export ein, um Verlauf, '
      'Variablen, Funktionen und Einstellungen wiederherzustellen.';
  @override
  String get importDataWarning =>
      'Dies überschreibt den aktuellen Verlauf, Variablen und '
      'Graphfunktionen. Es gibt keine Rückgängig-Funktion — kopiere '
      'vorher den aktuellen Zustand, wenn du ihn behalten möchtest.';
  @override
  String get importDataApply => 'Anwenden';
  @override
  String get importDataEmpty => 'Füge ein JSON ein, um zu importieren.';
  @override
  String get importDataNotObject =>
      'Das JSON muss ein Objekt sein (beginnt mit `{`).';
  @override
  String get importDataApplied => 'Importiert';
  @override
  String get settingsImportData => 'Daten importieren';
  @override
  String get settingsImportDataSubtitle =>
      'Füge ein JSON aus einem früheren Export zum Wiederherstellen ein.';

  @override
  String get userFunctionsTitle => 'Benutzerdefinierte Funktionen';
  @override
  String get userFunctionsHelp =>
      'Definiere eine Funktion einmal, rufe sie aus jedem Ausdruck auf. '
      'Z. B. `f(x) = x^2 + 1`, dann ergibt `f(3) + 1` den Wert 11. Auch '
      'die Komposition `g(f(x))` funktioniert, sofern beide definiert sind.';
  @override
  String get userFunctionsEmpty =>
      'Noch keine benutzerdefinierten Funktionen. Tippe Hinzufügen, um '
      'die erste anzulegen.';
  @override
  String get userFunctionsAdd => 'Hinzufügen';
  @override
  String get userFunctionsEdit => 'Bearbeiten';
  @override
  String get userFunctionsDelete => 'Löschen';
  @override
  String get userFunctionsName => 'Name';
  @override
  String get userFunctionsNameHelp =>
      'Einzelner Kleinbuchstabe (a..z), der nicht mit eingebauten Namen '
      'kollidiert.';
  @override
  String get userFunctionsNameRequired => 'Pflichtfeld';
  @override
  String get userFunctionsNameInvalid =>
      'Muss ein einzelner Kleinbuchstabe (a..z) sein.';
  @override
  String get userFunctionsParam => 'Parameter';
  @override
  String get userFunctionsBody => 'Rumpf';
  @override
  String get userFunctionsBodyRequired => 'Funktionsrumpf erforderlich';
  @override
  String get settingsUserFunctions => 'Benutzerdefinierte Funktionen';
  @override
  String get settingsUserFunctionsSubtitle =>
      'Definiere benannte Funktionen wie f(x) = x^2 + 1 und nutze sie '
      'in jedem Ausdruck wieder.';

  @override
  String get onboardingSkip => 'Überspringen';
  @override
  String get onboardingNext => 'Weiter';
  @override
  String get onboardingDone => 'Verstanden';
  @override
  String onboardingPage(int current, int total) => '$current / $total';
  @override
  String get onboardingKeypadTitle => 'Tastenfeld mit Reitern';
  @override
  String get onboardingKeypadBody =>
      'Wechsle zwischen den Reitern Num, Trig, CAS und Erweitert, um die '
      'gewünschte Operation zu finden. Bei breiteren Fenstern passt das '
      'ganze Tastenfeld auf einen Bildschirm — ohne Reiter.';
  @override
  String get onboardingHistoryTitle => 'Verlauf durchblättern';
  @override
  String get onboardingHistoryBody =>
      'Jede Berechnung wird gespeichert. Nach oben scrollen, um sie '
      'erneut zu sehen, lange drücken zum Kopieren oder erneut '
      'Verwenden, Suchsymbol antippen zum Filtern.';
  @override
  String get onboardingFunctionsTitle => 'Funktion auswählen';
  @override
  String get onboardingFunctionsBody =>
      'Die Tasten ∫⌄, d/dx⌄ und solve⌄ öffnen Schritt-für-Schritt-'
      'Auswahlen, die das Ergebnis Regel für Regel erklären.';
  @override
  String get onboardingAnalysisTitle => 'Analyse-Hub';
  @override
  String get onboardingAnalysisBody =>
      'Kurvendiskussion, Ebenen, Kegelschnitte, 3D-Diagramme, Statistik '
      'und der Einheitenrechner finden sich alle im Reiter Analyse.';
  @override
  String get onboardingNotepadTitle => 'Notizblock';
  @override
  String get onboardingNotepadBody =>
      'Mathe wie ein Dokument schreiben — ein Ausdruck pro Zeile, '
      'Ergebnisse in der rechten Spalte. Variablen definieren '
      '(tax = 0.085), frühere Zeilen referenzieren und zusehen, '
      'wie sich alles live aktualisiert.';
  @override
  String get onboardingWorksheetTitle =>
      'Ein Rechner mit Gedächtnis';
  @override
  String get onboardingWorksheetBody =>
      'Beginne mit einem Arbeitsblatt: a = 3, f(x) = x² + a, f(4). Ändere a, und alle Ergebnisse samt verknüpftem Graphen rechnen neu. Prüfpunkt speichern, vergleichen, wiederherstellen und die ganze Sitzung exportieren.';
  @override
  String get onboardingTryWorksheet =>
      'Live-Arbeitsblatt ausprobieren';
  @override
  String get analysisLabsTitle =>
      'Labor';
  @override
  String get analysisLabsSubtitle =>
      'Constraint-Probleme, Sudoku-Löser und der 3D-Szeneneditor';
  @override
  String get aboutOurApps =>
      'Unsere Apps';
  @override
  String get aboutOurAppsIntro =>
      'Weitere Apps desselben Entwicklers. Apps in TestFlight sind kostenlose Betas: Der Link installiert zuerst Apples TestFlight.';
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
      'Bald verfügbar';
  @override
  String get aboutThisApp =>
      'diese App';
  @override
  String get settingsReplayTour => 'Einführungstour erneut anzeigen';
  @override
  String get settingsReplayTourSubtitle =>
      'Die Erststart-Tour beim nächsten Öffnen der App noch einmal zeigen.';

  @override
  String get helpTitle => 'Hilfe';
  @override
  String get helpFunctionsHeading => 'Unterstützte Funktionen';
  @override
  String get helpMatrixHeading => 'Matrix-Syntax';
  @override
  String get helpStepsHeading => 'Schritt-für-Schritt-Lösungen';
  @override
  String get helpMatrixBody =>
      'Matrizen mit `;` als Zeilen- und `,` als Spaltentrenner eingeben:\n\n    [1, 2; 3, 4]\n\nIntern wird das in `Matrix([[1, 2], [3, 4]])` umgewandelt. Operationen: det, inv, transpose, rref, +, -, *.';
  @override
  String get helpStepsBody =>
      'Drei Tasten im CAS-Reiter öffnen Schritt-für-Schritt-Spuren:\n\n  • d/dx⌄ für Ableitungsschritte\n  • solve⌄ für Gleichungen lösen\n  • ∫⌄ für unbestimmte Integration\n\nJede zeigt die angewandte Regel pro Schritt plus das Endergebnis.';

  @override
  String get constantsTitle => 'Konstantenreferenz';
  @override
  String get constantsSearchHint => 'Nach Symbol, Name oder Einheit suchen…';
  @override
  String get constantsNoMatches => 'Keine Konstanten passen zum Filter.';
  @override
  String get constantsAllCategory => 'Alle';
  @override
  String get constantsCategoryMathematical => 'Mathematisch';
  @override
  String get constantsCategoryPhysical => 'Physikalisch';
  @override
  String get constantsCategoryChemistry => 'Chemie';
  @override
  String get constantsCategoryAstronomy => 'Astronomie';
  @override
  String get constantsCopyValue => 'Wert kopieren';
  @override
  String constantsCopiedToast(String symbol) =>
      '$symbol in Zwischenablage kopiert';
  @override
  String get settingsConstants => 'Konstantenreferenz';
  @override
  String get settingsConstantsSubtitle =>
      'Physikalische, mathematische, chemische und astronomische Konstanten.';

  @override
  String get tabNum => 'Num';
  @override
  String get tabTrig => 'Trig';
  @override
  String get tabCas => 'CAS';
  @override
  String get tabAdvanced => 'Erweitert';
  @override
  String get tabVars => 'Variablen';
  @override
  String get tabBasic => 'Basis';
  @override
  String get tabSymbolic => 'Symbolisch';

  @override
  String? stepNote(StepNote note) {
    final p = note.params;
    switch (note.key) {
      case 'startEquation':
        return 'Wir beginnen mit der gegebenen Gleichung.';
      case 'moveRightSideOver':
        return 'Subtrahieren der rechten Seite von beiden Seiten bringt '
            'die Gleichung in die Standardform `Ausdruck = 0`, sodass der '
            'lineare oder quadratische Löser anwendbar ist.';
      case 'noEqualsSign':
        return 'Kein `=` in der Eingabe; wir behandeln sie als '
            '${p['body']} = 0.';
      case 'doesNotDependOn':
        return 'Die Gleichung hängt nicht von ${p['var']} ab.';
      case 'solveFallthroughSymbolic':
        return 'Keine standardmäßige lineare oder quadratische Form — '
            'die Antwort übernimmt der symbolische Löser.';
      case 'linearIdentifyCoefs':
        return 'Lies den Leitkoeffizienten und den konstanten Term ab — '
            'dies ist eine lineare Gleichung.';
      case 'moveConstant':
        return 'Bringe die Konstante auf die andere Seite.';
      case 'divideByCoef':
        return 'Teile beide Seiten durch den Leitkoeffizienten, um '
            '${p['var']} zu isolieren.';
      case 'quadraticIdentifyCoefs':
        return 'Lies die drei Koeffizienten am Polynom ab. Wir nehmen a aus '
            'der zweiten Ableitung ÷ 2, b aus der ersten Ableitung bei '
            '${p['var']} = 0 und c aus dem Polynom bei ${p['var']} = 0.';
      case 'discriminant':
        return 'Die Diskriminante sagt uns, wie viele reelle Wurzeln es '
            'gibt: positiv → zwei verschiedene reelle Wurzeln; null → eine '
            'Doppelwurzel; negativ → zwei komplex konjugierte Wurzeln.';
      case 'quadFormulaApply':
        return 'Setze a, b und Δ in die Mitternachtsformel ein. Das `±` '
            'liefert beide Wurzeln in einem Schritt.';
      case 'integralPullMinusOut':
        return 'Ziehe das führende Minuszeichen aus dem Integral; der '
            'Rest ist einfach ∫f.';
      case 'exprDoesNotDependOn':
        return '${p['expr']} hängt nicht von ${p['var']} ab.';
      case 'integralIdentityPower1':
        return 'Die Potenzregel für n=1: Erhöhe den Exponenten auf 2 und '
            'teile durch den neuen Exponenten.';
      case 'integralLinearity':
        return 'Integration ist linear: Das Integral einer Summe ist die '
            'Summe der Integrale.';
      case 'integralPullConstantOut':
        return 'Ziehe `${p['const']}` vor das Integral — Konstanten '
            'lassen sich herausziehen.';
      case 'integralReciprocalLog':
        return 'Das Integral von 1/${p['var']} ist der natürliche '
            'Logarithmus des Betrags.';
      case 'integralPowerRule':
        return 'Erhöhe den Exponenten um 1 und teile durch den neuen '
            'Exponenten. Funktioniert für jede Konstante n ≠ −1.';
      case 'uSubLinear':
        return 'Setze u = ${p['u']}; dann ist du = '
            '(${p['slope']})·d${p['var']}.';
      case 'integralStandardAntideriv':
        return 'Verwende die Standard-Stammfunktion für ${p['fn']}.';
      case 'uSubLinearFn':
        return 'Setze u = ${p['u']}; dann ist du = '
            '(${p['slope']})·d${p['var']}. Die Stammfunktion von '
            '${p['fn']} ist die Standardform, ausgewertet an u und durch '
            'die Steigung geteilt.';
      case 'ibpLnX':
        final v = p['var']!;
        return 'Setze u = ln($v), dv = d$v. Dann ist du = (1/$v)·d$v und '
            'v = $v, also ∫u·dv = u·v − ∫v·du = $v·ln($v) − ∫1 d$v.';
      case 'ibpXTimesF':
        return 'Setze u = ${p['var']} (also du = d${p['var']}) und '
            'dv = ${p['right']}·d${p['var']}, woraus v = ${p['v']} folgt.';
      case 'ibpRepeated':
        return 'Setze u = ${p['u']} und dv = ${p['right']}·d${p['var']}. '
            'Dann ist du = ${p['n']}·… (eine Potenz von ${p['var']} weniger) '
            'und v = ${p['v']}, sodass das neue Integral eine Potenz von '
            '${p['var']} verliert — Rekursion.';
      case 'uSubNonlinear':
        return 'Setze u = ${p['u']}; dann ist du = '
            '(${p['du']})·d${p['var']}. Der Integrand hat die Form '
            'f(u)·du, daher liefert die Substitution ∫f(u) du = '
            'Standard-Stammfunktion von ${p['fn']} ausgewertet an u'
            '${p['ratio'] == '1' ? '.' : ', mal dem konstanten Faktor ${p['ratio']}.'}';
      case 'integralLogDerivative':
        return 'Der Zähler ist (${p['ratio']})·(d/d${p['var']}[${p['den']}]), '
            'also ist das Integral ${p['ratio']}·ln|${p['den']}|.';
      case 'partialFractions':
        return 'Der Nenner hat unterschiedliche ganzzahlige Nullstellen '
            '${p['roots']}. Die Cover-up-Methode liefert '
            'A_i = P(r_i) / Q\'(r_i) für jede Nullstelle.';
      case 'partialFractionsIntegrate':
        return 'Jedes Stück `A/(x-r)` integriert sich zu A·ln|x-r|.';
      case 'trigArctanForm':
        return 'Setze a² = ${p['aSq']}, also a = ${p['a']}. Die '
            'Standardform liefert (1/a)·arctan(${p['var']}/a).';
      case 'trigArcsinForm':
        return 'Setze a² = ${p['aSq']}, also a = ${p['a']}. Die '
            'Standardform liefert arcsin(${p['var']}/a).';
      case 'integralFallthroughSymbolic':
        return 'Keine standardmäßige Lehrbuchregel passt zu dieser Form '
            '— die Antwort übernimmt der symbolische Integrator.';
      case 'diffIdentity':
        return 'Die Ableitung von ${p['var']} nach sich selbst ist 1.';
      case 'diffSumDifference':
        return 'Leite jeden Summanden einzeln ab; die Ableitung verteilt '
            'sich über `+` und `−`.';
      case 'diffQuotient':
        return 'Für einen Quotienten gilt: Zähler `f′g − fg′`, Nenner '
            'wird quadriert.';
      case 'diffProduct':
        return 'Für ein Produkt: leite jeden Faktor ab und addiere die '
            'Stücke — `(fg)′ = f′g + fg′`.';
      case 'diffPowerSimple':
        return 'Ziehe den Exponenten als Koeffizient herunter und '
            'reduziere den Exponenten um 1.';
      case 'diffPowerChain':
        return 'Ziehe den Exponenten herunter und reduziere ihn um 1, '
            'multipliziere dann mit der Ableitung der inneren Basis — '
            'dieser Faktor `d/d${p['var']}[${p['base']}]` ist die '
            'Kettenregel.';
      case 'diffExponential':
        return 'Wenn die Variable im Exponenten steht, ist die Ableitung '
            'der gleiche Ausdruck mal `ln(Basis)` mal die Ableitung des '
            'Exponenten.';
      case 'diffStandardSimple':
        return 'Wende die Standardableitung für ${p['fn']} an.';
      case 'diffStandardChain':
        return 'Das Argument hängt von ${p['var']} ab, also multipliziere '
            'mit dessen Ableitung (Kettenregel).';
      case 'diffFallthrough':
        return 'Kein Muster einer höherwertigen Regel erkannt für diese '
            'Form.';
    }
    return null;
  }
}

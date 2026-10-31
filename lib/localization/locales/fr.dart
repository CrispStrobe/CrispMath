// lib/localization/locales/fr.dart
//
// French strings for [AppLocalizations].

part of '../app_localizations.dart';

class FrLocalizations implements AppLocalizations {
  const FrLocalizations();

  @override
  String get navCalculator => 'Calculatrice';
  @override
  String get navNotepad => 'Notes';
  @override
  String get notepadDefaultDocName => 'Sans titre';
  @override
  String get notepadAddLine => 'Ajouter une ligne';
  @override
  String get notepadDeleteLine => 'Supprimer la ligne';
  @override
  String get notepadDocumentMenu => 'Menu du document';
  @override
  String get notepadNewDocument => 'Nouveau document';
  @override
  String get notepadOpenWelcomeSample => 'Ouvrir l\'exemple de bienvenue';
  @override
  String get notepadRecalculateAll => 'Tout recalculer';
  @override
  String get notepadRename => 'Renommer';
  @override
  String get notepadDuplicate => 'Dupliquer';
  @override
  String get notepadCopyAsMarkdown => 'Copier en Markdown';
  @override
  String get notepadDeleteDocument => 'Supprimer le document';
  @override
  String get notepadUndo => 'Annuler';
  @override
  String get notepadLineDeleted => 'Ligne supprimée';
  @override
  String notepadDocumentDeleted(String name) => 'Document « $name » supprimé';
  @override
  String get notepadCopiedAsMarkdown => 'Copié en Markdown';
  @override
  String get notepadCopyResult => 'Copier le résultat';
  @override
  String get notepadCopyAsLatex => 'Copier en LaTeX';
  @override
  String get notepadCopiedResult => 'Résultat copié';
  @override
  String get notepadCopiedAsLatex => 'Copié en LaTeX';
  @override
  String get notepadEmptyTitle => 'Aucun document';
  @override
  String get notepadEmptyBody =>
      'Créez un nouveau document ou ouvrez l\'exemple de bienvenue pour commencer.';
  @override
  String notepadFreeVars(String names) => 'libre : $names';
  @override
  String notepadBlockedBy(String alias) => 'Bloqué par $alias';
  @override
  String notepadCycle(String path) => 'Cycle : $path';
  @override
  String notepadUnknownImport(String name) =>
      'Import inconnu : « $name » absent des variables globales';
  @override
  String notepadInvalidImport(String name) =>
      'Nom d\'import invalide : « $name »';
  @override
  String get notepadEmptyImportList => 'Liste d\'imports vide';
  @override
  String notepadUseDirective(String code) => 'Directive use : $code';
  @override
  String get notepadManageTitle => 'Gérer les notes';
  @override
  String get notepadManageNotepads => 'Gérer les notes…';
  @override
  String get notepadOpenDocument => 'Ouvrir';
  @override
  String get notepadOpenFile => 'Ouvrir un fichier de feuille de calcul';
  @override
  String get notepadSaveFile => 'Enregistrer la feuille de calcul';
  @override
  String get notepadFileSaved => 'Feuille de calcul enregistrée';
  @override
  String get notepadFileOpenFailed =>
      'Impossible d’ouvrir la feuille de calcul';
  @override
  String get notepadFileSaveFailed =>
      'Impossible d’enregistrer la feuille de calcul';
  @override
  String get notepadExportAsJson => 'Exporter en JSON';
  @override
  String get notepadImportFromJson => 'Importer depuis JSON';
  @override
  String get notepadImport => 'Importer';
  @override
  String get notepadImportJsonHint =>
      'Collez ici une charge utile JSON de note…';
  @override
  String get notepadJsonCopied => 'JSON de note copié dans le presse-papiers';
  @override
  String notepadJsonImported(String name) => '« $name » importé';
  @override
  String get notepadJsonImportFailed =>
      'Échec de l\'import : charge utile JSON de note invalide';
  @override
  String get graphErrorEmpty => 'La fonction est vide';
  @override
  String get graphErrorUnbalanced =>
      'Parenthèses ou crochets non équilibrés — la fonction ne peut pas être tracée';
  @override
  String get graphErrorTrailingOperator =>
      'La fonction se termine par un opérateur — ajoutez le membre de droite';
  @override
  String get navGraphing => 'Graphes';
  @override
  String get navFunctions => 'Fonctions';
  @override
  String get navAnalysis => 'Analyse';
  @override
  String get navSettings => 'Paramètres';

  @override
  String get historyHere => 'L\'historique des calculs apparaîtra ici.';
  @override
  String get historyLabel => 'Historique :';
  @override
  String get clearButton => 'C';
  @override
  String get clearHistory => 'Effacer l\'historique';
  @override
  String get clearHistoryConfirm =>
      'Supprimer toutes les entrées de l\'historique des calculs ?';
  @override
  String get searchHistory => 'Rechercher dans l\'historique';
  @override
  String get searchHistoryHint => 'Filtrer l\'historique…';
  @override
  String get historyNoMatches => 'Aucune entrée correspondante.';

  @override
  String get graphSampling => 'Actualisation du graphe';
  @override
  String get graphSamplingFailed => 'Impossible d’actualiser le graphe.';
  @override
  String get graphNoRealValues =>
      'Aucune valeur réelle dans cet intervalle. Vérifiez l’expression ou essayez un autre intervalle.';
  @override
  String get graphRetry => 'Réessayer';
  @override
  String graphingTitle(int count) => 'Graphes ($count fonctions)';
  @override
  String functionAdded(int slot) => 'Fonction ajoutée à Y$slot';
  @override
  String functionRemoved(int slot) => 'Y$slot supprimée';
  @override
  String get allSlotsFull =>
      'Tous les emplacements de fonction sont occupés. Effacez-en une d\'abord.';
  @override
  String get clearAllFunctions => 'Effacer toutes les fonctions';
  @override
  String get clearAllFunctionsConfirm =>
      'Voulez-vous vraiment effacer toutes les fonctions tracées ?';
  @override
  String get cancel => 'Annuler';
  @override
  String get clearAll => 'Tout effacer';
  @override
  String get zoomIn => 'Zoom avant';
  @override
  String get zoomOut => 'Zoom arrière';
  @override
  String get resetView => 'Réinitialiser la vue';
  @override
  String get showKeypad => 'Afficher le clavier';
  @override
  String get hideKeypad => 'Masquer le clavier';
  @override
  String get showAnnotations => 'Afficher racines et extréma';
  @override
  String get hideAnnotations => 'Masquer racines et extréma';
  @override
  String get analyzeFunctions => 'Analyser les fonctions';
  @override
  String get selectFunctionToAnalyze => 'Choisir la fonction à analyser';
  @override
  String get plotButton => 'Tracer';
  @override
  String get enterFunctionPrompt =>
      'Saisissez une fonction ci-dessous pour la tracer.';

  @override
  String get analysisModulesTitle => 'Modules d\'analyse';
  @override
  String get moduleCurveSketching => 'Étude de fonction';
  @override
  String get moduleCurveSketchingSubtitle =>
      'Analyse complète d\'une fonction f(x)';
  @override
  String get modulePlanes => 'Plans';
  @override
  String get modulePlanesSubtitle =>
      'Analyser des plans 3D en forme cartésienne ou paramétrique';
  @override
  String get moduleConics => 'Coniques';
  @override
  String get moduleConicsSubtitle =>
      'Classer Ax² + Bxy + Cy² + Dx + Ey + F = 0';
  @override
  String get moduleStatistics => 'Statistiques';
  @override
  String get moduleStatisticsSubtitle =>
      'Statistiques descriptives, régression linéaire, lois normale & binomiale';
  @override
  String get module3DTitle => 'Graphique 3D';
  @override
  String get module3DSubtitle =>
      'Tracer z = f(x, y) comme une surface filaire rotative';
  @override
  String get module3DFunctionLabel => 'f(x, y)';
  @override
  String get module3DRangeLabel => 'Plage';
  @override
  String get module3DResample => 'Rééchantillonner la grille';
  @override
  String get module3DTapPlot =>
      'Saisissez une fonction de x et y, puis appuyez sur Tracer.';

  // -- P9-A2 --
  @override
  String get module3DScene => 'Scène 3D';
  @override
  String get module3DSceneSubtitle =>
      'Rendre plusieurs objets 3D ensemble — plans, droites, sphères, quadriques';
  @override
  String get scene3DAddPlane => 'Ajouter un plan';
  @override
  String get scene3DEditPlane => 'Modifier le plan';
  @override
  String get scene3DEmpty =>
      'Glisser pour tourner · pincer pour zoomer · appuyer sur + pour ajouter un plan';
  @override
  String get scene3DPanelEmpty => 'Aucun objet pour l\'instant';
  @override
  String get scene3DObjectLabel => 'Étiquette';
  @override
  String get scene3DColor => 'Couleur';
  @override
  String get scene3DAdd => 'Ajouter';
  @override
  String get scene3DSave => 'Enregistrer';
  @override
  String get scene3DEdit => 'Modifier';
  @override
  String get scene3DDelete => 'Supprimer';
  @override
  String get scene3DHide => 'Masquer';
  @override
  String get scene3DShow => 'Afficher';
  @override
  String get scene3DLabelRequired => 'Étiquette requise';
  @override
  String get scene3DCoefRequired => 'Requis';
  @override
  String get scene3DCoefInvalid => 'Nombre invalide';
  @override
  String get scene3DPlaneZeroNormal =>
      'Le vecteur normal (a, b, c) doit être non nul';

  // -- P9-A3 --
  @override
  String get scene3DAddObject => 'Ajouter un objet';
  @override
  String get scene3DAddLine => 'Ajouter une droite';
  @override
  String get scene3DEditLine => 'Modifier la droite';
  @override
  String get scene3DAddSphere => 'Ajouter une sphère';
  @override
  String get scene3DEditSphere => 'Modifier la sphère';
  @override
  String get scene3DLinePointDir => 'Point + direction';
  @override
  String get scene3DLineTwoPoints => 'Deux points';
  @override
  String get scene3DLinePoint => 'Point';
  @override
  String get scene3DLineDirection => 'Direction';
  @override
  String get scene3DLineFirstPoint => 'Premier point';
  @override
  String get scene3DLineSecondPoint => 'Second point';
  @override
  String get scene3DLineZeroDirection =>
      'Le vecteur direction doit être non nul (ou choisir deux points distincts)';
  @override
  String get scene3DSphereCenter => 'Centre';
  @override
  String get scene3DSphereRadius => 'Rayon';
  @override
  String get scene3DSpherePositiveRadius =>
      'Le rayon doit être strictement positif';

  // -- P9-A4 --
  @override
  String get scene3DIntersectionsEmpty =>
      'Ajoutez deux objets ou plus pour voir leurs intersections';
  @override
  String scene3DIntersectionsTitle(int n) =>
      n == 1 ? '1 intersection' : '$n intersections';
  @override
  String get intersectionPoint => 'Point';
  @override
  String get intersectionTwoPoints => 'Deux points';
  @override
  String get intersectionLine => 'Droite';
  @override
  String get intersectionCircle => 'Cercle';
  @override
  String intersectionReason(String key) {
    switch (key) {
      case 'parallelPlanes':
        return 'Plans parallèles (aucune intersection)';
      case 'coincidentPlanes':
        return 'Plans confondus';
      case 'lineParallelToPlane':
        return 'Droite parallèle au plan (aucune intersection)';
      case 'lineInPlane':
        return 'Droite contenue dans le plan';
      case 'sphereMissesPlane':
        return 'Le plan ne touche pas la sphère';
      case 'degeneratePlane':
        return 'Plan dégénéré (vecteur normal nul)';
      case 'parallelLines':
        return 'Droites parallèles (aucune intersection)';
      case 'coincidentLines':
        return 'Droites confondues';
      case 'skewLines':
        return 'Droites non coplanaires (ne se rencontrent pas)';
      case 'lineMissesSphere':
        return 'La droite ne touche pas la sphère';
      case 'degenerateLine':
        return 'Droite dégénérée (direction nulle)';
      case 'spheresApart':
        return 'Sphères trop éloignées';
      case 'sphereInsideSphere':
        return 'Une sphère est contenue dans l\'autre';
      case 'coincidentSpheres':
        return 'Sphères identiques';
      case 'numericalFailure':
        return 'Cas numérique limite (essayer d\'autres valeurs)';
      // P9-A5b: plan × quadrique → conique.
      case 'circle':
        return 'Cercle';
      case 'ellipse':
        return 'Ellipse';
      case 'parabola':
        return 'Parabole';
      case 'hyperbola':
        return 'Hyperbole';
      case 'degenerateConic':
        return 'Conique dégénérée (paire de droites ou point)';
      case 'noConic':
        return 'Le plan ne touche pas la quadrique';
      case 'planeOnQuadric':
        return 'Le plan repose sur la quadrique';
      default:
        return key;
    }
  }

  // -- P9-A5 --
  @override
  String get scene3DAddQuadric => 'Ajouter une quadrique';
  @override
  String get scene3DEditQuadric => 'Modifier la quadrique';
  @override
  String get scene3DQuadricKind => 'Type';
  @override
  String get scene3DQuadricSemiAxes => 'Demi-axes';
  @override
  String get scene3DQuadricPositiveSemiAxes =>
      'Les demi-axes doivent être strictement positifs (a, b, c > 0)';
  @override
  String get quadricKindEllipsoid => 'Ellipsoïde';
  @override
  String get quadricKindCone => 'Cône elliptique';
  @override
  String get quadricKindCylinder => 'Cylindre elliptique';
  @override
  String get quadricKindParaboloid => 'Paraboloïde elliptique';
  @override
  String get quadricKindHyperboloid1 => 'Hyperboloïde (1 nappe)';
  @override
  String get quadricKindHyperboloid2 => 'Hyperboloïde (2 nappes)';

  // -- P9-A5c.3 --
  @override
  String get conicOpenIn3DScene => 'Ouvrir dans la scène 3D';
  @override
  String get conicLiftNotAConic =>
      'Ce n\'est pas une conique — rien à transposer. Ajoutez d\'abord des termes quadratiques.';

  // -- P9-A6 --
  @override
  String get scene3DAddParametricSurface => 'Ajouter une surface paramétrique';
  @override
  String get scene3DEditParametricSurface => 'Modifier la surface paramétrique';
  @override
  String get scene3DAddParametricCurve => 'Ajouter une courbe paramétrique';
  @override
  String get scene3DEditParametricCurve => 'Modifier la courbe paramétrique';
  @override
  String get scene3DParametricSurface => 'Surface paramétrique';
  @override
  String get scene3DParametricCurve => 'Courbe paramétrique';

  @override
  String get moduleUnitConverterTitle => 'Convertisseur d\'unités';
  @override
  String get moduleUnitConverterSubtitle =>
      'Convertir longueurs, temps, masse, température, vitesse, angle';
  @override
  String get sectionVariables => 'Variables';
  @override
  String get sectionGraphFunctions => 'Fonctions graphiques';
  @override
  String get sectionMemorySlots => 'Emplacements mémoire';
  @override
  String get funcCtxShowOnGraph => 'Afficher dans le graphique';
  @override
  String get funcCtxAnalyze => 'Analyser (étude de fonction)';
  @override
  String get funcCtxDifferentiate => 'Dériver';
  @override
  String get funcCtxIntegrate => 'Intégrer';
  @override
  String get funcCtxSolve => 'Résoudre f(x) = 0';
  @override
  String get funcCtxCopy => 'Copier l\'expression';
  @override
  String get funcEditorTitle => 'Éditeur de fonctions (Y=)';
  @override
  String get funcEditorDone => 'Terminé';
  @override
  String get funcEditorSelectFirst =>
      'Sélectionnez un champ de fonction à modifier.';
  @override
  String get funcEditorAnalyzeTooltip => 'Analyser cette fonction';
  @override
  String get funcEditorGraphTooltip => 'Tracer cette fonction';
  @override
  String get unitDimLength => 'Longueur';
  @override
  String get unitDimTime => 'Temps';
  @override
  String get unitDimMass => 'Masse';
  @override
  String get unitDimTemperature => 'Température';
  @override
  String get unitDimVelocity => 'Vitesse';
  @override
  String get unitDimAngle => 'Angle';
  @override
  String get planeAnalysisTitle => 'Analyse de plan';
  @override
  String get planeRepCoordinate => 'Coordonnées';
  @override
  String get planeRepParametric => 'Paramétrique';
  @override
  String get buttonAnalyze => 'Analyser';
  @override
  String get buttonClassify => 'Classifier';
  @override
  String get curveAnalysisEnterFunction =>
      'Saisissez une fonction à analyser :';
  @override
  String get curveResultWarnings => 'Avertissements';
  @override
  String get curveResultDerivatives => 'Dérivées';
  @override
  String get curveResultKeyPoints => 'Points clés';
  @override
  String get curveResultYIntercept => 'Ordonnée à l\'origine';
  @override
  String get curveResultRoots => 'Racines';
  @override
  String get curveResultExtrema => 'Extrema (Minima/Maxima)';
  @override
  String get curveResultInflectionPoints => 'Points d\'inflexion';
  @override
  String get curveResultNoExtrema => 'Aucun extremum trouvé.';
  @override
  String get curveResultNoInflection => 'Aucun point d\'inflexion trouvé.';
  @override
  String curveAnalysisOfFunction(String function) =>
      'Analyse de f(x) = $function';
  @override
  String curveResultPointPrefix(String point) => 'Point : $point';
  @override
  String get extremumLocalMinimum => 'Minimum local';
  @override
  String get extremumLocalMaximum => 'Maximum local';
  @override
  String get extremumCriticalPoint => 'Point critique';
  @override
  String get extremumInflectionPoint => 'Point d\'inflexion';
  @override
  String get extremumNoCriticalPoints => 'Aucun point critique trouvé';
  @override
  String get extremumConstantConcavity =>
      'La fonction a une concavité constante (f\'\'(x) = 0 partout)';
  @override
  String get statisticsTitle => 'Statistiques';
  @override
  String get statsTabDescriptive => 'Descriptive';
  @override
  String get statsTabRegression => 'Régression';
  @override
  String get statsTabDistributions => 'Distributions';
  @override
  String get statsTabTests => 'Tests';
  @override
  String get statsDescCount => 'Effectif';
  @override
  String get statsDescSum => 'Somme';
  @override
  String get statsDescMean => 'Moyenne';
  @override
  String get statsDescMedian => 'Médiane';
  @override
  String get statsDescMode => 'Mode';
  @override
  String get statsDescMin => 'Min';
  @override
  String get statsDescMax => 'Max';
  @override
  String get statsDescRange => 'Étendue';
  @override
  String get statsDescVariance => 'Variance';
  @override
  String get statsDescStddev => 'Écart-type';
  @override
  String get statsDescQ1 => 'Q1';
  @override
  String get statsDescQ3 => 'Q3';
  @override
  String get statsDescIqr => 'EIQ';
  @override
  String get helpGroupProbability => 'Probabilité';
  @override
  String get helpFnRrefDescription => 'Forme échelonnée réduite (Gauss-Jordan)';

  @override
  String get settingsTitle => 'Paramètres';
  @override
  String get settingsNumberFormat => 'Format des nombres';
  @override
  String get settingsNumberFormatAuto => 'Auto (129, 129,5)';
  @override
  String settingsNumberFormatDecimalPlaces(int n) => 'Décimales : $n';
  @override
  String get settingsAutoBindSolve => 'Liaison automatique des solutions';
  @override
  String get settingsAutoBindSolveSubtitle =>
      'Si activé, solve(éq, x) assigne aussi la solution à x.';
  @override
  String get settingsNumberFormatInteger => 'Entier (129)';
  @override
  String get settingsNumberFormatOneDecimal => 'Une décimale (129,0)';
  @override
  String get settingsNumberFormatTwoDecimal => 'Deux décimales (129,00)';
  @override
  String get settingsLanguage => 'Langue';
  @override
  String get settingsLanguageEnglish => 'English';
  @override
  String get settingsLanguageGerman => 'Deutsch';
  @override
  String get settingsLanguageFrench => 'Français';
  @override
  String get settingsLanguageSpanish => 'Español';
  @override
  String get settingsTheme => 'Apparence';
  @override
  String get settingsThemeSystem => 'Selon le système';
  @override
  String get settingsThemeLight => 'Clair';
  @override
  String get settingsThemeDark => 'Sombre';
  @override
  String get settingsLayoutTitle => 'Disposition';
  @override
  String get settingsLayoutBody =>
      'CrispMath s\'adapte à la largeur de la fenêtre : navigation '
      'inférieure sur smartphone, rail latéral sur tablette et bureau. '
      'À partir de ~760 px, le pavé affiche toutes les touches sans onglets.';

  @override
  String get aboutTitle => 'À propos de CrispMath';
  @override
  String get aboutTagline => 'Calculatrice symbolique CAS basée sur SymEngine';
  @override
  String aboutVersion(String version) => 'Version $version';
  @override
  String get aboutServiceProvider => 'Fournisseur';
  @override
  String get aboutContact => 'Contact';
  @override
  String get aboutPrivacy => 'Confidentialité';
  @override
  String get aboutPrivacyText =>
      'CrispMath fonctionne entièrement sur l\'appareil. Aucun calcul, '
      'entrée d\'historique ou variable utilisateur n\'est jamais transmis '
      'à un serveur. L\'application ne collecte aucune donnée d\'analyse '
      'et ne contacte aucun service distant.';
  @override
  String get aboutDisclaimer => 'Avertissement';
  @override
  String get aboutDisclaimerText =>
      'CrispMath est fourni « tel quel », sans aucune garantie. Le moteur '
      'symbolique peut renvoyer des résultats imprécis pour des entrées '
      'numériques mal conditionnées ou des expressions symboliques non '
      'prises en charge. Vérifiez de manière indépendante les calculs '
      'critiques.';
  @override
  String get aboutLicense => 'Licence';
  @override
  String get aboutLicenseText =>
      'CrispMath est un logiciel libre publié sous la GNU Affero General '
      'Public License version 3 ou ultérieure, avec une permission App '
      'Store. Les bibliothèques GMP/MPFR/MPC/FLINT incluses conservent '
      'leurs licences LGPL; les détails de source, build et relink sont '
      'dans Licences open source.';
  @override
  String get aboutOpenSourceLicenses => 'Licences open source';
  @override
  String get settingsAbout => 'À propos de CrispMath';
  @override
  String get matrixDiagnosticsTitle => 'Auto-test matriciel';
  @override
  String get matrixDiagnosticsSubtitle =>
      'Vérifier det / inv / transpose / + / * via le pont natif.';
  @override
  String matrixDiagnosticsSummary(int passed, int total) =>
      '$passed vérifications sur $total réussies';
  @override
  String get unitConverterTitle => 'Convertisseur d\'unités';
  @override
  String get unitConverterSubtitle =>
      'Longueur / temps / masse / température / vitesse / angle.';

  @override
  String get selectEquation =>
      'Sélectionnez une équation ou continuez à taper :';
  @override
  String get continueTyping => 'Continuer la saisie';
  @override
  String get selectFunction =>
      'Sélectionnez une fonction ou continuez à taper :';
  @override
  String get dismissPanel => 'Fermer ce panneau';
  @override
  String solveFor(int n) => 'Résoudre Y$n = 0';
  @override
  String whereY(int n, String func) => 'où Y$n = $func';

  @override
  String get dialogInsert => 'Insérer';
  @override
  String get dialogClose => 'Fermer';
  @override
  String get dialogShowSteps => 'Voir les étapes';
  @override
  String get dialogVariable => 'Variable';
  @override
  String get dialogExpression => 'Expression';
  @override
  String get dialogValue => 'Valeur';
  @override
  String get dialogFunction => 'Fonction f(x)';

  @override
  String get integralTitle => 'Intégrale';
  @override
  String get integralLowerBound => 'Borne inférieure';
  @override
  String get integralUpperBound => 'Borne supérieure';
  @override
  String get integralDefinite => 'Intégrale définie';
  @override
  String get nthRootTitle => 'Racine n-ième';
  @override
  String get nthRootBase => 'Base';
  @override
  String get limitTitle => 'Limite';
  @override
  String get limitApproaches => 'tend vers';
  @override
  String get substituteTitle => 'Substituer';
  @override
  String get substituteUseStoredVariable =>
      'Utiliser une variable stockée comme valeur :';

  @override
  String get differentiationStepsTitle => 'Étapes de dérivation';
  @override
  String differentiationStepsHeader(String variable) =>
      'Dérivation par rapport à $variable :';
  @override
  String get solveStepsTitle => 'Étapes de résolution';
  @override
  String get odeStepsTitle => 'Étapes de résolution de l\'EDO';
  @override
  String get solveStepsEquationLabel => 'Équation ou expression';
  @override
  String get solveStepsSolveFor => 'Résoudre pour';
  @override
  String get solveStepsHint => 'p. ex. 2x + 3 = 7  ou  x^2 - 5x + 6';
  @override
  String solveStepsHeader(String variable) => 'Résolution pour $variable :';
  @override
  String get integrationStepsTitle => 'Étapes d\'intégration';
  @override
  String get integrationStepsIntegrandLabel => 'Intégrande';
  @override
  String get integrationStepsWrt => 'Intégrer par rapport à';
  @override
  String get integrationStepsHint => 'p. ex. x^2  ou  sin(x) + 2x';
  @override
  String integrationStepsHeader(String variable) =>
      'Intégration par rapport à $variable :';

  @override
  String get errorSolveFormat =>
      'Erreur : le format de solve() est solve(équation, variable)';
  @override
  String get errorInvalidSolve => 'Erreur : syntaxe solve() invalide';
  @override
  String get errorInvalidDiff => 'Erreur : syntaxe d/dx() invalide';
  @override
  String get errorInvalidFactor => 'Erreur : syntaxe factor() invalide';
  @override
  String get errorInvalidExpand => 'Erreur : syntaxe expand() invalide';
  @override
  String get errorInvalidSimplify => 'Erreur : syntaxe simplify() invalide';
  @override
  String get errorGcdArgs => 'Erreur : gcd() requiert exactement 2 arguments';
  @override
  String get errorInvalidGcd => 'Erreur : syntaxe gcd() invalide';
  @override
  String get errorLcmArgs => 'Erreur : lcm() requiert exactement 2 arguments';
  @override
  String get errorInvalidLcm => 'Erreur : syntaxe lcm() invalide';

  @override
  String get errorMissingAns => 'Aucun Ans en mémoire.';
  @override
  String get errorParse =>
      'L\'expression n\'a pas pu être analysée. Vérifiez les parenthèses non appariées, les fautes de frappe ou les opérateurs manquants.';
  @override
  String get errorUnbalancedParen =>
      'Il y a une parenthèse fermante sans parenthèse ouvrante correspondante.';
  @override
  String get errorDivisionByZero => 'Division par zéro.';
  @override
  String errorUnknownFunction(String name) =>
      '\u0022$name\u0022 n\'est pas une fonction connue. Vérifiez l\'orthographe.';
  @override
  String errorWrongArity(String name) =>
      '\u0022$name\u0022 a reçu un nombre d\'arguments incorrect.';
  @override
  String get errorNativeRequired =>
      'Cette opération nécessite la bibliothèque mathématique native, non chargée sur cette plateforme.';
  @override
  String get errorNativeRequiredWeb =>
      'Le calcul formel (solve, factor, integrate, …) nécessite l\'application de bureau ou mobile — indisponible dans le navigateur.';
  @override
  String get webBannerCasLoading =>
      'Chargement du moteur symbolique dans le navigateur… solve, factor et integrate seront disponibles dès que ce sera prêt.';
  @override
  String get webBannerCasPartial =>
      'Le CAS symbolique complet — y compris les fonctions de haute précision et de théorie des nombres (isprime, factorint, evalf, Bessel) — fonctionne ici, dans votre navigateur. Seule la factorisation multivariée nécessite encore l\'application de bureau ou mobile.';
  @override
  String get webBannerCasUnavailable =>
      'Version navigateur : le CAS symbolique, la haute précision et la théorie des nombres nécessitent l\'application de bureau ou mobile. Les statistiques, matrices, Sudoku/CSP, unités et la calculatrice fonctionnent ici.';
  @override
  String get webDownloadApp => 'Obtenir l\'app';
  @override
  String get errorIntegrateNotImplemented =>
      'L\'intégration symbolique n\'est pas disponible dans cette version. Utilisez ∫ avec des bornes pour un résultat numérique (défini).';
  @override
  String get errorMatrixLiteral =>
      'Le littéral de matrice est mal formé. Utilisez le format [a,b; c,d] ou l\'éditeur de matrice.';
  @override
  String get errorInternalMatrixDisposed =>
      'Référence de matrice interne non valide. Veuillez relancer l\'opération.';
  @override
  String errorInvalidSyntax(String op) =>
      'Les arguments passés à $op() n\'avaient pas la forme attendue. Consultez l\'exemple dans l\'aide / À propos.';

  @override
  String get exportDataTitle => 'Exporter les données';
  @override
  String get exportDataSubtitle =>
      'Le JSON ci-dessous contient tout ce que CrispMath a stocké sur cet appareil — historique, variables, fonctions, paramètres, réglages. Copiez-le dans une note ou un document cloud avant de réinstaller.';
  @override
  String get exportDataCopy => 'Copier dans le presse-papiers';
  @override
  String get exportDataCopied => 'Copié dans le presse-papiers';
  @override
  String get historyEntryCopyResult => 'Copier le résultat';
  @override
  String get historyEntryCopyLatex => 'Copier en LaTeX';
  @override
  String get historyEntryCopyLatexSubtitle =>
      'Coller dans Word/Notion/Markdown pour des maths composées';
  @override
  String get historyEntryReuse => 'Réutiliser l\'expression';
  @override
  String get historyEntryCopied => 'Copié';

  // -- Round 91 --
  @override
  String get storeAsVariable => 'Enregistrer comme variable';
  @override
  String get storeAsFunction => 'Enregistrer comme fonction';
  @override
  String get storeVariableTitle => 'Enregistrer comme variable';
  @override
  String get storeFunctionTitle => 'Enregistrer comme fonction';
  @override
  String get storeNameLabel => 'Nom';
  @override
  String get storeFunctionParamLabel => 'Paramètre';
  @override
  String get storeButton => 'Enregistrer';
  @override
  String get storeNameReserved => 'Nom réservé par une fonction intégrée';
  @override
  String storeSavedAs(String name) => 'Enregistré comme $name';

  // -- R91b --
  @override
  String storeOverwriteTitle(String name) => 'Remplacer « $name » ?';
  @override
  String storeOverwriteCurrent(String existing) => 'Actuellement : $existing';
  @override
  String get storeOverwriteConfirm => 'Remplacer';

  @override
  String get settingsExportData => 'Exporter les données';
  @override
  String get settingsExportDataSubtitle =>
      'Copier tout ce qui est stocké sur cet appareil (historique, variables, réglages).';
  @override
  String get settingsHelp => 'Aide & référence des fonctions';
  @override
  String get settingsHelpSubtitle =>
      'Fonctions prises en charge, syntaxe matricielle et déclencheurs pas-à-pas.';

  @override
  String get settingsHighContrast => 'Contraste élevé';
  @override
  String get settingsHighContrastSubtitle =>
      'Couleurs et bordures plus fortes pour l\'accessibilité.';
  @override
  String get settingsTextScale => 'Taille du texte';

  @override
  String get settingsExactIntegerMode => 'Mode entier exact';
  @override
  String get settingsExactIntegerModeSubtitle =>
      'Afficher la chaîne complète de chiffres pour les résultats entiers '
      'en précision arbitraire (par ex. 100! = 158 chiffres). Désactivé : '
      'arrondi à la précision double.';
  @override
  String exactIntegerBadge(int digits) => 'Entier exact · $digits chiffres';
  @override
  String get exactIntegerTapToCopy => 'Toucher pour copier';

  @override
  String get calculating => 'Calcul en cours …';

  @override
  String get moduleSudokuTitle => 'Solveur de Sudoku';
  @override
  String get moduleSudokuSubtitle =>
      'Voir comment un solveur raisonne : singletons, hypothèses et retour arrière, pas à pas.';
  @override
  String get sudokuSolveButton => 'Résoudre';
  @override
  String get sudokuClearCell => 'Effacer';
  @override
  String get sudokuClearToStart => 'Réinitialiser';
  @override
  String get sudokuSolvedCorrectly => 'Résolu !';
  @override
  String get sudokuFilledWithErrors => 'Avec des erreurs';
  @override
  String get sudokuWinOverlayTapHint => 'Toucher pour fermer';
  @override
  String get sudokuPresetLabelChooser => 'Grille';
  @override
  String get sudokuPresetCustom => 'Personnalisée';
  @override
  String sudokuPresetLabel(String id) {
    switch (id) {
      case 'small4x4Easy':
        return '4×4 facile';
      case 'small4x4Medium':
        return '4×4 moyen';
      case 'small4x4Hard':
        return '4×4 difficile';
      case 'medium6x6':
        return '6×6 moyen';
      case 'eight8x8':
        return '8×8 moyen';
      case 'eight8x8X':
        return '8×8 Sudoku-X moyen';
      case 'eight8x8Disjoint':
        return '8×8 Disjoint moyen';
      case 'eight8x8Killer':
        return '8×8 Killer';
      case 'ten10x10':
        return '10×10 moyen';
      case 'twelve12x12':
        return '12×12 moyen';
      case 'fifteen15x15':
        return '15×15 moyen';
      case 'standard9x9Easy':
        return '9×9 facile';
      case 'standard9x9Medium':
        return '9×9 moyen';
      case 'standard9x9Hard':
        return '9×9 difficile (AI Escargot)';
      case 'standard9x9XEasy':
        return '9×9 Sudoku-X facile';
      case 'killer4x4':
        return '4×4 Killer';
      case 'killer9x9':
        return '9×9 Killer';
    }
    return id;
  }

  @override
  String get sudokuVisualizerHeader => 'Visualiseur de recherche';
  @override
  String get sudokuPlay => 'Lecture';
  @override
  String get sudokuPause => 'Pause';
  @override
  String get sudokuRestart => 'Redémarrer';
  @override
  String get sudokuSpeedSlow => 'Lent';
  @override
  String get sudokuSpeedMed => 'Moyen';
  @override
  String get sudokuSpeedFast => 'Rapide';
  @override
  String get sudokuGenerateButton => 'Générer';
  @override
  String get sudokuGenerateSection => 'Difficulté des nouveaux puzzles';
  @override
  String get sudokuDifficultyEasy => 'Facile';
  @override
  String get sudokuDifficultyMedium => 'Moyen';
  @override
  String get sudokuDifficultyHard => 'Difficile';
  @override
  String get sudokuVariantRegular => 'Classique';
  @override
  String get sudokuVariantX => 'Sudoku-X';
  @override
  String get sudokuVariantKiller => 'Killer';
  @override
  String get sudokuVariantDisjoint => 'Disjoint';
  @override
  String get sudokuCheckUnique => "Vérifier l'unicité";
  @override
  String get sudokuUniqueSolution => 'Solution unique';
  @override
  String get sudokuMultipleSolutions => 'Plusieurs solutions';
  @override
  String get sudokuShowHints => 'Afficher les indices';
  @override
  String get sudokuShowHintsSubtitle =>
      'Annotations au crayon : pour chaque case vide, les chiffres '
      'pas encore éliminés par la ligne, la colonne, le bloc ou la '
      'diagonale.';
  @override
  String get sudokuHintLevelOff => 'Désactivé';
  @override
  String get sudokuHintLevelBasic => 'Simple';
  @override
  String get sudokuHintLevelAdvanced => 'Avancé';
  @override
  String get sudokuHintLevelAdvancedHelp =>
      'Le mode avancé exécute le solveur CSP complet sur chaque '
      'candidat ; il détecte aussi les singletons cachés et les '
      'paires nues. Plus lent — quelques secondes sur les grilles '
      '9×9 difficiles.';
  @override
  String get sudokuHintLevelComputing => 'Calcul des indices avancés…';

  @override
  String sudokuConstraintRow(int row) => 'Ligne $row';
  @override
  String sudokuConstraintCol(int col) => 'Colonne $col';
  @override
  String sudokuConstraintBox(int box) => 'Bloc $box';
  @override
  String sudokuConstraintCage(int cage, int sum) => 'Cage $cage (somme $sum)';
  @override
  String get sudokuConstraintMainDiagonal => 'Diagonale principale';
  @override
  String get sudokuConstraintAntiDiagonal => 'Anti-diagonale';
  @override
  String sudokuConstraintDisjointGroup(int group) => 'Groupe disjoint $group';
  @override
  String sudokuStepStart(int clues) =>
      'Départ : $clues indices. Les annotations montrent les chiffres '
      'encore possibles dans chaque case vide : un chiffre est exclu dès '
      'qu\'une case de la même ligne, colonne ou région le contient.';
  @override
  String sudokuStepNakedSingle(String cell, int value, int eliminated) =>
      'Singleton nu : $cell n\'a plus qu\'un candidat, donc $value. '
      '$value disparaît de $eliminated cases voisines.';
  @override
  String sudokuStepHiddenSingle(String unit, int value, String cell) =>
      'Singleton caché : dans $unit, $value ne peut aller qu\'en $cell, '
      'même si $cell a d\'autres candidats.';
  @override
  String sudokuStepGuess(String cell, int value, String alternatives) =>
      'Plus aucune déduction : le solveur fait une hypothèse. '
      'Il choisit $cell, '
      'qui a le moins de candidats, essaie $value et garde $alternatives '
      'pour le retour arrière.';
  @override
  String sudokuStepLastOption(String cell, int value) =>
      'Dernière option : tous les autres choix pour $cell ont échoué, '
      'donc $value (selon les hypothèses précédentes).';
  @override
  String sudokuStepContradictionCell(String cell) =>
      'Contradiction : $cell n\'a plus de candidat.';
  @override
  String sudokuStepContradictionUnit(String unit, int value) =>
      'Contradiction : $value n\'a plus de place dans $unit.';
  @override
  String sudokuStepBacktrack(String cell) =>
      'Retour arrière : annuler tout depuis l\'hypothèse en $cell et '
      'essayer son option suivante.';
  @override
  String get sudokuStepSolved =>
      'Résolu : chaque case est remplie et chaque règle respectée.';
  @override
  String sudokuExplainStats(
          int naked, int hidden, int guesses, int backtracks, int depth) =>
      [
        if (naked > 0) 'Singletons nus $naked',
        if (hidden > 0) 'Singletons cachés $hidden',
        if (guesses > 0) 'Hypothèses $guesses',
        if (backtracks > 0) 'Retours arrière $backtracks',
        if (depth > 0) 'Profondeur max $depth',
      ].join(' · ');
  @override
  String get sudokuExplainLogicOnly =>
      'Résolu par la logique seule : aucune hypothèse nécessaire.';
  @override
  String sudokuExplainTruncated(int shown) =>
      'Affichage des $shown premières étapes ; la résolution a continué.';
  @override
  String sudokuStepCage(int sum, int size, String combos, int removed) =>
      'Somme de cage : $size cases doivent totaliser $sum avec des chiffres '
      'différents. Les ensembles possibles sont $combos. Leurs affectations '
      'aux cases qui respectent les contraintes montrent que $removed '
      'candidats ne peuvent pas être utilisés dans leurs cases respectives ; '
      'ils sont retirés.';
  @override
  String sudokuStepLocked(int digit, String unit, String other, int removed) =>
      'Candidats verrouillés : dans $unit, $digit ne peut aller que dans '
      'des cases qui appartiennent aussi à $other. Où qu\'il aille, $other '
      'y reçoit son $digit, donc $digit est retiré de $removed autres cases '
      'de $other.';
  @override
  String sudokuStepNakedSubset(
          int size, String cells, String digits, String unit, int removed) =>
      '${size == 2 ? 'Paire' : 'Triplet'} nu : $cells dans $unit ne '
      'contiennent que $digits, ces chiffres vont donc dans ces $size cases '
      'et sont retirés du reste de $unit ($removed candidats).';
  @override
  String sudokuStepHiddenSubset(
          int size, String digits, String unit, String cells, int removed) =>
      '${size == 2 ? 'Paire' : 'Triplet'} caché : dans $unit, $digits ne '
      'tiennent que dans $cells, ces cases les prennent donc et perdent '
      'leurs autres candidats ($removed retirés).';
  @override
  String sudokuStepContradictionCage(int sum) =>
      'Contradiction : la cage de $sum ne peut plus atteindre sa somme.';
  @override
  String sudokuExplainEliminations(
          int cages, int locked, int nakedSubsets, int hiddenSubsets) =>
      [
        if (cages > 0) 'Sommes de cage $cages',
        if (locked > 0) 'Candidats verrouillés $locked',
        if (nakedSubsets > 0) 'Paires/triplets nus $nakedSubsets',
        if (hiddenSubsets > 0) 'Paires/triplets cachés $hiddenSubsets',
      ].join(' · ');
  @override
  String get sudokuSearchTreeTitle => 'Arbre de recherche';
  @override
  String get sudokuSearchTreeHint =>
      'Chaque point est une hypothèse, ses enfants sont les hypothèses '
      'suivantes. Les points rouges ont mené à une contradiction, les verts '
      'forment le chemin vers la solution. Le point cerclé est l\'hypothèse '
      'en vigueur à l\'étape courante.';
  @override
  String sudokuSearchTreeTruncated(int shown) =>
      'Affichage des $shown premières hypothèses.';
  @override
  String get sudokuStepPrevious => 'Étape précédente';
  @override
  String get sudokuStepNext => 'Étape suivante';
  @override
  String get sudokuEnterClues =>
      'Saisir des indices : touchez une case puis un chiffre pour '
      'analyser votre propre grille.';
  @override
  String get sudokuConstraintStartingPosition => 'Position de départ';
  @override
  String sudokuError(SudokuError error) => switch (error.kind) {
        SudokuErrorKind.unsupported => 'Sudoku non pris en charge.',
        SudokuErrorKind.clashingClues =>
          'Les indices enfreignent déjà une règle.',
        SudokuErrorKind.noSolution => 'Ce Sudoku n’a pas de solution.',
        SudokuErrorKind.placementLimit =>
          'Recherche arrêtée après ${error.limit} placements.',
        SudokuErrorKind.cageWorkLimit =>
          'Recherche arrêtée à la limite de travail des cages '
              '(${error.limit}).',
      };

  @override
  String get moduleConstraintsTitle => 'Problèmes de contraintes';
  @override
  String get moduleConstraintsSubtitle =>
      'Équations diophantiennes et cryptarithmes — trouver des '
      'solutions entières et des attributions de chiffres.';
  @override
  String get constraintsTabDiophantine => 'Diophantien';
  @override
  String get constraintsTabCryptarithm => 'Cryptarithme';
  @override
  String get constraintsTabDsl => 'Texte libre';
  @override
  String get constraintsTabFlatZinc => 'FlatZinc';
  @override
  String get constraintsTabMagicSquare => 'Carré magique';
  @override
  String get constraintsMagicIntro =>
      'Génère un carré magique de l\'ordre choisi : les nombres 1..N² '
      'disposés de sorte que chaque ligne, chaque colonne et les deux '
      'diagonales aient la même somme. Chaque « Générer » montre une '
      'orientation différente d\'une solution.';
  @override
  String get constraintsMagicSize => 'Taille';
  @override
  String constraintsMagicConstant(int m) => 'Constante magique : $m';
  @override
  String constraintsSoftScore(int satisfied, int total) =>
      'Satisfaction : $satisfied / $total';
  @override
  String get constraintsMagicGenerate => 'Générer';
  @override
  String get constraintsMagicHint =>
      'Chaque ligne, colonne et diagonale somme à la constante magique.';
  @override
  String get constraintsDslIntro =>
      'Déclarer des variables avec `vars: x, y in 1..9`, '
      'utiliser `allDifferent(x, y, z)` pour la distinction, '
      "et écrire toute autre ligne comme contrainte "
      '(p. ex. `x + 2*y == 10`).';
  @override
  String get constraintsDslInputLabel => 'Programme de contraintes';
  @override
  String get constraintsDslExamplesButton => 'Exemples';
  @override
  String get constraintsDslExamplesTooltip =>
      'Charger un exemple pré-construit';
  @override
  String constraintsDslExampleTitle(String id) {
    switch (id) {
      case 'magicSum':
        return 'Somme magique à 3 chiffres';
      case 'magicSquare3':
        return 'Carré magique 3×3';
      case 'magicSquare4':
        return 'Carré magique 4×4 (constante 34)';
      case 'mapColoring':
        return 'Coloration de carte (K4)';
      case 'mapColoringAustralia':
        return 'Coloration de carte — Australie (3 couleurs)';
      case 'mapColoringGermany':
        return 'Coloration de carte — Allemagne (4 couleurs requises)';
      case 'orderedTriples':
        return 'Triplets ordonnés sommant à 20';
      case 'equalSumSplit':
        return 'Partition en sommes égales';
      case 'coinChangeMin':
        return 'Rendu de monnaie (minimiser les pièces)';
      case 'knapsack':
        return 'Sac à dos 0/1 (maximiser la valeur)';
      case 'productionPlanning':
        return 'Planification de production (maximiser le profit)';
      case 'assignmentMinCost':
        return 'Problème d\'affectation (minimiser le coût)';
      case 'transportation':
        return 'Problème de transport (coût minimal)';
      case 'schedulingMakespan':
        return 'Ordonnancement — minimiser le makespan';
      case 'cumulativeScheduling':
        return 'Ordonnancement cumulatif — capacité 2';
      case 'rcpsp':
        return 'RCPSP — équipe + équipement';
      case 'logicGrid':
        return 'Grille de logique — déduction';
      case 'nurseRostering':
        return 'Planning d\'infirmières (motifs de gardes)';
      case 'chromaticNumber':
        return 'Nombre chromatique (moins de couleurs)';
      case 'menuPairing':
        return 'Combinaisons de menu (table)';
      case 'packing':
        return 'Placement 2D (disposition diffN)';
      case 'deliveryRoute':
        return 'Tournée de livraison (circuit / TSP)';
      case 'shiftPrefs':
        return 'Préférences d\'horaire (soft / MaxCSP)';
      case 'committee':
        return 'Sélection de comité (variables ensemblistes)';
    }
    return id;
  }

  @override
  String get constraintsFlatZincIntro =>
      'Coller un modèle FlatZinc (typiquement produit par mzn2fzn à '
      "partir d'une source MiniZinc). Le solveur renvoie la sortie "
      'FlatZinc standard : lignes `nom = valeur;` par annotation '
      '`:: output_var`, terminées par `----------`, suivies de '
      '`==========` après la dernière solution.';
  @override
  String get constraintsFlatZincInputLabel => 'Code source FlatZinc';
  @override
  String get constraintsFlatZincAllSolutions => 'Toutes les solutions';
  @override
  String get constraintsFlatZincFirstSolution => 'Première solution';
  @override
  String get constraintsFlatZincExhaustiveOne => '1 solution (exhaustif)';
  @override
  String constraintsFlatZincExhaustiveN(int n) => '$n solutions (exhaustif)';
  @override
  String get constraintsFlatZincUnsatisfiable => 'Insatisfiable';
  @override
  String constraintsFlatZincExampleTitle(String id) {
    switch (id) {
      case 'nqueens4':
        return '4 reines';
      case 'binPacking':
        return 'Bin-packing (3 objets, 2 boîtes)';
    }
    return id;
  }

  @override
  String get constraintsExplainFailure => "Expliquer l'échec";
  @override
  String get constraintsExplainHeader => 'Conflit minimal (QuickXplain)';
  @override
  String get constraintsExplainSatisfiable =>
      'Aucun conflit — le modèle est en fait satisfaisable.';
  @override
  String constraintsExplainEntryCount(int n) =>
      n == 1 ? '1 contrainte conflictuelle' : '$n contraintes conflictuelles';
  @override
  String constraintsExplainAltHeader(int n) =>
      'Un autre conflit minimal ($n contraintes)';
  @override
  String get constraintsExportFlatZinc => 'Exporter en FlatZinc';
  @override
  String get constraintsVisualizeButton => 'Visualiser';
  @override
  String get constraintsCompareStrategies => 'Comparer les stratégies';
  @override
  String get constraintsStrategyHeader =>
      'Comparaison des stratégies de recherche';
  @override
  String get constraintsStrategyCol => 'Stratégie';
  @override
  String get constraintsStrategyDecisions => 'Décisions';
  @override
  String get constraintsStrategyBacktracks => 'Retours arrière';
  @override
  String get constraintsStrategyPropagations => 'Propagations';
  @override
  String get constraintsStrategyIterations => 'Itérations';
  @override
  String get constraintsStrategyTime => 'Temps';
  @override
  String get constraintsStructureButton => 'Afficher la structure';
  @override
  String constraintsStructureHeader(int vars, int constraints) =>
      'Réseau de contraintes · $vars variables · $constraints contraintes';
  @override
  String constraintsColorGraphHeader(int nodes, int colours) =>
      'Coloration de graphe · $nodes nœuds · $colours couleurs';
  @override
  String get constraintsTraceHeader => 'Trace de propagation';
  @override
  String get constraintsTraceIntro =>
      'Parcourez le solveur pas à pas : chaque décision, chaque valeur '
      'retirée d’un domaine par une contrainte, chaque impasse et chaque '
      'retour arrière.';
  @override
  String constraintsTraceStepCounter(int current, int total) =>
      'Étape $current / $total';
  @override
  String get constraintsTraceInitial =>
      'Domaines initiaux — avant toute recherche.';
  @override
  String constraintsTraceDecision(String variable, int value) =>
      'Décision : essayer $variable = $value';
  @override
  String constraintsTracePrune(String values, String variable, String cause) =>
      'Retirer $values de $variable — $cause';
  @override
  String constraintsTraceWipeout(String variable, String cause) =>
      'Impasse : domaine de $variable vidé — $cause';
  @override
  String get constraintsTraceBacktrack =>
      'Retour arrière — annuler la dernière décision et essayer une autre '
      'valeur.';
  @override
  String constraintsTraceBackjump(int from, int to) =>
      'Saut arrière de la profondeur $from à la profondeur $to.';
  @override
  String get constraintsTraceSolutionStep =>
      'Solution — toutes les variables affectées.';
  @override
  String constraintsTraceStats(
          int decisions, int prunes, int wipeouts, int backtracks) =>
      'Décisions $decisions · Élagages $prunes · Impasses $wipeouts · '
      'Retours arrière $backtracks';
  @override
  String get constraintsTracePropagationOnly =>
      'Résolu par propagation seule : aucune décision nécessaire.';
  @override
  String get constraintsTraceTopConstraints =>
      'Contraintes qui ont retiré le plus de valeurs :';
  @override
  String constraintsTraceConstraintWork(
          int removed, int prunes, int wipeouts) =>
      '$removed valeurs · $prunes élagages · $wipeouts impasses';
  @override
  String get constraintsMagicVisualizeHint =>
      'Visualiser rejoue la construction d\'un carré par le solveur : la '
      'case qu\'il fixe, ce que les sommes et la règle tous-différents '
      'élaguent, et où il revient en arrière. Disponible pour 3×3 et 4×4.';
  @override
  String get constraintsTraceSolved => 'Résolu';
  @override
  String get constraintsTraceUnsat =>
      'Aucune solution — espace de recherche épuisé';
  @override
  String constraintsTraceTruncatedNote(int n) =>
      'Trace limitée à $n étapes — la relecture n’est qu’un préfixe partiel.';
  @override
  String get constraintsTraceObjectiveNote =>
      'Affichage de la recherche de faisabilité ; l’objectif est ignoré.';
  @override
  String get constraintsTracePlay => 'Lire';
  @override
  String get constraintsTracePause => 'Pause';
  @override
  String get constraintsTraceRestart => 'Redémarrer';
  @override
  String get constraintsTraceStepBack => 'Étape précédente';
  @override
  String get constraintsTraceStepForward => 'Étape suivante';
  @override
  String get constraintsExportedHeader => 'Traduction FlatZinc';

  @override
  String get constraintsDiophantineIntro =>
      'Déclare des variables entières bornées, liste les contraintes '
      'à satisfaire — le solveur énumère toutes les solutions '
      'entières (plafonnées à 100).';
  @override
  String get constraintsCryptarithmIntro =>
      'Entre une énigme de la forme `MOT1 + MOT2 = MOT3` (ou `−` au '
      'lieu de `+`). Chaque lettre est un chiffre 0..9 ; les chiffres '
      'de tête sont non nuls ; toutes les lettres portent des chiffres '
      'distincts.';
  @override
  String get constraintsVariablesLabel => 'Variables';
  @override
  String get constraintsVariablesHint =>
      'Une par ligne, format : name in min..max';
  @override
  String get constraintsConstraintsLabel => 'Contraintes';
  @override
  String get constraintsConstraintsHint =>
      'Une par ligne. Comparaisons, arithmétique, in/not-in ensembles '
      'tous pris en charge.';
  @override
  String get constraintsCryptarithmInputLabel => 'Énigme';
  @override
  String get constraintsSolveButton => 'Résoudre';
  @override
  String get constraintsCancelButton => 'Annuler';
  @override
  String get constraintsBadVarLine =>
      'Ligne de variable non reconnue. Attendu : `name in min..max`';
  @override
  String get constraintsNoSolutions => 'Aucune solution.';
  @override
  String get constraintsCryptarithmFoundHeader => 'Attribution des chiffres';
  @override
  String constraintsSolutionsHeader(int n) =>
      n == 1 ? '1 solution' : '$n solutions';
  @override
  String constraintsTruncatedHeader(int n) =>
      'Affichage des $n premières solutions (d\'autres existent)';
  @override
  String get constraintsCopyResult => 'Copier les solutions';
  @override
  String get constraintsCopiedToast => 'Copié dans le presse-papiers.';
  @override
  String constraintsOptimalHeader(num objective) =>
      'Optimal : objectif = $objective';

  @override
  String get clearSearchTooltip => 'Effacer la recherche';
  @override
  String get clearFunctionSlotTooltip => 'Effacer l\'emplacement de fonction';
  @override
  String get deleteMemorySlotTooltip => 'Supprimer l\'emplacement mémoire';

  @override
  String get helpModeEnableTooltip =>
      'Mode aide : touchez n\'importe quel contrôle pour une explication';
  @override
  String get helpModeDisableTooltip => 'Quitter le mode aide';
  @override
  String get keypadHelpLearnMore => 'En savoir plus';
  @override
  String get historyHelpTitle => 'Comment ceci a été calculé';
  @override
  String historyHelpComputedVia(String engine) => 'Calculé via $engine';
  @override
  String get historyHelpDirectEvaluation =>
      'Évaluation numérique directe — aucun appel symbolique.';
  @override
  String get historyHelpShowSteps => 'Afficher les étapes';

  @override
  String get moduleHelpTooltip => 'Que fait ce module ?';
  @override
  String moduleHelpTitle(ModuleHelpKind kind) {
    switch (kind) {
      case ModuleHelpKind.curveSketching:
        return 'Étude de courbe';
      case ModuleHelpKind.planes:
        return 'Analyse de plans';
      case ModuleHelpKind.conicSections:
        return 'Coniques';
      case ModuleHelpKind.statistics:
        return 'Statistiques';
      case ModuleHelpKind.graphing3D:
        return 'Graphique 3D';
      case ModuleHelpKind.scene3D:
        return 'Scène 3D';
      case ModuleHelpKind.constraints:
        return 'Contraintes';
      case ModuleHelpKind.sudoku:
        return 'Sudoku';
      case ModuleHelpKind.notepad:
        return 'Bloc-notes';
    }
  }

  @override
  String moduleHelpDescription(ModuleHelpKind kind) {
    switch (kind) {
      case ModuleHelpKind.curveSketching:
        return 'Étude complète d\'une fonction à une variable f(x) : '
            'domaine, intersections, dérivée et points critiques, '
            'extrema, points d\'inflexion, asymptotes, et un croquis. '
            'Entrez la fonction dans la zone de saisie ; les résultats '
            'apparaissent au tap.';
      case ModuleHelpKind.planes:
        return 'Analyse de plans 3D donnés sous forme cartésienne '
            '(ax + by + cz = d) ou paramétrique (point + deux vecteurs '
            'directeurs). Calcule le vecteur normal, les intersections '
            'avec les axes de coordonnées et les relations entre plans.';
      case ModuleHelpKind.conicSections:
        return 'Classifie une conique générale '
            'Ax² + Bxy + Cy² + Dx + Ey + F = 0 comme ellipse, '
            'hyperbole, parabole ou dégénérée, et extrait centre, axes, '
            'foyers et excentricité. Utilise le discriminant '
            'B² − 4AC pour la classification.';
      case ModuleHelpKind.statistics:
        return 'Statistiques descriptives (moyenne, médiane, variance, '
            '…), régression linéaire avec R² et résidus, lois normale '
            'et binomiale avec PDF / CDF / quantiles, et tests '
            'd\'hypothèses : t de Welch, t apparié, ANOVA à un facteur, '
            'chi-deux d\'ajustement et d\'indépendance, test exact de '
            'Fisher, test des rangs signés de Wilcoxon et test des '
            'signes. Les tests fournissent la statistique, la valeur '
            'p, et (si applicable) un intervalle de confiance au seuil α '
            'choisi.';
      case ModuleHelpKind.graphing3D:
        return 'Trace z = f(x, y) sous forme de surface filaire '
            'rotative. Faites glisser pour faire pivoter ; pincez / '
            'défilez pour zoomer. L\'action de rééchantillonnage '
            'reconstruit le maillage au niveau de zoom courant pour '
            'que le détail suive la distance de la caméra.';
      case ModuleHelpKind.scene3D:
        return 'Rendu de plusieurs objets 3D ensemble — plans, '
            'droites, sphères et quadriques — dans une scène partagée. '
            'Utile pour visualiser les intersections (par exemple deux '
            'plans se rencontrant le long d\'une droite) et construire '
            'des arguments géométriques étape par étape.';
      case ModuleHelpKind.constraints:
        return 'Résout des problèmes combinatoires : équations '
            'diophantiennes (solutions entières de ax + by = c), '
            'cryptarithmes (style SEND + MORE = MONEY), un petit '
            'DSL de programmation par contraintes à domaines finis '
            '(`allDifferent`, `noOverlap`, `cumulative`, `minimize` / '
            '`maximize`), et un onglet FlatZinc pour les problèmes '
            'écrits au format intermédiaire MiniZinc.';
      case ModuleHelpKind.sudoku:
        return 'Résout les grilles 4×4 et 9×9, y compris les variantes '
            'X (diagonales), Killer (sommes de cages) et Disjoint-'
            'Groups. Le solveur pas à pas montre l\'arbre de recherche '
            'pour observer comment le moteur restreint les candidats. '
            'Les niveaux d\'indice révèlent soit la réponse de la '
            'cellule suivante, soit une justification logique.';
      case ModuleHelpKind.notepad:
        return 'Un bloc-notes multi-documents où chaque ligne est une formule vivante, recalculée à la frappe. Au-delà des maths ordinaires, il gère des directives : `use <document>` importe les variables d\'un autre document ; `fzn:` résout un modèle FlatZinc en ligne ; et `Ans in <unité>` réutilise le résultat de la ligne précédente, avec conversion d\'unités optionnelle. Export en LaTeX ou Markdown.';
    }
  }

  @override
  String get workedExamplesTitle => 'Exemples résolus';
  @override
  String get workedExamplesSearchHint => 'Rechercher des exemples…';
  @override
  String get workedExamplesEmpty => 'Aucun exemple ne correspond au filtre.';
  @override
  String get workedExamplesCopy => 'Copier l\'expression';
  @override
  String get workedExamplesCopied =>
      'Copié dans le presse-papiers. Colle dans la calculatrice pour '
      'l\'essayer.';
  @override
  String get workedExamplesInsert => 'Insérer dans la calculatrice';
  @override
  String get workedExamplesCatAll => 'Tous';
  @override
  String get workedExamplesCatCalculus => 'Analyse';
  @override
  String get workedExamplesCatAlgebra => 'Algèbre';
  @override
  String get workedExamplesCatLinearAlgebra => 'Algèbre linéaire';
  @override
  String get workedExamplesCatNumberTheory => 'Théorie des nombres';
  @override
  String get workedExamplesCatStatistics => 'Statistiques';
  @override
  String get workedExamplesCatUnits => 'Unités';
  @override
  String get workedExamplesCatConstraints => 'Contraintes';
  @override
  String? workedExampleTitle(String id) {
    switch (id) {
      case 'dsolveSecondOrder':
        return 'EDO linéaire du second ordre';
      case 'dsolveSeparable':
        return 'EDO séparable du premier ordre';
      case 'taylorSine':
        return 'Série de Taylor du sinus';
      case 'rationalLogIntegral':
        return 'Intégrale logarithmique (Rothstein–Trager)';
      case 'quadraticInequality':
        return 'Inéquation du second degré';
      case 'piecewiseSelect':
        return 'Sélection par morceaux';
      case 'linsolveSystem':
        return 'Résoudre un système linéaire';
      case 'killerSudoku':
        return 'Killer Sudoku (9×9)';
      case 'constraintEditor':
        return 'Éditeur de contraintes libres';
      case 'dslMagicSquare':
        return 'Carré magique 3×3 (DSL)';
      case 'dslMapColoring':
        return 'Coloration de carte K4 (DSL)';
      case 'dslOrderedTriples':
        return 'Triplets ordonnés sommant à 20 (DSL)';
      case 'dslMapColoringAustralia':
        return 'Coloration de carte — Australie, 3 couleurs (DSL)';
      case 'dslMapColoringGermany':
        return 'Coloration de carte — Allemagne, 4 couleurs requises (DSL)';
      case 'dslKnapsack':
        return 'Sac à dos 0/1 — maximiser la valeur (DSL)';
      case 'dslTransportation':
        return 'Problème de transport — coût minimal (DSL)';
      case 'dslCoinChange':
        return 'Rendu de monnaie — minimiser les pièces (DSL)';
      case 'dslSchedulingMakespan':
        return 'Ordonnancement mono-machine — minimiser le makespan (DSL)';
      case 'dslCumulativeScheduling':
        return 'Ordonnancement parallèle — cumulative (DSL)';
      case 'dslRcpsp':
        return 'Ordonnancement de projet RCPSP — deux ressources (DSL)';
      case 'cryptSendMoreMoney':
        return 'Cryptarithme — SEND + MORE = MONEY';
      case 'derivPoly':
        return 'Dérivée d\'un polynôme';
      case 'chainRule':
        return 'Exemple de règle de la chaîne';
      case 'integralByParts':
        return 'Intégrale indéfinie par parties';
      case 'definiteIntegral':
        return 'Intégrale définie';
      case 'sinxOverX':
        return 'Limite en une singularité supprimable';
      case 'partialFractions':
        return 'Décomposition en éléments simples';
      case 'quadraticFormula':
        return 'Formule quadratique';
      case 'factorCubic':
        return 'Factoriser un polynôme';
      case 'expandBinomial':
        return 'Développer un binôme';
      case 'simplifyRational':
        return 'Simplifier une expression rationnelle';
      case 'polyGcdShared':
        return 'PGCD de polynômes';
      case 'polyDiscriminantCubic':
        return 'Discriminant d\'un polynôme';
      case 'polyFactorMod':
        return 'Factorisation modulo p';
      case 'matrixDet':
        return 'Déterminant d\'une matrice';
      case 'matrixInverse':
        return 'Inverse d\'une matrice';
      case 'rref':
        return 'Forme échelonnée réduite';
      case 'factorial100':
        return 'Factorielle — entier exact';
      case 'fibonacci50':
        return 'Nombre de Fibonacci';
      case 'gcdEuclid':
        return 'PGCD par Euclide';
      case 'isprime':
        return 'Test de primalité (petit n)';
      case 'piPrecision':
        return 'π à 100 chiffres';
      case 'ePrecision':
        return 'e à 50 chiffres';
      case 'factorint360':
        return 'Factorisation en facteurs premiers';
      case 'nextprime1000':
        return 'Premier suivant après 1000';
      case 'mersenneM31':
        return 'Premier de Mersenne M31';
      case 'divisors12':
        return 'Tous les diviseurs';
      case 'eulerTotient':
        return "Indicatrice d'Euler";
      case 'modpowCrypto':
        return 'Exponentiation modulaire';
      case 'contFracPi':
        return 'Fraction continue de π';
      case 'zetaBasel':
        return 'Zêta de Riemann — le problème de Bâle';
      case 'gammaHalf':
        return 'Gamma en un demi-entier';
      case 'evalfLn10':
        return 'evalf de précision arbitraire';
      case 'besselJZero':
        return 'Fonction de Bessel';
      case 'cevalfPow':
        return 'Haute précision complexe';
      case 'booleanIsprimeAnd':
        return 'Premier et borné';
      case 'booleanEqualityFold':
        return 'Évaluation d\'égalité';
      case 'booleanNotPrime':
        return 'Négation';
      case 'booleanOrChain':
        return 'Disjonction sur des comparaisons';
      case 'booleanIfFold':
        return 'Évaluation conditionnelle';
      case 'compoundInterest':
        return 'Intérêts composés';
      case 'zScore':
        return 'Lecture d\'un score Z';
      case 'statsHypothesisTests':
        return 'Espace tests d\'hypothèse';
      case 'statsWelchTwoSample':
        return 't à deux échantillons de Welch (prérempli)';
      case 'statsAnovaThreeGroups':
        return 'ANOVA à un facteur (préremplie)';
      case 'statsChiSquareGof':
        return 'Khi-deux d\'ajustement (prérempli)';
      case 'unitConversion':
        return 'Conversion d\'unités en ligne';
      case 'compositeDim':
        return 'Arithmétique à dimensions composées';
    }
    return additionalWorkedExampleTitle('fr', id);
  }

  @override
  String? workedExampleDescription(String id) {
    switch (id) {
      case 'dsolveSecondOrder':
        return 'y\'\' + 3y\' + 2y = 0 via les racines caractéristiques −1, −2.';
      case 'dsolveSeparable':
        return 'y\' = x·y se sépare en ∫dy/y = ∫x dx → C·e^(x²/2).';
      case 'taylorSine':
        return 'sin(x) autour de 0 à 7 termes — puissances impaires, (−1)^k/(2k+1)!.';
      case 'rationalLogIntegral':
        return '∫ (3x² + 1)/(x³ + x + 1) dx = log(x³ + x + 1) — le numérateur est la dérivée du dénominateur.';
      case 'quadraticInequality':
        return 'résoudre x² − 4 > 0 → x < −2 ∨ x > 2 (analyse de signe entre les racines).';
      case 'piecewiseSelect':
        return 'piecewise(cond, val, …) choisit la première branche vraie — base des fonctions définies par morceaux.';
      case 'linsolveSystem':
        return 'x + y = 3, x − y = 1 → x = 2, y = 1 (linsolve symbolique exact).';
      case 'killerSudoku':
        return 'Ouvre le module Sudoku préchargé avec la grille 9×9 Killer.';
      case 'constraintEditor':
        return 'Ouvre le module Contraintes — déclarer des variables, ajouter des contraintes, résoudre.';
      case 'dslMagicSquare':
        return 'Charge le programme à 9 variables du carré magique dans l\'éditeur DSL.';
      case 'dslMapColoring':
        return 'Charge une coloration K4 à 3 couleurs — volontairement infaisable pour montrer le chemin « aucune solution ».';
      case 'dslOrderedTriples':
        return 'Charge un programme DSL énumérant (a, b, c) avec a < b < c et a + b + c = 20.';
      case 'dslMapColoringAustralia':
        return 'Charge la carte de l\'Australie à 7 régions (Russell & Norvig). Trois couleurs suffisent ; la solution s\'affiche en carte colorée.';
      case 'dslMapColoringGermany':
        return 'Charge les 16 Länder allemands. Contrairement à l\'Australie, cette carte exige quatre couleurs (une roue à 5 autour de la Thuringe) — passez le domaine à 1..3 pour la rendre insatisfiable.';
      case 'dslKnapsack':
        return 'Charge un sac à dos 0/1 à quatre objets borné en poids ; `maximize` renvoie le sous-ensemble de valeur optimale.';
      case 'dslTransportation':
        return 'Charge un problème de transport équilibré (2 entrepôts → 3 clients, offre = demande) ; `minimize` renvoie le plan d\'expédition de coût minimal.';
      case 'dslCoinChange':
        return 'Charge un programme DSL qui paie 17 ¢ avec le moins de pièces de {1, 5, 10, 25} via `minimize`.';
      case 'dslSchedulingMakespan':
        return 'Charge un programme DSL qui ordonnance trois tâches (durées 4/3/2) sur une machine via `noOverlap` et minimise le makespan.';
      case 'dslCumulativeScheduling':
        return 'Charge un programme DSL qui ordonnance trois tâches sur une ressource de capacité 2 via `cumulative` et minimise le makespan.';
      case 'dslRcpsp':
        return 'Charge un programme DSL avec deux contraintes `cumulative` parallèles (équipe + équipement, capacité 3 chacune) sur quatre tâches ; minimise le makespan.';
      case 'cryptSendMoreMoney':
        return 'Ouvre l\'onglet Cryptarithme avec le puzzle classique : chaque lettre est un chiffre distinct 0–9 (pas de zéro en tête). Solution unique 9567 + 1085 = 10652.';
      case 'derivPoly':
        return 'd/dx de x³ − 4x + 7 en tout x.';
      case 'chainRule':
        return 'd/dx de sin(x²) — règle de la chaîne sur le x² intérieur.';
      case 'integralByParts':
        return '∫ x·sin(x) dx — pose u = x, dv = sin(x) dx.';
      case 'definiteIntegral':
        return '∫₀¹ x² dx = 1/3 par le théorème fondamental.';
      case 'sinxOverX':
        return 'lim x→0 sin(x)/x = 1 (le classique).';
      case 'partialFractions':
        return '∫ 1/(x² − 1) dx par la méthode du masque en x = ±1.';
      case 'quadraticFormula':
        return 'Résoudre 2x² + 5x − 3 = 0 via le discriminant.';
      case 'factorCubic':
        return 'Factoriser x³ − 8 — somme/différence de cubes.';
      case 'expandBinomial':
        return 'Développer (x + 2)⁵ — triangle de Pascal.';
      case 'simplifyRational':
        return 'Réduire (x² − 4)/(x − 2) à sa forme la plus simple.';
      case 'polyGcdShared':
        return 'polygcd(x² − 1, x² − 2x + 1) — le facteur commun x − 1.';
      case 'polyDiscriminantCubic':
        return 'polydiscriminant(x³ − 2) — non nul ⇒ racines distinctes.';
      case 'polyFactorMod':
        return 'polyfactor(x⁴ + 1, mod=2) — irréductible sur ℚ, '
            '(x + 1)⁴ sur 𝔽₂.';
      case 'matrixDet':
        return 'det d\'une 3×3 — développement de Laplace ou réduction.';
      case 'matrixInverse':
        return 'Inverse d\'une 2×2 — A⁻¹ = adj(A)/det(A).';
      case 'rref':
        return 'rref d\'un système 2×3 augmenté.';
      case 'factorial100':
        return '100! — 158 chiffres, conservés en mode entier exact.';
      case 'fibonacci50':
        return 'fib(50) — récurrence jusqu\'à un grand terme.';
      case 'gcdEuclid':
        return 'gcd(252, 105) — la récurrence d\'origine.';
      case 'isprime':
        return 'isprime(2027) — division d\'essai rapide.';
      case 'piPrecision':
        return 'pi(100) — constante haute précision via MPFR.';
      case 'ePrecision':
        return 'e(50) — même pipeline MPFR que pi(N).';
      case 'factorint360':
        return 'factorint(360) → 2³ · 3² · 5 avec exposants Unicode.';
      case 'nextprime1000':
        return 'nextprime(1000) — appuyé par FLINT via SymEngine ntheory.';
      case 'mersenneM31':
        return 'factorint(2^31 − 1) — confirme le huitième nombre '
            'premier de Mersenne comme facteur unique.';
      case 'divisors12':
        return 'divisors(12) → 1, 2, 3, 4, 6, 12 — dérivé de la '
            'factorisation en facteurs premiers.';
      case 'eulerTotient':
        return 'totient(36) — nombre de restes premiers avec 36.';
      case 'modpowCrypto':
        return 'modpow(2, 100, 1000000007) — le cœur de RSA / '
            'Diffie-Hellman.';
      case 'contFracPi':
        return 'cfrac(pi, 10) — le développement [3; 7, 15, 1, 292, …] '
            'derrière 355/113.';
      case 'zetaBasel':
        return 'zeta(2) — le ζ(2) = π²/6 ≈ 1,6449 d\'Euler.';
      case 'gammaHalf':
        return 'gamma(0.5) — Γ(½) = √π ≈ 1,7725.';
      case 'evalfLn10':
        return 'evalf(ln(10), 50) — toute expression à 50 décimales.';
      case 'besselJZero':
        return 'besselj(0, 1) — J₀(1) ≈ 0,7652, via MPFR. Tracez '
            'besselj(0, x).';
      case 'cevalfPow':
        return 'cevalf((1+I)^10, 20) — (1+i)¹⁰ = 32i, via MPC.';
      case 'booleanIsprimeAnd':
        return 'isprime(17) et 17 < 20 — les deux clauses sont vraies, '
            'donc la conjonction est vraie.';
      case 'booleanEqualityFold':
        return '2 == 2 — des opérandes constants se réduisent à vrai.';
      case 'booleanNotPrime':
        return 'not isprime(15) — 15 = 3·5, donc le résultat est vrai.';
      case 'booleanOrChain':
        return '(5 > 3) ou (1 == 2) — la première clause est vraie, '
            'donc la disjonction entière est vraie.';
      case 'booleanIfFold':
        return 'if(isprime(7), 100, 200) — la condition se réduit à vrai, '
            'donc la branche then l\'emporte.';
      case 'compoundInterest':
        return '1000 € à 5 % sur 10 ans, capitalisation annuelle.';
      case 'zScore':
        return 'Aller dans l\'écran Statistiques → Distributions pour '
            'calculer Φ(1,96) ≈ 0,975.';
      case 'statsHypothesisTests':
        return 'Ouvre le module Statistiques directement sur l\'onglet '
            'Tests — t à un échantillon, t à deux échantillons (Welch), '
            'apparié, ANOVA, khi-deux et Wilcoxon — avec des données '
            'd\'exemple préchargées.';
      case 'statsWelchTwoSample':
        return 'Ouvre l\'onglet Tests sur le t à deux échantillons de Welch '
            'avec deux groupes de variances inégales déjà saisis.';
      case 'statsAnovaThreeGroups':
        return 'Ouvre l\'onglet Tests sur l\'ANOVA à un facteur avec trois '
            'groupes distincts déjà saisis.';
      case 'statsChiSquareGof':
        return 'Ouvre l\'onglet Tests sur le khi-deux d\'ajustement avec des '
            'effectifs observés déjà saisis face à une distribution uniforme.';
      case 'unitConversion':
        return '100 km/h converti en mph — analyseur inline V2.';
      case 'compositeDim':
        return '100 m / 10 s donne une vitesse en m/s — analyseur V5.';
    }
    return additionalWorkedExampleDescription('fr', id);
  }

  // Round 100: FR function-reference prose. Double-quoted strings
  // throughout because French is full of apostrophes (prefer_single_quotes
  // is not enforced in analysis_options).
  @override
  String? functionRefDescription(String id) {
    switch (id) {
      case 'solve':
        return "Résout symboliquement une équation pour une variable ; "
            "renvoie une liste de solutions.";
      case 'expand':
        return "Développe les produits et les puissances en une somme de "
            "monômes.";
      case 'simplify':
        return "Regroupe les termes semblables, simplifie les facteurs "
            "communs et applique les identités algébriques usuelles.";
      case 'factor':
        return "Factorise un polynôme sur les rationnels en facteurs "
            "irréductibles.";
      case 'diff':
        return "Dérivée première symbolique par rapport à une variable.";
      case 'integrate':
        return "Intégrale indéfinie (3 arguments) ou intégrale définie "
            "(5 arguments) avec repli numérique.";
      case 'subst':
        return "Remplace chaque occurrence libre de `variable` dans "
            "`expression` par `value`. Également disponible sous le nom "
            "`substitute(...)`.";
      case 'limit':
        return "Limite numérique lorsque `variable` tend vers `point`. "
            "`point` peut être une valeur finie ou `oo` / `-oo`.";
      case 'gcd':
        return "Plus grand commun diviseur (PGCD) de deux entiers ou "
            "polynômes.";
      case 'lcm':
        return "Plus petit commun multiple (PPCM) de deux entiers ou "
            "polynômes.";
      case 'polygcd':
        return "Plus grand commun diviseur unitaire de deux polynômes à une "
            "variable sur ℚ.";
      case 'polydiv':
        return "Division polynomiale de `p ÷ q` sur ℚ. Renvoie le quotient "
            "et le reste.";
      case 'polyresultant':
        return "Résultant Res(p, q) — nul exactement lorsque `p` et `q` "
            "partagent un facteur non constant.";
      case 'polydiscriminant':
        return "Discriminant d'un polynôme à une variable (degré ≥ 1) — nul "
            "exactement lorsque `p` a une racine multiple.";
      case 'polyfactor':
        return "Factorise un polynôme à une variable sur le corps fini 𝔽ₖ "
            "(k premier) en facteurs irréductibles unitaires. Pour la "
            "factorisation sur ℚ, utilisez `factor`.";
      case 'gamma':
        return "La fonction Gamma Γ(x) — le prolongement continu de "
            "(x − 1)! aux réels et au plan complexe.";
      case 'zeta':
        return "La fonction zêta de Riemann ζ(s) = Σ 1/nˢ et son "
            "prolongement analytique.";
      case 'erf':
        return "La fonction d'erreur erf(x) = (2/√π) ∫₀ˣ e^(−t²) dt — "
            "centrale pour la loi normale.";
      case 'lambertw':
        return "La fonction W de Lambert — la réciproque de x·eˣ, telle que "
            "W(x)·e^(W(x)) = x.";
      case 'beta':
        return "La fonction Bêta B(a, b) = Γ(a)·Γ(b) / Γ(a + b).";
      case 'besselj':
        return "Fonction de Bessel de première espèce Jₙ(x) — ordre entier "
            "n, x réel. Traçable.";
      case 'bessely':
        return "Fonction de Bessel de seconde espèce Yₙ(x) (fonction de "
            "Weber) — ordre entier n, x réel > 0. Traçable.";
      case 'factorial':
        return "Factorielle entière exacte. Les petits `n` utilisent le "
            "`BigInt` de Dart ; les grands `n` sont confiés à SymEngine.";
      case 'fibonacci':
        return "n-ième nombre de Fibonacci. `fib(n)` est le nom abrégé.";
      case 'taylor':
        return "Polynôme de Taylor/Maclaurin de f au point de développement "
            "x0 (0 par défaut), tronqué après n termes (6 par défaut). "
            "Séries SymEngine sur FLINT ; disponible en natif et sur le web.";
      case 'linsolve':
        return "Résout un système d'équations linéaires symboliquement "
            "(fractions exactes/symboles). Équations séparées par « ; », "
            "puis les inconnues. Disponible en natif et sur le web.";
      case 'dsolve':
        return "Résout une EDO exactement. Second ordre : linéaire à "
            "coefficients constants (homogène + coefficients indéterminés). "
            "Premier ordre : séparable, linéaire (facteur intégrant), "
            "Bernoulli et exacte (M dx + N dy = 0 avec le potentiel "
            "implicite F(x, y) = C1).";
      case 'isprime':
        return "Test de primalité probabiliste sur les entiers.";
      case 'nextprime':
        return "Plus petit nombre premier strictement supérieur à `n`.";
      case 'prevprime':
        return "Plus grand nombre premier strictement inférieur à `n`. "
            "Erreur si aucun nombre premier de ce type n'existe "
            "(par ex. `prevprime(2)`).";
      case 'factorint':
        return "Décomposition en facteurs premiers sous la forme "
            "`p₁^e₁ · p₂^e₂ · …` avec des exposants Unicode en exposant.";
      case 'divisors':
        return "Tous les diviseurs positifs de `n`, triés par ordre croissant "
            "et séparés par des virgules.";
      case 'totient':
        return "Indicatrice d'Euler φ(n) : le nombre d'entiers de 1 à n "
            "premiers avec `n`.";
      case 'modpow':
        return "Exponentiation modulaire `aᵉ mod m`. Un exposant négatif "
            "utilise l'inverse modulaire de `a` (lorsqu'il existe).";
      case 'modinv':
        return "Inverse modulaire `a⁻¹ mod m` via l'algorithme d'Euclide "
            "étendu. Erreur lorsque `pgcd(a, m) ≠ 1`.";
      case 'jacobi':
        return "Symbole de Jacobi (a/n) ∈ {−1, 0, 1} pour `n` impair positif ; "
            "généralise le symbole de Legendre.";
      case 'cfrac':
        return "Développement en fraction continue `[a₀; a₁, …]` de `x` sur "
            "`n` termes. `x` peut être `pi` / `e` / `EulerGamma` / "
            "`sqrt(2)`, un rationnel `p/q` ou un décimal.";
      case 'convergent':
        return "La k-ième réduite `p/q` de la fraction continue de `x` — une "
            "meilleure approximation rationnelle pour la taille de son "
            "dénominateur.";
      case 'pi_precision':
        return "π avec N décimales via MPFR ; renvoie la chaîne de chiffres "
            "brute.";
      case 'e_precision':
        return "Nombre d'Euler e avec N décimales via MPFR.";
      case 'sqrt_precision':
        return "Racine carrée de l'entier `k` avec N décimales via MPFR. La "
            "forme à deux arguments choisit le chemin haute précision.";
      case 'eulergamma_precision':
        return "Constante d'Euler-Mascheroni γ ≈ 0,5772… avec N décimales "
            "via MPFR.";
      case 'evalf':
        return "Évalue n'importe quelle expression réelle avec N décimales "
            "via MPFR — la valeur numérique de précision arbitraire de "
            "`expr`.";
      case 'cevalf':
        return "Évaluation complexe de précision arbitraire — comme `evalf` "
            "mais conserve la partie imaginaire, renvoyant `a + b·I` avec N "
            "décimales via MPC.";
      case 'matrix_literal':
        return "Littéral matriciel : une liste de lignes, chaque ligne étant "
            "une liste d'expressions de cellule. Les cellules peuvent être "
            "des nombres, des fractions ou symboliques.";
      case 'det':
        return "Déterminant d'une matrice carrée. Renvoie un scalaire "
            "symbolique.";
      case 'inv':
        return "Inverse d'une matrice carrée non singulière. Erreur lorsque "
            "`det = 0`.";
      case 'transpose':
        return "Transposée : échange des lignes et des colonnes. Fonctionne "
            "sur les matrices rectangulaires.";
      case 'rref':
        return "Forme échelonnée réduite par lignes via l'élimination de "
            "Gauss-Jordan. Fonctionne sur des entrées symboliques/"
            "rationnelles.";
      case 'matrix_arithmetic':
        return "Addition/soustraction terme à terme et multiplication "
            "matricielle sur des littéraux `Matrix(...)`.";
      case 'eigenvalues':
        return "Valeurs propres d'une matrice carrée numérique via "
            "l'algorithme QR. Renvoie aussi les valeurs propres complexes.";
      case 'eigenvectors':
        return "Valeurs propres et vecteurs propres d'une matrice carrée "
            "numérique. Vecteurs propres pour les matrices 2×2 à valeurs "
            "propres réelles.";
      case 'mean':
        return "Moyenne arithmétique d'un échantillon sous forme de liste de "
            "nombres. Proposée dans l'onglet « Statistiques descriptives » du "
            "module Statistiques, avec les indicateurs usuels.";
      case 'one_sample_t':
        return "Test t à un échantillon : la moyenne de l'échantillon "
            "diffère-t-elle d'une moyenne de population supposée μ₀ ? Fournit "
            "t, df = n−1 et une valeur p bilatérale.";
      case 'welch_t':
        return "Test t à deux échantillons à variances inégales "
            "(Welch-Satterthwaite). Choix par défaut robuste lorsque les deux "
            "groupes peuvent avoir des dispersions différentes.";
      case 'paired_t':
        return "Test t apparié sur les différences intra-sujet contre "
            "μ₀ = 0. À utiliser lorsque les mêmes unités sont mesurées deux "
            "fois (avant/après).";
      case 'anova_1':
        return "Analyse de variance (ANOVA) à un facteur sur K groupes "
            "indépendants. Teste si les moyennes des groupes diffèrent ; "
            "fournit une statistique F et une valeur p.";
      case 'chi2_goodness':
        return "Test d'adéquation du khi-deux : les effectifs observés "
            "correspondent-ils à une distribution supposée ?";
      case 'chi2_independence':
        return "Test d'indépendance du khi-deux sur une table de "
            "contingence — deux variables catégorielles sont-elles "
            "indépendantes ?";
      case 'fisher_exact':
        return "Test exact de Fisher sur une table de contingence 2×2. "
            "Valeur p hypergéométrique exacte — sans approximation pour "
            "grands échantillons.";
      case 'wilcoxon':
        return "Test de la somme des rangs de Wilcoxon / U de "
            "Mann-Whitney — test non paramétrique à deux échantillons sur "
            "les rangs. Robuste aux données non normales.";
      case 'sign_test':
        return "Test des signes apparié — test non paramétrique fondé sur la "
            "médiane des différences appariées. Compte combien de fois "
            "`après > avant`.";
      case 'linreg':
        return "Régression linéaire par les moindres carrés y = a·x + b sur "
            "des données appariées (x, y). Fournit la pente, l'ordonnée à "
            "l'origine et le coefficient de détermination R².";
      case 'normal_dist':
        return "Loi normale (gaussienne) N(μ, σ) : probabilité cumulée "
            "P(X ≤ x) et le quantile (fonction de répartition inverse) pour "
            "une probabilité p donnée.";
      case 'binomial_dist':
        return "Loi binomiale B(n, p) sur n épreuves indépendantes de "
            "probabilité de succès p : moyenne n·p, variance n·p·(1−p), la "
            "masse ponctuelle P(X = k) et la probabilité cumulée P(X ≤ k).";
      case 'vars':
        return "Déclare les variables de décision entières et leur domaine. "
            "Toujours la première ligne d'un programme DSL de CrispMath.";
      case 'all_different':
        return "Contrainte globale « toutes les valeurs deux à deux "
            "distinctes ». La contrainte PPC phare — propagation bien plus "
            "forte que n·(n-1)/2 clauses `!=` deux à deux.";
      case 'no_overlap':
        return "Ordonnancement disjonctif : des tâches ayant des variables "
            "de début données et des durées fixes ne peuvent pas se "
            "chevaucher dans le temps sur une même machine.";
      case 'cumulative':
        return "Ordonnancement cumulatif sur une ressource renouvelable de "
            "capacité fixe. Chaque tâche a une durée et une demande de "
            "ressource propre.";
      case 'minimize':
        return "Objectif : minimiser une expression linéaire sur les "
            "variables de décision. À combiner avec des contraintes pour "
            "résoudre des PSC d'optimisation.";
      case 'maximize':
        return "Objectif : maximiser une expression linéaire. Image miroir "
            "de `minimize` — même séparation-évaluation, dans le sens "
            "opposé.";
      case 'at_least':
        return 'Au moins k des conditions `nom=valeur` données doivent être vraies. Chaque condition est réifiée en booléen et leur somme est minorée.';
      case 'poly_fit':
        return 'Régression polynomiale des moindres carrés y = c₀ + c₁x + … + c_d·xᵈ d\'un degré d choisi sur des données appariées (x, y). Renvoie les coefficients et R².';
      case 'exp_fit':
        return 'Régression exponentielle des moindres carrés y = a·e^(b·x) sur des données appariées (x, y) (ajustement par transformation log-linéaire). Renvoie a, b et R².';
      case 'at_most':
        return 'Au plus k des conditions `nom=valeur` données peuvent être vraies — les conditions réifiées se somment à k au maximum.';
      case 'exactly':
        return 'Exactement k des conditions `nom=valeur` données sont vraies — les conditions réifiées se somment à exactement k.';
      case 'implies':
        return 'Implication matérielle sur deux conditions `nom=valeur` : si la première est vraie, la seconde doit l\'être aussi (a=1 ⇒ b=2).';
      case 'gcc':
        return 'Cardinalité globale : chaque valeur listée doit apparaître un nombre exact de fois parmi les variables (valeur 1 deux fois, valeur 2 une fois, …).';
      case 'among':
        return 'La variable déclarée c est égale au nombre de variables listées prenant une valeur dans l\'ensemble donné.';
      case 'nvalue':
        return 'La variable déclarée c est égale au nombre de valeurs DISTINCTES prises par les variables listées. Minimisez c pour en utiliser le moins possible.';
      case 'at_most_in_a_row':
        return 'Aucune suite de plus de `max` `valeur`s consécutives dans la séquence — compilé en un petit automate fini (contrainte regular).';
      case 'value_precedence':
        return 'Brisure de symétrie : la valeur order[i+1] ne peut apparaître avant order[i]. Regroupe les valeurs interchangeables (p. ex. couleurs de carte) pour n\'énumérer qu\'un représentant par classe.';
      case 'table':
        return 'Le tuple (x, y, z) doit correspondre à l\'une des lignes listées. Encode des relations arbitraires : matrices de compatibilité, combinaisons autorisées, tables d\'indices de casse-tête logique.';
      case 'element':
        return 'Accès indexé : list[idx] == value, index base 0. Modélise une indirection comme « le coût de l\'option choisie est v ».';
      case 'diff_n':
        return 'Rectangles 2D sans chevauchement : chaque tuple place un rectangle w×h au coin inférieur gauche (x, y). Modélise le placement, le pavage et les plans au sol ; l\'onglet DSL dessine la disposition trouvée à l\'échelle.';
      case 'circuit':
        return 'Un unique circuit hamiltonien sur des variables successeur : next[i] est le nœud visité après le nœud i, et le circuit doit atteindre chaque nœud une fois puis revenir au départ. Modélise le voyageur de commerce et le routage ; l\'onglet DSL dessine le circuit en graphe orienté. `subcircuit` autorise des nœuds non visités (boucles).';
      case 'soft':
        return 'Une préférence MaxCSP : le solveur la satisfait si possible, contribuant son poids (1 par défaut) au score. Quand les préférences s\'opposent, l\'affectation qui maximise le poids total satisfait l\'emporte. L\'onglet DSL affiche un score de satisfaction et quelles préférences ont tenu.';
      case 'set_var':
        return 'Les variables ensemblistes choisissent un sous-ensemble d\'un univers entier — sélection d\'équipe / de comité. Déclarez avec `set S from lo..hi`, puis façonnez : `card(S) = k` (aussi `<=`, `in a..b`), `subset(A, B)`, `disjoint(A, B)`, `setEquals(A, B)`, `S contains e`, `S excludes e`. Les solutions s\'affichent en grappes de puces.';
      case 'dot':
        return 'Produit scalaire de deux vecteurs de même longueur : Σ aᵢ·bᵢ. Renvoie un scalaire.';
      case 'cross':
        return 'Produit vectoriel de deux vecteurs 3D : le vecteur orthogonal aux deux, de longueur |a||b|sin θ.';
      case 'norm':
        return 'Longueur euclidienne (norme 2) d\'un vecteur : √(Σ vᵢ²).';
      case 'unit':
        return 'Vecteur unitaire dans la direction de v : v / norm(v). Même direction, longueur 1.';
      case 'mod':
        return 'Modulo : le reste de a ÷ n. La touche `mod` insère l\'opérateur entre deux entiers.';
      case 'nth_root':
        return 'La racine n-ième de x, soit x^(1/n). La touche ouvre une petite boîte de dialogue pour le degré n et le radicande x.';
      case 'sin':
        return 'Sinus de x (x en radians).';
      case 'cos':
        return 'Cosinus de x (x en radians).';
      case 'tan':
        return 'Tangente de x = sin(x)/cos(x) (x en radians).';
      case 'asin':
        return 'Arc sinus : l\'angle dont le sinus vaut x.';
      case 'acos':
        return 'Arc cosinus : l\'angle dont le cosinus vaut x.';
      case 'atan':
        return 'Arc tangente : l\'angle dont la tangente vaut x.';
      case 'sinh':
        return 'Sinus hyperbolique : (eˣ − e⁻ˣ)/2.';
      case 'cosh':
        return 'Cosinus hyperbolique : (eˣ + e⁻ˣ)/2.';
      case 'tanh':
        return 'Tangente hyperbolique : sinh(x)/cosh(x).';
      case 'asinh':
        return 'Argument sinus hyperbolique (réciproque de sinh).';
      case 'acosh':
        return 'Argument cosinus hyperbolique.';
      case 'atanh':
        return 'Argument tangente hyperbolique.';
      case 'ln':
        return 'Logarithme naturel (base e) de x.';
      case 'log':
        return 'Logarithme décimal (base 10) de x.';
      case 'exp':
        return 'Fonction exponentielle e^x.';
      case 'abs':
        return 'Valeur absolue de x — aussi le module d\'un nombre complexe.';
      case 'sqrt':
        return 'Racine carrée de x (valeur principale, branche positive).';
      case 'pi':
        return 'La constante π ≈ 3,14159 — circonférence d\'un cercle divisée par son diamètre. La touche insère le symbole.';
      case 'imaginary_unit':
        return 'L\'unité imaginaire i, avec i² = −1. Représentée en interne par I de SymEngine.';
      case 'euler_gamma':
        return 'La constante d\'Euler-Mascheroni γ ≈ 0,57722 — la limite de (Σ 1/k − ln n) quand n → ∞.';
      case 'infinity':
        return 'L\'infini positif ∞ — comme borne dans les limites et intégrales impropres, non comme valeur à calculer.';
      case 'sudoku_regular':
        return "Règles classiques du Sudoku : chaque ligne, colonne et bloc "
            "contient chaque chiffre exactement une fois. Des modèles "
            "existent pour 4×4, 6×6, 8×8, 9×9, 10×10, 12×12, 15×15 et 16×16.";
      case 'sudoku_x':
        return "Sudoku-X : règles classiques du Sudoku, plus les deux "
            "diagonales principales sont également « toutes différentes ». "
            "Fourni comme modèle 8×8.";
      case 'sudoku_disjoint':
        return "Groupes disjoints : règles classiques, plus une contrainte "
            "« toutes différentes » supplémentaire sur les cellules occupant "
            "la même position dans le bloc, à travers tous les blocs.";
      case 'sudoku_killer':
        return "Sudoku killer : aucun indice donné ; à la place, la grille "
            "est partitionnée en « cages », chaque cage étant « toutes "
            "différentes » et de somme égale à une cible donnée.";
      case 'eq_op':
        return 'Test d\'égalité — renvoie true lorsque les deux côtés évaluent la même valeur.';
      case 'ne_op':
        return 'Test d\'inégalité — renvoie true lorsque les deux côtés diffèrent.';
      case 'lt_op':
        return 'Comparaison strictement inférieur.';
      case 'le_op':
        return 'Comparaison inférieur ou égal.';
      case 'gt_op':
        return 'Comparaison strictement supérieur.';
      case 'ge_op':
        return 'Comparaison supérieur ou égal.';
      case 'and_op':
        return 'Conjonction logique — true uniquement si les deux opérandes sont true.';
      case 'or_op':
        return 'Disjonction logique — true si au moins un opérande est true.';
      case 'not_op':
        return 'Négation logique — inverse true en false et vice versa.';
      case 'xor_op':
        return 'Ou exclusif — true lorsqu\'exactement un opérande est true.';
      case 'if_cond':
        return 'Conditionnel — évalue la condition, renvoie la branche then si true, sinon la branche else.';
      default:
        return null;
    }
  }

  @override
  String? functionRefExampleHint(String id, int index) {
    final list = _frHints[id];
    if (list == null || index < 0 || index >= list.length) return null;
    return list[index];
  }

  static const _frHints = <String, List<String>>{
    'solve': [
      "Dans CrispMath, `solve(x^2 - 1, x)` renvoie une liste de racines à la "
          "manière de Python. L'appel sous-jacent est le `solve()` de "
          "SymEngine (branche des racines rationnelles pour les polynômes), "
          "encapsulé par le pont et sérialisé en chaîne Dart.",
      "`=` dans l'entrée est accepté comme syntaxe d'équation — le "
          "préprocesseur normalise `lhs = rhs` en `lhs - rhs` avant l'appel "
          "au pont.",
      "Les racines complexes reviennent sous le littéral `I` de SymEngine. "
          "Réutilisées dans d'autres appels (par ex. `expand((-I)*(I))`), le "
          "pont les conserve sous forme symbolique.",
      "Les INÉQUATIONS polynomiales sont aussi résolues : les racines découpent la droite en intervalles et le signe de chaque intervalle décide. Gère aussi ≤/≥, les bornes en radicaux exacts et les cas ≠ / point / ℝ / ∅.",
    ],
    'expand': [
      "Dans CrispMath, `expand((x + 1)^2)` renvoie le développement du "
          "binôme. L'appel sous-jacent est le `expand()` de SymEngine, qui "
          "décompose les nœuds `Pow` et `Mul` et regroupe les termes "
          "semblables.",
      "Les coefficients correspondent à la 5ᵉ ligne du triangle de Pascal : "
          "1, 5, 10, 10, 5, 1, chacun multiplié par la puissance de 2 "
          "appropriée.",
      "L'identité de la différence de deux carrés — utile en alternance avec "
          "`factor` pour passer d'une forme à l'autre.",
    ],
    'simplify': [
      "Dans CrispMath, `simplify` simplifie le facteur commun `(x - 2)`. "
          "L'appel sous-jacent est le `simplify()` de SymEngine, qui essaie "
          "`rational_simplify` ainsi qu'un petit ensemble de règles de "
          "réécriture.",
      "Regroupement des termes semblables sur une entrée polynomiale — en "
          "interne, c'est simplement `expand` suivi de la fusion des "
          "coefficients.",
      "Identité de Pythagore ; SymEngine applique la règle de réécriture "
          "trigonométrique avant de renvoyer le littéral `1`.",
    ],
    'factor': [
      "Dans CrispMath, `factor(x^2 - 1)` renvoie la factorisation en "
          "différence de deux carrés. L'appel sous-jacent est le `factor()` "
          "de SymEngine, qui utilise Berlekamp / Cantor–Zassenhaus pour les "
          "polynômes à une variable sur Q.",
      "Identité de la somme/différence de cubes : un facteur linéaire "
          "multiplié par un trinôme du second degré irréductible sur Q.",
      "La factorisation s'arrête à l'irréductibilité sur Q — `x^2 + 1` ne se "
          "décompose pas davantage sans admettre de racines complexes.",
    ],
    'diff': [
      "Dans CrispMath, `diff(...)` applique terme à terme les règles de "
          "dérivation des puissances et des constantes. L'appel sous-jacent "
          "est le `diff()` de SymEngine, qui parcourt l'arbre d'expression et "
          "produit un nouveau nœud `Add` symbolique.",
      "Règle de dérivation en chaîne : SymEngine applique "
          "`diff(sin(u))/du * du/dx` pour l'intérieur `u = x^2`.",
      "Règle du produit — notez que SymEngine laisse le résultat non "
          "factorisé. Passé dans `factor`, `exp(x)` est mis en facteur.",
    ],
    'integrate': [
      "Dans CrispMath, l'intégrale indéfinie `integrate(...)` est déléguée "
          "au `integrate()` de SymEngine. L'intégration par parties est "
          "appliquée automatiquement lorsqu'un facteur se dérive en un "
          "polynôme.",
      "Forme définie : lorsque SymEngine dispose d'une primitive sous forme "
          "close, il applique le théorème fondamental de l'analyse. En cas "
          "d'échec symbolique, CrispMath se rabat sur la méthode de Simpson "
          "(200 sous-intervalles).",
      "Décomposition en éléments simples : 1/(x²-1) = 1/(2(x-1)) - "
          "1/(2(x+1)). SymEngine effectue le calcul automatiquement.",
    ],
    'subst': [
      "Dans CrispMath, `subst` réécrit l'arbre d'expression puis tente une "
          "passe de simplification. L'appel sous-jacent est le `xreplace()` "
          "de SymEngine (remplacement de variables uniquement, sans filtrage "
          "de motif).",
      "Les constantes numériques `pi`, `e` et l'unité imaginaire `I` sont "
          "reconnues par SymEngine et propagées à travers l'identité "
          "trigonométrique.",
      "La substitution est symbolique — les variables libres sans rapport "
          "`a` et `b` restent intactes.",
    ],
    'limit': [
      "Dans CrispMath, `limit(...)` est une approche numérique : le pont "
          "évalue l'expression en une suite de points convergeant vers "
          "`point` et renvoie la limite dès que des échantillons consécutifs "
          "concordent à la précision de travail. Pas de développement en "
          "série symbolique.",
      "Le littéral `oo` est la sentinelle d'infini de SymEngine — le "
          "préprocesseur la reconnaît avant l'envoi. Utilisez `-oo` pour "
          "l'infini négatif.",
      "Tend vers le nombre d'Euler. Comme le chemin est numérique, le "
          "résultat est un nombre à virgule flottante — utilisez `e(N)` pour "
          "la constante en haute précision.",
    ],
    'gcd': [
      "Dans CrispMath, le `gcd(...)` entier utilise la récurrence "
          "d'Euclide gcd(a, b) = gcd(b, a mod b). L'appel sous-jacent est le "
          "`gcd()` de SymEngine, qui s'appuie sur `mpz_gcd` de GMP dans le "
          "cas entier.",
      "PGCD polynomial via l'algorithme des sous-résultants (PRS). Utile en "
          "préalable à `simplify` pour les simplifications.",
      "Convention : `gcd(0, n) = |n|`. Conforme à la définition "
          "mathématique qui traite 0 comme un multiple de tout entier.",
    ],
    'lcm': [
      "Dans CrispMath, le `lcm(...)` entier est calculé via l'identité "
          "`lcm(a, b) = |a*b| / gcd(a, b)`. L'appel sous-jacent est le "
          "`lcm()` de SymEngine, qui délègue à `mpz_lcm` de GMP.",
      "36 = 2²·3², l'union des facteurs en puissances de nombres premiers de "
          "12 = 2²·3 et 18 = 2·3².",
      "Le PPCM polynomial choisit le multiple de plus haut degré — `x^2 - 1` "
          "contient déjà `x + 1` comme facteur.",
    ],
    'polygcd': [
      "Dans CrispMath, `polygcd` exécute l'algorithme d'Euclide avec des "
          "coefficients rationnels exacts (Dart pur). Les deux polynômes "
          "partagent le facteur `x - 1` ; le résultat est rendu unitaire.",
      "Des polynômes premiers entre eux donnent la constante unitaire 1.",
    ],
    'polydiv': [
      "Division exacte — le reste est nul. "
          "`x² - 1 = (x + 1)(x - 1)`.",
      "Non-exacte : `x² + 3x + 5 = (x + 2)(x + 1) + 3`.",
    ],
    'polyresultant': [
      "Calculé comme le déterminant de la matrice de Sylvester. Il s'annule "
          "ici car les deux s'annulent en `x = 1`.",
      "Un résultant non nul certifie que les deux polynômes sont premiers "
          "entre eux sur ℚ.",
    ],
    'polydiscriminant': [
      "Pour `x² + bx + c`, le discriminant est `b² − 4c` — ici 25 − 24 = 1. "
          "CrispMath utilise `(−1)^(n(n−1)/2)·Res(p, p′)/aₙ`.",
      "`(x − 2)²` a une racine double, donc le discriminant est 0.",
    ],
    'polyfactor': [
      "Dans CrispMath, `polyfactor` réduit le polynôme modulo k, effectue une "
          "factorisation sans carré puis l'algorithme de Berlekamp (Dart "
          "pur). Les coefficients s'affichent comme des restes dans [0, k), "
          "donc `x − 1` apparaît comme `x + 4` modulo 5.",
      "`x⁴ + 1` est irréductible sur ℚ mais devient une puissance 4ᵉ parfaite "
          "modulo 2 — la factorisation sans carré récupère la multiplicité.",
      "Irréductible sur 𝔽₂ — un polynôme primitif servant à construire "
          "GF(8). Un facteur unique est renvoyé tel quel.",
    ],
    'gamma': [
      "Pour un entier positif n, Γ(n) = (n − 1)!, donc Γ(5) = 4! = 24. "
          "Évalué numériquement via `basic_evalf` de SymEngine (MPFR).",
      "Γ(½) = √π — la constante derrière l'intégrale de Gauss. Traçable : "
          "tracez `gamma(x)` pour voir les pôles aux entiers négatifs ou "
          "nuls.",
    ],
    'zeta': [
      "Le problème de Bâle : ζ(2) = π²/6 ≈ 1,6449. Évalué numériquement via "
          "MPFR.",
      "ζ(4) = π⁴/90. Les valeurs aux entiers pairs sont toutes des multiples "
          "rationnels de puissances de π.",
    ],
    'erf': [
      "erf est impaire, avec erf(0) = 0 et erf(x) → 1 quand x → ∞. "
          "Traçable : tracez `erf(x)` pour la sigmoïde classique.",
      "La fonction d'erreur complémentaire erfc(x) = 1 − erf(x).",
    ],
    'lambertw': [
      "La constante oméga Ω, solution de Ω·e^Ω = 1. Résout les équations de "
          "la forme x·eˣ = c.",
      "W(0) = 0, car 0·e⁰ = 0.",
    ],
    'beta': [
      "B(2, 3) = 1!·2!/4! = 2/24 = 1/12. Sous-tend la loi Bêta en "
          "statistique.",
      "B(1, 1) = Γ(1)²/Γ(2) = 1 — une loi Bêta uniforme.",
    ],
    'besselj': [
      "J₀ en x = 1. Les Jₙ résolvent x²y″ + xy′ + (x² − n²)y = 0 — "
          "membranes vibrantes, guides d'ondes. Via `mpfr_jn` de MPFR. "
          "Traçable : tracez `besselj(0, x)`.",
      "Jₙ(0) = 0 pour n ≥ 1, tandis que J₀(0) = 1.",
    ],
    'bessely': [
      "La seconde solution indépendante de l'équation de Bessel ; "
          "Yₙ(x) → −∞ quand x → 0⁺. Via `mpfr_yn` de MPFR.",
      "Traçable : tracez `bessely(0, x)` à côté de `besselj(0, x)`.",
    ],
    'factorial': [
      "Dans CrispMath, le suffixe `n!` et `factorial(n)` sont équivalents — "
          "le préprocesseur réécrit le suffixe en appel. Pour `n ≤ 1000`, "
          "nous calculons en Dart avec la multiplication `BigInt` ; au-delà, "
          "l'appel sous-jacent est le `factorial()` de SymEngine.",
      "158 chiffres, conservés exactement grâce au chemin BigInt — passer en "
          "IEEE-754 arrondirait ici à 1,0 × 10^157.",
      "Convention du produit vide : 0! = 1. Nécessaire pour que la récurrence "
          "n! = n · (n-1)! se termine à 1.",
    ],
    'dsolve': [
      "Équation caractéristique r^2 + 3r + 2 = 0 de racines -1 et -2 ; "
          "chaque racine fournit un mode exponentiel. Les paires "
          "complexes donnent exp*(cos + sin), les racines doubles "
          "(C1 + C2*x)*exp.",
      "Solution homogène plus une solution particulière polynomiale par "
          "coefficients indéterminés — le tout en arithmétique "
          "rationnelle exacte, sans dérive flottante des coefficients.",
    ],
    'taylor': [
      "Seulement des puissances impaires — le sinus est une fonction "
          "impaire. Le développement s'arrête avant x^8 (reste O(x^8)) ; "
          "les coefficients sont (-1)^k/(2k+1)!.",
      "`series(f, x, n)` est le raccourci du développement de Maclaurin "
          "(point 0). Les coefficients de la série exponentielle sont 1/k!.",
    ],
    'linsolve': [
      "Chaque équation peut s'écrire « membre gauche = membre droit » ou "
          "comme expression (implicitement = 0). La résolution est exacte "
          "via le linsolve() de SymEngine.",
      "Les résultats restent des fractions exactes — pas d'arrondi "
          "flottant. Les systèmes non linéaires ou sous-déterminés "
          "renvoient une erreur.",
    ],
    'fibonacci': [
      "Dans CrispMath, `fib(n)` et `fibonacci(n)` sont le même appel. Pour "
          "`n ≤ 90`, nous utilisons une table précalculée ; pour les `n` plus "
          "grands, l'appel sous-jacent est le `fibonacci()` de SymEngine, qui "
          "utilise le doublement rapide (O(log n) multiplications via GMP).",
      "Le 50ᵉ nombre de Fibonacci — bien au-delà de la limite de la table "
          "pour les petits termes, mais tient encore dans un entier signé de "
          "64 bits.",
      "Bascule sur le chemin appuyé par GMP. Le doublement rapide évite la "
          "récurrence linéaire en O(n), si bien que même fib(10000) reste "
          "sous la seconde.",
    ],
    'isprime': [
      "Dans CrispMath, `isprime(n)` renvoie une puce booléenne. L'appel "
          "sous-jacent est `mpz_probab_prime_p` de GMP (25 tours de "
          "Miller-Rabin, borne d'erreur 4^-25 ≈ 9×10^-16) via le module "
          "`ntheory` de SymEngine. 2027 est le 308ᵉ nombre premier.",
      "2024 = 2³·11·23.",
      "Le neuvième nombre premier de Mersenne, M61. Miller-Rabin se résout "
          "encore en microsecondes à cette taille — le coût réside dans les "
          "exponentiations modulaires, pas dans la longueur en bits.",
    ],
    'nextprime': [
      "Dans CrispMath, `nextprime(n)` itère à partir de `n+1` et teste "
          "chaque candidat. L'appel sous-jacent est le "
          "`ntheory::nextprime()` de SymEngine, qui utilise le crible de "
          "FLINT sur de courtes fenêtres lorsque l'écart est grand.",
      "Strictement supérieur — `nextprime(p)` n'est jamais `p` lui-même, "
          "même lorsque `p` est premier.",
    ],
    'prevprime': [
      "Dans CrispMath, `prevprime(n)` descend à partir de `n-1`. L'appel "
          "sous-jacent est le `ntheory::prevprime()` de SymEngine.",
      "Il n'existe aucun nombre premier en dessous de 2 ; le pont lève une "
          "erreur plutôt que de renvoyer une valeur sentinelle. CrispMath "
          "affiche la puce d'erreur.",
    ],
    'factorint': [
      "Dans CrispMath, `factorint(n)` renvoie une décomposition en facteurs "
          "premiers mise en forme. L'appel sous-jacent est `fmpz_factor` de "
          "FLINT, en façade via l'enveloppe ntheory de SymEngine ; CrispMath "
          "convertit la liste de (nombre premier, exposant) en l'affichage à "
          "chiffres Unicode en exposant.",
      "Le 8ᵉ nombre premier de Mersenne, M31. Un facteur unique (lui-même) — "
          "`factorint` court-circuite lorsque l'entrée est première.",
      "Cas limite : par convention, 1 a la factorisation vide ; CrispMath "
          "l'affiche comme le littéral `1` plutôt qu'une chaîne vide.",
    ],
    'divisors': [
      "Dans CrispMath, `divisors(n)` est dérivé en Dart pur de `factorint(n)` : "
          "chaque produit de puissances de nombres premiers pᵏ avec "
          "0 ≤ k ≤ exposant. Le compte vaut ∏(eᵢ + 1) — ici (2+1)(1+1) = 6.",
      "28 est un nombre parfait : la somme de ses diviseurs propres (tous "
          "sauf 28 lui-même) vaut 28.",
    ],
    'totient': [
      "Les quatre restes premiers avec 12 sont {1, 5, 7, 11}. CrispMath "
          "calcule φ à partir de la décomposition en facteurs premiers via "
          "`fmpz_euler_phi` de FLINT.",
      "Pour un nombre premier p, φ(p) = p − 1, car tout entier positif plus "
          "petit est premier avec p.",
    ],
    'modpow': [
      "Exponentiation rapide (carré-et-multiplie) via `mpz_powm` de GMP — "
          "l'opération de base de l'arithmétique modulaire et (en version "
          "scolaire) de RSA / Diffie-Hellman. Le gigantesque `2¹⁰⁰` n'est "
          "jamais formé explicitement.",
      "Un exposant négatif inverse d'abord la base, donc `modpow(a, -1, m)` "
          "égale `modinv(a, m)` — ici 3⁻¹ ≡ 4 (mod 11). Erreur si "
          "pgcd(a, m) ≠ 1.",
    ],
    'modinv': [
      "L'unique x dans [0, m) tel que a·x ≡ 1 (mod m), via `mpz_invert` de "
          "GMP. Vérification : 3·4 = 12 ≡ 1 (mod 11).",
      "Seules les unités modulo m sont inversibles. pgcd(2, 4) = 2 ≠ 1, donc "
          "aucun inverse n'existe.",
    ],
    'jacobi': [
      "Pour un nombre premier n, le symbole de Jacobi coïncide avec le "
          "symbole de Legendre — ici 2 est un résidu quadratique modulo 7 "
          "(car 3² ≡ 2). Via `mpz_jacobi` de GMP.",
      "Le symbole vaut 0 exactement lorsque pgcd(a, n) ≠ 1 ; ici "
          "pgcd(6, 9) = 3.",
    ],
    'cfrac': [
      "Dans CrispMath, `cfrac` effectue un développement exact en BigInt sur "
          "une approximation MPFR haute précision de la constante. Le grand "
          "terme 292 est précisément pourquoi la réduite 355/113 approche π "
          "de façon si remarquable.",
      "Pour un rationnel exact, le développement est fini — ce n'est que "
          "l'algorithme d'Euclide consignant ses quotients.",
    ],
    'convergent': [
      "Milü — l'approximation de π par Zu Chongzhi (Ve siècle), exacte à six "
          "décimales. CrispMath replie les k+1 premiers quotients partiels de "
          "`cfrac` en une fraction.",
      "L'approximation scolaire de π ; `convergent(x, 0)` est la partie "
          "entière ⌊x⌋.",
    ],
    'pi_precision': [
      "Dans CrispMath, `pi(N)` est un appel traité à part, dirigé vers le "
          "chemin haute précision avant que SymEngine ne le voie. L'appel "
          "sous-jacent est `mpfr_const_pi` de MPFR à la précision "
          "⌈N·log2(10)⌉ + 16 bits de garde, suivi de la conversion en base "
          "10.",
      "À N = 100, la précision de travail est d'environ 348 bits. Les bits "
          "de garde empêchent la conversion de base d'afficher des chiffres "
          "de fin arrondis.",
    ],
    'e_precision': [
      "Dans CrispMath, `e(N)` reflète le pipeline de `pi(N)` : `mpfr_const_e` "
          "de MPFR (qui utilise la série de Taylor Σ 1/k!) à la précision "
          "⌈N·log2(10)⌉ + 16 bits de garde, puis le rendu en base 10.",
      "Assez court pour être mémorisé — utile comme vérification rapide de "
          "précision face à `limit((1 + 1/n)^n, n, oo)`.",
    ],
    'sqrt_precision': [
      "Dans CrispMath, le `sqrt(k, N)` à deux arguments est la voie haute "
          "précision. L'appel sous-jacent est `mpfr_sqrt_ui` de MPFR à la "
          "précision ⌈N·log2(10)⌉ + 16 bits de garde. Le `sqrt(2)` à un "
          "argument renvoie plutôt le `sqrt(2)` symbolique via SymEngine.",
      "Utile pour la vérification — `sqrt(3, N)` devrait concorder avec des "
          "chiffres de référence dérivés indépendamment.",
    ],
    'eulergamma_precision': [
      "Dans CrispMath, `EulerGamma(N)` utilise `mpfr_const_euler` de MPFR, "
          "qui évalue γ via la formule de Brent–McMillan (fonctions de "
          "Bessel modifiées). La précision est ⌈N·log2(10)⌉ + 16 bits de "
          "garde, comme le pipeline de `pi(N)` et `e(N)`.",
      "γ n'a aucune forme close connue. La routine MPFR est l'implémentation "
          "de référence standard ; CrispMath se contente d'afficher la chaîne "
          "de chiffres.",
    ],
    'evalf': [
      "Dans CrispMath, `evalf` analyse n'importe quelle expression et la "
          "dirige vers `basic_evalf` de SymEngine à ⌈N·log2(10)⌉ + 8 bits. "
          "Le pendant générique de `pi(N)` / `e(N)` — fonctionne pour les "
          "logarithmes, racines, sommes et les fonctions spéciales.",
      "À combiner avec les fonctions spéciales pour des valeurs de haute "
          "précision : ζ(2) = π²/6. Les résultats non réels sont rejetés "
          "(le complexe haute précision est un chemin distinct).",
    ],
    'cevalf': [
      "Dans CrispMath, `cevalf` utilise `basic_evalf` de SymEngine sur le "
          "chemin MPC (complexe). (1+i)¹⁰ = 32i. L'unité imaginaire est le "
          "littéral `I`.",
      "Là où `evalf` rejette un résultat non réel, `cevalf` renvoie la "
          "valeur complexe complète : √(−2) = i·√2.",
    ],
    'matrix_literal': [
      "Dans CrispMath, le littéral `Matrix(...)` est reconnu par "
          "l'évaluateur de matrices avant que le moteur ne voie l'expression. "
          "L'appel sous-jacent est le constructeur `DenseMatrix` de "
          "SymEngine — la disposition lignes/colonnes est fixée à la "
          "construction.",
      "Les cellules restent symboliques — les rationnels ne sont pas réduits "
          "en nombres à virgule flottante. Idem pour les symboles libres : "
          "`Matrix([[a, b], [c, d]])` est accepté et propagé via `det` / "
          "`inv` / `rref`.",
      "Les matrices non carrées conviennent à `transpose` et `rref` mais "
          "échouent pour `det` / `inv`, qui exigent une entrée carrée.",
    ],
    'det': [
      "Dans CrispMath, `det(M)` est évalué comme un scalaire unique. L'appel "
          "sous-jacent est le `DenseMatrix::det()` de SymEngine, qui utilise "
          "l'algorithme sans fraction de Bareiss — exact pour des entrées "
          "symboliques/rationnelles, sans explosion en virgule flottante.",
      "Exemple scolaire classique 3×3 — le développement de Laplace par "
          "cofacteurs donne le même résultat en 6 termes.",
      "Les entrées symboliques passent inchangées. Bareiss conserve le "
          "résultat sous forme d'`Add` SymEngine plutôt qu'un nombre à "
          "virgule flottante.",
    ],
    'inv': [
      "Dans CrispMath, `inv(M)` renvoie `adj(M)/det(M)`. L'appel sous-jacent "
          "est le `DenseMatrix::inv()` de SymEngine, qui utilise "
          "l'élimination de Gauss-Jordan sur les rationnels — les entrées "
          "reviennent en fractions exactes, pas en nombres à virgule "
          "flottante.",
      "La matrice identité est sa propre inverse — un test rapide de bon "
          "fonctionnement confirmant que le pont fait l'aller-retour "
          "correctement.",
      "Une entrée singulière (det = 0) provoque une erreur propre plutôt que "
          "de renvoyer de grands nombres absurdes. La puce d'erreur apparaît "
          "dans l'historique de la calculatrice.",
    ],
    'transpose': [
      "Dans CrispMath, `transpose(M)` est implémenté côté Dart car le pont "
          "n'expose pas de point d'entrée de transposition. Nous allouons une "
          "nouvelle `SymEngineMatrix` aux dimensions échangées et copions les "
          "cellules une à une.",
      "Entrée rectangulaire : une 2×3 devient une 3×2 — utile pour les "
          "dispositions de données appariées.",
      "Idempotente après deux applications. Vérifie que l'échange des "
          "cellules laisse le contenu symbolique intact.",
    ],
    'rref': [
      "Dans CrispMath, `rref` exécute Gauss-Jordan en Dart et appelle le "
          "`simplify()` de SymEngine à chaque mise à jour de cellule. Le pont "
          "n'expose pas `rref` directement, donc l'algorithme parcourt les "
          "colonnes de gauche à droite, met à l'échelle la ligne de pivot, "
          "puis élimine la colonne au-dessus et en dessous.",
      "Entrée de rang déficient : la seconde ligne se réduit à des zéros. "
          "Utile pour repérer visuellement une dépendance linéaire.",
      "La mise à l'échelle du pivot normalise les entrées de tête à 1. La "
          "détection symbolique des valeurs non nulles est le point "
          "sensible — voir la note d'algorithme dans `matrix_evaluator.dart`.",
    ],
    'matrix_arithmetic': [
      "Dans CrispMath, les opérations binaires sur matrices sont prises en "
          "charge par l'évaluateur de matrices lorsque les deux opérandes se "
          "lisent comme des littéraux `Matrix(...)`. L'appel sous-jacent est "
          "`add_dense_dense` de SymEngine ; la soustraction passe par "
          "`add_dense_dense` avec une négation terme à terme du membre de "
          "droite.",
      "La multiplication est le produit scalaire ligne par colonne habituel "
          "via `mul_dense_dense` de SymEngine. La multiplication à droite par "
          "l'identité est un test de bon fonctionnement.",
      "La soustraction est terme à terme ; une discordance de dimensions "
          "échoue proprement avec `Error: matrix - failed: …`.",
    ],
    'eigenvalues': [
      "Matrice 2×2 symétrique — solution en forme close via le polynôme "
          "caractéristique. Les valeurs propres sont toujours réelles pour "
          "les matrices symétriques.",
      "La matrice identité a toutes ses valeurs propres égales à 1.",
      "Matrice de rotation — les valeurs propres sont des paires conjuguées "
          "complexes ±i. L'algorithme QR traite les blocs 2×2 de Schur réels.",
    ],
    'eigenvectors': [
      "Pour les matrices 2×2 à valeurs propres réelles, les vecteurs propres "
          "sont calculés via le noyau de (A − λI). Pour les matrices plus "
          "grandes ou les valeurs propres complexes, seules les valeurs propres "
          "sont renvoyées.",
    ],
    'mean': [
      "Dans CrispMath, `mean` est calculée par `DescriptiveStats.mean` (voir "
          "`lib/engine/statistics.dart`) — une somme en une passe / n. Pour "
          "des données appariées ou groupées, le module Statistiques expose "
          "aussi l'écart-type, la médiane, les quartiles et l'écart "
          "interquartile.",
      "Entrée à virgule flottante — l'implémentation accumule en `double`, "
          "si bien que des listes très grandes ou d'ordres de grandeur mêlés "
          "peuvent nécessiter un algorithme de sommation stable si vous "
          "voulez plus de 15 chiffres.",
    ],
    'one_sample_t': [
      "Dans CrispMath, `oneSampleT` se trouve dans "
          "`lib/engine/hypothesis_tests.dart`. L'appel sous-jacent calcule "
          "t = (x̄ − μ₀) / (s / √n), puis lit la valeur p bilatérale dans "
          "`TDistribution.cdf` avec df = n − 1.",
      "L'échantillon se situe nettement au-dessus de μ₀ = 70 ; le test rejette "
          "donc H₀ (moyenne = 70) au seuil α = 0,05. À comparer avec "
          "`paired_t`, un test t à un échantillon sur le vecteur des "
          "différences.",
    ],
    'welch_t': [
      "Dans CrispMath, `welchT` se trouve dans "
          "`lib/engine/hypothesis_tests.dart`. L'appel sous-jacent calcule la "
          "statistique de test t = (x̄_A − x̄_B) / √(s_A²/n_A + s_B²/n_B), "
          "approche ensuite les degrés de liberté via Welch-Satterthwaite, et "
          "lit la valeur p sur `TDistribution.cdf`.",
      "Cas à très petit échantillon — le ddl de Welch ≈ 4 bien que "
          "n_A + n_B = 6, car la loi t à deux échantillons tient compte de "
          "l'incertitude de l'estimation de la variance.",
    ],
    'paired_t': [
      "Dans CrispMath, `pairedT` se ramène à un test t à un échantillon sur "
          "le vecteur des différences d = après − avant. L'appel sous-jacent "
          "est la même voie `TDistribution.cdf` que `welchT`, mais avec "
          "ddl = n - 1 (pas de correction de Welch car il n'y a qu'une seule "
          "estimation de variance à faire).",
      "Cas limite : des décalages identiques produisent une variance nulle "
          "des différences, que l'implémentation présente comme la valeur "
          "limite p = 0 plutôt qu'un NaN.",
    ],
    'anova_1': [
      "Dans CrispMath, `anovaOneWay` partitionne la somme des carrés totale "
          "en somme des carrés inter-groupes et intra-groupes. L'appel "
          "sous-jacent est F = MS_inter / MS_intra avec ddl1 = K - 1 et "
          "ddl2 = N - K, puis `FDistribution.sf` pour la valeur p de la queue "
          "supérieure.",
      "Des dispersions égales et des moyennes bien séparées produisent un F "
          "élevé. On rejette H₀ (toutes les moyennes égales) au seuil "
          "α = 0,05.",
    ],
    'chi2_goodness': [
      "Dans CrispMath, `chiSquareGof` évalue Σ (O - E)² / E et lit la valeur "
          "p de la queue supérieure sur `ChiSquaredDistribution.sf` avec "
          "ddl = k - 1, où k est le nombre de catégories. On suppose les "
          "effectifs des cellules ≥ 5 — l'implémentation n'applique pas de "
          "correction de Yates automatique.",
      "Concordance parfaite → χ² = 0 → on ne rejette H₀ à aucun seuil α.",
    ],
    'chi2_independence': [
      "Dans CrispMath, `chiSquareIndependence` calcule les effectifs "
          "attendus à partir des marges ligne × colonne (E_ij = ligne_i · "
          "colonne_j / total), puis Σ (O - E)² / E avec "
          "ddl = (lignes - 1) · (colonnes - 1). La valeur p sous-jacente "
          "provient de `ChiSquaredDistribution.sf`.",
      "Forte concentration hors diagonale → faible valeur p. Pour les tables "
          "2×2 creuses, préférez `fisher_exact`, qui ne repose pas sur "
          "l'approximation du khi-deux pour grands échantillons.",
    ],
    'fisher_exact': [
      "Dans CrispMath, `fisherExact` énumère toutes les tables 2×2 ayant les "
          "mêmes marges et somme les probabilités hypergéométriques des "
          "tables au moins aussi extrêmes que l'observée. L'appel sous-jacent "
          "calcule des termes log-binomiaux pour éviter le dépassement sur de "
          "grands totaux, puis exponentie ; la valeur p bilatérale suit la "
          "convention de R (somme des probabilités de queue ≤ celle "
          "observée).",
      "Table symétrique → aucun indice d'association.",
    ],
    'wilcoxon': [
      "Dans CrispMath, `wilcoxonRankSum` réunit les deux échantillons, "
          "attribue des rangs corrigés par les rangs moyens, somme les rangs "
          "du groupe A et fournit le z de l'approximation normale. L'appel "
          "sous-jacent applique une correction de liaisons à la variance et "
          "lit la valeur p bilatérale sur la fonction de répartition normale.",
      "Cas à très petit échantillon — l'approximation normale est limite à "
          "n_A + n_B = 6. Pour de très petits échantillons, on préférera la "
          "loi de permutation exacte (pas encore livrée).",
    ],
    'sign_test': [
      "Dans CrispMath, `pairedSign` écarte les paires de différence nulle, "
          "compte les positives parmi les n restantes et teste contre une "
          "loi Binomiale(n, 0,5). La valeur p sous-jacente utilise la queue "
          "binomiale exacte — pas d'approximation normale, c'est donc le bon "
          "choix pour de très petits échantillons appariés.",
      "Une paire liée (4 → 4) est écartée, laissant n = 3 positives sur 3 "
          "paires informatives. La valeur p exacte bilatérale est "
          "2 · min(Binom(3, 0,5).cdf(3), …).",
    ],
    'linreg': [
      "Dans CrispMath, l'onglet « Régression » ajuste les données via les "
          "estimateurs des moindres carrés en forme close a = Sxy / Sxx et "
          "b = ȳ − a·x̄ (voir `lib/engine/statistics.dart`). Le même onglet "
          "propose aussi des modèles polynomial et exponentiel.",
      "Des points proches de y = 2x donnent une pente ≈ 2 et un R² proche de "
          "1 — un ajustement linéaire presque parfait.",
    ],
    'poly_fit': [
      'Le sélecteur de degré (2–5) de l\'onglet Régression fixe d ; un degré plus élevé épouse plus de courbure mais risque le surajustement. Basé sur Statistics.polynomialFit.',
    ],
    'exp_fit': [
      'Ajuste des données de croissance / décroissance ; régresse en interne ln(y) contre x, donc tous les y doivent être positifs. Basé sur Statistics.expFit.',
    ],
    'normal_dist': [
      "Dans CrispMath, l'onglet « Distributions » évalue la fonction de "
          "répartition de la loi normale via la fonction d'erreur "
          "(`Normal.cdf` dans `lib/engine/statistics.dart`) ; x = μ + 2σ se "
          "situe au ≈ 97,7ᵉ centile.",
      "Le quantile 0,95 est la fonction de répartition inverse — la valeur "
          "en dessous de laquelle se trouve 95 % de la masse (≈ μ + 1,645σ). "
          "Va de pair avec `erf`, qui sous-tend la fonction de répartition.",
    ],
    'binomial_dist': [
      "Dans CrispMath, l'onglet « Distributions » évalue la fonction de masse "
          "binomiale C(n, k)·pᵏ·(1−p)^(n−k) (`Binomial.pmf` dans "
          "`lib/engine/statistics.dart`) ; avec un taux de défaut de 10 % sur "
          "20 articles, le nombre de défauts le plus probable est la moyenne, "
          "2.",
      "La fonction de répartition somme la fonction de masse de 0 à k. Ici "
          "≈ 68 % des lots présentent au plus deux défauts. La variance vaut "
          "n·p·(1−p) = 1,8, donc l'écart-type ≈ 1,34.",
    ],
    'vars': [
      "Dans CrispMath, la ligne `vars:` est analysée par `DslToFlatZinc` "
          "(voir `lib/engine/csp_solver.dart`) et émet une déclaration "
          "FlatZinc `var int: x :: …` par nom. Les bornes du domaine sont des "
          "entiers concrets ; les domaines symboliques ne sont pas pris en "
          "charge.",
      "Un domaine `0..1` modélise une variable booléenne. FlatZinc a un type "
          "`var bool` distinct — l'analyseur ne le détecte pas, mais le "
          "solveur traite l'entier 0/1 tout aussi efficacement.",
    ],
    'all_different': [
      "Dans CrispMath, `allDifferent` se traduit en "
          "`all_different_int([a, b, c])` de FlatZinc. Le solveur sous-jacent "
          "(dart_csp) implémente la propagation par cohérence de bornes via "
          "l'algorithme de couplage de Régin — bien plus rapide que le mode "
          "deux à deux sur de grandes listes d'arguments.",
      "Les modèles de Sudoku du module Sudoku reposent sur des piles de "
          "contraintes `allDifferent` — une par ligne, colonne, bloc et "
          "éventuelles zones de variante.",
    ],
    'no_overlap': [
      "Dans CrispMath, `noOverlap` se traduit en "
          "`disjunctive([s1, s2, s3], [4, 3, 2])` de FlatZinc. Le solveur "
          "sous-jacent utilise l'edge-finding plus le propagateur θ-tree de "
          "Vilím — le même algorithme que celui intégré à MiniZinc.",
      "Problème classique de séquencement sur une machine. Combinez avec "
          "`minimize` sur l'expression du makespan pour obtenir "
          "l'ordonnancement optimal. Voir l'exemple résolu pour le programme "
          "DSL complet.",
    ],
    'cumulative': [
      "Dans CrispMath, `cumulative` se traduit en "
          "`cumulative([starts], [durations], [resources], capacity)` de "
          "FlatZinc. Le solveur sous-jacent utilise la propagation par "
          "emploi du temps plus le raisonnement énergétique — des variantes "
          "tenant compte de la capacité des propagateurs de `noOverlap`.",
      "Le problème d'ordonnancement de projet à contraintes de ressources "
          "(RCPSP) empile plusieurs contraintes `cumulative`, une par type de "
          "ressource. Voir l'exemple résolu `dslRcpsp` pour un projet à deux "
          "ressources.",
    ],
    'minimize': [
      "Dans CrispMath, `minimize` émet `solve minimize __obj__;` de FlatZinc "
          "après avoir construit la variable objectif via l'analyse de "
          "l'expression linéaire. Le solveur sous-jacent utilise la "
          "séparation-évaluation — test de faisabilité, puis resserrement de "
          "la borne supérieure à chaque solution améliorante.",
      "Voir l'exemple résolu `dslCoinChange` — minimisez sur une somme de "
          "variables indicatrices pour trouver le plus petit ensemble de "
          "pièces totalisant la cible.",
    ],
    'maximize': [
      "Dans CrispMath, `maximize` émet `solve maximize __obj__;` de FlatZinc. "
          "Le solveur sous-jacent fait de la séparation-évaluation tout comme "
          "`minimize`, mais avec le resserrement de la borne inférieure "
          "inversé.",
      "Problème du sac à dos 0/1 classique. Le DSL le gère naturellement "
          "comme une déclaration `vars: x_1, ... in 0..1` plus une contrainte "
          "de capacité linéaire et un objectif linéaire.",
    ],
    'at_least': [
      'Les conditions peuvent viser n\'importe quelle valeur, pas seulement des booléens — `atLeast(1, a=3, b=5)` signifie a vaut 3 ou b vaut 5 (ou les deux).',
    ],
    'at_most': [
      'Combinez avec `atLeast` sur les mêmes conditions pour un nombre exact, ou utilisez directement `exactly`.',
    ],
    'exactly': [
      'Le cheval de bataille des grilles de logique — « exactement une personne possède le chat », « exactement deux maisons sont bleues », etc.',
    ],
    'implies': [
      'Des chaînes de `implies` encodent la logique des indices des énigmes d\'Einstein / du zèbre. Voir l\'exemple `logicGrid`.',
    ],
    'gcc': [
      'Incontournable des plannings et emplois du temps — fixez combien de fois chaque garde/valeur apparaît. Voir l\'exemple `nurseRostering`.',
    ],
    'among': [
      'Contraignez ou minimisez c pour contrôler combien de variables entrent dans une catégorie.',
    ],
    'nvalue': [
      'Avec des contraintes `!=` d\'adjacence de graphe, minimiser nvalue donne le nombre chromatique. Voir l\'exemple `chromaticNumber`.',
    ],
    'at_most_in_a_row': [
      'Encode des règles de fatigue / de motif que le simple comptage ne peut exprimer. L\'automate a un état par longueur de suite 0..max.',
    ],
    'value_precedence': [
      'Ajoutez-la à tout problème aux valeurs interchangeables pour retirer les k! doublons de renommage de l\'ensemble des solutions.',
    ],
    'table': [
      'Toute relation sans formule nette tient dans une table. Voir l\'exemple `menuPairing`.',
    ],
    'element': [
      'Combinez avec `minimize`/`maximize` sur la valeur consultée pour optimiser un choix parmi des coûts tabulés.',
    ],
    'diff_n': [
      'Les variables de coordonnées doivent être déclarées ; la largeur et la hauteur sont des littéraux entiers. La taille du conteneur est déduite des plages de coordonnées.',
    ],
    'circuit': [
      'Chaque variable successeur doit être déclarée avec un domaine couvrant 0..n-1. Ajoutez `; labels=…` pour nommer les nœuds dans le graphe ; utilisez `subcircuit` si certains nœuds peuvent être ignorés.',
    ],
    'soft': [
      'Le corps est une comparaison simple (`x = 5`, `x < 3`, `x = y`). Ne peut pas être combiné avec `minimize`/`maximize` — les deux sont des objectifs.',
    ],
    'set_var': [
      'Les éléments de l\'univers sont des entiers. Ne peut pas être combiné avec `minimize`/`maximize` ni `soft(…)`. Les membres s\'affichent en puces.',
    ],
    'dot': [
      'Le produit scalaire vaut |a||b|cos θ — nul exactement quand les vecteurs sont orthogonaux.',
    ],
    'cross': [
      'Règle de la main droite : x × y = z. Défini seulement pour les vecteurs 3D.',
    ],
    'norm': [
      'Le triangle 3-4-5. `norm` est la magnitude par laquelle `unit` divise.',
    ],
    'unit': [
      'Normaliser conserve la direction, jette la magnitude — indéfini pour le vecteur nul.',
    ],
    'mod': [
      'Se combine avec `modpow` / `modinv` pour l\'arithmétique modulaire ; `a mod n` vaut `a − n·⌊a/n⌋`.',
    ],
    'nth_root': [
      'La racine cubique de 27. Pour n = 2, utilisez la touche √ dédiée ; `ⁿ√x` couvre tout degré.',
    ],
    'sin': [
      'Période 2π, image [-1, 1]. La calculatrice interprète l\'argument en radians.',
    ],
    'cos': [
      'Période 2π, image [-1, 1] ; cos est sin décalé de π/2.',
    ],
    'tan': [
      'Période π ; indéfinie là où cos(x)=0 (x = π/2 + kπ).',
    ],
    'asin': [
      'Domaine [-1, 1], image principale [-π/2, π/2].',
    ],
    'acos': [
      'Domaine [-1, 1], image principale [0, π].',
    ],
    'atan': [
      'Domaine tous réels, image principale (-π/2, π/2).',
    ],
    'sinh': [
      'Fonction impaire, non bornée ; la famille des chaînettes.',
    ],
    'cosh': [
      'Fonction paire, minimum 1 en x=0 ; forme d\'une chaîne suspendue.',
    ],
    'tanh': [
      'Impaire, image (-1, 1) ; fonction d\'activation courante en réseaux de neurones.',
    ],
    'asinh': [
      'Domaine tous réels ; asinh(x) = ln(x + √(x²+1)).',
    ],
    'acosh': [
      'Domaine x ≥ 1 ; acosh(x) = ln(x + √(x²−1)).',
    ],
    'atanh': [
      'Domaine (-1, 1) ; atanh(x) = ½·ln((1+x)/(1−x)).',
    ],
    'ln': [
      'Réciproque de exp ; domaine x > 0. ln(e) = 1.',
    ],
    'log': [
      'Domaine x > 0. Pour d\'autres bases : ln(x)/ln(b).',
    ],
    'exp': [
      'Réciproque de ln ; toujours positive, sa propre dérivée.',
    ],
    'abs': [
      'abs(x) = √(x²) ; pour a+bi renvoie √(a²+b²).',
    ],
    'sqrt': [
      'sqrt(x) = x^(1/2). Pour d\'autres degrés, la touche ⁿ√x.',
    ],
    'pi': [
      'Pour π à un nombre de chiffres choisi, la touche π(N) (pi_precision).',
    ],
    'imaginary_unit': [
      'Les résultats complexes reviennent en termes de I — p. ex. solve(x² + 1 = 0) → x = ±i.',
    ],
    'euler_gamma': [
      'Insère EulerGamma ; pour γ à un nombre de chiffres choisi, la touche γ(N) (eulergamma_precision).',
    ],
    'infinity': [
      'Insère le symbole ∞ ; à combiner avec `lim` ou `∫` pour un comportement limite / impropre.',
    ],
    'sudoku_regular': [
      "Dans CrispMath, la variante classique se trouve dans "
          "`lib/engine/sudoku.dart` sous `SudokuVariant.regular`. Le solveur "
          "sous-jacent instancie une contrainte `allDifferent` par ligne, "
          "colonne et bloc (27 au total pour le 9×9) et les confie à "
          "`dart_csp`.",
    ],
    'sudoku_x': [
      "Dans CrispMath, le Sudoku-X est `SudokuVariant.x` "
          "(`lib/engine/sudoku.dart`). Le solveur sous-jacent ajoute deux "
          "contraintes `allDifferent` supplémentaires au trio classique "
          "ligne/colonne/bloc — une par diagonale.",
    ],
    'sudoku_disjoint': [
      "Dans CrispMath, c'est `SudokuVariant.disjoint`. Pour une grille N×N "
          "avec des blocs √N × √N, la contrainte ajoute N recouvrements "
          "`allDifferent` de plus — un par position dans le bloc. Le 8×8 est "
          "livré comme un modèle unique.",
    ],
    'sudoku_killer': [
      "Dans CrispMath, c'est `SudokuVariant.killer`. Le solveur sous-jacent "
          "superpose au trio classique ligne/colonne/bloc une contrainte "
          "`allDifferent` par cage et une contrainte `somme = cible` par "
          "cage. Les modèles killer 4×4 et 9×9 sont tous deux livrés.",
    ],
    'eq_op': [
      'Abaissé vers Eq(2, 2) de SymEngine et simplifié en True.',
      'Symbolique — reste sous forme d\'équation quand x est libre.',
    ],
    'ne_op': [
      'Abaissé vers Ne(3, 4) de SymEngine.',
      'Des valeurs égales donnent false.',
    ],
    'lt_op': [
      'Abaissé vers Lt(2, 5) de SymEngine.',
      'Pas strictement inférieur — utilisez <= pour non-strict.',
    ],
    'le_op': [
      'Abaissé vers Le(5, 5) de SymEngine.',
      'Strictement supérieur échoue au test.',
    ],
    'gt_op': [
      'Abaissé vers Gt(10, 3) de SymEngine.',
    ],
    'ge_op': [
      'Abaissé vers Ge(5, 5) de SymEngine.',
    ],
    'and_op': [
      'Les deux prédicats sont vrais → true.',
      'Un opérande faux → false.',
    ],
    'or_op': [
      'Un seul opérande vrai suffit.',
    ],
    'not_op': [
      '4 n\'est pas premier → not false → true.',
      'Inverse l\'égalité.',
    ],
    'xor_op': [
      'Les deux vrais → xor est false.',
      'Exactement un vrai → xor est true.',
    ],
    'if_cond': [
      '7 est premier → la condition est true → renvoie 100.',
      '2 n\'est pas > 5 → renvoie la branche else.',
    ],
  };

  @override
  String get settingsWorkedExamples => 'Bibliothèque d\'exemples résolus';
  @override
  String get settingsWorkedExamplesSubtitle =>
      'Désormais accessible aussi via l\'icône livre en haut de la '
      'Calculatrice et du Bloc-notes. Appuyez ici pour la bibliothèque '
      'complète.';
  @override
  String get functionRefTitle => 'Référence des fonctions';
  @override
  String get functionRefSearchHint => 'Rechercher des fonctions…';
  @override
  String get functionRefEmpty => 'Aucune fonction ne correspond à ce filtre.';
  @override
  String get functionRefSeeAlso => 'Voir aussi :';
  @override
  String get functionRefTryInCalculator => 'Essayer dans la Calculatrice';
  @override
  String get functionRefOpenModule => 'Ouvrir le module';
  @override
  String get functionRefSeeWorkedExample => 'Voir l\'exemple résolu';
  @override
  String get functionRefCatCas => 'CAS';
  @override
  String get functionRefCatNumberTheory => 'Théorie des nombres';
  @override
  String get functionRefCatPrecision => 'Haute précision';
  @override
  String get functionRefCatMatrix => 'Matrices';
  @override
  String get functionRefCatGraphing => 'Graphes';
  @override
  String get functionRefCatStatistics => 'Statistiques';
  @override
  String get functionRefCatConstraints => 'Contraintes';
  @override
  String get functionRefCatSudoku => 'Sudoku';
  @override
  String get functionRefCatUnits => 'Unités';
  @override
  String get functionRefCatLogic => 'Logique';
  @override
  String get settingsFunctionRef => 'Référence des fonctions';
  @override
  String get settingsFunctionRefSubtitle =>
      'Parcourez chaque fonction de CrispMath : signature, exemples, '
      'fonctions liées et un raccourci pour coller dans la Calculatrice.';

  @override
  String get importDataTitle => 'Importer les données';
  @override
  String get importDataSubtitle =>
      'Colle un JSON issu d\'un export précédent pour restaurer '
      'l\'historique, les variables, les fonctions et les réglages.';
  @override
  String get importDataWarning =>
      'Cela écrase l\'historique actuel, les variables et les fonctions '
      'graphiques. Pas d\'annulation — copie d\'abord l\'état actuel '
      'si tu veux le conserver.';
  @override
  String get importDataApply => 'Appliquer';
  @override
  String get importDataEmpty => 'Colle un JSON pour importer.';
  @override
  String get importDataNotObject =>
      'Le JSON doit être un objet (commence par `{`).';
  @override
  String get importDataApplied => 'Importé';
  @override
  String get settingsImportData => 'Importer les données';
  @override
  String get settingsImportDataSubtitle =>
      'Colle un JSON d\'un export précédent pour restaurer.';

  @override
  String get userFunctionsTitle => 'Fonctions personnalisées';
  @override
  String get userFunctionsHelp =>
      'Définis une fonction une fois, appelle-la depuis n\'importe quelle '
      'expression. Par ex. `f(x) = x^2 + 1`, alors `f(3) + 1` vaut 11. '
      'La composition `g(f(x))` fonctionne tant que les deux sont définies.';
  @override
  String get userFunctionsEmpty =>
      'Pas encore de fonctions personnalisées. Appuie sur Ajouter pour en '
      'créer une.';
  @override
  String get userFunctionsAdd => 'Ajouter';
  @override
  String get userFunctionsEdit => 'Modifier';
  @override
  String get userFunctionsDelete => 'Supprimer';
  @override
  String get userFunctionsName => 'Nom';
  @override
  String get userFunctionsNameHelp =>
      'Une seule lettre minuscule (a..z) qui n\'entre pas en conflit '
      'avec les noms intégrés.';
  @override
  String get userFunctionsNameRequired => 'Obligatoire';
  @override
  String get userFunctionsNameInvalid =>
      'Doit être une seule lettre minuscule (a..z).';
  @override
  String get userFunctionsParam => 'Paramètre';
  @override
  String get userFunctionsBody => 'Corps';
  @override
  String get userFunctionsBodyRequired => 'Corps de fonction requis';
  @override
  String get settingsUserFunctions => 'Fonctions personnalisées';
  @override
  String get settingsUserFunctionsSubtitle =>
      'Définis des fonctions nommées comme f(x) = x^2 + 1 et réutilise-les '
      'dans toute expression.';

  @override
  String get onboardingSkip => 'Passer';
  @override
  String get onboardingNext => 'Suivant';
  @override
  String get onboardingDone => 'Compris';
  @override
  String onboardingPage(int current, int total) => '$current / $total';
  @override
  String get onboardingKeypadTitle => 'Clavier à onglets';
  @override
  String get onboardingKeypadBody =>
      'Bascule entre les onglets Num, Trig, CAS et Avancé pour '
      'trouver l\'opération recherchée. Sur les écrans plus larges, '
      'tout le clavier tient en une seule vue — sans onglets.';
  @override
  String get onboardingHistoryTitle => 'Parcourir l\'historique';
  @override
  String get onboardingHistoryBody =>
      'Chaque calcul est enregistré. Fais défiler vers le haut pour '
      'le revoir, appuie longuement pour copier ou réutiliser, touche '
      'l\'icône de recherche pour filtrer.';
  @override
  String get onboardingFunctionsTitle => 'Choisir une fonction';
  @override
  String get onboardingFunctionsBody =>
      'Les boutons ∫⌄, d/dx⌄ et solve⌄ ouvrent des sélecteurs pas-à-pas '
      'qui détaillent la réponse règle par règle.';
  @override
  String get onboardingAnalysisTitle => 'Hub d\'analyse';
  @override
  String get onboardingAnalysisBody =>
      'Étude de fonction, plans, coniques, tracé 3D, statistiques et '
      'le convertisseur d\'unités sont tous dans l\'onglet Analyse.';
  @override
  String get onboardingNotepadTitle => 'Bloc-notes';
  @override
  String get onboardingNotepadBody =>
      'Écrivez des maths comme un document — une expression par ligne, '
      'résultats dans la colonne de droite. Définissez des variables '
      '(tax = 0.085), référencez les lignes précédentes et voyez tout '
      'se recalculer en direct.';
  @override
  String get onboardingWorksheetTitle =>
      'Une calculatrice qui se souvient';
  @override
  String get onboardingWorksheetBody =>
      'Commencez par une feuille de calcul : a = 3, f(x) = x² + a, f(4). Modifiez a et tous les résultats ainsi que le graphique lié se recalculent. Enregistrez un point de contrôle, comparez, restaurez et exportez toute la session.';
  @override
  String get onboardingTryWorksheet =>
      'Essayer une feuille de calcul interactive';
  @override
  String get analysisLabsTitle =>
      'Labo';
  @override
  String get analysisLabsSubtitle =>
      'Problèmes de contraintes, solveur de Sudoku et compositeur de scènes 3D';
  @override
  String get aboutOurApps =>
      'Nos apps';
  @override
  String get aboutOurAppsIntro =>
      'D\'autres apps du même développeur. Les apps dans TestFlight sont des bêtas gratuites : le lien installe d\'abord TestFlight d\'Apple.';
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
      'Bientôt disponible';
  @override
  String get aboutThisApp =>
      'cette app';
  @override
  String get settingsReplayTour => 'Revoir la visite guidée';
  @override
  String get settingsReplayTourSubtitle =>
      'Afficher à nouveau la visite de premier lancement la prochaine fois '
      'que tu ouvres l\'app.';

  @override
  String get helpTitle => 'Aide';
  @override
  String get helpFunctionsHeading => 'Fonctions prises en charge';
  @override
  String get helpMatrixHeading => 'Syntaxe matricielle';
  @override
  String get helpStepsHeading => 'Solutions pas-à-pas';
  @override
  String get helpMatrixBody =>
      'Saisissez des matrices avec `;` pour les lignes et `,` pour les cellules :\n\n    [1, 2; 3, 4]\n\nLa calculatrice convertit en `Matrix([[1, 2], [3, 4]])` en interne. Opérations : det, inv, transpose, rref, +, -, *.';
  @override
  String get helpStepsBody =>
      'Trois boutons du pavé CAS ouvrent des traces pas-à-pas :\n\n  • d/dx⌄ pour les étapes de dérivation\n  • solve⌄ pour la résolution d\'équations\n  • ∫⌄ pour l\'intégration indéfinie\n\nChaque vue montre la règle appliquée à chaque étape plus la réponse finale.';

  @override
  String get constantsTitle => 'Référence des constantes';
  @override
  String get constantsSearchHint => 'Rechercher par symbole, nom ou unité…';
  @override
  String get constantsNoMatches =>
      'Aucune constante ne correspond à ce filtre.';
  @override
  String get constantsAllCategory => 'Toutes';
  @override
  String get constantsCategoryMathematical => 'Mathématiques';
  @override
  String get constantsCategoryPhysical => 'Physique';
  @override
  String get constantsCategoryChemistry => 'Chimie';
  @override
  String get constantsCategoryAstronomy => 'Astronomie';
  @override
  String get constantsCopyValue => 'Copier la valeur';
  @override
  String constantsCopiedToast(String symbol) =>
      '$symbol copié dans le presse-papiers';
  @override
  String get settingsConstants => 'Référence des constantes';
  @override
  String get settingsConstantsSubtitle =>
      'Constantes physiques, mathématiques, chimiques et astronomiques.';

  @override
  String get tabNum => 'Num';
  @override
  String get tabTrig => 'Trig';
  @override
  String get tabCas => 'CAS';
  @override
  String get tabAdvanced => 'Avancé';
  @override
  String get tabVars => 'Variables';
  @override
  String get tabBasic => 'Base';
  @override
  String get tabSymbolic => 'Symbolique';

  @override
  String? stepNote(StepNote note) {
    final p = note.params;
    switch (note.key) {
      case 'startEquation':
        return 'Partons de l\'équation telle qu\'elle est donnée.';
      case 'moveRightSideOver':
        return 'Soustraire le membre de droite des deux côtés met '
            'l\'équation sous la forme standard `expression = 0`, ce qui '
            'permet d\'appliquer le solveur linéaire ou quadratique.';
      case 'noEqualsSign':
        return 'Pas de `=` dans l\'entrée ; on la traite comme '
            '${p['body']} = 0.';
      case 'doesNotDependOn':
        return 'L\'équation ne dépend pas de ${p['var']}.';
      case 'solveFallthroughSymbolic':
        return 'Pas de forme linéaire ou quadratique standard — la réponse '
            'est confiée au solveur symbolique.';
      case 'linearIdentifyCoefs':
        return 'Repérons le coefficient dominant et le terme constant — '
            'c\'est une équation linéaire.';
      case 'moveConstant':
        return 'Passe la constante de l\'autre côté.';
      case 'divideByCoef':
        return 'Divise les deux membres par le coefficient dominant pour '
            'isoler ${p['var']}.';
      case 'quadraticIdentifyCoefs':
        return 'Lis les trois coefficients sur le polynôme. On prend a à '
            'partir de la dérivée seconde ÷ 2, b à partir de la dérivée '
            'première en ${p['var']} = 0, et c à partir du polynôme en '
            '${p['var']} = 0.';
      case 'discriminant':
        return 'Le discriminant indique le nombre de racines réelles : '
            'positif → deux racines réelles distinctes ; nul → une racine '
            'double ; négatif → deux racines complexes conjuguées.';
      case 'quadFormulaApply':
        return 'Substitue a, b et Δ dans la formule quadratique. Le `±` '
            'donne les deux racines en une étape.';
      case 'integralPullMinusOut':
        return 'Sors le signe moins de l\'intégrale ; le reste est '
            'simplement ∫f.';
      case 'exprDoesNotDependOn':
        return '${p['expr']} ne dépend pas de ${p['var']}.';
      case 'integralIdentityPower1':
        return 'La règle des puissances pour n=1 : monte l\'exposant à 2 '
            'et divise par le nouvel exposant.';
      case 'integralLinearity':
        return 'L\'intégration est linéaire : l\'intégrale d\'une somme '
            'est la somme des intégrales.';
      case 'integralPullConstantOut':
        return 'Sors `${p['const']}` de l\'intégrale — les constantes se '
            'factorisent.';
      case 'integralReciprocalLog':
        return 'L\'intégrale de 1/${p['var']} est le logarithme naturel '
            'de sa valeur absolue.';
      case 'integralPowerRule':
        return 'Augmente l\'exposant de 1 et divise par le nouvel '
            'exposant. Valable pour toute constante n ≠ −1.';
      case 'uSubLinear':
        return 'Pose u = ${p['u']} ; alors du = '
            '(${p['slope']})·d${p['var']}.';
      case 'integralStandardAntideriv':
        return 'Utilise la primitive standard de ${p['fn']}.';
      case 'uSubLinearFn':
        return 'Pose u = ${p['u']} ; alors du = '
            '(${p['slope']})·d${p['var']}. La primitive de ${p['fn']} est '
            'la forme standard, évaluée en u et divisée par la pente.';
      case 'ibpLnX':
        final v = p['var']!;
        return 'Pose u = ln($v), dv = d$v. Alors du = (1/$v)·d$v et '
            'v = $v, donc ∫u·dv = u·v − ∫v·du = $v·ln($v) − ∫1 d$v.';
      case 'ibpXTimesF':
        return 'Pose u = ${p['var']} (donc du = d${p['var']}) et '
            'dv = ${p['right']}·d${p['var']}, ce qui donne v = ${p['v']}.';
      case 'ibpRepeated':
        return 'Pose u = ${p['u']} et dv = ${p['right']}·d${p['var']}. '
            'Alors du = ${p['n']}·… (une puissance de ${p['var']} en moins) '
            'et v = ${p['v']}, et la nouvelle intégrale perd une puissance '
            'de ${p['var']} — récursion.';
      case 'uSubNonlinear':
        return 'Pose u = ${p['u']} ; alors du = (${p['du']})·d${p['var']}. '
            'L\'intégrande a la forme f(u)·du, donc la substitution donne '
            '∫f(u) du = primitive standard de ${p['fn']} évaluée en u'
            '${p['ratio'] == '1' ? '.' : ', multipliée par le facteur constant ${p['ratio']}.'}';
      case 'integralLogDerivative':
        return 'Le numérateur vaut (${p['ratio']})·(d/d${p['var']}[${p['den']}]), '
            'donc l\'intégrale est ${p['ratio']}·ln|${p['den']}|.';
      case 'partialFractions':
        return 'Le dénominateur a des racines entières distinctes '
            '${p['roots']}. La méthode du masque donne '
            'A_i = P(r_i) / Q\'(r_i) pour chaque racine.';
      case 'partialFractionsIntegrate':
        return 'Chaque terme `A/(x-r)` s\'intègre en A·ln|x-r|.';
      case 'trigArctanForm':
        return 'Pose a² = ${p['aSq']}, donc a = ${p['a']}. La forme '
            'standard donne (1/a)·arctan(${p['var']}/a).';
      case 'trigArcsinForm':
        return 'Pose a² = ${p['aSq']}, donc a = ${p['a']}. La forme '
            'standard donne arcsin(${p['var']}/a).';
      case 'integralFallthroughSymbolic':
        return 'Aucune règle classique ne correspond à cette forme — la '
            'réponse est confiée à l\'intégrateur symbolique.';
      case 'diffIdentity':
        return 'La dérivée de ${p['var']} par rapport à elle-même vaut 1.';
      case 'diffSumDifference':
        return 'Dérive chaque terme séparément ; la dérivation se '
            'distribue sur `+` et `−`.';
      case 'diffQuotient':
        return 'Pour un quotient, le numérateur devient `f′g − fg′` et le '
            'dénominateur est mis au carré.';
      case 'diffProduct':
        return 'Pour un produit, dérive chaque facteur et additionne les '
            'morceaux — `(fg)′ = f′g + fg′`.';
      case 'diffPowerSimple':
        return 'Descends l\'exposant comme coefficient et diminue '
            'l\'exposant de 1.';
      case 'diffPowerChain':
        return 'Descends l\'exposant et diminue-le de 1, puis multiplie '
            'par la dérivée de la base — ce facteur '
            '`d/d${p['var']}[${p['base']}]` est la règle de la chaîne.';
      case 'diffExponential':
        return 'Quand la variable est en exposant, la dérivée est la même '
            'expression multipliée par `ln(base)` et par la dérivée de '
            'l\'exposant.';
      case 'diffStandardSimple':
        return 'Applique la dérivée standard de ${p['fn']}.';
      case 'diffStandardChain':
        return 'L\'argument dépend de ${p['var']}, donc multiplie par sa '
            'dérivée (règle de la chaîne).';
      case 'diffFallthrough':
        return 'Aucun motif de règle de plus haut niveau reconnu pour '
            'cette forme.';
    }
    return null;
  }
}

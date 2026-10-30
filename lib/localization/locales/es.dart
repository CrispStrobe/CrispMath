// lib/localization/locales/es.dart
//
// Spanish strings for [AppLocalizations].

part of '../app_localizations.dart';

class EsLocalizations implements AppLocalizations {
  const EsLocalizations();

  @override
  String get navCalculator => 'Calculadora';
  @override
  String get navNotepad => 'Notas';
  @override
  String get notepadDefaultDocName => 'Sin título';
  @override
  String get notepadAddLine => 'Añadir línea';
  @override
  String get notepadDeleteLine => 'Eliminar línea';
  @override
  String get notepadDocumentMenu => 'Menú del documento';
  @override
  String get notepadNewDocument => 'Nuevo documento';
  @override
  String get notepadOpenWelcomeSample => 'Abrir muestra de bienvenida';
  @override
  String get notepadRecalculateAll => 'Recalcular todo';
  @override
  String get notepadRename => 'Renombrar';
  @override
  String get notepadDuplicate => 'Duplicar';
  @override
  String get notepadCopyAsMarkdown => 'Copiar como Markdown';
  @override
  String get notepadDeleteDocument => 'Eliminar documento';
  @override
  String get notepadUndo => 'Deshacer';
  @override
  String get notepadLineDeleted => 'Línea eliminada';
  @override
  String notepadDocumentDeleted(String name) => 'Documento «$name» eliminado';
  @override
  String get notepadCopiedAsMarkdown => 'Copiado como Markdown';
  @override
  String get notepadCopyResult => 'Copiar resultado';
  @override
  String get notepadCopyAsLatex => 'Copiar como LaTeX';
  @override
  String get notepadCopiedResult => 'Resultado copiado';
  @override
  String get notepadCopiedAsLatex => 'Copiado como LaTeX';
  @override
  String get notepadEmptyTitle => 'Aún no hay documentos';
  @override
  String get notepadEmptyBody =>
      'Crea un nuevo documento o abre la muestra de bienvenida para empezar.';
  @override
  String notepadFreeVars(String names) => 'libre: $names';
  @override
  String notepadBlockedBy(String alias) => 'Bloqueado por $alias';
  @override
  String notepadCycle(String path) => 'Ciclo: $path';
  @override
  String notepadUnknownImport(String name) =>
      'Import desconocido: «$name» no está en las variables globales';
  @override
  String notepadInvalidImport(String name) =>
      'Nombre de import no válido: «$name»';
  @override
  String get notepadEmptyImportList => 'Lista de imports vacía';
  @override
  String notepadUseDirective(String code) => 'Directiva use: $code';
  @override
  String get notepadManageTitle => 'Gestionar notas';
  @override
  String get notepadManageNotepads => 'Gestionar notas…';
  @override
  String get notepadOpenDocument => 'Abrir';
  @override
  String get notepadOpenFile => 'Abrir archivo de hoja de cálculo';
  @override
  String get notepadSaveFile => 'Guardar archivo de hoja de cálculo';
  @override
  String get notepadFileSaved => 'Hoja de cálculo guardada';
  @override
  String get notepadFileOpenFailed => 'No se pudo abrir la hoja de cálculo';
  @override
  String get notepadFileSaveFailed => 'No se pudo guardar la hoja de cálculo';
  @override
  String get notepadExportAsJson => 'Exportar como JSON';
  @override
  String get notepadImportFromJson => 'Importar desde JSON';
  @override
  String get notepadImport => 'Importar';
  @override
  String get notepadImportJsonHint => 'Pega aquí una carga JSON de la nota…';
  @override
  String get notepadJsonCopied => 'JSON de la nota copiado al portapapeles';
  @override
  String notepadJsonImported(String name) => '«$name» importado';
  @override
  String get notepadJsonImportFailed =>
      'Importación fallida: la carga no es un JSON de nota válido';
  @override
  String get graphErrorEmpty => 'La función está vacía';
  @override
  String get graphErrorUnbalanced =>
      'Paréntesis o corchetes desequilibrados — la función no se puede graficar';
  @override
  String get graphErrorTrailingOperator =>
      'La función termina con un operador — añade el lado derecho';
  @override
  String get navGraphing => 'Gráficos';
  @override
  String get navFunctions => 'Funciones';
  @override
  String get navAnalysis => 'Análisis';
  @override
  String get navSettings => 'Ajustes';

  @override
  String get historyHere => 'El historial de cálculos aparecerá aquí.';
  @override
  String get historyLabel => 'Historial:';
  @override
  String get clearButton => 'C';
  @override
  String get clearHistory => 'Borrar historial';
  @override
  String get clearHistoryConfirm =>
      '¿Eliminar todas las entradas del historial de cálculos?';
  @override
  String get searchHistory => 'Buscar en el historial';
  @override
  String get searchHistoryHint => 'Filtrar historial…';
  @override
  String get historyNoMatches => 'No hay entradas coincidentes.';

  @override
  String get graphSampling => 'Actualizando gráfico';
  @override
  String get graphSamplingFailed => 'No se pudo actualizar el gráfico.';
  @override
  String get graphNoRealValues =>
      'No hay valores reales en este intervalo. Revisa la expresión o prueba otro intervalo.';
  @override
  String get graphRetry => 'Reintentar';
  @override
  String graphingTitle(int count) => 'Gráficos ($count funciones)';
  @override
  String functionAdded(int slot) => 'Función añadida a Y$slot';
  @override
  String functionRemoved(int slot) => 'Y$slot eliminada';
  @override
  String get allSlotsFull =>
      'Todas las posiciones de función están ocupadas. Borra una primero.';
  @override
  String get clearAllFunctions => 'Borrar todas las funciones';
  @override
  String get clearAllFunctionsConfirm =>
      '¿Seguro que quieres borrar todas las funciones representadas?';
  @override
  String get cancel => 'Cancelar';
  @override
  String get clearAll => 'Borrar todo';
  @override
  String get zoomIn => 'Acercar';
  @override
  String get zoomOut => 'Alejar';
  @override
  String get resetView => 'Restablecer vista';
  @override
  String get showKeypad => 'Mostrar teclado';
  @override
  String get hideKeypad => 'Ocultar teclado';
  @override
  String get showAnnotations => 'Mostrar raíces y extremos';
  @override
  String get hideAnnotations => 'Ocultar raíces y extremos';
  @override
  String get analyzeFunctions => 'Analizar funciones';
  @override
  String get selectFunctionToAnalyze => 'Selecciona la función a analizar';
  @override
  String get plotButton => 'Representar';
  @override
  String get enterFunctionPrompt =>
      'Escribe una función abajo para representarla.';

  @override
  String get analysisModulesTitle => 'Módulos de análisis';
  @override
  String get moduleCurveSketching => 'Estudio de funciones';
  @override
  String get moduleCurveSketchingSubtitle =>
      'Análisis completo de una función f(x)';
  @override
  String get modulePlanes => 'Planos';
  @override
  String get modulePlanesSubtitle =>
      'Analiza planos 3D en forma cartesiana o paramétrica';
  @override
  String get moduleConics => 'Cónicas';
  @override
  String get moduleConicsSubtitle =>
      'Clasifica Ax² + Bxy + Cy² + Dx + Ey + F = 0';
  @override
  String get moduleStatistics => 'Estadística';
  @override
  String get moduleStatisticsSubtitle =>
      'Estadística descriptiva, regresión lineal, distribuciones normal y binomial';
  @override
  String get module3DTitle => 'Gráfica 3D';
  @override
  String get module3DSubtitle =>
      'Representa z = f(x, y) como superficie rotable de alambre';
  @override
  String get module3DFunctionLabel => 'f(x, y)';
  @override
  String get module3DRangeLabel => 'Rango';
  @override
  String get module3DResample => 'Remuestrear cuadrícula';
  @override
  String get module3DTapPlot =>
      'Introduce una función de x e y y pulsa Representar.';

  // -- P9-A2 --
  @override
  String get module3DScene => 'Escena 3D';
  @override
  String get module3DSceneSubtitle =>
      'Renderiza varios objetos 3D juntos — planos, rectas, esferas, cuádricas';
  @override
  String get scene3DAddPlane => 'Añadir plano';
  @override
  String get scene3DEditPlane => 'Editar plano';
  @override
  String get scene3DEmpty =>
      'Arrastra para rotar · pellizca para hacer zoom · pulsa + para añadir un plano';
  @override
  String get scene3DPanelEmpty => 'Aún no hay objetos';
  @override
  String get scene3DObjectLabel => 'Etiqueta';
  @override
  String get scene3DColor => 'Color';
  @override
  String get scene3DAdd => 'Añadir';
  @override
  String get scene3DSave => 'Guardar';
  @override
  String get scene3DEdit => 'Editar';
  @override
  String get scene3DDelete => 'Eliminar';
  @override
  String get scene3DHide => 'Ocultar';
  @override
  String get scene3DShow => 'Mostrar';
  @override
  String get scene3DLabelRequired => 'Etiqueta requerida';
  @override
  String get scene3DCoefRequired => 'Requerido';
  @override
  String get scene3DCoefInvalid => 'Número no válido';
  @override
  String get scene3DPlaneZeroNormal =>
      'El vector normal (a, b, c) no puede ser cero';

  // -- P9-A3 --
  @override
  String get scene3DAddObject => 'Añadir objeto';
  @override
  String get scene3DAddLine => 'Añadir recta';
  @override
  String get scene3DEditLine => 'Editar recta';
  @override
  String get scene3DAddSphere => 'Añadir esfera';
  @override
  String get scene3DEditSphere => 'Editar esfera';
  @override
  String get scene3DLinePointDir => 'Punto + dirección';
  @override
  String get scene3DLineTwoPoints => 'Dos puntos';
  @override
  String get scene3DLinePoint => 'Punto';
  @override
  String get scene3DLineDirection => 'Dirección';
  @override
  String get scene3DLineFirstPoint => 'Primer punto';
  @override
  String get scene3DLineSecondPoint => 'Segundo punto';
  @override
  String get scene3DLineZeroDirection =>
      'El vector dirección no puede ser cero (o elige dos puntos distintos)';
  @override
  String get scene3DSphereCenter => 'Centro';
  @override
  String get scene3DSphereRadius => 'Radio';
  @override
  String get scene3DSpherePositiveRadius => 'El radio debe ser mayor que cero';

  // -- P9-A4 --
  @override
  String get scene3DIntersectionsEmpty =>
      'Añade dos o más objetos para ver sus intersecciones';
  @override
  String scene3DIntersectionsTitle(int n) =>
      n == 1 ? '1 intersección' : '$n intersecciones';
  @override
  String get intersectionPoint => 'Punto';
  @override
  String get intersectionTwoPoints => 'Dos puntos';
  @override
  String get intersectionLine => 'Recta';
  @override
  String get intersectionCircle => 'Círculo';
  @override
  String intersectionReason(String key) {
    switch (key) {
      case 'parallelPlanes':
        return 'Planos paralelos (sin intersección)';
      case 'coincidentPlanes':
        return 'Planos coincidentes';
      case 'lineParallelToPlane':
        return 'Recta paralela al plano (sin intersección)';
      case 'lineInPlane':
        return 'La recta está contenida en el plano';
      case 'sphereMissesPlane':
        return 'El plano no toca la esfera';
      case 'degeneratePlane':
        return 'Plano degenerado (vector normal cero)';
      case 'parallelLines':
        return 'Rectas paralelas (sin intersección)';
      case 'coincidentLines':
        return 'Rectas coincidentes';
      case 'skewLines':
        return 'Rectas alabeadas (no se encuentran)';
      case 'lineMissesSphere':
        return 'La recta no toca la esfera';
      case 'degenerateLine':
        return 'Recta degenerada (dirección cero)';
      case 'spheresApart':
        return 'Las esferas están demasiado separadas';
      case 'sphereInsideSphere':
        return 'Una esfera está contenida en la otra';
      case 'coincidentSpheres':
        return 'Esferas idénticas';
      case 'numericalFailure':
        return 'Caso numérico límite (prueba con otros valores)';
      // P9-A5b: plano × cuádrica → cónica.
      case 'circle':
        return 'Círculo';
      case 'ellipse':
        return 'Elipse';
      case 'parabola':
        return 'Parábola';
      case 'hyperbola':
        return 'Hipérbola';
      case 'degenerateConic':
        return 'Cónica degenerada (par de rectas o un punto)';
      case 'noConic':
        return 'El plano no toca la cuádrica';
      case 'planeOnQuadric':
        return 'El plano descansa sobre la cuádrica';
      default:
        return key;
    }
  }

  // -- P9-A5 --
  @override
  String get scene3DAddQuadric => 'Añadir cuádrica';
  @override
  String get scene3DEditQuadric => 'Editar cuádrica';
  @override
  String get scene3DQuadricKind => 'Tipo';
  @override
  String get scene3DQuadricSemiAxes => 'Semiejes';
  @override
  String get scene3DQuadricPositiveSemiAxes =>
      'Los semiejes deben ser positivos (a, b, c > 0)';
  @override
  String get quadricKindEllipsoid => 'Elipsoide';
  @override
  String get quadricKindCone => 'Cono elíptico';
  @override
  String get quadricKindCylinder => 'Cilindro elíptico';
  @override
  String get quadricKindParaboloid => 'Paraboloide elíptico';
  @override
  String get quadricKindHyperboloid1 => 'Hiperboloide (1 hoja)';
  @override
  String get quadricKindHyperboloid2 => 'Hiperboloide (2 hojas)';

  // -- P9-A5c.3 --
  @override
  String get conicOpenIn3DScene => 'Abrir en escena 3D';
  @override
  String get conicLiftNotAConic =>
      'No es una cónica — nada que elevar. Añade primero términos cuadráticos.';

  // -- P9-A6 --
  @override
  String get scene3DAddParametricSurface => 'Añadir superficie paramétrica';
  @override
  String get scene3DEditParametricSurface => 'Editar superficie paramétrica';
  @override
  String get scene3DAddParametricCurve => 'Añadir curva paramétrica';
  @override
  String get scene3DEditParametricCurve => 'Editar curva paramétrica';
  @override
  String get scene3DParametricSurface => 'Superficie paramétrica';
  @override
  String get scene3DParametricCurve => 'Curva paramétrica';

  @override
  String get moduleUnitConverterTitle => 'Conversor de unidades';
  @override
  String get moduleUnitConverterSubtitle =>
      'Convierte longitud, tiempo, masa, temperatura, velocidad, ángulo';
  @override
  String get sectionVariables => 'Variables';
  @override
  String get sectionGraphFunctions => 'Funciones gráficas';
  @override
  String get sectionMemorySlots => 'Espacios de memoria';
  @override
  String get funcCtxShowOnGraph => 'Mostrar en la gráfica';
  @override
  String get funcCtxAnalyze => 'Analizar (estudio de la función)';
  @override
  String get funcCtxDifferentiate => 'Derivar';
  @override
  String get funcCtxIntegrate => 'Integrar';
  @override
  String get funcCtxSolve => 'Resolver f(x) = 0';
  @override
  String get funcCtxCopy => 'Copiar expresión';
  @override
  String get funcEditorTitle => 'Editor de funciones (Y=)';
  @override
  String get funcEditorDone => 'Listo';
  @override
  String get funcEditorSelectFirst =>
      'Selecciona un campo de función para editar.';
  @override
  String get funcEditorAnalyzeTooltip => 'Analizar esta función';
  @override
  String get funcEditorGraphTooltip => 'Representar esta función';
  @override
  String get unitDimLength => 'Longitud';
  @override
  String get unitDimTime => 'Tiempo';
  @override
  String get unitDimMass => 'Masa';
  @override
  String get unitDimTemperature => 'Temperatura';
  @override
  String get unitDimVelocity => 'Velocidad';
  @override
  String get unitDimAngle => 'Ángulo';
  @override
  String get planeAnalysisTitle => 'Análisis de plano';
  @override
  String get planeRepCoordinate => 'Coordenadas';
  @override
  String get planeRepParametric => 'Paramétrica';
  @override
  String get buttonAnalyze => 'Analizar';
  @override
  String get buttonClassify => 'Clasificar';
  @override
  String get curveAnalysisEnterFunction =>
      'Introduce una función para analizar:';
  @override
  String get curveResultWarnings => 'Advertencias';
  @override
  String get curveResultDerivatives => 'Derivadas';
  @override
  String get curveResultKeyPoints => 'Puntos clave';
  @override
  String get curveResultYIntercept => 'Intersección con Y';
  @override
  String get curveResultRoots => 'Raíces';
  @override
  String get curveResultExtrema => 'Extremos (Mínimos/Máximos)';
  @override
  String get curveResultInflectionPoints => 'Puntos de inflexión';
  @override
  String get curveResultNoExtrema => 'No se encontraron extremos.';
  @override
  String get curveResultNoInflection =>
      'No se encontraron puntos de inflexión.';
  @override
  String curveAnalysisOfFunction(String function) =>
      'Análisis de f(x) = $function';
  @override
  String curveResultPointPrefix(String point) => 'Punto: $point';
  @override
  String get extremumLocalMinimum => 'Mínimo local';
  @override
  String get extremumLocalMaximum => 'Máximo local';
  @override
  String get extremumCriticalPoint => 'Punto crítico';
  @override
  String get extremumInflectionPoint => 'Punto de inflexión';
  @override
  String get extremumNoCriticalPoints => 'No se encontraron puntos críticos';
  @override
  String get extremumConstantConcavity =>
      'La función tiene concavidad constante (f\'\'(x) = 0 en todas partes)';
  @override
  String get statisticsTitle => 'Estadística';
  @override
  String get statsTabDescriptive => 'Descriptiva';
  @override
  String get statsTabRegression => 'Regresión';
  @override
  String get statsTabDistributions => 'Distribuciones';
  @override
  String get statsTabTests => 'Pruebas';
  @override
  String get statsDescCount => 'Conteo';
  @override
  String get statsDescSum => 'Suma';
  @override
  String get statsDescMean => 'Media';
  @override
  String get statsDescMedian => 'Mediana';
  @override
  String get statsDescMode => 'Moda';
  @override
  String get statsDescMin => 'Mín';
  @override
  String get statsDescMax => 'Máx';
  @override
  String get statsDescRange => 'Rango';
  @override
  String get statsDescVariance => 'Varianza';
  @override
  String get statsDescStddev => 'Desviación típica';
  @override
  String get statsDescQ1 => 'Q1';
  @override
  String get statsDescQ3 => 'Q3';
  @override
  String get statsDescIqr => 'RIQ';
  @override
  String get helpGroupProbability => 'Probabilidad';
  @override
  String get helpFnRrefDescription =>
      'Forma escalonada reducida (Gauss-Jordan)';

  @override
  String get settingsTitle => 'Ajustes';
  @override
  String get settingsNumberFormat => 'Formato numérico';
  @override
  String get settingsNumberFormatAuto => 'Auto (129; 129,5)';
  @override
  String settingsNumberFormatDecimalPlaces(int n) => 'Decimales: $n';
  @override
  String get settingsAutoBindSolve => 'Asignar soluciones automáticamente';
  @override
  String get settingsAutoBindSolveSubtitle =>
      'Si está activo, solve(ec, x) también asigna la solución a x.';
  @override
  String get settingsNumberFormatInteger => 'Entero (129)';
  @override
  String get settingsNumberFormatOneDecimal => 'Un decimal (129,0)';
  @override
  String get settingsNumberFormatTwoDecimal => 'Dos decimales (129,00)';
  @override
  String get settingsLanguage => 'Idioma';
  @override
  String get settingsLanguageEnglish => 'English';
  @override
  String get settingsLanguageGerman => 'Deutsch';
  @override
  String get settingsLanguageFrench => 'Français';
  @override
  String get settingsLanguageSpanish => 'Español';
  @override
  String get settingsTheme => 'Tema';
  @override
  String get settingsThemeSystem => 'Según el sistema';
  @override
  String get settingsThemeLight => 'Claro';
  @override
  String get settingsThemeDark => 'Oscuro';
  @override
  String get settingsLayoutTitle => 'Diseño';
  @override
  String get settingsLayoutBody =>
      'CrispMath se adapta al ancho de la ventana: navegación inferior en '
      'móviles, raíl lateral en tabletas y escritorio. A partir de ~760 px '
      'el teclado muestra todas las teclas sin pestañas.';

  @override
  String get aboutTitle => 'Acerca de CrispMath';
  @override
  String get aboutTagline => 'Calculadora CAS simbólica basada en SymEngine';
  @override
  String aboutVersion(String version) => 'Versión $version';
  @override
  String get aboutServiceProvider => 'Proveedor';
  @override
  String get aboutContact => 'Contacto';
  @override
  String get aboutPrivacy => 'Privacidad';
  @override
  String get aboutPrivacyText =>
      'CrispMath funciona íntegramente en el dispositivo. Ningún cálculo, '
      'entrada del historial o variable de usuario se envía a un servidor. '
      'La aplicación no recopila datos de telemetría ni contacta servicios '
      'remotos.';
  @override
  String get aboutDisclaimer => 'Aviso legal';
  @override
  String get aboutDisclaimerText =>
      'CrispMath se ofrece «tal cual», sin garantía alguna. El motor '
      'simbólico puede devolver resultados imprecisos para entradas '
      'numéricas mal condicionadas o expresiones simbólicas no '
      'soportadas. Verifica de forma independiente los cálculos críticos.';
  @override
  String get aboutLicense => 'Licencia';
  @override
  String get aboutLicenseText =>
      'CrispMath es software libre publicado bajo la GNU Affero General '
      'Public License versión 3 o posterior, con un permiso para tiendas '
      'de apps. Las bibliotecas GMP/MPFR/MPC/FLINT incluidas conservan sus '
      'propias licencias LGPL; los detalles de código fuente, build y '
      'relink están en Licencias de código abierto.';
  @override
  String get aboutOpenSourceLicenses => 'Licencias de código abierto';
  @override
  String get settingsAbout => 'Acerca de CrispMath';
  @override
  String get matrixDiagnosticsTitle => 'Autoprueba de matrices';
  @override
  String get matrixDiagnosticsSubtitle =>
      'Comprobar det / inv / transpose / + / * vía el puente nativo.';
  @override
  String matrixDiagnosticsSummary(int passed, int total) =>
      '$passed de $total comprobaciones superadas';
  @override
  String get unitConverterTitle => 'Conversor de unidades';
  @override
  String get unitConverterSubtitle =>
      'Longitud / tiempo / masa / temperatura / velocidad / ángulo.';

  @override
  String get selectEquation => 'Selecciona una ecuación o sigue escribiendo:';
  @override
  String get continueTyping => 'Continuar escribiendo';
  @override
  String get selectFunction => 'Selecciona una función o sigue escribiendo:';
  @override
  String get dismissPanel => 'Cerrar este panel';
  @override
  String solveFor(int n) => 'Resolver Y$n = 0';
  @override
  String whereY(int n, String func) => 'donde Y$n = $func';

  @override
  String get dialogInsert => 'Insertar';
  @override
  String get dialogClose => 'Cerrar';
  @override
  String get dialogShowSteps => 'Ver pasos';
  @override
  String get dialogVariable => 'Variable';
  @override
  String get dialogExpression => 'Expresión';
  @override
  String get dialogValue => 'Valor';
  @override
  String get dialogFunction => 'Función f(x)';

  @override
  String get integralTitle => 'Integral';
  @override
  String get integralLowerBound => 'Límite inferior';
  @override
  String get integralUpperBound => 'Límite superior';
  @override
  String get integralDefinite => 'Integral definida';
  @override
  String get nthRootTitle => 'Raíz n-ésima';
  @override
  String get nthRootBase => 'Base';
  @override
  String get limitTitle => 'Límite';
  @override
  String get limitApproaches => 'tiende a';
  @override
  String get substituteTitle => 'Sustituir';
  @override
  String get substituteUseStoredVariable =>
      'Usar una variable guardada como valor:';

  @override
  String get differentiationStepsTitle => 'Pasos de derivación';
  @override
  String differentiationStepsHeader(String variable) =>
      'Derivando respecto a $variable:';
  @override
  String get solveStepsTitle => 'Pasos de resolución';
  @override
  String get odeStepsTitle => 'Pasos de resolución de la EDO';
  @override
  String get solveStepsEquationLabel => 'Ecuación o expresión';
  @override
  String get solveStepsSolveFor => 'Resolver para';
  @override
  String get solveStepsHint => 'p. ej. 2x + 3 = 7  o  x^2 - 5x + 6';
  @override
  String solveStepsHeader(String variable) => 'Resolviendo para $variable:';
  @override
  String get integrationStepsTitle => 'Pasos de integración';
  @override
  String get integrationStepsIntegrandLabel => 'Integrando';
  @override
  String get integrationStepsWrt => 'Integrar respecto a';
  @override
  String get integrationStepsHint => 'p. ej. x^2  o  sin(x) + 2x';
  @override
  String integrationStepsHeader(String variable) =>
      'Integrando respecto a $variable:';

  @override
  String get errorSolveFormat =>
      'Error: el formato de solve() es solve(ecuación, variable)';
  @override
  String get errorInvalidSolve => 'Error: sintaxis de solve() inválida';
  @override
  String get errorInvalidDiff => 'Error: sintaxis de d/dx() inválida';
  @override
  String get errorInvalidFactor => 'Error: sintaxis de factor() inválida';
  @override
  String get errorInvalidExpand => 'Error: sintaxis de expand() inválida';
  @override
  String get errorInvalidSimplify => 'Error: sintaxis de simplify() inválida';
  @override
  String get errorGcdArgs => 'Error: gcd() requiere exactamente 2 argumentos';
  @override
  String get errorInvalidGcd => 'Error: sintaxis de gcd() inválida';
  @override
  String get errorLcmArgs => 'Error: lcm() requiere exactamente 2 argumentos';
  @override
  String get errorInvalidLcm => 'Error: sintaxis de lcm() inválida';

  @override
  String get errorParse =>
      'No se pudo analizar la expresión. Revisa paréntesis sin pareja, erratas u operadores ausentes.';
  @override
  String get errorUnbalancedParen =>
      'Hay un paréntesis de cierre sin su correspondiente apertura.';
  @override
  String get errorDivisionByZero => 'División por cero.';
  @override
  String errorUnknownFunction(String name) =>
      '\u0022$name\u0022 no es una función conocida. Revisa la ortografía.';
  @override
  String errorWrongArity(String name) =>
      '\u0022$name\u0022 recibió un número de argumentos incorrecto.';
  @override
  String get errorNativeRequired =>
      'Esta operación necesita la biblioteca matemática nativa, no cargada en esta plataforma.';
  @override
  String get errorNativeRequiredWeb =>
      'El cálculo simbólico (solve, factor, integrate, …) necesita la app de escritorio o móvil — no disponible en el navegador.';
  @override
  String get webBannerCasLoading =>
      'Cargando el motor simbólico en el navegador… solve, factor e integrate estarán disponibles en cuanto termine.';
  @override
  String get webBannerCasPartial =>
      'El CAS simbólico completo —incluidas las funciones de alta precisión y teoría de números (isprime, factorint, evalf, Bessel)— funciona aquí, en tu navegador. Solo la factorización multivariada sigue necesitando la app de escritorio o móvil.';
  @override
  String get webBannerCasUnavailable =>
      'Versión navegador: el CAS simbólico, la alta precisión y la teoría de números necesitan la app de escritorio o móvil. La estadística, matrices, Sudoku/CSP, unidades y la calculadora funcionan aquí.';
  @override
  String get webDownloadApp => 'Obtener la app';
  @override
  String get errorIntegrateNotImplemented =>
      'La integración simbólica no está disponible en esta versión. Usa ∫ con límites para un resultado numérico (definido).';
  @override
  String get errorMatrixLiteral =>
      'El literal de matriz no es válido. Usa el formato [a,b; c,d] o el editor de matrices.';
  @override
  String get errorInternalMatrixDisposed =>
      'La referencia interna a la matriz ya no es válida. Vuelve a ejecutar la operación.';
  @override
  String errorInvalidSyntax(String op) =>
      'Los argumentos pasados a $op() no tenían el formato esperado. Consulta el ejemplo en la ayuda / Acerca de.';

  @override
  String get exportDataTitle => 'Exportar datos';
  @override
  String get exportDataSubtitle =>
      'El JSON de abajo contiene todo lo que CrispMath ha guardado en este dispositivo: historial, variables, funciones, parámetros, ajustes. Cópialo a una nota o documento en la nube antes de reinstalar.';
  @override
  String get exportDataCopy => 'Copiar al portapapeles';
  @override
  String get exportDataCopied => 'Copiado al portapapeles';
  @override
  String get historyEntryCopyResult => 'Copiar resultado';
  @override
  String get historyEntryCopyLatex => 'Copiar como LaTeX';
  @override
  String get historyEntryCopyLatexSubtitle =>
      'Pegar en Word/Notion/Markdown para matemáticas con formato';
  @override
  String get historyEntryReuse => 'Reutilizar expresión';
  @override
  String get historyEntryCopied => 'Copiado';

  // -- Round 91 --
  @override
  String get storeAsVariable => 'Guardar como variable';
  @override
  String get storeAsFunction => 'Guardar como función';
  @override
  String get storeVariableTitle => 'Guardar como variable';
  @override
  String get storeFunctionTitle => 'Guardar como función';
  @override
  String get storeNameLabel => 'Nombre';
  @override
  String get storeFunctionParamLabel => 'Parámetro';
  @override
  String get storeButton => 'Guardar';
  @override
  String get storeNameReserved => 'Nombre reservado por una función integrada';
  @override
  String storeSavedAs(String name) => 'Guardado como $name';

  // -- R91b --
  @override
  String storeOverwriteTitle(String name) => '¿Sobrescribir "$name"?';
  @override
  String storeOverwriteCurrent(String existing) => 'Actualmente: $existing';
  @override
  String get storeOverwriteConfirm => 'Sobrescribir';

  @override
  String get settingsExportData => 'Exportar datos';
  @override
  String get settingsExportDataSubtitle =>
      'Copia todo lo guardado en este dispositivo (historial, variables, ajustes).';
  @override
  String get settingsHelp => 'Ayuda y referencia de funciones';
  @override
  String get settingsHelpSubtitle =>
      'Funciones soportadas, sintaxis de matrices y disparadores paso a paso.';

  @override
  String get settingsHighContrast => 'Alto contraste';
  @override
  String get settingsHighContrastSubtitle =>
      'Colores y bordes más fuertes para accesibilidad.';
  @override
  String get settingsTextScale => 'Tamaño del texto';

  @override
  String get settingsExactIntegerMode => 'Modo entero exacto';
  @override
  String get settingsExactIntegerModeSubtitle =>
      'Mostrar la cadena completa de dígitos para resultados enteros de '
      'precisión arbitraria (p. ej. 100! = 158 dígitos). Desactivado: '
      'redondear a precisión double.';
  @override
  String exactIntegerBadge(int digits) => 'Entero exacto · $digits dígitos';
  @override
  String get exactIntegerTapToCopy => 'Toca para copiar';

  @override
  String get calculating => 'Calculando…';

  @override
  String get moduleSudokuTitle => 'Solucionador de Sudoku';
  @override
  String get moduleSudokuSubtitle =>
      'Mira cómo razona un solucionador: únicos, suposiciones y retroceso, paso a paso.';
  @override
  String get sudokuSolveButton => 'Resolver';
  @override
  String get sudokuClearCell => 'Borrar';
  @override
  String get sudokuClearToStart => 'Reiniciar';
  @override
  String get sudokuSolvedCorrectly => '¡Resuelto!';
  @override
  String get sudokuFilledWithErrors => 'Con errores';
  @override
  String get sudokuWinOverlayTapHint => 'Toca para cerrar';
  @override
  String get sudokuPresetLabelChooser => 'Cuadrícula';
  @override
  String get sudokuPresetCustom => 'Personalizada';
  @override
  String sudokuPresetLabel(String id) {
    switch (id) {
      case 'small4x4Easy':
        return '4×4 fácil';
      case 'small4x4Medium':
        return '4×4 medio';
      case 'small4x4Hard':
        return '4×4 difícil';
      case 'medium6x6':
        return '6×6 medio';
      case 'eight8x8':
        return '8×8 medio';
      case 'eight8x8X':
        return '8×8 Sudoku-X medio';
      case 'eight8x8Disjoint':
        return '8×8 Disjunto medio';
      case 'eight8x8Killer':
        return '8×8 Killer';
      case 'ten10x10':
        return '10×10 medio';
      case 'twelve12x12':
        return '12×12 medio';
      case 'fifteen15x15':
        return '15×15 medio';
      case 'standard9x9Easy':
        return '9×9 fácil';
      case 'standard9x9Medium':
        return '9×9 medio';
      case 'standard9x9Hard':
        return '9×9 difícil (AI Escargot)';
      case 'standard9x9XEasy':
        return '9×9 Sudoku-X fácil';
      case 'killer4x4':
        return '4×4 Killer';
      case 'killer9x9':
        return '9×9 Killer';
    }
    return id;
  }

  @override
  String get sudokuVisualizerHeader => 'Visualizador de búsqueda';
  @override
  String get sudokuPlay => 'Reproducir';
  @override
  String get sudokuPause => 'Pausa';
  @override
  String get sudokuRestart => 'Reiniciar';
  @override
  String get sudokuSpeedSlow => 'Lento';
  @override
  String get sudokuSpeedMed => 'Medio';
  @override
  String get sudokuSpeedFast => 'Rápido';
  @override
  String get sudokuGenerateButton => 'Generar';
  @override
  String get sudokuDifficultyEasy => 'Fácil';
  @override
  String get sudokuDifficultyMedium => 'Medio';
  @override
  String get sudokuDifficultyHard => 'Difícil';
  @override
  String get sudokuVariantRegular => 'Clásico';
  @override
  String get sudokuVariantX => 'Sudoku-X';
  @override
  String get sudokuVariantKiller => 'Killer';
  @override
  String get sudokuVariantDisjoint => 'Disjunto';
  @override
  String get sudokuCheckUnique => 'Comprobar unicidad';
  @override
  String get sudokuUniqueSolution => 'Solución única';
  @override
  String get sudokuMultipleSolutions => 'Varias soluciones';
  @override
  String get sudokuShowHints => 'Mostrar pistas';
  @override
  String get sudokuShowHintsSubtitle =>
      'Notas a lápiz: para cada casilla vacía, los dígitos aún no '
      'eliminados por fila, columna, bloque o diagonal.';
  @override
  String get sudokuHintLevelOff => 'Desactivado';
  @override
  String get sudokuHintLevelBasic => 'Básico';
  @override
  String get sudokuHintLevelAdvanced => 'Avanzado';
  @override
  String get sudokuHintLevelAdvancedHelp =>
      'El modo avanzado ejecuta el solver CSP completo en cada '
      'candidato, detectando también los singles ocultos y los pares '
      'desnudos. Más lento — tarda unos segundos en sudokus 9×9 '
      'difíciles.';
  @override
  String get sudokuHintLevelComputing => 'Calculando pistas avanzadas…';

  @override
  String sudokuConstraintRow(int row) => 'Fila $row';
  @override
  String sudokuConstraintCol(int col) => 'Columna $col';
  @override
  String sudokuConstraintBox(int box) => 'Bloque $box';
  @override
  String sudokuConstraintCage(int cage, int sum) => 'Jaula $cage (suma $sum)';
  @override
  String get sudokuConstraintMainDiagonal => 'Diagonal principal';
  @override
  String get sudokuConstraintAntiDiagonal => 'Antidiagonal';
  @override
  String sudokuConstraintDisjointGroup(int group) => 'Grupo disjunto $group';
  @override
  String sudokuStepStart(int clues) =>
      'Inicio: $clues pistas. Las anotaciones muestran los dígitos que '
      'cada celda vacía aún admite: un dígito se descarta cuando una '
      'celda de la misma fila, columna o caja ya lo contiene.';
  @override
  String sudokuStepNakedSingle(String cell, int value, int eliminated) =>
      'Único desnudo: $cell solo tiene un candidato, así que es $value. '
      'Eso elimina $value de $eliminated celdas vecinas.';
  @override
  String sudokuStepHiddenSingle(String unit, int value, String cell) =>
      'Único oculto: en $unit, $value solo cabe en $cell, aunque $cell '
      'tenga otros candidatos.';
  @override
  String sudokuStepGuess(String cell, int value, String alternatives) =>
      'No queda ningún paso lógico, así que el solucionador supone. '
      'Elige $cell '
      'porque tiene menos candidatos, prueba $value y guarda '
      '$alternatives para retroceder.';
  @override
  String sudokuStepLastOption(String cell, int value) =>
      'Última opción: las demás opciones para $cell fallaron, así que es '
      '$value (según las suposiciones anteriores).';
  @override
  String sudokuStepContradictionCell(String cell) =>
      'Contradicción: $cell no tiene candidatos.';
  @override
  String sudokuStepContradictionUnit(String unit, int value) =>
      'Contradicción: $value no tiene sitio en $unit.';
  @override
  String sudokuStepBacktrack(String cell) =>
      'Retroceso: deshacer todo desde la suposición en $cell y probar su '
      'siguiente opción.';
  @override
  String get sudokuStepSolved =>
      'Resuelto: todas las celdas están llenas y se cumplen todas las '
      'reglas.';
  @override
  String sudokuExplainStats(
          int naked, int hidden, int guesses, int backtracks, int depth) =>
      'Únicos desnudos $naked · Únicos ocultos $hidden · Suposiciones '
      '$guesses · Retrocesos $backtracks · Profundidad máx. $depth';
  @override
  String get sudokuExplainLogicOnly =>
      'Resuelto solo con lógica: no hizo falta suponer.';
  @override
  String sudokuExplainTruncated(int shown) =>
      'Se muestran los primeros $shown pasos; la resolución continuó.';
  @override
  String sudokuStepCage(int sum, int size, String combos, int removed) =>
      'Suma de jaula: $size celdas deben sumar $sum con dígitos distintos. '
      'Los conjuntos posibles de dígitos son $combos. Sus asignaciones a las '
      'celdas que cumplen las restricciones muestran que $removed candidatos '
      'no pueden usarse en sus respectivas celdas y se eliminan.';
  @override
  String sudokuStepLocked(int digit, String unit, String other, int removed) =>
      'Candidatos bloqueados: en $unit, $digit solo cabe en celdas que '
      'también pertenecen a $other. Caiga donde caiga, $other tendrá allí '
      'su $digit, así que $digit se elimina de otras $removed celdas de '
      '$other.';
  @override
  String sudokuStepNakedSubset(
          int size, String cells, String digits, String unit, int removed) =>
      '${size == 2 ? 'Par' : 'Trío'} desnudo: $cells en $unit solo '
      'contienen $digits, así que esos dígitos van en estas $size celdas y '
      'se eliminan del resto de $unit ($removed candidatos).';
  @override
  String sudokuStepHiddenSubset(
          int size, String digits, String unit, String cells, int removed) =>
      '${size == 2 ? 'Par' : 'Trío'} oculto: en $unit, $digits solo caben '
      'en $cells, así que esas celdas los toman y pierden sus otros '
      'candidatos ($removed eliminados).';
  @override
  String sudokuStepContradictionCage(int sum) =>
      'Contradicción: la jaula de $sum ya no puede alcanzar su suma.';
  @override
  String sudokuExplainEliminations(
          int cages, int locked, int nakedSubsets, int hiddenSubsets) =>
      'Sumas de jaula $cages · Candidatos bloqueados $locked · Pares/tríos '
      'desnudos $nakedSubsets · Pares/tríos ocultos $hiddenSubsets';
  @override
  String get sudokuSearchTreeTitle => 'Árbol de búsqueda';
  @override
  String get sudokuSearchTreeHint =>
      'Cada punto es una suposición y sus hijos son suposiciones '
      'posteriores. Los puntos rojos llevaron a una contradicción, los '
      'verdes son el camino a la solución. El punto con anillo es la '
      'suposición vigente en el paso actual.';
  @override
  String sudokuSearchTreeTruncated(int shown) =>
      'Se muestran las primeras $shown suposiciones.';
  @override
  String get sudokuStepPrevious => 'Paso anterior';
  @override
  String get sudokuStepNext => 'Paso siguiente';
  @override
  String get sudokuEnterClues =>
      'Introducir pistas: toca una celda y luego un dígito para analizar '
      'tu propio sudoku.';
  @override
  String get sudokuConstraintStartingPosition => 'Posición inicial';

  @override
  String get moduleConstraintsTitle => 'Problemas de restricciones';
  @override
  String get moduleConstraintsSubtitle =>
      'Ecuaciones diofánticas y criptoaritmos — encontrar soluciones '
      'enteras y asignaciones de dígitos.';
  @override
  String get constraintsTabDiophantine => 'Diofántico';
  @override
  String get constraintsTabCryptarithm => 'Criptoaritmo';
  @override
  String get constraintsTabDsl => 'Texto libre';
  @override
  String get constraintsTabFlatZinc => 'FlatZinc';
  @override
  String get constraintsTabMagicSquare => 'Cuadrado mágico';
  @override
  String get constraintsMagicIntro =>
      'Genera un cuadrado mágico del orden elegido: los números 1..N² '
      'dispuestos de modo que cada fila, cada columna y ambas diagonales '
      'tengan la misma suma. Cada «Generar» muestra una orientación '
      'distinta de una solución.';
  @override
  String get constraintsMagicSize => 'Tamaño';
  @override
  String constraintsMagicConstant(int m) => 'Constante mágica: $m';
  @override
  String constraintsSoftScore(int satisfied, int total) =>
      'Satisfacción: $satisfied / $total';
  @override
  String get constraintsMagicGenerate => 'Generar';
  @override
  String get constraintsMagicHint =>
      'Cada fila, columna y diagonal suma la constante mágica.';
  @override
  String get constraintsDslIntro =>
      'Declare variables con `vars: x, y in 1..9`, '
      'use `allDifferent(x, y, z)` para distinción, '
      'y escriba cualquier otra línea como restricción '
      '(p. ej. `x + 2*y == 10`).';
  @override
  String get constraintsDslInputLabel => 'Programa de restricciones';
  @override
  String get constraintsDslExamplesButton => 'Ejemplos';
  @override
  String get constraintsDslExamplesTooltip => 'Cargar un ejemplo prediseñado';
  @override
  String constraintsDslExampleTitle(String id) {
    switch (id) {
      case 'magicSum':
        return 'Suma mágica de 3 dígitos';
      case 'magicSquare3':
        return 'Cuadrado mágico 3×3';
      case 'magicSquare4':
        return 'Cuadrado mágico 4×4 (constante 34)';
      case 'mapColoring':
        return 'Coloración de mapa (K4)';
      case 'mapColoringAustralia':
        return 'Coloración de mapa — Australia (3 colores)';
      case 'mapColoringGermany':
        return 'Coloración de mapa — Alemania (requiere 4 colores)';
      case 'orderedTriples':
        return 'Tripletes ordenados que suman 20';
      case 'equalSumSplit':
        return 'Partición de suma igual';
      case 'coinChangeMin':
        return 'Cambio de monedas (minimizar piezas)';
      case 'knapsack':
        return 'Mochila 0/1 (maximizar el valor)';
      case 'productionPlanning':
        return 'Planificación de producción (maximizar el beneficio)';
      case 'assignmentMinCost':
        return 'Problema de asignación (minimizar el coste)';
      case 'transportation':
        return 'Problema de transporte (coste mínimo)';
      case 'schedulingMakespan':
        return 'Planificación — minimizar el makespan';
      case 'cumulativeScheduling':
        return 'Planificación acumulativa — capacidad 2';
      case 'rcpsp':
        return 'RCPSP — equipo + equipamiento';
      case 'logicGrid':
        return 'Rejilla lógica — deducción';
      case 'nurseRostering':
        return 'Turnos de enfermería (patrones)';
      case 'chromaticNumber':
        return 'Número cromático (menos colores)';
      case 'menuPairing':
        return 'Combinaciones de menú (tabla)';
      case 'packing':
        return 'Empaquetado 2D (disposición diffN)';
      case 'deliveryRoute':
        return 'Ruta de reparto (circuit / TSP)';
      case 'shiftPrefs':
        return 'Preferencias de turno (soft / MaxCSP)';
      case 'committee':
        return 'Selección de comité (variables de conjunto)';
    }
    return id;
  }

  @override
  String get constraintsFlatZincIntro =>
      'Pegue un modelo FlatZinc (típicamente generado por mzn2fzn '
      'a partir de una fuente MiniZinc). El solver devuelve la '
      'salida estándar FlatZinc: líneas `nombre = valor;` por cada '
      'anotación `:: output_var`, terminadas con `----------`, '
      'seguidas de `==========` tras la última solución.';
  @override
  String get constraintsFlatZincInputLabel => 'Código fuente FlatZinc';
  @override
  String get constraintsFlatZincAllSolutions => 'Todas las soluciones';
  @override
  String get constraintsFlatZincFirstSolution => 'Primera solución';
  @override
  String get constraintsFlatZincExhaustiveOne => '1 solución (exhaustivo)';
  @override
  String constraintsFlatZincExhaustiveN(int n) => '$n soluciones (exhaustivo)';
  @override
  String get constraintsFlatZincUnsatisfiable => 'Insatisfacible';
  @override
  String constraintsFlatZincExampleTitle(String id) {
    switch (id) {
      case 'nqueens4':
        return '4 reinas';
      case 'binPacking':
        return 'Bin packing (3 objetos, 2 cajas)';
    }
    return id;
  }

  @override
  String get constraintsExplainFailure => 'Explicar el fallo';
  @override
  String get constraintsExplainHeader => 'Conflicto mínimo (QuickXplain)';
  @override
  String get constraintsExplainSatisfiable =>
      'Sin conflicto — el modelo es en realidad satisfacible.';
  @override
  String constraintsExplainEntryCount(int n) =>
      n == 1 ? '1 restricción en conflicto' : '$n restricciones en conflicto';
  @override
  String constraintsExplainAltHeader(int n) =>
      'Otro conflicto mínimo ($n restricciones)';
  @override
  String get constraintsExportFlatZinc => 'Exportar como FlatZinc';
  @override
  String get constraintsVisualizeButton => 'Visualizar';
  @override
  String get constraintsCompareStrategies => 'Comparar estrategias';
  @override
  String get constraintsStrategyHeader =>
      'Comparación de estrategias de búsqueda';
  @override
  String get constraintsStrategyCol => 'Estrategia';
  @override
  String get constraintsStrategyDecisions => 'Decisiones';
  @override
  String get constraintsStrategyBacktracks => 'Retrocesos';
  @override
  String get constraintsStrategyPropagations => 'Propagaciones';
  @override
  String get constraintsStrategyIterations => 'Iteraciones';
  @override
  String get constraintsStrategyTime => 'Tiempo';
  @override
  String get constraintsStructureButton => 'Mostrar estructura';
  @override
  String constraintsStructureHeader(int vars, int constraints) =>
      'Red de restricciones · $vars variables · $constraints restricciones';
  @override
  String constraintsColorGraphHeader(int nodes, int colours) =>
      'Coloración de grafo · $nodes nodos · $colours colores';
  @override
  String get constraintsTraceHeader => 'Traza de propagación';
  @override
  String get constraintsTraceIntro =>
      'Recorre el solucionador paso a paso: cada decisión, cada valor '
      'eliminado de un dominio por una restricción, cada callejón sin '
      'salida y cada retroceso.';
  @override
  String constraintsTraceStepCounter(int current, int total) =>
      'Paso $current / $total';
  @override
  String get constraintsTraceInitial =>
      'Dominios iniciales — antes de toda búsqueda.';
  @override
  String constraintsTraceDecision(String variable, int value) =>
      'Decisión: probar $variable = $value';
  @override
  String constraintsTracePrune(String values, String variable, String cause) =>
      'Eliminar $values de $variable — $cause';
  @override
  String constraintsTraceWipeout(String variable, String cause) =>
      'Callejón sin salida: dominio de $variable vaciado — $cause';
  @override
  String get constraintsTraceBacktrack =>
      'Retroceso — deshacer la última decisión y probar otro valor.';
  @override
  String constraintsTraceBackjump(int from, int to) =>
      'Salto atrás de la profundidad $from a la profundidad $to.';
  @override
  String get constraintsTraceSolutionStep =>
      'Solución — todas las variables asignadas.';
  @override
  String constraintsTraceStats(
          int decisions, int prunes, int wipeouts, int backtracks) =>
      'Decisiones $decisions · Podas $prunes · Callejones sin salida '
      '$wipeouts · Retrocesos $backtracks';
  @override
  String get constraintsTracePropagationOnly =>
      'Resuelto solo por propagación: no hizo falta decidir.';
  @override
  String get constraintsTraceTopConstraints =>
      'Restricciones que eliminaron más valores:';
  @override
  String constraintsTraceConstraintWork(
          int removed, int prunes, int wipeouts) =>
      '$removed valores · $prunes podas · $wipeouts callejones sin salida';
  @override
  String get constraintsMagicVisualizeHint =>
      'Visualizar reproduce cómo el solucionador construye un cuadrado: qué '
      'celda fija, qué podan las sumas y la regla todos-distintos, y dónde '
      'retrocede. Disponible para 3×3 y 4×4.';
  @override
  String get constraintsTraceSolved => 'Resuelto';
  @override
  String get constraintsTraceUnsat =>
      'Sin solución — espacio de búsqueda agotado';
  @override
  String constraintsTraceTruncatedNote(int n) =>
      'Traza limitada a $n pasos — la reproducción es un prefijo parcial.';
  @override
  String get constraintsTraceObjectiveNote =>
      'Se muestra la búsqueda de factibilidad; el objetivo se ignora.';
  @override
  String get constraintsTracePlay => 'Reproducir';
  @override
  String get constraintsTracePause => 'Pausa';
  @override
  String get constraintsTraceRestart => 'Reiniciar';
  @override
  String get constraintsTraceStepBack => 'Paso atrás';
  @override
  String get constraintsTraceStepForward => 'Paso adelante';
  @override
  String get constraintsExportedHeader => 'Traducción FlatZinc';

  @override
  String get constraintsDiophantineIntro =>
      'Declara variables enteras acotadas, lista las restricciones a '
      'satisfacer — el solver enumera todas las soluciones enteras '
      '(limitado a 100).';
  @override
  String get constraintsCryptarithmIntro =>
      'Introduce un puzzle de la forma `PALABRA1 + PALABRA2 = '
      'PALABRA3` (o `−` en vez de `+`). Cada letra es un dígito 0..9; '
      'los dígitos de cabecera no son cero; todas las letras llevan '
      'dígitos distintos.';
  @override
  String get constraintsVariablesLabel => 'Variables';
  @override
  String get constraintsVariablesHint =>
      'Una por línea, formato: name in min..max';
  @override
  String get constraintsConstraintsLabel => 'Restricciones';
  @override
  String get constraintsConstraintsHint =>
      'Una por línea. Comparaciones, aritmética, in/not-in conjuntos '
      'todos soportados.';
  @override
  String get constraintsCryptarithmInputLabel => 'Puzzle';
  @override
  String get constraintsSolveButton => 'Resolver';
  @override
  String get constraintsCancelButton => 'Cancelar';
  @override
  String get constraintsBadVarLine =>
      'No se pudo analizar la línea de variable. Esperado: '
      '`name in min..max`';
  @override
  String get constraintsNoSolutions => 'Sin soluciones.';
  @override
  String get constraintsCryptarithmFoundHeader => 'Asignación de dígitos';
  @override
  String constraintsSolutionsHeader(int n) =>
      n == 1 ? '1 solución' : '$n soluciones';
  @override
  String constraintsTruncatedHeader(int n) =>
      'Mostrando las primeras $n soluciones (existen más)';
  @override
  String get constraintsCopyResult => 'Copiar soluciones';
  @override
  String get constraintsCopiedToast => 'Copiado al portapapeles.';
  @override
  String constraintsOptimalHeader(num objective) =>
      'Óptimo: objetivo = $objective';

  @override
  String get clearSearchTooltip => 'Borrar búsqueda';
  @override
  String get clearFunctionSlotTooltip => 'Borrar función';
  @override
  String get deleteMemorySlotTooltip => 'Eliminar espacio de memoria';

  @override
  String get helpModeEnableTooltip =>
      'Modo ayuda: toca cualquier control para ver una explicación';
  @override
  String get helpModeDisableTooltip => 'Salir del modo ayuda';
  @override
  String get keypadHelpLearnMore => 'Más información';
  @override
  String get historyHelpTitle => 'Cómo se calculó esto';
  @override
  String historyHelpComputedVia(String engine) => 'Calculado mediante $engine';
  @override
  String get historyHelpDirectEvaluation =>
      'Evaluación numérica directa — sin llamada simbólica.';
  @override
  String get historyHelpShowSteps => 'Mostrar pasos';

  @override
  String get moduleHelpTooltip => '¿Qué hace este módulo?';
  @override
  String moduleHelpTitle(ModuleHelpKind kind) {
    switch (kind) {
      case ModuleHelpKind.curveSketching:
        return 'Estudio de curvas';
      case ModuleHelpKind.planes:
        return 'Análisis de planos';
      case ModuleHelpKind.conicSections:
        return 'Cónicas';
      case ModuleHelpKind.statistics:
        return 'Estadística';
      case ModuleHelpKind.graphing3D:
        return 'Gráficos 3D';
      case ModuleHelpKind.scene3D:
        return 'Escena 3D';
      case ModuleHelpKind.constraints:
        return 'Restricciones';
      case ModuleHelpKind.sudoku:
        return 'Sudoku';
      case ModuleHelpKind.notepad:
        return 'Bloc de notas';
    }
  }

  @override
  String moduleHelpDescription(ModuleHelpKind kind) {
    switch (kind) {
      case ModuleHelpKind.curveSketching:
        return 'Análisis completo de una función de una variable f(x): '
            'dominio, intersecciones, derivada y puntos críticos, '
            'extremos, puntos de inflexión, asíntotas y un croquis. '
            'Introduce la función en el cuadro de entrada; los '
            'resultados aparecen al tocar.';
      case ModuleHelpKind.planes:
        return 'Analiza planos 3D dados en forma cartesiana '
            '(ax + by + cz = d) o paramétrica (punto + dos vectores '
            'directores). Calcula el vector normal, las intersecciones '
            'con los ejes y las relaciones entre planos.';
      case ModuleHelpKind.conicSections:
        return 'Clasifica una cónica general '
            'Ax² + Bxy + Cy² + Dx + Ey + F = 0 como elipse, hipérbola, '
            'parábola o degenerada, y obtiene centro, ejes, focos y '
            'excentricidad. Usa el discriminante B² − 4AC para la '
            'clasificación.';
      case ModuleHelpKind.statistics:
        return 'Estadística descriptiva (media, mediana, varianza, …), '
            'regresión lineal con R² y residuos, distribuciones normal '
            'y binomial con PDF / CDF / cuantiles, y pruebas de '
            'hipótesis: t de Welch, t pareada, ANOVA de un factor, '
            'chi-cuadrado de bondad de ajuste e independencia, prueba '
            'exacta de Fisher, prueba de los rangos con signo de '
            'Wilcoxon y prueba de signos. Las pruebas devuelven el '
            'estadístico, el valor p y (si procede) un intervalo de '
            'confianza al α elegido.';
      case ModuleHelpKind.graphing3D:
        return 'Representa z = f(x, y) como una superficie alámbrica '
            'rotable. Arrastra para rotar; pellizca / desplaza para '
            'hacer zoom. La acción de remuestreo reconstruye la malla '
            'al nivel de zoom actual para que el detalle siga a la '
            'distancia de la cámara.';
      case ModuleHelpKind.scene3D:
        return 'Renderiza varios objetos 3D juntos — planos, rectas, '
            'esferas y cuádricas — en una escena compartida. Útil para '
            'visualizar intersecciones (por ejemplo dos planos que se '
            'encuentran en una recta) y para construir argumentos '
            'geométricos paso a paso.';
      case ModuleHelpKind.constraints:
        return 'Resuelve problemas combinatorios: ecuaciones '
            'diofánticas (soluciones enteras de ax + by = c), '
            'criptaritmos (estilo SEND + MORE = MONEY), un pequeño DSL '
            'de programación con restricciones de dominio finito '
            '(`allDifferent`, `noOverlap`, `cumulative`, `minimize` / '
            '`maximize`) y una pestaña FlatZinc para problemas '
            'escritos en el formato intermedio MiniZinc.';
      case ModuleHelpKind.sudoku:
        return 'Resuelve puzzles 4×4 y 9×9, incluidas las variantes '
            'X (diagonal), Killer (sumas de jaulas) y Disjoint-Groups. '
            'El solucionador paso a paso muestra el árbol de búsqueda, '
            'permitiendo ver cómo el motor reduce los candidatos. Los '
            'niveles de pista exponen la respuesta de la siguiente '
            'celda o una justificación lógica.';
      case ModuleHelpKind.notepad:
        return 'Un bloc de notas multidocumento donde cada línea es una fórmula viva, recalculada mientras escribes. Además de matemáticas ordinarias admite directivas: `use <documento>` importa las variables de otro documento; `fzn:` resuelve un modelo FlatZinc en línea; y `Ans in <unidad>` reutiliza el resultado de la línea anterior, con conversión de unidades opcional. Exporta a LaTeX o Markdown.';
    }
  }

  @override
  String get workedExamplesTitle => 'Ejemplos resueltos';
  @override
  String get workedExamplesSearchHint => 'Buscar ejemplos…';
  @override
  String get workedExamplesEmpty => 'Ningún ejemplo coincide con el filtro.';
  @override
  String get workedExamplesCopy => 'Copiar expresión';
  @override
  String get workedExamplesCopied =>
      'Copiado al portapapeles. Pega en la calculadora para probarlo.';
  @override
  String get workedExamplesInsert => 'Insertar en la calculadora';
  @override
  String get workedExamplesCatAll => 'Todos';
  @override
  String get workedExamplesCatCalculus => 'Cálculo';
  @override
  String get workedExamplesCatAlgebra => 'Álgebra';
  @override
  String get workedExamplesCatLinearAlgebra => 'Álgebra lineal';
  @override
  String get workedExamplesCatNumberTheory => 'Teoría de números';
  @override
  String get workedExamplesCatStatistics => 'Estadística';
  @override
  String get workedExamplesCatUnits => 'Unidades';
  @override
  String get workedExamplesCatConstraints => 'Restricciones';
  @override
  String? workedExampleTitle(String id) {
    switch (id) {
      case 'dsolveSecondOrder':
        return 'EDO lineal de segundo orden';
      case 'dsolveSeparable':
        return 'EDO separable de primer orden';
      case 'taylorSine':
        return 'Serie de Taylor del seno';
      case 'rationalLogIntegral':
        return 'Integral logarítmica (Rothstein–Trager)';
      case 'quadraticInequality':
        return 'Inecuación cuadrática';
      case 'piecewiseSelect':
        return 'Selección por tramos';
      case 'linsolveSystem':
        return 'Resolver un sistema lineal';
      case 'killerSudoku':
        return 'Killer Sudoku (9×9)';
      case 'constraintEditor':
        return 'Editor de restricciones libres';
      case 'dslMagicSquare':
        return 'Cuadrado mágico 3×3 (DSL)';
      case 'dslMapColoring':
        return 'Coloración de mapa K4 (DSL)';
      case 'dslOrderedTriples':
        return 'Tripletes ordenados que suman 20 (DSL)';
      case 'dslMapColoringAustralia':
        return 'Coloración de mapa — Australia, 3 colores (DSL)';
      case 'dslMapColoringGermany':
        return 'Coloración de mapa — Alemania, requiere 4 colores (DSL)';
      case 'dslKnapsack':
        return 'Mochila 0/1 — maximizar el valor (DSL)';
      case 'dslTransportation':
        return 'Problema de transporte — coste mínimo (DSL)';
      case 'dslCoinChange':
        return 'Cambio de monedas — minimizar piezas (DSL)';
      case 'dslSchedulingMakespan':
        return 'Planificación mono-máquina — minimizar el makespan (DSL)';
      case 'dslCumulativeScheduling':
        return 'Planificación paralela — cumulative (DSL)';
      case 'dslRcpsp':
        return 'Planificación de proyecto RCPSP — dos recursos (DSL)';
      case 'cryptSendMoreMoney':
        return 'Criptoaritmo — SEND + MORE = MONEY';
      case 'derivPoly':
        return 'Derivada de un polinomio';
      case 'chainRule':
        return 'Ejemplo de la regla de la cadena';
      case 'integralByParts':
        return 'Integral indefinida por partes';
      case 'definiteIntegral':
        return 'Integral definida';
      case 'sinxOverX':
        return 'Límite en una singularidad evitable';
      case 'partialFractions':
        return 'Fracciones parciales';
      case 'quadraticFormula':
        return 'Fórmula cuadrática';
      case 'factorCubic':
        return 'Factorizar un polinomio';
      case 'expandBinomial':
        return 'Desarrollar un binomio';
      case 'simplifyRational':
        return 'Simplificar una expresión racional';
      case 'polyGcdShared':
        return 'MCD de polinomios';
      case 'polyDiscriminantCubic':
        return 'Discriminante de un polinomio';
      case 'polyFactorMod':
        return 'Factorización módulo p';
      case 'matrixDet':
        return 'Determinante de una matriz';
      case 'matrixInverse':
        return 'Inversa de una matriz';
      case 'rref':
        return 'Forma escalonada reducida por filas';
      case 'factorial100':
        return 'Factorial — entero exacto';
      case 'fibonacci50':
        return 'Número de Fibonacci';
      case 'gcdEuclid':
        return 'MCD por Euclides';
      case 'isprime':
        return 'Test de primalidad (n pequeño)';
      case 'piPrecision':
        return 'π con 100 dígitos';
      case 'ePrecision':
        return 'e con 50 dígitos';
      case 'factorint360':
        return 'Factorización en primos';
      case 'nextprime1000':
        return 'Primo siguiente después de 1000';
      case 'mersenneM31':
        return 'Primo de Mersenne M31';
      case 'divisors12':
        return 'Todos los divisores';
      case 'eulerTotient':
        return 'Función φ de Euler';
      case 'modpowCrypto':
        return 'Exponenciación modular';
      case 'contFracPi':
        return 'Fracción continua de π';
      case 'zetaBasel':
        return 'Zeta de Riemann — el problema de Basilea';
      case 'gammaHalf':
        return 'Gamma en un semientero';
      case 'evalfLn10':
        return 'evalf de precisión arbitraria';
      case 'besselJZero':
        return 'Función de Bessel';
      case 'cevalfPow':
        return 'Alta precisión compleja';
      case 'booleanIsprimeAnd':
        return 'Primo y acotado';
      case 'booleanEqualityFold':
        return 'Evaluación de igualdad';
      case 'booleanNotPrime':
        return 'Negación';
      case 'booleanOrChain':
        return 'Disyunción sobre comparaciones';
      case 'booleanIfFold':
        return 'Evaluación condicional';
      case 'compoundInterest':
        return 'Interés compuesto';
      case 'zScore':
        return 'Consulta de puntuación Z';
      case 'statsHypothesisTests':
        return 'Espacio de pruebas de hipótesis';
      case 'statsWelchTwoSample':
        return 't de dos muestras de Welch (rellenado)';
      case 'statsAnovaThreeGroups':
        return 'ANOVA de un factor (rellenada)';
      case 'statsChiSquareGof':
        return 'Chi-cuadrado de bondad de ajuste (rellenado)';
      case 'unitConversion':
        return 'Conversión de unidades en línea';
      case 'compositeDim':
        return 'Aritmética con dimensiones compuestas';
    }
    return additionalWorkedExampleTitle('es', id);
  }

  @override
  String? workedExampleDescription(String id) {
    switch (id) {
      case 'dsolveSecondOrder':
        return 'y\'\' + 3y\' + 2y = 0 mediante las raíces características −1, −2.';
      case 'dsolveSeparable':
        return 'y\' = x·y se separa en ∫dy/y = ∫x dx → C·e^(x²/2).';
      case 'taylorSine':
        return 'sin(x) alrededor de 0 hasta 7 términos — potencias impares, (−1)^k/(2k+1)!.';
      case 'rationalLogIntegral':
        return '∫ (3x² + 1)/(x³ + x + 1) dx = log(x³ + x + 1) — el numerador es la derivada del denominador.';
      case 'quadraticInequality':
        return 'resolver x² − 4 > 0 → x < −2 ∨ x > 2 (análisis de signo entre las raíces).';
      case 'piecewiseSelect':
        return 'piecewise(cond, val, …) elige la primera rama verdadera — base de las funciones définies par morceaux.';
      case 'linsolveSystem':
        return 'x + y = 3, x − y = 1 → x = 2, y = 1 (linsolve simbólico exacto).';
      case 'killerSudoku':
        return 'Abre el módulo Sudoku precargado con la cuadrícula 9×9 Killer.';
      case 'constraintEditor':
        return 'Abre el módulo Restricciones — declara variables, agrega restricciones, resuelve.';
      case 'dslMagicSquare':
        return 'Carga el programa de 9 variables del cuadrado mágico en el editor DSL.';
      case 'dslMapColoring':
        return 'Carga una coloración K4 con 3 colores — intencionalmente infactible para mostrar la ruta «sin soluciones».';
      case 'dslOrderedTriples':
        return 'Carga un programa DSL que enumera (a, b, c) con a < b < c y a + b + c = 20.';
      case 'dslMapColoringAustralia':
        return 'Carga el mapa de Australia de 7 regiones (Russell & Norvig). Bastan tres colores; la solución se muestra como mapa coloreado.';
      case 'dslMapColoringGermany':
        return 'Carga los 16 Bundesländer de Alemania. A diferencia de Australia, este mapa necesita cuatro colores (una rueda de 5 en Turingia) — cambia el dominio a 1..3 para volverlo insatisfacible.';
      case 'dslKnapsack':
        return 'Carga una mochila 0/1 de cuatro objetos acotada por peso; `maximize` devuelve el subconjunto de valor óptimo.';
      case 'dslTransportation':
        return 'Carga un problema de transporte equilibrado (2 almacenes → 3 clientes, oferta = demanda); `minimize` devuelve el plan de envío de coste mínimo.';
      case 'dslCoinChange':
        return 'Carga un programa DSL que paga 17 ¢ con el menor número de monedas de {1, 5, 10, 25} mediante `minimize`.';
      case 'dslSchedulingMakespan':
        return 'Carga un programa DSL que planifica tres tareas (duraciones 4/3/2) en una máquina con `noOverlap` y minimiza el makespan.';
      case 'dslCumulativeScheduling':
        return 'Carga un programa DSL que planifica tres tareas sobre un recurso de capacidad 2 con `cumulative` y minimiza el makespan.';
      case 'dslRcpsp':
        return 'Carga un programa DSL con dos restricciones `cumulative` paralelas (equipo + equipamiento, capacidad 3 cada una) sobre cuatro tareas; minimiza el makespan.';
      case 'cryptSendMoreMoney':
        return 'Abre la pestaña Criptoaritmo con el puzle clásico: cada letra es un dígito distinto 0–9 (sin ceros a la izquierda). Solución única 9567 + 1085 = 10652.';
      case 'derivPoly':
        return 'd/dx de x³ − 4x + 7 en cualquier x.';
      case 'chainRule':
        return 'd/dx de sin(x²) — regla de la cadena sobre el x² interior.';
      case 'integralByParts':
        return '∫ x·sin(x) dx — toma u = x, dv = sin(x) dx.';
      case 'definiteIntegral':
        return '∫₀¹ x² dx = 1/3 por el teorema fundamental.';
      case 'sinxOverX':
        return 'lim x→0 sin(x)/x = 1 (el clásico).';
      case 'partialFractions':
        return '∫ 1/(x² − 1) dx por el método de cobertura en x = ±1.';
      case 'quadraticFormula':
        return 'Resuelve 2x² + 5x − 3 = 0 mediante el discriminante.';
      case 'factorCubic':
        return 'Factoriza x³ − 8 — suma/diferencia de cubos.';
      case 'expandBinomial':
        return 'Desarrolla (x + 2)⁵ — triángulo de Pascal.';
      case 'simplifyRational':
        return 'Reduce (x² − 4)/(x − 2) a su forma más simple.';
      case 'polyGcdShared':
        return 'polygcd(x² − 1, x² − 2x + 1) — el factor común x − 1.';
      case 'polyDiscriminantCubic':
        return 'polydiscriminant(x³ − 2) — distinto de cero ⇒ raíces '
            'distintas.';
      case 'polyFactorMod':
        return 'polyfactor(x⁴ + 1, mod=2) — irreducible sobre ℚ, '
            '(x + 1)⁴ sobre 𝔽₂.';
      case 'matrixDet':
        return 'det de una 3×3 — desarrollo de Laplace o reducción.';
      case 'matrixInverse':
        return 'Inversa de una 2×2 — A⁻¹ = adj(A)/det(A).';
      case 'rref':
        return 'rref de un sistema 2×3 aumentado.';
      case 'factorial100':
        return '100! — 158 dígitos, conservados en modo entero exacto.';
      case 'fibonacci50':
        return 'fib(50) — recurrencia hasta un término grande.';
      case 'gcdEuclid':
        return 'gcd(252, 105) — la recurrencia original.';
      case 'isprime':
        return 'isprime(2027) — división de prueba rápida.';
      case 'piPrecision':
        return 'pi(100) — constante de alta precisión vía MPFR.';
      case 'ePrecision':
        return 'e(50) — misma canalización MPFR que pi(N).';
      case 'factorint360':
        return 'factorint(360) → 2³ · 3² · 5 con superíndices Unicode.';
      case 'nextprime1000':
        return 'nextprime(1000) — respaldado por FLINT vía SymEngine ntheory.';
      case 'mersenneM31':
        return 'factorint(2^31 − 1) — confirma el octavo primo de '
            'Mersenne como factor único.';
      case 'divisors12':
        return 'divisors(12) → 1, 2, 3, 4, 6, 12 — derivado de la '
            'factorización en primos.';
      case 'eulerTotient':
        return 'totient(36) — cantidad de restos coprimos con 36.';
      case 'modpowCrypto':
        return 'modpow(2, 100, 1000000007) — el núcleo de RSA / '
            'Diffie-Hellman.';
      case 'contFracPi':
        return 'cfrac(pi, 10) — el desarrollo [3; 7, 15, 1, 292, …] '
            'detrás de 355/113.';
      case 'zetaBasel':
        return 'zeta(2) — el ζ(2) = π²/6 ≈ 1,6449 de Euler.';
      case 'gammaHalf':
        return 'gamma(0.5) — Γ(½) = √π ≈ 1,7725.';
      case 'evalfLn10':
        return 'evalf(ln(10), 50) — cualquier expresión con 50 cifras.';
      case 'besselJZero':
        return 'besselj(0, 1) — J₀(1) ≈ 0,7652, mediante MPFR. Dibuja '
            'besselj(0, x).';
      case 'cevalfPow':
        return 'cevalf((1+I)^10, 20) — (1+i)¹⁰ = 32i, mediante MPC.';
      case 'booleanIsprimeAnd':
        return 'isprime(17) y 17 < 20 — ambas cláusulas son verdaderas, '
            'así que la conjunción es verdadera.';
      case 'booleanEqualityFold':
        return '2 == 2 — operandos constantes se reducen a verdadero.';
      case 'booleanNotPrime':
        return 'not isprime(15) — 15 = 3·5, por lo que el resultado '
            'es verdadero.';
      case 'booleanOrChain':
        return '(5 > 3) o (1 == 2) — la primera cláusula es verdadera, '
            'así que la disyunción entera es verdadera.';
      case 'booleanIfFold':
        return 'if(isprime(7), 100, 200) — la condición se reduce a '
            'verdadero, por lo que gana la rama then.';
      case 'compoundInterest':
        return '1000 € al 5 % durante 10 años, capitalización anual.';
      case 'zScore':
        return 'Ve a la pantalla Estadística → Distribuciones para '
            'calcular Φ(1,96) ≈ 0,975.';
      case 'statsHypothesisTests':
        return 'Abre el módulo Estadística directamente en la pestaña '
            'Pruebas — t de una muestra, t de dos muestras (Welch), '
            'pareada, ANOVA, chi-cuadrado y Wilcoxon — con datos de '
            'ejemplo precargados.';
      case 'statsWelchTwoSample':
        return 'Abre la pestaña Pruebas en la t de dos muestras de Welch con '
            'dos grupos de varianzas desiguales ya introducidos.';
      case 'statsAnovaThreeGroups':
        return 'Abre la pestaña Pruebas en la ANOVA de un factor con tres '
            'grupos separados ya introducidos.';
      case 'statsChiSquareGof':
        return 'Abre la pestaña Pruebas en el chi-cuadrado de bondad de '
            'ajuste con frecuencias observadas ya introducidas frente a una '
            'distribución uniforme.';
      case 'unitConversion':
        return '100 km/h convertido a mph — analizador inline V2.';
      case 'compositeDim':
        return '100 m / 10 s da una velocidad en m/s — analizador V5.';
    }
    return additionalWorkedExampleDescription('es', id);
  }

  // Round 100: ES function-reference prose.
  @override
  String? functionRefDescription(String id) {
    switch (id) {
      case 'solve':
        return "Resuelve simbólicamente una ecuación para una variable; "
            "devuelve una lista de soluciones.";
      case 'expand':
        return "Desarrolla productos y potencias en una suma de monomios.";
      case 'simplify':
        return "Agrupa términos semejantes, cancela factores comunes y "
            "aplica las identidades algebraicas habituales.";
      case 'factor':
        return "Factoriza un polinomio sobre los racionales en factores "
            "irreducibles.";
      case 'diff':
        return "Derivada primera simbólica respecto a una variable.";
      case 'integrate':
        return "Integral indefinida (3 argumentos) o integral definida "
            "(5 argumentos) con respaldo numérico.";
      case 'subst':
        return "Sustituye cada aparición libre de `variable` en `expression` "
            "por `value`. También disponible como `substitute(...)`.";
      case 'limit':
        return "Límite numérico cuando `variable` tiende a `point`. `point` "
            "puede ser un valor finito o `oo` / `-oo`.";
      case 'gcd':
        return "Máximo común divisor (MCD) de dos enteros o polinomios.";
      case 'lcm':
        return "Mínimo común múltiplo (mcm) de dos enteros o polinomios.";
      case 'polygcd':
        return "Máximo común divisor mónico de dos polinomios de una variable "
            "sobre ℚ.";
      case 'polydiv':
        return "División polinómica de `p ÷ q` sobre ℚ. Devuelve el cociente "
            "y el resto.";
      case 'polyresultant':
        return "Resultante Res(p, q) — cero exactamente cuando `p` y `q` "
            "comparten un factor no constante.";
      case 'polydiscriminant':
        return "Discriminante de un polinomio de una variable (grado ≥ 1) — "
            "cero exactamente cuando `p` tiene una raíz múltiple.";
      case 'polyfactor':
        return "Factoriza un polinomio de una variable sobre el cuerpo finito "
            "𝔽ₖ (k primo) en factores irreducibles mónicos. Para factorizar "
            "sobre ℚ usa `factor`.";
      case 'gamma':
        return "La función Gamma Γ(x) — la extensión continua de (x − 1)! a "
            "los reales y al plano complejo.";
      case 'zeta':
        return "La función zeta de Riemann ζ(s) = Σ 1/nˢ y su prolongación "
            "analítica.";
      case 'erf':
        return "La función error erf(x) = (2/√π) ∫₀ˣ e^(−t²) dt — central "
            "para la distribución normal.";
      case 'lambertw':
        return "La función W de Lambert — la inversa de x·eˣ, tal que "
            "W(x)·e^(W(x)) = x.";
      case 'beta':
        return "La función Beta B(a, b) = Γ(a)·Γ(b) / Γ(a + b).";
      case 'besselj':
        return "Función de Bessel de primera especie Jₙ(x) — orden entero "
            "n, x real. Graficable.";
      case 'bessely':
        return "Función de Bessel de segunda especie Yₙ(x) (función de "
            "Weber) — orden entero n, x real > 0. Graficable.";
      case 'factorial':
        return "Factorial entero exacto. Los `n` pequeños usan el `BigInt` "
            "de Dart; los `n` grandes se delegan en SymEngine.";
      case 'fibonacci':
        return "n-ésimo número de Fibonacci. `fib(n)` es el alias corto.";
      case 'taylor':
        return "Polinomio de Taylor/Maclaurin de f en el punto de "
            "desarrollo x0 (0 por defecto), truncado tras n términos (6 por "
            "defecto). Series de SymEngine con FLINT; en nativo y en la web.";
      case 'linsolve':
        return "Resuelve un sistema de ecuaciones lineales simbólicamente "
            "(fracciones exactas/símbolos). Ecuaciones separadas por \";\", "
            "después las incógnitas. En nativo y en la web.";
      case 'dsolve':
        return "Resuelve una EDO exactamente. Segundo orden: lineal de "
            "coeficientes constantes (homogénea + coeficientes indeterminados). "
            "Primer orden: separable, lineal (factor integrante), Bernoulli "
            "y exacta (M dx + N dy = 0 con el potencial implícito "
            "F(x, y) = C1).";
      case 'isprime':
        return "Test de primalidad probabilístico sobre enteros.";
      case 'nextprime':
        return "El menor número primo estrictamente mayor que `n`.";
      case 'prevprime':
        return "El mayor número primo estrictamente menor que `n`. Error si "
            "no existe tal primo (p. ej. `prevprime(2)`).";
      case 'factorint':
        return "Factorización en primos con la forma `p₁^e₁ · p₂^e₂ · …` con "
            "exponentes en superíndice Unicode.";
      case 'divisors':
        return "Todos los divisores positivos de `n`, ordenados de menor a "
            "mayor y separados por comas.";
      case 'totient':
        return "Función φ de Euler φ(n): la cantidad de enteros en 1..n "
            "coprimos con `n`.";
      case 'modpow':
        return "Exponenciación modular `aᵉ mod m`. Un exponente negativo usa "
            "el inverso modular de `a` (cuando existe).";
      case 'modinv':
        return "Inverso modular `a⁻¹ mod m` mediante el algoritmo de Euclides "
            "extendido. Error cuando `mcd(a, m) ≠ 1`.";
      case 'jacobi':
        return "Símbolo de Jacobi (a/n) ∈ {−1, 0, 1} para `n` impar positivo; "
            "generaliza el símbolo de Legendre.";
      case 'cfrac':
        return "Desarrollo en fracción continua `[a₀; a₁, …]` de `x` con `n` "
            "términos. `x` puede ser `pi` / `e` / `EulerGamma` / `sqrt(2)`, "
            "un racional `p/q` o un decimal.";
      case 'convergent':
        return "El k-ésimo convergente `p/q` de la fracción continua de `x` — "
            "una mejor aproximación racional para el tamaño de su "
            "denominador.";
      case 'pi_precision':
        return "π con N cifras decimales mediante MPFR; devuelve la cadena "
            "de dígitos en bruto.";
      case 'e_precision':
        return "Número de Euler e con N cifras decimales mediante MPFR.";
      case 'sqrt_precision':
        return "Raíz cuadrada del entero `k` con N cifras decimales mediante "
            "MPFR. La forma de dos argumentos elige la vía de alta "
            "precisión.";
      case 'eulergamma_precision':
        return "Constante de Euler-Mascheroni γ ≈ 0,5772… con N cifras "
            "decimales mediante MPFR.";
      case 'evalf':
        return "Evalúa cualquier expresión real con N cifras decimales "
            "mediante MPFR — el valor numérico de precisión arbitraria de "
            "`expr`.";
      case 'cevalf':
        return "Evaluación compleja de precisión arbitraria — como `evalf` "
            "pero conserva la parte imaginaria, devolviendo `a + b·I` con N "
            "cifras mediante MPC.";
      case 'matrix_literal':
        return "Literal de matriz: una lista de filas, cada fila una lista "
            "de expresiones de celda. Las celdas pueden ser números, "
            "fracciones o simbólicas.";
      case 'det':
        return "Determinante de una matriz cuadrada. Devuelve un escalar "
            "simbólico.";
      case 'inv':
        return "Inversa de una matriz cuadrada no singular. Error cuando "
            "`det = 0`.";
      case 'transpose':
        return "Transpuesta: intercambia filas y columnas. Funciona con "
            "matrices rectangulares.";
      case 'rref':
        return "Forma escalonada reducida por filas mediante eliminación de "
            "Gauss-Jordan. Funciona sobre entradas simbólicas/racionales.";
      case 'matrix_arithmetic':
        return "Suma/resta elemento a elemento y multiplicación de matrices "
            "sobre literales `Matrix(...)`.";
      case 'eigenvalues':
        return "Valores propios de una matriz cuadrada numérica mediante el "
            "algoritmo QR. Devuelve también valores propios complejos.";
      case 'eigenvectors':
        return "Valores y vectores propios de una matriz cuadrada numérica. "
            "Vectores propios para matrices 2×2 con valores propios reales.";
      case 'mean':
        return "Media aritmética de una muestra como lista de números. "
            "Disponible en la pestaña «Estadística descriptiva» del módulo de "
            "Estadística, junto a los estadísticos habituales.";
      case 'one_sample_t':
        return "Prueba t para una muestra: ¿difiere la media muestral de una "
            "media poblacional supuesta μ₀? Da t, df = n−1 y un valor p "
            "bilateral.";
      case 'welch_t':
        return "Prueba t de dos muestras con varianzas desiguales "
            "(Welch-Satterthwaite). Opción robusta por defecto cuando los dos "
            "grupos pueden tener dispersiones distintas.";
      case 'paired_t':
        return "Prueba t para muestras pareadas sobre las diferencias "
            "intrasujeto frente a μ₀ = 0. Se usa cuando las mismas unidades "
            "se miden dos veces (antes/después).";
      case 'anova_1':
        return "Análisis de varianza (ANOVA) de un factor sobre K grupos "
            "independientes. Contrasta si difieren las medias de los grupos; "
            "da un estadístico F y un valor p.";
      case 'chi2_goodness':
        return "Prueba de bondad de ajuste chi-cuadrado: ¿los recuentos "
            "observados coinciden con una distribución supuesta?";
      case 'chi2_independence':
        return "Prueba de independencia chi-cuadrado sobre una tabla de "
            "contingencia: ¿son independientes dos variables categóricas?";
      case 'fisher_exact':
        return "Prueba exacta de Fisher sobre una tabla de contingencia 2×2. "
            "Valor p hipergeométrico exacto, sin aproximación para muestras "
            "grandes.";
      case 'wilcoxon':
        return "Prueba de suma de rangos de Wilcoxon / U de "
            "Mann-Whitney: prueba no paramétrica de dos muestras sobre "
            "rangos. Robusta ante datos no normales.";
      case 'sign_test':
        return "Prueba de los signos para muestras pareadas: prueba no "
            "paramétrica basada en la mediana de las diferencias pareadas. "
            "Cuenta cuántas veces `después > antes`.";
      case 'linreg':
        return "Regresión lineal por mínimos cuadrados y = a·x + b sobre datos "
            "pareados (x, y). Da la pendiente, la ordenada en el origen y el "
            "coeficiente de determinación R².";
      case 'normal_dist':
        return "Distribución normal (gaussiana) N(μ, σ): probabilidad "
            "acumulada P(X ≤ x) y el cuantil (función de distribución inversa) "
            "para una probabilidad p dada.";
      case 'binomial_dist':
        return "Distribución binomial B(n, p) sobre n ensayos independientes "
            "con probabilidad de éxito p: media n·p, varianza n·p·(1−p), la "
            "masa puntual P(X = k) y la acumulada P(X ≤ k).";
      case 'vars':
        return "Declara las variables de decisión enteras y su dominio. "
            "Siempre la primera línea de un programa DSL de CrispMath.";
      case 'all_different':
        return "Restricción global «todos los valores distintos dos a dos». "
            "La restricción estrella de PPC: propagación mucho más fuerte que "
            "n·(n-1)/2 cláusulas `!=` dos a dos.";
      case 'no_overlap':
        return "Planificación disyuntiva: tareas con variables de inicio "
            "dadas y duraciones fijas no pueden solaparse en el tiempo en una "
            "misma máquina.";
      case 'cumulative':
        return "Planificación acumulativa sobre un recurso renovable de "
            "capacidad fija. Cada tarea tiene una duración y una demanda de "
            "recurso propia.";
      case 'minimize':
        return "Objetivo: minimizar una expresión lineal sobre las variables "
            "de decisión. Combínalo con restricciones para resolver PSR de "
            "optimización.";
      case 'maximize':
        return "Objetivo: maximizar una expresión lineal. Imagen especular "
            "de `minimize`: la misma ramificación y acotación, en sentido "
            "opuesto.";
      case 'at_least':
        return 'Al menos k de las condiciones `nombre=valor` dadas deben cumplirse. Cada condición se reifica a booleano y su suma se acota inferiormente.';
      case 'poly_fit':
        return 'Regresión polinómica por mínimos cuadrados y = c₀ + c₁x + … + c_d·xᵈ de un grado d elegido sobre datos emparejados (x, y). Devuelve los coeficientes y R².';
      case 'exp_fit':
        return 'Regresión exponencial por mínimos cuadrados y = a·e^(b·x) sobre datos emparejados (x, y) (ajuste por transformación log-lineal). Devuelve a, b y R².';
      case 'at_most':
        return 'Como máximo k de las condiciones `nombre=valor` dadas pueden cumplirse — las condiciones reificadas suman k o menos.';
      case 'exactly':
        return 'Exactamente k de las condiciones `nombre=valor` dadas se cumplen — las condiciones reificadas suman exactamente k.';
      case 'implies':
        return 'Implicación material sobre dos condiciones `nombre=valor`: si la primera se cumple, la segunda también debe cumplirse (a=1 ⇒ b=2).';
      case 'gcc':
        return 'Cardinalidad global: cada valor listado debe aparecer un número exacto de veces entre las variables (valor 1 dos veces, valor 2 una vez, …).';
      case 'among':
        return 'La variable declarada c es igual al número de variables listadas que toman un valor del conjunto dado.';
      case 'nvalue':
        return 'La variable declarada c es igual al número de valores DISTINTOS que toman las variables listadas. Minimiza c para usar los menos posibles.';
      case 'at_most_in_a_row':
        return 'Ninguna racha de más de `max` `valor`es consecutivos en la secuencia — compilado a un pequeño autómata finito (restricción regular).';
      case 'value_precedence':
        return 'Ruptura de simetría: el valor order[i+1] no puede aparecer antes que order[i]. Agrupa valores intercambiables (p. ej. colores de mapa) para enumerar un solo representante por clase.';
      case 'table':
        return 'La tupla (x, y, z) debe coincidir con una de las filas listadas. Codifica relaciones arbitrarias: matrices de compatibilidad, combinaciones permitidas, tablas de pistas de acertijos lógicos.';
      case 'element':
        return 'Acceso indexado: list[idx] == value, índice base 0. Modela indirección como «el coste de la opción elegida es v».';
      case 'diff_n':
        return 'Rectángulos 2D sin solapamiento: cada tupla coloca un rectángulo w×h en la esquina inferior izquierda (x, y). Modela empaquetado, teselado y planos de planta; la pestaña DSL dibuja la disposición hallada a escala.';
      case 'circuit':
        return 'Un único circuito hamiltoniano sobre variables sucesoras: next[i] es el nodo visitado tras el nodo i, y el circuito debe alcanzar cada nodo una vez y volver al inicio. Modela el viajante de comercio y el enrutamiento; la pestaña DSL dibuja el circuito como grafo dirigido. `subcircuit` permite nodos no visitados (bucles).';
      case 'soft':
        return 'Una preferencia MaxCSP: el solucionador la satisface cuando puede, aportando su peso (1 por defecto) a la puntuación. Cuando las preferencias entran en conflicto, gana la asignación que maximiza el peso total satisfecho. La pestaña DSL muestra una puntuación de satisfacción y qué preferencias se cumplieron.';
      case 'set_var':
        return 'Las variables de conjunto eligen un subconjunto de un universo entero — selección de equipo / comité. Declara con `set S from lo..hi`, luego moldea: `card(S) = k` (también `<=`, `in a..b`), `subset(A, B)`, `disjoint(A, B)`, `setEquals(A, B)`, `S contains e`, `S excludes e`. Las soluciones se muestran como grupos de fichas.';
      case 'dot':
        return 'Producto escalar de dos vectores de igual longitud: Σ aᵢ·bᵢ. Devuelve un escalar.';
      case 'cross':
        return 'Producto vectorial de dos vectores 3D: el vector ortogonal a ambos, de longitud |a||b|sin θ.';
      case 'norm':
        return 'Longitud euclídea (norma 2) de un vector: √(Σ vᵢ²).';
      case 'unit':
        return 'Vector unitario en la dirección de v: v / norm(v). Misma dirección, longitud 1.';
      case 'mod':
        return 'Módulo: el resto de a ÷ n. La tecla `mod` inserta el operador entre dos enteros.';
      case 'nth_root':
        return 'La raíz n-ésima de x, es decir x^(1/n). La tecla abre un pequeño diálogo para el grado n y el radicando x.';
      case 'sin':
        return 'Seno de x (x en radianes).';
      case 'cos':
        return 'Coseno de x (x en radianes).';
      case 'tan':
        return 'Tangente de x = sin(x)/cos(x) (x en radianes).';
      case 'asin':
        return 'Arcoseno: el ángulo cuyo seno es x.';
      case 'acos':
        return 'Arcocoseno: el ángulo cuyo coseno es x.';
      case 'atan':
        return 'Arcotangente: el ángulo cuya tangente es x.';
      case 'sinh':
        return 'Seno hiperbólico: (eˣ − e⁻ˣ)/2.';
      case 'cosh':
        return 'Coseno hiperbólico: (eˣ + e⁻ˣ)/2.';
      case 'tanh':
        return 'Tangente hiperbólica: sinh(x)/cosh(x).';
      case 'asinh':
        return 'Arcoseno hiperbólico (inversa de sinh).';
      case 'acosh':
        return 'Arcocoseno hiperbólico.';
      case 'atanh':
        return 'Arcotangente hiperbólica.';
      case 'ln':
        return 'Logaritmo natural (base e) de x.';
      case 'log':
        return 'Logaritmo decimal (base 10) de x.';
      case 'exp':
        return 'Función exponencial e^x.';
      case 'abs':
        return 'Valor absoluto de x — también el módulo de un número complejo.';
      case 'sqrt':
        return 'Raíz cuadrada de x (valor principal, rama no negativa).';
      case 'pi':
        return 'La constante π ≈ 3,14159 — circunferencia de un círculo dividida por su diámetro. La tecla inserta el símbolo.';
      case 'imaginary_unit':
        return 'La unidad imaginaria i, con i² = −1. Representada internamente como I de SymEngine.';
      case 'euler_gamma':
        return 'La constante de Euler-Mascheroni γ ≈ 0,57722 — el límite de (Σ 1/k − ln n) cuando n → ∞.';
      case 'infinity':
        return 'El infinito positivo ∞ — como cota en límites e integrales impropias, no como valor a calcular.';
      case 'sudoku_regular':
        return "Reglas clásicas del Sudoku: cada fila, columna y caja "
            "contiene cada dígito exactamente una vez. Hay plantillas para "
            "4×4, 6×6, 8×8, 9×9, 10×10, 12×12, 15×15 y 16×16.";
      case 'sudoku_x':
        return "Sudoku-X: reglas clásicas del Sudoku más las dos diagonales "
            "principales, que también son «todas distintas». Se ofrece como "
            "plantilla 8×8.";
      case 'sudoku_disjoint':
        return "Grupos disjuntos: reglas clásicas más una restricción «todas "
            "distintas» adicional sobre las celdas que ocupan la misma "
            "posición dentro de la caja, en todas las cajas.";
      case 'sudoku_killer':
        return "Sudoku killer: sin pistas dadas; en su lugar, la cuadrícula "
            "se divide en «jaulas», cada una «todas distintas» y con suma "
            "igual a un objetivo dado.";
      case 'eq_op':
        return 'Test de igualdad — devuelve true cuando ambos lados evalúan al mismo valor.';
      case 'ne_op':
        return 'Test de desigualdad — devuelve true cuando los dos lados difieren.';
      case 'lt_op':
        return 'Comparación estrictamente menor.';
      case 'le_op':
        return 'Comparación menor o igual.';
      case 'gt_op':
        return 'Comparación estrictamente mayor.';
      case 'ge_op':
        return 'Comparación mayor o igual.';
      case 'and_op':
        return 'Conjunción lógica — true solo cuando ambos operandos son true.';
      case 'or_op':
        return 'Disyunción lógica — true si al menos un operando es true.';
      case 'not_op':
        return 'Negación lógica — invierte true a false y viceversa.';
      case 'xor_op':
        return 'O exclusivo — true cuando exactamente un operando es true.';
      case 'if_cond':
        return 'Condicional — evalúa la condición, devuelve la rama then si es true, de lo contrario la rama else.';
      default:
        return null;
    }
  }

  @override
  String? functionRefExampleHint(String id, int index) {
    final list = _esHints[id];
    if (list == null || index < 0 || index >= list.length) return null;
    return list[index];
  }

  static const _esHints = <String, List<String>>{
    'solve': [
      "En CrispMath, `solve(x^2 - 1, x)` devuelve una lista de raíces al "
          "estilo de Python. La llamada subyacente es el `solve()` de "
          "SymEngine (la rama de raíces racionales para polinomios), envuelta "
          "por el puente y serializada de nuevo a una cadena de Dart.",
      "`=` en la entrada se acepta como sintaxis de ecuación: el "
          "preprocesador normaliza `lhs = rhs` a `lhs - rhs` antes de la "
          "llamada al puente.",
      "Las raíces complejas vuelven como el literal `I` de SymEngine. Si las "
          "reutilizas en otras llamadas (p. ej. `expand((-I)*(I))`), el "
          "puente las mantiene simbólicas.",
      "También se resuelven las DESIGUALDADES polinómicas: las raíces dividen la recta en intervalos y el signo de cada intervalo decide. También ≤/≥, extremos con radicales exactos y los casos ≠ / punto / ℝ / ∅.",
    ],
    'expand': [
      "En CrispMath, `expand((x + 1)^2)` devuelve el desarrollo del binomio. "
          "La llamada subyacente es el `expand()` de SymEngine, que descompone "
          "los nodos `Pow` y `Mul` y agrupa los términos semejantes.",
      "Los coeficientes coinciden con la fila 5 del triángulo de Pascal: "
          "1, 5, 10, 10, 5, 1, cada uno multiplicado por la potencia de 2 "
          "correspondiente.",
      "La identidad de la diferencia de cuadrados, útil en combinación con "
          "`factor` para alternar entre las formas.",
    ],
    'simplify': [
      "En CrispMath, `simplify` cancela el factor común `(x - 2)`. La "
          "llamada subyacente es el `simplify()` de SymEngine, que prueba "
          "`rational_simplify` más un pequeño conjunto de reglas de "
          "reescritura.",
      "Agrupación de términos semejantes en una entrada polinómica: "
          "internamente es simplemente `expand` seguido de la fusión de "
          "coeficientes.",
      "Identidad pitagórica; SymEngine aplica la regla de reescritura "
          "trigonométrica antes de devolver el literal `1`.",
    ],
    'factor': [
      "En CrispMath, `factor(x^2 - 1)` devuelve la factorización como "
          "diferencia de cuadrados. La llamada subyacente es el `factor()` de "
          "SymEngine, que usa Berlekamp / Cantor–Zassenhaus para polinomios "
          "de una variable sobre Q.",
      "Identidad de la suma/diferencia de cubos: un factor lineal por un "
          "trinomio de segundo grado irreducible sobre Q.",
      "La factorización se detiene en la irreducibilidad sobre Q: `x^2 + 1` "
          "no se descompone más sin admitir raíces complejas.",
    ],
    'diff': [
      "En CrispMath, `diff(...)` aplica término a término las reglas de la "
          "potencia y de la constante. La llamada subyacente es el `diff()` "
          "de SymEngine, que recorre el árbol de la expresión y emite un "
          "nuevo nodo `Add` simbólico.",
      "Regla de la cadena: SymEngine aplica `diff(sin(u))/du * du/dx` para el "
          "interior `u = x^2`.",
      "Regla del producto: observa que SymEngine deja el resultado sin "
          "factorizar. Pasado por `factor`, se saca `exp(x)` como factor "
          "común.",
    ],
    'integrate': [
      "En CrispMath, la integral indefinida `integrate(...)` se delega en el "
          "`integrate()` de SymEngine. La integración por partes se aplica "
          "automáticamente cuando un factor se deriva a un polinomio.",
      "Forma definida: cuando SymEngine dispone de una primitiva en forma "
          "cerrada, aplica el teorema fundamental del cálculo. Si falla "
          "simbólicamente, CrispMath recurre a la regla de Simpson "
          "(200 subintervalos).",
      "Fracciones parciales: 1/(x²-1) = 1/(2(x-1)) - 1/(2(x+1)). SymEngine "
          "realiza el cálculo automáticamente.",
    ],
    'subst': [
      "En CrispMath, `subst` reescribe el árbol de la expresión y luego "
          "intenta una pasada de simplificación. La llamada subyacente es el "
          "`xreplace()` de SymEngine (sustitución solo de variables, sin "
          "coincidencia de patrones).",
      "Las constantes numéricas `pi`, `e` y la unidad imaginaria `I` las "
          "reconoce SymEngine y se propagan a través de la identidad "
          "trigonométrica.",
      "La sustitución es simbólica: las variables libres no relacionadas `a` "
          "y `b` permanecen intactas.",
    ],
    'limit': [
      "En CrispMath, `limit(...)` es un método numérico: el puente evalúa la "
          "expresión en una sucesión de puntos que convergen a `point` y "
          "comunica el límite cuando muestras consecutivas concuerdan a la "
          "precisión de trabajo. Sin desarrollo en serie simbólico.",
      "El literal `oo` es el centinela de infinito de SymEngine: el "
          "preprocesador lo reconoce antes del envío. Usa `-oo` para el "
          "infinito negativo.",
      "Tiende al número de Euler. Como la vía es numérica, el resultado es "
          "un número en coma flotante; usa `e(N)` para la constante en alta "
          "precisión.",
    ],
    'gcd': [
      "En CrispMath, el `gcd(...)` entero usa la recurrencia de Euclides "
          "gcd(a, b) = gcd(b, a mod b). La llamada subyacente es el `gcd()` "
          "de SymEngine, que en el caso entero recurre a `mpz_gcd` de GMP.",
      "MCD de polinomios mediante el algoritmo de subresultantes (PRS). Útil "
          "como paso previo a `simplify` para las cancelaciones.",
      "Convención: `gcd(0, n) = |n|`. Coincide con la definición matemática "
          "que trata el 0 como múltiplo de todo entero.",
    ],
    'lcm': [
      "En CrispMath, el `lcm(...)` entero se calcula mediante la identidad "
          "`lcm(a, b) = |a*b| / gcd(a, b)`. La llamada subyacente es el "
          "`lcm()` de SymEngine, que delega en `mpz_lcm` de GMP.",
      "36 = 2²·3², la unión de los factores en potencias de primos de "
          "12 = 2²·3 y 18 = 2·3².",
      "El mcm de polinomios elige el múltiplo de mayor grado: `x^2 - 1` ya "
          "contiene `x + 1` como factor.",
    ],
    'polygcd': [
      "En CrispMath, `polygcd` ejecuta el algoritmo de Euclides con "
          "coeficientes racionales exactos (Dart puro). Ambos polinomios "
          "comparten el factor `x - 1`; el resultado se normaliza a mónico.",
      "Polinomios coprimos dan la constante mónica 1.",
    ],
    'polydiv': [
      "División exacta — el resto es cero. "
          "`x² - 1 = (x + 1)(x - 1)`.",
      "No exacta: `x² + 3x + 5 = (x + 2)(x + 1) + 3`.",
    ],
    'polyresultant': [
      "Se calcula como el determinante de la matriz de Sylvester. Se anula "
          "aquí porque ambos se anulan en `x = 1`.",
      "Un resultante no nulo certifica que los dos polinomios son coprimos "
          "sobre ℚ.",
    ],
    'polydiscriminant': [
      "Para `x² + bx + c` el discriminante es `b² − 4c`: aquí 25 − 24 = 1. "
          "CrispMath usa `(−1)^(n(n−1)/2)·Res(p, p′)/aₙ`.",
      "`(x − 2)²` tiene una raíz doble, así que el discriminante es 0.",
    ],
    'polyfactor': [
      "En CrispMath, `polyfactor` reduce el polinomio módulo k, realiza una "
          "factorización libre de cuadrados y luego el algoritmo de "
          "Berlekamp (Dart puro). Los coeficientes se muestran como restos "
          "en [0, k), así que `x − 1` aparece como `x + 4` módulo 5.",
      "`x⁴ + 1` es irreducible sobre ℚ pero es una cuarta potencia perfecta "
          "módulo 2 — la factorización libre de cuadrados recupera la "
          "multiplicidad.",
      "Irreducible sobre 𝔽₂ — un polinomio primitivo para construir GF(8). "
          "Un único factor se devuelve sin cambios.",
    ],
    'gamma': [
      "Para un entero positivo n, Γ(n) = (n − 1)!, así que Γ(5) = 4! = 24. "
          "Evaluada numéricamente mediante `basic_evalf` de SymEngine (MPFR).",
      "Γ(½) = √π — la constante tras la integral de Gauss. Graficable: "
          "dibuja `gamma(x)` para ver los polos en los enteros no positivos.",
    ],
    'zeta': [
      "El problema de Basilea: ζ(2) = π²/6 ≈ 1,6449. Evaluada numéricamente "
          "mediante MPFR.",
      "ζ(4) = π⁴/90. Los valores en enteros pares son todos múltiplos "
          "racionales de potencias de π.",
    ],
    'erf': [
      "erf es impar, con erf(0) = 0 y erf(x) → 1 cuando x → ∞. Graficable: "
          "dibuja `erf(x)` para la sigmoide clásica.",
      "La función error complementaria erfc(x) = 1 − erf(x).",
    ],
    'lambertw': [
      "La constante omega Ω, solución de Ω·e^Ω = 1. Resuelve ecuaciones de "
          "la forma x·eˣ = c.",
      "W(0) = 0, pues 0·e⁰ = 0.",
    ],
    'beta': [
      "B(2, 3) = 1!·2!/4! = 2/24 = 1/12. Sustenta la distribución Beta en "
          "estadística.",
      "B(1, 1) = Γ(1)²/Γ(2) = 1 — una distribución Beta uniforme.",
    ],
    'besselj': [
      "J₀ en x = 1. Las Jₙ resuelven x²y″ + xy′ + (x² − n²)y = 0 — "
          "membranas vibrantes, guías de ondas. Mediante `mpfr_jn` de MPFR. "
          "Graficable: dibuja `besselj(0, x)`.",
      "Jₙ(0) = 0 para n ≥ 1, mientras que J₀(0) = 1.",
    ],
    'bessely': [
      "La segunda solución independiente de la ecuación de Bessel; "
          "Yₙ(x) → −∞ cuando x → 0⁺. Mediante `mpfr_yn` de MPFR.",
      "Graficable: dibuja `bessely(0, x)` junto a `besselj(0, x)`.",
    ],
    'factorial': [
      "En CrispMath, el sufijo `n!` y `factorial(n)` son equivalentes: el "
          "preprocesador reescribe el sufijo como llamada. Para `n ≤ 1000` "
          "calculamos en Dart con multiplicación `BigInt`; más allá, la "
          "llamada subyacente es el `factorial()` de SymEngine.",
      "158 dígitos, conservados exactamente gracias a la vía BigInt: pasar a "
          "IEEE-754 redondearía aquí a 1,0 × 10^157.",
      "Convención del producto vacío: 0! = 1. Necesaria para que la "
          "recurrencia n! = n · (n-1)! termine en 1.",
    ],
    'dsolve': [
      "Ecuación característica r^2 + 3r + 2 = 0 con raíces -1 y -2; cada "
          "raíz aporta un modo exponencial. Los pares complejos dan "
          "exp*(cos + sin); las raíces dobles, (C1 + C2*x)*exp.",
      "Solución homogénea más una particular polinómica por coeficientes "
          "indeterminados — todo en aritmética racional exacta, sin "
          "deriva de coma flotante en los coeficientes.",
    ],
    'taylor': [
      "Solo potencias impares: el seno es una función impar. El desarrollo "
          "se corta antes de x^8 (resto O(x^8)); los coeficientes son "
          "(-1)^k/(2k+1)!.",
      "`series(f, x, n)` es el atajo del desarrollo de Maclaurin (punto 0). "
          "Los coeficientes de la serie exponencial son 1/k!.",
    ],
    'linsolve': [
      "Cada ecuación puede escribirse como \"lado izquierdo = lado "
          "derecho\" o como expresión (implícitamente = 0). Se resuelve de "
          "forma exacta con linsolve() de SymEngine.",
      "Los resultados quedan como fracciones exactas, sin redondeo de coma "
          "flotante. Los sistemas no lineales o subdeterminados devuelven "
          "un error.",
    ],
    'fibonacci': [
      "En CrispMath, `fib(n)` y `fibonacci(n)` son la misma llamada. Para "
          "`n ≤ 90` usamos una tabla precalculada; para `n` mayores, la "
          "llamada subyacente es el `fibonacci()` de SymEngine, que usa "
          "duplicación rápida (O(log n) multiplicaciones mediante GMP).",
      "El 50.º número de Fibonacci: muy por encima del límite de la tabla "
          "para términos pequeños, pero aún cabe en un entero con signo de "
          "64 bits.",
      "Pasa a la vía respaldada por GMP. La duplicación rápida evita la "
          "recurrencia lineal O(n), de modo que incluso fib(10000) queda por "
          "debajo de un segundo.",
    ],
    'isprime': [
      "En CrispMath, `isprime(n)` devuelve una etiqueta booleana. La llamada "
          "subyacente es `mpz_probab_prime_p` de GMP (25 rondas de "
          "Miller-Rabin, cota de error 4^-25 ≈ 9×10^-16) mediante el módulo "
          "`ntheory` de SymEngine. 2027 es el 308.º número primo.",
      "2024 = 2³·11·23.",
      "El noveno número primo de Mersenne, M61. Miller-Rabin se resuelve aún "
          "en microsegundos a este tamaño: el coste está en las "
          "exponenciaciones modulares, no en la longitud en bits.",
    ],
    'nextprime': [
      "En CrispMath, `nextprime(n)` itera desde `n+1` y prueba cada "
          "candidato. La llamada subyacente es el `ntheory::nextprime()` de "
          "SymEngine, que usa la criba de FLINT sobre ventanas cortas cuando "
          "el hueco es grande.",
      "Estrictamente mayor: `nextprime(p)` nunca es `p` mismo, aunque `p` sea "
          "primo.",
    ],
    'prevprime': [
      "En CrispMath, `prevprime(n)` desciende desde `n-1`. La llamada "
          "subyacente es el `ntheory::prevprime()` de SymEngine.",
      "Por debajo de 2 no existen primos; el puente lanza un error en lugar "
          "de devolver un valor centinela. CrispMath muestra la etiqueta de "
          "error.",
    ],
    'factorint': [
      "En CrispMath, `factorint(n)` devuelve una descomposición en primos "
          "ya formateada. La llamada subyacente es `fmpz_factor` de FLINT, "
          "con la envoltura ntheory de SymEngine por delante; CrispMath "
          "convierte la lista de (primo, exponente) en la representación con "
          "dígitos Unicode en superíndice.",
      "El 8.º número primo de Mersenne, M31. Un único factor (él mismo): "
          "`factorint` se cortocircuita cuando la entrada es prima.",
      "Caso límite: por convención, 1 tiene la factorización vacía; "
          "CrispMath lo muestra como el literal `1` en vez de una cadena "
          "vacía.",
    ],
    'divisors': [
      "En CrispMath, `divisors(n)` se deriva en Dart puro a partir de "
          "`factorint(n)`: cada producto de potencias de primos pᵏ con "
          "0 ≤ k ≤ exponente. La cantidad es ∏(eᵢ + 1) — aquí (2+1)(1+1) = 6.",
      "28 es un número perfecto: la suma de sus divisores propios (todos "
          "salvo el propio 28) es 28.",
    ],
    'totient': [
      "Los cuatro restos coprimos con 12 son {1, 5, 7, 11}. CrispMath calcula "
          "φ a partir de la factorización en primos mediante `fmpz_euler_phi` "
          "de FLINT.",
      "Para un primo p, φ(p) = p − 1, ya que todo entero positivo menor es "
          "coprimo con p.",
    ],
    'modpow': [
      "Exponenciación rápida (cuadrar y multiplicar) mediante `mpz_powm` de "
          "GMP — la operación básica de la aritmética modular y (en su "
          "versión escolar) de RSA / Diffie-Hellman. El gigantesco `2¹⁰⁰` "
          "nunca se forma de manera explícita.",
      "Un exponente negativo invierte primero la base, así que "
          "`modpow(a, -1, m)` equivale a `modinv(a, m)` — aquí 3⁻¹ ≡ 4 "
          "(mod 11). Error si mcd(a, m) ≠ 1.",
    ],
    'modinv': [
      "El único x en [0, m) con a·x ≡ 1 (mod m), mediante `mpz_invert` de "
          "GMP. Comprobación: 3·4 = 12 ≡ 1 (mod 11).",
      "Solo las unidades módulo m son invertibles. mcd(2, 4) = 2 ≠ 1, así que "
          "no existe inverso.",
    ],
    'jacobi': [
      "Para un primo n, el símbolo de Jacobi coincide con el símbolo de "
          "Legendre — aquí 2 es un residuo cuadrático módulo 7 (pues 3² ≡ 2). "
          "Mediante `mpz_jacobi` de GMP.",
      "El símbolo es 0 exactamente cuando mcd(a, n) ≠ 1; aquí mcd(6, 9) = 3.",
    ],
    'cfrac': [
      "En CrispMath, `cfrac` realiza un desarrollo exacto en BigInt sobre una "
          "aproximación MPFR de alta precisión de la constante. El término "
          "grande 292 es justamente por qué el convergente 355/113 aproxima "
          "π de forma tan notable.",
      "Para un racional exacto el desarrollo es finito — no es más que el "
          "algoritmo de Euclides registrando sus cocientes.",
    ],
    'convergent': [
      "Milü — la aproximación de π de Zu Chongzhi (siglo V), exacta hasta "
          "seis decimales. CrispMath pliega los primeros k+1 cocientes "
          "parciales de `cfrac` en la fracción.",
      "La aproximación escolar de π; `convergent(x, 0)` es la parte entera "
          "⌊x⌋.",
    ],
    'pi_precision': [
      "En CrispMath, `pi(N)` es una llamada con tratamiento especial, "
          "dirigida a la vía de alta precisión antes de que SymEngine la vea. "
          "La llamada subyacente es `mpfr_const_pi` de MPFR con precisión "
          "⌈N·log2(10)⌉ + 16 bits de guarda, seguida de la conversión a "
          "base 10.",
      "Con N = 100 la precisión de trabajo es de unos 348 bits. Los bits de "
          "guarda impiden que la conversión de base muestre dígitos finales "
          "redondeados.",
    ],
    'e_precision': [
      "En CrispMath, `e(N)` refleja la canalización de `pi(N)`: "
          "`mpfr_const_e` de MPFR (que usa la serie de Taylor Σ 1/k!) con "
          "precisión ⌈N·log2(10)⌉ + 16 bits de guarda, y luego la "
          "representación en base 10.",
      "Lo bastante corto para memorizarlo: útil como comprobación rápida de "
          "precisión frente a `limit((1 + 1/n)^n, n, oo)`.",
    ],
    'sqrt_precision': [
      "En CrispMath, el `sqrt(k, N)` de dos argumentos es la vía de alta "
          "precisión. La llamada subyacente es `mpfr_sqrt_ui` de MPFR con "
          "precisión ⌈N·log2(10)⌉ + 16 bits de guarda. El `sqrt(2)` de un "
          "argumento devuelve en cambio el `sqrt(2)` simbólico mediante "
          "SymEngine.",
      "Útil para verificar: `sqrt(3, N)` debería concordar con dígitos de "
          "referencia obtenidos de forma independiente.",
    ],
    'eulergamma_precision': [
      "En CrispMath, `EulerGamma(N)` usa `mpfr_const_euler` de MPFR, que "
          "evalúa γ mediante la fórmula de Brent–McMillan (funciones de "
          "Bessel modificadas). La precisión es ⌈N·log2(10)⌉ + 16 bits de "
          "guarda, igual que la canalización de `pi(N)` y `e(N)`.",
      "γ no tiene forma cerrada conocida. La rutina de MPFR es la "
          "implementación de referencia estándar; CrispMath se limita a "
          "mostrar la cadena de dígitos.",
    ],
    'evalf': [
      "En CrispMath, `evalf` analiza cualquier expresión y la dirige a "
          "`basic_evalf` de SymEngine con ⌈N·log2(10)⌉ + 8 bits. El "
          "equivalente genérico de `pi(N)` / `e(N)`: funciona con "
          "logaritmos, raíces, sumas y las funciones especiales.",
      "Combínalo con funciones especiales para valores de alta precisión: "
          "ζ(2) = π²/6. Los resultados no reales se rechazan (el complejo "
          "de alta precisión es una vía aparte).",
    ],
    'cevalf': [
      "En CrispMath, `cevalf` usa `basic_evalf` de SymEngine en la vía MPC "
          "(compleja). (1+i)¹⁰ = 32i. La unidad imaginaria es el literal `I`.",
      "Donde `evalf` rechaza un resultado no real, `cevalf` devuelve el "
          "valor complejo completo: √(−2) = i·√2.",
    ],
    'matrix_literal': [
      "En CrispMath, el literal `Matrix(...)` lo reconoce el evaluador de "
          "matrices antes de que el motor vea la expresión. La llamada "
          "subyacente es el constructor `DenseMatrix` de SymEngine: la "
          "disposición de filas/columnas se fija en la construcción.",
      "Las celdas siguen siendo simbólicas: los racionales no se reducen a "
          "coma flotante. Lo mismo ocurre con los símbolos libres: "
          "`Matrix([[a, b], [c, d]])` se acepta y se propaga por `det` / "
          "`inv` / `rref`.",
      "Las matrices no cuadradas valen para `transpose` y `rref` pero fallan "
          "en `det` / `inv`, que exigen una entrada cuadrada.",
    ],
    'det': [
      "En CrispMath, `det(M)` se evalúa como un único escalar. La llamada "
          "subyacente es el `DenseMatrix::det()` de SymEngine, que usa el "
          "algoritmo sin fracciones de Bareiss: exacto para entradas "
          "simbólicas/racionales, sin desbordamiento en coma flotante.",
      "Ejemplo clásico de libro de texto 3×3: el desarrollo por cofactores "
          "de Laplace da el mismo resultado en 6 términos.",
      "Las entradas simbólicas pasan sin cambios. Bareiss mantiene el "
          "resultado como un `Add` de SymEngine en lugar de un número en coma "
          "flotante.",
    ],
    'inv': [
      "En CrispMath, `inv(M)` devuelve `adj(M)/det(M)`. La llamada subyacente "
          "es el `DenseMatrix::inv()` de SymEngine, que usa la eliminación de "
          "Gauss-Jordan sobre los racionales: las entradas vuelven como "
          "fracciones exactas, no como coma flotante.",
      "La matriz identidad es su propia inversa: una comprobación rápida de "
          "que el puente hace el viaje de ida y vuelta correctamente.",
      "Una entrada singular (det = 0) da un error limpio en lugar de "
          "devolver números enormes sin sentido. La etiqueta de error aparece "
          "en el historial de la calculadora.",
    ],
    'transpose': [
      "En CrispMath, `transpose(M)` está implementado del lado de Dart "
          "porque el puente no expone un punto de entrada de transposición. "
          "Reservamos una nueva `SymEngineMatrix` con dimensiones "
          "intercambiadas y copiamos las celdas una a una.",
      "Entrada rectangular: una 2×3 pasa a ser una 3×2, útil para "
          "disposiciones de datos pareados.",
      "Idempotente tras dos aplicaciones. Verifica que el intercambio de "
          "celdas deja intacto el contenido simbólico.",
    ],
    'rref': [
      "En CrispMath, `rref` ejecuta Gauss-Jordan en Dart y llama al "
          "`simplify()` de SymEngine en cada actualización de celda. El "
          "puente no expone `rref` directamente, así que el algoritmo recorre "
          "las columnas de izquierda a derecha, escala la fila pivote y luego "
          "elimina la columna por encima y por debajo.",
      "Entrada de rango deficiente: la segunda fila se reduce a todo ceros. "
          "Útil para detectar visualmente la dependencia lineal.",
      "El escalado del pivote normaliza a 1 las entradas principales. La "
          "detección simbólica de valores no nulos es el punto débil: véase "
          "la nota del algoritmo en `matrix_evaluator.dart`.",
    ],
    'matrix_arithmetic': [
      "En CrispMath, las operaciones binarias con matrices las gestiona el "
          "evaluador de matrices cuando ambos operandos se analizan como "
          "literales `Matrix(...)`. La llamada subyacente es `add_dense_dense` "
          "de SymEngine; la resta pasa por `add_dense_dense` con una negación "
          "elemento a elemento del lado derecho.",
      "La multiplicación es el producto escalar fila por columna habitual "
          "mediante `mul_dense_dense` de SymEngine. La multiplicación por la "
          "derecha por la identidad es una comprobación de funcionamiento.",
      "La resta es elemento a elemento; una discrepancia de dimensiones falla "
          "limpiamente con `Error: matrix - failed: …`.",
    ],
    'eigenvalues': [
      "Matriz 2×2 simétrica — solución en forma cerrada por el polinomio "
          "característico. Los valores propios siempre son reales para "
          "matrices simétricas.",
      "La matriz identidad tiene todos los valores propios iguales a 1.",
      "Matriz de rotación — los valores propios son pares conjugados "
          "complejos ±i. El algoritmo QR maneja bloques 2×2 de Schur reales.",
    ],
    'eigenvectors': [
      "Para matrices 2×2 con valores propios reales, los vectores propios "
          "se calculan mediante el espacio nulo de (A − λI). Para matrices "
          "mayores o valores propios complejos, solo se devuelven los valores "
          "propios.",
    ],
    'mean': [
      "En CrispMath, `mean` la calcula `DescriptiveStats.mean` (véase "
          "`lib/engine/statistics.dart`): una suma en una pasada / n. Para "
          "datos pareados o agrupados, el módulo de Estadística también ofrece "
          "desviación típica, mediana, cuartiles y el rango intercuartílico.",
      "Entrada en coma flotante: la implementación acumula en `double`, así "
          "que listas muy grandes o de magnitudes mezcladas pueden requerir "
          "un algoritmo de suma estable si necesitas más de 15 dígitos.",
    ],
    'one_sample_t': [
      "En CrispMath, `oneSampleT` está en "
          "`lib/engine/hypothesis_tests.dart`. La llamada subyacente calcula "
          "t = (x̄ − μ₀) / (s / √n) y lee el valor p bilateral de "
          "`TDistribution.cdf` con df = n − 1.",
      "La muestra está claramente por encima de μ₀ = 70, así que la prueba "
          "rechaza H₀ (media = 70) con α = 0,05. Compárese con `paired_t`, una "
          "prueba t para una muestra sobre el vector de diferencias.",
    ],
    'welch_t': [
      "En CrispMath, `welchT` está en "
          "`lib/engine/hypothesis_tests.dart`. La llamada subyacente calcula "
          "el estadístico t = (x̄_A − x̄_B) / √(s_A²/n_A + s_B²/n_B), luego "
          "aproxima los grados de libertad mediante Welch-Satterthwaite y lee "
          "el valor p en `TDistribution.cdf`.",
      "Caso de muestra diminuta: los gl de Welch ≈ 4 aunque n_A + n_B = 6, "
          "porque la distribución t de dos muestras ajusta la incertidumbre "
          "de la estimación de la varianza.",
    ],
    'paired_t': [
      "En CrispMath, `pairedT` se reduce a una prueba t de una muestra sobre "
          "el vector de diferencias d = después − antes. La llamada subyacente "
          "es la misma vía `TDistribution.cdf` que usa `welchT`, pero con "
          "gl = n - 1 (sin ajuste de Welch, ya que solo hay una estimación de "
          "la varianza que hacer).",
      "Caso límite: desplazamientos idénticos producen varianza nula en las "
          "diferencias, que la implementación presenta como el valor límite "
          "p = 0 en lugar de un NaN.",
    ],
    'anova_1': [
      "En CrispMath, `anovaOneWay` descompone la suma de cuadrados total en "
          "la suma de cuadrados entre grupos y dentro de los grupos. La "
          "llamada subyacente es F = MC_entre / MC_dentro con gl1 = K - 1 y "
          "gl2 = N - K, y luego `FDistribution.sf` para el valor p de la cola "
          "superior.",
      "Dispersiones iguales y medias bien separadas producen una F alta. Se "
          "rechaza H₀ (todas las medias iguales) al nivel α = 0,05.",
    ],
    'chi2_goodness': [
      "En CrispMath, `chiSquareGof` evalúa Σ (O - E)² / E y lee el valor p "
          "de la cola superior en `ChiSquaredDistribution.sf` con gl = k - 1, "
          "donde k es el número de categorías. Se supone que los recuentos de "
          "celda son ≥ 5: la implementación no aplica la corrección de Yates "
          "automáticamente.",
      "Coincidencia perfecta → χ² = 0 → no se rechaza H₀ a ningún nivel α.",
    ],
    'chi2_independence': [
      "En CrispMath, `chiSquareIndependence` calcula los recuentos esperados "
          "a partir de los marginales de fila × columna (E_ij = fila_i · "
          "columna_j / total), luego Σ (O - E)² / E con "
          "gl = (filas - 1) · (columnas - 1). El valor p subyacente proviene "
          "de `ChiSquaredDistribution.sf`.",
      "Fuerte concentración fuera de la diagonal → valor p bajo. Para tablas "
          "2×2 dispersas, prefiere `fisher_exact`, que no depende de la "
          "aproximación chi-cuadrado para muestras grandes.",
    ],
    'fisher_exact': [
      "En CrispMath, `fisherExact` enumera todas las tablas 2×2 con los "
          "mismos marginales y suma las probabilidades hipergeométricas de "
          "las tablas al menos tan extremas como la observada. La llamada "
          "subyacente calcula términos log-binomiales para evitar el "
          "desbordamiento con totales grandes, y luego exponencia; el valor p "
          "bilateral sigue la convención de R (suma de probabilidades de cola "
          "≤ la observada).",
      "Tabla simétrica → ninguna evidencia de asociación.",
    ],
    'wilcoxon': [
      "En CrispMath, `wilcoxonRankSum` une ambas muestras, asigna rangos "
          "corregidos por rangos medios, suma los rangos del grupo A e "
          "informa del z de la aproximación normal. La llamada subyacente "
          "aplica una corrección por empates a la varianza y lee el valor p "
          "bilateral en la función de distribución normal.",
      "Caso de muestra diminuta: la aproximación normal está en el límite con "
          "n_A + n_B = 6. Para muestras muy pequeñas conviene la distribución "
          "de permutación exacta (aún no incluida).",
    ],
    'sign_test': [
      "En CrispMath, `pairedSign` descarta los pares con diferencia nula, "
          "cuenta los positivos entre los n restantes y contrasta frente a "
          "una Binomial(n, 0,5). El valor p subyacente usa la cola binomial "
          "exacta: sin aproximación normal, por lo que es la opción adecuada "
          "para muestras pareadas muy pequeñas.",
      "Un par empatado (4 → 4) se descarta, dejando n = 3 positivos de 3 "
          "pares informativos. El valor p exacto bilateral es "
          "2 · min(Binom(3, 0,5).cdf(3), …).",
    ],
    'linreg': [
      "En CrispMath, la pestaña «Regresión» ajusta los datos mediante los "
          "estimadores de mínimos cuadrados en forma cerrada a = Sxy / Sxx y "
          "b = ȳ − a·x̄ (véase `lib/engine/statistics.dart`). La misma pestaña "
          "ofrece también modelos polinómico y exponencial.",
      "Puntos próximos a y = 2x dan una pendiente ≈ 2 y un R² cercano a 1: un "
          "ajuste lineal casi perfecto.",
    ],
    'poly_fit': [
      'El selector de grado (2–5) de la pestaña Regresión fija d; un grado mayor ajusta más curvatura pero arriesga sobreajuste. Basado en Statistics.polynomialFit.',
    ],
    'exp_fit': [
      'Regresa internamente ln(y) contra x, así que todos los y deben ser positivos; ajusta datos de crecimiento / decaimiento. Basado en Statistics.expFit.',
    ],
    'normal_dist': [
      "En CrispMath, la pestaña «Distribuciones» evalúa la función de "
          "distribución de la normal mediante la función de error "
          "(`Normal.cdf` en `lib/engine/statistics.dart`); x = μ + 2σ se sitúa "
          "en torno al percentil 97,7.",
      "El cuantil 0,95 es la función de distribución inversa: el valor por "
          "debajo del cual queda el 95 % de la masa (≈ μ + 1,645σ). Va de la "
          "mano de `erf`, que sustenta la función de distribución.",
    ],
    'binomial_dist': [
      "En CrispMath, la pestaña «Distribuciones» evalúa la función de masa "
          "binomial C(n, k)·pᵏ·(1−p)^(n−k) (`Binomial.pmf` en "
          "`lib/engine/statistics.dart`); con una tasa de defectos del 10 % "
          "sobre 20 artículos, el número de defectos más probable es la media, "
          "2.",
      "La función de distribución suma la función de masa de 0 a k. Aquí "
          "≈ 68 % de los lotes presentan a lo sumo dos defectos. La varianza "
          "es n·p·(1−p) = 1,8, así que la desviación típica ≈ 1,34.",
    ],
    'vars': [
      "En CrispMath, la línea `vars:` la analiza `DslToFlatZinc` (véase "
          "`lib/engine/csp_solver.dart`) y emite una declaración FlatZinc "
          "`var int: x :: …` por nombre. Las cotas del dominio son enteros "
          "concretos; los dominios simbólicos no se admiten.",
      "Un dominio `0..1` modela una variable booleana. FlatZinc tiene un tipo "
          "`var bool` aparte: el analizador no lo detecta, pero el solucionador "
          "trata el entero 0/1 con la misma eficiencia.",
    ],
    'all_different': [
      "En CrispMath, `allDifferent` se traduce a "
          "`all_different_int([a, b, c])` de FlatZinc. El solucionador "
          "subyacente (dart_csp) implementa la propagación por consistencia de "
          "cotas mediante el algoritmo de emparejamiento de Régin: mucho más "
          "rápido que el modo dos a dos en listas de argumentos grandes.",
      "Las plantillas de Sudoku del módulo Sudoku se construyen sobre pilas "
          "de restricciones `allDifferent`: una por fila, columna, caja y las "
          "zonas de variante que haya.",
    ],
    'no_overlap': [
      "En CrispMath, `noOverlap` se traduce a "
          "`disjunctive([s1, s2, s3], [4, 3, 2])` de FlatZinc. El "
          "solucionador subyacente usa edge-finding más el propagador θ-tree "
          "de Vilím: el mismo algoritmo que el integrado en MiniZinc.",
      "Problema clásico de secuenciación en una máquina. Combínalo con "
          "`minimize` sobre la expresión del makespan para obtener la "
          "planificación óptima. Véase el ejemplo resuelto para el programa "
          "DSL completo.",
    ],
    'cumulative': [
      "En CrispMath, `cumulative` se traduce a "
          "`cumulative([starts], [durations], [resources], capacity)` de "
          "FlatZinc. El solucionador subyacente usa propagación por "
          "calendario más razonamiento energético: variantes conscientes de "
          "la capacidad de los propagadores de `noOverlap`.",
      "El problema de planificación de proyectos con recursos limitados "
          "(RCPSP) apila varias restricciones `cumulative`, una por tipo de "
          "recurso. Véase el ejemplo resuelto `dslRcpsp` para un proyecto con "
          "dos recursos.",
    ],
    'minimize': [
      "En CrispMath, `minimize` emite `solve minimize __obj__;` de FlatZinc "
          "tras construir la variable objetivo mediante el análisis de la "
          "expresión lineal. El solucionador subyacente usa ramificación y "
          "acotación: comprobación de factibilidad y luego ajuste de la cota "
          "superior en cada solución que mejora.",
      "Véase el ejemplo resuelto `dslCoinChange`: minimiza sobre una suma de "
          "variables indicadoras para hallar el menor conjunto de monedas que "
          "suma el objetivo.",
    ],
    'maximize': [
      "En CrispMath, `maximize` emite `solve maximize __obj__;` de FlatZinc. "
          "El solucionador subyacente hace ramificación y acotación igual que "
          "`minimize`, pero con el ajuste de la cota inferior invertido.",
      "Problema clásico de la mochila 0/1. El DSL lo gestiona de forma "
          "natural como una declaración `vars: x_1, ... in 0..1` más una "
          "restricción de capacidad lineal y un objetivo lineal.",
    ],
    'at_least': [
      'Las condiciones pueden apuntar a cualquier valor, no solo booleanos — `atLeast(1, a=3, b=5)` significa a es 3 o b es 5 (o ambos).',
    ],
    'at_most': [
      'Combina con `atLeast` sobre las mismas condiciones para un número exacto, o usa `exactly` directamente.',
    ],
    'exactly': [
      'El caballo de batalla de los acertijos de lógica — «exactamente una persona tiene el gato», «exactamente dos casas son azules», etc.',
    ],
    'implies': [
      'Cadenas de `implies` codifican la lógica de pistas de los acertijos de Einstein / la cebra. Ver el ejemplo `logicGrid`.',
    ],
    'gcc': [
      'Básico en horarios y turnos — fija cuántas veces aparece cada turno/valor. Ver el ejemplo `nurseRostering`.',
    ],
    'among': [
      'Restringe o minimiza c para controlar cuántas variables caen en una categoría.',
    ],
    'nvalue': [
      'Con restricciones `!=` de adyacencia de grafo, minimizar nvalue da el número cromático. Ver el ejemplo `chromaticNumber`.',
    ],
    'at_most_in_a_row': [
      'Codifica reglas de fatiga / patrón que el mero conteo no puede expresar. El autómata tiene un estado por longitud de racha 0..max.',
    ],
    'value_precedence': [
      'Añádela a cualquier problema con valores intercambiables para eliminar los k! duplicados de reetiquetado del conjunto de soluciones.',
    ],
    'table': [
      'Cualquier relación sin fórmula limpia cabe en una tabla. Ver el ejemplo `menuPairing`.',
    ],
    'element': [
      'Combina con `minimize`/`maximize` sobre el valor consultado para optimizar una elección entre costes tabulados.',
    ],
    'diff_n': [
      'Las variables de coordenadas deben declararse; el ancho y el alto son literales enteros. El tamaño del contenedor se infiere de los rangos de las coordenadas.',
    ],
    'circuit': [
      'Cada variable sucesora debe declararse con un dominio que cubra 0..n-1. Añade `; labels=…` para nombrar los nodos en el grafo; usa `subcircuit` si algunos nodos pueden omitirse.',
    ],
    'soft': [
      'El cuerpo es una comparación simple (`x = 5`, `x < 3`, `x = y`). No puede combinarse con `minimize`/`maximize`: ambos son objetivos.',
    ],
    'set_var': [
      'Los elementos del universo son enteros. No puede combinarse con `minimize`/`maximize` ni `soft(…)`. Los miembros se muestran como fichas.',
    ],
    'dot': [
      'El producto escalar es |a||b|cos θ — cero exactamente cuando los vectores son ortogonales.',
    ],
    'cross': [
      'Regla de la mano derecha: x × y = z. Definido solo para vectores 3D.',
    ],
    'norm': [
      'El triángulo 3-4-5. `norm` es la magnitud por la que `unit` divide.',
    ],
    'unit': [
      'Normalizar conserva la dirección, descarta la magnitud — indefinido para el vector cero.',
    ],
    'mod': [
      'Se combina con `modpow` / `modinv` para aritmética modular; `a mod n` es `a − n·⌊a/n⌋`.',
    ],
    'nth_root': [
      'La raíz cúbica de 27. Para n = 2 usa la tecla √ dedicada; `ⁿ√x` cubre cualquier grado.',
    ],
    'sin': [
      'Período 2π, rango [-1, 1]. La calculadora interpreta el argumento en radianes.',
    ],
    'cos': [
      'Período 2π, rango [-1, 1]; cos es sin desplazado π/2.',
    ],
    'tan': [
      'Período π; indefinida donde cos(x)=0 (x = π/2 + kπ).',
    ],
    'asin': [
      'Dominio [-1, 1], rango principal [-π/2, π/2].',
    ],
    'acos': [
      'Dominio [-1, 1], rango principal [0, π].',
    ],
    'atan': [
      'Dominio todos los reales, rango principal (-π/2, π/2).',
    ],
    'sinh': [
      'Función impar, no acotada; la familia de las catenarias.',
    ],
    'cosh': [
      'Función par, mínimo 1 en x=0; forma de una cadena colgante.',
    ],
    'tanh': [
      'Impar, rango (-1, 1); función de activación común en redes neuronales.',
    ],
    'asinh': [
      'Dominio todos los reales; asinh(x) = ln(x + √(x²+1)).',
    ],
    'acosh': [
      'Dominio x ≥ 1; acosh(x) = ln(x + √(x²−1)).',
    ],
    'atanh': [
      'Dominio (-1, 1); atanh(x) = ½·ln((1+x)/(1−x)).',
    ],
    'ln': [
      'Inversa de exp; dominio x > 0. ln(e) = 1.',
    ],
    'log': [
      'Dominio x > 0. Para otras bases: ln(x)/ln(b).',
    ],
    'exp': [
      'Inversa de ln; siempre positiva, su propia derivada.',
    ],
    'abs': [
      'abs(x) = √(x²); para a+bi devuelve √(a²+b²).',
    ],
    'sqrt': [
      'sqrt(x) = x^(1/2). Para otros grados, la tecla ⁿ√x.',
    ],
    'pi': [
      'Para π con un número de dígitos elegido, la tecla π(N) (pi_precision).',
    ],
    'imaginary_unit': [
      'Los resultados complejos vuelven en términos de I — p. ej. solve(x² + 1 = 0) → x = ±i.',
    ],
    'euler_gamma': [
      'Inserta EulerGamma; para γ con un número de dígitos elegido, la tecla γ(N) (eulergamma_precision).',
    ],
    'infinity': [
      'Inserta el símbolo ∞; combínalo con `lim` o `∫` para comportamiento límite / impropio.',
    ],
    'sudoku_regular': [
      "En CrispMath, la variante clásica está en `lib/engine/sudoku.dart` "
          "como `SudokuVariant.regular`. El solucionador subyacente instancia "
          "una restricción `allDifferent` por fila, columna y caja (27 en "
          "total para el 9×9) y se las pasa a `dart_csp`.",
    ],
    'sudoku_x': [
      "En CrispMath, el Sudoku-X es `SudokuVariant.x` "
          "(`lib/engine/sudoku.dart`). El solucionador subyacente añade dos "
          "restricciones `allDifferent` adicionales al trío clásico "
          "fila/columna/caja: una por diagonal.",
    ],
    'sudoku_disjoint': [
      "En CrispMath, es `SudokuVariant.disjoint`. Para una cuadrícula N×N "
          "con cajas √N × √N, la restricción añade N superposiciones "
          "`allDifferent` más: una por posición dentro de la caja. El 8×8 se "
          "ofrece como una sola plantilla.",
    ],
    'sudoku_killer': [
      "En CrispMath, es `SudokuVariant.killer`. El solucionador subyacente "
          "superpone al trío clásico fila/columna/caja una restricción "
          "`allDifferent` por jaula y una restricción `suma = objetivo` por "
          "jaula. Se ofrecen las plantillas killer de 4×4 y 9×9.",
    ],
    'eq_op': [
      'Se convierte a Eq(2, 2) de SymEngine y se simplifica a True.',
      'Simbólico — permanece como ecuación cuando x es libre.',
    ],
    'ne_op': [
      'Se convierte a Ne(3, 4) de SymEngine.',
      'Valores iguales dan false.',
    ],
    'lt_op': [
      'Se convierte a Lt(2, 5) de SymEngine.',
      'No es estrictamente menor — use <= para no estricto.',
    ],
    'le_op': [
      'Se convierte a Le(5, 5) de SymEngine.',
      'Estrictamente mayor falla la prueba.',
    ],
    'gt_op': [
      'Se convierte a Gt(10, 3) de SymEngine.',
    ],
    'ge_op': [
      'Se convierte a Ge(5, 5) de SymEngine.',
    ],
    'and_op': [
      'Ambos predicados se cumplen → true.',
      'Un operando falso → false.',
    ],
    'or_op': [
      'Un operando verdadero es suficiente.',
    ],
    'not_op': [
      '4 no es primo → not false → true.',
      'Niega la igualdad.',
    ],
    'xor_op': [
      'Ambos verdaderos → xor es false.',
      'Exactamente uno verdadero → xor es true.',
    ],
    'if_cond': [
      '7 es primo → la condición es true → devuelve 100.',
      '2 no es > 5 → devuelve la rama else.',
    ],
  };

  @override
  String get settingsWorkedExamples => 'Biblioteca de ejemplos resueltos';
  @override
  String get settingsWorkedExamplesSubtitle =>
      'Ahora también accesible mediante el icono de libro en la parte '
      'superior de la Calculadora y el Bloc de notas. Toca aquí para la '
      'biblioteca completa.';
  @override
  String get functionRefTitle => 'Referencia de funciones';
  @override
  String get functionRefSearchHint => 'Buscar funciones…';
  @override
  String get functionRefEmpty => 'Ninguna función coincide con este filtro.';
  @override
  String get functionRefSeeAlso => 'Véase también:';
  @override
  String get functionRefTryInCalculator => 'Probar en la Calculadora';
  @override
  String get functionRefOpenModule => 'Abrir el módulo';
  @override
  String get functionRefSeeWorkedExample => 'Ver ejemplo resuelto';
  @override
  String get functionRefCatCas => 'CAS';
  @override
  String get functionRefCatNumberTheory => 'Teoría de números';
  @override
  String get functionRefCatPrecision => 'Alta precisión';
  @override
  String get functionRefCatMatrix => 'Matrices';
  @override
  String get functionRefCatGraphing => 'Gráficos';
  @override
  String get functionRefCatStatistics => 'Estadística';
  @override
  String get functionRefCatConstraints => 'Restricciones';
  @override
  String get functionRefCatSudoku => 'Sudoku';
  @override
  String get functionRefCatUnits => 'Unidades';
  @override
  String get functionRefCatLogic => 'Lógica';
  @override
  String get settingsFunctionRef => 'Referencia de funciones';
  @override
  String get settingsFunctionRefSubtitle =>
      'Explora cada función de CrispMath: firma, ejemplos, funciones '
      'relacionadas y un atajo para pegar en la Calculadora.';

  @override
  String get importDataTitle => 'Importar datos';
  @override
  String get importDataSubtitle =>
      'Pega un JSON de una exportación anterior para restaurar el '
      'historial, las variables, las funciones y los ajustes.';
  @override
  String get importDataWarning =>
      'Esto sobrescribe el historial actual, las variables y las '
      'funciones gráficas. No hay deshacer — copia primero el estado '
      'actual si quieres conservarlo.';
  @override
  String get importDataApply => 'Aplicar';
  @override
  String get importDataEmpty => 'Pega un JSON para importar.';
  @override
  String get importDataNotObject =>
      'El JSON debe ser un objeto (empieza con `{`).';
  @override
  String get importDataApplied => 'Importado';
  @override
  String get settingsImportData => 'Importar datos';
  @override
  String get settingsImportDataSubtitle =>
      'Pega un JSON de una exportación anterior para restaurar.';

  @override
  String get userFunctionsTitle => 'Funciones definidas por el usuario';
  @override
  String get userFunctionsHelp =>
      'Define una función una vez, llámala desde cualquier expresión. '
      'P. ej. `f(x) = x^2 + 1`, entonces `f(3) + 1` evalúa a 11. La '
      'composición `g(f(x))` funciona mientras ambas estén definidas.';
  @override
  String get userFunctionsEmpty =>
      'Aún no hay funciones definidas por el usuario. Pulsa Añadir para '
      'crear la primera.';
  @override
  String get userFunctionsAdd => 'Añadir';
  @override
  String get userFunctionsEdit => 'Editar';
  @override
  String get userFunctionsDelete => 'Eliminar';
  @override
  String get userFunctionsName => 'Nombre';
  @override
  String get userFunctionsNameHelp =>
      'Una sola letra minúscula (a..z) que no entre en conflicto con '
      'nombres integrados.';
  @override
  String get userFunctionsNameRequired => 'Obligatorio';
  @override
  String get userFunctionsNameInvalid =>
      'Debe ser una sola letra minúscula (a..z).';
  @override
  String get userFunctionsParam => 'Parámetro';
  @override
  String get userFunctionsBody => 'Cuerpo';
  @override
  String get userFunctionsBodyRequired => 'Cuerpo de la función requerido';
  @override
  String get settingsUserFunctions => 'Funciones definidas por el usuario';
  @override
  String get settingsUserFunctionsSubtitle =>
      'Define funciones con nombre como f(x) = x^2 + 1 y reutilízalas en '
      'cualquier expresión.';

  @override
  String get onboardingSkip => 'Omitir';
  @override
  String get onboardingNext => 'Siguiente';
  @override
  String get onboardingDone => 'Entendido';
  @override
  String onboardingPage(int current, int total) => '$current / $total';
  @override
  String get onboardingKeypadTitle => 'Teclado con pestañas';
  @override
  String get onboardingKeypadBody =>
      'Cambia entre las pestañas Núm, Trig, CAS y Avanzado para '
      'encontrar la operación que necesitas. En ventanas más anchas '
      'todo el teclado cabe en una sola pantalla — sin pestañas.';
  @override
  String get onboardingHistoryTitle => 'Desplaza por el historial';
  @override
  String get onboardingHistoryBody =>
      'Cada cálculo se guarda. Desplázate hacia arriba para revisarlo, '
      'mantén pulsado para copiar o reutilizar, toca el icono de '
      'búsqueda para filtrar.';
  @override
  String get onboardingFunctionsTitle => 'Elegir una función';
  @override
  String get onboardingFunctionsBody =>
      'Los botones ∫⌄, d/dx⌄ y solve⌄ abren selectores paso a paso '
      'que explican la respuesta regla por regla.';
  @override
  String get onboardingAnalysisTitle => 'Centro de análisis';
  @override
  String get onboardingAnalysisBody =>
      'Estudio de curvas, planos, cónicas, gráficos 3D, estadística y '
      'el conversor de unidades están todos en la pestaña Análisis.';
  @override
  String get onboardingNotepadTitle => 'Bloc de notas';
  @override
  String get onboardingNotepadBody =>
      'Escribe matemáticas como un documento — una expresión por línea, '
      'resultados en la columna derecha. Define variables (tax = 0.085), '
      'referencia líneas anteriores y observa cómo todo se actualiza '
      'en tiempo real.';
  @override
  String get onboardingWorksheetTitle =>
      'Una calculadora que recuerda';
  @override
  String get onboardingWorksheetBody =>
      'Empieza con una hoja de trabajo: a = 3, f(x) = x² + a, f(4). Cambia a y todos los resultados y la gráfica vinculada se recalculan. Guarda un punto de control, compara, restaura y exporta toda la sesión.';
  @override
  String get onboardingTryWorksheet =>
      'Probar una hoja de trabajo en vivo';
  @override
  String get analysisLabsTitle =>
      'Laboratorio';
  @override
  String get analysisLabsSubtitle =>
      'Problemas de restricciones, solucionador de Sudoku y compositor de escenas 3D';
  @override
  String get aboutOurApps =>
      'Nuestras apps';
  @override
  String get aboutOurAppsIntro =>
      'Más apps del mismo desarrollador. Las apps en TestFlight son betas gratuitas: el enlace instala primero TestFlight de Apple.';
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
      'Próximamente';
  @override
  String get aboutThisApp =>
      'esta app';
  @override
  String get settingsReplayTour => 'Repetir la visita guiada';
  @override
  String get settingsReplayTourSubtitle =>
      'Mostrar la visita de primer inicio la próxima vez que abras la '
      'aplicación.';

  @override
  String get helpTitle => 'Ayuda';
  @override
  String get helpFunctionsHeading => 'Funciones soportadas';
  @override
  String get helpMatrixHeading => 'Sintaxis de matrices';
  @override
  String get helpStepsHeading => 'Soluciones paso a paso';
  @override
  String get helpMatrixBody =>
      'Escribe matrices con `;` para filas y `,` para celdas:\n\n    [1, 2; 3, 4]\n\nLa calculadora lo convierte internamente a `Matrix([[1, 2], [3, 4]])`. Operaciones: det, inv, transpose, rref, +, -, *.';
  @override
  String get helpStepsBody =>
      'Tres botones del teclado CAS abren trazas paso a paso:\n\n  • d/dx⌄ para pasos de derivación\n  • solve⌄ para resolución de ecuaciones\n  • ∫⌄ para integración indefinida\n\nCada vista muestra la regla aplicada en cada paso más la respuesta final.';

  @override
  String get constantsTitle => 'Referencia de constantes';
  @override
  String get constantsSearchHint => 'Buscar por símbolo, nombre o unidad…';
  @override
  String get constantsNoMatches =>
      'Ninguna constante coincide con este filtro.';
  @override
  String get constantsAllCategory => 'Todas';
  @override
  String get constantsCategoryMathematical => 'Matemáticas';
  @override
  String get constantsCategoryPhysical => 'Física';
  @override
  String get constantsCategoryChemistry => 'Química';
  @override
  String get constantsCategoryAstronomy => 'Astronomía';
  @override
  String get constantsCopyValue => 'Copiar valor';
  @override
  String constantsCopiedToast(String symbol) =>
      '$symbol copiado al portapapeles';
  @override
  String get settingsConstants => 'Referencia de constantes';
  @override
  String get settingsConstantsSubtitle =>
      'Constantes físicas, matemáticas, químicas y astronómicas.';

  @override
  String get tabNum => 'Núm';
  @override
  String get tabTrig => 'Trig';
  @override
  String get tabCas => 'CAS';
  @override
  String get tabAdvanced => 'Avanzado';
  @override
  String get tabVars => 'Variables';
  @override
  String get tabBasic => 'Básico';
  @override
  String get tabSymbolic => 'Simbólico';

  @override
  String? stepNote(StepNote note) {
    final p = note.params;
    switch (note.key) {
      case 'startEquation':
        return 'Partimos de la ecuación tal como está dada.';
      case 'moveRightSideOver':
        return 'Restar el lado derecho en ambos lados deja la ecuación en '
            'la forma estándar `expresión = 0`, lo que permite aplicar el '
            'solver lineal o cuadrático.';
      case 'noEqualsSign':
        return 'No hay `=` en la entrada; se trata como '
            '${p['body']} = 0.';
      case 'doesNotDependOn':
        return 'La ecuación no depende de ${p['var']}.';
      case 'solveFallthroughSymbolic':
        return 'No es una forma lineal o cuadrática estándar — la '
            'respuesta la calcula el solver simbólico.';
      case 'linearIdentifyCoefs':
        return 'Identifica el coeficiente principal y el término '
            'constante — esta es una ecuación lineal.';
      case 'moveConstant':
        return 'Pasa la constante al otro lado.';
      case 'divideByCoef':
        return 'Divide ambos lados entre el coeficiente principal para '
            'despejar ${p['var']}.';
      case 'quadraticIdentifyCoefs':
        return 'Lee los tres coeficientes en el polinomio. Tomamos a de '
            'la segunda derivada ÷ 2, b de la primera derivada en '
            '${p['var']} = 0, y c del polinomio en ${p['var']} = 0.';
      case 'discriminant':
        return 'El discriminante indica cuántas raíces reales hay: '
            'positivo → dos raíces reales distintas; cero → una raíz '
            'doble; negativo → dos raíces complejas conjugadas.';
      case 'quadFormulaApply':
        return 'Sustituye a, b y Δ en la fórmula cuadrática. El `±` '
            'entrega ambas raíces en un solo paso.';
      case 'integralPullMinusOut':
        return 'Saca el signo menos de la integral; el resto es '
            'simplemente ∫f.';
      case 'exprDoesNotDependOn':
        return '${p['expr']} no depende de ${p['var']}.';
      case 'integralIdentityPower1':
        return 'La regla de la potencia para n=1: sube el exponente a 2 '
            'y divide entre el nuevo exponente.';
      case 'integralLinearity':
        return 'La integración es lineal: la integral de una suma es la '
            'suma de las integrales.';
      case 'integralPullConstantOut':
        return 'Saca `${p['const']}` de la integral — las constantes '
            'se factorizan.';
      case 'integralReciprocalLog':
        return 'La integral de 1/${p['var']} es el logaritmo natural de '
            'su valor absoluto.';
      case 'integralPowerRule':
        return 'Sube el exponente en 1 y divide entre el nuevo '
            'exponente. Vale para cualquier constante n ≠ −1.';
      case 'uSubLinear':
        return 'Sea u = ${p['u']}; entonces du = '
            '(${p['slope']})·d${p['var']}.';
      case 'integralStandardAntideriv':
        return 'Usa la antiderivada estándar de ${p['fn']}.';
      case 'uSubLinearFn':
        return 'Sea u = ${p['u']}; entonces du = '
            '(${p['slope']})·d${p['var']}. La antiderivada de ${p['fn']} '
            'es la forma estándar, evaluada en u y dividida por la '
            'pendiente.';
      case 'ibpLnX':
        final v = p['var']!;
        return 'Sea u = ln($v), dv = d$v. Entonces du = (1/$v)·d$v y '
            'v = $v, así ∫u·dv = u·v − ∫v·du = $v·ln($v) − ∫1 d$v.';
      case 'ibpXTimesF':
        return 'Sea u = ${p['var']} (entonces du = d${p['var']}) y '
            'dv = ${p['right']}·d${p['var']}, dando v = ${p['v']}.';
      case 'ibpRepeated':
        return 'Sea u = ${p['u']} y dv = ${p['right']}·d${p['var']}. '
            'Entonces du = ${p['n']}·… (una potencia de ${p['var']} menos) '
            'y v = ${p['v']}, por lo que el nuevo integrando pierde una '
            'potencia de ${p['var']} — recursión.';
      case 'uSubNonlinear':
        return 'Sea u = ${p['u']}; entonces du = (${p['du']})·d${p['var']}. '
            'El integrando tiene la forma f(u)·du, así la sustitución '
            'lo convierte en ∫f(u) du = antiderivada estándar de ${p['fn']} '
            'evaluada en u'
            '${p['ratio'] == '1' ? '.' : ', multiplicada por el factor constante ${p['ratio']}.'}';
      case 'integralLogDerivative':
        return 'El numerador es (${p['ratio']})·(d/d${p['var']}[${p['den']}]), '
            'así que la integral es ${p['ratio']}·ln|${p['den']}|.';
      case 'partialFractions':
        return 'El denominador tiene raíces enteras distintas '
            '${p['roots']}. El método de cobertura da '
            'A_i = P(r_i) / Q\'(r_i) para cada raíz.';
      case 'partialFractionsIntegrate':
        return 'Cada término `A/(x-r)` se integra a A·ln|x-r|.';
      case 'trigArctanForm':
        return 'Iguala a² = ${p['aSq']}, así a = ${p['a']}. La forma '
            'estándar da (1/a)·arctan(${p['var']}/a).';
      case 'trigArcsinForm':
        return 'Iguala a² = ${p['aSq']}, así a = ${p['a']}. La forma '
            'estándar da arcsin(${p['var']}/a).';
      case 'integralFallthroughSymbolic':
        return 'Ninguna regla de libro de texto encaja con esta forma — '
            'la respuesta la calcula el integrador simbólico.';
      case 'diffIdentity':
        return 'La derivada de ${p['var']} con respecto a sí misma es 1.';
      case 'diffSumDifference':
        return 'Deriva cada término por separado; la derivación se '
            'distribuye sobre `+` y `−`.';
      case 'diffQuotient':
        return 'Para un cociente, el numerador queda `f′g − fg′` y el '
            'denominador se eleva al cuadrado.';
      case 'diffProduct':
        return 'Para un producto, deriva cada factor y suma las piezas '
            '— `(fg)′ = f′g + fg′`.';
      case 'diffPowerSimple':
        return 'Baja el exponente como coeficiente y reduce el exponente '
            'en 1.';
      case 'diffPowerChain':
        return 'Baja el exponente y redúcelo en 1, luego multiplica por '
            'la derivada de la base interna — ese factor '
            '`d/d${p['var']}[${p['base']}]` es la regla de la cadena.';
      case 'diffExponential':
        return 'Cuando la variable está en el exponente, la derivada es '
            'la misma expresión multiplicada por `ln(base)` y por la '
            'derivada del exponente.';
      case 'diffStandardSimple':
        return 'Aplica la derivada estándar de ${p['fn']}.';
      case 'diffStandardChain':
        return 'El argumento depende de ${p['var']}, así que multiplica '
            'por su derivada (regla de la cadena).';
      case 'diffFallthrough':
        return 'No se reconoce ningún patrón de regla de alto nivel para '
            'esta forma.';
    }
    return null;
  }
}

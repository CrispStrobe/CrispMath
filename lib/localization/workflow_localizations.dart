import 'package:flutter/material.dart';

/// Strings for the connected entry, graph and provider workflows.
/// Keep every locale exhaustive; coverage is enforced by unit tests.
enum WorkflowLabel {
  editExpression,
  mathPreview,
  expression,
  resetFocus,
  backspace,
  cursorLeft,
  cursorRight,
  evaluate,
  linkedSource,
  sourceExplanation,
  editVariable,
  detachSource,
  openSource,
  close,
  mathAssistance,
  configured,
  configureProvider,
  mathQuestion,
  questionHint,
  providerNotice,
  reviewExpression,
  translatedExpression,
  cancelRequest,
  cancelled,
  translate,
  retry,
  useCalculator,
  clarification,
  updatingResults,
  resultsFailed,
}

class WorkflowLocalizations {
  const WorkflowLocalizations(this.language);
  final String language;
  static WorkflowLocalizations of(BuildContext context) =>
      WorkflowLocalizations(Localizations.localeOf(context).languageCode);
  String text(WorkflowLabel key, [String value = '']) =>
      (translations[language] ?? translations['en']!)[key]!
          .replaceAll('{value}', value);

  static const translations = <String, Map<WorkflowLabel, String>>{
    'en': {
      WorkflowLabel.updatingResults: 'Updating results. You can keep editing.',
      WorkflowLabel.resultsFailed:
          'Could not update all results. Retry the calculation.',
      WorkflowLabel.editExpression: 'Edit expression',
      WorkflowLabel.mathPreview: 'Math preview',
      WorkflowLabel.expression: 'Expression',
      WorkflowLabel.resetFocus: 'Reset keyboard focus',
      WorkflowLabel.backspace: 'Backspace',
      WorkflowLabel.cursorLeft: 'Move cursor left',
      WorkflowLabel.cursorRight: 'Move cursor right',
      WorkflowLabel.evaluate: 'Evaluate',
      WorkflowLabel.linkedSource: 'Linked source for Y{value}',
      WorkflowLabel.sourceExplanation:
          'x is the graph variable. Other values come from the source document.',
      WorkflowLabel.editVariable: 'Edit {value}',
      WorkflowLabel.detachSource: 'Detach source',
      WorkflowLabel.openSource: 'Open source',
      WorkflowLabel.close: 'Close',
      WorkflowLabel.mathAssistance: 'Math assistance',
      WorkflowLabel.configured:
          'Configured: {value}. Connection is verified after a successful request.',
      WorkflowLabel.configureProvider:
          'Configure a provider endpoint and model in CrispAssist settings.',
      WorkflowLabel.mathQuestion: 'Math question',
      WorkflowLabel.questionHint: 'e.g. Integrate x squared',
      WorkflowLabel.providerNotice:
          'This sends your question to the configured provider. Review its translation; the calculator computes the result.',
      WorkflowLabel.reviewExpression:
          'Provider responded. Review or edit this expression:',
      WorkflowLabel.translatedExpression: 'Translated expression',
      WorkflowLabel.cancelRequest: 'Cancel request',
      WorkflowLabel.cancelled: 'Request cancelled. You can retry.',
      WorkflowLabel.translate: 'Translate',
      WorkflowLabel.retry: 'Retry',
      WorkflowLabel.useCalculator: 'Use in calculator',
      WorkflowLabel.clarification: 'More information needed: {value}',
    },
    'de': {
      WorkflowLabel.updatingResults:
          'Ergebnisse werden aktualisiert. Weitere Eingaben sind möglich.',
      WorkflowLabel.resultsFailed:
          'Nicht alle Ergebnisse konnten aktualisiert werden. Berechnung erneut versuchen.',
      WorkflowLabel.editExpression: 'Ausdruck bearbeiten',
      WorkflowLabel.mathPreview: 'Mathematische Vorschau',
      WorkflowLabel.expression: 'Ausdruck',
      WorkflowLabel.resetFocus: 'Tastaturfokus zurücksetzen',
      WorkflowLabel.backspace: 'Rücktaste',
      WorkflowLabel.cursorLeft: 'Cursor nach links',
      WorkflowLabel.cursorRight: 'Cursor nach rechts',
      WorkflowLabel.evaluate: 'Berechnen',
      WorkflowLabel.linkedSource: 'Verknüpfte Quelle für Y{value}',
      WorkflowLabel.sourceExplanation:
          'x ist die Graphvariable. Andere Werte stammen aus dem Quelldokument.',
      WorkflowLabel.editVariable: '{value} bearbeiten',
      WorkflowLabel.detachSource: 'Quelle trennen',
      WorkflowLabel.openSource: 'Quelle öffnen',
      WorkflowLabel.close: 'Schließen',
      WorkflowLabel.mathAssistance: 'Mathematikhilfe',
      WorkflowLabel.configured:
          'Konfiguriert: {value}. Die Verbindung wird nach einer erfolgreichen Anfrage bestätigt.',
      WorkflowLabel.configureProvider:
          'Endpunkt und Modell in den CrispAssist-Einstellungen konfigurieren.',
      WorkflowLabel.mathQuestion: 'Mathematische Frage',
      WorkflowLabel.questionHint: 'z. B. x zum Quadrat integrieren',
      WorkflowLabel.providerNotice:
          'Die Frage wird an den konfigurierten Anbieter gesendet. Übersetzung prüfen; der Rechner berechnet das Ergebnis.',
      WorkflowLabel.reviewExpression:
          'Anbieter hat geantwortet. Ausdruck prüfen oder bearbeiten:',
      WorkflowLabel.translatedExpression: 'Übersetzter Ausdruck',
      WorkflowLabel.cancelRequest: 'Anfrage abbrechen',
      WorkflowLabel.cancelled: 'Anfrage abgebrochen. Erneuter Versuch möglich.',
      WorkflowLabel.translate: 'Übersetzen',
      WorkflowLabel.retry: 'Erneut versuchen',
      WorkflowLabel.useCalculator: 'Im Rechner verwenden',
      WorkflowLabel.clarification: 'Weitere Angaben nötig: {value}',
    },
    'fr': {
      WorkflowLabel.updatingResults:
          'Mise à jour des résultats. Vous pouvez continuer à modifier.',
      WorkflowLabel.resultsFailed:
          'Impossible de mettre à jour tous les résultats. Relancez le calcul.',
      WorkflowLabel.editExpression: 'Modifier l’expression',
      WorkflowLabel.mathPreview: 'Aperçu mathématique',
      WorkflowLabel.expression: 'Expression',
      WorkflowLabel.resetFocus: 'Rétablir le focus du clavier',
      WorkflowLabel.backspace: 'Effacer le caractère',
      WorkflowLabel.cursorLeft: 'Déplacer le curseur à gauche',
      WorkflowLabel.cursorRight: 'Déplacer le curseur à droite',
      WorkflowLabel.evaluate: 'Calculer',
      WorkflowLabel.linkedSource: 'Source liée à Y{value}',
      WorkflowLabel.sourceExplanation:
          'x est la variable du graphique. Les autres valeurs proviennent du document source.',
      WorkflowLabel.editVariable: 'Modifier {value}',
      WorkflowLabel.detachSource: 'Détacher la source',
      WorkflowLabel.openSource: 'Ouvrir la source',
      WorkflowLabel.close: 'Fermer',
      WorkflowLabel.mathAssistance: 'Aide mathématique',
      WorkflowLabel.configured:
          'Configuré : {value}. La connexion est vérifiée après une requête réussie.',
      WorkflowLabel.configureProvider:
          'Configurer un point d’accès et un modèle dans les paramètres CrispAssist.',
      WorkflowLabel.mathQuestion: 'Question mathématique',
      WorkflowLabel.questionHint: 'p. ex. Intégrer x au carré',
      WorkflowLabel.providerNotice:
          'Votre question est envoyée au fournisseur configuré. Vérifiez la traduction ; la calculatrice calcule le résultat.',
      WorkflowLabel.reviewExpression:
          'Réponse reçue. Vérifiez ou modifiez cette expression :',
      WorkflowLabel.translatedExpression: 'Expression traduite',
      WorkflowLabel.cancelRequest: 'Annuler la requête',
      WorkflowLabel.cancelled: 'Requête annulée. Vous pouvez réessayer.',
      WorkflowLabel.translate: 'Traduire',
      WorkflowLabel.retry: 'Réessayer',
      WorkflowLabel.useCalculator: 'Utiliser dans la calculatrice',
      WorkflowLabel.clarification:
          'Informations supplémentaires nécessaires : {value}',
    },
    'es': {
      WorkflowLabel.updatingResults:
          'Actualizando resultados. Puedes seguir editando.',
      WorkflowLabel.resultsFailed:
          'No se pudieron actualizar todos los resultados. Reintenta el cálculo.',
      WorkflowLabel.editExpression: 'Editar expresión',
      WorkflowLabel.mathPreview: 'Vista matemática',
      WorkflowLabel.expression: 'Expresión',
      WorkflowLabel.resetFocus: 'Restablecer el foco del teclado',
      WorkflowLabel.backspace: 'Borrar carácter',
      WorkflowLabel.cursorLeft: 'Mover cursor a la izquierda',
      WorkflowLabel.cursorRight: 'Mover cursor a la derecha',
      WorkflowLabel.evaluate: 'Calcular',
      WorkflowLabel.linkedSource: 'Fuente vinculada de Y{value}',
      WorkflowLabel.sourceExplanation:
          'x es la variable del gráfico. Los demás valores provienen del documento fuente.',
      WorkflowLabel.editVariable: 'Editar {value}',
      WorkflowLabel.detachSource: 'Desvincular fuente',
      WorkflowLabel.openSource: 'Abrir fuente',
      WorkflowLabel.close: 'Cerrar',
      WorkflowLabel.mathAssistance: 'Ayuda matemática',
      WorkflowLabel.configured:
          'Configurado: {value}. La conexión se verifica tras una solicitud correcta.',
      WorkflowLabel.configureProvider:
          'Configura un punto de acceso y un modelo en los ajustes de CrispAssist.',
      WorkflowLabel.mathQuestion: 'Pregunta matemática',
      WorkflowLabel.questionHint: 'p. ej. Integrar x al cuadrado',
      WorkflowLabel.providerNotice:
          'La pregunta se envía al proveedor configurado. Revisa la traducción; la calculadora calcula el resultado.',
      WorkflowLabel.reviewExpression:
          'El proveedor respondió. Revisa o edita esta expresión:',
      WorkflowLabel.translatedExpression: 'Expresión traducida',
      WorkflowLabel.cancelRequest: 'Cancelar solicitud',
      WorkflowLabel.cancelled: 'Solicitud cancelada. Puedes reintentarlo.',
      WorkflowLabel.translate: 'Traducir',
      WorkflowLabel.retry: 'Reintentar',
      WorkflowLabel.useCalculator: 'Usar en calculadora',
      WorkflowLabel.clarification: 'Se necesita más información: {value}',
    },
  };
}

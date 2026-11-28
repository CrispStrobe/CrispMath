import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../engine/ai_output_attribution.dart';

class AiContentLabels {
  AiContentLabels(this.language);
  final String language;

  String _pick(String en, String de, String fr, String es) =>
      switch (language) {
        'de' => de,
        'fr' => fr,
        'es' => es,
        _ => en,
      };

  String title(AiOutputKind kind) => switch (kind) {
        AiOutputKind.generatedText => _pick(
            'AI-generated explanation',
            'KI-generierte Erklärung',
            'Explication générée par IA',
            'Explicación generada por IA',
          ),
        AiOutputKind.assistedExpression => _pick(
            'AI-assisted expression',
            'KI-unterstützter Ausdruck',
            'Expression assistée par IA',
            'Expresión asistida por IA',
          ),
        AiOutputKind.assistedTranscription => _pick(
            'AI-assisted transcription',
            'KI-unterstützte Erkennung',
            'Transcription assistée par IA',
            'Transcripción asistida por IA',
          ),
      };

  String body(AiOutputKind kind) => kind == AiOutputKind.generatedText
      ? _pick(
          'Check the explanation. The mathematical result was computed by the calculator.',
          'Prüfe die Erklärung. Das mathematische Ergebnis wurde vom Rechner berechnet.',
          'Vérifiez l’explication. Le résultat mathématique a été calculé par la calculatrice.',
          'Revisa la explicación. La calculadora calculó el resultado matemático.',
        )
      : _pick(
          'Review the expression before using it. Calculations are performed by the calculator.',
          'Prüfe den Ausdruck vor der Verwendung. Berechnungen führt der Rechner aus.',
          'Vérifiez l’expression avant utilisation. Les calculs sont effectués par la calculatrice.',
          'Revisa la expresión antes de usarla. La calculadora realiza los cálculos.',
        );

  String get copy => _pick(
        'Copy with source',
        'Mit Herkunft kopieren',
        'Copier avec la source',
        'Copiar con origen',
      );
  String get text => _pick(
        'Text with attribution',
        'Text mit Herkunft',
        'Texte avec attribution',
        'Texto con atribución',
      );
  String get json => _pick(
        'JSON with attribution',
        'JSON mit Herkunft',
        'JSON avec attribution',
        'JSON con atribución',
      );
  String get copied => _pick(
        'Copied with source',
        'Mit Herkunft kopiert',
        'Copié avec la source',
        'Copiado con origen',
      );
  String get partial => _pick(
        'Partial or unconfirmed response',
        'Vollständigkeit nicht bestätigt',
        'Réponse partielle ou non confirmée',
        'Respuesta parcial o no confirmada',
      );
  String source(AiOutputAttribution attribution) {
    final endpoint = switch (attribution.providerHost) {
      'local_endpoint' => _pick('Local endpoint', 'Lokaler Endpunkt',
          'Service local', 'Servicio local'),
      'configured_endpoint' => _pick(
          'Configured endpoint',
          'Konfigurierter Endpunkt',
          'Service configuré',
          'Servicio configurado'),
      _ => attribution.providerHost,
    };
    if (attribution.responseModel == null &&
        attribution.requestedModel == null) {
      return endpoint;
    }
    final modelLabel = attribution.responseModel != null
        ? _pick(
            'Response model',
            'Antwortmodell',
            'Modèle de réponse',
            'Modelo de respuesta',
          )
        : _pick(
            'Requested model',
            'Angefragtes Modell',
            'Modèle demandé',
            'Modelo solicitado',
          );
    return '$endpoint · $modelLabel: ${attribution.responseModel ?? attribution.requestedModel}';
  }
}

/// Adjacent disclosure; never inserted into the calculator's expression text.
class AiContentNotice extends StatelessWidget {
  const AiContentNotice({super.key, required this.kind, this.attribution});
  final AiOutputKind kind;
  final AiOutputAttribution? attribution;

  @override
  Widget build(BuildContext context) {
    final labels = AiContentLabels(
      Localizations.localeOf(context).languageCode,
    );
    return Semantics(
      container: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labels.title(kind),
            style: Theme.of(context).textTheme.labelLarge,
          ),
          Text(labels.body(kind), style: Theme.of(context).textTheme.bodySmall),
          if (attribution != null)
            Text(
              labels.source(attribution!),
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
    );
  }
}

/// Text exports retain a readable label; JSON exports retain structured origin.
class AiOutputCopyButton extends StatelessWidget {
  const AiOutputCopyButton({
    super.key,
    required this.content,
    required this.attribution,
    required this.complete,
  });
  final String content;
  final AiOutputAttribution attribution;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    final labels = AiContentLabels(
      Localizations.localeOf(context).languageCode,
    );
    return PopupMenuButton<String>(
      tooltip: labels.copy,
      icon: const Icon(Icons.copy_outlined),
      itemBuilder: (_) => [
        PopupMenuItem(value: 'text', child: Text(labels.text)),
        PopupMenuItem(value: 'json', child: Text(labels.json)),
      ],
      onSelected: (format) async {
        final text = format == 'json'
            ? attribution.exportJson(content, complete: complete)
            : '${labels.title(attribution.kind)}${complete ? '' : ' · ${labels.partial}'}\n'
                '${labels.source(attribution)}\n\n$content';
        await Clipboard.setData(ClipboardData(text: text));
        if (context.mounted) {
          ScaffoldMessenger.maybeOf(context)
              ?.showSnackBar(SnackBar(content: Text(labels.copied)));
        }
      },
    );
  }
}

// lib/widgets/app_showcase.dart
//
// "Our apps" on the About screen: every app of this developer account with
// its App Store and/or TestFlight link. Mirrors the Brickwright About-dialog
// gallery (same list, order and link rules).
//
// Source, 2026-10-27: App Store Connect (`GET /v1/apps`, app-info subtitles,
// public TestFlight group links) and the public iTunes lookup for which apps
// are live on the App Store. Icons (assets/app_showcase/, 128 px) are the App
// Store artwork, the latest TestFlight build's icon, or the app's own icon.
// Refresh by re-reading those sources; links never point anywhere else.

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../localization/app_localizations.dart';

class ShowcaseApp {
  final String slug;
  final String name;

  /// App Store id when the app is live there ([mac]: only the Mac App Store).
  final String? store;
  final bool mac;

  /// Public TestFlight code; with no [store] either, the app is a private
  /// beta and listed as coming soon.
  final String? beta;
  final bool self;
  final Map<String, String> description;

  const ShowcaseApp({
    required this.slug,
    required this.name,
    this.store,
    this.mac = false,
    this.beta,
    this.self = false,
    required this.description,
  });

  String get iconAsset => 'assets/app_showcase/$slug.png';
  Uri? get storeUri =>
      store == null ? null : Uri.parse('https://apps.apple.com/app/id$store');
  Uri? get betaUri => beta == null
      ? null
      : Uri.parse('https://testflight.apple.com/join/$beta');

  String describe(String languageCode) =>
      description[languageCode] ?? description['en']!;
}

const List<ShowcaseApp> showcaseApps = [
  ShowcaseApp(
    slug: 'brickwright',
    name: 'Brickwright',
    beta: 'UngCMwHZ',
    description: {
      'en': 'Code, circuits & machines',
      'de': 'Code, Schaltungen, Maschinen',
      'fr': 'Code, circuits et machines',
      'es': 'Código, circuitos y máquinas',
    },
  ),
  ShowcaseApp(
    slug: 'cometbeat',
    name: 'CometBeat',
    store: '6791962816',
    beta: 'cKUMvyqU',
    description: {
      'en': 'Learn music theory by playing',
      'de': 'Musik lernen mit Spielen',
      'fr': 'Apprendre la théorie musicale en jouant',
      'es': 'Aprende teoría musical jugando',
    },
  ),
  ShowcaseApp(
    slug: 'crispaudio',
    name: 'CrispAudio',
    store: '6791876962',
    beta: 'YpRwC6wF',
    description: {
      'en': 'SFX, voice FX & audio editor',
      'de': 'Effekte, Stimm-FX & Audio-Editor',
      'fr': 'Effets, effets vocaux et éditeur audio',
      'es': 'Efectos, efectos de voz y editor de audio',
    },
  ),
  ShowcaseApp(
    slug: 'crispbingo',
    name: 'CrispBingo',
    beta: '3CG3SfZ9',
    description: {
      'en': 'Bingo & Tombola for groups',
      'de': 'Bingo & Tombola für Gruppen',
      'fr': 'Bingo et tombola en groupe',
      'es': 'Bingo y tómbola para grupos',
    },
  ),
  ShowcaseApp(
    slug: 'crispchess',
    name: 'CrispChess',
    beta: 'UCk7DK56',
    description: {
      'en': 'Chess through human eyes',
      'de': 'Schach mit menschlichem Blick',
      'fr': 'Les échecs vus par un humain',
      'es': 'Ajedrez con ojos humanos',
    },
  ),
  ShowcaseApp(
    slug: 'crispcloud',
    name: 'CrispCloud',
    beta: 'eFXzu56b',
    description: {
      'en': 'Multi-cloud file manager',
      'de': 'Dateimanager für viele Clouds',
      'fr': 'Gestionnaire de fichiers multi-cloud',
      'es': 'Gestor de archivos multinube',
    },
  ),
  ShowcaseApp(
    slug: 'crispdeck',
    name: 'CrispDeck',
    beta: 'hYwFh4Ut',
    description: {
      'en': 'Mastodon · Bluesky · Threads',
      'de': 'Mastodon · Bluesky · Threads',
      'fr': 'Mastodon · Bluesky · Threads',
      'es': 'Mastodon · Bluesky · Threads',
    },
  ),
  ShowcaseApp(
    slug: 'crispmath',
    name: 'CrispMath',
    beta: 'E6HdVhTx',
    self: true,
    description: {
      'en': 'CAS calculator & graphing',
      'de': 'CAS-Rechner & Funktionsgraphen',
      'fr': 'Calculatrice formelle et graphiques',
      'es': 'Calculadora CAS y gráficas',
    },
  ),
  ShowcaseApp(
    slug: 'crispmesh',
    name: 'CrispMesh',
    beta: 'Pk6ds8vY',
    description: {
      'en': '3D models from turntable photos',
      'de': '3D-Modelle aus Drehteller-Fotos',
      'fr': 'Modèles 3D à partir de photos sur plateau tournant',
      'es': 'Modelos 3D a partir de fotos en plataforma giratoria',
    },
  ),
  ShowcaseApp(
    slug: 'crisperplayer',
    name: 'CrisperPlayer',
    description: {
      'en': 'Your audiobooks, your place',
      'de': 'Deine Hörbücher, dein Ort',
      'fr': 'Vos livres audio, chez vous',
      'es': 'Tus audiolibros, a tu manera',
    },
  ),
  ShowcaseApp(
    slug: 'crisperweaver',
    name: 'CrisperWeaver',
    store: '6789600762',
    beta: 'svwfvHvh',
    description: {
      'en': 'Offline transcription & speech',
      'de': 'Offline-Transkription & Sprachausgabe',
      'fr': 'Transcription et synthèse vocale hors ligne',
      'es': 'Transcripción y voz sin conexión',
    },
  ),
  ShowcaseApp(
    slug: 'crispsorter',
    name: 'CrispSorter',
    beta: 'eqpChBGM',
    description: {
      'en': 'Organise & search documents with local AI',
      'de': 'Dokumente mit lokaler KI ordnen & durchsuchen',
      'fr': 'Classer et rechercher des documents avec une IA locale',
      'es': 'Organiza y busca documentos con IA local',
    },
  ),
  ShowcaseApp(
    slug: 'crispsudoku',
    name: 'CrispSudoku',
    store: '6788990894',
    beta: 'gjFeKMcH',
    description: {
      'en': 'Classic, Killer, Thermo & more',
      'de': 'Klassisch, Killer, Thermo',
      'fr': 'Classique, Killer, Thermo et plus',
      'es': 'Clásico, Killer, Thermo y más',
    },
  ),
  ShowcaseApp(
    slug: 'crisptuner',
    name: 'CrispTuner',
    beta: 'nfCbAzy4',
    description: {
      'en': 'Chromatic tuner & temperaments',
      'de': 'Stimmgerät mit Temperaturen',
      'fr': 'Accordeur chromatique et tempéraments',
      'es': 'Afinador cromático y temperamentos',
    },
  ),
  ShowcaseApp(
    slug: 'hectopolis',
    name: 'Hectopolis',
    store: '6809142647',
    mac: true,
    beta: 'paBCcWnH',
    description: {
      'en': 'Build, observe, understand',
      'de': 'Bauen, beobachten, verstehen',
      'fr': 'Construire, observer, comprendre',
      'es': 'Construir, observar, comprender',
    },
  ),
  ShowcaseApp(
    slug: 'kerotakis',
    name: 'Kerotakis',
    store: '6805214816',
    beta: 'P3WxEdqp',
    description: {
      'en': 'Chemistry that computes',
      'de': 'Chemie, die wirklich rechnet',
      'fr': 'La chimie qui calcule',
      'es': 'Química que calcula',
    },
  ),
  ShowcaseApp(
    slug: 'naga',
    name: 'Naga – The Snake Game',
    beta: 'SuVAjkwH',
    description: {
      'en': '27 original twists on Snake',
      'de': '27 neue Wendungen für Snake',
      'fr': '27 variantes originales de Snake',
      'es': '27 giros originales de Snake',
    },
  ),
  ShowcaseApp(
    slug: 'numbernebula',
    name: 'NumberNebula',
    store: '6789984849',
    mac: true,
    beta: 'GDzrzSF5',
    description: {
      'en': 'Cosmic math games for kids',
      'de': 'Kosmische Mathe-Spiele',
      'fr': 'Jeux de maths cosmiques pour enfants',
      'es': 'Juegos de matemáticas cósmicos para niños',
    },
  ),
  ShowcaseApp(
    slug: 'word-universe',
    name: 'Word Universe',
    store: '6790143931',
    beta: '6CQMmAnt',
    description: {
      'en': 'German & English word games',
      'de': 'Wortschatz spielerisch üben',
      'fr': 'Jeux de mots en allemand et en anglais',
      'es': 'Juegos de palabras en alemán e inglés',
    },
  ),
];

/// Live apps first, then betas, each alphabetically; this app last.
List<ShowcaseApp> orderedShowcaseApps() {
  int flag(bool b) => b ? 1 : 0;
  return [...showcaseApps]..sort((a, b) {
      final self = flag(a.self) - flag(b.self);
      if (self != 0) return self;
      final live = flag(b.store != null) - flag(a.store != null);
      if (live != 0) return live;
      return a.name.compareTo(b.name);
    });
}

class AppShowcase extends StatelessWidget {
  const AppShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    return Column(
      key: const ValueKey('about-app-showcase'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.aboutOurAppsIntro, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            // Two columns once there is room for two 230 px tiles.
            final columns = (constraints.maxWidth / 238).floor().clamp(1, 3);
            final width = (constraints.maxWidth - 8 * (columns - 1)) / columns;
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final app in orderedShowcaseApps())
                  SizedBox(
                    width: width,
                    child: _AppTile(app: app, lang: lang),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _AppTile extends StatelessWidget {
  final ShowcaseApp app;
  final String lang;
  const _AppTile({required this.app, required this.lang});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      key: ValueKey('about-app-${app.slug}'),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              app.iconAsset,
              width: 44,
              height: 44,
              excludeFromSemantics: true,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: app.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      if (app.self)
                        TextSpan(
                          text: ' (${l.aboutThisApp})',
                          style: TextStyle(
                            color: scheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  app.describe(lang),
                  style: text.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (app.storeUri != null)
                      _LinkChip(
                        label: app.mac ? l.aboutMacAppStore : l.aboutAppStore,
                        uri: app.storeUri!,
                        background: const Color(0xFF0F172A),
                        foreground: Colors.white,
                      ),
                    if (app.betaUri != null)
                      _LinkChip(
                        label: l.aboutTestFlight,
                        uri: app.betaUri!,
                        background: const Color(0xFFE0F2FE),
                        foreground: const Color(0xFF075985),
                      ),
                    if (app.storeUri == null && app.betaUri == null)
                      _LinkChip(
                        label: l.aboutComingSoon,
                        background: scheme.onSurface.withValues(alpha: 0.12),
                        foreground: scheme.onSurface,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkChip extends StatelessWidget {
  final String label;
  final Uri? uri;
  final Color background;
  final Color foreground;
  const _LinkChip({
    required this.label,
    this.uri,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: foreground,
        ),
      ),
    );
    if (uri == null) return chip;
    return Semantics(
      link: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () => launchUrl(uri!, mode: LaunchMode.externalApplication),
        child: chip,
      ),
    );
  }
}

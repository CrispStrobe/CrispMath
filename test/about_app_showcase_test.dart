// "Our apps" on the About screen lists every app of the developer account
// with its App Store and/or TestFlight link (lib/widgets/app_showcase.dart).

import 'dart:io';
import 'dart:typed_data';

import 'package:crisp_math/localization/app_localizations.dart';
import 'package:crisp_math/widgets/app_showcase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host(Locale locale) => MaterialApp(
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('de'),
          Locale('fr'),
          Locale('es'),
        ],
        locale: locale,
        home: const Scaffold(body: SingleChildScrollView(child: AppShowcase())),
      );

  test(
    'every listed app has its icon, four descriptions and only Apple links',
    () {
      expect(showcaseApps.length, greaterThanOrEqualTo(19));
      expect(
        {for (final app in showcaseApps) app.slug}.length,
        showcaseApps.length,
      );
      final pubspec = File('pubspec.yaml').readAsStringSync();
      expect(pubspec, contains('- assets/app_showcase/'));
      for (final app in showcaseApps) {
        expect(File(app.iconAsset).existsSync(), isTrue, reason: app.slug);
        for (final lang in const ['en', 'de', 'fr', 'es']) {
          expect(
            app.description[lang],
            isNotEmpty,
            reason: '${app.slug} $lang',
          );
        }
        if (app.store != null) {
          expect(app.store, matches(RegExp(r'^\d{9,11}$')), reason: app.slug);
          expect(app.storeUri!.host, 'apps.apple.com');
        }
        if (app.beta != null) {
          expect(
            app.beta,
            matches(RegExp(r'^[A-Za-z0-9]{8}$')),
            reason: app.slug,
          );
          expect(app.betaUri!.host, 'testflight.apple.com');
        }
      }
      expect(
        [
          for (final app in showcaseApps)
            if (app.self) app.slug,
        ],
        ['crispmath'],
      );
    },
  );

  test('only App Store apps are listed for now, alphabetically', () {
    final listed = orderedShowcaseApps();
    expect(listed.every((app) => app.store != null), isTrue);
    expect([
      for (final app in listed) app.slug
    ], [
      'cometbeat',
      'crispaudio',
      'crisperweaver',
      'crispsudoku',
      'hectopolis',
      'kerotakis',
      'numbernebula',
      'word-universe',
    ]);
  });

  test('with betas: live apps first, then betas alphabetically, this app last',
      () {
    final ordered = orderedShowcaseApps(includeBetas: true);
    expect(ordered.length, showcaseApps.length);
    expect(ordered.last.slug, 'crispmath');
    final rest = ordered.sublist(0, ordered.length - 1);
    final firstBeta = rest.indexWhere((app) => app.store == null);
    expect(rest.skip(firstBeta).every((app) => app.store == null), isTrue);
    final live = [for (final app in rest.take(firstBeta)) app.name.toLowerCase()];
    expect(live, [...live]..sort());
  });

  testWidgets('renders only App Store apps with store and TestFlight chips', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(host(const Locale('en')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('about-app-showcase')), findsOneWidget);
    for (final app in showcaseApps) {
      expect(find.byKey(ValueKey('about-app-${app.slug}')),
          app.store != null ? findsOneWidget : findsNothing,
          reason: app.slug);
    }
    expect(find.text('Mac App Store'), findsNWidgets(2));
    expect(find.text('App Store'), findsNWidgets(6));
    expect(find.text('TestFlight'), findsNWidgets(8));
    expect(find.text('Coming soon'), findsNothing);
    expect(find.textContaining('this app'), findsNothing);
  });

  testWidgets('uses the German chrome and descriptions', (tester) async {
    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(host(const Locale('de')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Weitere Apps desselben'), findsOneWidget);
    expect(find.text('Chemie, die wirklich rechnet'), findsOneWidget);
  });

  test('icons are real 128 px PNGs', () async {
    for (final app in showcaseApps) {
      final bytes = File(app.iconAsset).readAsBytesSync();
      // PNG signature, then the IHDR width/height (big-endian at 16..23).
      expect(
          bytes.sublist(0, 8),
          [
            0x89,
            0x50,
            0x4E,
            0x47,
            0x0D,
            0x0A,
            0x1A,
            0x0A,
          ],
          reason: app.slug);
      final data = ByteData.sublistView(bytes);
      expect(data.getUint32(16), 128, reason: app.slug);
      expect(data.getUint32(20), 128, reason: app.slug);
    }
  });
}

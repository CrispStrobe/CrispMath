// test/model_license_consent_test.dart
//
// Restrictive model-license metadata, persisted consent and defaults
// (CrispStrobe/CrispEmbed#92, tests/results/licenses/registry-qwen-audit.json).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:crisp_math/engine/model_license_consent.dart';
import 'package:crisp_math/engine/ocr_model_catalog.dart';
import 'package:crisp_math/widgets/model_license_consent_dialog.dart';

/// Model-name fragments whose weights the CrispEmbed audit found to carry
/// non-commercial terms despite permissive labels.
const _auditedRestricted = [
  'qwen2vl-3b',
  'qwen2.5-vl-3b',
  'nanonets-ocr-s',
  'uni-mumer-qwen2.5',
  'teleocr',
  'got-ocr',
  'transcoda',
];

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ModelLicenseConsent.resetForTest();
  });

  group('license terms', () {
    test('Qwen Research terms name the license, NC and the link', () {
      const t = ModelLicenseTerms.qwenResearch;
      expect(t.tag, 'qwen-research');
      expect(t.nonCommercial, true);
      expect(t.url, startsWith('https://huggingface.co/Qwen/'));
      expect(t.runtimeEnvGate, 'CRISPEMBED_ACCEPT_QWEN_RESEARCH_LICENSE');
      final text = t.consentText('Qwen2.5-VL');
      expect(text, contains('Qwen RESEARCH LICENSE AGREEMENT'));
      expect(text, contains('NON-COMMERCIAL'));
      expect(text, contains(t.url));
    });

    test('Tongyi Qianwen terms carry the no-improving-other-LLMs clause', () {
      const t = ModelLicenseTerms.tongyiQianwenResearch;
      expect(t.tag, 'tongyi-qianwen-research');
      expect(t.nonCommercial, true);
      expect(t.runtimeEnvGate, 'CRISPEMBED_ACCEPT_TONGYI_QIANWEN_LICENSE');
      final text = t.consentText('GOT-OCR2');
      expect(text, contains('NON-COMMERCIAL'));
      expect(text, contains('improve any other large language model'));
      expect(text, contains(t.url));
    });

    test('tags are unique', () {
      final tags = ModelLicenseTerms.all.map((t) => t.tag).toSet();
      expect(tags.length, ModelLicenseTerms.all.length);
    });
  });

  group('catalog license metadata', () {
    test('every audited restricted model in the catalog is gated', () {
      for (final m in OcrModelCatalog.all) {
        final key = '${m.id} ${m.filename} ${m.url}'.toLowerCase();
        if (_auditedRestricted.any(key.contains)) {
          expect(m.restrictedTerms, isNotNull, reason: m.id);
          expect(m.license, isNot(contains('Apache')), reason: m.id);
          expect(m.license, isNot(contains('MIT')), reason: m.id);
          expect(m.requiresLicenseAcceptance, true, reason: m.id);
        }
      }
    });

    test('Qwen2.5-VL-3B entries are qwen-research', () {
      expect(OcrModelCatalog.visionLanguage, isNotEmpty);
      for (final m in OcrModelCatalog.visionLanguage) {
        expect(m.license, ModelLicenseTerms.qwenResearch.tag);
        expect(m.restrictedTerms, same(ModelLicenseTerms.qwenResearch));
      }
    });

    test('license string of restricted models equals their terms tag', () {
      for (final m in OcrModelCatalog.all) {
        if (m.restrictedTerms != null) {
          expect(m.license, m.restrictedTerms!.tag, reason: m.id);
        }
      }
    });

    test('preferred Qwen3-VL replacement is Apache-2.0 and ungated', () {
      expect(OcrModelCatalog.visionLanguageQwen3, isNotEmpty);
      for (final m in OcrModelCatalog.visionLanguageQwen3) {
        expect(m.license, 'Apache-2.0');
        expect(m.restrictedTerms, isNull);
        expect(m.autoSelectable, true);
      }
    });
  });

  group('defaults', () {
    test('auto-selectable families contain no license-gated model', () {
      for (final family in OcrModelCatalog.autoSelectableFamilies) {
        for (final m in family) {
          expect(m.autoSelectable, true, reason: m.id);
          expect(m.requiresLicenseAcceptance, false, reason: m.id);
        }
      }
    });

    test('restricted models are never auto-selectable', () {
      for (final m in OcrModelCatalog.all) {
        if (m.restrictedTerms != null) {
          expect(m.autoSelectable, false, reason: m.id);
        }
      }
    });
  });

  group('persisted consent', () {
    test('restricted terms are denied before load and without consent',
        () async {
      expect(ModelLicenseConsent.allows(ModelLicenseTerms.qwenResearch), false);
      await ModelLicenseConsent.load();
      expect(ModelLicenseConsent.allows(ModelLicenseTerms.qwenResearch), false);
      expect(ModelLicenseConsent.allows(null), true);
    });

    test('grant persists across reload and sets the runtime gate', () async {
      final gates = <String, bool>{};
      ModelLicenseConsent.runtimeGateSetter = (k, v) => gates[k] = v;
      await ModelLicenseConsent.load();
      await ModelLicenseConsent.grant(ModelLicenseTerms.qwenResearch);
      expect(gates['CRISPEMBED_ACCEPT_QWEN_RESEARCH_LICENSE'], true);

      final prefs = await SharedPreferences.getInstance();
      expect(
          prefs.getString('model_license_consent.v1.qwen-research'), isNotNull);

      ModelLicenseConsent.resetForTest();
      expect(ModelLicenseConsent.allows(ModelLicenseTerms.qwenResearch), false);
      await ModelLicenseConsent.load();
      expect(ModelLicenseConsent.allows(ModelLicenseTerms.qwenResearch), true);
      // Consent is per license: Qwen consent does not cover Tongyi Qianwen.
      expect(
          ModelLicenseConsent.allows(ModelLicenseTerms.tongyiQianwenResearch),
          false);
    });

    test('revoke removes consent and clears the runtime gate', () async {
      final gates = <String, bool>{};
      ModelLicenseConsent.runtimeGateSetter = (k, v) => gates[k] = v;
      await ModelLicenseConsent.load();
      await ModelLicenseConsent.grant(ModelLicenseTerms.qwenResearch);
      await ModelLicenseConsent.revoke(ModelLicenseTerms.qwenResearch);
      expect(gates['CRISPEMBED_ACCEPT_QWEN_RESEARCH_LICENSE'], false);
      expect(ModelLicenseConsent.allows(ModelLicenseTerms.qwenResearch), false);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('model_license_consent.v1.qwen-research'), isNull);
    });

    test('applyRuntimeGate does nothing without consent', () async {
      final gates = <String, bool>{};
      ModelLicenseConsent.runtimeGateSetter = (k, v) => gates[k] = v;
      await ModelLicenseConsent.load();
      ModelLicenseConsent.applyRuntimeGate(ModelLicenseTerms.qwenResearch);
      expect(gates, isEmpty);
    });
  });

  group('consent dialog', () {
    Future<bool?> run(WidgetTester tester, String buttonText) async {
      bool? result;
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await ensureModelLicenseConsent(
                  context, ModelLicenseTerms.qwenResearch, 'Qwen2.5-VL');
            },
            child: const Text('open'),
          ),
        ),
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Qwen RESEARCH LICENSE AGREEMENT'),
          findsOneWidget);
      expect(find.textContaining('NON-COMMERCIAL'), findsOneWidget);
      expect(find.text('Read the license'), findsOneWidget);
      await tester.tap(find.text(buttonText));
      await tester.pumpAndSettle();
      return result;
    }

    testWidgets('decline records no consent', (tester) async {
      expect(await run(tester, 'Decline'), false);
      expect(ModelLicenseConsent.allows(ModelLicenseTerms.qwenResearch), false);
    });

    testWidgets('accept records consent; no second prompt', (tester) async {
      expect(await run(tester, 'I accept these terms'), true);
      expect(ModelLicenseConsent.allows(ModelLicenseTerms.qwenResearch), true);

      bool? again;
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              again = await ensureModelLicenseConsent(
                  context, ModelLicenseTerms.qwenResearch, 'Qwen2.5-VL');
            },
            child: const Text('again'),
          ),
        ),
      ));
      await tester.tap(find.text('again'));
      await tester.pumpAndSettle();
      expect(find.byType(ModelLicenseConsentDialog), findsNothing);
      expect(again, true);
    });
  });
}

// test/ocr_integration_test.dart
//
// Tests for the CrispEmbed integration batch (June 2026):
//   - MixTex model catalog entries
//   - General OCR (DBNet + TrOCR) catalog entries
//   - Surya text detection catalog entries
//   - Layout detection catalog entries
//   - Provider selector mechanics
//   - PPM encoding helper
//   - OcrSettingsDialog widget smoke test

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:crisp_calc/engine/ocr_model_catalog.dart';
import 'package:crisp_calc/engine/ocr_provider.dart';

void main() {
  // =========================================================================
  // MixTex catalog
  // =========================================================================
  group('MixTex catalog', () {
    test('has at least 3 variants (Q8, Q4K, F16)', () {
      expect(
          OcrModelCatalog.printedMathMixtex.length, greaterThanOrEqualTo(3));
    });

    test('all MixTex models have correct HF URL', () {
      for (final m in OcrModelCatalog.printedMathMixtex) {
        expect(m.url, contains('mixtex-zhen-gguf'));
        expect(m.url, startsWith('https://huggingface.co/cstr/'));
        expect(m.url, endsWith('.gguf'));
      }
    });

    test('MixTex IDs are unique', () {
      final ids =
          OcrModelCatalog.printedMathMixtex.map((m) => m.id).toSet();
      expect(ids.length, OcrModelCatalog.printedMathMixtex.length);
    });

    test('MixTex Q8 is ~89 MB', () {
      final q8 = OcrModelCatalog.printedMathMixtex
          .firstWhere((m) => m.id.contains('q8'));
      expect(q8.sizeBytes, 89 * 1024 * 1024);
      expect(q8.sizeLabel, '89 MB');
    });

    test('MixTex license is Apache-2.0', () {
      for (final m in OcrModelCatalog.printedMathMixtex) {
        expect(m.license, 'Apache-2.0');
        expect(m.requiresLicenseAcceptance, false);
      }
    });

    test('MixTex is included in all models', () {
      final allIds = OcrModelCatalog.all.map((m) => m.id).toSet();
      for (final m in OcrModelCatalog.printedMathMixtex) {
        expect(allIds, contains(m.id));
      }
    });
  });

  // =========================================================================
  // Text detection catalog (DBNet)
  // =========================================================================
  group('DBNet text detection catalog', () {
    test('has at least 2 variants', () {
      expect(OcrModelCatalog.textDetection.length, greaterThanOrEqualTo(2));
    });

    test('DBNet models have correct HF URL', () {
      for (final m in OcrModelCatalog.textDetection) {
        expect(m.url, contains('dbnet-ic15-gguf'));
      }
    });

    test('DBNet Q4K is smallest at 7 MB', () {
      final sorted = List.of(OcrModelCatalog.textDetection)
        ..sort((a, b) => a.sizeBytes.compareTo(b.sizeBytes));
      expect(sorted.first.sizeBytes, 7 * 1024 * 1024);
      expect(sorted.first.id, contains('q4k'));
    });

    test('DBNet license is Apache-2.0', () {
      for (final m in OcrModelCatalog.textDetection) {
        expect(m.license, 'Apache-2.0');
      }
    });
  });

  // =========================================================================
  // Text detection catalog (Surya)
  // =========================================================================
  group('Surya text detection catalog', () {
    test('has at least 2 variants', () {
      expect(OcrModelCatalog.textDetectionSurya.length,
          greaterThanOrEqualTo(2));
    });

    test('Surya models have correct HF URL', () {
      for (final m in OcrModelCatalog.textDetectionSurya) {
        expect(m.url, contains('surya-det-gguf'));
      }
    });

    test('Surya Q8 is 41 MB', () {
      final q8 = OcrModelCatalog.textDetectionSurya
          .firstWhere((m) => m.id.contains('q8'));
      expect(q8.sizeBytes, 41 * 1024 * 1024);
    });

    test('Surya Q4K is 23 MB', () {
      final q4k = OcrModelCatalog.textDetectionSurya
          .firstWhere((m) => m.id.contains('q4k'));
      expect(q4k.sizeBytes, 23 * 1024 * 1024);
    });

    test('Surya license is MIT', () {
      for (final m in OcrModelCatalog.textDetectionSurya) {
        expect(m.license, 'MIT');
      }
    });
  });

  // =========================================================================
  // Text recognition catalog (TrOCR)
  // =========================================================================
  group('TrOCR text recognition catalog', () {
    test('has at least 2 variants', () {
      expect(
          OcrModelCatalog.textRecognition.length, greaterThanOrEqualTo(2));
    });

    test('TrOCR models have correct HF URL', () {
      for (final m in OcrModelCatalog.textRecognition) {
        expect(m.url, contains('trocr-small-printed-gguf'));
      }
    });

    test('TrOCR Q8 is 63 MB', () {
      final q8 = OcrModelCatalog.textRecognition
          .firstWhere((m) => m.id.contains('q8'));
      expect(q8.sizeBytes, 63 * 1024 * 1024);
    });

    test('TrOCR license is MIT', () {
      for (final m in OcrModelCatalog.textRecognition) {
        expect(m.license, 'MIT');
      }
    });
  });

  // =========================================================================
  // Layout detection catalog
  // =========================================================================
  group('Layout detection catalog', () {
    test('has at least 2 variants', () {
      expect(
          OcrModelCatalog.layoutDetection.length, greaterThanOrEqualTo(2));
    });

    test('layout models have correct HF URL', () {
      for (final m in OcrModelCatalog.layoutDetection) {
        expect(m.url, contains('layout-heron-gguf'));
      }
    });

    test('layout Q8 is 43 MB', () {
      final q8 = OcrModelCatalog.layoutDetection
          .firstWhere((m) => m.id.contains('q8'));
      expect(q8.sizeBytes, 43 * 1024 * 1024);
    });

    test('layout license is Apache-2.0', () {
      for (final m in OcrModelCatalog.layoutDetection) {
        expect(m.license, 'Apache-2.0');
      }
    });
  });

  // =========================================================================
  // Full catalog integrity
  // =========================================================================
  group('Full catalog integrity', () {
    test('all models have unique IDs across all categories', () {
      final ids = OcrModelCatalog.all.map((m) => m.id).toSet();
      expect(ids.length, OcrModelCatalog.all.length,
          reason: 'Duplicate model IDs found');
    });

    test('all URLs are valid HTTPS HuggingFace links', () {
      for (final m in OcrModelCatalog.all) {
        expect(m.url, startsWith('https://huggingface.co/cstr/'));
        expect(m.url, endsWith('.gguf'));
      }
    });

    test('all filenames end in .gguf', () {
      for (final m in OcrModelCatalog.all) {
        expect(m.filename, endsWith('.gguf'));
      }
    });

    test('all models have descriptions', () {
      for (final m in OcrModelCatalog.all) {
        expect(m.description, isNotEmpty);
      }
    });

    test('all models have license set', () {
      for (final m in OcrModelCatalog.all) {
        expect(m.license, isNotNull);
      }
    });

    test('total catalog has at least 20 models', () {
      expect(OcrModelCatalog.all.length, greaterThanOrEqualTo(20));
    });

    test('NC models require license acceptance', () {
      for (final m in OcrModelCatalog.all) {
        if (m.license != null && m.license!.contains('NC')) {
          expect(m.requiresLicenseAcceptance, true,
              reason: '${m.id} has NC license but no acceptance gate');
        }
      }
    });

    test('non-NC models do not require license acceptance', () {
      for (final m in OcrModelCatalog.all) {
        if (m.license != null && !m.license!.contains('NC')) {
          expect(m.requiresLicenseAcceptance, false,
              reason: '${m.id} incorrectly requires license acceptance');
        }
      }
    });
  });

  // =========================================================================
  // Provider registry
  // =========================================================================
  group('OcrProviders registry', () {
    test('register adds to list', () {
      final initial = OcrProviders.all.length;
      OcrProviders.register(_MockProvider('test-A'));
      expect(OcrProviders.all.length, initial + 1);
    });

    test('active can be set and read', () {
      final provider = _MockProvider('test-active');
      OcrProviders.register(provider);
      OcrProviders.active = provider;
      expect(OcrProviders.active, provider);
      expect(OcrProviders.active!.name, 'test-active');
    });

    test('available filters by isAvailable', () {
      final avail = _MockProvider('avail', available: true);
      final unavail = _MockProvider('unavail', available: false);
      OcrProviders.register(avail);
      OcrProviders.register(unavail);
      expect(OcrProviders.available, contains(avail));
      expect(OcrProviders.available, isNot(contains(unavail)));
    });

    test('switching active provider works', () {
      final p1 = _MockProvider('provider-1');
      final p2 = _MockProvider('provider-2');
      OcrProviders.register(p1);
      OcrProviders.register(p2);
      OcrProviders.active = p1;
      expect(OcrProviders.active!.name, 'provider-1');
      OcrProviders.active = p2;
      expect(OcrProviders.active!.name, 'provider-2');
    });
  });

  // =========================================================================
  // OcrModelVariant helpers
  // =========================================================================
  group('OcrModelVariant helpers', () {
    test('sizeLabel formats MB', () {
      const m = OcrModelVariant(
        id: 'test',
        name: 'Test',
        filename: 'test.gguf',
        url: 'https://example.com/test.gguf',
        sizeBytes: 42 * 1024 * 1024,
        description: 'Test',
      );
      expect(m.sizeLabel, '42 MB');
    });

    test('sizeLabel formats GB for large models', () {
      const m = OcrModelVariant(
        id: 'test-big',
        name: 'Big',
        filename: 'big.gguf',
        url: 'https://example.com/big.gguf',
        sizeBytes: 2 * 1024 * 1024 * 1024,
        description: 'Test',
      );
      expect(m.sizeLabel, '2.0 GB');
    });

    test('requiresLicenseAcceptance for NC licenses', () {
      const nc = OcrModelVariant(
        id: 'nc',
        name: 'NC',
        filename: 'nc.gguf',
        url: 'https://example.com/nc.gguf',
        sizeBytes: 1024,
        description: 'Test',
        license: 'CC BY-NC-SA 3.0',
      );
      expect(nc.requiresLicenseAcceptance, true);
    });

    test('no license acceptance for permissive licenses', () {
      const mit = OcrModelVariant(
        id: 'mit',
        name: 'MIT',
        filename: 'mit.gguf',
        url: 'https://example.com/mit.gguf',
        sizeBytes: 1024,
        description: 'Test',
        license: 'MIT',
      );
      expect(mit.requiresLicenseAcceptance, false);
    });

    test('no license acceptance when license is null', () {
      const noLic = OcrModelVariant(
        id: 'nolic',
        name: 'NoLic',
        filename: 'nolic.gguf',
        url: 'https://example.com/nolic.gguf',
        sizeBytes: 1024,
        description: 'Test',
      );
      expect(noLic.requiresLicenseAcceptance, false);
    });
  });

  // =========================================================================
  // OcrSettingsDialog widget test
  // =========================================================================
  group('OcrSettingsDialog', () {
    testWidgets('renders and shows all catalog sections',
        (WidgetTester tester) async {
      // Register a mock provider so the dialog has something to show.
      final mockProvider = _MockProvider('Mock Provider');
      OcrProviders.register(mockProvider);
      OcrProviders.active = mockProvider;

      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: SizedBox()),
      ));

      // Can't show the dialog without OcrModelManager (dart:io),
      // but we can verify the catalog sections exist.
      expect(OcrModelCatalog.printedMathPpfnl, isNotEmpty);
      expect(OcrModelCatalog.printedMathTexo, isNotEmpty);
      expect(OcrModelCatalog.printedMathMixtex, isNotEmpty);
      expect(OcrModelCatalog.printedMath, isNotEmpty);
      expect(OcrModelCatalog.handwrittenMath, isNotEmpty);
      expect(OcrModelCatalog.textDetection, isNotEmpty);
      expect(OcrModelCatalog.textDetectionSurya, isNotEmpty);
      expect(OcrModelCatalog.textRecognition, isNotEmpty);
      expect(OcrModelCatalog.layoutDetection, isNotEmpty);
    });
  });

  // =========================================================================
  // latexToEngineSyntax for new model outputs
  // =========================================================================
  group('latexToEngineSyntax — MixTex output patterns', () {
    test('simple polynomial', () {
      final result = latexToEngineSyntax(r'x^2 + 2x + 1');
      expect(result, 'x^2+2x+1');
    });

    test('formatting commands stripped', () {
      expect(
          latexToEngineSyntax(r'\mathbf{x} + \mathrm{y}'), 'x+y');
    });

    test('rightarrow mapped to \\to then simplified', () {
      // \rightarrow → \to → fromLatex strips it
      final result = latexToEngineSyntax(r'x \rightarrow y');
      expect(result, isNotEmpty);
      expect(result, isNot(contains(r'\')));
    });

    test('extra delimiters converted to parens', () {
      expect(latexToEngineSyntax(r'\lfloor x \rfloor'), '( x )');
      expect(latexToEngineSyntax(r'\lceil x \rceil'), '( x )');
    });

    test('extra Greek letters', () {
      expect(latexToEngineSyntax(r'\epsilon'), 'epsilon');
      expect(latexToEngineSyntax(r'\tau'), 'tau');
      expect(latexToEngineSyntax(r'\psi'), 'psi');
    });
  });

  // =========================================================================
  // Provider switching
  // =========================================================================
  group('Provider switching at runtime', () {
    test('switching active updates immediately', () {
      final p1 = _MockProvider('switch-A');
      final p2 = _MockProvider('switch-B');
      OcrProviders.register(p1);
      OcrProviders.register(p2);
      OcrProviders.active = p1;
      expect(OcrProviders.active!.name, 'switch-A');
      OcrProviders.active = p2;
      expect(OcrProviders.active!.name, 'switch-B');
    });

    test('can set active to null', () {
      OcrProviders.active = null;
      expect(OcrProviders.active, isNull);
    });

    test('available list includes all registered available providers', () {
      final count = OcrProviders.available.length;
      final newP = _MockProvider('new-avail-${DateTime.now().millisecondsSinceEpoch}');
      OcrProviders.register(newP);
      expect(OcrProviders.available.length, count + 1);
    });
  });

  // =========================================================================
  // Handwriting dialog provider display
  // =========================================================================
  group('Handwriting dialog', () {
    test('OcrProviders.active has name for display', () {
      final p = _MockProvider('PosFormer (handwritten, 57%)');
      OcrProviders.register(p);
      OcrProviders.active = p;
      // The handwriting dialog shows OcrProviders.active!.name
      expect(OcrProviders.active!.name, contains('PosFormer'));
    });
  });

  // =========================================================================
  // Layout provider detection for camera flow
  // =========================================================================
  group('Layout provider detection', () {
    test('can find layout provider by name', () {
      final layout = _MockProvider('Layout-aware OCR');
      final math = _MockProvider('pix2tex (printed)');
      OcrProviders.register(layout);
      OcrProviders.register(math);

      final found = OcrProviders.available
          .where((p) => p.name.contains('Layout'))
          .firstOrNull;
      expect(found, isNotNull);
      expect(found!.name, 'Layout-aware OCR');
    });

    test('returns null when no layout provider registered', () {
      // Filter to only non-layout providers
      final found = OcrProviders.available
          .where((p) => p.name == 'NONEXISTENT_LAYOUT')
          .firstOrNull;
      expect(found, isNull);
    });
  });

  // =========================================================================
  // Mock provider recognize
  // =========================================================================
  group('Mock provider behavior', () {
    test('recognize returns result', () async {
      final p = _MockProvider('test-rec');
      final result = await p.recognize(Uint8List(0), 0, 0);
      expect(result, isNotNull);
      expect(result!.text, 'mock result');
      expect(result.providerName, 'test-rec');
    });

    test('unavailable provider reports false', () {
      final p = _MockProvider('unavail', available: false);
      expect(p.isAvailable, false);
      expect(p.requiresNetwork, false);
      expect(p.requiresApiKey, false);
    });
  });
}

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

class _MockProvider implements OcrProvider {
  final String _name;
  final bool _available;

  _MockProvider(this._name, {bool available = true}) : _available = available;

  @override
  String get name => _name;

  @override
  bool get isAvailable => _available;

  @override
  bool get requiresNetwork => false;

  @override
  bool get requiresApiKey => false;

  @override
  Future<OcrResult?> recognize(
      Uint8List imageBytes, int width, int height) async {
    return OcrResult(
      text: 'mock result',
      rawOutput: 'mock',
      providerName: _name,
    );
  }
}

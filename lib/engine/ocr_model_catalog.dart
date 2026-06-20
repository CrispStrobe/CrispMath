// lib/engine/ocr_model_catalog.dart
//
// OCR model variant types and catalog — platform-independent (no dart:io).
// Split from ocr_model_manager.dart so web code can import the catalog
// without pulling in dart:io.

/// A downloadable OCR model variant.
class OcrModelVariant {
  final String id;
  final String name;
  final String filename;
  final String url;
  final int sizeBytes;
  final String description;

  /// License string (e.g. 'MIT', 'CC BY-NC-SA 3.0'). If non-null and
  /// contains 'NC', the download UI should show an acceptance gate.
  final String? license;

  const OcrModelVariant({
    required this.id,
    required this.name,
    required this.filename,
    required this.url,
    required this.sizeBytes,
    required this.description,
    this.license,
  });

  /// Whether the model requires the user to accept NC license terms.
  bool get requiresLicenseAcceptance =>
      license != null && license!.contains('NC');

  String get sizeLabel {
    if (sizeBytes >= 1024 * 1024 * 1024) {
      return '${(sizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(0)} MB';
  }
}

/// Registry of available OCR models.
class OcrModelCatalog {
  static const String _hfBaseUrl =
      'https://huggingface.co/cstr/pix2tex-mfr-gguf/resolve/main';

  static const List<OcrModelVariant> printedMath = [
    OcrModelVariant(
      id: 'pix2tex-mfr-q4k',
      name: 'Math OCR (tiny)',
      filename: 'pix2tex-mfr-q4_k.gguf',
      url: '$_hfBaseUrl/pix2tex-mfr-q4_k.gguf',
      sizeBytes: 17 * 1024 * 1024,
      description: 'Printed math recognition. Smallest model, '
          'good for mobile. 17 MB, Q4_K quantization.',
      license: 'MIT',
    ),
    OcrModelVariant(
      id: 'pix2tex-mfr-q8',
      name: 'Math OCR (balanced)',
      filename: 'pix2tex-mfr-q8_0.gguf',
      url: '$_hfBaseUrl/pix2tex-mfr-q8_0.gguf',
      sizeBytes: 31 * 1024 * 1024,
      description: 'Printed math recognition. Best quality/size '
          'balance for desktop. 31 MB, Q8_0 quantization.',
      license: 'MIT',
    ),
    OcrModelVariant(
      id: 'pix2tex-mfr-f16',
      name: 'Math OCR (full)',
      filename: 'pix2tex-mfr-f16.gguf',
      url: '$_hfBaseUrl/pix2tex-mfr-f16.gguf',
      sizeBytes: 56 * 1024 * 1024,
      description: 'Printed math recognition. Full FP16 precision. '
          '56 MB. Use when accuracy matters more than size.',
      license: 'MIT',
    ),
  ];

  static const String _hfTexoUrl =
      'https://huggingface.co/cstr/texo-distill-gguf/resolve/main';

  static const List<OcrModelVariant> printedMathTexo = [
    OcrModelVariant(
      id: 'texo-distill-q8',
      name: 'Texo Distill (best printed)',
      filename: 'texo-distill-q8_0.gguf',
      url: '$_hfTexoUrl/texo-distill-q8_0.gguf',
      sizeBytes: 22 * 1024 * 1024,
      description: 'SOTA printed math (HGNetv2+MBart, 20M params). '
          '22 MB Q8_0. BLEU 0.90 on UniMER SPE.',
      license: 'AGPL-3.0',
    ),
    OcrModelVariant(
      id: 'texo-distill-f16',
      name: 'Texo Distill (full)',
      filename: 'texo-distill-f16.gguf',
      url: '$_hfTexoUrl/texo-distill-f16.gguf',
      sizeBytes: 39 * 1024 * 1024,
      description: 'SOTA printed math (HGNetv2+MBart, 20M params). '
          '39 MB FP16. Full precision.',
      license: 'AGPL-3.0',
    ),
  ];

  static const String _hfPpfnlUrl =
      'https://huggingface.co/cstr/ppformulanet-l-gguf/resolve/main';

  static const List<OcrModelVariant> printedMathPpfnl = [
    OcrModelVariant(
      id: 'ppformulanet-l-q8',
      name: 'PP-FormulaNet-L (best quality)',
      filename: 'ppformulanet-l-q8_0.gguf',
      url: '$_hfPpfnlUrl/ppformulanet-l-q8_0.gguf',
      sizeBytes: 180 * 1024 * 1024,
      description: 'Printed math (SAM-ViT+MBart, 181M params). '
          '180 MB Q8_0. SOTA printed formula recognition.',
      license: 'Apache-2.0',
    ),
    OcrModelVariant(
      id: 'ppformulanet-l-q4k',
      name: 'PP-FormulaNet-L (balanced)',
      filename: 'ppformulanet-l-q4_k.gguf',
      url: '$_hfPpfnlUrl/ppformulanet-l-q4_k.gguf',
      sizeBytes: 100 * 1024 * 1024,
      description: 'Printed math (SAM-ViT+MBart, 181M params). '
          '100 MB Q4_K. Good quality/size trade-off.',
      license: 'Apache-2.0',
    ),
    OcrModelVariant(
      id: 'ppformulanet-l-f16',
      name: 'PP-FormulaNet-L (full)',
      filename: 'ppformulanet-l-f16.gguf',
      url: '$_hfPpfnlUrl/ppformulanet-l-f16.gguf',
      sizeBytes: 346 * 1024 * 1024,
      description: 'Printed math (SAM-ViT+MBart, 181M params). '
          '346 MB FP16. Full precision.',
      license: 'Apache-2.0',
    ),
  ];

  static const String _hfMixtexUrl =
      'https://huggingface.co/cstr/mixtex-zhen-gguf/resolve/main';

  static const List<OcrModelVariant> printedMathMixtex = [
    OcrModelVariant(
      id: 'mixtex-zhen-q8',
      name: 'MixTex (Chinese+English)',
      filename: 'mixtex-zhen-q8_0.gguf',
      url: '$_hfMixtexUrl/mixtex-zhen-q8_0.gguf',
      sizeBytes: 89 * 1024 * 1024,
      description: 'Chinese+English LaTeX OCR (Swin-Tiny+RoBERTa). '
          '89 MB Q8_0. Handles mixed CJK+math formulas.',
      license: 'Apache-2.0',
    ),
    OcrModelVariant(
      id: 'mixtex-zhen-q4k',
      name: 'MixTex (balanced)',
      filename: 'mixtex-zhen-q4_k.gguf',
      url: '$_hfMixtexUrl/mixtex-zhen-q4_k.gguf',
      sizeBytes: 57 * 1024 * 1024,
      description: 'Chinese+English LaTeX OCR (Swin-Tiny+RoBERTa). '
          '57 MB Q4_K. Smaller for mobile.',
      license: 'Apache-2.0',
    ),
    OcrModelVariant(
      id: 'mixtex-zhen-f16',
      name: 'MixTex (full)',
      filename: 'mixtex-zhen-f16.gguf',
      url: '$_hfMixtexUrl/mixtex-zhen-f16.gguf',
      sizeBytes: 165 * 1024 * 1024,
      description: 'Chinese+English LaTeX OCR (Swin-Tiny+RoBERTa). '
          '165 MB FP16. Full precision.',
      license: 'Apache-2.0',
    ),
  ];

  static const String _hfHmerUrl =
      'https://huggingface.co/cstr/hmer-handwritten-math-gguf/resolve/main';

  static const String _hfBttrUrl =
      'https://huggingface.co/cstr/bttr-handwritten-math-gguf/resolve/main';

  static const String _hfPosformerUrl =
      'https://huggingface.co/cstr/posformer-crohme-GGUF/resolve/main';

  static const List<OcrModelVariant> handwrittenMath = [
    OcrModelVariant(
      id: 'posformer-crohme-q8',
      name: 'PosFormer (best handwritten)',
      filename: 'posformer-crohme-q8_0.gguf',
      url: '$_hfPosformerUrl/posformer-crohme-q8_0.gguf',
      sizeBytes: 12 * 1024 * 1024,
      description: 'Best handwritten math (DenseNet+Transformer+ARM). '
          '12 MB Q8_0. ~57% on CROHME 2014.',
      license: 'CC BY-NC-SA 3.0',
    ),
    OcrModelVariant(
      id: 'posformer-crohme-q4k',
      name: 'PosFormer (mobile)',
      filename: 'posformer-crohme-q4_k.gguf',
      url: '$_hfPosformerUrl/posformer-crohme-q4_k.gguf',
      sizeBytes: 10 * 1024 * 1024,
      description: 'Handwritten math (DenseNet+Transformer+ARM). '
          '10 MB Q4_K. Smallest high-accuracy model.',
      license: 'CC BY-NC-SA 3.0',
    ),
    OcrModelVariant(
      id: 'bttr-hw-q8',
      name: 'Handwritten Math BTTR',
      filename: 'bttr-hw-q8_0.gguf',
      url: '$_hfBttrUrl/bttr-hw-q8_0.gguf',
      sizeBytes: 13 * 1024 * 1024,
      description: 'Handwritten math (DenseNet+Transformer). '
          '13 MB Q8_0. 49% on CROHME.',
      license: 'CC BY-NC-SA 3.0',
    ),
    OcrModelVariant(
      id: 'bttr-hw-q4k',
      name: 'Handwritten Math BTTR (mobile)',
      filename: 'bttr-hw-q4_k.gguf',
      url: '$_hfBttrUrl/bttr-hw-q4_k.gguf',
      sizeBytes: 11 * 1024 * 1024,
      description: 'Handwritten math (DenseNet+Transformer). '
          '11 MB Q4_K. Smaller for mobile.',
      license: 'CC BY-NC-SA 3.0',
    ),
    OcrModelVariant(
      id: 'bttr-hw-f32',
      name: 'Handwritten Math BTTR (full)',
      filename: 'bttr-hw-f32.gguf',
      url: '$_hfBttrUrl/bttr-hw-f32.gguf',
      sizeBytes: 25 * 1024 * 1024,
      description: 'Handwritten math (DenseNet+Transformer). '
          '25 MB F32. Full precision.',
      license: 'CC BY-NC-SA 3.0',
    ),
    OcrModelVariant(
      id: 'hmer-hw-q4k',
      name: 'Handwritten Math HMER (tiny)',
      filename: 'hmer-hw-q4_k.gguf',
      url: '$_hfHmerUrl/hmer-hw-q4_k.gguf',
      sizeBytes: 4 * 1024 * 1024,
      description: 'Handwritten math (DenseNet+GRU). '
          '4 MB Q4_K. Smallest model.',
      license: 'CC BY-NC-SA 3.0',
    ),
    OcrModelVariant(
      id: 'hmer-hw-q8',
      name: 'Handwritten Math HMER (balanced)',
      filename: 'hmer-hw-q8_0.gguf',
      url: '$_hfHmerUrl/hmer-hw-q8_0.gguf',
      sizeBytes: 7 * 1024 * 1024,
      description: 'Handwritten math (DenseNet+GRU). '
          '7 MB Q8_0.',
      license: 'CC BY-NC-SA 3.0',
    ),
  ];

  static const String _hfLayoutUrl =
      'https://huggingface.co/cstr/layout-heron-gguf/resolve/main';

  static const List<OcrModelVariant> layoutDetection = [
    OcrModelVariant(
      id: 'layout-heron-q8',
      name: 'Layout Detection (RT-DETRv2)',
      filename: 'layout-heron-q8_0.gguf',
      url: '$_hfLayoutUrl/layout-heron-q8_0.gguf',
      sizeBytes: 43 * 1024 * 1024,
      description: 'Document layout detection (17 classes). '
          '43 MB Q8_0. Detects text, table, figure, formula regions.',
      license: 'Apache-2.0',
    ),
    OcrModelVariant(
      id: 'layout-heron-f32',
      name: 'Layout Detection (full)',
      filename: 'layout-heron-f32.gguf',
      url: '$_hfLayoutUrl/layout-heron-f32.gguf',
      sizeBytes: 161 * 1024 * 1024,
      description: 'Document layout detection (17 classes). '
          '161 MB F32. Full precision.',
      license: 'Apache-2.0',
    ),
  ];

  // -- General OCR: text detection + recognition --------------------------

  static const String _hfDbnetUrl =
      'https://huggingface.co/cstr/dbnet-ic15-gguf/resolve/main';

  static const List<OcrModelVariant> textDetection = [
    OcrModelVariant(
      id: 'dbnet-ic15-q8',
      name: 'Text Detection (DBNet)',
      filename: 'dbnet-ic15-q8_0.gguf',
      url: '$_hfDbnetUrl/dbnet-ic15-q8_0.gguf',
      sizeBytes: 12 * 1024 * 1024,
      description: 'Text region detection (ResNet-18 DBNet). '
          '12 MB Q8_0. Finds text bounding boxes in images.',
      license: 'Apache-2.0',
    ),
    OcrModelVariant(
      id: 'dbnet-ic15-q4k',
      name: 'Text Detection (tiny)',
      filename: 'dbnet-ic15-q4_k.gguf',
      url: '$_hfDbnetUrl/dbnet-ic15-q4_k.gguf',
      sizeBytes: 7 * 1024 * 1024,
      description: 'Text region detection (ResNet-18 DBNet). '
          '7 MB Q4_K. Smallest text detector.',
      license: 'Apache-2.0',
    ),
  ];

  static const String _hfTrocrPrintedUrl =
      'https://huggingface.co/cstr/trocr-small-printed-gguf/resolve/main';

  static const List<OcrModelVariant> textRecognition = [
    OcrModelVariant(
      id: 'trocr-small-printed-q8',
      name: 'Text Recognition (TrOCR)',
      filename: 'trocr-small-printed-q8_0.gguf',
      url: '$_hfTrocrPrintedUrl/trocr-small-printed-q8_0.gguf',
      sizeBytes: 63 * 1024 * 1024,
      description: 'Printed text recognition (DeiT+Transformer). '
          '63 MB Q8_0. Recognizes cropped text regions.',
      license: 'MIT',
    ),
    OcrModelVariant(
      id: 'trocr-small-printed-q4k',
      name: 'Text Recognition (smaller)',
      filename: 'trocr-small-printed-q4_k.gguf',
      url: '$_hfTrocrPrintedUrl/trocr-small-printed-q4_k.gguf',
      sizeBytes: 42 * 1024 * 1024,
      description: 'Printed text recognition (DeiT+Transformer). '
          '42 MB Q4_K. Good quality/size trade-off.',
      license: 'MIT',
    ),
  ];

  static const String _hfSuryaDetUrl =
      'https://huggingface.co/cstr/surya-det-gguf/resolve/main';

  static const List<OcrModelVariant> textDetectionSurya = [
    OcrModelVariant(
      id: 'surya-det-q8',
      name: 'Surya Text Detection (91 langs)',
      filename: 'surya-det-q8_0.gguf',
      url: '$_hfSuryaDetUrl/surya-det-q8_0.gguf',
      sizeBytes: 41 * 1024 * 1024,
      description: 'Surya-OCR-2 text detection (EfficientViT segformer). '
          '41 MB Q8_0. 91 languages, superior to DBNet.',
      license: 'MIT',
    ),
    OcrModelVariant(
      id: 'surya-det-q4k',
      name: 'Surya Text Detection (smaller)',
      filename: 'surya-det-q4_k.gguf',
      url: '$_hfSuryaDetUrl/surya-det-q4_k.gguf',
      sizeBytes: 23 * 1024 * 1024,
      description: 'Surya-OCR-2 text detection (EfficientViT segformer). '
          '23 MB Q4_K. Smaller for mobile.',
      license: 'MIT',
    ),
  ];

  // -- Vision-language OCR -------------------------------------------------

  static const String _hfQwen3vlUrl =
      'https://huggingface.co/cstr/qwen3-vl-2b-crispembed-GGUF/resolve/main';

  /// Qwen3-VL-2B: smaller and faster than Qwen2.5-VL-3B with DeepStack
  /// vision injection, fused flash attention, and backend KV cache.
  static const List<OcrModelVariant> visionLanguageQwen3 = [
    OcrModelVariant(
      id: 'qwen3vl-2b-q4k',
      name: 'Qwen3-VL (document OCR)',
      filename: 'qwen3-vl-2b-q4_k.gguf',
      url: '$_hfQwen3vlUrl/qwen3-vl-2b-q4_k.gguf',
      sizeBytes: 1536 * 1024 * 1024, // 1.5 GB
      description: 'Vision-language model (2B params, Qwen3-VL). '
          '1.5 GB Q4_K. Faster than Qwen2.5-VL with DeepStack '
          'vision fusion. Desktop only.',
      license: 'Apache-2.0',
    ),
    OcrModelVariant(
      id: 'qwen3vl-2b-q8',
      name: 'Qwen3-VL (high quality)',
      filename: 'qwen3-vl-2b-q8_0.gguf',
      url: '$_hfQwen3vlUrl/qwen3-vl-2b-q8_0.gguf',
      sizeBytes: 2253 * 1024 * 1024, // 2.2 GB
      description: 'Vision-language model (2B params, Qwen3-VL). '
          '2.2 GB Q8_0. Best quality with DeepStack vision fusion. '
          'Desktop only.',
      license: 'Apache-2.0',
    ),
  ];

  static const String _hfQwen2vlUrl =
      'https://huggingface.co/cstr/qwen2.5-vl-3b-crispembed-GGUF/resolve/main';

  static const List<OcrModelVariant> visionLanguage = [
    OcrModelVariant(
      id: 'qwen2vl-3b-q4k',
      name: 'Qwen2.5-VL (document OCR)',
      filename: 'qwen2.5-vl-3b-q4_k.gguf',
      url: '$_hfQwen2vlUrl/qwen2.5-vl-3b-q4_k.gguf',
      sizeBytes: 2670 * 1024 * 1024, // 2.6 GB
      description: 'Vision-language model (3B params). '
          '2.6 GB Q4_K. Full document OCR with custom prompts. '
          'Desktop only — too large for mobile/web.',
      license: 'Apache-2.0',
    ),
    OcrModelVariant(
      id: 'qwen2vl-3b-q8',
      name: 'Qwen2.5-VL (high quality)',
      filename: 'qwen2.5-vl-3b-q8_0.gguf',
      url: '$_hfQwen2vlUrl/qwen2.5-vl-3b-q8_0.gguf',
      sizeBytes: 3930 * 1024 * 1024, // 3.9 GB
      description: 'Vision-language model (3B params). '
          '3.9 GB Q8_0. Best quality document OCR. Desktop only.',
      license: 'Apache-2.0',
    ),
  ];

  // -- DeepSeek-OCR2 (SAM-ViT + Qwen2 encoder + DeepSeek-V2 MoE) ---------
  // TODO: upload quantized variants to cstr/deepseek-ocr2-crispembed-GGUF

  static const String _hfDeepseekOcr2Url =
      'https://huggingface.co/cstr/deepseek-ocr2-crispembed-GGUF/resolve/main';

  static const List<OcrModelVariant> deepseekOcr2 = [
    OcrModelVariant(
      id: 'deepseek-ocr2-f16',
      name: 'DeepSeek-OCR2 (MoE, full)',
      filename: 'deepseek-ocr2-f16.gguf',
      url: '$_hfDeepseekOcr2Url/deepseek-ocr2-f16.gguf',
      sizeBytes: 6554 * 1024 * 1024, // 6.4 GB
      description: 'DeepSeek-OCR2 (SAM-ViT + Qwen2 + MoE decoder, 3B). '
          '6.4 GB FP16. High-accuracy document OCR. Desktop only. '
          'Quantized variants pending.',
      license: 'Apache-2.0',
    ),
  ];

  static List<OcrModelVariant> get all =>
      [...printedMathPpfnl, ...printedMathTexo, ...printedMathMixtex, ...printedMath, ...handwrittenMath, ...layoutDetection, ...textDetection, ...textDetectionSurya, ...textRecognition, ...visionLanguageQwen3, ...visionLanguage, ...deepseekOcr2];
}

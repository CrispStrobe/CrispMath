// lib/engine/model_license_terms.dart
//
// Restrictive model-weight licenses that need explicit, persisted user
// consent before CrispMath downloads or runs a model. Platform-independent
// (no dart:io) so catalog, web and widget code can share it.
//
// Source: CrispEmbed license audit (CrispStrobe/CrispEmbed#92,
// tests/results/licenses/registry-qwen-audit.json). The tags match
// CrispEmbed's `--accept-license <tag>` registry tags, and [runtimeEnvGate]
// matches the env gate newer CrispEmbed runtimes check before loading the
// model. The pinned runtime (0.17.12) does not check these gates yet, so
// CrispMath enforces consent itself and also sets the gate for upgrades.

/// Terms of a restrictive (non-commercial) model-weight license.
class ModelLicenseTerms {
  /// Stable tag, identical to CrispEmbed's registry `--accept-license` tag.
  final String tag;

  /// Human-readable license name shown in the consent dialog.
  final String name;

  /// Canonical license text.
  final String url;

  /// Whether the weights may only be used for non-commercial purposes.
  final bool nonCommercial;

  /// Additional restriction beyond non-commercial use, if any.
  final String? additionalRestriction;

  /// CrispEmbed runtime env gate that acknowledges this license, if any.
  final String? runtimeEnvGate;

  const ModelLicenseTerms({
    required this.tag,
    required this.name,
    required this.url,
    required this.nonCommercial,
    this.additionalRestriction,
    this.runtimeEnvGate,
  });

  /// Qwen RESEARCH LICENSE AGREEMENT (Qwen2.5-VL-3B and its fine-tunes).
  static const qwenResearch = ModelLicenseTerms(
    tag: 'qwen-research',
    name: 'Qwen RESEARCH LICENSE AGREEMENT',
    url: 'https://huggingface.co/Qwen/Qwen2.5-VL-3B-Instruct/blob/main/LICENSE',
    nonCommercial: true,
    runtimeEnvGate: 'CRISPEMBED_ACCEPT_QWEN_RESEARCH_LICENSE',
  );

  /// Tongyi Qianwen RESEARCH LICENSE AGREEMENT (Qwen1/1.5 lineage, e.g.
  /// GOT-OCR2). Not used by any current CrispMath catalog entry; defined so
  /// a future GOT-OCR2 entry must carry the extra clause.
  static const tongyiQianwenResearch = ModelLicenseTerms(
    tag: 'tongyi-qianwen-research',
    name: 'Tongyi Qianwen RESEARCH LICENSE AGREEMENT',
    url: 'https://huggingface.co/Qwen/Qwen1.5-0.5B/blob/main/LICENSE',
    nonCommercial: true,
    additionalRestriction: 'Neither the model nor its outputs may be used '
        'to improve any other large language model.',
    runtimeEnvGate: 'CRISPEMBED_ACCEPT_TONGYI_QIANWEN_LICENSE',
  );

  static const List<ModelLicenseTerms> all = [
    qwenResearch,
    tongyiQianwenResearch,
  ];

  /// Consent text shown to the user before download or first use.
  String consentText(String modelName) {
    final b = StringBuffer()
      ..write('$modelName is licensed under the $name ($tag).\n\n');
    if (nonCommercial) {
      b.write(
        'These model weights may be used for NON-COMMERCIAL purposes '
        'only. Commercial use is not permitted under this license.\n\n',
      );
    }
    if (additionalRestriction != null) {
      b.write('$additionalRestriction\n\n');
    }
    b.write(
      'This applies only to the model weights, not to CrispMath '
      'itself. Your consent is remembered on this device and can be '
      'withdrawn in OCR settings.\n\n'
      'License: $url',
    );
    return b.toString();
  }
}

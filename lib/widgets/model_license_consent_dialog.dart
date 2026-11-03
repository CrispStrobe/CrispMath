// lib/widgets/model_license_consent_dialog.dart
//
// Explicit consent dialog for restrictive model-weight licenses. Consent is
// persisted per license tag by ModelLicenseConsent.

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../engine/model_license_consent.dart';
import '../engine/model_license_terms.dart';

/// Returns true if consent for [terms] is (now) recorded. Shows the dialog
/// only when consent is not already persisted.
Future<bool> ensureModelLicenseConsent(
  BuildContext context,
  ModelLicenseTerms terms,
  String modelName,
) async {
  await ModelLicenseConsent.load();
  if (ModelLicenseConsent.allows(terms)) return true;
  if (!context.mounted) return false;
  final accepted = await showDialog<bool>(
    context: context,
    builder: (ctx) =>
        ModelLicenseConsentDialog(terms: terms, modelName: modelName),
  );
  if (accepted != true) return false;
  await ModelLicenseConsent.grant(terms);
  return true;
}

class ModelLicenseConsentDialog extends StatelessWidget {
  final ModelLicenseTerms terms;
  final String modelName;

  const ModelLicenseConsentDialog({
    super.key,
    required this.terms,
    required this.modelName,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        terms.nonCommercial
            ? 'Non-commercial model license'
            : 'Model license terms',
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SelectableText(terms.consentText(modelName)),
            const SizedBox(height: 8),
            TextButton.icon(
              icon: const Icon(
                Icons.open_in_new,
                size: 16,
                semanticLabel: 'Open license',
              ),
              label: const Text('Read the license'),
              onPressed: () => launchUrl(
                Uri.parse(terms.url),
                mode: LaunchMode.externalApplication,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Decline'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('I accept these terms'),
        ),
      ],
    );
  }
}

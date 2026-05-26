// P9-A2: dialogs for adding / editing scene objects. A2 ships only
// the Add/Edit Plane dialog; A3 will add the line + sphere dialogs;
// A5 / A6 follow with quadric + parametric.

import 'package:flutter/material.dart';

import '../engine/scene_3d/scene_object.dart';
import '../localization/app_localizations.dart';

/// Curated palette of distinguishable colors used by the scene
/// object pickers. Each kind gets a default index so freshly
/// created objects don't all start the same color.
const List<int> kSceneObjectPalette = [
  0xFFE53935, // red
  0xFF1E88E5, // blue
  0xFF43A047, // green
  0xFFFB8C00, // orange
  0xFF8E24AA, // purple
  0xFFFDD835, // amber
  0xFF00897B, // teal
  0xFF6D4C41, // brown
];

/// Show the Add/Edit Plane dialog. Returns the new / edited
/// [PlaneObject] on save, or null if cancelled.
Future<PlaneObject?> showPlaneEditorDialog(
  BuildContext context, {
  PlaneObject? existing,
  int defaultColor = 0xFF1E88E5,
}) async {
  final t = AppLocalizations.of(context);
  final labelCtrl = TextEditingController(text: existing?.label ?? 'Plane');
  final aCtrl = TextEditingController(text: (existing?.a ?? 1).toString());
  final bCtrl = TextEditingController(text: (existing?.b ?? 0).toString());
  final cCtrl = TextEditingController(text: (existing?.c ?? 0).toString());
  final dCtrl = TextEditingController(text: (existing?.d ?? 0).toString());
  var color = existing?.color ?? defaultColor;
  final formKey = GlobalKey<FormState>();

  final saved = await showDialog<PlaneObject>(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(builder: (ctx, setStateDlg) {
        return AlertDialog(
          title:
              Text(existing == null ? t.scene3DAddPlane : t.scene3DEditPlane),
          content: SizedBox(
            width: 360,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'a·x + b·y + c·z = d',
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'monospace',
                      color: Theme.of(ctx)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: labelCtrl,
                    decoration: InputDecoration(
                      labelText: t.scene3DObjectLabel,
                      isDense: true,
                    ),
                    validator: (s) => (s?.trim().isEmpty ?? true)
                        ? t.scene3DLabelRequired
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: _coef(aCtrl, 'a', t)),
                    const SizedBox(width: 8),
                    Expanded(child: _coef(bCtrl, 'b', t)),
                    const SizedBox(width: 8),
                    Expanded(child: _coef(cCtrl, 'c', t)),
                    const SizedBox(width: 8),
                    Expanded(child: _coef(dCtrl, 'd', t)),
                  ]),
                  const SizedBox(height: 16),
                  Text(
                    t.scene3DColor,
                    style: Theme.of(ctx).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final swatch in kSceneObjectPalette)
                        _ColorSwatch(
                          color: Color(swatch),
                          selected: color == swatch,
                          onTap: () => setStateDlg(() => color = swatch),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(t.cancel),
            ),
            FilledButton(
              onPressed: () {
                if (!(formKey.currentState?.validate() ?? false)) return;
                final a = double.tryParse(aCtrl.text.trim()) ?? 0;
                final b = double.tryParse(bCtrl.text.trim()) ?? 0;
                final c = double.tryParse(cCtrl.text.trim()) ?? 0;
                final d = double.tryParse(dCtrl.text.trim()) ?? 0;
                if (a == 0 && b == 0 && c == 0) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                    content: Text(t.scene3DPlaneZeroNormal),
                    duration: const Duration(seconds: 2),
                  ));
                  return;
                }
                Navigator.of(ctx).pop(PlaneObject(
                  id: existing?.id ?? generateSceneObjectId(),
                  label: labelCtrl.text.trim(),
                  color: color,
                  visible: existing?.visible ?? true,
                  a: a,
                  b: b,
                  c: c,
                  d: d,
                ));
              },
              child: Text(existing == null ? t.scene3DAdd : t.scene3DSave),
            ),
          ],
        );
      });
    },
  );
  return saved;
}

Widget _coef(TextEditingController c, String label, AppLocalizations t) {
  return TextFormField(
    controller: c,
    keyboardType:
        const TextInputType.numberWithOptions(signed: true, decimal: true),
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      isDense: true,
    ),
    validator: (s) {
      final v = s?.trim() ?? '';
      if (v.isEmpty) return t.scene3DCoefRequired;
      if (double.tryParse(v) == null) return t.scene3DCoefInvalid;
      return null;
    },
  );
}

class _ColorSwatch extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  const _ColorSwatch({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.onSurface
                : Colors.transparent,
            width: 2.5,
          ),
        ),
      ),
    );
  }
}

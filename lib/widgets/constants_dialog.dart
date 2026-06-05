// lib/widgets/constants_dialog.dart
//
// Browse + search the constants catalog. Category chips at the top
// filter the list; a search field narrows further by substring
// match. Each row shows the symbol, name, value with unit, and an
// optional note. Tapping a row copies the numeric value to the
// clipboard so it can be pasted into the calculator (or anywhere
// else — Notion, code, a homework PDF).
//
// V1 deliberately doesn't insert directly into the calculator's
// LaTeX field because the dialog can be opened from Settings where
// there's no live LatexController in scope; clipboard is universal.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../engine/constants_catalog.dart';
import '../localization/app_localizations.dart';

class ConstantsDialog extends StatefulWidget {
  const ConstantsDialog({super.key});

  @override
  State<ConstantsDialog> createState() => _ConstantsDialogState();
}

class _ConstantsDialogState extends State<ConstantsDialog> {
  ConstantCategory? _filter; // null = all categories
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<PhysicalConstant> get _filtered {
    final pool = _filter == null
        ? ConstantsCatalog.all
        : ConstantsCatalog.byCategory(_filter!);
    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return pool;
    return pool
        .where((c) =>
            c.symbol.toLowerCase().contains(q) ||
            c.name.toLowerCase().contains(q) ||
            c.unit.toLowerCase().contains(q))
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final results = _filtered;

    return AlertDialog(
      title: Text(t.constantsTitle),
      content: SizedBox(
        width: 520,
        height: 480,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Category filter chips.
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                ChoiceChip(
                  label: Text(t.constantsAllCategory),
                  selected: _filter == null,
                  onSelected: (_) => setState(() => _filter = null),
                ),
                for (final c in ConstantCategory.values)
                  ChoiceChip(
                    label: Text(_categoryLabel(c, t)),
                    selected: _filter == c,
                    onSelected: (_) => setState(() => _filter = c),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                isDense: true,
                prefixIcon:
                    const Icon(Icons.search, size: 18, semanticLabel: 'Search'),
                hintText: t.constantsSearchHint,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: results.isEmpty
                  ? Center(child: Text(t.constantsNoMatches))
                  : ListView.separated(
                      itemCount: results.length,
                      separatorBuilder: (_, __) => const Divider(height: 0),
                      itemBuilder: (_, i) => _row(context, results[i], t),
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t.dialogClose),
        ),
      ],
    );
  }

  Widget _row(BuildContext context, PhysicalConstant c, AppLocalizations t) {
    return ListTile(
      dense: true,
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              c.symbol,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(c.name, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatValue(c),
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
          ),
          if (c.note != null)
            Text(
              c.note!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
            ),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.copy, size: 18, semanticLabel: 'Copy value'),
        tooltip: t.constantsCopyValue,
        onPressed: () async {
          await Clipboard.setData(ClipboardData(text: c.value.toString()));
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t.constantsCopiedToast(c.symbol)),
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  String _formatValue(PhysicalConstant c) {
    final abs = c.value.abs();
    String num;
    if (abs == 0) {
      num = '0';
    } else if (abs >= 1e6 || abs < 1e-3) {
      num = c.value.toStringAsExponential(6);
    } else {
      num = c.value.toStringAsPrecision(10);
      // Strip trailing zeros for readability.
      if (num.contains('.') && !num.contains('e')) {
        num = num.replaceAll(RegExp(r'0+$'), '');
        if (num.endsWith('.')) num = num.substring(0, num.length - 1);
      }
    }
    return c.unit.isEmpty ? num : '$num ${c.unit}';
  }

  String _categoryLabel(ConstantCategory c, AppLocalizations t) {
    switch (c) {
      case ConstantCategory.mathematical:
        return t.constantsCategoryMathematical;
      case ConstantCategory.physical:
        return t.constantsCategoryPhysical;
      case ConstantCategory.chemistry:
        return t.constantsCategoryChemistry;
      case ConstantCategory.astronomy:
        return t.constantsCategoryAstronomy;
    }
  }
}

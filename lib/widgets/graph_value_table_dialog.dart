import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../engine/graph_inspection.dart';
import '../services/graph_sampling_service.dart';

class GraphValueTableDialog extends StatefulWidget {
  final Map<int, String> functions;
  const GraphValueTableDialog({super.key, required this.functions});
  @override
  State<GraphValueTableDialog> createState() => _GraphValueTableDialogState();
}

class _GraphValueTableDialogState extends State<GraphValueTableDialog> {
  final _from = TextEditingController(text: '-5');
  final _to = TextEditingController(text: '5');
  final _step = TextEditingController(text: '1');
  late int _slot = widget.functions.keys.first;
  List<List<double?>>? _rows;
  String? _error;
  bool _busy = false;
  @override
  void dispose() {
    _from.dispose();
    _to.dispose();
    _step.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    setState(() {
      _busy = true;
      _error = null;
      _rows = null;
    });
    try {
      final xs = graphTableCoordinates(double.parse(_from.text),
          double.parse(_to.text), double.parse(_step.text));
      final rows =
          await GraphSamplingService.values(widget.functions[_slot]!, xs);
      if (mounted) setState(() => _rows = rows);
    } catch (e) {
      if (mounted) {
        setState(() => _error = e is ArgumentError
            ? e.message.toString()
            : 'Could not generate values. Check the interval and expression.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _field(TextEditingController c, String label) => Expanded(
      child: Padding(
          padding: const EdgeInsets.all(4),
          child: TextField(
              controller: c,
              enabled: !_busy,
              keyboardType: const TextInputType.numberWithOptions(
                  signed: true, decimal: true),
              decoration: InputDecoration(
                  labelText: label, border: const OutlineInputBorder()))));

  @override
  Widget build(BuildContext context) => AlertDialog(
          title: const Text('Value table'),
          content: SizedBox(
              width: 480,
              height: 420,
              child: Column(children: [
                DropdownButtonFormField<int>(
                    initialValue: _slot,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Function'),
                    items: [
                      for (final entry in widget.functions.entries)
                        DropdownMenuItem(
                            value: entry.key,
                            child: Text('Y${entry.key + 1} = ${entry.value}',
                                overflow: TextOverflow.ellipsis))
                    ],
                    onChanged: _busy
                        ? null
                        : (v) => setState(() {
                              _slot = v!;
                              _rows = null;
                            })),
                Row(children: [
                  _field(_from, 'From'),
                  _field(_to, 'To'),
                  _field(_step, 'Step')
                ]),
                FilledButton(
                    onPressed: _busy ? null : _generate,
                    child: const Text('Generate table')),
                if (_busy) const LinearProgressIndicator(),
                if (_error != null)
                  Text(_error!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error)),
                const SizedBox(height: 8),
                Expanded(
                    child: _rows == null
                        ? const Center(
                            child:
                                Text('Choose an interval to inspect values.'))
                        : SingleChildScrollView(
                            child: SelectableText(
                                graphValuesText(_rows!, separator: '\t'),
                                style:
                                    const TextStyle(fontFamily: 'monospace')))),
              ])),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close')),
            TextButton(
                onPressed: _rows == null
                    ? null
                    : () async {
                        await Clipboard.setData(ClipboardData(
                            text: graphValuesText(_rows!, separator: '\t')));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Table copied')));
                        }
                      },
                child: const Text('Copy table')),
            TextButton(
                onPressed: _rows == null
                    ? null
                    : () async {
                        await Clipboard.setData(
                            ClipboardData(text: graphValuesText(_rows!)));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('CSV copied')));
                        }
                      },
                child: const Text('Copy CSV')),
          ]);
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../engine/command_catalog.dart';

class CommandPalette extends StatefulWidget {
  const CommandPalette({super.key});
  @override
  State<CommandPalette> createState() => _CommandPaletteState();
}

class _CommandPaletteState extends State<CommandPalette> {
  String query = '';
  int selected = 0;
  @override
  Widget build(BuildContext context) {
    final results = searchCommands(query);
    return AlertDialog(
      title: const Text('Search commands'),
      content: SizedBox(
          width: 560,
          height: MediaQuery.sizeOf(context).height.clamp(240, 580) * .65,
          child: Column(children: [
            Focus(
                onKeyEvent: (_, event) {
                  if (event is! KeyDownEvent) return KeyEventResult.ignored;
                  final delta = event.logicalKey == LogicalKeyboardKey.arrowDown
                      ? 1
                      : event.logicalKey == LogicalKeyboardKey.arrowUp
                          ? -1
                          : 0;
                  if (delta == 0 || results.isEmpty)
                    return KeyEventResult.ignored;
                  setState(() => selected =
                      (selected + delta).clamp(0, results.length - 1));
                  return KeyEventResult.handled;
                },
                child: TextField(
                    autofocus: true,
                    decoration: const InputDecoration(
                        labelText: 'Find a command',
                        hintText: 'Functions, tools or screens',
                        prefixIcon: Icon(Icons.search)),
                    onChanged: (value) => setState(() {
                          query = value;
                          selected = 0;
                        }),
                    onSubmitted: (_) {
                      if (results.isNotEmpty)
                        Navigator.pop(context, results[selected]);
                    })),
            const SizedBox(height: 8),
            Expanded(
                child: results.isEmpty
                    ? const Center(child: Text('No commands found'))
                    : ListView.builder(
                        itemCount: results.length,
                        itemBuilder: (_, i) => ListTile(
                            selected: i == selected,
                            title: Text(results[i].title),
                            subtitle: Text(results[i].description,
                                maxLines: 2, overflow: TextOverflow.ellipsis),
                            onTap: () => Navigator.pop(context, results[i])))),
          ])),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: const Text('Close'))
      ],
    );
  }
}

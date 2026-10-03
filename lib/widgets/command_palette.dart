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
  final _scroll = ScrollController();
  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

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
                  if (event is! KeyDownEvent) {
                    return KeyEventResult.ignored;
                  }
                  final delta = event.logicalKey == LogicalKeyboardKey.arrowDown
                      ? 1
                      : event.logicalKey == LogicalKeyboardKey.arrowUp
                          ? -1
                          : 0;
                  if (delta == 0 || results.isEmpty) {
                    return KeyEventResult.ignored;
                  }
                  setState(() => selected =
                      (selected + delta).clamp(0, results.length - 1));
                  if (_scroll.hasClients) {
                    _scroll.animateTo(
                        (selected * 80.0)
                            .clamp(0, _scroll.position.maxScrollExtent),
                        duration: const Duration(milliseconds: 100),
                        curve: Curves.easeOut);
                  }
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
                          if (_scroll.hasClients) _scroll.jumpTo(0);
                        }),
                    onSubmitted: (_) {
                      // Input changes can arrive before the next build frame.
                      final current = searchCommands(query);
                      if (current.isNotEmpty) {
                        Navigator.pop(context,
                            current[selected.clamp(0, current.length - 1)]);
                      }
                    })),
            const SizedBox(height: 8),
            Expanded(
                child: results.isEmpty
                    ? const Center(child: Text('No commands found'))
                    : ListView.builder(
                        controller: _scroll,
                        itemCount: results.length,
                        itemBuilder: (_, i) => ListTile(
                            selected: i == selected,
                            title: Text(results[i].title,
                                maxLines: 1, overflow: TextOverflow.ellipsis),
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

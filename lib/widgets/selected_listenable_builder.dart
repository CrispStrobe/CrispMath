import 'package:flutter/widgets.dart';

/// Rebuilds only when the selected state changes, even if a shared progress
/// notifier emits updates for other rows.
class SelectedListenableBuilder<T> extends StatefulWidget {
  const SelectedListenableBuilder({
    super.key,
    required this.listenable,
    required this.select,
    required this.builder,
  });

  final Listenable listenable;
  final T Function() select;
  final WidgetBuilder builder;

  @override
  State<SelectedListenableBuilder<T>> createState() =>
      _SelectedListenableBuilderState<T>();
}

class _SelectedListenableBuilderState<T>
    extends State<SelectedListenableBuilder<T>> {
  late T _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.select();
    widget.listenable.addListener(_changed);
  }

  void _changed() {
    final selected = widget.select();
    if (selected != _selected) {
      setState(() => _selected = selected);
    }
  }

  @override
  void didUpdateWidget(covariant SelectedListenableBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listenable != widget.listenable) {
      oldWidget.listenable.removeListener(_changed);
      widget.listenable.addListener(_changed);
    }
    _selected = widget.select();
  }

  @override
  void dispose() {
    widget.listenable.removeListener(_changed);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context);
}

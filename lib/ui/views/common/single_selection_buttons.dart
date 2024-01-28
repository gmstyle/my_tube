import 'package:flutter/material.dart';

class SingleSelectionButtons extends StatefulWidget {
  const SingleSelectionButtons({
    super.key,
    required this.items,
    this.icons,
    required this.onSelected,
  });

  final List<String> items;
  final List<IconData>? icons;
  final Function(int, String) onSelected;

  @override
  State<SingleSelectionButtons> createState() => _SingleSelectionButtonsState();
}

class _SingleSelectionButtonsState extends State<SingleSelectionButtons> {
  int selected = 0;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      for (var item in widget.items)
        FilterChip(
          avatar: widget.icons != null && selected != widget.items.indexOf(item)
              ? Icon(
                  widget.icons![widget.items.indexOf(item)],
                )
              : null,
          label: Text(item),
          onSelected: (value) => setState(() {
            selected = widget.items.indexOf(item);
            widget.onSelected(widget.items.indexOf(item), item);
          }),
          selected: widget.items.indexOf(item) == selected,
        )
    ]);
  }
}

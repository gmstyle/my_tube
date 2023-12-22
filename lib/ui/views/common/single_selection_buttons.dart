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
    return Row(children: [
      for (var item in widget.items)
        IconButton(
            color: widget.items.indexOf(item) == selected
                ? Colors.white
                : Colors.grey,
            onPressed: () {
              setState(() {
                selected = widget.items.indexOf(item);
                widget.onSelected.call(widget.items.indexOf(item), item);
              });
            },
            icon: Row(
              children: [
                if (widget.icons != null)
                  Icon(
                    widget.icons![widget.items.indexOf(item)],
                    color: widget.items.indexOf(item) == selected
                        ? Colors.white
                        : Colors.grey,
                  ),
                const SizedBox(width: 4),
                Text(
                  item,
                  style: TextStyle(
                      color: selected == widget.items.indexOf(item)
                          ? Colors.white
                          : Colors.grey),
                ),
              ],
            ))
    ]);
  }
}

import 'package:flutter/material.dart';
import 'package:my_tube/ui/views/home/tabs/explore_tab_view.dart';

class SingleSelectionButtons extends StatefulWidget {
  const SingleSelectionButtons({
    super.key,
    required this.items,
    this.icons,
    required this.onSelected,
  });

  final List<CategoryEnum> items;
  final List<IconData>? icons;
  final Function(int, CategoryEnum) onSelected;

  @override
  State<SingleSelectionButtons> createState() => _SingleSelectionButtonsState();
}

class _SingleSelectionButtonsState extends State<SingleSelectionButtons> {
  int selected = 0;
  List<Icon>? icons;

  @override
  void initState() {
    super.initState();
    if (widget.icons != null) {
      icons = widget.icons!.map((iconData) => Icon(iconData)).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Wrap(spacing: 8, children: [
        for (var entry in widget.items.asMap().entries)
          FilterChip(
            avatar: icons != null && selected != entry.key
                ? icons![entry.key]
                : null,
            label: Text(entry.value.name),
            onSelected: (value) => setState(() {
              selected = entry.key;
              widget.onSelected(entry.key, entry.value);
            }),
            selected: entry.key == selected,
          )
      ]),
    );
  }
}

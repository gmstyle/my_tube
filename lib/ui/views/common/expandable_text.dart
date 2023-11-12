import 'package:flutter/material.dart';

class ExpandableText extends StatefulWidget {
  const ExpandableText({super.key, required this.text, this.style});

  final String text;
  final TextStyle? style;

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            widget.text,
            maxLines:
                isExpanded ? null : 2, // Mostra solo 2 righe se non è espansa

            style: widget.style ??
                Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                    ),
          ),
        ),
        if (widget.text.split('\n').length > 2)
          TextButton(
            onPressed: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: Text(
              isExpanded ? 'Show less' : 'Show more',
              style: widget.style ??
                  Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                      ),
            ),
          ),
      ],
    );
  }
}

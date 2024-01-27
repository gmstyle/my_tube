import 'package:flutter/material.dart';

class ExpandableText extends StatelessWidget {
  const ExpandableText({
    super.key,
    required this.title,
    required this.text,
  });

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
      ),
      child: ExpansionTile(
          collapsedIconColor: Theme.of(context).colorScheme.onPrimary,
          iconColor: Theme.of(context).colorScheme.onPrimary,
          title: Text(
            title,
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          ),
          children: [
            ListTile(
                title: Text(text,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary)))
          ]),
    );
  }
}

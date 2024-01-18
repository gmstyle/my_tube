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
          collapsedIconColor: Colors.white,
          iconColor: Colors.white,
          title: Text(
            title,
            style: const TextStyle(color: Colors.white),
          ),
          children: [
            ListTile(
                title: Text(text, style: const TextStyle(color: Colors.white)))
          ]),
    );
  }
}

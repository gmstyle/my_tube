import 'package:flutter/material.dart';

class EmptySearch extends StatelessWidget {
  const EmptySearch({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          Icons.search,
          color: Theme.of(context).colorScheme.onPrimary,
          size: 100.0,
        ),
        Text(
          'Start searching!',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 20.0,
          ),
        ),
      ],
    );
  }
}

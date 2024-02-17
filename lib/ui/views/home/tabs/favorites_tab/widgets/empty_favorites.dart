import 'package:flutter/material.dart';

class EmptyFavorites extends StatelessWidget {
  const EmptyFavorites({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          Icons.favorite_border,
          color: Theme.of(context).colorScheme.onPrimary,
          size: 100.0,
        ),
        Text(
          message,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 20.0,
          ),
        ),
      ],
    );
  }
}

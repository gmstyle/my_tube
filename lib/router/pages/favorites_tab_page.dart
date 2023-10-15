import 'package:flutter/material.dart';

class FavoritesTabPAge extends Page {
  const FavoritesTabPAge({Key? key});

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
        settings: this,
        builder: (context) {
          return const Scaffold(
            body: Center(
              child: Text('Favorites Tab'),
            ),
          );
        });
  }
}

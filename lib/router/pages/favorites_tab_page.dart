import 'package:flutter/material.dart';
import 'package:my_tube/ui/views/home/tabs/favorites_tab/favorites_tab_view.dart';

class FavoritesTabPage extends Page {
  const FavoritesTabPage({super.key});

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) {
        return const QueueTabView();
      },
    );
  }
}

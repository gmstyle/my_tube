import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/ui/views/common/main_gradient.dart';
import 'package:my_tube/ui/views/common/mini_player.dart';

class ScaffoldWithNavbarView extends StatelessWidget {
  const ScaffoldWithNavbarView({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  final _navBarItems = const [
    NavigationDestination(
      icon: Icon(Icons.explore),
      label: 'Explore',
    ),
    NavigationDestination(
      icon: Icon(Icons.music_note),
      label: 'Music',
    ),
    NavigationDestination(
      icon: Icon(Icons.favorite),
      label: 'Favorites',
    ),
    NavigationDestination(
      icon: Icon(Icons.search),
      label: 'Search',
    ),
  ];

  void onDestinationSelected(int index) {
    navigationShell.goBranch(index,
        initialLocation: index == navigationShell.currentIndex);
    log('onDestinationSelected: $index');
  }

  @override
  Widget build(BuildContext context) {
    return MainGradient(
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: navigationShell,
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const MiniPlayer(),
              NavigationBar(
                  elevation: 0,
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  selectedIndex: navigationShell.currentIndex,
                  destinations: _navBarItems,
                  onDestinationSelected: onDestinationSelected,
                  labelBehavior:
                      NavigationDestinationLabelBehavior.onlyShowSelected),
            ],
          ),
        ),
      ),
    );
  }
}

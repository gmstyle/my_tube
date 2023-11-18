import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/blocs/home/mini_player_cubit/mini_player_cubit.dart';
import 'package:my_tube/ui/views/common/custom_appbar.dart';
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
      icon: Icon(Icons.favorite),
      label: 'Favorites',
    ),
    NavigationDestination(
      icon: Icon(Icons.search),
      label: 'Search',
    ),
    NavigationDestination(
      icon: Icon(Icons.subscriptions),
      label: 'Subscriptions',
    ),
    NavigationDestination(
      icon: Icon(Icons.account_circle),
      label: 'Me',
    ),
  ];

  void onDestinationSelected(int index) {
    navigationShell.goBranch(index,
        initialLocation: index == navigationShell.currentIndex);
    log('onDestinationSelected: $index');
  }

  @override
  Widget build(BuildContext context) {
    final miniPlayerHeight = MediaQuery.of(context).size.height * 0.15;
    final miniplayerStatus = context.watch<MiniPlayerCubit>().state.status;

    return MainGradient(
      child: Scaffold(
        appBar: const CustomAppbar(
          title: 'My Tube',
        ),
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            /// Tab content
            Expanded(child: navigationShell),

            /// Mini player
            AnimatedContainer(
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10))),
              duration: const Duration(milliseconds: 500),
              height: miniplayerStatus == MiniPlayerStatus.shown ||
                      miniplayerStatus == MiniPlayerStatus.loading
                  ? miniPlayerHeight
                  : 0,
              child: BlocBuilder<MiniPlayerCubit, MiniPlayerState>(
                  builder: (context, state) {
                switch (state.status) {
                  case MiniPlayerStatus.loading:
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  case MiniPlayerStatus.shown:
                    return const MiniPlayer();
                  default:
                    return const SizedBox.shrink();
                }
              }),
            ),
          ],
        ),
        bottomNavigationBar: NavigationBar(
            elevation: 0,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            selectedIndex: navigationShell.currentIndex,
            destinations: _navBarItems,
            onDestinationSelected: onDestinationSelected,
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected),
      ),
    );
  }
}

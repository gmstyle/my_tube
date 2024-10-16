import 'dart:developer';

import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/blocs/update_bloc/update_bloc.dart';
import 'package:my_tube/router/app_router.dart';
import 'package:my_tube/ui/views/common/custom_appbar.dart';
import 'package:my_tube/ui/views/common/main_gradient.dart';
import 'package:my_tube/ui/views/common/mini_player.dart';
import 'package:my_tube/ui/views/common/update_available_dialog.dart';

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

  final _navigationRailDestinations = const [
    NavigationRailDestination(
      icon: Icon(Icons.explore),
      selectedIcon: Icon(Icons.explore),
      label: Text('Explore'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.music_note),
      selectedIcon: Icon(Icons.music_note),
      label: Text('Music'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.favorite),
      selectedIcon: Icon(Icons.favorite),
      label: Text('Favorites'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.search),
      selectedIcon: Icon(Icons.search),
      label: Text('Search'),
    ),
  ];

  void onDestinationSelected(int index) {
    navigationShell.goBranch(index,
        initialLocation: index == navigationShell.currentIndex);
    log('onDestinationSelected: $index');
  }

  Future<void> disableBatteryOptimization() async {
    try {
      final isDisabled =
          await DisableBatteryOptimization.isAllBatteryOptimizationDisabled;
      if (isDisabled == false) {
        await DisableBatteryOptimization
            .showDisableBatteryOptimizationSettings();
      }
    } catch (e) {
      log('Error disabling battery optimization: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Spostare la chiamata a disableBatteryOptimization in un metodo di inizializzazione
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await disableBatteryOptimization();
    });

    return BlocListener<UpdateBloc, UpdateState>(
      listener: (context, state) {
        if (state.status == UpdateStatus.updateAvailable) {
          // Show update dialog
          showDialog(
              context: context,
              builder: (context) {
                return UpdateAvailableDialog(update: state.update!);
              });
        }
      },
      child: MainGradient(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.smallest.shortestSide > 600;

              return Scaffold(
                appBar: CustomAppbar(
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () =>
                          context.pushNamed(AppRoute.settings.name),
                    ),
                  ],
                ),
                backgroundColor: Colors.transparent,
                resizeToAvoidBottomInset: false,
                body: isTablet ? _buildTabletLayout() : _buildMobileLayout(),
                bottomNavigationBar:
                    !isTablet ? _buildMobileNavBar(context) : null,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Stack(
      children: [
        Row(
          children: [
            NavigationRail(
              selectedIndex: navigationShell.currentIndex,
              destinations: _navigationRailDestinations,
              onDestinationSelected: onDestinationSelected,
              labelType: NavigationRailLabelType.selected,
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 8.0,
                  left: 8.0,
                  right: 8.0,
                ),
                child: navigationShell,
              ),
            ),
          ],
        ),
        const Positioned(bottom: 0, right: 8, child: MiniPlayer()),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: navigationShell,
    );
  }

  Widget _buildMobileNavBar(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const MiniPlayer(),
        NavigationBar(
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          selectedIndex: navigationShell.currentIndex,
          destinations: _navBarItems,
          onDestinationSelected: onDestinationSelected,
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        ),
      ],
    );
  }
}

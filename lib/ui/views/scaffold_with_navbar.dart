import 'dart:developer';

import 'package:disable_battery_optimizations_latest/disable_battery_optimizations_latest.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/blocs/update_bloc/update_bloc.dart';
import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';
import 'package:my_tube/ui/views/common/custom_appbar.dart';
import 'package:my_tube/ui/views/common/global_search_delegate.dart';
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
      icon: Icon(Icons.favorite),
      label: 'Favorites',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings),
      label: 'Settings',
    ),
  ];

  // NavigationRail destinations for larger screens
  final _railDestinations = const [
    NavigationRailDestination(
      icon: Icon(Icons.explore),
      label: Text('Explore'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.favorite),
      label: Text('Favorites'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.settings),
      label: Text('Settings'),
    ),
  ];

  void onDestinationSelected(int index) {
    navigationShell.goBranch(index,
        initialLocation: index == navigationShell.currentIndex);
    log('onDestinationSelected: $index');
  }

  void _showGlobalSearch(BuildContext context) {
    showSearch(
      context: context,
      delegate: GlobalSearchDelegate(),
    );
  }

  Future<void> disableBatteryOptimization() async {
    try {
      final isDisabled = await DisableBatteryOptimizationLatest
          .isAllBatteryOptimizationDisabled;
      if (isDisabled == false) {
        await DisableBatteryOptimizationLatest
            .showDisableBatteryOptimizationSettings();
      }
    } catch (e) {
      log('Error disabling battery optimization: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await disableBatteryOptimization();
    });

    return BlocListener<UpdateBloc, UpdateState>(
      listener: (context, state) {
        if (state.status == UpdateStatus.updateAvailable) {
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
              final bool useNavigationRail = constraints.maxWidth >= 640;

              if (useNavigationRail) {
                return _buildNavigationRailLayout(context);
              } else {
                return _buildNavigationBarLayout(context);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationRailLayout(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        actions: [
          IconButton(
              onPressed: () => _showGlobalSearch(context),
              icon: Icon(Icons.search)),
        ],
      ),
      backgroundColor: Colors.transparent,
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: onDestinationSelected,
            labelType: NavigationRailLabelType.all,
            backgroundColor: Colors.transparent,
            destinations: _railDestinations,
            selectedIconTheme: IconThemeData(
              color: Theme.of(context).colorScheme.primary,
            ),
            selectedLabelTextStyle: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
            unselectedIconTheme: IconThemeData(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
            ),
            unselectedLabelTextStyle: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: MainGradient(
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
                      child: navigationShell,
                    ),
                  ),
                  BlocBuilder<PlayerCubit, PlayerState>(
                    builder: (context, state) {
                      if (state.status == PlayerStatus.hidden) {
                        return const SizedBox.shrink();
                      }
                      return const MiniPlayer();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationBarLayout(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        actions: [
          IconButton(
              onPressed: () => _showGlobalSearch(context),
              icon: Icon(Icons.search)),
        ],
      ),
      backgroundColor: Colors.transparent,
      body: MainGradient(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
          child: navigationShell,
        ),
      ),
      bottomNavigationBar: BlocBuilder<PlayerCubit, PlayerState>(
        builder: (context, state) {
          if (state.status == PlayerStatus.hidden) {
            // Solo la navigation bar quando il player è nascosto
            return NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: onDestinationSelected,
              destinations: _navBarItems,
              backgroundColor:
                  Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
              indicatorColor: Theme.of(context).colorScheme.secondaryContainer,
              shadowColor: Theme.of(context).colorScheme.shadow,
              elevation: 8,
            );
          } else {
            // Mini player + navigation bar quando il player è attivo
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const MiniPlayer(),
                NavigationBar(
                  selectedIndex: navigationShell.currentIndex,
                  onDestinationSelected: onDestinationSelected,
                  destinations: _navBarItems,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  indicatorColor:
                      Theme.of(context).colorScheme.secondaryContainer,
                  shadowColor: Theme.of(context).colorScheme.shadow,
                  elevation: 8,
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

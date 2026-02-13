import 'dart:developer';

import 'package:disable_battery_optimizations_latest/disable_battery_optimizations_latest.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';
import 'package:my_tube/blocs/update_bloc/update_bloc.dart';
import 'package:my_tube/ui/views/common/custom_appbar.dart';
import 'package:my_tube/ui/views/common/global_search_delegate.dart';
import 'package:my_tube/ui/views/common/update_available_dialog.dart';
import 'package:my_tube/blocs/persistent_ui/persistent_ui_cubit.dart';

class ScaffoldWithNavbarView extends StatelessWidget {
  const ScaffoldWithNavbarView({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  static const double _miniPlayerHeight = 72.0;

  // NavigationRail destinations for larger screens
  final _railDestinations = const [
    NavigationRailDestination(
      icon: Icon(Icons.explore),
      label: Text('Explore'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.music_note),
      label: Text('Music'),
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

  void onDestinationSelected(int index, {BuildContext? context}) {
    navigationShell.goBranch(index,
        initialLocation: index == navigationShell.currentIndex);
    log('onDestinationSelected: $index');
    if (context != null) {
      Navigator.of(context).pop(); // Close drawer
    }
  }

  void _showGlobalSearch(BuildContext context) async {
    final persistentUiCubit = context.read<PersistentUiCubit>();
    // Reset padding when search is open to avoid floating miniplayer
    persistentUiCubit.setBottomPadding(0);

    await showSearch(
      context: context,
      delegate: GlobalSearchDelegate(),
    );

    // Restore padding after search is closed
    // Height will be restored by the LayoutBuilder postFrameCallback
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool useNavigationRail = constraints.maxWidth >= 640;

          // Update global UI state
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<PersistentUiCubit>().setBottomPadding(0);
          });

          if (useNavigationRail) {
            return _buildNavigationRailLayout(context);
          } else {
            return _buildDrawerLayout(context);
          }
        },
      ),
    );
  }

  Widget _buildContentPadding(BuildContext context, Widget child) {
    return BlocBuilder<PlayerCubit, PlayerState>(
      builder: (context, playerState) {
        return BlocBuilder<PersistentUiCubit, PersistentUiState>(
          builder: (context, uiState) {
            final isPlayerVisible = playerState.status != PlayerStatus.hidden &&
                uiState.isPlayerVisible;
            // The content needs padding if the player is visible,
            // otherwise it will be covered by the GlobalMiniPlayer (which is at bottom: 0)
            final bottomPadding = isPlayerVisible ? _miniPlayerHeight : 0.0;

            return Padding(
              padding: EdgeInsets.fromLTRB(8.0, 0, 8.0, bottomPadding),
              child: child,
            );
          },
        );
      },
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
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: onDestinationSelected,
            labelType: NavigationRailLabelType.all,
            destinations: _railDestinations,
          ),
          Expanded(
            child: _buildContentPadding(context, navigationShell),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerLayout(BuildContext context) {
    return Scaffold(
      drawer: _AppDrawer(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) =>
            onDestinationSelected(index, context: context),
      ),
      appBar: CustomAppbar(
        actions: [
          IconButton(
              onPressed: () => _showGlobalSearch(context),
              icon: Icon(Icons.search)),
        ],
      ),
      body: _buildContentPadding(context, navigationShell),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.6,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8.0,
                children: [
                  // Icona dell'app
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    backgroundImage:
                        AssetImage('assets/images/ic_launcher.webp'),
                  ),
                  Text(
                    'MyTube',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.explore),
            title: const Text('Explore'),
            selected: selectedIndex == 0,
            onTap: () => onDestinationSelected(0),
          ),
          ListTile(
            leading: const Icon(Icons.music_note),
            title: const Text('Music'),
            selected: selectedIndex == 1,
            onTap: () => onDestinationSelected(1),
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Favorites'),
            selected: selectedIndex == 2,
            onTap: () => onDestinationSelected(2),
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            selected: selectedIndex == 3,
            onTap: () => onDestinationSelected(3),
          ),
        ],
      ),
    );
  }
}

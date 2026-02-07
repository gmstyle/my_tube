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
  ScaffoldWithNavbarView({super.key, required this.navigationShell});
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

  final GlobalKey _navBarKey = GlobalKey();

  void onDestinationSelected(int index) {
    navigationShell.goBranch(index,
        initialLocation: index == navigationShell.currentIndex);
    log('onDestinationSelected: $index');
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
            double finalPadding = 0;
            if (!useNavigationRail) {
              final RenderBox? navBarBox =
                  _navBarKey.currentContext?.findRenderObject() as RenderBox?;
              if (navBarBox != null && navBarBox.hasSize) {
                finalPadding = navBarBox.size.height;
              } else {
                // Fallback to nominal height if measurement fails
                finalPadding = 80.0;
              }
            }
            context.read<PersistentUiCubit>().setBottomPadding(finalPadding);
          });

          if (useNavigationRail) {
            return _buildNavigationRailLayout(context);
          } else {
            return _buildNavigationBarLayout(context);
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
            final bottomPadding = isPlayerVisible ? uiState.bottomPadding : 0.0;

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

  Widget _buildNavigationBarLayout(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        actions: [
          IconButton(
              onPressed: () => _showGlobalSearch(context),
              icon: Icon(Icons.search)),
        ],
      ),
      body: _buildContentPadding(context, navigationShell),
      bottomNavigationBar: NavigationBar(
        key: _navBarKey,
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: _navBarItems,
      ),
    );
  }
}

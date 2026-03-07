import 'dart:developer';

import 'package:disable_battery_optimizations_latest/disable_battery_optimizations_latest.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';
import 'package:my_tube/blocs/update_bloc/update_bloc.dart';

import 'package:my_tube/ui/views/common/update_available_dialog.dart';
import 'package:my_tube/blocs/persistent_ui/persistent_ui_cubit.dart';

class ScaffoldWithNavbarView extends StatelessWidget {
  const ScaffoldWithNavbarView({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  static const double _miniPlayerHeight = 60.0;
  static const double _bottomNavigationBarHeight = 65.0;

  final _navigationBarDestinations = const [
    NavigationDestination(
      icon: Icon(Icons.explore_outlined),
      selectedIcon: Icon(Icons.explore),
      label: 'Explore',
    ),
    NavigationDestination(
      icon: Icon(Icons.music_note_outlined),
      selectedIcon: Icon(Icons.music_note),
      label: 'Music',
    ),
    NavigationDestination(
      icon: Icon(Icons.favorite_outline),
      selectedIcon: Icon(Icons.favorite),
      label: 'Favorites',
    ),
    NavigationDestination(
      icon: Icon(Icons.search_outlined),
      selectedIcon: Icon(Icons.search),
      label: 'Search',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: 'Settings',
    ),
  ];

  final _railDestinations = const [
    NavigationRailDestination(
      icon: Icon(Icons.explore_outlined),
      selectedIcon: Icon(Icons.explore),
      label: Text('Explore'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.music_note_outlined),
      selectedIcon: Icon(Icons.music_note),
      label: Text('Music'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.favorite_outline),
      selectedIcon: Icon(Icons.favorite),
      label: Text('Favorites'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.search_outlined),
      selectedIcon: Icon(Icons.search),
      label: Text('Search'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: Text('Settings'),
    ),
  ];

  void onDestinationSelected(int index, {BuildContext? context}) {
    navigationShell.goBranch(index,
        initialLocation: index == navigationShell.currentIndex);
    log('onDestinationSelected: $index');
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
          // Compensiamo il rialzo di sistema (es. la barra dei gesti di Android/iOS)
          final bottomSafeArea = MediaQuery.of(context).padding.bottom;
          final leftSafeArea = MediaQuery.of(context).padding.left;

          // Update global UI state to keep MiniPlayer hovering perfectly
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // Material 3 NavigationBar custom squeezed height is 65.0
            // Material 3 NavigationRail default width is 80.0
            context.read<PersistentUiCubit>().setBottomLayout(
                  useNavigationRail ? 0 : _bottomNavigationBarHeight,
                  bottomSafeArea,
                );
            context.read<PersistentUiCubit>().setLeftPadding(
                  useNavigationRail ? 80.0 + leftSafeArea : 0,
                );
          });

          if (useNavigationRail) {
            return _buildNavigationRailLayout(context);
          } else {
            return _buildMobileLayout(context);
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
            // The content needs padding if the player is visible, plus the dynamic uiState padding (NavBar height, safe areas, etc.)
            final playerHeight = isPlayerVisible ? _miniPlayerHeight : 0.0;
            final double currentBottomPadding =
                playerHeight + uiState.bottomPadding;

            return AnimatedPadding(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: EdgeInsets.fromLTRB(0.0, 0, 0.0, currentBottomPadding),
              child: child,
            );
          },
        );
      },
    );
  }

  Widget _buildNavigationRailLayout(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) =>
                onDestinationSelected(index, context: context),
            labelType: NavigationRailLabelType.all,
            groupAlignment: -1.0,
            destinations: _railDestinations,
            // Optionally we can add leading/trailing here for aesthetics
          ),
          Expanded(
            child: _buildContentPadding(context, navigationShell),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      extendBody:
          true, // Importante per far scorrere la NavBar senza lasciare buchi bianchi sotto
      body: MediaQuery.removePadding(
        context: context,
        removeBottom:
            true, // Il padding inferiore lo forniamo noi via _buildContentPadding dinamicamente
        child: NotificationListener<UserScrollNotification>(
          onNotification: (notification) {
            final cubit = context.read<PersistentUiCubit>();
            if (notification.direction == ScrollDirection.reverse) {
              // Utente scorre verso il basso -> Nascondiamo NavBar
              cubit.setNavBarVisibility(false);
            } else if (notification.direction == ScrollDirection.forward) {
              // Utente scorre verso l'alto -> Mostriamo NavBar
              cubit.setNavBarVisibility(true);
            }
            return false;
          },
          child: _buildContentPadding(context, navigationShell),
        ),
      ),
      bottomNavigationBar: BlocBuilder<PersistentUiCubit, PersistentUiState>(
        buildWhen: (previous, current) =>
            previous.isNavBarVisible != current.isNavBarVisible ||
            previous.isSearchOpen != current.isSearchOpen,
        builder: (context, uiState) {
          final hideBar = !uiState.isNavBarVisible || uiState.isSearchOpen;

          return AnimatedSlide(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            offset: hideBar ? const Offset(0, 1) : Offset.zero,
            child: NavigationBarTheme(
              data: NavigationBarThemeData(
                // Rimuoviamo l'ombra "pesante" di default per far fondere la barra col contenuto
                elevation: 0,
                // Sfondo leggermente differenziato o opaco a seconda del tema
                backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                // Colore del riquadro di selezione (il rettangolo stondato)
                indicatorColor: Theme.of(context).colorScheme.primaryContainer,

                // Regoliamo le icone dinamicamente (colore e grandezza)
                iconTheme: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return IconThemeData(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      size: 26, // Lieve ingrandimento "pop"
                    );
                  }
                  return IconThemeData(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withValues(alpha: 0.7),
                    size: 24, // Dimensione classica non selezionata
                  );
                }),

                // Stile tipografico sofisticato per l'etichetta selezionata
                labelTextStyle: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3, // Aggiunge respiro
                      color: Theme.of(context).colorScheme.primary,
                    );
                  }
                  return const TextStyle();
                }),

                // Mostriamo l'etichetta solo per la pagina in cui ci troviamo (Minimalismo)
                labelBehavior:
                    NavigationDestinationLabelBehavior.onlyShowSelected,
                // Cambiamo la forma della "pillola" di selezione in un rettangolo stondato premium
                indicatorShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: NavigationBar(
                height:
                    _bottomNavigationBarHeight, // Ridotto considerevolmente rispetto al default (80)
                selectedIndex: navigationShell.currentIndex,
                onDestinationSelected: (index) =>
                    onDestinationSelected(index, context: context),
                destinations: _navigationBarDestinations,
              ),
            ),
          );
        },
      ),
    );
  }
}

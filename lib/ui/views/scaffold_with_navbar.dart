import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/router/app_router.dart';
import 'package:my_tube/ui/views/common/main_gradient.dart';
import 'package:my_tube/ui/views/common/mini_player.dart';

class ScaffoldWithNavbarView extends StatefulWidget {
  const ScaffoldWithNavbarView({super.key, required this.child});
  final Widget child;

  @override
  State<ScaffoldWithNavbarView> createState() => _ScaffoldWithNavbarViewState();
}

class _ScaffoldWithNavbarViewState extends State<ScaffoldWithNavbarView> {
  int currentIndex = 0;
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
    switch (index) {
      case 0:
        context.goNamed(AppRoute.explore.name);
        break;
      case 1:
        context.goNamed(AppRoute.music.name);
        break;

      case 2:
        context.goNamed(AppRoute.favorites.name);
        break;
      case 3:
        context.goNamed(AppRoute.search.name);
        break;
      default:
        break;
    }

    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainGradient(
      child: SafeArea(
        child: Scaffold(
          /*appBar: const CustomAppbar(
               actions: [
              IconButton(
                  onPressed: () {
                    showSearch(
                        context: context,
                        delegate: CustomSearchDelegate(
                            searchBloc: searchBloc,
                            searchSuggestionCubit: serachSuggestionsCubit,
                            miniPlayerCubit: miniPlayerCubit));
                  },
                  icon: const Icon(Icons.search))
            ],
              ), */
          backgroundColor: Colors.transparent,
          body: widget.child,
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              //const SkeletonMiniPlayer(),
              const MiniPlayer(),
              NavigationBar(
                  elevation: 0,
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  selectedIndex: currentIndex,
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

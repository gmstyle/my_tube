import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/blocs/home/mini_player_cubit/mini_player_cubit.dart';
import 'package:my_tube/blocs/home/search_bloc/search_bloc.dart';
import 'package:my_tube/blocs/home/search_suggestion/search_suggestion_cubit.dart';
import 'package:my_tube/router/app_router.dart';
import 'package:my_tube/ui/views/common/custom_appbar.dart';
import 'package:my_tube/ui/views/common/custom_search_delegate.dart';
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
        context.goNamed(AppRoute.queue.name);
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
    final searchBloc = context.read<SearchBloc>();
    final serachSuggestionsCubit = context.read<SearchSuggestionCubit>();
    final miniPlayerCubit = context.read<MiniPlayerCubit>();
    final miniPlayerHeight = MediaQuery.of(context).size.height * 0.10;
    final miniplayerStatus = context.watch<MiniPlayerCubit>().state.status;

    return MainGradient(
      child: Scaffold(
        appBar: CustomAppbar(
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
        ),
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            /// Tab content
            Expanded(child: widget.child),

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
            selectedIndex: currentIndex,
            destinations: _navBarItems,
            onDestinationSelected: onDestinationSelected,
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected),
      ),
    );
  }
}

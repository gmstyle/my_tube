import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/mini_player_cubit/mini_player_cubit.dart';
import 'package:my_tube/blocs/home/search_bloc/search_bloc.dart';
import 'package:my_tube/ui/views/common/mini_player.dart';
import 'package:my_tube/ui/views/home/tabs/account_tab.dart';
import 'package:my_tube/ui/views/home/tabs/explore_tab.dart';
import 'package:my_tube/ui/views/home/tabs/subscriptions_tab.dart';

import 'package:my_tube/ui/views/common/mt_search_delegate.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final pageController = PageController();
  int currentIndex = 0;

  final _navBarItems = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.explore),
      label: 'Explore',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.subscriptions),
      label: 'Subscriptions',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.account_circle),
      label: 'My Account',
    ),
  ];

  final _tabs = [ExploreTab(), const SubscriptionsTab(), const AccountTab()];

  void _onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  void _onTap(int index) {
    pageController.animateToPage(index,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    final searchBloc = context.read<SearchBloc>();
    final miniPlayerCubit = context.read<MiniPlayerCubit>();
    final miniPlayerHeight = MediaQuery.of(context).size.height * 0.1;
    final miniplayerStatus = context.watch<MiniPlayerCubit>().state.status;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tube'),
        actions: [
          // Search button
          IconButton(
              onPressed: () {
                showSearch(
                    context: context,
                    delegate: MTSearchDelegate(
                        searchBloc: searchBloc,
                        miniPlayerCubit: miniPlayerCubit));
              },
              icon: const Icon(Icons.search),
              tooltip: 'Search'),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: pageController,
              onPageChanged: _onPageChanged,
              physics: const NeverScrollableScrollPhysics(),
              children: _tabs,
            ),
          ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// Mini player
          AnimatedContainer(
            decoration: const BoxDecoration(
                //color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.only(
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
                  return MiniPlayer(
                    video: state.video,
                    streamUrl: state.streamUrl!,
                    chewieController: state.chewieController!,
                  );
                default:
                  return const SizedBox.shrink();
              }
            }),
          ),
          BottomNavigationBar(
            currentIndex: currentIndex,
            items: _navBarItems,
            onTap: _onTap,
            type: BottomNavigationBarType.fixed,
          ),
        ],
      ),
    );
  }
}

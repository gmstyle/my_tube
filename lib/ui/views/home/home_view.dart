import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/explore_tab/explore_tab_bloc.dart';
import 'package:my_tube/blocs/home/mini_player_cubit/mini_player_cubit.dart';
import 'package:my_tube/ui/views/common/mini_player.dart';
import 'package:my_tube/ui/views/home/tabs/account_tab.dart';
import 'package:my_tube/ui/views/home/tabs/explore_tab.dart';
import 'package:my_tube/ui/views/home/tabs/subscriptions_tab.dart';

import '../../../respositories/youtube_repository.dart';
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
    final youtubeRepository = context.read<YoutubeRepository>();
    final miniPlayerHeight = MediaQuery.of(context).size.height * 0.1;
    final miniplayerStatus = context.watch<MiniPlayerCubit>().state.status;

    return MultiBlocProvider(
        providers: [
          BlocProvider<ExploreTabBloc>(
              create: (_) =>
                  ExploreTabBloc(youtubeRepository: youtubeRepository)
                    ..add(const GetVideos())),
        ],
        child: Scaffold(
          appBar: AppBar(
            title: const Text('My Tube'),
            actions: [
              // Search button
              IconButton(
                  onPressed: () {
                    showSearch(context: context, delegate: MTSearchDelegate());
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
                      return MiniPlayer(
                        video: state.video!,
                        streamUrl: state.streamUrl!,
                        chewieController: state.chewieController!,
                      );
                    default:
                      return const SizedBox.shrink();
                  }
                }),
              )
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: currentIndex,
            items: _navBarItems,
            onTap: _onTap,
            type: BottomNavigationBarType.fixed,
          ),
        ));
  }
}

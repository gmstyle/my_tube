import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/explore_tab/explore_tab_bloc.dart';
import 'package:my_tube/ui/views/home/tabs/account_tab.dart';
import 'package:my_tube/ui/views/home/tabs/explore_tab.dart';
import 'package:my_tube/ui/views/home/tabs/subscriptions_tab.dart';

import '../../../respositories/youtube_repository.dart';

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

  final _tabs = [ExploreTab(), SubscriptionsTab(), AccountTab()];

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
    return MultiBlocProvider(
        providers: [
          BlocProvider<ExploreTabBloc>(
              create: (_) => ExploreTabBloc(
                  youtubeRepository: context.read<YoutubeRepository>())
                ..add(const GetVideos()))
        ],
        child: Scaffold(
          appBar: AppBar(
            title: const Text('My Tube'),
          ),
          body: PageView(
            controller: pageController,
            onPageChanged: _onPageChanged,
            physics: const NeverScrollableScrollPhysics(),
            children: _tabs,
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:googleapis/content/v2_1.dart';
import 'package:my_tube/blocs/home/home_bloc.dart';
import 'package:my_tube/ui/views/home/tabs/account_tab.dart';
import 'package:my_tube/ui/views/home/tabs/explore_tab.dart';
import 'package:my_tube/ui/views/home/tabs/home_tab.dart';
import 'package:my_tube/ui/views/home/tabs/subscriptions_tab.dart';

import '../../../blocs/auth/auth_bloc.dart';
import '../../../respositories/youtube_repository.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int currentIndex = 0;

  final _navBarItems = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Home',
    ),
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

  final _tabs = const [
    HomeTab(),
    ExploreTab(),
    SubscriptionsTab(),
    AccountTab()
  ];

  void _onTap(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<HomeBloc>(
              create: (_) =>
                  HomeBloc(youtubeRepository: context.read<YoutubeRepository>())
                    ..add(const GetVideos()))
        ],
        child: Scaffold(
          appBar: AppBar(
            title: const Text('My Tube'),
          ),
          body: IndexedStack(
            index: currentIndex,
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

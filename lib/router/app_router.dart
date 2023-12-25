import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/router/pages/channel_page.dart';
import 'package:my_tube/router/pages/explore_tab_page.dart';
import 'package:my_tube/router/pages/musci_tab_page.dart';
import 'package:my_tube/router/pages/playlist_page.dart';
import 'package:my_tube/router/pages/queue_tab_page.dart';
import 'package:my_tube/router/pages/subscriptions_tab_page.dart';
import 'package:my_tube/ui/views/scaffold_with_navbar.dart';

class AppRouter {
  static final rootNavigatorKey = GlobalKey<NavigatorState>();
  static final shellNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(navigatorKey: rootNavigatorKey, routes: [
    ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) =>
            ScaffoldWithNavbarView(child: child),
        routes: [
          // Tab Explore
          GoRoute(
              parentNavigatorKey: shellNavigatorKey,
              name: AppRoute.explore.name,
              path: AppRoute.explore.path,
              pageBuilder: (context, state) => const ExploreTabPage(),
              routes: [
                GoRoute(
                    path: AppRoute.channel.path,
                    pageBuilder: (context, state) {
                      final extra = state.extra as Map<String, dynamic>;
                      final channelId = extra['channelId'] as String;
                      return ChannelPage(channelId: channelId);
                    }),
                GoRoute(
                    name: AppRoute.playlist.name,
                    path: AppRoute.playlist.path,
                    pageBuilder: (context, state) {
                      final extra = state.extra as Map<String, dynamic>;
                      final playlistId = extra['playlistId'] as String;
                      return PlaylistPage(playlistId: playlistId);
                    }),
              ]),

          // Tab Favorites
          GoRoute(
              parentNavigatorKey: shellNavigatorKey,
              name: AppRoute.music.name,
              path: AppRoute.music.path,
              pageBuilder: (context, state) => const MusicTabPAge()),

          // Tab Subscriptions
          GoRoute(
              name: AppRoute.subscriptions.name,
              path: AppRoute.subscriptions.path,
              pageBuilder: (context, state) => const SubscriptionsTabPAge(),
              routes: [
                GoRoute(
                    parentNavigatorKey: shellNavigatorKey,
                    name: AppRoute.channel.name,
                    path: AppRoute.channel.path,
                    pageBuilder: (context, state) {
                      final extra = state.extra as Map<String, dynamic>;
                      final channelId = extra['channelId'] as String;
                      return ChannelPage(channelId: channelId);
                    }),
              ]),

          // Tab Queue
          GoRoute(
              parentNavigatorKey: shellNavigatorKey,
              name: AppRoute.queue.name,
              path: AppRoute.queue.path,
              pageBuilder: (context, state) => const QueueTabPage())
        ]),
  ]);
}

enum AppRoute {
  explore('/'),
  music('/music'),
  search('/search'),
  subscriptions('/subscriptions'),
  account('/account'),
  channel('channel'),
  playlist('playlist'),
  queue('/queue'),
  ;

  final String path;

  const AppRoute(this.path);
}

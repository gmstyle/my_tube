import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/router/pages/channel_page.dart';
import 'package:my_tube/router/pages/explore_tab_page.dart';
import 'package:my_tube/router/pages/musci_tab_page.dart';
import 'package:my_tube/router/pages/playlist_page.dart';
import 'package:my_tube/router/pages/favorites_tab_page.dart';
import 'package:my_tube/router/pages/search_page.dart';
import 'package:my_tube/router/pages/video_page.dart';
import 'package:my_tube/ui/views/scaffold_with_navbar.dart';

class AppRouter {
  static final rootNavigatorKey = GlobalKey<NavigatorState>();
  static final shellNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(navigatorKey: rootNavigatorKey, routes: [
    // Root
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      name: AppRoute.video.name,
      path: AppRoute.video.path,
      pageBuilder: (context, state) => const VideoPage(),
    ),
    // Shell
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
            /* routes: [
                GoRoute(
                    name: AppRoute.channel.name,
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
              ] */
          ),

          // Tab Favorites
          GoRoute(
              parentNavigatorKey: shellNavigatorKey,
              name: AppRoute.music.name,
              path: AppRoute.music.path,
              pageBuilder: (context, state) => const MusicTabPAge()),

          // Tab Favorites
          GoRoute(
              parentNavigatorKey: shellNavigatorKey,
              name: AppRoute.favorites.name,
              path: AppRoute.favorites.path,
              pageBuilder: (context, state) => const FavoritesTabPage()),

          // Tab Search
          GoRoute(
              parentNavigatorKey: shellNavigatorKey,
              name: AppRoute.search.name,
              path: AppRoute.search.path,
              pageBuilder: (context, state) => const SearchPage(),
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
                GoRoute(
                    parentNavigatorKey: shellNavigatorKey,
                    name: AppRoute.playlist.name,
                    path: AppRoute.playlist.path,
                    pageBuilder: (context, state) {
                      final extra = state.extra as Map<String, dynamic>;
                      final playlistId = extra['playlistId'] as String;
                      return PlaylistPage(playlistId: playlistId);
                    }),
              ]),
        ]),
  ]);
}

enum AppRoute {
  explore('/'),
  music('/music'),
  search('/search'),
  account('/account'),
  channel('channel'),
  playlist('playlist'),
  favorites('/favorites'),
  video('/video');

  final String path;

  const AppRoute(this.path);
}

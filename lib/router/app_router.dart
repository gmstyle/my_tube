import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/router/pages/app_shell_page.dart';
import 'package:my_tube/router/pages/channel_page.dart';
import 'package:my_tube/router/pages/explore_tab_page.dart';
import 'package:my_tube/router/pages/playlist_page.dart';
import 'package:my_tube/router/pages/favorites_tab_page.dart';
import 'package:my_tube/router/pages/search_page.dart';
import 'package:my_tube/router/pages/settings_page.dart';
import 'package:my_tube/router/pages/video_page.dart';
import 'package:my_tube/router/pages/test_youtube_explode_page.dart';

class AppRouter {
  static final rootNavigatorKey = GlobalKey<NavigatorState>();
  static final exploreKey = GlobalKey<NavigatorState>();
  //static final musicKey = GlobalKey<NavigatorState>();
  static final searchKey = GlobalKey<NavigatorState>();
  static final favoritesKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(navigatorKey: rootNavigatorKey, routes: [
    // Root
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      name: AppRoute.video.name,
      path: AppRoute.video.path,
      pageBuilder: (context, state) => const VideoPage(),
    ),
    // Settings
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      name: AppRoute.settings.name,
      path: AppRoute.settings.path,
      pageBuilder: (context, state) => const SettingsPage(),
    ),
    // Test YouTube Explode
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      name: AppRoute.testYoutubeExplode.name,
      path: AppRoute.testYoutubeExplode.path,
      pageBuilder: (context, state) => const TestYoutubeExplodePageWrapper(),
    ),
    // Shell
    StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShellPage(navigationShell: navigationShell),
        branches: [
          // Tab Explore
          StatefulShellBranch(navigatorKey: exploreKey, routes: [
            GoRoute(
                name: AppRoute.explore.name,
                path: AppRoute.explore.path,
                pageBuilder: (context, state) => const ExploreTabPage()),
          ]),

          // Tab Music
          /*StatefulShellBranch(navigatorKey: musicKey, routes: [
            GoRoute(
                name: AppRoute.music.name,
                path: AppRoute.music.path,
                pageBuilder: (context, state) => const MusicTabPAge())
          ]),*/

          // Tab Favorites
          StatefulShellBranch(navigatorKey: favoritesKey, routes: [
            GoRoute(
                name: AppRoute.favorites.name,
                path: AppRoute.favorites.path,
                pageBuilder: (context, state) => const FavoritesTabPage(),
                routes: [
                  GoRoute(
                      name: AppRoute.channelFavorites.name,
                      path: AppRoute.channelFavorites.path,
                      pageBuilder: (context, state) {
                        final extra = state.extra as Map<String, dynamic>;
                        final channelId = extra['channelId'] as String;
                        return ChannelPage(channelId: channelId);
                      }),
                  GoRoute(
                      name: AppRoute.playlistFavorites.name,
                      path: AppRoute.playlistFavorites.path,
                      pageBuilder: (context, state) {
                        final extra = state.extra as Map<String, dynamic>;
                        final playlistId = extra['playlistId'] as String;
                        return PlaylistPage(playlistId: playlistId);
                      }),
                ]),
          ]),

          // Tab Search
          StatefulShellBranch(navigatorKey: searchKey, routes: [
            GoRoute(
                name: AppRoute.search.name,
                path: AppRoute.search.path,
                pageBuilder: (context, state) => const SearchPage(),
                routes: [
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
                ]),
          ])
        ]),
  ]);
}

enum AppRoute {
  explore('/'),
  music('/music'),
  search('/search'),
  account('/account'),
  channel('channel'),
  channelFavorites('channelFavorite'),
  playlist('playlist'),
  playlistFavorites('playlistFavorite'),
  favorites('/favorites'),
  settings('/settings'),
  video('/video'),
  testYoutubeExplode('/test-youtube-explode');

  final String path;

  const AppRoute(this.path);
}

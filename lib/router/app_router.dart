import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/router/pages/app_shell_page.dart';
import 'package:my_tube/router/pages/channel_page.dart';
import 'package:my_tube/router/pages/explore_tab_page.dart';
import 'package:my_tube/router/pages/music_tab_page.dart';
import 'package:my_tube/router/pages/playlist_page.dart';
import 'package:my_tube/router/pages/favorites_tab_page.dart';
import 'package:my_tube/router/pages/queue_page.dart';
import 'package:my_tube/router/pages/search_tab_page.dart';
import 'package:my_tube/router/pages/settings_page.dart';
import 'package:my_tube/router/pages/video_page.dart';
import 'package:my_tube/models/custom_playlist.dart';
import 'package:my_tube/router/pages/custom_playlist_page.dart';
import 'package:my_tube/ui/views/common/global_mini_player.dart';

class AppRouter {
  /// Shared secondary routes injected into every tab branch.
  /// Using relative paths (no leading `/`) so they resolve correctly under any branch.
  static List<RouteBase> _buildSharedSubRoutes() => [
        GoRoute(
          path: 'channel',
          pageBuilder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            final channelId = extra['channelId'] as String;
            return ChannelPage(channelId: channelId);
          },
        ),
        GoRoute(
          path: 'playlist',
          pageBuilder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            final playlistId = extra['playlistId'] as String;
            return PlaylistPage(playlistId: playlistId);
          },
        ),
        GoRoute(
          path: 'custom-playlist',
          pageBuilder: (context, state) {
            final playlist = state.extra as CustomPlaylist;
            return CustomPlaylistPage(playlist: playlist);
          },
        ),
        GoRoute(
          path: 'queue',
          pageBuilder: (context, state) => const QueuePage(),
        ),
      ];

  static final rootNavigatorKey = GlobalKey<NavigatorState>();
  static final shellNavigatorKey = GlobalKey<NavigatorState>();
  static final exploreKey = GlobalKey<NavigatorState>();
  static final musicKey = GlobalKey<NavigatorState>();
  static final favoritesKey = GlobalKey<NavigatorState>();
  static final searchKey = GlobalKey<NavigatorState>();
  static final settingsKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(navigatorKey: rootNavigatorKey, routes: [
    ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) {
          return Stack(
            children: [
              child,
              const GlobalMiniPlayer(),
            ],
          );
        },
        routes: [
          // ── Video player (full-screen, no navbar) ──────────────────────
          GoRoute(
            parentNavigatorKey: shellNavigatorKey,
            name: AppRoute.video.name,
            path: AppRoute.video.path,
            pageBuilder: (context, state) => const VideoPage(),
            routes: [
              // Queue accessible from the full-screen player
              GoRoute(
                parentNavigatorKey: shellNavigatorKey,
                name: AppRoute.queue.name,
                path: AppRoute.queue.path,
                pageBuilder: (context, state) => const QueuePage(),
              ),
            ],
          ),

          // ── Tab shell (Navbar always visible) ─────────────────────────
          StatefulShellRoute.indexedStack(
              builder: (context, state, navigationShell) =>
                  AppShellPage(navigationShell: navigationShell),
              branches: [
                // Tab Explore
                StatefulShellBranch(navigatorKey: exploreKey, routes: [
                  GoRoute(
                      name: AppRoute.explore.name,
                      path: AppRoute.explore.path,
                      pageBuilder: (context, state) => const ExploreTabPage(),
                      routes: AppRouter._buildSharedSubRoutes()),
                ]),

                // Tab Music
                StatefulShellBranch(navigatorKey: musicKey, routes: [
                  GoRoute(
                      name: AppRoute.music.name,
                      path: AppRoute.music.path,
                      pageBuilder: (context, state) => const MusicTabPage(),
                      routes: AppRouter._buildSharedSubRoutes()),
                ]),

                // Tab Favorites
                StatefulShellBranch(navigatorKey: favoritesKey, routes: [
                  GoRoute(
                      name: AppRoute.favorites.name,
                      path: AppRoute.favorites.path,
                      pageBuilder: (context, state) => const FavoritesTabPage(),
                      routes: AppRouter._buildSharedSubRoutes()),
                ]),

                // Tab Search
                StatefulShellBranch(navigatorKey: searchKey, routes: [
                  GoRoute(
                      name: AppRoute.search.name,
                      path: AppRoute.search.path,
                      pageBuilder: (context, state) => const SearchTabPage(),
                      routes: AppRouter._buildSharedSubRoutes()),
                ]),

                // Tab Settings
                StatefulShellBranch(navigatorKey: settingsKey, routes: [
                  GoRoute(
                      name: AppRoute.settings.name,
                      path: AppRoute.settings.path,
                      pageBuilder: (context, state) => const SettingsPage(),
                      routes: AppRouter._buildSharedSubRoutes()),
                ])
              ]),
        ]),
  ]);
}

enum AppRoute {
  explore('/'),
  music('/music'),
  account('/account'),
  favorites('/favorites'),
  settings('/settings'),
  search('/search'),
  // Video player (full-screen, shell level)
  video('/video'),
  // Queue as sub-route of video (shell level, from full-screen player)
  queue('queue'),
  testYoutubeExplode('/test-youtube-explode');

  final String path;

  const AppRoute(this.path);
}

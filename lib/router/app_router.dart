import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/router/pages/account_tab_page.dart';
import 'package:my_tube/router/pages/channel_page.dart';
import 'package:my_tube/router/pages/explore_tab_page.dart';
import 'package:my_tube/router/pages/favorites_tab_page.dart';
import 'package:my_tube/router/pages/login_page.dart';
import 'package:my_tube/router/pages/playlist_page.dart';
import 'package:my_tube/router/pages/search_page.dart';
import 'package:my_tube/router/pages/splash_page.dart';
import 'package:my_tube/router/pages/subscriptions_tab_page.dart';
import 'package:my_tube/ui/views/scaffold_with_navbar.dart';

class AppRouter {
  static final rootNavigatorKey = GlobalKey<NavigatorState>();
  static final exploreTabNavigatorKey = GlobalKey<NavigatorState>();
  static final favoritesTabNavigatorKey = GlobalKey<NavigatorState>();
  static final searchTabNavigatorKey = GlobalKey<NavigatorState>();
  static final subscriptionsTabNavigatorKey = GlobalKey<NavigatorState>();
  static final accountTabNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: AppRoute.splash.path,
      routes: [
        GoRoute(
            parentNavigatorKey: rootNavigatorKey,
            name: AppRoute.splash.name,
            path: AppRoute.splash.path,
            pageBuilder: (context, state) => const SplashPage()),
        GoRoute(
            parentNavigatorKey: rootNavigatorKey,
            name: AppRoute.login.name,
            path: AppRoute.login.path,
            pageBuilder: (context, state) => const LoginPage()),
        StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) =>
                ScaffoldWithNavbarView(navigationShell: navigationShell),
            branches: [
              // Tab Explore
              StatefulShellBranch(
                  navigatorKey: exploreTabNavigatorKey,
                  routes: [
                    GoRoute(
                        name: AppRoute.explore.name,
                        path: AppRoute.explore.path,
                        pageBuilder: (context, state) =>
                            const ExploreTabPage()),
                  ]),

              // Tab Favorites
              StatefulShellBranch(
                  navigatorKey: favoritesTabNavigatorKey,
                  routes: [
                    GoRoute(
                        name: AppRoute.favorites.name,
                        path: AppRoute.favorites.path,
                        pageBuilder: (context, state) =>
                            const FavoritesTabPAge()),
                  ]),

              // Tab Search
              StatefulShellBranch(navigatorKey: searchTabNavigatorKey, routes: [
                GoRoute(
                    name: AppRoute.search.name,
                    path: AppRoute.search.path,
                    pageBuilder: (context, state) => const SearchPage(),
                    routes: [
                      GoRoute(
                          parentNavigatorKey: searchTabNavigatorKey,
                          path: AppRoute.channel.path,
                          pageBuilder: (context, state) {
                            final extra = state.extra as Map<String, dynamic>;
                            final channelId = extra['channelId'] as String;
                            return ChannelPage(channelId: channelId);
                          }),
                      GoRoute(
                          parentNavigatorKey: searchTabNavigatorKey,
                          name: AppRoute.playlist.name,
                          path: AppRoute.playlist.path,
                          pageBuilder: (context, state) {
                            final extra = state.extra as Map<String, dynamic>;
                            final playlistTitle =
                                extra['playlistTitle'] as String;
                            final playlistId = extra['playlistId'] as String;
                            return PlaylistPage(
                                playlistTitle: playlistTitle,
                                playlistId: playlistId);
                          })
                    ]),
              ]),

              // Tab Subscriptions
              StatefulShellBranch(
                  navigatorKey: subscriptionsTabNavigatorKey,
                  routes: [
                    GoRoute(
                        name: AppRoute.subscriptions.name,
                        path: AppRoute.subscriptions.path,
                        pageBuilder: (context, state) =>
                            const SubscriptionsTabPAge(),
                        routes: [
                          GoRoute(
                              parentNavigatorKey: subscriptionsTabNavigatorKey,
                              name: AppRoute.channel.name,
                              path: AppRoute.channel.path,
                              pageBuilder: (context, state) {
                                final extra =
                                    state.extra as Map<String, dynamic>;
                                final channelId = extra['channelId'] as String;
                                return ChannelPage(channelId: channelId);
                              }),
                        ]),
                  ]),

              // Tab Account
              StatefulShellBranch(
                  navigatorKey: accountTabNavigatorKey,
                  routes: [
                    GoRoute(
                        name: AppRoute.account.name,
                        path: AppRoute.account.path,
                        pageBuilder: (context, state) => const AccountTabPage())
                  ]),
            ]),
      ]);
}

enum AppRoute {
  splash('/'),
  login('/login'),
  explore('/explore'),
  favorites('/favorites'),
  search('/search'),
  subscriptions('/subscriptions'),
  account('/account'),
  channel('channel'),
  playlist('playlist');

  final String path;

  const AppRoute(this.path);
}

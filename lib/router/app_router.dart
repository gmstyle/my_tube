import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/router/pages/account_tab_page.dart';
import 'package:my_tube/router/pages/explore_tab_page.dart';
import 'package:my_tube/router/pages/favorites_tab_page.dart';
import 'package:my_tube/router/pages/login_page.dart';
import 'package:my_tube/router/pages/subscriptions_tab_page.dart';
import 'package:my_tube/ui/views/scaffold_with_navbar.dart';

class AppRouter {
  static final rootNavigatorKey = GlobalKey<NavigatorState>();
  static final exploreTabNavigatorKey = GlobalKey<NavigatorState>();
  static final favoritesTabNavigatorKey = GlobalKey<NavigatorState>();
  static final subscriptionsTabNavigatorKey = GlobalKey<NavigatorState>();
  static final accountTabNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: AppRoute.login.path,
      routes: [
        StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) =>
                ScaffoldWithNavbarView(navigationShell: navigationShell),
            branches: [
              StatefulShellBranch(
                  navigatorKey: exploreTabNavigatorKey,
                  routes: [
                    GoRoute(
                        name: AppRoute.explore.name,
                        path: AppRoute.explore.path,
                        pageBuilder: (context, state) =>
                            const ExploreTabPage()),
                  ]),
              StatefulShellBranch(
                  navigatorKey: favoritesTabNavigatorKey,
                  routes: [
                    GoRoute(
                        name: AppRoute.favorites.name,
                        path: AppRoute.favorites.path,
                        pageBuilder: (context, state) =>
                            const FavoritesTabPAge()),
                  ]),
              StatefulShellBranch(
                  navigatorKey: subscriptionsTabNavigatorKey,
                  routes: [
                    GoRoute(
                        name: AppRoute.subscriptions.name,
                        path: AppRoute.subscriptions.path,
                        pageBuilder: (context, state) =>
                            const SubscriptionsTabPAge()),
                  ]),
              StatefulShellBranch(
                  navigatorKey: accountTabNavigatorKey,
                  routes: [
                    GoRoute(
                        name: AppRoute.account.name,
                        path: AppRoute.account.path,
                        pageBuilder: (context, state) => const AccountTabPage())
                  ]),
            ]),
        GoRoute(
            parentNavigatorKey: rootNavigatorKey,
            name: AppRoute.login.name,
            path: AppRoute.login.path,
            pageBuilder: (context, state) => const LoginPage())
      ]);
}

enum AppRoute {
  dashboard('/'),
  login('/login'),
  explore('/explore'),
  favorites('/favorites'),
  subscriptions('/subscriptions'),
  account('/account');

  final String path;

  const AppRoute(this.path);
}

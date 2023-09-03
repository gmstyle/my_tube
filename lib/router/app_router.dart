import 'package:go_router/go_router.dart';
import 'package:my_tube/router/pages/dashboard_page.dart';

class AppRouter {
  static final router = GoRouter(routes: [
    GoRoute(
      name: AppRoute.dashboard.name,
      path: AppRoute.dashboard.path,
      pageBuilder: (context, state) => const DashboardPage(),
    )
  ]);
}

enum AppRoute {
  dashboard('/');

  final String path;

  const AppRoute(this.path);
}

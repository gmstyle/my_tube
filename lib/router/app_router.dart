import 'package:go_router/go_router.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:my_tube/router/pages/dashboard_page.dart';
import 'package:my_tube/router/pages/video_player_page.dart';

class AppRouter {
  static final router = GoRouter(routes: [
    GoRoute(
        name: AppRoute.dashboard.name,
        path: AppRoute.dashboard.path,
        pageBuilder: (context, state) => const DashboardPage(),
        routes: [
          GoRoute(
            name: AppRoute.videoPlayer.name,
            path: AppRoute.videoPlayer.path,
            pageBuilder: (context, state) {
              final video = state.extra as Video;
              return VideoPlayerPage(video: video);
            },
          )
        ])
  ]);
}

enum AppRoute {
  dashboard('/'),
  videoPlayer('video-player');

  final String path;

  const AppRoute(this.path);
}

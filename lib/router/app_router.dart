import 'package:chewie/chewie.dart';
import 'package:go_router/go_router.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:my_tube/models/video_mt.dart';
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
              final extra = state.extra as Map<String, dynamic>;
              final video = extra['video'] as VideoMT?;
              final result = extra['result'] as SearchResult?;
              final streamUrl = extra['streamUrl'] as String;
              final vlcPlayerController =
                  extra['chewieController'] as ChewieController;

              return VideoPlayerPage(
                  video: video,
                  streamUrl: streamUrl,
                  chewieController: vlcPlayerController);
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

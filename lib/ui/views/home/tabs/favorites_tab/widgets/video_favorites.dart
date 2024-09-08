import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_video_bloc.dart';
import 'package:my_tube/ui/views/common/play_pause_gesture_detector.dart';
import 'package:my_tube/ui/views/common/video_menu_dialog.dart';
import 'package:my_tube/ui/views/common/video_tile.dart';
import 'package:my_tube/ui/views/home/tabs/favorites_tab/widgets/empty_favorites.dart';
import 'package:my_tube/ui/views/home/tabs/favorites_tab/widgets/favorites_header.dart';

class VideoFavorites extends StatelessWidget {
  const VideoFavorites({super.key, required this.searchQuery});

  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    context.read<FavoritesVideoBloc>().add(const GetFavorites());

    return BlocBuilder<FavoritesVideoBloc, FavoritesVideoState>(
        builder: (context, state) {
      switch (state.status) {
        case FavoritesStatus.loading:
          return const Center(child: CircularProgressIndicator());
        case FavoritesStatus.success:
          final favorites = state.resources!
              .where((video) {
                final title = video.title?.toLowerCase() ?? '';
                final channelTitle = video.channelTitle?.toLowerCase() ?? '';
                final query = searchQuery.toLowerCase();
                return title.contains(query) || channelTitle.contains(query);
              })
              .toList()
              .reversed
              .toList();

          return Column(
            children: [
              FavoritesHeader(
                title: 'Videos',
                favorites: favorites,
              ),
              Expanded(
                child: favorites.isNotEmpty
                    ? ListView.builder(
                        itemCount: favorites.length,
                        itemBuilder: (context, index) {
                          final video = favorites[index];
                          return PlayPauseGestureDetector(
                              resource: video,
                              child: VideoMenuDialog(
                                  video: video,
                                  child: VideoTile(video: video)));
                        },
                      )
                    : const EmptyFavorites(
                        message: 'No favorite videos yet',
                      ),
              ),
            ],
          );
        case FavoritesStatus.failure:
          return Center(child: Text(state.error!));
        default:
          return const SizedBox.shrink();
      }
    });
  }
}

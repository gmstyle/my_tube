import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_video_bloc.dart';
import 'package:my_tube/ui/skeletons/custom_skeletons.dart';
import 'package:my_tube/ui/views/common/video_menu_dialog.dart';
import 'package:my_tube/ui/views/common/video_tile.dart';
import 'package:my_tube/ui/views/home/tabs/favorites_tab/widgets/empty_favorites.dart';

class VideoFavorites extends StatelessWidget {
  const VideoFavorites({super.key, required this.searchQuery});

  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesVideoBloc, FavoritesVideoState>(
        builder: (context, state) {
      switch (state.status) {
        case FavoritesStatus.initial:
        case FavoritesStatus.loading:
          return const CustomSkeletonGridList();
        case FavoritesStatus.success:
          final favorites = state.videos!
              .where((video) {
                final title = video.title.toLowerCase();
                final channelTitle = video.artist?.toLowerCase() ?? '';
                final query = searchQuery.toLowerCase();
                return title.contains(query) || channelTitle.contains(query);
              })
              .toList()
              .reversed
              .toList();

          return favorites.isNotEmpty
              ? ListView.separated(
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final video = favorites[index];
                    final quickVideo = {
                      'id': video.id,
                      'title': video.title,
                    };
                    return VideoMenuDialog(
                        quickVideo: quickVideo, child: VideoTile(video: video));
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                )
              : const EmptyFavorites(
                  message: 'No favorite videos yet',
                );
        case FavoritesStatus.failure:
          return Center(child: Text(state.error!));
      }
    });
  }
}

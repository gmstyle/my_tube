import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_playlist/favorites_playlist_bloc.dart';
import 'package:my_tube/blocs/playlist_page/playlist_bloc.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/ui/skeletons/skeleton_playlist.dart';
import 'package:my_tube/ui/views/common/custom_appbar.dart';
import 'package:my_tube/ui/views/common/main_gradient.dart';
import 'package:my_tube/ui/views/common/play_pause_gesture_detector.dart';
import 'package:my_tube/ui/views/common/video_menu_dialog.dart';
import 'package:my_tube/ui/views/common/video_tile.dart';
import 'package:my_tube/ui/views/playlist/widgets/playlist_header.dart';

class PlaylistView extends StatelessWidget {
  const PlaylistView({super.key, required this.playlistId});

  final String playlistId;

  @override
  Widget build(BuildContext context) {
    return MainGradient(
      child: Scaffold(
        appBar: CustomAppbar(
          showTitle: false,
          actions: [
            BlocBuilder<PlaylistBloc, PlaylistState>(builder: (context, state) {
              if (state.status == PlaylistStatus.loaded) {
                final playlist = state.response;
                return BlocBuilder<FavoritesPlaylistBloc,
                    FavoritesPlaylistState>(builder: (context, state) {
                  final favoritesBloc = context.read<FavoritesPlaylistBloc>();
                  return IconButton(
                      color: Theme.of(context).colorScheme.onPrimary,
                      onPressed: () {
                        if (favoritesBloc.favoritesRepository.playlistIds
                            .contains(playlistId)) {
                          favoritesBloc
                              .add(RemoveFromFavoritesPlaylist(playlistId));
                        } else {
                          favoritesBloc.add(AddToFavoritesPlaylist(ResourceMT(
                              id: playlistId,
                              title: playlist!.title,
                              description: playlist.description,
                              channelTitle: null,
                              thumbnailUrl: playlist.thumbnailUrl,
                              kind: 'playlist',
                              channelId: playlist.channelId,
                              playlistId: playlistId,
                              videoCount: playlist.itemCount.toString(),
                              duration: null,
                              streamUrl: null)));
                        }
                      },
                      icon: favoritesBloc.favoritesRepository.playlistIds
                              .contains(playlistId)
                          ? const Icon(Icons.favorite)
                          : const Icon(Icons.favorite_border));
                });
              }

              return const SizedBox.shrink();
            })
          ],
        ),
        backgroundColor: Colors.transparent,
        body: BlocBuilder<PlaylistBloc, PlaylistState>(
          builder: ((context, state) {
            switch (state.status) {
              case PlaylistStatus.loading:
                return const SkeletonPlaylist();

              case PlaylistStatus.loaded:
                final playlist = state.response;
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      PlaylistHeader(playlist: playlist),
                      const SizedBox(height: 16),
                      ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: playlist?.videos!.length,
                          itemBuilder: (context, index) {
                            final video = playlist?.videos![index];
                            return PlayPauseGestureDetector(
                              resource: video!,
                              child: VideoMenuDialog(
                                  video: video, child: VideoTile(video: video)),
                            );
                          }),
                    ],
                  ),
                );

              case PlaylistStatus.failure:
                return Center(
                  child: Text(state.error!),
                );

              default:
                return const Center(child: CircularProgressIndicator());
            }
          }),
        ),
      ),
    );
  }
}

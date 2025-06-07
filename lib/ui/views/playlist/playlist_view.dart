import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_playlist/favorites_playlist_bloc.dart';
import 'package:my_tube/blocs/playlist_page/playlist_bloc.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/services/download_service.dart';
import 'package:my_tube/ui/skeletons/custom_skeletons.dart';
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
    final downloadService = context.read<DownloadService>();

    return MainGradient(
      child: Scaffold(
        appBar: CustomAppbar(
          showTitle: false,
          actions: [
            BlocBuilder<PlaylistBloc, PlaylistState>(builder: (context, state) {
              if (state.status == PlaylistStatus.loaded) {
                final playlist = state.response;
                return Wrap(
                  children: [
                    IconButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // show the option to download the video
                                      ListTile(
                                        leading: const Icon(Icons.download),
                                        title: const Text('Download'),
                                        onTap: () {
                                          downloadService.download(
                                              videos: playlist!.videos!,
                                              destinationDir: playlist.title,
                                              context: context);
                                          Navigator.of(context).pop();
                                        },
                                      ),

                                      // show the option to download the audio only
                                      ListTile(
                                        leading: const Icon(Icons.music_note),
                                        title:
                                            const Text('Download audio only'),
                                        onTap: () {
                                          downloadService.download(
                                              videos: playlist!.videos!,
                                              destinationDir: playlist.title,
                                              context: context,
                                              isAudioOnly: true);
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              });
                        },
                        icon: const Icon(Icons.download)),
                    BlocBuilder<FavoritesPlaylistBloc, FavoritesPlaylistState>(
                        builder: (context, state) {
                      final favoritesPlaylistBloc =
                          context.read<FavoritesPlaylistBloc>();
                      return IconButton(
                          color: Theme.of(context).colorScheme.onPrimary,
                          onPressed: () {
                            if (favoritesPlaylistBloc
                                .favoritesRepository.playlistIds
                                .contains(playlistId)) {
                              favoritesPlaylistBloc
                                  .add(RemoveFromFavoritesPlaylist(playlistId));
                            } else {
                              favoritesPlaylistBloc.add(AddToFavoritesPlaylist(
                                  ResourceMT(
                                      id: playlistId,
                                      title: playlist!.title,
                                      description: playlist.description,
                                      channelTitle: null,
                                      thumbnailUrl: playlist.thumbnailUrl,
                                      base64Thumbnail: playlist.base64Thumbnail,
                                      kind: 'playlist',
                                      channelId: playlist.channelId,
                                      playlistId: playlistId,
                                      videoCount: playlist.itemCount.toString(),
                                      duration: null,
                                      streamUrl: null)));
                            }
                          },
                          icon: favoritesPlaylistBloc
                                  .favoritesRepository.playlistIds
                                  .contains(playlistId)
                              ? const Icon(Icons.favorite)
                              : const Icon(Icons.favorite_border));
                    }),
                  ],
                );
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
                return const CustomSkeletonPlaylist();

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

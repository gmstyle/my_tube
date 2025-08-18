import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_playlist/favorites_playlist_bloc.dart';
import 'package:my_tube/blocs/playlist_page/playlist_bloc.dart';
import 'package:my_tube/services/download_service.dart';
import 'package:my_tube/ui/skeletons/custom_skeletons.dart';
import 'package:my_tube/ui/views/common/custom_appbar.dart';
import 'package:my_tube/ui/views/common/main_gradient.dart';
import 'package:my_tube/ui/views/common/play_pause_gesture_detector.dart';
import 'package:my_tube/ui/views/common/video_menu_dialog.dart';
import 'package:my_tube/ui/views/common/video_tile.dart';
import 'package:my_tube/ui/views/playlist/widgets/playlist_header.dart';
import 'package:my_tube/models/tiles.dart' as models;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

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
                final playlist = state.response!['playlist'] as Playlist;
                final videos =
                    state.response!['videos'] as List<models.VideoTile>;
                final quickVideos = videos.map<Map<String, String>>((video) {
                  return {
                    'id': video.id,
                    'title': video.title,
                  };
                }).toList();
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
                                              videos: quickVideos,
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
                                              videos: quickVideos,
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
                              favoritesPlaylistBloc
                                  .add(AddToFavoritesPlaylist(playlistId));
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
                final playlist = state.response!['playlist'] as Playlist;
                final videos =
                    state.response!['videos'] as List<models.VideoTile>;
                final videoIds = videos.map((video) => video.id).toList();
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      PlaylistHeader(playlist: playlist, videoIds: videoIds),
                      const SizedBox(height: 16),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: videos.length,
                        itemBuilder: (context, index) {
                          final video = videos[index];
                          final quickVideo = {
                            'id': video.id,
                            'title': video.title
                          };
                          return PlayPauseGestureDetector(
                            id: video.id,
                            child: VideoMenuDialog(
                                quickVideo: quickVideo,
                                child: VideoTile(video: video)),
                          );
                        },
                        separatorBuilder: (context, index) => const SizedBox(
                          height: 8,
                        ),
                      ),
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

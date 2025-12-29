import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';
import 'package:my_tube/blocs/playlist_page/playlist_bloc.dart';
import 'package:my_tube/utils/utils.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class PlaylistHeader extends StatelessWidget {
  const PlaylistHeader({
    super.key,
    required this.playlist,
    required this.videoIds,
  });

  final Playlist playlist;
  final List<String> videoIds;

  @override
  Widget build(BuildContext context) {
    final miniplayerCubit = context.read<PlayerCubit>();
    final playlistState = context.watch<PlaylistBloc>().state;
    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;

    final double screenWidth = MediaQuery.of(context).size.width;
    final double size = screenWidth * 0.6;
    final double minSize = 200.0; // Dimensione minima per smartphone
    final double maxSize = 400.0; // Dimensione massima per tablet

    final double imageSize = size.clamp(minSize, maxSize);

    return Column(
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.end,
          runSpacing: 8,
          children: [
            FloatingActionButton.small(
                elevation: 0,
                heroTag: "add_playlist_to_queue_${playlist.id}",
                onPressed: () {
                  miniplayerCubit.addAllToQueue(videoIds);
                },
                child: const Icon(Icons.queue_music)),
            const SizedBox(width: 8),
            SizedBox(
              height: isLandscape
                  ? MediaQuery.of(context).size.height * 0.5
                  : imageSize,
              width: imageSize,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Utils.buildImageWithFallback(
                        thumbnailUrl: playlist.thumbnails.highResUrl,
                        context: context,
                        fit: BoxFit.cover),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 8,
                      right: 8,
                      bottom: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Text(
                                  playlist.title,
                                  maxLines: 2,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        color: Colors.white,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.music_note_rounded,
                                color: Colors.white,
                              ),
                              Text(
                                playlist.videoCount.toString(),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.white,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            FloatingActionButton.small(
                elevation: 0,
                heroTag: "play_playlist_${playlist.id}",
                onPressed: playlistState.status == PlaylistStatus.loaded
                    ? () {
                        miniplayerCubit.startPlayingPlaylist(videoIds);
                      }
                    : null,
                child: const Icon(Icons.playlist_play)),
          ],
        ),
      ],
    );
  }
}

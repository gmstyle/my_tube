import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';
import 'package:my_tube/blocs/playlist_page/playlist_bloc.dart';
import 'package:my_tube/models/playlist_mt.dart';
import 'package:my_tube/ui/views/common/expandable_text.dart';

class PlaylistHeader extends StatelessWidget {
  const PlaylistHeader({
    super.key,
    required this.playlist,
  });

  final PlaylistMT? playlist;

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
                heroTag: "add_playlist_to_queue_${playlist!.id}",
                backgroundColor: Theme.of(context).colorScheme.onPrimary,
                onPressed: () {
                  miniplayerCubit.addAllToQueue(playlist!.videos!);
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
                    playlist?.thumbnailUrl != null
                        ? CachedNetworkImage(
                            imageUrl: playlist!.thumbnailUrl!,
                            height: imageSize,
                            width: imageSize,
                            fit: BoxFit.cover,
                          )
                        : const SizedBox(),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.8),
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
                                  playlist?.title ?? '',
                                  maxLines: 2,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.music_note_rounded,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                              Text(
                                playlist!.itemCount ?? '',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
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
                heroTag: "play_playlist_${playlist!.id}",
                backgroundColor: Theme.of(context).colorScheme.onPrimary,
                onPressed: playlistState.status == PlaylistStatus.loaded
                    ? () {
                        miniplayerCubit.startPlayingPlaylist(playlist!.videos!);
                      }
                    : null,
                child: const Icon(Icons.playlist_play)),
          ],
        ),
        if (playlist!.description != null) ...[
          const SizedBox(height: 8),
          ExpandableText(
              title: 'Description', text: playlist!.description ?? '')
        ],
      ],
    );
  }
}

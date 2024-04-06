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
    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.25,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                    imageUrl: playlist?.thumbnailUrl ?? '',
                    height: MediaQuery.of(context).size.height * 0.2,
                    width: MediaQuery.of(context).size.width * 0.8,
                    fit: BoxFit.fill,
                    errorWidget: (context, url, error) => const FlutterLogo()),
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
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
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
                            ' Tracks: ${playlist!.itemCount}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                    right: 16,
                    bottom: 16,
                    child: Row(
                      children: [
                        FloatingActionButton.small(
                            heroTag: "add_playlist_to_queue_${playlist!.id}",
                            backgroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                            onPressed: () {
                              miniplayerCubit.addAllToQueue(playlist!.videos!);
                            },
                            child: const Icon(Icons.queue_music)),
                        FloatingActionButton.small(
                            heroTag: "play_playlist_${playlist!.id}",
                            backgroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                            onPressed:
                                playlistState.status == PlaylistStatus.loaded
                                    ? () {
                                        miniplayerCubit.startPlayingPlaylist(
                                            playlist!.videos!);
                                      }
                                    : null,
                            child: const Icon(Icons.playlist_play)),
                      ],
                    ))
              ],
            ),
          ),
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

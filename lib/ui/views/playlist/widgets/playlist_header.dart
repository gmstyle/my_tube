import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/mini_player_cubit/mini_player_cubit.dart';
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
    final miniplayerCubit = context.read<MiniPlayerCubit>();
    final playlistState = context.watch<PlaylistBloc>().state;
    return Column(
      children: [
        /*  Row(
          children: [
            IconButton(
              onPressed: () {
                context.pop();
              },
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_vert, color: Colors.white),
            ),
          ],
        ), */
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.25,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(playlist?.thumbnailUrl ?? '',
                    height: MediaQuery.of(context).size.height * 0.2,
                    width: MediaQuery.of(context).size.width * 0.8,
                    fit: BoxFit.cover),
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
                            ' Tracks: ${playlist!.itemCount}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.white,
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
                    child: FloatingActionButton.small(
                        backgroundColor: Colors.white,
                        onPressed: playlistState.status == PlaylistStatus.loaded
                            ? () {
                                miniplayerCubit
                                    .startPlayingPlaylist(playlist!.videos!);
                              }
                            : null,
                        child: const Icon(Icons.playlist_play)))
              ],
            ),
          ),
        ),
        if (playlist!.description != null) ...[
          const SizedBox(height: 8),
          ExpandableText(text: playlist!.description ?? '')
        ],
      ],
    );
  }
}

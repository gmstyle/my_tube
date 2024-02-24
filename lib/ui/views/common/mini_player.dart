import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';
import 'package:my_tube/router/app_router.dart';
import 'package:my_tube/ui/skeletons/skeleton_mini_player.dart';
import 'package:my_tube/ui/views/common/horizontal_swipe_to_skip.dart';
import 'package:my_tube/ui/views/common/seek_bar.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final PlayerCubit playerCubit = context.read<PlayerCubit>();

    return BlocBuilder<PlayerCubit, PlayerState>(
      builder: (context, state) {
        if (state.status == PlayerStatus.loading) {
          return const SkeletonMiniPlayer();
        }
        if (state.status == PlayerStatus.hidden) {
          return const SizedBox.shrink();
        }

        if (state.status == PlayerStatus.error) {
          return ClipRRect(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10)),
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              height: 80,
              child: Center(
                child: Text(state.message!),
              ),
            ),
          );
        }

        return GestureDetector(
          onTap: () => context.pushNamed(AppRoute.video.name),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10)),
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              height: 80,
              child: HorizontalSwipeToSkip(
                child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Row(
                      children: [
                        // Image
                        StreamBuilder(
                            stream: playerCubit.mtPlayerService.mediaItem,
                            builder: (context, snapshot) {
                              final mediaItem = snapshot.data;
                              return Hero(
                                tag: 'video_image_or_player',
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: mediaItem?.artUri != null
                                      ? CachedNetworkImage(
                                          height: 80,
                                          width: 80,
                                          fit: BoxFit.cover,
                                          imageUrl:
                                              mediaItem!.artUri.toString(),
                                        )
                                      : const SizedBox(
                                          height: 80,
                                          width: 80,
                                        ),
                                ),
                              );
                            }),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Wrap(
                            children: [
                              // Video Title and Album
                              StreamBuilder(
                                  stream: playerCubit.mtPlayerService.mediaItem,
                                  builder: (context, snapshot) {
                                    final mediaItem = snapshot.data;
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Hero(
                                          tag: 'video_title',
                                          child: Text(
                                            mediaItem?.title ?? '',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Hero(
                                          tag: 'video_album',
                                          child: Text(
                                            mediaItem?.album ?? '',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                              const SizedBox(height: 4),
                              // SeekBar
                              const SeekBar(
                                darkBackground: false,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Play/Pause Button
                        StreamBuilder(
                            stream: playerCubit.mtPlayerService.playbackState
                                .map((playbackState) => playbackState.playing)
                                .distinct(),
                            builder: (context, snapshot) {
                              final isPlaying = snapshot.data ?? false;
                              return Hero(
                                tag: 'play_pause_button',
                                child: IconButton(
                                    iconSize:
                                        MediaQuery.of(context).size.width * 0.1,
                                    onPressed: () {
                                      if (isPlaying) {
                                        playerCubit.mtPlayerService.pause();
                                      } else {
                                        playerCubit.mtPlayerService.play();
                                      }
                                    },
                                    icon: Icon(
                                      isPlaying
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                    )),
                              );
                            }),
                      ],
                    )),
              ),
            ),
          ),
        );
      },
    );
  }
}

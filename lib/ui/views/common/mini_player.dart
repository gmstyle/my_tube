import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';
import 'package:my_tube/router/app_router.dart';
import 'package:my_tube/services/mt_player_service.dart';
import 'package:my_tube/ui/skeletons/custom_skeletons.dart';
import 'package:my_tube/ui/views/common/horizontal_swipe_to_skip.dart';
import 'package:my_tube/ui/views/common/seek_bar.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({
    super.key,
  });

  double _setAspectRatio(MtPlayerService mtPlayerService) {
    final chewie = mtPlayerService.chewieController;
    if (chewie == null) return 1;
    final vpc = chewie.videoPlayerController;
    try {
      final ratio = vpc.value.aspectRatio;
      return ratio <= 1 ? 1 : ratio;
    } catch (_) {
      return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final PlayerCubit playerCubit = context.read<PlayerCubit>();

    return BlocBuilder<PlayerCubit, PlayerState>(
      builder: (context, state) {
        if (state.status == PlayerStatus.loading &&
            state.loadingOperation != LoadingOperation.addToQueue) {
          // Usa skeleton con overlay di progresso quando disponibile
          if (state.loadingProgress != null && state.loadingTotal != null) {
            return Stack(
              children: [
                const CustomSkeletonMiniPlayer(),
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16)),
                    child: Container(
                      color: Theme.of(context)
                          .colorScheme
                          .surface
                          .withValues(alpha: 0.85),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${state.loadingProgress}/${state.loadingTotal}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value:
                                  state.loadingProgress! / state.loadingTotal!,
                              minHeight: 4,
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
          // Skeleton semplice per loading senza progresso
          return const CustomSkeletonMiniPlayer();
        }
        if (state.status == PlayerStatus.hidden) {
          return const SizedBox.shrink();
        }

        if (state.status == PlayerStatus.error) {
          return ClipRRect(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            child: Container(
              color: Theme.of(context).colorScheme.surfaceContainer,
              child: Center(
                child: Text(state.message!),
              ),
            ),
          );
        }

        return GestureDetector(
            onTap: () => AppRouter.router.pushNamed(AppRoute.video.name),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16), topRight: Radius.circular(16)),
              child: Container(
                color: Theme.of(context).colorScheme.surfaceContainer,
                child: HorizontalSwipeToSkip(
                  child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      child: Wrap(
                        children: [
                          Row(
                            spacing: 4,
                            children: [
                              // Video
                              Expanded(
                                child: StreamBuilder(
                                  stream: playerCubit.mtPlayerService.mediaItem,
                                  builder: (context, snapshot) {
                                    return Hero(
                                      tag: 'video_image_or_player',
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: AspectRatio(
                                            aspectRatio: _setAspectRatio(
                                                playerCubit.mtPlayerService),
                                            child: Builder(builder: (context) {
                                              final chewie = playerCubit
                                                  .mtPlayerService
                                                  .chewieController;
                                              if (chewie == null) {
                                                // fallback small placeholder if controller not ready
                                                return Container(
                                                  color: Colors.black,
                                                  child:
                                                      const SizedBox.shrink(),
                                                );
                                              }
                                              return Chewie(
                                                  controller: chewie.copyWith(
                                                showControls: false,
                                              ));
                                            })),
                                      ),
                                    );
                                  },
                                ),
                              ),

                              Expanded(
                                flex: 3,
                                child: Wrap(
                                  children: [
                                    // Video Title and Album
                                    StreamBuilder(
                                        stream: playerCubit
                                            .mtPlayerService.mediaItem,
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
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }),
                                  ],
                                ),
                              ),
                              // Play/Pause Button
                              StreamBuilder(
                                  stream: playerCubit
                                      .mtPlayerService.playbackState
                                      .map((playbackState) =>
                                          playbackState.playing)
                                      .distinct(),
                                  builder: (context, snapshot) {
                                    final isPlaying = snapshot.data ?? false;
                                    return Hero(
                                      tag: 'play_pause_button',
                                      child: IconButton.filled(
                                          onPressed: () {
                                            if (isPlaying) {
                                              playerCubit.mtPlayerService
                                                  .pause();
                                            } else {
                                              playerCubit.mtPlayerService
                                                  .play();
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
                          ),
                          // SeekBar
                          const SeekBar(
                            darkBackground: false,
                            thumbShapeRadius: 2,
                            overlayRadius: 2,
                          ),
                        ],
                      )),
                ),
              ),
            ));
      },
    );
  }
}

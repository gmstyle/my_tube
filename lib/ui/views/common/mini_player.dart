import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/blocs/home/mini_player_cubit/mini_player_cubit.dart';
import 'package:my_tube/router/app_router.dart';
import 'package:my_tube/ui/views/common/seek_bar.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final MiniPlayerCubit miniPlayerCubit = context.read<MiniPlayerCubit>();

    return BlocBuilder<MiniPlayerCubit, MiniPlayerState>(
      builder: (context, state) {
        if (state.status == MiniPlayerStatus.loading ||
            state.status == MiniPlayerStatus.hidden) {
          //TODO: shimmer
          return const SizedBox.shrink();
        }
        return GestureDetector(
          onTap: () => context.pushNamed(AppRoute.video.name),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10)),
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Dismissible(
                confirmDismiss: (direction) async {
                  // skip to previous or next song
                  if (direction == DismissDirection.startToEnd) {
                    await miniPlayerCubit.skipToPrevious();
                  } else {
                    await miniPlayerCubit.skipToNext();
                  }
                  return Future.value(false);
                },
                key:
                    Key(miniPlayerCubit.mtPlayerHandler.currentTrack?.id ?? ''),
                child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Row(
                      children: [
                        // Image
                        StreamBuilder(
                            stream: miniPlayerCubit.mtPlayerHandler.mediaItem,
                            builder: (context, snapshot) {
                              final mediaItem = snapshot.data;
                              return Hero(
                                tag: 'video_image_or_player',
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: mediaItem?.artUri != null
                                      ? Image.network(
                                          height: 80,
                                          width: 80,
                                          fit: BoxFit.cover,
                                          mediaItem!.artUri.toString(),
                                        )
                                      : const SizedBox(
                                          height: 80,
                                          width: 80,
                                          child: FlutterLogo()),
                                ),
                              );
                            }),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Video Title and Album
                              StreamBuilder(
                                  stream:
                                      miniPlayerCubit.mtPlayerHandler.mediaItem,
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
                            stream: miniPlayerCubit
                                .mtPlayerHandler.playbackState
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
                                        miniPlayerCubit.mtPlayerHandler.pause();
                                      } else {
                                        miniPlayerCubit.mtPlayerHandler.play();
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
    ); /* ClipRRect(
      borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10), topRight: Radius.circular(10)),
      child: GestureDetector(
        onTap: () => {
          showBottomSheet(
              context: context,
              builder: (context) {
                return const SongView();
              })
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            StreamBuilder(
                stream: miniPlayerCubit.mtPlayerHandler.mediaItem,
                builder: (context, snapshot) {
                  final mediaItem = snapshot.data;
                  return mediaItem?.artUri != null
                      ? Image.network(
                          fit: BoxFit.fitWidth,
                          mediaItem!.artUri.toString(),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: const FlutterLogo(),
                        );
                }),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.9),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // Video Info
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    // Video Title and Album
                    Expanded(
                      child: StreamBuilder(
                          stream: miniPlayerCubit.mtPlayerHandler.mediaItem,
                          builder: (context, snapshot) {
                            final mediaItem = snapshot.data;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  mediaItem?.title ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  mediaItem?.album ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            );
                          }),
                    ),

                    // skip previous button
                    StreamBuilder(
                        stream: miniPlayerCubit.mtPlayerHandler.queue,
                        builder: ((context, snapshot) {
                          final queue = snapshot.data ?? [];
                          final index = queue.indexOf(
                              miniPlayerCubit.mtPlayerHandler.currentTrack);
                          return IconButton(
                            icon: Icon(
                              Icons.skip_previous,
                              color: index > 0 ? Colors.white : Colors.grey,
                            ),
                            onPressed: index > 0
                                ? () async {
                                    await miniPlayerCubit.skipToPrevious();
                                  }
                                : null,
                          );
                        })),

                    // Play/Pause Button
                    StreamBuilder(
                        stream: miniPlayerCubit.mtPlayerHandler.playbackState
                            .map((playbackState) => playbackState.playing)
                            .distinct(),
                        builder: (context, snapshot) {
                          final isPlaying = snapshot.data ?? false;
                          return IconButton(
                              iconSize: MediaQuery.of(context).size.width * 0.1,
                              onPressed: () {
                                if (isPlaying) {
                                  miniPlayerCubit.mtPlayerHandler.pause();
                                } else {
                                  miniPlayerCubit.mtPlayerHandler.play();
                                }
                              },
                              icon: Icon(
                                isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                              ));
                        }),

                    // skip next button
                    StreamBuilder(
                        stream: miniPlayerCubit.mtPlayerHandler.queue,
                        builder: ((context, snapshot) {
                          final queue = snapshot.data ?? [];
                          final index = queue.indexOf(
                              miniPlayerCubit.mtPlayerHandler.currentTrack);
                          final hasNext = index < queue.length - 1;
                          return IconButton(
                            icon: Icon(
                              Icons.skip_next,
                              color: hasNext ? Colors.white : Colors.grey,
                            ),
                            onPressed: hasNext
                                ? () async {
                                    await miniPlayerCubit.skipToNext();
                                  }
                                : null,
                          );
                        })),
                  ],
                ),
              ),
            ),

            // SeekBar
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SeekBar(
                darkBackground: true,
              ),
            ),
          ],
        ),
      ),
    ); */
  }
}

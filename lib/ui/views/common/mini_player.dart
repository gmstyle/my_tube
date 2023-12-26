import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/mini_player_cubit/mini_player_cubit.dart';
import 'package:my_tube/ui/views/common/seek_bar.dart';
import 'package:my_tube/ui/views/song_view/song_view.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final MiniPlayerCubit miniPlayerCubit = context.read<MiniPlayerCubit>();
    return ClipRRect(
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
    );
    /* return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Expanded(
                    child: GestureDetector(
                  child: Row(
                    children: [
                      /// SzedBox con width 0 per far partire il video
                      /// senza che si veda il video in modalità mini player
                      SizedBox(
                          width: 0,
                          child: Chewie(
                            controller: mtPlayerHandler.chewieController,
                          )),

                      // Thumbnail
                      StreamBuilder(
                          stream: mtPlayerHandler.mediaItem,
                          builder: (context, snapshot) {
                            final mediaItem = snapshot.data;
                            return mediaItem?.artUri != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      mediaItem!.artUri.toString(),
                                    ),
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: const FlutterLogo(),
                                  );
                          }),

                      const SizedBox(
                        width: 8,
                      ),

                      // Title
                      StreamBuilder(
                          stream: mtPlayerHandler.mediaItem,
                          builder: (context, snapshot) {
                            final mediaItem = snapshot.data;
                            return Expanded(
                              flex: 2,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          mediaItem?.title ?? '',
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 2,
                                  ),
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          mediaItem?.album ?? '',
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          })
                    ],
                  ),
                  onTap: () {
                    context.pushNamed(AppRoute.song.name);
                  },
                )),
              ],
            ),
          ),

          // Controls
          Row(
            children: [
              // Progress bar
              const Flexible(child: SeekBar()),
              //
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                // skip previous button
                StreamBuilder(
                    stream: mtPlayerHandler.queue,
                    builder: ((context, snapshot) {
                      final queue = snapshot.data ?? [];
                      final index = queue.indexOf(mtPlayerHandler.currentTrack);
                      return IconButton(
                        icon: const Icon(
                          Icons.skip_previous,
                        ),
                        onPressed: index > 0
                            ? () async {
                                await mtPlayerHandler.skipToPrevious();
                              }
                            : null,
                      );
                    })),

                //Play/pause button
                StreamBuilder(
                    stream: mtPlayerHandler.playbackState
                        .map((playbackState) => playbackState.playing)
                        .distinct(),
                    builder: (context, snapshot) {
                      final isPlaying = snapshot.data ?? false;
                      return IconButton(
                          iconSize: MediaQuery.of(context).size.width * 0.1,
                          onPressed: () {
                            if (isPlaying) {
                              mtPlayerHandler.pause();
                            } else {
                              mtPlayerHandler.play();
                            }
                          },
                          icon:
                              Icon(isPlaying ? Icons.pause : Icons.play_arrow));
                    }),

                //Stop button
                /*  IconButton(
                    onPressed: () {
                      miniPlayerCubit.mtPlayerHandler.stop();
                    },
                    icon: const Icon(Icons.stop)),
 */
                // skip next button
                StreamBuilder(
                    stream: mtPlayerHandler.queue,
                    builder: ((context, snapshot) {
                      final queue = snapshot.data ?? [];
                      final index = queue.indexOf(mtPlayerHandler.currentTrack);
                      return IconButton(
                        icon: const Icon(
                          Icons.skip_next,
                        ),
                        onPressed: index < queue.length - 1
                            ? () async {
                                await mtPlayerHandler.skipToNext();
                              }
                            : null,
                      );
                    })),
              ]),
            ],
          ),
        ],
      ),
    ); */
  }
}

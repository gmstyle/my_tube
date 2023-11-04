import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/blocs/home/mini_player_cubit/mini_player_cubit.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/router/app_router.dart';
import 'package:my_tube/services/mt_player_handler.dart';
import 'package:my_tube/ui/views/common/seek_bar.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({
    super.key,
    required this.video,
  });

  final ResourceMT? video;

  @override
  Widget build(BuildContext context) {
    final MiniPlayerCubit miniPlayerCubit = context.read<MiniPlayerCubit>();
    final MtPlayerHandler mtPlayerHandler = context.read<MtPlayerHandler>();
    return Padding(
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
                                ? Expanded(
                                    child: Image.network(
                                      mediaItem!.artUri.toString(),
                                    ),
                                  )
                                : const Expanded(
                                    child: SizedBox(
                                      child: FlutterLogo(),
                                    ),
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
                //Play/pause button
                StreamBuilder(
                    stream: mtPlayerHandler.playbackState
                        .map((playbackState) => playbackState.playing)
                        .distinct(),
                    builder: (context, snapshot) {
                      final isPlaying = snapshot.data ?? false;
                      return IconButton(
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

                //Close button
                IconButton(
                    onPressed: () {
                      miniPlayerCubit.mtPlayerHandler.stop();
                    },
                    icon: const Icon(Icons.stop)),

                // button
                /* IconButton(
                    onPressed: () {
                      context.pushNamed(AppRoute.song.name);
                    },
                    icon: const Icon(Icons.expand_less)), */
              ]),
            ],
          ),
        ],
      ),
    );
  }
}

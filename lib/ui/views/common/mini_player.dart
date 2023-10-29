import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/mini_player_cubit/mini_player_cubit.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/services/mt_player_handler.dart';
import 'package:my_tube/ui/views/common/video_player_bottom_sheet.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer(
      {super.key, required this.video, required this.mtPlayerHandler});

  final ResourceMT? video;

  final MtPlayerHandler mtPlayerHandler;

  @override
  Widget build(BuildContext context) {
    final MiniPlayerCubit miniPlayerCubit = context.read<MiniPlayerCubit>();
    return Padding(
      padding: const EdgeInsets.all(8.0),
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
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
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
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
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
              showVideoPlayerBottomSheet(context);
            },
          )),
          const SizedBox(
            width: 8,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            //Play/pause button
            StreamBuilder(
                stream: miniPlayerCubit.mtPlayerHandler.playbackState
                    .map((playbackState) => playbackState.playing)
                    .distinct(),
                builder: (context, snapshot) {
                  final isPlaying = snapshot.data ?? false;
                  return IconButton(
                      onPressed: () {
                        if (isPlaying) {
                          miniPlayerCubit.pauseMiniPlayer();
                        } else {
                          miniPlayerCubit.playMiniPlayer();
                        }
                      },
                      icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow));
                }),

            //Close button
            IconButton(
                onPressed: () {
                  miniPlayerCubit.hideMiniPlayer();
                },
                icon: const Icon(Icons.stop)),

            // button
            IconButton(
                onPressed: () {
                  showVideoPlayerBottomSheet(context);
                },
                icon: const Icon(Icons.expand_less)),
          ]),
        ],
      ),
    );
  }

  void showVideoPlayerBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (context) => VideoPlayerBottomSheet(
              video: video,
              mtPlayerHandler: mtPlayerHandler,
            ));
  }
}

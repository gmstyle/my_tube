import 'package:audio_service/audio_service.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:my_tube/blocs/home/mini_player_cubit/mini_player_cubit.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/services/mt_player_handler.dart';
import 'package:my_tube/ui/views/common/custom_appbar.dart';
import 'package:my_tube/ui/views/common/seek_bar.dart';

class SongView extends StatelessWidget {
  const SongView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final mtPlayerHandler = context.read<MtPlayerHandler>();
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const CustomAppbar(),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              AspectRatio(
                  aspectRatio: mtPlayerHandler
                      .chewieController.videoPlayerController.value.aspectRatio,
                  child: Chewie(controller: mtPlayerHandler.chewieController)),
              const SizedBox(
                height: 8,
              ),
              StreamBuilder(
                  stream: mtPlayerHandler.mediaItem,
                  builder: (context, snapshot) {
                    final mediaItem = snapshot.data;
                    return Row(
                      children: [
                        Flexible(
                          child: Text(
                            mediaItem?.title ?? '',
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
                    );
                  }),
              const SizedBox(
                height: 8,
              ),

              // Seek bar
              const SeekBar(
                darkBackground: true,
              ),
              // controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // TODO: Previous
                  StreamBuilder(
                      stream: mtPlayerHandler.queue,
                      builder: ((context, snapshot) {
                        final queue = snapshot.data ?? [];
                        final index =
                            queue.indexOf(mtPlayerHandler.mediaItem.value!);
                        return IconButton(
                          icon: const Icon(
                            Icons.skip_previous,
                            color: Colors.white,
                          ),
                          onPressed: index > 0
                              ? () {
                                  mtPlayerHandler.skipToPrevious();
                                }
                              : null,
                        );
                      })),

                  // Play/Pause
                  StreamBuilder(
                      stream: mtPlayerHandler.playbackState
                          .map((state) => state.playing)
                          .distinct(),
                      builder: (context, snapshot) {
                        final playing = snapshot.data ?? false;
                        return IconButton(
                          iconSize: MediaQuery.of(context).size.width * 0.15,
                          icon: Icon(
                            playing ? Icons.pause_circle : Icons.play_circle,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            if (playing) {
                              mtPlayerHandler.pause();
                            } else {
                              mtPlayerHandler.play();
                            }
                          },
                        );
                      }),

                  // TODO: Next
                  StreamBuilder(
                      stream: mtPlayerHandler.queue,
                      builder: ((context, snapshot) {
                        final queue = snapshot.data ?? [];
                        final index =
                            queue.indexOf(mtPlayerHandler.mediaItem.value!);
                        return IconButton(
                          icon: const Icon(
                            Icons.skip_next,
                            color: Colors.white,
                          ),
                          onPressed: index < queue.length - 1
                              ? () {
                                  mtPlayerHandler.skipToNext();
                                }
                              : null,
                        );
                      })),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

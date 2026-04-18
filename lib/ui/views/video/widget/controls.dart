import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/services/player/mt_player_service.dart';

class Controls extends StatelessWidget {
  const Controls({super.key});

  @override
  Widget build(BuildContext context) {
    final mtPlayerService = context.read<MtPlayerService>();
    return LayoutBuilder(
      builder: (context, constraints) {
        // Derive icon size from the available width, capped to avoid
        // overflow in constrained containers (e.g. queue_view SliverAppBar).
        final iconSize = (constraints.maxWidth * 0.15).clamp(48.0, 72.0);
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Shuffle
            StreamBuilder(
                stream: mtPlayerService.playbackState
                    .map((state) =>
                        state.shuffleMode == AudioServiceShuffleMode.all)
                    .distinct(),
                builder: (context, snapshot) {
                  final shuffleEnabled = snapshot.data ?? false;
                  return IconButton(
                    icon: Icon(
                      Icons.shuffle,
                      color: shuffleEnabled
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5),
                    ),
                    onPressed: () async {
                      await mtPlayerService.setShuffleMode(shuffleEnabled
                          ? AudioServiceShuffleMode.none
                          : AudioServiceShuffleMode.all);
                    },
                  );
                }),
            /*  // seek backward
          IconButton(
            icon: Icon(
              Icons.replay_10,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            onPressed: () async {
              await mtPlayerService.seek(
                  mtPlayerService.videoPlayerController.value.position -
                      const Duration(seconds: 10));
            },
          ), */

            // Skip previous
            StreamBuilder(
                stream: mtPlayerService.queue,
                builder: ((context, snapshot) {
                  final queue = snapshot.data ?? [];
                  final currentMediaItem = mtPlayerService.mediaItem.value;
                  final index = currentMediaItem != null
                      ? queue.indexOf(currentMediaItem)
                      : -1;
                  bool isEnabled = index > 0;
                  return IconButton(
                    icon: Icon(
                      Icons.skip_previous,
                      color: isEnabled
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5),
                    ),
                    onPressed: isEnabled
                        ? () async {
                            await mtPlayerService.skipToPrevious();
                          }
                        : null,
                  );
                })),

            // Play/Pause
            StreamBuilder(
                stream: mtPlayerService.playbackState
                    .map((state) => state.playing)
                    .distinct(),
                builder: (context, snapshot) {
                  final playing = snapshot.data ?? false;
                  return Hero(
                    tag: 'play_pause_button',
                    child: IconButton(
                      iconSize: iconSize,
                      icon: Icon(
                        playing ? Icons.pause_circle : Icons.play_circle,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () {
                        if (playing) {
                          mtPlayerService.pause();
                        } else {
                          mtPlayerService.play();
                        }
                      },
                    ),
                  );
                }),

            // Skip next
            StreamBuilder(
                stream: mtPlayerService.queue,
                builder: ((context, snapshot) {
                  final queue = snapshot.data ?? [];
                  final currentMediaItem = mtPlayerService.mediaItem.value;
                  final index = currentMediaItem != null
                      ? queue.indexOf(currentMediaItem)
                      : -1;
                  bool isEnable = index >= 0 && index < queue.length - 1;
                  return IconButton(
                    icon: Icon(
                      Icons.skip_next,
                      color: isEnable
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5),
                    ),
                    onPressed: isEnable
                        ? () async {
                            await mtPlayerService.skipToNext();
                          }
                        : null,
                  );
                })),

            /* // seek forward
          IconButton(
            icon: Icon(
              Icons.forward_10,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            onPressed: () async {
              await mtPlayerService.seek(
                  mtPlayerService.videoPlayerController.value.position +
                      const Duration(seconds: 10));
            },
          ), */
            // repeat
            StreamBuilder(
                stream: mtPlayerService.playbackState
                    .map((state) => state.repeatMode)
                    .distinct(),
                builder: (context, snapshot) {
                  final repeatMode =
                      snapshot.data ?? AudioServiceRepeatMode.none;
                  final icons = [
                    Icon(Icons.repeat,
                        color: Theme.of(context).colorScheme.primary),
                    Icon(Icons.repeat_one,
                        color: Theme.of(context).colorScheme.primary),
                    Icon(Icons.repeat,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5)),
                  ];
                  const cycleModes = [
                    AudioServiceRepeatMode.all,
                    AudioServiceRepeatMode.one,
                    AudioServiceRepeatMode.none,
                  ];
                  final index = cycleModes.indexOf(repeatMode);
                  return IconButton(
                    icon: icons[index],
                    onPressed: () {
                      var cycleMode =
                          cycleModes[(index + 1) % cycleModes.length];
                      mtPlayerService.setRepeatMode(cycleMode);
                    },
                  );
                }),
          ],
        );
      },
    );
  }
}

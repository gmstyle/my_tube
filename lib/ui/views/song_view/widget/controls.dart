import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:my_tube/services/mt_player_handler.dart';

class Controls extends StatelessWidget {
  const Controls({super.key, required this.mtPlayerHandler});

  final MtPlayerHandler mtPlayerHandler;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Shuffle
        IconButton(
          icon: Icon(
            Icons.shuffle,
            color: mtPlayerHandler.shuffleEnabled
                ? Theme.of(context).colorScheme.onPrimary
                : Colors.white.withOpacity(0.5),
          ),
          onPressed: () async {
            await mtPlayerHandler
                .toggleShuffle(); // Aggiungi questa funzione nel tuo MtPlayerHandler
          },
        ),

        // seek backward
        IconButton(
          icon: const Icon(
            Icons.replay_10,
            color: Colors.white,
          ),
          onPressed: () async {
            await mtPlayerHandler.seek(
                mtPlayerHandler.videoPlayerController.value.position -
                    const Duration(seconds: 10));
          },
        ),

        // Skip previous
        StreamBuilder(
            stream: mtPlayerHandler.queue,
            builder: ((context, snapshot) {
              final queue = snapshot.data ?? [];
              final index = queue.indexOf(mtPlayerHandler.mediaItem.value!);
              bool isEnabled = index > 0;
              return IconButton(
                icon: Icon(
                  Icons.skip_previous,
                  color: isEnabled ? Colors.white : null,
                ),
                onPressed: isEnabled
                    ? () async {
                        await mtPlayerHandler.skipToPrevious();
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

        // Skip next
        StreamBuilder(
            stream: mtPlayerHandler.queue,
            builder: ((context, snapshot) {
              final queue = snapshot.data ?? [];
              final index = queue.indexOf(mtPlayerHandler.mediaItem.value!);
              bool isEnable = index < queue.length - 1;
              return IconButton(
                icon: Icon(
                  Icons.skip_next,
                  color: isEnable ? Colors.white : null,
                ),
                onPressed: isEnable
                    ? () async {
                        await mtPlayerHandler.skipToNext();
                      }
                    : null,
              );
            })),

        // seek forward
        IconButton(
          icon: const Icon(
            Icons.forward_10,
            color: Colors.white,
          ),
          onPressed: () async {
            await mtPlayerHandler.seek(
                mtPlayerHandler.videoPlayerController.value.position +
                    const Duration(seconds: 10));
          },
        ),

        // repeat
        StreamBuilder(
            stream: mtPlayerHandler.playbackState
                .map((state) => state.repeatMode)
                .distinct(),
            builder: (context, snapshot) {
              final repeatMode = snapshot.data ?? AudioServiceRepeatMode.none;
              const icons = [
                Icon(Icons.repeat, color: Colors.white),
                Icon(Icons.repeat_one, color: Colors.white),
              ];
              const cycleModes = [
                AudioServiceRepeatMode.none,
                AudioServiceRepeatMode.one,
              ];
              final index = cycleModes.indexOf(repeatMode);
              return IconButton(
                icon: icons[index],
                onPressed: () {
                  mtPlayerHandler.setRepeatMode(cycleModes[
                      (cycleModes.indexOf(repeatMode) + 1) %
                          cycleModes.length]);
                },
              );
            }),
      ],
    );
  }
}

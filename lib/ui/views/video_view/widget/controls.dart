import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:my_tube/services/mt_player_service.dart';

class Controls extends StatelessWidget {
  const Controls({super.key, required this.mtPlayerService});

  final MtPlayerService mtPlayerService;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Shuffle
        IconButton(
          icon: Icon(
            Icons.shuffle,
            color: mtPlayerService.shuffleEnabled
                ? Theme.of(context).colorScheme.onPrimary
                : Colors.white.withOpacity(0.5),
          ),
          onPressed: () async {
            await mtPlayerService
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
            await mtPlayerService.seek(
                mtPlayerService.videoPlayerController.value.position -
                    const Duration(seconds: 10));
          },
        ),

        // Skip previous
        StreamBuilder(
            stream: mtPlayerService.queue,
            builder: ((context, snapshot) {
              final queue = snapshot.data ?? [];
              final index = queue.indexOf(mtPlayerService.mediaItem.value!);
              bool isEnabled = index > 0;
              return IconButton(
                icon: Icon(
                  Icons.skip_previous,
                  color: isEnabled ? Colors.white : null,
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
                  iconSize: MediaQuery.of(context).size.width * 0.15,
                  icon: Icon(
                    playing ? Icons.pause_circle : Icons.play_circle,
                    color: Colors.white,
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
              final index = queue.indexOf(mtPlayerService.mediaItem.value!);
              bool isEnable = index < queue.length - 1;
              return IconButton(
                icon: Icon(
                  Icons.skip_next,
                  color: isEnable ? Colors.white : null,
                ),
                onPressed: isEnable
                    ? () async {
                        await mtPlayerService.skipToNext();
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
            await mtPlayerService.seek(
                mtPlayerService.videoPlayerController.value.position +
                    const Duration(seconds: 10));
          },
        ),

        // repeat
        StreamBuilder(
            stream: mtPlayerService.playbackState
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
                  mtPlayerService.setRepeatMode(cycleModes[
                      (cycleModes.indexOf(repeatMode) + 1) %
                          cycleModes.length]);
                },
              );
            }),
      ],
    );
  }
}

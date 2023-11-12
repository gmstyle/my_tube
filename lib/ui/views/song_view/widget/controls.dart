import 'package:flutter/material.dart';
import 'package:my_tube/services/mt_player_handler.dart';

class Controls extends StatelessWidget {
  const Controls({super.key, required this.mtPlayerHandler});

  final MtPlayerHandler mtPlayerHandler;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
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
      ],
    );
  }
}

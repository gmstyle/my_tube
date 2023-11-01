import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/services/mt_player_handler.dart';

class SeekBar extends StatelessWidget {
  const SeekBar({super.key, this.darkBackground = false});

  final bool darkBackground;

  String _fornmatDuration(Duration? duration) {
    if (duration == null) {
      return '--:--';
    }

    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final mtPlayerHandler = context.read<MtPlayerHandler>();
    return Row(
      children: [
        // Position
        StreamBuilder(
            stream: mtPlayerHandler.playbackState
                .map((playbackState) => playbackState.position)
                .distinct(),
            builder: (context, snapshot) {
              final position = snapshot.data ?? Duration.zero;
              return Text(
                _fornmatDuration(position),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: darkBackground
                          ? Colors.white
                          : Theme.of(context).colorScheme.primary,
                    ),
              );
            }),

        // Seek bar
        Flexible(
          child: StreamBuilder(
              stream: mtPlayerHandler.playbackState
                  .map((playbackState) => playbackState.position)
                  .distinct(),
              builder: (context, snapshot) {
                final position = snapshot.data ?? Duration.zero;
                return StreamBuilder(
                    stream: mtPlayerHandler.mediaItem
                        .map((mediaItem) => mediaItem?.duration)
                        .distinct(),
                    builder: (context, snapshot) {
                      final duration = snapshot.data ?? Duration.zero;
                      return SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: darkBackground
                              ? Colors.white
                              : Theme.of(context).colorScheme.primary,
                          inactiveTrackColor: darkBackground
                              ? Colors.white.withOpacity(0.3)
                              : Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.3),
                          thumbColor: darkBackground
                              ? Colors.white
                              : Theme.of(context).colorScheme.primary,
                          overlayColor: darkBackground
                              ? Colors.white.withOpacity(0.3)
                              : Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.3),
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 5),
                          overlayShape:
                              const RoundSliderOverlayShape(overlayRadius: 10),
                        ),
                        child: Slider(
                          value: position.inMilliseconds.toDouble(),
                          max: duration.inMilliseconds.toDouble(),
                          onChanged: (value) {
                            mtPlayerHandler.seek(Duration(
                                milliseconds: value.toInt(),
                                microseconds: 0,
                                seconds: 0));
                          },
                        ),
                      );
                    });
              }),
        ),

        // Remaining time
        StreamBuilder(
            stream: mtPlayerHandler.playbackState
                .map((playbackState) => playbackState.position)
                .distinct(),
            builder: (context, snapshot) {
              final position = snapshot.data ?? Duration.zero;
              return StreamBuilder(
                  stream: mtPlayerHandler.mediaItem
                      .map((mediaItem) => mediaItem?.duration)
                      .distinct(),
                  builder: (context, snapshot) {
                    final duration = snapshot.data ?? Duration.zero;
                    return Text(
                      _fornmatDuration(duration - position),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: darkBackground
                                ? Colors.white
                                : Theme.of(context).colorScheme.primary,
                          ),
                    );
                  });
            }),
      ],
    );
  }
}

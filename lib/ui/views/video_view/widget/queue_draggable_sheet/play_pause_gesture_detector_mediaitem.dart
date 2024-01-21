import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/mini_player_cubit/mini_player_cubit.dart';

class PlayPauseGestureDetectorMediaitem extends StatelessWidget {
  const PlayPauseGestureDetectorMediaitem(
      {super.key, required this.mediaItem, required this.child});

  final MediaItem mediaItem;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final miniPlayerCubit = context.read<MiniPlayerCubit>();
    return StreamBuilder(
        stream: miniPlayerCubit.mtPlayerService.playbackState
            .map((playbackState) => playbackState.playing)
            .distinct(),
        builder: (context, snapshot) {
          final isPlaying = snapshot.data ?? false;
          return GestureDetector(
            onTap: () {
              // se la traccia corrente è diversa da quella che si vuole riprodurre
              // si avvia la riproduzione
              if (miniPlayerCubit.mtPlayerService.currentTrack?.id !=
                  mediaItem.id) {
                miniPlayerCubit.startPlaying(mediaItem.id);
              } else {
                // altrimenti si mette in pausa o si riprende la riproduzione
                if (isPlaying) {
                  miniPlayerCubit.mtPlayerService.pause();
                } else {
                  miniPlayerCubit.mtPlayerService.play();
                }
              }
            },
            child: child,
          );
        });
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';

class PlayPauseGestureDetector extends StatelessWidget {
  const PlayPauseGestureDetector(
      {super.key, required this.id, required this.child, this.onTap});

  final String id;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final playerCubit = context.read<PlayerCubit>();
    return StreamBuilder(
        stream: playerCubit.mtPlayerService.playbackState
            .map((playbackState) => playbackState.playing)
            .distinct(),
        builder: (context, snapshot) {
          final isPlaying = snapshot.data ?? false;
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (onTap != null) {
                  onTap!();
                }
                // se la traccia corrente è diversa da quella che si vuole riprodurre
                // si avvia la riproduzione
                if (playerCubit.mtPlayerService.currentTrack?.id != id) {
                  playerCubit.startPlaying(id);
                } else {
                  // altrimenti si mette in pausa o si riprende la riproduzione
                  if (isPlaying) {
                    playerCubit.mtPlayerService.pause();
                  } else {
                    playerCubit.mtPlayerService.play();
                  }
                }
              },
              child: child,
            ),
          );
        });
  }
}

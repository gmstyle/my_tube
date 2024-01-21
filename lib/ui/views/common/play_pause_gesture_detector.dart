import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/mini_player_cubit/mini_player_cubit.dart';
import 'package:my_tube/models/resource_mt.dart';

class PlayPauseGestureDetector extends StatelessWidget {
  const PlayPauseGestureDetector(
      {super.key, required this.resource, required this.child});

  final ResourceMT resource;
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
                  resource.id) {
                miniPlayerCubit.startPlaying(resource.id!);
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

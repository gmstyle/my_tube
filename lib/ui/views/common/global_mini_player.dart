import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';
import 'package:my_tube/blocs/persistent_ui/persistent_ui_cubit.dart';
import 'package:my_tube/ui/views/common/mini_player.dart';

class GlobalMiniPlayer extends StatelessWidget {
  const GlobalMiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerCubit, PlayerState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, playerState) {
        if (playerState.status == PlayerStatus.hidden) {
          return const SizedBox.shrink();
        }

        return BlocBuilder<PersistentUiCubit, PersistentUiState>(
          builder: (context, uiState) {
            return AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: 0,
              right: 0,
              bottom: uiState.bottomPadding,
              child: Material(
                color: Colors.transparent,
                child: const MiniPlayer(),
              ),
            );
          },
        );
      },
    );
  }
}

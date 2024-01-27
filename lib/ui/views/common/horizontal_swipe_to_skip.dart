import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';

class HorizontalSwipeToSkip extends StatelessWidget {
  const HorizontalSwipeToSkip({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final PlayerCubit playerCubit = context.read<PlayerCubit>();
    return Dismissible(
      key: const Key('horizontal_swipe_to_skip'),
      child: child,
      confirmDismiss: (direction) async {
        _confirmDismiss(playerCubit, direction);

        return Future.value(false);
      },
    );
  }

  Future<void> _confirmDismiss(
      PlayerCubit playerCubit, DismissDirection direction) async {
    if (direction == DismissDirection.startToEnd) {
      if (playerCubit.mtPlayerService.isShuffleModeEnabled) {
        await playerCubit.skipToNextInShuffleMode();
      } else {
        await playerCubit.skipToPrevious();
      }
    } else {
      if (playerCubit.mtPlayerService.isShuffleModeEnabled) {
        await playerCubit.skipToNextInShuffleMode();
      } else {
        await playerCubit.skipToNext();
      }
    }
  }
}

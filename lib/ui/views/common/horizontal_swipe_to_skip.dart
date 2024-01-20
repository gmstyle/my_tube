import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/mini_player_cubit/mini_player_cubit.dart';

class HorizontalSwipeToSkip extends StatelessWidget {
  const HorizontalSwipeToSkip({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final MiniPlayerCubit miniPlayerCubit = context.read<MiniPlayerCubit>();
    return Dismissible(
      key: const Key('horizontal_swipe_to_skip'),
      child: child,
      confirmDismiss: (direction) async {
        _confirmDismiss(miniPlayerCubit, direction);

        return Future.value(false);
      },
    );
  }

  Future<void> _confirmDismiss(
      MiniPlayerCubit miniPlayerCubit, DismissDirection direction) async {
    if (direction == DismissDirection.startToEnd) {
      if (miniPlayerCubit.mtPlayerService.isShuffleModeEnabled) {
        await miniPlayerCubit.skipToNextInShuffleMode();
      } else {
        await miniPlayerCubit.skipToPrevious();
      }
    } else {
      if (miniPlayerCubit.mtPlayerService.isShuffleModeEnabled) {
        await miniPlayerCubit.skipToNextInShuffleMode();
      } else {
        await miniPlayerCubit.skipToNext();
      }
    }
  }
}

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
        if (direction == DismissDirection.startToEnd) {
          await miniPlayerCubit.skipToPrevious();
        } else {
          await miniPlayerCubit.skipToNext();
        }

        return Future.value(false);
      },
    );
  }
}

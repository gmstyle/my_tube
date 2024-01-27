import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';

class ClearQueueButton extends StatelessWidget {
  const ClearQueueButton({super.key});

  @override
  Widget build(BuildContext context) {
    final playerCubit = context.watch<PlayerCubit>();
    return IconButton(
        onPressed: () {
          _onClearQueuePressed(context, playerCubit);
        },
        icon: const Icon(Icons.clear_all));
  }

  void _onClearQueuePressed(BuildContext context, PlayerCubit playerCubit) {
    showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.queue_music),
                  SizedBox(width: 8),
                  Text('Clear queue'),
                ],
              ),
              content: const Text('Are you sure you want to clear your queue?'),
              actions: [
                TextButton(
                    onPressed: () {
                      context.pop(false);
                    },
                    child: const Text('No')),
                TextButton(
                    onPressed: () {
                      context.pop(true);
                    },
                    child: const Text('Yes')),
              ],
            )).then((value) => {
          if (value == true)
            {
              playerCubit.stopPlayingAndClearQueue(),
              context.pop(),
            }
        });
  }
}

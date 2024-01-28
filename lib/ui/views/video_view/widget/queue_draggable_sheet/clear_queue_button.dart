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
              title: Row(
                children: [
                  Icon(Icons.queue_music,
                      color:
                          Theme.of(context).colorScheme.onSecondaryContainer),
                  const SizedBox(width: 8),
                  const Text('Clear queue'),
                ],
              ),
              content: const Text('Are you sure you want to clear your queue?'),
              actions: [
                IconButton(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    onPressed: () {
                      context.pop(false);
                    },
                    icon: const Icon(
                      Icons.close,
                    )),
                IconButton(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    onPressed: () {
                      context.pop(true);
                    },
                    icon: const Icon(
                      Icons.check,
                    )),
              ],
            )).then((value) => {
          if (value == true)
            {
              playerCubit.stopPlayingAndClearQueue(),
            }
        });
  }
}

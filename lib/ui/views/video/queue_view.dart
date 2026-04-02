import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';
import 'package:my_tube/ui/views/video/widget/queue_draggable_sheet/clear_queue_button.dart';
import 'package:my_tube/ui/views/video/widget/queue_draggable_sheet/media_item_list.dart';

class QueueView extends StatefulWidget {
  const QueueView({super.key});

  @override
  State<QueueView> createState() => _QueueViewState();
}

class _QueueViewState extends State<QueueView> {
  late final PlayerCubit playerCubit;

  @override
  void initState() {
    super.initState();
    playerCubit = context.read<PlayerCubit>();

    // Ascolta quando la queue diventa vuota
    playerCubit.mtPlayerService.queue.listen((queue) {
      if (queue.isEmpty && mounted) {
        context.pop();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down),
          tooltip: 'Back',
          onPressed: () => context.pop(),
        ),
        title: const Text('Queue'),
        centerTitle: true,
        actions: const [ClearQueueButton()],
      ),
      body: const MediaItemList(),
    );
  }
}

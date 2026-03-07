import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/blocs/persistent_ui/persistent_ui_cubit.dart';
import 'package:my_tube/ui/views/video/widget/queue_draggable_sheet/clear_queue_button.dart';
import 'package:my_tube/ui/views/video/widget/queue_draggable_sheet/media_item_list.dart';

class QueueView extends StatefulWidget {
  const QueueView({super.key, this.restoreMiniPlayer = false});

  final bool restoreMiniPlayer;

  @override
  State<QueueView> createState() => _QueueViewState();
}

class _QueueViewState extends State<QueueView> {
  late final PersistentUiCubit persistentUiCubit;

  @override
  void initState() {
    super.initState();
    persistentUiCubit = context.read<PersistentUiCubit>();
  }

  @override
  void dispose() {
    if (widget.restoreMiniPlayer) {
      persistentUiCubit.setPlayerVisibility(true);
    }
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

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/ui/views/video/widget/queue_draggable_sheet/clear_queue_button.dart';
import 'package:my_tube/ui/views/video/widget/queue_draggable_sheet/media_item_list.dart';

class QueueView extends StatelessWidget {
  const QueueView({super.key});

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

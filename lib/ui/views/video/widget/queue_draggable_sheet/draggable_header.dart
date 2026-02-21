import 'package:flutter/material.dart';
import 'package:my_tube/ui/views/video/widget/queue_draggable_sheet/clear_queue_button.dart';
import 'package:my_tube/ui/views/video/widget/queue_draggable_sheet/queue_draggable_sheet.dart';

class DraggableHeader extends StatelessWidget {
  const DraggableHeader({super.key, required this.controller});

  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: controller,
      child: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Column(children: [
          // drag handle
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // content row: changes based on sheet state
          ListenableBuilder(
            listenable: queueDraggableController,
            builder: (context, child) {
              final isExpanded = queueDraggableController.size == maxChildSize;
              if (isExpanded) {
                // expanded: show collapse button + title + clear button
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_down),
                        tooltip: 'Close queue',
                        onPressed: () => queueDraggableController.animateTo(
                          minChildSize,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Queue',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      const ClearQueueButton(),
                    ],
                  ),
                );
              }
              // collapsed: show queue icon hint
              return Icon(
                Icons.queue_music,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5),
              );
            },
          ),
        ]),
      ),
    );
  }
}

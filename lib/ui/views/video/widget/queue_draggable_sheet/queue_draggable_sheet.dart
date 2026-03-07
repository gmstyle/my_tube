import 'package:flutter/material.dart';
import 'package:my_tube/utils/constants.dart';
import 'package:my_tube/ui/views/video/widget/queue_draggable_sheet/draggable_header.dart';
import 'package:my_tube/ui/views/video/widget/queue_draggable_sheet/media_item_list.dart';

final queueDraggableController = DraggableScrollableController();

class QueueDraggableSheet extends StatelessWidget {
  const QueueDraggableSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        controller: queueDraggableController,
        initialChildSize: queueSheetMinChildSize,
        minChildSize: queueSheetMinChildSize,
        maxChildSize: queueSheetMaxChildSize,
        snap: true,
        snapSizes: queueSheetSnapSizes,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8), topRight: Radius.circular(8))),
            child: Stack(
              children: [
                InkWell(
                    onTap: _expandCollapse,
                    child: DraggableHeader(controller: scrollController)),
                const SizedBox(
                  height: 8,
                ),
                const MediaItemList(),
              ],
            ),
          );
        });
  }

  void _expandCollapse() {
    final targetSize = queueDraggableController.size == queueSheetMinChildSize
        ? queueSheetMaxChildSize
        : queueSheetMinChildSize;
    _animateControllerTo(targetSize);
  }

  void _animateControllerTo(double targetSize) {
    queueDraggableController.animateTo(
      targetSize,
      duration: queueSheetAnimationDuration,
      curve: Curves.easeInOut,
    );
  }
}

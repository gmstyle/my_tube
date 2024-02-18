import 'package:flutter/material.dart';
import 'package:my_tube/ui/views/video_view/widget/queue_draggable_sheet/draggable_header.dart';
import 'package:my_tube/ui/views/video_view/widget/queue_draggable_sheet/media_item_list.dart';

const minChildSize = 0.05;
const maxChildSize = 1.0;
const snapSizes = [
  0.4,
];

final queueDraggableController = DraggableScrollableController();

class QueueDraggableSheet extends StatelessWidget {
  const QueueDraggableSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        controller: queueDraggableController,
        initialChildSize: minChildSize,
        minChildSize: minChildSize,
        maxChildSize: maxChildSize,
        snap: true,
        snapSizes: snapSizes,
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
    final targetSize = queueDraggableController.size == minChildSize
        ? maxChildSize
        : minChildSize;
    _animateControllerTo(targetSize);
  }

  void _animateControllerTo(double targetSize) {
    queueDraggableController.animateTo(
      targetSize,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }
}

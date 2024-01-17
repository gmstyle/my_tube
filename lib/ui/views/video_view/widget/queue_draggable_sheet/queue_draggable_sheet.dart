import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/mini_player_cubit/mini_player_cubit.dart';
import 'package:my_tube/ui/views/video_view/widget/queue_draggable_sheet/draggable_header.dart';
import 'package:my_tube/ui/views/video_view/widget/queue_draggable_sheet/media_item_list.dart';

const minChildSize = 0.05;
const maxChildSize = 1.0;
const snapSizes = [
  0.5,
];

class QueueDraggableSheet extends StatelessWidget {
  QueueDraggableSheet({super.key});

  final controller = DraggableScrollableController();

  @override
  Widget build(BuildContext context) {
    final miniPlayerCubit = context.read<MiniPlayerCubit>();

    return DraggableScrollableSheet(
        controller: controller,
        initialChildSize: minChildSize,
        minChildSize: minChildSize,
        maxChildSize: maxChildSize,
        snap: true,
        snapSizes: snapSizes,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
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
                const MediaItemList()
              ],
            ),
          );
        });
  }

  void _expandCollapse() {
    final targetSize =
        controller.size == minChildSize ? maxChildSize : minChildSize;
    _animateControllerTo(targetSize);
  }

  void _animateControllerTo(double targetSize) {
    controller.animateTo(
      targetSize,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }
}

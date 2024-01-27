import 'package:flutter/material.dart';
import 'package:my_tube/ui/views/video_view/widget/queue_draggable_sheet/queue_draggable_sheet.dart';

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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.5),
                    borderRadius: BorderRadius.circular(2)),
              ),
            ],
          ),
          const SizedBox(
            height: 4,
          ),
          ListenableBuilder(
            listenable: queueDraggableController,
            builder: (context, child) {
              if (queueDraggableController.size != maxChildSize) {
                return child!;
              }
              return const SizedBox();
            },
            child: Icon(
              Icons.queue_music,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          )
        ]),
      ),
    );
  }
}

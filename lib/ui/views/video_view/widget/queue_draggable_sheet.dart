import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/mini_player_cubit/mini_player_cubit.dart';
import 'package:my_tube/ui/views/video_view/widget/mediaitem_tile.dart';

class QueueDraggableSheet extends StatelessWidget {
  QueueDraggableSheet({super.key});

  final controller = DraggableScrollableController();
  final minChildSize = 0.05;
  final maxChildSize = 1.0;
  final snapSizes = const [
    0.5,
  ];
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
                  child: SingleChildScrollView(
                    controller: scrollController,
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
                        const Text(
                          'QUEUE',
                        ),
                      ]),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Positioned(
                  top: 40,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: StreamBuilder<List<MediaItem>>(
                      stream: miniPlayerCubit.mtPlayerHandler.queue,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final queue = snapshot.data!;
                          return ListView.builder(
                              itemCount: queue.length,
                              itemBuilder: (context, index) {
                                final mediaItem = queue[index];
                                return GestureDetector(
                                    onTap: () {
                                      miniPlayerCubit
                                          .startPlaying(mediaItem.id);
                                    },
                                    child: MediaitemTile(video: mediaItem));
                              });
                        } else {
                          return const SizedBox();
                        }
                      }),
                ),
              ],
            ),
          );
        });
  }

  void _expandCollapse() {
    // se il draggable sheet è aperto lo chiudo altrimenti lo apro
    if (controller.size == minChildSize) {
      controller.animateTo(
        maxChildSize,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      controller.animateTo(
        minChildSize,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }
}

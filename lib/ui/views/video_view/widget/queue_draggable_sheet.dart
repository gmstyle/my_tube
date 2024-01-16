import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/services/mt_player_handler.dart';

class QueueDraggableSheet extends StatelessWidget {
  const QueueDraggableSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final mtPlayerHandler = context.read<MtPlayerHandler>();

    return DraggableScrollableSheet(
        initialChildSize: 0.05,
        minChildSize: 0.05,
        snap: true,
        snapSizes: const [
          0.5,
        ],
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8), topRight: Radius.circular(8))),
            child: Column(
              children: [
                SingleChildScrollView(
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('Queue',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface)),
                        ],
                      ),
                    ]),
                  ),
                ),
                Expanded(
                  child: StreamBuilder<List<MediaItem>>(
                      stream: mtPlayerHandler.queue,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final queue = snapshot.data!;
                          return ListView.builder(
                              itemCount: queue.length,
                              itemBuilder: (context, index) {
                                final mediaItem = queue[index];
                                return ListTile(
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                        mediaItem.artUri.toString()),
                                  ),
                                  title: Text(mediaItem.title ?? ''),
                                  subtitle: Text(mediaItem.album ?? ''),
                                  onTap: () {
                                    // TODO: Implement onTap
                                  },
                                );
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
}

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/mini_player_cubit/mini_player_cubit.dart';
import 'package:my_tube/respositories/queue_repository.dart';
import 'package:my_tube/ui/views/common/resource_tile.dart';

class QueueTabView extends StatelessWidget {
  const QueueTabView({super.key});

  @override
  Widget build(BuildContext context) {
    final queueRepository = context.read<QueueRepository>();

    return ValueListenableBuilder(
        valueListenable: queueRepository.queueListenable,
        builder: (context, box, _) {
          final queue = box.values.toList();

          if (queue.isEmpty) {
            return const Center(
              child: Text('No videos in queue'),
            );
          }

          return ListView.builder(
            itemCount: queue.length,
            itemBuilder: (context, index) {
              queue.sort((b, a) => a.addedAt!.compareTo(b.addedAt!));
              final video = queue[index];
              return GestureDetector(
                  onTap: () async {
                    await context
                        .read<MiniPlayerCubit>()
                        .startPlaying(video.id!);
                  },
                  child: ResourceTile(resource: video));
            },
          );
        });
  }
}

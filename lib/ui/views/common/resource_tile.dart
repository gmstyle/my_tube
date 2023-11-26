import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:my_tube/blocs/home/queue_tab/queue_cubit.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/respositories/queue_repository.dart';
import 'package:my_tube/services/mt_player_handler.dart';
import 'package:my_tube/ui/views/common/audio_spectrum_icon.dart';
import 'package:provider/provider.dart';

class ResourceTile extends StatelessWidget {
  const ResourceTile({super.key, required this.resource});

  final ResourceMT resource;

  @override
  Widget build(BuildContext context) {
    final queueCubit = context.read<QueueCubit>();
    return Container(
      height: MediaQuery.of(context).size.height * 0.1,
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.03),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  resource.thumbnailUrl != null
                      ? Image.network(
                          resource.thumbnailUrl!,
                          height: MediaQuery.of(context).size.height * 0.09,
                          width: MediaQuery.of(context).size.width * 0.2,
                          fit: BoxFit.cover,
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: const SizedBox(
                            child: FlutterLogo(),
                          ),
                        ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.4),
                          Colors.black.withOpacity(0.9),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    left: 8,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // show an animated that the video is playing
                        StreamBuilder(
                            stream: queueCubit.mtPlayerHandler.mediaItem,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                final currentVideoId = snapshot.data!.id;
                                if (currentVideoId == resource.id) {
                                  return StreamBuilder(
                                      stream: queueCubit
                                          .mtPlayerHandler.playbackState
                                          .map((playbackState) =>
                                              playbackState.playing)
                                          .distinct(),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          final isPlaying =
                                              snapshot.data ?? false;
                                          if (isPlaying) {
                                            return const AudioSpectrumIcon();
                                          }
                                        }
                                        return const SizedBox();
                                      });
                                }
                              }
                              return const SizedBox();
                            }),
                        setTypeIcon(context) ?? const SizedBox(),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(
            width: 16,
          ),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resource.title ?? '',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold, color: Colors.white),
                  maxLines: 2,
                ),
                Text(resource.channelTitle ?? '',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.white)),
              ],
            ),
          ),

          //Menu
          if (resource.kind != 'youtube#channel')
            PopupMenuButton(
                iconColor: Colors.white,
                itemBuilder: (context) {
                  return [
                    // show the option to remove the video from the queue if it is in the queue
                    if (queueCubit.queueRepository.videoIds
                        .contains(resource.id))
                      PopupMenuItem(
                        value: 'remove',
                        child: const Text('Remove from queue'),
                        onTap: () async =>
                            await queueCubit.removeFromQueue(resource),
                      ),

                    // show the option to add the video to the queue if it is not in the queue
                    if (!queueCubit.queueRepository.videoIds
                        .contains(resource.id))
                      PopupMenuItem(
                        value: 'add',
                        child: const Text('Add to queue'),
                        onTap: () async =>
                            await queueCubit.addToQueue(resource),
                      ),
                  ];
                },
                icon: const Icon(Icons.more_vert_rounded))
        ],
      ),
    );
  }

  Widget? setTypeIcon(BuildContext context) {
    IconData icon;
    switch (resource.kind) {
      case 'youtube#channel':
        icon = Icons.monitor_rounded;
      case 'youtube#playlist':
        icon = Icons.queue_music_rounded;

      default:
        icon = Icons.audiotrack_rounded;
    }

    return Icon(icon, color: Colors.white);
  }
}

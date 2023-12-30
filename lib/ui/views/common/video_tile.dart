import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_bloc.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/services/mt_player_handler.dart';
import 'package:my_tube/ui/views/common/audio_spectrum_icon.dart';

class VideoTile extends StatelessWidget {
  const VideoTile({super.key, required this.video});

  final ResourceMT video;

  @override
  Widget build(BuildContext context) {
    final favoritesBloc = context.read<FavoritesBloc>();
    final MtPlayerHandler mtPlayerHandler = context.read<MtPlayerHandler>();
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
                  video.thumbnailUrl != null
                      ? Image.network(
                          video.thumbnailUrl!,
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
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    bottom: 4,
                    left: 4,
                    right: 0,
                    child: Column(
                      children: [
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // show an animated that the video is playing
                            StreamBuilder(
                                stream: mtPlayerHandler.mediaItem,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    final currentVideoId = snapshot.data!.id;
                                    if (currentVideoId == video.id) {
                                      return StreamBuilder(
                                          stream: mtPlayerHandler.playbackState
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
                          ],
                        ),
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
                  video.title ?? '',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold, color: Colors.white),
                  maxLines: 2,
                ),
                Text(video.channelTitle ?? '',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.white)),
              ],
            ),
          ),

          //Menu
          PopupMenuButton(
              iconColor: Colors.white,
              itemBuilder: (context) {
                return [
                  // show the option to remove the video from the queue if it is in the queue
                  if (favoritesBloc.favoritesRepository.videoIds
                      .contains(video.id))
                    PopupMenuItem(
                        value: 'remove',
                        child: const Text('Remove from queue'),
                        onTap: () {
                          //TODO
                        }),

                  // show the option to add the video to the queue if it is not in the queue
                  if (!favoritesBloc.favoritesRepository.videoIds
                      .contains(video.id))
                    PopupMenuItem(
                        value: 'add',
                        child: const Text('Add to queue'),
                        onTap: () {
                          //TODO
                        }),
                ];
              },
              icon: const Icon(Icons.more_vert_rounded))
        ],
      ),
    );
  }
}
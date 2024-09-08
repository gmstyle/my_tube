import 'package:audio_service/audio_service.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:my_tube/services/mt_player_service.dart';
import 'package:my_tube/ui/views/common/expandable_text.dart';
import 'package:my_tube/ui/views/video_view/widget/queue_draggable_sheet/clear_queue_button.dart';
import 'package:my_tube/ui/views/video_view/widget/queue_draggable_sheet/media_item_list.dart';

class VideoTabletScreen extends StatelessWidget {
  const VideoTabletScreen(
      {super.key,
      required this.mtPlayerService,
      this.mediaItem,
      required this.aspectRatio});

  final MtPlayerService mtPlayerService;
  final MediaItem? mediaItem;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              child: Column(
                //crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // video player
                  Hero(
                    tag: 'video_image_or_player',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: AspectRatio(
                          aspectRatio: aspectRatio,
                          child: Chewie(
                              controller: mtPlayerService.chewieController!)),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  // title
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          mediaItem?.title ?? '',
                          maxLines: 2,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  // album
                  Row(
                    children: [
                      Flexible(
                        child: Text(mediaItem?.album ?? '',
                            maxLines: 2,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                            )),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  if (mediaItem?.extras!['description'] != null &&
                      mediaItem?.extras!['description'] != '')
                    ExpandableText(
                      title: 'Description',
                      text: mediaItem?.extras!['description'] ?? '',
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(
            width: 16,
          ),
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.queue_music,
                          color: Colors.white,
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Text(
                          'Queue',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                  ),
                        ),
                      ],
                    ),
                    const Spacer(),

                    // clear queue
                    const ClearQueueButton(
                      isTablet: true,
                    ),
                    // repeat mode
                    StreamBuilder(
                        stream: mtPlayerService.playbackState
                            .map((state) => state.repeatMode)
                            .distinct(),
                        builder: (context, snapshot) {
                          final repeatMode =
                              snapshot.data ?? AudioServiceRepeatMode.none;
                          final icons = [
                            Icon(Icons.repeat,
                                color: Theme.of(context).colorScheme.onPrimary),
                            Icon(Icons.repeat_one,
                                color: Theme.of(context).colorScheme.onPrimary),
                            Icon(Icons.repeat,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimary
                                    .withOpacity(0.5)),
                          ];
                          const cycleModes = [
                            AudioServiceRepeatMode.all,
                            AudioServiceRepeatMode.one,
                            AudioServiceRepeatMode.none,
                          ];
                          final index = cycleModes.indexOf(repeatMode);
                          return IconButton(
                            icon: icons[index],
                            onPressed: () {
                              var cycleMode =
                                  cycleModes[(index + 1) % cycleModes.length];
                              mtPlayerService.setRepeatMode(cycleMode);
                            },
                          );
                        }),
                  ],
                ),
                const Expanded(
                    child: MediaItemList(
                  isTablet: true,
                ))
              ],
            ),
          ),
        ],
      ),
    );
  }
}

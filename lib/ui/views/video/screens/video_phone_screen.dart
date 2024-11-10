import 'package:audio_service/audio_service.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:my_tube/services/mt_player_service.dart';
import 'package:my_tube/ui/views/common/expandable_text.dart';
import 'package:my_tube/ui/views/common/horizontal_swipe_to_skip.dart';
import 'package:my_tube/ui/views/common/seek_bar.dart';
import 'package:my_tube/ui/views/video/widget/controls.dart';
import 'package:my_tube/ui/views/video/widget/queue_draggable_sheet/queue_draggable_sheet.dart';

class VideoPhoneScreen extends StatelessWidget {
  const VideoPhoneScreen(
      {super.key,
      required this.mtPlayerService,
      this.mediaItem,
      required this.aspectRatio});

  final MtPlayerService mtPlayerService;
  final MediaItem? mediaItem;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              HorizontalSwipeToSkip(
                child: Hero(
                  tag: 'video_image_or_player',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.4,
                      ),
                      child: AspectRatio(
                          aspectRatio: aspectRatio,
                          child: Chewie(
                              controller: mtPlayerService.chewieController!)),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      mediaItem?.title ?? '',
                      maxLines: 2,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(mediaItem?.album ?? '',
                                maxLines: 2,
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                )),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),

                      // Seek bar
                      const SeekBar(
                        darkBackground: true,
                      ),
                      // controls
                      const Controls(),

                      // description
                      if (mediaItem?.extras!['description'] != null &&
                          mediaItem?.extras!['description'] != '')
                        ExpandableText(
                          title: 'Description',
                          text: mediaItem?.extras!['description'] ?? '',
                        ),
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.08,
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        const QueueDraggableSheet()
      ],
    );
  }
}

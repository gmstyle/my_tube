import 'package:flutter/material.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/ui/views/common/video_menu_dialog.dart';

class VideoGridItem extends StatelessWidget {
  const VideoGridItem({super.key, required this.video});

  final ResourceMT video;

  @override
  Widget build(BuildContext context) {
    return VideoMenuDialog(
      video: video,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(video.thumbnailUrl!, fit: BoxFit.cover),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.audiotrack_rounded,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              video.title!,
                              maxLines: 2,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              ' ${video.channelTitle ?? ''}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            )),
      ),
    );
  }
}

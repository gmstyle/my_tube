import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/models/video_mt.dart';

class VideoPlayerView extends StatelessWidget {
  const VideoPlayerView(
      {super.key, required this.video, required this.chewieController});

  final VideoMT? video;
  final ChewieController chewieController;

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16), topRight: Radius.circular(16))),
      onClosing: () {},
      builder: (_) => Column(
        children: [
          Row(
            children: [
              IconButton(
                  onPressed: () {
                    context.pop();
                  },
                  icon: const Icon(Icons.close)),
              Expanded(
                child: Text(
                  video?.title ?? '',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          AspectRatio(
            aspectRatio:
                chewieController.videoPlayerController.value.aspectRatio,
            child: Chewie(
              controller: chewieController,
            ),
          ),
        ],
      ),
    );
  }
}

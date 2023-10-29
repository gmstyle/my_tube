import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/services/mt_player_handler.dart';

class VideoPlayerBottomSheet extends StatelessWidget {
  const VideoPlayerBottomSheet(
      {super.key, required this.video, required this.mtPlayerHandler});

  final ResourceMT? video;
  final MtPlayerHandler mtPlayerHandler;

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      enableDrag: false,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16), topRight: Radius.circular(16))),
      onClosing: () {},
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: Text(video?.title ?? ''),
        ),
        body: Column(
          children: [
            AspectRatio(
                aspectRatio: mtPlayerHandler
                    .chewieController.videoPlayerController.value.aspectRatio,
                child: Chewie(controller: mtPlayerHandler.chewieController)),
            const SizedBox(
              height: 8,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(video?.description ?? ''),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

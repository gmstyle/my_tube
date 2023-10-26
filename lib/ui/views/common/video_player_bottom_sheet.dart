import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:my_tube/models/resource_mt.dart';

class VideoPlayerBottomSheet extends StatelessWidget {
  const VideoPlayerBottomSheet(
      {super.key, required this.video, required this.chewieController});

  final ResourceMT? video;
  final ChewieController chewieController;

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
                aspectRatio:
                    chewieController.videoPlayerController.value.aspectRatio,
                child: Chewie(controller: chewieController)),
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

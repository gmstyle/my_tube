import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/services/mt_player_handler.dart';
import 'package:my_tube/ui/views/common/custom_appbar.dart';
import 'package:my_tube/ui/views/common/main_gradient.dart';
import 'package:my_tube/ui/views/common/seek_bar.dart';
import 'package:my_tube/ui/views/video_view/widget/controls.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class VideoView extends StatelessWidget {
  const VideoView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final mtPlayerHandler = context.read<MtPlayerHandler>();

    mtPlayerHandler.chewieController.videoPlayerController.addListener(() {
      WakelockPlus.toggle(
          enable: mtPlayerHandler.chewieController.isFullScreen);
    });

    return MainGradient(
      child: Scaffold(
        appBar: CustomAppbar(
          centerTitle: true,
          leading: context.canPop()
              ? IconButton(
                  icon: const Icon(Icons.keyboard_arrow_down),
                  color: Colors.white,
                  onPressed: () {
                    context.pop();
                  },
                )
              : null,
        ),
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: StreamBuilder(
              stream: mtPlayerHandler.mediaItem,
              builder: (context, snapshot) {
                final mediaItem = snapshot.data;
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Hero(
                        tag: 'video_image_or_player',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: AspectRatio(
                              aspectRatio: _setAspectRatio(mtPlayerHandler),
                              child: Chewie(
                                  controller:
                                      mtPlayerHandler.chewieController)),
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
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: Colors.white,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          Flexible(
                            child: Text(mediaItem?.album ?? '',
                                maxLines: 2,
                                style: const TextStyle(
                                  color: Colors.white,
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
                      Controls(mtPlayerHandler: mtPlayerHandler),

                      // description
                      if (mediaItem?.extras!['description'] != null)
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                mediaItem?.extras!['description'] ?? '',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                    ),
                              ),
                            )
                          ],
                        )
                    ],
                  ),
                );
              }),
        ),
      ),
    );
  }

  double _setAspectRatio(MtPlayerHandler mtPlayerHandler) {
    return mtPlayerHandler
                .chewieController.videoPlayerController.value.aspectRatio <=
            1
        ? 1
        : mtPlayerHandler
            .chewieController.videoPlayerController.value.aspectRatio;
  }
}
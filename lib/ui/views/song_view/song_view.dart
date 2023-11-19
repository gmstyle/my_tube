import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/services/mt_player_handler.dart';
import 'package:my_tube/ui/views/common/custom_appbar.dart';
import 'package:my_tube/ui/views/common/main_gradient.dart';
import 'package:my_tube/ui/views/common/seek_bar.dart';
import 'package:my_tube/ui/views/song_view/widget/controls.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class SongView extends StatelessWidget {
  const SongView({
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
        backgroundColor: Colors.transparent,
        appBar: const CustomAppbar(),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: StreamBuilder(
              stream: mtPlayerHandler.mediaItem,
              builder: (context, snapshot) {
                final mediaItem = snapshot.data;
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: AspectRatio(
                            aspectRatio: mtPlayerHandler.chewieController
                                .videoPlayerController.value.aspectRatio,
                            child: Chewie(
                                controller: mtPlayerHandler.chewieController)),
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
}

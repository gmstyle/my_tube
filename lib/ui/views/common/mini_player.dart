import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:my_tube/blocs/home/explore_tab/cubit/mini_player_cubit.dart';
import 'package:my_tube/router/app_router.dart';
import 'package:video_player/video_player.dart';

class MiniPlayer extends StatefulWidget {
  const MiniPlayer({super.key, required this.video, required this.streamUrl});

  final Video video;
  final String streamUrl;

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;

  @override
  void initState() {
    super.initState();
    initPlayer();
  }

  @override
  void dispose() async {
    videoPlayerController?.dispose();
    chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
              child: chewieController != null &&
                      chewieController!
                          .videoPlayerController.value.isInitialized
                  ? Row(
                      children: [
                        SizedBox(
                            width: 0,
                            child: Chewie(controller: chewieController!)),
                        GestureDetector(
                          onTap: () {
                            context.goNamed(AppRoute.videoPlayer.name, extra: {
                              'video': widget.video,
                              'streamUrl': widget.streamUrl,
                              'chewieController': chewieController
                            });
                          },
                          child: Image.network(
                              widget.video.snippet!.thumbnails!.high!.url!),
                        )
                      ],
                    )
                  : const Center(
                      child: CircularProgressIndicator(),
                    ) /* FutureBuilder(
                  future: initPlayer(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Row(
                        children: [
                          SizedBox(
                              width: 0,
                              child: Chewie(controller: chewieController!)),
                          GestureDetector(
                            onTap: () {
                              context
                                  .goNamed(AppRoute.videoPlayer.name, extra: {
                                'video': widget.video,
                                'streamUrl': widget.streamUrl,
                                'chewieController': chewieController
                              });
                            },
                            child: Image.network(
                                widget.video.snippet!.thumbnails!.high!.url!),
                          )
                        ],
                      );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  }) */
              ),
          const SizedBox(
            width: 8,
          ),
          Expanded(
            flex: 2,
            child: Text(
              widget.video.snippet!.title!,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          if (chewieController != null)
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              StatefulBuilder(builder: (context, setState) {
                return IconButton(
                    onPressed: () {
                      setState(() {
                        if (chewieController!.isPlaying) {
                          chewieController!.pause();
                          setState(() {});
                        } else {
                          chewieController!.play();
                          setState(() {});
                        }
                      });
                    },
                    icon: Icon(chewieController!.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow));
              }),
              IconButton(
                  onPressed: () {
                    context.read<MiniPlayerCubit>().hideMiniPlayer();
                  },
                  icon: const Icon(Icons.close)),
            ]),
        ],
      ),
    );
  }

  Future<void> initPlayer() async {
    videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(widget.streamUrl));
    await videoPlayerController!.initialize();
    chewieController = ChewieController(
      videoPlayerController: videoPlayerController!,
      autoPlay: true,
      hideControlsTimer: const Duration(seconds: 1),
      /* additionalOptions: (context) {
        return [OptionItem(onTap: () {}, iconData: Icons.abc, title: 'Prova')];
      }, */
    );

    setState(() {});
  }
}

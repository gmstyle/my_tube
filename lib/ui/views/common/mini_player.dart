import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/blocs/home/mini_player_cubit/mini_player_cubit.dart';
import 'package:my_tube/models/video_mt.dart';
import 'package:my_tube/router/app_router.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer(
      {super.key, required this.video, required this.chewieController});

  final VideoMT? video;

  final ChewieController chewieController;

  @override
  Widget build(BuildContext context) {
    final MiniPlayerCubit miniPlayerCubit = context.read<MiniPlayerCubit>();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
              child: GestureDetector(
            onTap: () {
              context.goNamed(AppRoute.videoPlayer.name, extra: {
                'video': video,
                'chewieController': chewieController
              });
            },
            child: Row(
              children: [
                /// SzedBox con width 0 per far partire il chewieController
                /// senza che si veda il video in modalità mini player
                SizedBox(width: 0, child: Chewie(controller: chewieController)),
                video?.thumbnailUrl != null
                    ? Image.network(
                        video!.thumbnailUrl!,
                      )
                    : const SizedBox(
                        child: Icon(Icons.video_collection),
                      ),
                const SizedBox(
                  width: 8,
                ),
                /* onTap: () {
                    context.goNamed(AppRoute.videoPlayer.name, extra: {
                      'video': video,
                      'streamUrl': streamUrl,
                      'chewieController': chewieController
                    });
                  } */
                Expanded(
                  flex: 2,
                  child: Text(
                    video?.title ?? '',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(
            width: 8,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            StatefulBuilder(builder: (context, setState) {
              return IconButton(
                  onPressed: () {
                    setState(() {
                      if (chewieController.isPlaying) {
                        miniPlayerCubit.pauseMiniPlayer();
                        setState(() {});
                      } else {
                        miniPlayerCubit.playMiniPlayer();
                        setState(() {});
                      }
                    });
                  },
                  icon: Icon(chewieController.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow));
            }),
            IconButton(
                onPressed: () {
                  miniPlayerCubit.hideMiniPlayer();
                },
                icon: const Icon(Icons.close)),
          ]),
        ],
      ),
    );
  }
}

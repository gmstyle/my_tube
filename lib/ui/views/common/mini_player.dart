
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/mini_player_cubit/mini_player_cubit.dart';
import 'package:my_tube/models/video_mt.dart';
import 'package:my_tube/ui/views/common/video_player_bottom_sheet.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer(
      {super.key, required this.video, required this.flickManager});

  final VideoMT? video;

  final FlickManager flickManager;

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
              showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  builder: (context) => VideoPlayerView(
                        video: video,
                        flickManager: flickManager,
                      ));
            },
            child: Row(
              children: [
                /// SzedBox con width 0 per far partire il video
                /// senza che si veda il video in modalità mini player
                SizedBox(
                    width: 0,
                    child: FlickVideoPlayer(flickManager: flickManager)),
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
              final isPlaying =
                  flickManager.flickVideoManager?.isPlaying ?? false;

              return IconButton(
                  onPressed: () {
                    setState(() {
                      if (isPlaying) {
                        miniPlayerCubit.pauseMiniPlayer();
                        setState(() {});
                      } else {
                        miniPlayerCubit.playMiniPlayer();
                        setState(() {});
                      }
                    });
                  },
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow));
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

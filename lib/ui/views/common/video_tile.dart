import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:my_tube/blocs/home/mini_player_cubit/mini_player_cubit.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/ui/views/common/audio_spectrum_icon.dart';

class VideoTile extends StatelessWidget {
  const VideoTile({super.key, required this.video});

  final ResourceMT video;

  @override
  Widget build(BuildContext context) {
    final MiniPlayerCubit miniPlayerCubit =
        BlocProvider.of<MiniPlayerCubit>(context);
    return Container(
      height: MediaQuery.of(context).size.height * 0.1,
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.03),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        video.thumbnailUrl != null
                            ? Image.network(
                                video.thumbnailUrl!,
                                height:
                                    MediaQuery.of(context).size.height * 0.09,
                                width: MediaQuery.of(context).size.width * 0.2,
                                fit: BoxFit.cover,
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: const SizedBox(
                                  child: FlutterLogo(),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  width: 16,
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        video.title ?? '',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold, color: Colors.white),
                        maxLines: 2,
                      ),
                      Text(video.channelTitle ?? '',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
            // overlay gradient per video selected
            StreamBuilder(
                stream: miniPlayerCubit.mtPlayerHandler.mediaItem,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final currentVideoId = snapshot.data!.id;
                    if (currentVideoId == video.id) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.4),
                              Colors.black.withOpacity(0.6),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      );
                    }
                  }
                  return const SizedBox();
                }),

            // audio spectrum icon
            Positioned.fromRelativeRect(
              rect: RelativeRect.fromLTRB(
                  (MediaQuery.of(context).size.width * 0.03) * 4, 0, 0, 0),
              child: Row(
                children: [
                  StreamBuilder(
                      stream: miniPlayerCubit.mtPlayerHandler.mediaItem,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final currentVideoId = snapshot.data!.id;
                          if (currentVideoId == video.id) {
                            return StreamBuilder(
                                stream: miniPlayerCubit
                                    .mtPlayerHandler.playbackState
                                    .map((playbackState) =>
                                        playbackState.playing)
                                    .distinct(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    final isPlaying = snapshot.data ?? false;
                                    if (isPlaying) {
                                      return const AudioSpectrumIcon(
                                        height: 48,
                                        width: 48,
                                      );
                                    } else {
                                      return const Icon(
                                        Icons.more_horiz,
                                        color: Colors.white,
                                      );
                                    }
                                  }
                                  return const SizedBox();
                                });
                          }
                        }
                        return const SizedBox();
                      }),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/ui/views/common/spectrum_playing_icon.dart';

class VideoTile extends StatelessWidget {
  const VideoTile({super.key, required this.video});

  final ResourceMT video;

  @override
  Widget build(BuildContext context) {
    final PlayerCubit playerCubit = BlocProvider.of<PlayerCubit>(context);
    return Container(
      height: 70,
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
                            ? CachedNetworkImage(
                                imageUrl: video.thumbnailUrl!,
                                height:
                                    MediaQuery.of(context).size.height * 0.09,
                                width: MediaQuery.of(context).size.width * 0.2,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) =>
                                    FlutterLogo())
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
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              video.title ?? '',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary),
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Flexible(
                            child: Text(video.channelTitle ?? '',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // overlay gradient per video selected
            StreamBuilder(
                stream: playerCubit.mtPlayerService.mediaItem,
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

            // audio spectrum icon in posizione centrale rispetto all'immagine

            Positioned(
              bottom: 0,
              right: 0,
              child: SpectrumPlayingIcon(videoId: video.id!),
            )
          ],
        ),
      ),
    );
  }
}

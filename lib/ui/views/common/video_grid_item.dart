import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/services/mt_player_service.dart';
import 'package:my_tube/ui/views/common/spectrum_playing_icon.dart';

class VideoGridItem extends StatelessWidget {
  const VideoGridItem({super.key, required this.video});

  final ResourceMT video;

  @override
  Widget build(BuildContext context) {
    final mtPlayerService = context.watch<MtPlayerService>();
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Stack(
            fit: StackFit.expand,
            children: [
              video.thumbnailUrl != null
                  ? CachedNetworkImage(
                      imageUrl: video.thumbnailUrl!,
                      fit: BoxFit.cover,
                    )
                  : const SizedBox(),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                  ),
                ),
              ),
              Positioned(
                top: 8,
                bottom: 8,
                left: 8,
                right: 8,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            video.title!,
                            maxLines: 2,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            ' ${video.channelTitle ?? ''}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // overlay gradient per video selected
              StreamBuilder(
                  stream: mtPlayerService.mediaItem,
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
              Positioned(
                bottom: 0,
                right: 0,
                child: SpectrumPlayingIcon(videoId: video.id!),
              ),
            ],
          )),
    );
  }
}

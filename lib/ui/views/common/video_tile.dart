import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/ui/views/common/spectrum_playing_icon.dart';
import 'package:my_tube/utils/utils.dart';

class VideoTile extends StatelessWidget {
  const VideoTile({super.key, required this.video});

  final ResourceMT video;

  @override
  Widget build(BuildContext context) {
    final PlayerCubit playerCubit = BlocProvider.of<PlayerCubit>(context);

    return ListTile(
      leading: SizedBox(
        width: 90,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              video.thumbnailUrl != null
                  ? CachedNetworkImage(
                      imageUrl: video.thumbnailUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) {
                        // show base64 image if error
                        return Utils.buildImage(video.base64Thumbnail, context);
                      },
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        color: Theme.of(context).colorScheme.primaryContainer,
                      ),
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
                top: 0,
                bottom: 0,
                right: 0,
                left: 0,
                child: SpectrumPlayingIcon(videoId: video.id!),
              )
            ],
          ),
        ),
      ),
      title: Text(
        video.title ?? '',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        video.channelTitle ?? '',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

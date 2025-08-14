import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';
import 'package:my_tube/ui/views/common/spectrum_playing_icon.dart';
import 'package:my_tube/utils/utils.dart';
import 'package:my_tube/models/tiles.dart' as models;

class VideoTile extends StatelessWidget {
  const VideoTile({super.key, required this.video});

  final models.VideoTile video;

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
              Utils.buildImageWithFallback(
                thumbnailUrl: video.thumbnailUrl,
                context: context,
                placeholder: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(
                    Icons.play_circle_outline,
                    size: 32,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
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
                                Theme.of(context)
                                    .colorScheme
                                    .shadow
                                    .withValues(alpha: 0.4),
                                Theme.of(context)
                                    .colorScheme
                                    .shadow
                                    .withValues(alpha: 0.6),
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
                child: SpectrumPlayingIcon(videoId: video.id),
              )
            ],
          ),
        ),
      ),
      title: Text(
        video.title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: video.artist != null
          ? Text(
              video.artist!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            )
          : null,
    );
  }
}

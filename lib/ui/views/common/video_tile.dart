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
        width: 110,
        height: 70,
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
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.play_circle_outline,
                    size: 28,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),

              // subtle dark gradient for legibility
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Theme.of(context)
                          .colorScheme
                          .shadow
                          .withValues(alpha: 0.35),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),

              // overlay when selected (from player)
              StreamBuilder(
                  stream: playerCubit.mtPlayerService.mediaItem,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final currentVideoId = snapshot.data!.id;
                      if (currentVideoId == video.id) {
                        // show a subtle dark overlay without colored border
                        return Container(
                          color: Theme.of(context)
                              .colorScheme
                              .shadow
                              .withValues(alpha: 0.32),
                        );
                      }
                    }
                    return const SizedBox.shrink();
                  }),

              // center small playing/spectrum icon
              Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 36,
                    height: 36,
                    child: SpectrumPlayingIcon(videoId: video.id),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      title: Text(
        video.title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: video.artist != null
          ? Text(
              video.artist!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
              overflow: TextOverflow.ellipsis,
            )
          : null,
    );
  }
}

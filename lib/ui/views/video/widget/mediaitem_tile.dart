import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';
import 'package:my_tube/ui/views/common/spectrum_playing_icon.dart';
import 'package:my_tube/utils/utils.dart';

class MediaitemTile extends StatelessWidget {
  const MediaitemTile(
      {super.key, required this.mediaItem, this.darkBackground = false});

  final MediaItem mediaItem;
  final bool darkBackground;

  @override
  Widget build(BuildContext context) {
    final PlayerCubit playerCubit = BlocProvider.of<PlayerCubit>(context);
    return Dismissible(
        key: Key(mediaItem.id),
        direction: DismissDirection.startToEnd,
        onDismissed: (direction) {
          playerCubit.removeFromQueue(mediaItem.id).then((value) {
            if (value == false && context.mounted) {
              context.pop();
            }
          });
        },
        background: const DismissibleBackgroud(),
        child: ListTile(
          leading: SizedBox(
            width: 110,
            height: 70,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Utils.buildImageWithFallback(
                    thumbnailUrl: mediaItem.artUri?.toString(),
                    context: context,
                    fit: BoxFit.cover,
                    placeholder: Container(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: const Center(child: FlutterLogo()),
                    ),
                  ),

                  // subtle dark gradient
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

                  // overlay when selected
                  StreamBuilder(
                      stream: playerCubit.mtPlayerService.mediaItem,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final currentVideoId = snapshot.data!.id;
                          if (currentVideoId == mediaItem.id) {
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

                  // center spectrum icon
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 36,
                        height: 36,
                        child: SpectrumPlayingIcon(videoId: mediaItem.id),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          title: Text(
            mediaItem.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: darkBackground
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            mediaItem.album ?? '',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: darkBackground
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ));
  }
}

class DismissibleBackgroud extends StatelessWidget {
  const DismissibleBackgroud({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.error,
      child: Row(
        children: [
          Icon(
            Icons.delete,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          const SizedBox(
            width: 8,
          ),
          Text(
            'Remove from queue',
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          )
        ],
      ),
    );
  }
}

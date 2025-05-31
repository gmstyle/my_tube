import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';
import 'package:my_tube/ui/views/common/spectrum_playing_icon.dart';

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
            width: 90,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  mediaItem.artUri != null
                      ? CachedNetworkImage(
                          imageUrl: mediaItem.artUri!.toString(),
                          height: MediaQuery.of(context).size.height * 0.09,
                          width: MediaQuery.of(context).size.width * 0.2,
                          fit: BoxFit.cover,
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: const SizedBox(
                            child: FlutterLogo(),
                          ),
                        ),
                  // overlay gradient per video selected
                  StreamBuilder(
                      stream: playerCubit.mtPlayerService.mediaItem,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final currentVideoId = snapshot.data!.id;
                          if (currentVideoId == mediaItem.id) {
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.3),
                                    Colors.black.withValues(alpha: 0.5),
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
                    top: 0,
                    bottom: 0,
                    right: 0,
                    left: 0,
                    child: Center(
                      child: SpectrumPlayingIcon(videoId: mediaItem.id),
                    ),
                  )
                ],
              ),
            ),
          ),
          title: Text(
            mediaItem.title,
            style: TextStyle(
              color: darkBackground
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
          ),
          subtitle: Text(
            mediaItem.album ?? '',
            style: TextStyle(
                color: darkBackground
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurface),
          ),
          trailing: const Icon(
            Icons.drag_handle,
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

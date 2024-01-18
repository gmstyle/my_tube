import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:my_tube/blocs/home/mini_player_cubit/mini_player_cubit.dart';
import 'package:my_tube/ui/views/common/audio_spectrum_icon.dart';

class MediaitemTile extends StatelessWidget {
  const MediaitemTile({super.key, required this.mediaItem});

  final MediaItem mediaItem;

  @override
  Widget build(BuildContext context) {
    final MiniPlayerCubit miniPlayerCubit =
        BlocProvider.of<MiniPlayerCubit>(context);
    return Dismissible(
      key: Key(mediaItem.id),
      direction: DismissDirection.horizontal,
      onDismissed: (direction) {
        //TODO: da gestire meglio
        miniPlayerCubit.removeFromQueue(mediaItem.id).then((value) {
          if (value == false) {
            context.pop();
          }
        });
      },
      background: const DismissibleBackgroud(),
      child: Container(
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
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          mediaItem.artUri != null
                              ? Image.network(
                                  mediaItem.artUri!.toString(),
                                  height:
                                      MediaQuery.of(context).size.height * 0.09,
                                  width:
                                      MediaQuery.of(context).size.width * 0.2,
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
                          mediaItem.title,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 2,
                        ),
                        Text(mediaItem.album ?? '',
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  // icon to show that list is reorderable
                  const Icon(
                    Icons.drag_handle,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                ],
              ),
              StreamBuilder(
                  stream: miniPlayerCubit.mtPlayerService.mediaItem,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final currentVideoId = snapshot.data!.id;
                      if (currentVideoId == mediaItem.id) {
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
                        stream: miniPlayerCubit.mtPlayerService.mediaItem,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final currentVideoId = snapshot.data!.id;
                            if (currentVideoId == mediaItem.id) {
                              return StreamBuilder(
                                  stream: miniPlayerCubit
                                      .mtPlayerService.playbackState
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
      ),
    );
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
      child: const Row(
        children: [
          Icon(
            Icons.delete,
            color: Colors.white,
          ),
          SizedBox(
            width: 8,
          ),
          Text(
            'Remove from queue',
            style: TextStyle(color: Colors.white),
          )
        ],
      ),
    );
  }
}

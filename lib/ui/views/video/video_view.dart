import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_video_bloc.dart';
import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/services/download_service.dart';
import 'package:my_tube/services/mt_player_service.dart';
import 'package:my_tube/ui/views/common/custom_appbar.dart';
import 'package:my_tube/ui/views/common/main_gradient.dart';
import 'package:my_tube/ui/views/video/screens/video_phone_screen.dart';
import 'package:my_tube/ui/views/video/screens/video_tablet_screen.dart';
import 'package:my_tube/ui/views/video/widget/queue_draggable_sheet/clear_queue_button.dart';
import 'package:my_tube/ui/views/video/widget/queue_draggable_sheet/queue_draggable_sheet.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

final scaffoldKey = GlobalKey<ScaffoldState>();

class VideoView extends StatefulWidget {
  const VideoView({
    super.key,
  });

  @override
  State<VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  late final PlayerCubit playerCubit;
  late final MtPlayerService mtPlayerService;
  late final DownloadService downloadService;

  double _setAspectRatio(MtPlayerService mtPlayerService) {
    return mtPlayerService
                .chewieController!.videoPlayerController.value.aspectRatio <=
            1
        ? 1.5
        : mtPlayerService
            .chewieController!.videoPlayerController.value.aspectRatio;
  }

  @override
  void initState() {
    super.initState();
    playerCubit = context.read<PlayerCubit>();
    mtPlayerService = playerCubit.mtPlayerService;
    downloadService = context.read<DownloadService>();

    mtPlayerService.chewieController?.videoPlayerController.addListener(() {
      WakelockPlus.toggle(
          enable: mtPlayerService.chewieController!.isFullScreen);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainGradient(
      child: StreamBuilder(
          stream: mtPlayerService.mediaItem,
          builder: (context, snapshot) {
            final mediaItem = snapshot.data;
            return Scaffold(
              key: scaffoldKey,
              appBar: CustomAppbar(
                centerTitle: true,
                title: queueDraggableController.isAttached
                    ? ListenableBuilder(
                        listenable: queueDraggableController,
                        builder: (context, child) {
                          if (queueDraggableController.size == maxChildSize) {
                            return child!;
                          } else {
                            return const SizedBox();
                          }
                        },
                        child: const Icon(Icons.queue_music),
                      )
                    : null,
                leading: queueDraggableController.isAttached
                    ? ListenableBuilder(
                        listenable: queueDraggableController,
                        builder: (context, child) {
                          if (queueDraggableController.size == maxChildSize) {
                            return child!;
                          } else {
                            if (context.canPop()) {
                              return IconButton(
                                icon: const Icon(Icons.keyboard_arrow_down),
                                color: Theme.of(context).colorScheme.onPrimary,
                                onPressed: () {
                                  context.pop();
                                },
                              );
                            } else {
                              return const SizedBox();
                            }
                          }
                        },
                        child: IconButton(
                          icon: const Icon(Icons.keyboard_arrow_down),
                          color: Theme.of(context).colorScheme.onPrimary,
                          onPressed: () {
                            queueDraggableController.animateTo(
                              minChildSize,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          },
                        ),
                      )
                    : null,
                actions: [
                  queueDraggableController.isAttached
                      ? ListenableBuilder(
                          listenable: queueDraggableController,
                          builder: (context, child) {
                            if (queueDraggableController.size == maxChildSize) {
                              return child!;
                            } else {
                              return Wrap(
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                content: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    // show the option to download the video
                                                    ListTile(
                                                      leading: const Icon(
                                                          Icons.download),
                                                      title: const Text(
                                                          'Download'),
                                                      onTap: () {
                                                        downloadService
                                                            .download(videos: [
                                                          ResourceMT
                                                              .fromMediaItem(
                                                                  mediaItem!)
                                                        ], context: context);
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),

                                                    // show the option to download the audio only
                                                    ListTile(
                                                      leading: const Icon(
                                                          Icons.music_note),
                                                      title: const Text(
                                                          'Download audio only'),
                                                      onTap: () {
                                                        downloadService
                                                            .download(
                                                                videos: [
                                                              ResourceMT
                                                                  .fromMediaItem(
                                                                      mediaItem!)
                                                            ],
                                                                context:
                                                                    context,
                                                                isAudioOnly:
                                                                    true);
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              );
                                            });
                                      },
                                      icon: const Icon(Icons.download)),
                                  BlocBuilder<FavoritesVideoBloc,
                                      FavoritesVideoState>(
                                    builder: (context, state) {
                                      final favoritesVideoBloc =
                                          BlocProvider.of<FavoritesVideoBloc>(
                                              context);
                                      return IconButton(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                          onPressed: () {
                                            if (favoritesVideoBloc
                                                .favoritesRepository.videoIds
                                                .contains(mediaItem?.id)) {
                                              favoritesVideoBloc
                                                  .add(RemoveFromFavorites(
                                                mediaItem!.id,
                                              ));
                                            } else {
                                              favoritesVideoBloc
                                                  .add(AddToFavorites(
                                                ResourceMT.fromMediaItem(
                                                    mediaItem!),
                                              ));
                                            }
                                          },
                                          icon: favoritesVideoBloc
                                                  .favoritesRepository.videoIds
                                                  .contains(mediaItem?.id)
                                              ? const Icon(Icons.favorite)
                                              : const Icon(
                                                  Icons.favorite_border));
                                    },
                                  ),
                                ],
                              );
                            }
                          },
                          child: const ClearQueueButton())
                      : const SizedBox(),
                ],
              ),
              backgroundColor: Colors.transparent,
              body: LayoutBuilder(builder: (context, constraints) {
                bool isTablet = constraints.maxWidth > 600;
                if (isTablet) {
                  return VideoTabletScreen(
                    mtPlayerService: mtPlayerService,
                    aspectRatio: _setAspectRatio(mtPlayerService),
                    mediaItem: mediaItem,
                  );
                } else {
                  return VideoPhoneScreen(
                    mtPlayerService: mtPlayerService,
                    aspectRatio: _setAspectRatio(mtPlayerService),
                    mediaItem: mediaItem,
                  );
                }
              }),
            );
          }),
    );
  }
}

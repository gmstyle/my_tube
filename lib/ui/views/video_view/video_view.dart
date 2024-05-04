import 'dart:developer';

import 'package:autorotation_check/autorotation_check.dart';
import 'package:chewie/chewie.dart';
import 'package:device_orientation/device_orientation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_video_bloc.dart';
import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/services/download_service.dart';
import 'package:my_tube/services/mt_player_service.dart';
import 'package:my_tube/ui/views/common/custom_appbar.dart';
import 'package:my_tube/ui/views/common/expandable_text.dart';
import 'package:my_tube/ui/views/common/horizontal_swipe_to_skip.dart';
import 'package:my_tube/ui/views/common/main_gradient.dart';
import 'package:my_tube/ui/views/common/seek_bar.dart';
import 'package:my_tube/ui/views/video_view/widget/controls.dart';
import 'package:my_tube/ui/views/video_view/widget/queue_draggable_sheet/clear_queue_button.dart';
import 'package:my_tube/ui/views/video_view/widget/queue_draggable_sheet/queue_draggable_sheet.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

final scaffoldKey = GlobalKey<ScaffoldState>();

class VideoView extends StatelessWidget {
  const VideoView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final playerCubit = context.read<PlayerCubit>();
    final mtPlayerService = playerCubit.mtPlayerService;
    final downloadService = context.read<DownloadService>();

    mtPlayerService.chewieController?.videoPlayerController.addListener(() {
      WakelockPlus.toggle(
          enable: mtPlayerService.chewieController!.isFullScreen);
    });

    _enterFullScreenOnOrientation(mtPlayerService);

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
              body: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        HorizontalSwipeToSkip(
                          child: Hero(
                            tag: 'video_image_or_player',
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight:
                                      MediaQuery.of(context).size.height * 0.4,
                                ),
                                child: AspectRatio(
                                    aspectRatio:
                                        _setAspectRatio(mtPlayerService),
                                    child: PopScope(
                                      onPopInvoked: (didPop) async {
                                        if (didPop) {
                                          log('pop invoked');
                                          await SystemChrome
                                              .setPreferredOrientations(
                                                  DeviceOrientation.values);
                                        }
                                      },
                                      child: Chewie(
                                          controller: mtPlayerService
                                              .chewieController!),
                                    )),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                mediaItem?.title ?? '',
                                maxLines: 2,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(mediaItem?.album ?? '',
                                          maxLines: 2,
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                          )),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 8,
                                ),

                                // Seek bar
                                const SeekBar(
                                  darkBackground: true,
                                ),
                                // controls
                                const Controls(),

                                // description
                                if (mediaItem?.extras!['description'] != null &&
                                    mediaItem?.extras!['description'] != '')
                                  ExpandableText(
                                    title: 'Description',
                                    text:
                                        mediaItem?.extras!['description'] ?? '',
                                  ),
                                const SizedBox(
                                  height: 8,
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const QueueDraggableSheet()
                ],
              ),
            );
          }),
    );
  }

  void _enterFullScreenOnOrientation(MtPlayerService mtPlayerService) {
    final autorotationCheck = AutorotationCheck();
    deviceOrientation$.listen((event) async {
      final bool isPortrait = (event == DeviceOrientation.portraitUp ||
          event == DeviceOrientation.portraitDown);
      final bool isLandscape = (event == DeviceOrientation.landscapeLeft ||
          event == DeviceOrientation.landscapeRight);
      final isAutorotationEnabled =
          await autorotationCheck.isAutorotationEnabled() ?? false;
      const duration = Duration(milliseconds: 500);

      if (isAutorotationEnabled) {
        final isFullScreen = mtPlayerService.chewieController!.isFullScreen;
        if (isPortrait && isFullScreen && !_isQueueDraggableSheetOpen) {
          await Future.delayed(duration);
          if (isFullScreen) {
            mtPlayerService.chewieController!.exitFullScreen();
            SystemChrome.setPreferredOrientations(DeviceOrientation.values);
          }
        } else if (isLandscape &&
            !isFullScreen &&
            !_isQueueDraggableSheetOpen) {
          await Future.delayed(duration);
          if (!isFullScreen) {
            mtPlayerService.chewieController!.enterFullScreen();
            SystemChrome.setPreferredOrientations(DeviceOrientation.values);
          }
        }
      }
    });
  }

  double _setAspectRatio(MtPlayerService mtPlayerService) {
    return mtPlayerService
                .chewieController!.videoPlayerController.value.aspectRatio <=
            1
        ? 1
        : mtPlayerService
            .chewieController!.videoPlayerController.value.aspectRatio;
  }

  bool get _isQueueDraggableSheetOpen =>
      queueDraggableController.isAttached &&
      queueDraggableController.size == maxChildSize;
}

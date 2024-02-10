import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_bloc.dart';
import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/services/download_service.dart';
import 'package:my_tube/services/mt_player_service.dart';
import 'package:my_tube/ui/views/common/custom_appbar.dart';
import 'package:my_tube/ui/views/common/expandable_text.dart';
import 'package:my_tube/ui/views/common/horizontal_swipe_to_skip.dart';
import 'package:my_tube/ui/views/common/main_gradient.dart';
import 'package:my_tube/ui/views/common/seek_bar.dart';
import 'package:my_tube/ui/views/common/video_menu_dialog.dart';
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
                                                      onTap: () async {
                                                        downloadService.download(
                                                            video: ResourceMT
                                                                .fromMediaItem(
                                                                    mediaItem!),
                                                            context: context,
                                                            isAudioOnly: false);
                                                      },
                                                    ),

                                                    // show the option to download the audio only
                                                    ListTile(
                                                      leading: const Icon(
                                                          Icons.music_note),
                                                      title: const Text(
                                                          'Download audio only'),
                                                      onTap: () {
                                                        downloadService.download(
                                                            video: ResourceMT
                                                                .fromMediaItem(
                                                                    mediaItem!),
                                                            context: context,
                                                            isAudioOnly: true);
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              );
                                            });
                                      },
                                      icon: const Icon(Icons.download)),
                                  BlocBuilder<FavoritesBloc, FavoritesState>(
                                    builder: (context, state) {
                                      final favoritesBloc =
                                          BlocProvider.of<FavoritesBloc>(
                                              context);
                                      return IconButton(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                          onPressed: () {
                                            if (favoritesBloc
                                                .favoritesRepository.videoIds
                                                .contains(mediaItem?.id)) {
                                              favoritesBloc.add(
                                                  RemoveFromFavorites(
                                                      mediaItem!.id));
                                            } else {
                                              favoritesBloc.add(AddToFavorites(
                                                  ResourceMT.fromMediaItem(
                                                      mediaItem!)));
                                            }
                                          },
                                          icon: favoritesBloc
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
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          HorizontalSwipeToSkip(
                            child: Hero(
                              tag: 'video_image_or_player',
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: AspectRatio(
                                    aspectRatio:
                                        _setAspectRatio(mtPlayerService),
                                    child: Chewie(
                                        controller:
                                            mtPlayerService.chewieController!)),
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
                              text: mediaItem?.extras!['description'] ?? '',
                            )
                        ],
                      ),
                    ),
                  ),
                  const QueueDraggableSheet()
                ],
              ),
            );
          }),
    );
  }

  double _setAspectRatio(MtPlayerService mtPlayerService) {
    return mtPlayerService
                .chewieController!.videoPlayerController.value.aspectRatio <=
            1
        ? 1
        : mtPlayerService
            .chewieController!.videoPlayerController.value.aspectRatio;
  }
}

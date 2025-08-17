import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/channel_page/channel_page_bloc.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_channel/favorites_channel_bloc.dart';
import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';
import 'package:my_tube/ui/skeletons/custom_skeletons.dart';
import 'package:my_tube/ui/views/channel/widgets/channel_header.dart';
import 'package:my_tube/ui/views/common/custom_appbar.dart';
import 'package:my_tube/ui/views/common/main_gradient.dart';
import 'package:my_tube/ui/views/common/play_pause_gesture_detector.dart';
import 'package:my_tube/ui/views/common/video_menu_dialog.dart';
import 'package:my_tube/ui/views/common/video_tile.dart';
import 'package:my_tube/models/tiles.dart' as models;

import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class ChannelView extends StatelessWidget {
  const ChannelView({super.key, required this.channelId});

  final String channelId;

  @override
  Widget build(BuildContext context) {
    final miniplayerCubit = context.read<PlayerCubit>();

    return MainGradient(
      child: Scaffold(
        appBar: CustomAppbar(
          showTitle: false,
          actions: [
            BlocBuilder<ChannelPageBloc, ChannelPageState>(
                builder: (context, state) {
              if (state.status == ChannelPageStatus.loaded) {
                return BlocBuilder<FavoritesChannelBloc, FavoritesChannelState>(
                    builder: (context, state) {
                  final favoriteChannelsBloc =
                      context.read<FavoritesChannelBloc>();
                  return IconButton(
                      color: Theme.of(context).colorScheme.onPrimary,
                      onPressed: () {
                        if (favoriteChannelsBloc.favoritesRepository.channelIds
                            .contains(channelId)) {
                          favoriteChannelsBloc
                              .add(RemoveFromFavoritesChannel(channelId));
                        } else {
                          favoriteChannelsBloc
                              .add(AddToFavoritesChannel(channelId));
                        }
                      },
                      icon: favoriteChannelsBloc.favoritesRepository.channelIds
                              .contains(channelId)
                          ? const Icon(Icons.favorite)
                          : const Icon(Icons.favorite_border));
                });
              }
              return const SizedBox.shrink();
            })
          ],
        ),
        backgroundColor: Colors.transparent,
        body: BlocBuilder<ChannelPageBloc, ChannelPageState>(
          builder: (context, state) {
            switch (state.status) {
              case ChannelPageStatus.loading:
                return const CustomSkeletonChannel();

              case ChannelPageStatus.loaded:
                final channel = state.data?['channel'] as Channel;
                final rawItems = state.items;
                final videos = rawItems != null
                    ? List<models.VideoTile>.from(
                        rawItems.map((e) => e as models.VideoTile))
                    : <models.VideoTile>[];
                final ids = videos.map((video) => video.id).toList();
                if (videos.isNotEmpty) {
                  return NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification.metrics.axis == Axis.vertical) {
                        final maxScroll = notification.metrics.maxScrollExtent;
                        final current = notification.metrics.pixels;
                        if (maxScroll - current < 300) {
                          context
                              .read<ChannelPageBloc>()
                              .add(const LoadMoreChannelVideos());
                        }
                      }
                      return false;
                    },
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(child: ChannelHeader(channel: channel)),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Row(
                                  children: [
                                    // add to queue
                                    IconButton(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                        onPressed: ids.isNotEmpty
                                            ? () {
                                                miniplayerCubit
                                                    .addAllToQueue(ids);
                                              }
                                            : null,
                                        icon: const Icon(Icons.queue_music)),
                                    IconButton(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                        onPressed: ids.isNotEmpty
                                            ? () {
                                                miniplayerCubit
                                                    .startPlayingPlaylist(ids);
                                              }
                                            : null,
                                        icon: const Icon(Icons.playlist_play)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              if (index >= videos.length) {
                                return const _ListLoader();
                              }
                              final video = videos[index];
                              final quickVideo = {
                                'id': video.id,
                                'title': video.title,
                              };
                              return PlayPauseGestureDetector(
                                  id: video.id,
                                  child: VideoMenuDialog(
                                      quickVideo: quickVideo,
                                      child: VideoTile(video: video)));
                            },
                            childCount:
                                videos.length + (state.isLoadingMore ? 1 : 0),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return const Center(
                    child: Text('No videos available'),
                  );
                }

              case ChannelPageStatus.failure:
                return Center(
                  child: Text(state.error!),
                );

              default:
                return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}

class _ListLoader extends StatelessWidget {
  const _ListLoader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.onPrimary,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        ),
      ),
    );
  }
}

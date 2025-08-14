import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/channel_page/channel_page_bloc.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_channel/favorites_channel_bloc.dart';
import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';
import 'package:my_tube/ui/skeletons/custom_skeletons.dart';
import 'package:my_tube/ui/views/channel/widgets/channel_header.dart';
import 'package:my_tube/ui/views/common/custom_appbar.dart';
import 'package:my_tube/ui/views/common/main_gradient.dart';
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
                final channel = state.data?['channel'] as ChannelAbout;
                final videos = state.data?['videos'] as List<models.VideoTile>?;
                final ids = videos?.map((video) => video.id).toList();
                if (videos != null && videos.isNotEmpty) {
                  return SingleChildScrollView(
                      child: Column(
                    children: [
                      ChannelHeader(channel: channel),
                      Row(
                        children: [
                          // add to queue
                          IconButton(
                              color: Theme.of(context).colorScheme.onPrimary,
                              onPressed: ids != null
                                  ? () {
                                      miniplayerCubit.addAllToQueue(ids);
                                    }
                                  : null,
                              icon: const Icon(Icons.queue_music)),
                          IconButton(
                              color: Theme.of(context).colorScheme.onPrimary,
                              onPressed: ids != null
                                  ? () {
                                      miniplayerCubit.startPlayingPlaylist(ids);
                                    }
                                  : null,
                              icon: const Icon(Icons.playlist_play)),
                        ],
                      ),
                      Expanded(
                          child: ListView.builder(
                              itemCount: videos.length,
                              itemBuilder: (context, index) {
                                final video = videos[index];
                                return VideoTile(video: video);
                              }))
                    ],
                  ));
                } else {
                  return const Center(
                    child: Text('No videos available'),
                  );
                }
              /* return SingleChildScrollView(
                  child: Column(
                    children: [
                      ChannelHeader(channel: channel),
                      const SizedBox(height: 8),
                      // sections
                      for (final section in channel!.sections!)
                        Column(
                          children: [
                            if (section.title != null &&
                                    section.title!.isNotEmpty &&
                                    section.videos != null &&
                                    section.videos!.isNotEmpty ||
                                section.playlists != null &&
                                    section.playlists!.isNotEmpty ||
                                section.channels != null &&
                                    section.channels!.isNotEmpty)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      section.title ?? '',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (section.videos != null &&
                                      section.videos!.isNotEmpty)
                                    Row(
                                      children: [
                                        // add to queue
                                        IconButton(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                            onPressed: () {
                                              miniplayerCubit.addAllToQueue(
                                                  section.videos!);
                                            },
                                            icon:
                                                const Icon(Icons.queue_music)),
                                        IconButton(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                            onPressed: () {
                                              miniplayerCubit
                                                  .startPlayingPlaylist(
                                                      section.videos!);
                                            },
                                            icon: const Icon(
                                                Icons.playlist_play)),
                                      ],
                                    )
                                ],
                              ),
                            const SizedBox(height: 8),
                            if (section.videos != null &&
                                section.videos!.isNotEmpty)
                              
                            if (section.playlists != null &&
                                section.playlists!.isNotEmpty)
                              PlaylistSection(playlists: section.playlists!),
                            if (section.channels != null &&
                                section.channels!.isNotEmpty)
                              FeaturedChannelsSection(
                                  channels: section.channels!),
                            const SizedBox(height: 8),
                          ],
                        )
                    ],
                  ),
                ); */

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

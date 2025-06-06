import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/channel_page/channel_page_bloc.dart';
import 'package:my_tube/blocs/home/favorites_tab/favorites_channel/favorites_channel_bloc.dart';
import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/ui/skeletons/custom_skeletons.dart';
import 'package:my_tube/ui/views/channel/widgets/channel_header.dart';
import 'package:my_tube/ui/views/common/custom_appbar.dart';
import 'package:my_tube/ui/views/common/main_gradient.dart';
import 'package:my_tube/ui/views/home/tabs/music_tab/widgets/featured_channels_section.dart';
import 'package:my_tube/ui/views/home/tabs/music_tab/widgets/playlist_section.dart';
import 'package:my_tube/ui/views/home/tabs/music_tab/widgets/video_section.dart';
import 'package:my_tube/utils/enums.dart';

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
                final channel = state.channel;
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
                              .add(AddToFavoritesChannel(ResourceMT(
                            id: channelId,
                            title: channel!.title,
                            description: channel.description,
                            channelTitle: channel.title,
                            thumbnailUrl: channel.avatarUrl,
                            kind: Kind.channel.name,
                            channelId: channelId,
                            playlistId: null,
                            duration: null,
                            streamUrl: null,
                            videoCount: channel.videoCount,
                            subscriberCount: channel.subscriberCount,
                          )));
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
                final channel = state.channel;
                return SingleChildScrollView(
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
                              VideoSection(
                                videos: section.videos!,
                                crossAxisCount: 2,
                              ),
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
                );

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

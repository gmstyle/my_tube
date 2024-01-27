import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/channel_page/channel_page_bloc.dart';
import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';
import 'package:my_tube/ui/skeletons/skeleton_channel.dart';
import 'package:my_tube/ui/views/channel/widgets/channel_header.dart';
import 'package:my_tube/ui/views/common/custom_appbar.dart';
import 'package:my_tube/ui/views/common/main_gradient.dart';
import 'package:my_tube/ui/views/home/tabs/music_tab/widgets/featured_channels_section.dart';
import 'package:my_tube/ui/views/home/tabs/music_tab/widgets/playlist_section.dart';
import 'package:my_tube/ui/views/home/tabs/music_tab/widgets/video_section.dart';

class ChannelView extends StatelessWidget {
  const ChannelView({super.key, required this.channelId});

  final String channelId;

  @override
  Widget build(BuildContext context) {
    final miniplayerCubit = context.read<PlayerCubit>();

    return MainGradient(
      child: Scaffold(
        appBar: const CustomAppbar(
          showTitle: false,
        ),
        backgroundColor: Colors.transparent,
        body: BlocBuilder<ChannelPageBloc, ChannelPageState>(
          builder: (context, state) {
            switch (state.status) {
              case ChannelPageStatus.loading:
                return const SkeletonChannel();

              case ChannelPageStatus.loaded:
                final channel = state.channel;
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                    ),
                    child: Column(
                      children: [
                        ChannelHeader(channel: channel),
                        const SizedBox(height: 8),
                        // sections
                        for (final section in channel!.sections!)
                          Column(
                            children: [
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/channel_page/channel_page_bloc.dart';
import 'package:my_tube/respositories/innertube_repository.dart';
import 'package:my_tube/ui/views/channel/widgets/channel_header.dart';
import 'package:my_tube/ui/views/common/main_gradient.dart';
import 'package:my_tube/ui/views/home/tabs/music_tab/widgets/playlist_section.dart';
import 'package:my_tube/ui/views/home/tabs/music_tab/widgets/video_section.dart';

class ChannelView extends StatelessWidget {
  const ChannelView({super.key, required this.channelId});

  final String channelId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ChannelPageBloc>(
      create: (context) => ChannelPageBloc(
          innertubeRepository: context.read<InnertubeRepository>())
        ..add(
          GetChannelDetails(channelId: channelId),
        ),
      child: MainGradient(
        child: SizedBox(
          height: MediaQuery.of(context).size.height - kToolbarHeight,
          child: BlocBuilder<ChannelPageBloc, ChannelPageState>(
            builder: (context, state) {
              switch (state.status) {
                case ChannelPageStatus.loading:
                  return const Center(child: CircularProgressIndicator());

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
                                if (section.title != null)
                                  const SizedBox(height: 8),
                                Container(
                                  margin: const EdgeInsets.only(
                                    bottom: 8,
                                  ),
                                  child: SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.25,
                                    width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            const SizedBox(width: 16),
                                            Text(
                                              section.title ?? '',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineSmall
                                                  ?.copyWith(
                                                    color: Colors.white,
                                                  ),
                                            ),
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
                                          PlaylistSection(
                                              playlists: section.playlists!),
                                      ],
                                    ),
                                  ),
                                ),
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
      ),
    );
  }
}

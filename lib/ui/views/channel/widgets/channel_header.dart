import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/channel_page/channel_page_bloc.dart';
import 'package:my_tube/blocs/home/mini_player_cubit/mini_player_cubit.dart';
import 'package:my_tube/models/channel_page_mt.dart';
import 'package:my_tube/ui/views/common/expandable_text.dart';

class ChannelHeader extends StatelessWidget {
  const ChannelHeader({super.key, required this.channel});

  final ChannelPageMT? channel;

  @override
  Widget build(BuildContext context) {
    final miniplayerCubit = context.read<MiniPlayerCubit>();
    final channelState = context.watch<ChannelPageBloc>().state;
    return Column(
      children: [
        // Actions
        /* Row(
          children: [
            IconButton(
              onPressed: () {
                context.pop();
              },
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_vert, color: Colors.white),
            ),
          ],
        ), */

        // Channel info
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.25,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  channel!.tvBannerUrl!,
                  fit: BoxFit.cover,
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Positioned(
                  left: 8,
                  right: 8,
                  bottom: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(channel!.title!,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    )),
                          ),
                        ],
                      ),
                      if (channel!.channelHandleText != null)
                        Row(
                          children: [
                            Text(
                              '${channel!.channelHandleText}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                      const SizedBox(height: 4),
                      /* Row(
                        children: [
                          const Icon(
                            Icons.music_note_rounded,
                            color: Colors.white,
                          ),
                          Text(
                            ' Tracks: ${channel!.videos?.length}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ), */
                      const SizedBox(width: 4),
                      if (channel!.subscriberCount != null)
                        Row(
                          children: [
                            const Icon(
                              Icons.remove_red_eye,
                              color: Colors.white,
                            ),
                            Text(
                              ' Subscribers: ${channel!.subscriberCount!}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                /* Positioned(
                    right: 16,
                    bottom: 16,
                    child: FloatingActionButton.small(
                        backgroundColor: Colors.white,
                        onPressed:
                            channelState.status == ChannelPageStatus.loaded
                                ? () {
                                    /* miniplayerCubit.startPlayingPlaylist(
                                        channelState.channel!.videoIds!); */
                                  }
                                : null,
                        child: const Icon(Icons.playlist_play))) */
              ],
            ),
          ),
        ),

        // Description
        if (channel!.description != null) ...[
          const SizedBox(height: 8),
          ExpandableText(text: channel!.description ?? '')
        ],
      ],
    );
  }
}

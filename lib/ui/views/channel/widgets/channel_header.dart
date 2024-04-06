import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:my_tube/models/channel_page_mt.dart';
import 'package:my_tube/ui/views/common/expandable_text.dart';

class ChannelHeader extends StatelessWidget {
  const ChannelHeader({super.key, required this.channel});

  final ChannelPageMT? channel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Channel info
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.25,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                    imageUrl: _setChannelBanner(channel!),
                    fit: BoxFit.fill,
                    errorWidget: (context, url, error) => const FlutterLogo()),
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
                            child: Text(channel!.title ?? '',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
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
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary),
                            ),
                          ],
                        ),
                      const SizedBox(height: 4),
                      /* Row(
                        children: [
                          const Icon(
                            Icons.music_note_rounded,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                          Text(
                            ' Tracks: ${channel!.videos?.length}',
                            style: const TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                          ),
                        ],
                      ), */
                      const SizedBox(width: 4),
                      if (channel!.subscriberCount != null)
                        Row(
                          children: [
                            Icon(
                              Icons.remove_red_eye,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                            Text(
                              ' Subscribers: ${channel!.subscriberCount!}',
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Description
        if (channel!.description != null && channel!.description != '') ...[
          const SizedBox(height: 8),
          ExpandableText(title: 'Description', text: channel!.description ?? '')
        ],
      ],
    );
  }

  String _setChannelBanner(ChannelPageMT channelPageMT) {
    if (channelPageMT.tvBannerUrl != null &&
        channelPageMT.tvBannerUrl!.isNotEmpty) {
      return channelPageMT.tvBannerUrl!;
    } else if (channelPageMT.bannerUrl != null &&
        channelPageMT.bannerUrl!.isNotEmpty) {
      return channelPageMT.bannerUrl!;
    } else {
      return channelPageMT.avatarUrl!;
    }
  }
}

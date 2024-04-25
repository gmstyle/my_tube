import 'dart:convert';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/utils/utils.dart';

class ChannelTile extends StatelessWidget {
  const ChannelTile({super.key, required this.channel});

  final ResourceMT channel;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.03),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ClipOval(
            child: channel.thumbnailUrl != null
                ? CachedNetworkImage(
                    imageUrl: channel.thumbnailUrl!,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) {
                      // show base64 image if error
                      final Uint8List? bytes = channel.base64Thumbnail != null
                          ? base64Decode(channel.base64Thumbnail!)
                          : null;
                      if (bytes != null) {
                        return Image.memory(
                          bytes,
                          fit: BoxFit.cover,
                        );
                      }
                      return const SizedBox();
                    })
                : ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: const SizedBox(child: FlutterLogo()),
                  ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  channel.channelTitle ?? '',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  channel.subscriberCount ?? '',
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  channel.videoCount != null &&
                          Utils.checkIfStringIsOnlyNumeric(channel.videoCount!)
                      ? '${channel.videoCount} videos'
                      : channel.videoCount ?? '',
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/utils/utils.dart';

class ChannelTile extends StatelessWidget {
  const ChannelTile({super.key, required this.channel});

  final ResourceMT channel;

  // Helper method to build circular image from base64 data
  Widget _buildCircularImage(String? base64Image, BuildContext context) {
    if (base64Image != null) {
      try {
        final bytes = base64Decode(base64Image);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
        );
      } catch (e) {
        // If base64 decoding fails, return placeholder
        return Container(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            Icons.person,
            size: 24,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        );
      }
    } else {
      // No base64 data available, return placeholder
      return Container(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(
          Icons.person,
          size: 24,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipOval(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: 48,
            minWidth: 48,
            maxHeight: 70,
            maxWidth: 70,
          ),
          child: channel.thumbnailUrl != null
              ? CachedNetworkImage(
                  imageUrl: channel.thumbnailUrl!,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) {
                    // show base64 image if error
                    return _buildCircularImage(
                        channel.base64Thumbnail, context);
                  },
                )
              : _buildCircularImage(channel.base64Thumbnail, context),
        ),
      ),
      title: Text(
        channel.channelTitle ?? '',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Text(
              channel.subscriberCount ?? '',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              channel.videoCount != null &&
                      Utils.checkIfStringIsOnlyNumeric(channel.videoCount!)
                  ? '${channel.videoCount} videos'
                  : channel.videoCount ?? '',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    /* return Container(
      height: 100,
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.03),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          
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
    ); */
  }
}

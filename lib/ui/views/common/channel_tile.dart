import 'package:flutter/material.dart';
import 'package:my_tube/models/tiles.dart' as models;
import 'package:my_tube/utils/utils.dart';

class ChannelTile extends StatelessWidget {
  const ChannelTile({super.key, required this.channel});

  final models.ChannelTile channel;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Utils.buildImageWithFallback(
          thumbnailUrl: channel.thumbnailUrl,
          context: context,
          isCircular: true),
      title: Text(
        channel.title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (channel.description != null && channel.description!.isNotEmpty)
            Flexible(
              child: Text(
                channel.description!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (channel.subscriberCount != null)
            Flexible(
              child: Text(
                '${channel.subscriberCount} subscribers',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

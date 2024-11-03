import 'package:flutter/material.dart';
import 'package:my_tube/models/resource_mt.dart';

class ChannelGridItem extends StatelessWidget {
  const ChannelGridItem({super.key, required this.channel});

  final ResourceMT channel;

  @override
  Widget build(BuildContext context) {
    final double size = MediaQuery.of(context).size.width *
        0.4; // Dimensione per mantenere il widget circolare

    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          fit: StackFit.expand,
          children: [
            channel.thumbnailUrl != null
                ? Image.network(
                    channel.thumbnailUrl!,
                    fit: BoxFit.cover,
                  )
                : const SizedBox(),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                ),
              ),
            ),
            Positioned(
              top: 8,
              bottom: 8,
              left: 8,
              right: 8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      '${channel.title!}\n${channel.subscriberCount}\n${channel.videoCount}',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

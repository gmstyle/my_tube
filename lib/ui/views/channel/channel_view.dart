import 'package:flutter/material.dart';
import 'package:my_tube/providers/youtube_provider.dart';

class ChannelView extends StatelessWidget {
  const ChannelView({super.key, required this.channelId});

  final String channelId;

  @override
  Widget build(BuildContext context) {
    YoutubeProvider().getChannelDetails(channelId);
    return Scaffold(
      body: Column(
        children: [
          Row(
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.arrow_back)),
              const Text('Channel'),
            ],
          ),
          Center(
            child: Text('Channel: $channelId'),
          ),
        ],
      ),
    );
  }
}

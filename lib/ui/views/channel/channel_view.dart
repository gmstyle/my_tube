import 'package:flutter/material.dart';

class ChannelView extends StatelessWidget {
  const ChannelView({super.key, required this.channelId});

  final String channelId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Channel: $channelId'),
      ),
    );
  }
}

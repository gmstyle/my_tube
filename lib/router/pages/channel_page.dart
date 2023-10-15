import 'package:flutter/material.dart';
import 'package:my_tube/ui/views/channel/channel_view.dart';

class ChannelPage extends Page {
  const ChannelPage({super.key, required this.channelId});

  final String channelId;

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) => ChannelView(channelId: channelId),
    );
  }
}

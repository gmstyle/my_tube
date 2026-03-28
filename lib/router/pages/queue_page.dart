import 'package:flutter/material.dart';
import 'package:my_tube/ui/views/video/queue_view.dart';

class QueuePage extends Page {
  const QueuePage({
    super.key,
    this.showMiniPlayer = false,
    this.hideMiniPlayerOnDispose = false,
  });

  final bool showMiniPlayer;
  final bool hideMiniPlayerOnDispose;

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (context) => QueueView(
          showMiniPlayer: showMiniPlayer,
          hideMiniPlayerOnDispose: hideMiniPlayerOnDispose),
    );
  }
}

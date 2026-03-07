import 'package:flutter/material.dart';
import 'package:my_tube/ui/views/video/queue_view.dart';

class QueuePage extends Page {
  const QueuePage({super.key, this.restoreMiniPlayer = false});

  final bool restoreMiniPlayer;

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (context) => QueueView(restoreMiniPlayer: restoreMiniPlayer),
    );
  }
}

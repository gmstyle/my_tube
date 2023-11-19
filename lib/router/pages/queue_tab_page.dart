import 'package:flutter/material.dart';
import 'package:my_tube/ui/views/home/tabs/queue_tab_view.dart';

class QueueTabPage extends Page {
  const QueueTabPage({super.key});

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) {
        return const QueueTabView();
      },
    );
  }
}

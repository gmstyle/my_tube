import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:my_tube/services/mt_player_service.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class FullScreenVideoView extends StatefulWidget {
  const FullScreenVideoView({super.key, required this.mtPlayerService});

  final MtPlayerService mtPlayerService;

  @override
  State<FullScreenVideoView> createState() => _FullScreenVideoViewState();
}

class _FullScreenVideoViewState extends State<FullScreenVideoView> {
  late StreamSubscription _skipSubscription;
  @override
  void initState() {
    super.initState();

    // enable wakelock
    WakelockPlus.enabled;

    _skipSubscription = widget.mtPlayerService.onSkip.listen((_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    // disable wakelock
    WakelockPlus.disable;
    _skipSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.mtPlayerService.chewieController!
          .videoPlayerController.value.aspectRatio,
      child: Chewie(controller: widget.mtPlayerService.chewieController!),
    );
  }
}

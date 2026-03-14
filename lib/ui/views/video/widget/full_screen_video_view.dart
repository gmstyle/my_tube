import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_tube/services/player/mt_player_service.dart';

class FullScreenVideoView extends StatefulWidget {
  const FullScreenVideoView({super.key, required this.mtPlayerService});

  final MtPlayerService mtPlayerService;

  @override
  State<FullScreenVideoView> createState() => _FullScreenVideoViewState();
}

class _FullScreenVideoViewState extends State<FullScreenVideoView> {
  late StreamSubscription _skipSubscription;
  Orientation? _lastOrientation;

  @override
  void initState() {
    super.initState();
    // Chewie locks orientation to landscape on enterFullScreen().
    // Unlock all orientations so OrientationBuilder can detect portrait rotation.
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    _skipSubscription = widget.mtPlayerService.onSkip.listen((_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _skipSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.mtPlayerService.chewieController;

    return OrientationBuilder(builder: (context, orientation) {
      // Auto exit fullscreen when user rotates back to portrait
      if (orientation == Orientation.portrait &&
          _lastOrientation == Orientation.landscape &&
          (controller?.isFullScreen ?? false)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          widget.mtPlayerService.chewieController?.exitFullScreen();
        });
      }
      _lastOrientation = orientation;

      if (controller == null) {
        return const Scaffold(
          backgroundColor: Colors.black,
          body: Center(child: CircularProgressIndicator()),
        );
      }

      return Scaffold(
        backgroundColor: Colors.black,
        body: Chewie(controller: controller),
      );
    });
  }
}

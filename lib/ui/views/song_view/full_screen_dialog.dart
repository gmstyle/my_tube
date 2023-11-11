import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_tube/services/mt_player_handler.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class FullScreenVideoDialog extends StatefulWidget {
  const FullScreenVideoDialog({super.key, required this.mtPlayerHandler});

  final MtPlayerHandler mtPlayerHandler;

  @override
  State<FullScreenVideoDialog> createState() => _FullScreenVideoDialogState();
}

class _FullScreenVideoDialogState extends State<FullScreenVideoDialog> {
  @override
  void initState() {
    super.initState();

    // set the orientation to landscape
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // hide the status bar
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersive,
    );

    // enable wakelock
    WakelockPlus.enabled;

    widget.mtPlayerHandler.onSkip.listen((_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    // set the orientation back to portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    // show the status bar
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );

    // disable wakelock
    WakelockPlus.disable;

    widget.mtPlayerHandler.skipController.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: Colors.black,
      child: SafeArea(
          child: AspectRatio(
        aspectRatio: widget.mtPlayerHandler.chewieController
            .videoPlayerController.value.aspectRatio,
        child: Chewie(controller: widget.mtPlayerHandler.chewieController),
      )),
    );
  }
}

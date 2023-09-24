import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:googleapis/youtube/v3.dart';

class VideoPlayerView extends StatefulWidget {
  const VideoPlayerView(
      {super.key,
      required this.video,
      required this.streamUrl,
      required this.vlcPlayerController});

  final Video video;
  final String streamUrl;
  final VlcPlayerController vlcPlayerController;
  @override
  State<VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView>
    with TickerProviderStateMixin {
  late AnimationController scaleVideoAnimationController;
  Animation<double> scaleVideoAnimation =
      const AlwaysStoppedAnimation<double>(1.0);
  double? targetVideoScale;

  @override
  void initState() {
    super.initState();

    //forceLandscape();

    scaleVideoAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 125));
  }

  @override
  void dispose() {
    //forcePortrait();
    scaleVideoAnimationController.dispose();
    widget.vlcPlayerController.stopRendererScanning();
    widget.vlcPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final videoSize = widget.vlcPlayerController.value.size;
    if (videoSize.width > 0) {
      final newTargetScale = screenSize.width /
          (videoSize.width * screenSize.height / videoSize.height);
      setTargetNativeScale(newTargetScale);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Video in Full Screen'),
      ),
      body: Center(
        child: VlcPlayer(
          controller: widget.vlcPlayerController,
          aspectRatio: 16 / 9,
        ),
      ),
    );
  }

  void setTargetNativeScale(double newValue) {
    if (!newValue.isFinite) {
      return;
    }
    scaleVideoAnimation =
        Tween<double>(begin: 1.0, end: newValue).animate(CurvedAnimation(
      parent: scaleVideoAnimationController,
      curve: Curves.easeInOut,
    ));

    if (targetVideoScale == null) {
      scaleVideoAnimationController.forward();
    }
    targetVideoScale = newValue;
  }

  Future<void> forceLandscape() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  Future<void> forcePortrait() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values); // to re-show bars
  }
}

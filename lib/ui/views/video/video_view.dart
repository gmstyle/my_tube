import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';
import 'package:my_tube/services/player/mt_player_service.dart';
import 'package:my_tube/ui/views/video/screens/video_phone_screen.dart';
import 'package:my_tube/ui/views/video/screens/video_tablet_screen.dart';
import 'package:my_tube/blocs/persistent_ui/persistent_ui_cubit.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class VideoView extends StatefulWidget {
  const VideoView({
    super.key,
  });

  @override
  State<VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  late final PlayerCubit playerCubit;
  late final MtPlayerService mtPlayerService;
  late final PersistentUiCubit persistentUiCubit;
  late final StreamSubscription<PlaybackState> _playbackStateSubscription;
  Orientation? _lastOrientation;

  double get _aspectRatio {
    final ratio = mtPlayerService
        .chewieController?.videoPlayerController.value.aspectRatio;
    if (ratio == null || ratio <= 1) return 16 / 9;
    return ratio;
  }

  @override
  void initState() {
    super.initState();
    playerCubit = context.read<PlayerCubit>();
    mtPlayerService = playerCubit.mtPlayerService;
    persistentUiCubit = context.read<PersistentUiCubit>();

    // Keep screen on while playing, allow sleep when paused
    _playbackStateSubscription = mtPlayerService.playbackState.listen((state) {
      WakelockPlus.toggle(enable: state.playing);
    });
    // Apply initial state immediately
    WakelockPlus.toggle(enable: mtPlayerService.playbackState.value.playing);

    // Hide mini player when video view is open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      persistentUiCubit.setPlayerVisibility(false);
    });
  }

  @override
  void dispose() {
    _playbackStateSubscription.cancel();
    // Lock back to portrait
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    // Allow screen to sleep again
    WakelockPlus.toggle(enable: false);
    // Show mini player when video view is closed (fallback for non-pop dismissals)
    persistentUiCubit.setPlayerVisibility(true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      // Restore mini player visibility BEFORE the pop transition starts so the
      // Hero controller can find the destination Hero widget in GlobalMiniPlayer.
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) persistentUiCubit.setPlayerVisibility(true);
      },
      child: StreamBuilder(
        stream: mtPlayerService.mediaItem,
        builder: (context, snapshot) {
          final mediaItem = snapshot.data;
          return Scaffold(
            body: OrientationBuilder(builder: (context, orientation) {
              if (mtPlayerService.chewieController == null) {
                return const Center(child: CircularProgressIndicator());
              }

              // Use shortestSide so the tablet check is orientation-independent:
              // a phone in landscape has shortestSide ≈ 360dp, a tablet ≥ 600dp.
              final bool isTablet =
                  MediaQuery.of(context).size.shortestSide > 600;
              if (!isTablet &&
                  orientation == Orientation.landscape &&
                  _lastOrientation == Orientation.portrait &&
                  !(mtPlayerService.chewieController?.isFullScreen ?? true)) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  mtPlayerService.chewieController?.enterFullScreen();
                });
              }
              _lastOrientation = orientation;

              if (isTablet) {
                return VideoTabletScreen(
                  mtPlayerService: mtPlayerService,
                  aspectRatio: _aspectRatio,
                  mediaItem: mediaItem,
                );
              }
              return VideoPhoneScreen(
                mtPlayerService: mtPlayerService,
                aspectRatio: _aspectRatio,
                mediaItem: mediaItem,
              );
            }),
          );
        }),
    );
  }
}

import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/player_cubit/player_cubit.dart';
import 'package:my_tube/services/player/mt_player_service.dart';
import 'package:my_tube/ui/shared/responsive_layout_builder.dart';
import 'package:my_tube/ui/views/video/layouts/video_desktop_layout.dart';
import 'package:my_tube/ui/views/video/layouts/video_mobile_layout.dart';
import 'package:my_tube/ui/views/video/layouts/video_tablet_layout.dart';
import 'package:my_tube/blocs/persistent_ui/persistent_ui_cubit.dart';
import 'package:my_tube/ui/skeletons/custom_skeletons.dart';
import 'package:my_tube/utils/app_breakpoints.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class VideoView extends StatefulWidget {
  const VideoView({super.key});

  @override
  State<VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  late final PlayerCubit playerCubit;
  late final MtPlayerService mtPlayerService;
  late final PersistentUiCubit persistentUiCubit;
  late final StreamSubscription<PlaybackState> _playbackStateSubscription;

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
    WakelockPlus.toggle(enable: mtPlayerService.playbackState.value.playing);

    // Hide mini player when video view is open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      persistentUiCubit.setPlayerVisibility(false);
    });
  }

  @override
  void dispose() {
    _playbackStateSubscription.cancel();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    WakelockPlus.toggle(enable: false);
    persistentUiCubit.setPlayerVisibility(true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) persistentUiCubit.setPlayerVisibility(true);
      },
      child: StreamBuilder(
        stream: mtPlayerService.mediaItem,
        builder: (context, snapshot) {
          final mediaItem = snapshot.data;

          if (mediaItem == null || mtPlayerService.chewieController == null) {
            return const Scaffold(
              body: CustomSkeletonVideoView(),
            );
          }

          return Scaffold(
            body: ResponsiveLayoutBuilder(
              mobile: (_) => VideoMobileLayout(
                mtPlayerService: mtPlayerService,
                aspectRatio: _aspectRatio,
                mediaItem: mediaItem,
              ),
              tablet: (_) => VideoTabletLayout(
                mtPlayerService: mtPlayerService,
                aspectRatio: _aspectRatio,
                mediaItem: mediaItem,
              ),
              desktop: (_) => VideoDesktopLayout(
                mtPlayerService: mtPlayerService,
                aspectRatio: _aspectRatio,
                mediaItem: mediaItem,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Determines which responsive layout tier to use based on shortestSide.
/// This ensures the decision is orientation-independent.
class ResponsiveScaffold extends StatelessWidget {
  const ResponsiveScaffold({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  });

  final WidgetBuilder mobile;
  final WidgetBuilder? tablet;
  final WidgetBuilder? desktop;
  final WidgetBuilder? largeDesktop;

  @override
  Widget build(BuildContext context) {
    final shortestSide = MediaQuery.sizeOf(context).shortestSide;

    if (shortestSide >= AppBreakpoints.large && largeDesktop != null) {
      return largeDesktop!(context);
    }
    if (shortestSide >= AppBreakpoints.expanded && desktop != null) {
      return desktop!(context);
    }
    if (shortestSide >= AppBreakpoints.medium && tablet != null) {
      return tablet!(context);
    }
    return mobile(context);
  }
}

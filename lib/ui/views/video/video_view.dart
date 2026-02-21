import 'package:flutter/material.dart';
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
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  double _setAspectRatio(MtPlayerService mtPlayerService) {
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

    mtPlayerService.chewieController?.videoPlayerController.addListener(() {
      WakelockPlus.toggle(
          enable: mtPlayerService.chewieController!.isFullScreen);
    });

    // Hide mini player when video view is open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      persistentUiCubit.setPlayerVisibility(false);
    });
  }

  @override
  void dispose() {
    // Show mini player when video view is closed
    persistentUiCubit.setPlayerVisibility(true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: mtPlayerService.mediaItem,
        builder: (context, snapshot) {
          final mediaItem = snapshot.data;
          return Scaffold(
            key: _scaffoldKey,
            body: LayoutBuilder(builder: (context, constraints) {
              if (mtPlayerService.chewieController == null) {
                return const Center(child: CircularProgressIndicator());
              }
              final bool isTablet = constraints.maxWidth > 600;
              if (isTablet) {
                return VideoTabletScreen(
                  mtPlayerService: mtPlayerService,
                  aspectRatio: _setAspectRatio(mtPlayerService),
                  mediaItem: mediaItem,
                );
              } else {
                return VideoPhoneScreen(
                  mtPlayerService: mtPlayerService,
                  aspectRatio: _setAspectRatio(mtPlayerService),
                  mediaItem: mediaItem,
                );
              }
            }),
          );
        });
  }
}

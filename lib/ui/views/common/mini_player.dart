import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:go_router/go_router.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:my_tube/blocs/home/explore_tab/cubit/mini_player_cubit.dart';
import 'package:my_tube/router/app_router.dart';

class MiniPlayer extends StatefulWidget {
  const MiniPlayer({super.key, required this.video, required this.streamUrl});

  final Video video;
  final String streamUrl;

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  VlcPlayerController? vlcPlayerController;

  bool isPlaying = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() async {
    await vlcPlayerController?.stopRendererScanning();
    await vlcPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final miniPlayerHeight = MediaQuery.of(context).size.height * 0.1;
    if (vlcPlayerController != null) {
      vlcPlayerController?.stopRendererScanning();
      vlcPlayerController?.dispose();
    }

    return AnimatedContainer(
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10))),
      duration: const Duration(milliseconds: 500),
      height: miniPlayerHeight,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
                child: FutureBuilder(
                    future: initVlcPlayer(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return VlcPlayer(
                          controller: vlcPlayerController!,
                          aspectRatio: 16 / 9,
                        );
                      } else {
                        return Image.network(
                            widget.video.snippet!.thumbnails!.high!.url!);
                      }
                    })),
            const SizedBox(
              width: 8,
            ),
            Expanded(
              flex: 2,
              child: Text(
                widget.video.snippet!.title!,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              StatefulBuilder(builder: (context, setState) {
                return IconButton(
                    onPressed: () {
                      setState(() {
                        if (vlcPlayerController!.value.isPlaying) {
                          isPlaying = false;
                          vlcPlayerController!.pause();
                        } else {
                          isPlaying = true;
                          vlcPlayerController!.play();
                        }
                      });
                    },
                    icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow));
              }),
              IconButton(
                  onPressed: () {
                    context.goNamed(AppRoute.videoPlayer.name, extra: {
                      'video': widget.video,
                      'streamUrl': widget.streamUrl,
                      'vlcPlayerController': vlcPlayerController
                    });
                  },
                  icon: const Icon(Icons.fullscreen)),
              IconButton(
                  onPressed: () {
                    context.read<MiniPlayerCubit>().hideMiniPlayer();
                  },
                  icon: const Icon(Icons.stop)),
            ]),
          ],
        ),
      ),
    );
  }

  Future<void> initVlcPlayer() async {
    vlcPlayerController = VlcPlayerController.network(
      widget.streamUrl,
      options: VlcPlayerOptions(
          advanced:
              VlcAdvancedOptions([VlcAdvancedOptions.networkCaching(1000)])),
    )..addListener(() {
        if (vlcPlayerController!.value.isInitialized) {
          vlcPlayerController!.play();
        }
      });
  }
}

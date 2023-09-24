import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:my_tube/blocs/home/explore_tab/cubit/mini_player_cubit.dart';

class MiniPlayer extends StatefulWidget {
  const MiniPlayer({super.key, required this.video, required this.streamUrl});

  final Video video;
  final String streamUrl;

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  VlcPlayerController? vlcPlayerController;

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
    if (vlcPlayerController != null) {
      vlcPlayerController?.stopRendererScanning();
      vlcPlayerController?.dispose();
    }

    return Padding(
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
          Expanded(
              flex: 1,
              child: Row(children: [
                StatefulBuilder(builder: (context, setState) {
                  return IconButton(
                      onPressed: () {
                        setState(() {
                          if (vlcPlayerController!.value.isPlaying) {
                            vlcPlayerController!.pause();
                          } else {
                            vlcPlayerController!.play();
                          }
                        });
                      },
                      icon: Icon(vlcPlayerController!.value.isPlaying
                          ? Icons.play_arrow
                          : Icons.pause));
                }),
                IconButton(
                    onPressed: () {
                      context.read<MiniPlayerCubit>().hideMiniPlayer();
                    },
                    icon: const Icon(Icons.stop)),
              ])),
        ],
      ),
    );
  }

  Future<void> initVlcPlayer() async {
    vlcPlayerController = VlcPlayerController.network(
      widget.streamUrl,
      options: VlcPlayerOptions(),
    );
  }
}

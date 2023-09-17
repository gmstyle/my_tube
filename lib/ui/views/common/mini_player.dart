import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class MiniPlayer extends StatefulWidget {
  const MiniPlayer({super.key, required this.video});

  final Video video;

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  late YoutubePlayerController youtubePlayerController;

  @override
  void initState() {
    super.initState();

    youtubePlayerController = YoutubePlayerController.fromVideoId(
      videoId: widget.video.id!,
      autoPlay: true,
      params: YoutubePlayerParams(
          color: Colors.transparent.value.toString(),
          showControls: false,
          showFullscreenButton: false,
          loop: false),
    );
  }

  @override
  void dispose() {
    youtubePlayerController.stopVideo();
    youtubePlayerController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
              child:
                  //Image.network(widget.video.snippet!.thumbnails!.high!.url!),
                  YoutubePlayer(controller: youtubePlayerController)),
          Expanded(
            flex: 2,
            child: Text(
              widget.video.snippet!.title!,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
              child: Row(
            children: [
              IconButton(
                  onPressed: () {
                    youtubePlayerController.playVideo();
                  },
                  icon: const Icon(Icons.play_arrow)),
              IconButton(
                  onPressed: () {
                    youtubePlayerController.pauseVideo();
                  },
                  icon: const Icon(Icons.pause)),
            ],
          )),
        ],
      ),
    );
  }
}

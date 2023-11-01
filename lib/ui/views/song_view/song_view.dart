import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/mini_player_cubit/mini_player_cubit.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/services/mt_player_handler.dart';
import 'package:my_tube/ui/views/common/custom_appbar.dart';
import 'package:my_tube/ui/views/common/seek_bar.dart';

class SongView extends StatelessWidget {
  const SongView({super.key, required this.video});

  final ResourceMT? video;

  @override
  Widget build(BuildContext context) {
    final mtPlayerHandler = context.read<MtPlayerHandler>();
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: CustomAppbar(title: video?.title ?? ''),
        body: Column(
          children: [
            AspectRatio(
                aspectRatio: mtPlayerHandler
                    .chewieController.videoPlayerController.value.aspectRatio,
                child: Chewie(controller: mtPlayerHandler.chewieController)),
            const SizedBox(
              height: 8,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(video?.description ?? ''),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

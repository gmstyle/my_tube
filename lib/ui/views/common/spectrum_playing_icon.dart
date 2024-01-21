import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/services/mt_player_service.dart';

class SpectrumPlayingIcon extends StatelessWidget {
  const SpectrumPlayingIcon({super.key, required this.videoId});

  final String videoId;

  @override
  Widget build(BuildContext context) {
    final mtPlayerService = context.read<MtPlayerService>();
    return StreamBuilder(
        stream: mtPlayerService.mediaItem,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final currentVideoId = snapshot.data!.id;
            if (currentVideoId == videoId) {
              return StreamBuilder(
                  stream: mtPlayerService.playbackState
                      .map((playbackState) => playbackState.playing)
                      .distinct(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final isPlaying = snapshot.data ?? false;
                      if (isPlaying) {
                        return const AudioSpectrumIcon(
                          height: 48,
                          width: 48,
                        );
                      }
                    }
                    return const SizedBox();
                  });
            }
          }
          return const SizedBox();
        });
  }
}

class AudioSpectrumIcon extends StatefulWidget {
  const AudioSpectrumIcon(
      {super.key,
      this.width = 24,
      this.height = 24,
      this.barColor = Colors.white});

  final double width;
  final double height;
  final Color barColor;

  @override
  State<AudioSpectrumIcon> createState() => _AudioSpectrumIconState();
}

class _AudioSpectrumIconState extends State<AudioSpectrumIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: CustomPaint(
        painter: AudioSpectrumPainter(
            controller: _controller, barColor: widget.barColor),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class AudioSpectrumPainter extends CustomPainter {
  final Animation<double> controller;
  final Color barColor;

  AudioSpectrumPainter({required this.controller, required this.barColor})
      : super(repaint: controller);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = barColor
      ..strokeWidth = size.width / 15
      ..strokeCap = StrokeCap.round;

    final double barWidth = size.width / 15;
    final double spaceWidth = size.width / 30;

    final double centerY = size.height / 2;

    // Calculate the total width of the bars and spaces
    final double totalWidth = 3 * barWidth + 2 * spaceWidth;

    // Calculate the starting x position to center the bars
    final double startX = (size.width - totalWidth) / 2;

    for (int i = 0; i < 3; i++) {
      final double x = startX + i * (barWidth + spaceWidth) + barWidth / 2;
      final double height =
          size.height * (0.2 + 0.5 * sin(controller.value * pi * 2 + i * 0.2));

      canvas.drawLine(
        Offset(x, centerY - height / 2),
        Offset(x, centerY + height / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

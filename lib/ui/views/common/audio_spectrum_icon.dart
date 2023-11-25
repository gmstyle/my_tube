import 'dart:math';

import 'package:flutter/material.dart';

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

    for (int i = 0; i < 4; i++) {
      final double x = i * (barWidth + spaceWidth) + barWidth / 2;
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

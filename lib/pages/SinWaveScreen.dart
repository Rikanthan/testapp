import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class SineWaveScreen extends StatefulWidget {
  const SineWaveScreen({Key? key}) : super(key: key);

  @override
  _SineWaveScreenState createState() => _SineWaveScreenState();
}

class _SineWaveScreenState extends State<SineWaveScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _offset = 0.0;
  double amplitude = 100.0;
  double frequency = 2.0; // 2 cycles

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1000),
    )..addListener(() {
        setState(() {
          _offset += 2; // move the wave forward
        });
      });
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomPaint(
        painter: SineWavePainter(
          offset: _offset,
          amplitude: amplitude,
          frequency: frequency,
        ),
        child: Container(),
      ),
    );
  }
}

class SineWavePainter extends CustomPainter {
  final double offset;
  final double amplitude;
  final double frequency;

  SineWavePainter({
    required this.offset,
    required this.amplitude,
    required this.frequency,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final midY = size.height / 2;
    final paintSine = Paint()
      ..color = Colors.green
      ..strokeWidth = 2;
    final paintMirror = Paint()
      ..color = Colors.pinkAccent
      ..strokeWidth = 2;

    // Draw sine wave
    for (double x = 0; x < size.width; x++) {
      double radians = 2 * pi * frequency * (x + offset) / size.width;
      double y = amplitude * sin(radians);
      canvas.drawPoints(
        PointMode.points,
        [Offset(x, midY - y)],
        paintSine,
      );
    }

    // Draw mirrored sine wave
    for (double x = 0; x < size.width; x++) {
      double radians = 2 * pi * frequency * (x + offset) / size.width;
      double y = -amplitude * sin(radians); // MIRROR
      canvas.drawPoints(
        PointMode.points,
        [Offset(x, midY - y)],
        paintMirror,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

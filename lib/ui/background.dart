// lib/widgets/animated_web_background.dart
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

/// AnimatedWebBackground:
/// An elevated, restaurant-themed background featuring dynamic
/// sine-wave animations and floating culinary icons, utilizing
/// a bold orange gradient for brand consistency and user engagement.
class AnimatedWebBackground extends StatefulWidget {
  const AnimatedWebBackground({Key? key}) : super(key: key);

  @override
  State<AnimatedWebBackground> createState() => _AnimatedWebBackgroundState();
}

class _AnimatedWebBackgroundState extends State<AnimatedWebBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  /// Icon set representing core restaurant themes.
  final List<IconData> _icons = const [
    Icons.restaurant,
    Icons.fastfood,
    Icons.local_pizza,
    Icons.local_cafe,
    Icons.local_bar,
    Icons.icecream,
    Icons.ramen_dining,
    Icons.emoji_food_beverage,
    Icons.cake,
  ];

  /// Normalized start positions for each icon.
  final List<Offset> _startOffsets = const [
    Offset(0.1, 0.2),
    Offset(0.4, 0.1),
    Offset(0.7, 0.3),
    Offset(0.2, 0.6),
    Offset(0.8, 0.5),
    Offset(0.3, 0.85),
    Offset(0.6, 0.75),
    Offset(0.5, 0.4),
    Offset(0.9, 0.8),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Computes a subtle floating offset for each icon.
  Offset _calculateIconOffset(Offset start, double phase) {
    final t = _controller.value * 2 * pi;
    const double amplitude = 0.035;
    final dx = start.dx + amplitude * sin(t + phase);
    final dy = start.dy + amplitude * cos(t - phase);
    return Offset(dx, dy);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        // Dynamic gradient alignment for a moving visual flow.
        final double angle = _controller.value * 2 * pi;
        final Alignment begin = Alignment(cos(angle), sin(angle));
        final Alignment end = Alignment(-cos(angle), -sin(angle));

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: const [
                Color(0xFFFFA726), // Orange 400
                Color(0xFFF57C00), // Orange 700
              ],
              begin: begin,
              end: end,
            ),
          ),
          child: CustomPaint(
            size: size,
            painter: _WavePainter(_controller.value),
            child: Stack(
              children: List.generate(_icons.length, (i) {
                final offset = _calculateIconOffset(
                  _startOffsets[i],
                  i * 0.7,
                );
                return Positioned(
                  left: offset.dx * size.width,
                  top: offset.dy * size.height,
                  child: Icon(
                    _icons[i],
                    size: 40,
                    color: Colors.white.withOpacity(0.75),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}

/// _WavePainter renders animated sine waves to suggest gentle flow.
class _WavePainter extends CustomPainter {
  final double progress;
  _WavePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    const int waveCount = 4;
    final Paint paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < waveCount; i++) {
      final Path path = Path();
      final double phase = progress * 2 * pi - (i * pi / waveCount);
      final double amplitude = size.height * 0.03 * (1 + i * 0.1);
      final double yOffset = size.height * (0.2 + i * 0.18);
      path.moveTo(0, yOffset);
      for (double x = 0; x <= size.width; x += 1) {
        final y = yOffset + sin((x / size.width * 2 * pi) + phase) * amplitude;
        path.lineTo(x, y);
      }
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) => true;
}

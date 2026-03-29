import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'weather_theme.dart';

class WeatherAnimationBackground extends StatelessWidget {
  final WeatherType type;
  const WeatherAnimationBackground({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case WeatherType.sunny: return const SunnyAnimation();
      case WeatherType.cloudy: return const CloudyAnimation();
      case WeatherType.rainy: return const RainyAnimation();
      case WeatherType.stormy: return const RainyAnimation(stormy: true);
      case WeatherType.snowy: return const SnowyAnimation();
      default: return const SizedBox();
    }
  }
}

/// --- Sunny Animation: Moving flares and light rays ---
class SunnyAnimation extends StatefulWidget {
  const SunnyAnimation({super.key});
  @override
  State<SunnyAnimation> createState() => _SunnyAnimationState();
}

class _SunnyAnimationState extends State<SunnyAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 15))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: SunnyPainter(_controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class SunnyPainter extends CustomPainter {
  final double animationValue;
  SunnyPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.8, size.height * 0.2);
    final radius = size.width * 0.25;

    // Outer glow
    canvas.drawCircle(
      center, 
      radius * 1.4 + (math.sin(animationValue * 2 * math.pi) * 10), 
      Paint()
        ..color = Colors.amber.withOpacity(0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30),
    );

    // Sun core
    canvas.drawCircle(
      center, 
      radius * 0.6, 
      Paint()
        ..color = Colors.amber.withOpacity(0.9)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    // More distinct rays
    final rayPaint = Paint()
      ..color = Colors.amber.withOpacity(0.4)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 12; i++) {
      final angle = (i * 30 * math.pi / 180) + (animationValue * 0.5);
      final rayStart = Offset(
        center.dx + math.cos(angle) * (radius * 0.8),
        center.dy + math.sin(angle) * (radius * 0.8),
      );
      final rayEnd = Offset(
        center.dx + math.cos(angle) * (radius * 2.0),
        center.dy + math.sin(angle) * (radius * 2.0),
      );
      canvas.drawLine(rayStart, rayEnd, rayPaint);
    }
  }

  @override
  bool shouldRepaint(SunnyPainter oldDelegate) => true;
}

/// --- Rainy Animation: Falling lines ---
class RainyAnimation extends StatefulWidget {
  final bool stormy;
  const RainyAnimation({super.key, this.stormy = false});
  @override
  State<RainyAnimation> createState() => _RainyAnimationState();
}

class _RainyAnimationState extends State<RainyAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<RainDrop> _drops = List.generate(40, (_) => RainDrop());

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: RainPainter(_drops, _controller.value, widget.stormy),
          size: Size.infinite,
        );
      },
    );
  }
}

class RainDrop {
  double x = math.Random().nextDouble();
  double y = math.Random().nextDouble();
  double length = math.Random().nextDouble() * 15 + 5;
  double speed = math.Random().nextDouble() * 0.05 + 0.02;

  void update() {
    y += speed;
    if (y > 1.0) {
      y = -0.1;
      x = math.Random().nextDouble();
    }
  }
}

class RainPainter extends CustomPainter {
  final List<RainDrop> drops;
  final double animationValue;
  final bool stormy;
  RainPainter(this.drops, this.animationValue, this.stormy);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    for (var drop in drops) {
      drop.update();
      final start = Offset(drop.x * size.width, drop.y * size.height);
      final end = Offset(drop.x * size.width, (drop.y * size.height) + drop.length);
      canvas.drawLine(start, end, paint);
    }
    
    if (stormy && math.Random().nextDouble() < 0.02) {
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Colors.white.withOpacity(0.2));
    }
  }

  @override
  bool shouldRepaint(RainPainter oldDelegate) => true;
}

/// --- Cloudy Animation: Drifting translucent circles ---
class CloudyAnimation extends StatefulWidget {
  const CloudyAnimation({super.key});
  @override
  State<CloudyAnimation> createState() => _CloudyAnimationState();
}

class _CloudyAnimationState extends State<CloudyAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            _buildCloud(context, 0.1, 0.15, 120, 0.6),
            _buildCloud(context, 0.4, 0.05, 180, 0.4),
            _buildCloud(context, 0.7, 0.2, 140, 0.5),
            _buildCloud(context, 0.3, 0.3, 100, 0.3),
          ],
        );
      },
    );
  }

  Widget _buildCloud(BuildContext context, double x, double y, double size, double opacity) {
    final offset = math.sin(_controller.value * 2 * math.pi) * 30;
    return Positioned(
      left: (MediaQuery.of(context).size.width * x) + offset,
      top: MediaQuery.of(context).size.height * y,
      child: Stack(
        children: [
          // Sub-circles to make it look like a cloud
          _cloudCircle(size, 0, 0, opacity),
          _cloudCircle(size * 0.7, size * 0.3, -size * 0.1, opacity),
          _cloudCircle(size * 0.8, -size * 0.2, size * 0.05, opacity),
        ],
      ),
    );
  }

  Widget _cloudCircle(double size, double dx, double dy, double opacity) {
    return Transform.translate(
      offset: Offset(dx, dy),
      child: Container(
        width: size,
        height: size * 0.7,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(opacity * 0.4),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            )
          ],
        ),
      ),
    );
  }
}

/// --- Snowy Animation: Falling white dots ---
class SnowyAnimation extends StatefulWidget {
  const SnowyAnimation({super.key});
  @override
  State<SnowyAnimation> createState() => _SnowyAnimationState();
}

class _SnowyAnimationState extends State<SnowyAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Snowflake> _flakes = List.generate(50, (_) => Snowflake());

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(painter: SnowPainter(_flakes), size: Size.infinite);
      },
    );
  }
}

class Snowflake {
  double x = math.Random().nextDouble();
  double y = math.Random().nextDouble();
  double radius = math.Random().nextDouble() * 3 + 1;
  double speed = math.Random().nextDouble() * 0.005 + 0.002;

  void update() {
    y += speed;
    if (y > 1.0) {
      y = -0.05;
      x = math.Random().nextDouble();
    }
  }
}

class SnowPainter extends CustomPainter {
  final List<Snowflake> flakes;
  SnowPainter(this.flakes);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.6);
    for (var flake in flakes) {
      flake.update();
      canvas.drawCircle(Offset(flake.x * size.width, flake.y * size.height), flake.radius, paint);
    }
  }

  @override
  bool shouldRepaint(SnowPainter oldDelegate) => true;
}

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';

class RingChart extends StatelessWidget {
  final double percent;
  final double size;
  final double strokeWidth;
  final List<Color> gradientColors;
  final Color backgroundColor;

  const RingChart({
    super.key,
    required this.percent,
    this.size = 180,
    this.strokeWidth = 12,
    this.gradientColors = const [Color(0xFF667EEA), Color(0xFF764BA2)],
    this.backgroundColor = const Color(0xFF0D1117),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ring
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              percent: percent,
              strokeWidth: strokeWidth,
              gradientColors: gradientColors,
              backgroundColor: backgroundColor,
            ),
          ),
          // Center text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${percent.toStringAsFixed(0)}%",
                style: context.moonTypography!.heading.text32.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                "Used",
                style: context.moonTypography!.body.text12.copyWith(
                  color: context.moonColors!.trunks,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double percent;
  final double strokeWidth;
  final List<Color> gradientColors;
  final Color backgroundColor;

  _RingPainter({
    required this.percent,
    required this.strokeWidth,
    required this.gradientColors,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Background ring
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);

    // Gradient ring
    final sweepAngle = (percent / 100) * 2 * math.pi;
    final gradient = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: 3 * math.pi / 2,
      colors: gradientColors,
    );

    final fillPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      -math.pi / 2, // Start from top
      sweepAngle,
      false,
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.percent != percent;
  }
}

class RingLegend extends StatelessWidget {
  const RingLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem(
          label: "Used",
          colors: const [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
        const SizedBox(width: 24),
        _LegendItem(label: "Free", color: const Color(0xFF3FB950)),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final List<Color>? colors;
  final Color? color;

  const _LegendItem({required this.label, this.colors, this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: colors != null
                ? LinearGradient(
                    colors: colors!,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: color,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: context.moonTypography!.body.text12.copyWith(
            color: context.moonColors!.trunks,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:math' as math;

class SimpleRiskGauge extends StatelessWidget {
  final int score;
  final double size;

  const SimpleRiskGauge({super.key, required this.score, this.size = 200});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size / 2 + 60,
      child: Stack(
        children: [
          // Gauge background
          CustomPaint(
            size: Size(size, size / 2),
            painter: SimpleGaugePainter(score: score),
          ),

          // Score indicator
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                    border: Border.all(color: _getScoreColor(score), width: 3),
                  ),
                  child: Center(
                    child: Text(
                      score.toString(),
                      style: TextStyle(
                        color: _getScoreColor(score),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getRiskText(score),
                  style: TextStyle(
                    color: _getScoreColor(score),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Gauge labels (using positioned widgets instead of TextPainter)
          Positioned(
            left: size * 0.1,
            bottom: size * 0.25,
            child: const Text(
              '0',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          Positioned(
            left: size * 0.3,
            bottom: size * 0.4,
            child: const Text(
              '2',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          Positioned(
            left: size * 0.5,
            bottom: size * 0.45,
            child: const Text(
              '5',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          Positioned(
            right: size * 0.3,
            bottom: size * 0.4,
            child: const Text(
              '8',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          Positioned(
            right: size * 0.1,
            bottom: size * 0.25,
            child: const Text(
              '10',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score <= 3) {
      return Colors.green;
    } else if (score <= 6) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  String _getRiskText(int score) {
    if (score <= 3) {
      return 'Low Risk';
    } else if (score <= 6) {
      return 'Medium Risk';
    } else {
      return 'High Risk';
    }
  }
}

class SimpleGaugePainter extends CustomPainter {
  final int score;

  SimpleGaugePainter({required this.score});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;

    // Draw gauge background
    final bgPaint =
        Paint()
          ..color = Colors.grey.withOpacity(0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 20;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 10),
      math.pi,
      math.pi,
      false,
      bgPaint,
    );

    // Draw gauge segments
    final segmentCount = 10;
    final segmentAngle = math.pi / segmentCount;

    for (int i = 0; i < segmentCount; i++) {
      final segmentPaint =
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 20;

      if (i < 3) {
        segmentPaint.color = Colors.green.withOpacity(i < score ? 1.0 : 0.3);
      } else if (i < 7) {
        segmentPaint.color = Colors.orange.withOpacity(i < score ? 1.0 : 0.3);
      } else {
        segmentPaint.color = Colors.red.withOpacity(i < score ? 1.0 : 0.3);
      }

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 10),
        math.pi + (i * segmentAngle),
        segmentAngle,
        false,
        segmentPaint,
      );
    }

    // Draw gauge ticks
    final tickPaint =
        Paint()
          ..color = Colors.grey
          ..strokeWidth = 2;

    for (int i = 0; i <= segmentCount; i++) {
      final angle = math.pi + (i * segmentAngle);
      final outerPoint = Offset(
        center.dx + (radius - 5) * math.cos(angle),
        center.dy + (radius - 5) * math.sin(angle),
      );
      final innerPoint = Offset(
        center.dx + (radius - 25) * math.cos(angle),
        center.dy + (radius - 25) * math.sin(angle),
      );

      canvas.drawLine(innerPoint, outerPoint, tickPaint);
    }

    // Draw needle
    final needleLength = radius - 30;
    final needleAngle = math.pi + (score / 10 * math.pi);
    final needleEnd = Offset(
      center.dx + needleLength * math.cos(needleAngle),
      center.dy + needleLength * math.sin(needleAngle),
    );

    final needlePaint =
        Paint()
          ..color = Colors.black
          ..strokeWidth = 3;

    canvas.drawLine(center, needleEnd, needlePaint);

    // Draw needle pivot
    final pivotPaint = Paint()..color = Colors.black;

    canvas.drawCircle(center, 8, pivotPaint);

    final pivotInnerPaint = Paint()..color = Colors.white;

    canvas.drawCircle(center, 4, pivotInnerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

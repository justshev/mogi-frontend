import 'package:flutter/material.dart';
import 'package:jamur/models/prediction_data.dart';
import 'dart:math' as math;

class PredictionChart extends StatelessWidget {
  final GrowthPrediction prediction;

  const PredictionChart({super.key, required this.prediction});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Wrap the Row in a SingleChildScrollView to handle overflow
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Prediksi Pertumbuhan Jamur',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14, // Reduced font size
                ),
              ),
              const SizedBox(width: 8), // Add spacing
              Row(
                children: [
                  Container(
                    width: 10, // Reduced size
                    height: 10, // Reduced size
                    decoration: const BoxDecoration(
                      color: Color(0xFF2E7D32),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Aktual',
                    style: TextStyle(fontSize: 10), // Reduced font size
                  ),
                  const SizedBox(width: 8), // Reduced spacing
                  Container(
                    width: 10, // Reduced size
                    height: 10, // Reduced size
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Prediksi',
                    style: TextStyle(fontSize: 10), // Reduced font size
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16), // Reduced spacing
        Expanded(
          child: CustomPaint(
            size: Size.infinite,
            painter: ChartPainter(prediction: prediction),
          ),
        ),
      ],
    );
  }
}

class ChartPainter extends CustomPainter {
  final GrowthPrediction prediction;

  ChartPainter({required this.prediction});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final padding = 20.0;

    // Drawing area
    final drawingWidth = width - (padding * 2);
    final drawingHeight = height - (padding * 2);
    final drawingOrigin = Offset(padding, height - padding);

    // Paint for grid lines
    final gridPaint =
        Paint()
          ..color = Colors.grey.withOpacity(0.2)
          ..strokeWidth = 1;

    // Paint for axis
    final axisPaint =
        Paint()
          ..color = Colors.grey
          ..strokeWidth = 1;

    // Paint for actual data line
    final actualLinePaint =
        Paint()
          ..color = const Color(0xFF2E7D32)
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;

    // Paint for prediction data line
    final predictionLinePaint =
        Paint()
          ..color = Colors.blue
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;

    // Paint for actual data area
    final actualAreaPaint =
        Paint()
          ..color = const Color(0xFF2E7D32).withOpacity(0.2)
          ..style = PaintingStyle.fill;

    // Paint for prediction data area
    final predictionAreaPaint =
        Paint()
          ..color = Colors.blue.withOpacity(0.2)
          ..style = PaintingStyle.fill;

    // Calculate max growth for y-axis (round up to nearest whole number)
    final maxGrowth = (prediction.maxGrowth.ceil() + 1).toDouble();

    // Calculate total days for x-axis
    final totalDays = prediction.totalDays;

    // Draw horizontal grid lines
    final yGridLines = 6;
    for (int i = 0; i <= yGridLines; i++) {
      final y = drawingOrigin.dy - (i * drawingHeight / yGridLines);
      canvas.drawLine(
        Offset(padding, y),
        Offset(width - padding, y),
        gridPaint,
      );

      // Draw y-axis labels
      final growthValue = (i * maxGrowth / yGridLines);
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${growthValue.toStringAsFixed(1)} cm',
          style: const TextStyle(color: Colors.grey, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(5, y - 5));
    }

    // Draw vertical grid lines
    final xGridLines = math.min(11, totalDays);
    for (int i = 0; i <= xGridLines; i++) {
      final x = drawingOrigin.dx + (i * drawingWidth / xGridLines);
      canvas.drawLine(
        Offset(x, padding),
        Offset(x, height - padding),
        gridPaint,
      );

      // Draw x-axis labels (only for some points)
      if (i % 2 == 0 || i == xGridLines) {
        final dayValue = (i * totalDays / xGridLines).round();
        final textPainter = TextPainter(
          text: TextSpan(
            text: 'Hari ${dayValue + 1}',
            style: const TextStyle(color: Colors.grey, fontSize: 10),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(x - 15, height - 15));
      }
    }

    // Draw x and y axis
    canvas.drawLine(
      Offset(padding, padding),
      Offset(padding, height - padding),
      axisPaint,
    );
    canvas.drawLine(
      Offset(padding, height - padding),
      Offset(width - padding, height - padding),
      axisPaint,
    );

    // Convert data points to screen coordinates
    List<Offset> actualPoints = [];
    for (final data in prediction.actualData) {
      final x = drawingOrigin.dx + (data.day * drawingWidth / totalDays);
      final y = drawingOrigin.dy - (data.growth * drawingHeight / maxGrowth);
      actualPoints.add(Offset(x, y));
    }

    List<Offset> predictionPoints = [];
    // Add the last actual point as the first prediction point for continuity
    if (actualPoints.isNotEmpty) {
      predictionPoints.add(actualPoints.last);
    }

    for (final data in prediction.predictedData) {
      final x = drawingOrigin.dx + (data.day * drawingWidth / totalDays);
      final y = drawingOrigin.dy - (data.growth * drawingHeight / maxGrowth);
      predictionPoints.add(Offset(x, y));
    }

    // Draw actual data line
    if (actualPoints.length > 1) {
      final actualPath = Path();
      actualPath.moveTo(actualPoints[0].dx, actualPoints[0].dy);
      for (int i = 1; i < actualPoints.length; i++) {
        actualPath.lineTo(actualPoints[i].dx, actualPoints[i].dy);
      }
      canvas.drawPath(actualPath, actualLinePaint);

      // Draw area under actual line
      final actualAreaPath = Path();
      actualAreaPath.moveTo(actualPoints[0].dx, drawingOrigin.dy);
      actualAreaPath.lineTo(actualPoints[0].dx, actualPoints[0].dy);
      for (int i = 1; i < actualPoints.length; i++) {
        actualAreaPath.lineTo(actualPoints[i].dx, actualPoints[i].dy);
      }
      actualAreaPath.lineTo(actualPoints.last.dx, drawingOrigin.dy);
      actualAreaPath.close();
      canvas.drawPath(actualAreaPath, actualAreaPaint);
    }

    // Draw prediction data line
    if (predictionPoints.length > 1) {
      final predictionPath = Path();
      predictionPath.moveTo(predictionPoints[0].dx, predictionPoints[0].dy);
      for (int i = 1; i < predictionPoints.length; i++) {
        predictionPath.lineTo(predictionPoints[i].dx, predictionPoints[i].dy);
      }
      canvas.drawPath(predictionPath, predictionLinePaint);

      // Draw area under prediction line
      final predictionAreaPath = Path();
      predictionAreaPath.moveTo(predictionPoints[0].dx, drawingOrigin.dy);
      predictionAreaPath.lineTo(predictionPoints[0].dx, predictionPoints[0].dy);
      for (int i = 1; i < predictionPoints.length; i++) {
        predictionAreaPath.lineTo(
          predictionPoints[i].dx,
          predictionPoints[i].dy,
        );
      }
      predictionAreaPath.lineTo(predictionPoints.last.dx, drawingOrigin.dy);
      predictionAreaPath.close();
      canvas.drawPath(predictionAreaPath, predictionAreaPaint);
    }

    // Draw data points
    final pointPaint =
        Paint()
          ..color = Colors.white
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    final pointFillPaint =
        Paint()
          ..color = const Color(0xFF2E7D32)
          ..style = PaintingStyle.fill;

    final predictionPointFillPaint =
        Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.fill;

    for (final point in actualPoints) {
      canvas.drawCircle(point, 4, pointFillPaint);
      canvas.drawCircle(point, 4, pointPaint);
    }

    for (final point in predictionPoints.sublist(1)) {
      canvas.drawCircle(point, 4, predictionPointFillPaint);
      canvas.drawCircle(point, 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

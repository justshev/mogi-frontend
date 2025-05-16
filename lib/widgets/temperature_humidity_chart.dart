import 'package:flutter/material.dart';
import 'package:jamur/models/analysis_data.dart';
import 'dart:math' as math;

class TemperatureHumidityChart extends StatelessWidget {
  final List<HistoryLog> logs;
  final double width;
  final double height;

  const TemperatureHumidityChart({
    super.key,
    required this.logs,
    this.width = 300,
    this.height = 300,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Distribusi Suhu & Kelembapan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildLegendItem('Risiko Rendah', Colors.green),
                const SizedBox(width: 16),
                _buildLegendItem('Risiko Sedang', Colors.orange),
                const SizedBox(width: 16),
                _buildLegendItem('Risiko Tinggi', Colors.red),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: CustomPaint(
                size: Size(width - 32, height - 80),
                painter: ScatterPlotPainter(logs: logs, context: context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class ScatterPlotPainter extends CustomPainter {
  final List<HistoryLog> logs;
  final BuildContext context;

  ScatterPlotPainter({required this.logs, required this.context});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final padding = 40.0;

    // Drawing area
    final drawingWidth = width - (padding * 2);
    final drawingHeight = height - (padding * 2);
    final drawingOrigin = Offset(padding, height - padding);

    // Axis ranges
    final minTemp = 0.0;
    final maxTemp = 100.0;
    final minHumidity = 0.0;
    final maxHumidity = 100.0;

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

    // Draw horizontal grid lines (temperature)
    for (int i = 0; i <= 10; i++) {
      final y = drawingOrigin.dy - (i * drawingHeight / 10);
      canvas.drawLine(
        Offset(padding, y),
        Offset(width - padding, y),
        gridPaint,
      );

      // Draw y-axis labels using simpler approach
      final temp = (i * (maxTemp - minTemp) / 10).toInt();
      final textStyle = const TextStyle(color: Colors.grey, fontSize: 10);
      final textSpan = TextSpan(text: '$temp°C', style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.rtl, // Use rtl instead of ltr
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(5, y - 5));
    }

    // Draw vertical grid lines (humidity)
    for (int i = 0; i <= 10; i++) {
      final x = drawingOrigin.dx + (i * drawingWidth / 10);
      canvas.drawLine(
        Offset(x, padding),
        Offset(x, height - padding),
        gridPaint,
      );

      // Draw x-axis labels
      final humidity = (i * (maxHumidity - minHumidity) / 10).toInt();
      final textStyle = const TextStyle(color: Colors.grey, fontSize: 10);
      final textSpan = TextSpan(text: '$humidity%', style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.rtl, // Use rtl instead of ltr
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, height - 25));
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

    // Draw axis labels
    final xLabelStyle = const TextStyle(color: Colors.black, fontSize: 12);
    final xLabelSpan = TextSpan(text: 'Kelembapan (%)', style: xLabelStyle);
    final xLabelPainter = TextPainter(
      text: xLabelSpan,
      textDirection: TextDirection.rtl, // Use rtl instead of ltr
    );
    xLabelPainter.layout();
    xLabelPainter.paint(
      canvas,
      Offset(width / 2 - xLabelPainter.width / 2, height - 10),
    );

    final yLabelStyle = const TextStyle(color: Colors.black, fontSize: 12);
    final yLabelSpan = TextSpan(text: 'Suhu (°C)', style: yLabelStyle);
    final yLabelPainter = TextPainter(
      text: yLabelSpan,
      textDirection: TextDirection.rtl, // Use rtl instead of ltr
    );
    yLabelPainter.layout();

    // Rotate and position the y-axis label
    canvas.save();
    canvas.translate(10, height / 2);
    canvas.rotate(-math.pi / 2);
    yLabelPainter.paint(
      canvas,
      Offset(-yLabelPainter.width / 2, -yLabelPainter.height / 2),
    );
    canvas.restore();

    // Draw optimal growth zone
    final optimalZonePath = Path();
    final optimalZonePaint =
        Paint()
          ..color = Colors.green.withOpacity(0.1)
          ..style = PaintingStyle.fill;

    // Optimal zone: 20-28°C, 80-90% humidity
    final x1 = drawingOrigin.dx + (80 * drawingWidth / 100);
    final x2 = drawingOrigin.dx + (90 * drawingWidth / 100);
    final y1 = drawingOrigin.dy - (20 * drawingHeight / 100);
    final y2 = drawingOrigin.dy - (28 * drawingHeight / 100);

    optimalZonePath.moveTo(x1, y1);
    optimalZonePath.lineTo(x2, y1);
    optimalZonePath.lineTo(x2, y2);
    optimalZonePath.lineTo(x1, y2);
    optimalZonePath.close();

    canvas.drawPath(optimalZonePath, optimalZonePaint);

    // Draw border for optimal zone
    final optimalZoneBorderPaint =
        Paint()
          ..color = Colors.green
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;

    canvas.drawPath(optimalZonePath, optimalZoneBorderPaint);

    // Draw data points
    for (final log in logs) {
      for (final input in log.inputLogs) {
        final x = drawingOrigin.dx + (input.humidity * drawingWidth / 100);
        final y = drawingOrigin.dy - (input.temperature * drawingHeight / 100);

        final pointPaint = Paint()..style = PaintingStyle.fill;

        // Color based on risk level
        if (log.tingkatRisiko.toLowerCase() == 'rendah') {
          pointPaint.color = Colors.green;
        } else if (log.tingkatRisiko.toLowerCase() == 'sedang') {
          pointPaint.color = Colors.orange;
        } else {
          pointPaint.color = Colors.red;
        }

        canvas.drawCircle(Offset(x, y), 5, pointPaint);

        // Draw border
        final borderPaint =
            Paint()
              ..color = Colors.white
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1;

        canvas.drawCircle(Offset(x, y), 5, borderPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

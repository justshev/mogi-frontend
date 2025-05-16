import 'package:flutter/material.dart';
import 'package:jamur/models/analysis_data.dart';

class SimpleScatterChart extends StatelessWidget {
  final List<HistoryLog> logs;
  final double width;
  final double height;

  const SimpleScatterChart({
    super.key,
    required this.logs,
    this.width = double.infinity,
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
              'Temperatur & Humidity Distribution',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16, // Jarak horizontal antar item
              runSpacing: 8, // Jarak vertikal antar baris
              children: [
                _buildLegendItem('Low Risk', Colors.green),
                _buildLegendItem('Medium Risk', Colors.orange),
                _buildLegendItem('High Risk', Colors.red),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      // Y-axis labels (Temperature)
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 20,
                        width: 25,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '100°',
                              style: TextStyle(fontSize: 8, color: Colors.grey),
                            ),
                            const Text(
                              '80°',
                              style: TextStyle(fontSize: 8, color: Colors.grey),
                            ),
                            const Text(
                              '60°',
                              style: TextStyle(fontSize: 8, color: Colors.grey),
                            ),
                            const Text(
                              '40°',
                              style: TextStyle(fontSize: 8, color: Colors.grey),
                            ),
                            const Text(
                              '20°',
                              style: TextStyle(fontSize: 8, color: Colors.grey),
                            ),
                            const Text(
                              '0°',
                              style: TextStyle(fontSize: 8, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),

                      // X-axis labels (Humidity)
                      Positioned(
                        left: 25,
                        right: 0,
                        bottom: 0,
                        height: 20,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Text(
                              '0%',
                              style: TextStyle(fontSize: 8, color: Colors.grey),
                            ),
                            const Text(
                              '20%',
                              style: TextStyle(fontSize: 8, color: Colors.grey),
                            ),
                            const Text(
                              '40%',
                              style: TextStyle(fontSize: 8, color: Colors.grey),
                            ),
                            const Text(
                              '60%',
                              style: TextStyle(fontSize: 8, color: Colors.grey),
                            ),
                            const Text(
                              '80%',
                              style: TextStyle(fontSize: 8, color: Colors.grey),
                            ),
                            const Text(
                              '100%',
                              style: TextStyle(fontSize: 8, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),

                      // Chart area
                      Positioned(
                        left: 25,
                        right: 0,
                        top: 0,
                        bottom: 20,
                        child: CustomPaint(
                          size: Size(
                            constraints.maxWidth - 25,
                            constraints.maxHeight - 20,
                          ),
                          painter: SimpleScatterChartPainter(logs: logs),
                        ),
                      ),

                      // Axis labels
                      Positioned(
                        left: 0,
                        bottom: constraints.maxHeight / 2,
                        child: RotatedBox(
                          quarterTurns: 3,
                          child: Text(
                            'Temperature (°C)',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 5,
                        left: constraints.maxWidth / 2 - 30,
                        child: Text(
                          'Humidity (%)',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
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

class SimpleScatterChartPainter extends CustomPainter {
  final List<HistoryLog> logs;

  SimpleScatterChartPainter({required this.logs});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Paint for grid lines
    final gridPaint =
        Paint()
          ..color = Colors.grey.withOpacity(0.2)
          ..strokeWidth = 1;

    // Draw horizontal grid lines (temperature)
    for (int i = 0; i <= 5; i++) {
      final y = height - (i * height / 5);
      canvas.drawLine(Offset(0, y), Offset(width, y), gridPaint);
    }

    // Draw vertical grid lines (humidity)
    for (int i = 0; i <= 5; i++) {
      final x = i * width / 5;
      canvas.drawLine(Offset(x, 0), Offset(x, height), gridPaint);
    }

    // Draw optimal growth zone
    final optimalZonePath = Path();
    final optimalZonePaint =
        Paint()
          ..color = Colors.green.withOpacity(0.1)
          ..style = PaintingStyle.fill;

    // Optimal zone: 20-28°C, 80-90% humidity
    final x1 = width * 0.8; // 80% humidity
    final x2 = width * 0.9; // 90% humidity
    final y1 = height - (height * 0.2); // 20°C
    final y2 = height - (height * 0.28); // 28°C

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
        final x = width * (input.humidity / 100);
        final y = height - (height * (input.temperature / 100));

        final pointPaint = Paint()..style = PaintingStyle.fill;

        // Color based on risk level
        if (log.tingkatRisiko.toLowerCase() == 'low') {
          pointPaint.color = Colors.green;
        } else if (log.tingkatRisiko.toLowerCase() == 'medium') {
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

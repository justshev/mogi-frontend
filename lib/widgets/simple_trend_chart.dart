import 'package:flutter/material.dart';
import 'package:jamur/models/analysis_data.dart';
import 'package:intl/intl.dart';

class SimpleTrendChart extends StatelessWidget {
  final List<HistoryLog> logs;
  final double width;
  final double height;

  const SimpleTrendChart({
    super.key,
    required this.logs,
    this.width = double.infinity,
    this.height = 300,
  });

  @override
  Widget build(BuildContext context) {
    // Sort logs by timestamp
    final sortedLogs = List<HistoryLog>.from(logs)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

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
              'Growth Score Trend',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Score',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  'Time',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      // Y-axis labels
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        width: 20,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '10',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                            const Text(
                              '8',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                            const Text(
                              '6',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                            const Text(
                              '4',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                            const Text(
                              '2',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                            const Text(
                              '0',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
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
                          painter: SimpleTrendChartPainter(
                            logs: sortedLogs,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),

                      // X-axis labels
                      if (sortedLogs.length >= 2)
                        Positioned(
                          left: 25,
                          right: 0,
                          bottom: 0,
                          height: 20,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                DateFormat(
                                  'dd/MM',
                                ).format(sortedLogs.first.timestamp),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                              if (sortedLogs.length > 2)
                                Text(
                                  DateFormat('dd/MM').format(
                                    sortedLogs[sortedLogs.length ~/ 2]
                                        .timestamp,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              Text(
                                DateFormat(
                                  'dd/MM',
                                ).format(sortedLogs.last.timestamp),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
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
}

class SimpleTrendChartPainter extends CustomPainter {
  final List<HistoryLog> logs;
  final Color color;

  SimpleTrendChartPainter({required this.logs, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (logs.isEmpty) return;

    final width = size.width;
    final height = size.height;

    // Paint for grid lines
    final gridPaint =
        Paint()
          ..color = Colors.grey.withOpacity(0.2)
          ..strokeWidth = 1;

    // Draw horizontal grid lines
    for (int i = 0; i <= 5; i++) {
      final y = height - (i * height / 5);
      canvas.drawLine(Offset(0, y), Offset(width, y), gridPaint);
    }

    // Draw vertical grid lines
    for (int i = 0; i <= 4; i++) {
      final x = i * width / 4;
      canvas.drawLine(Offset(x, 0), Offset(x, height), gridPaint);
    }

    // Draw data points and line
    final pointPaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    final linePaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    final path = Path();
    final areaPath = Path();

    // Calculate x positions based on time intervals
    final firstTimestamp = logs.first.timestamp;
    final lastTimestamp = logs.last.timestamp;
    final timeRange = lastTimestamp.difference(firstTimestamp).inSeconds;

    for (int i = 0; i < logs.length; i++) {
      final log = logs[i];
      final timeOffset = log.timestamp.difference(firstTimestamp).inSeconds;
      final xRatio = timeRange > 0 ? timeOffset / timeRange : 0.5;
      final x = xRatio * width;
      final y = height - (log.skorPertumbuhan * height / 10);

      // Draw point
      canvas.drawCircle(Offset(x, y), 4, pointPaint);

      // Draw border
      final borderPaint =
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1;

      canvas.drawCircle(Offset(x, y), 4, borderPaint);

      // Add to path
      if (i == 0) {
        path.moveTo(x, y);
        areaPath.moveTo(x, height);
        areaPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        areaPath.lineTo(x, y);
      }
    }

    // Draw line
    canvas.drawPath(path, linePaint);

    // Draw area under line
    areaPath.lineTo(width, logs.last.skorPertumbuhan * height / 10);
    areaPath.lineTo(width, height);
    areaPath.close();

    final areaPaint =
        Paint()
          ..color = color.withOpacity(0.1)
          ..style = PaintingStyle.fill;

    canvas.drawPath(areaPath, areaPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

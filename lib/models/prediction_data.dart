import 'dart:math' as math;

class PredictionData {
  final double day;
  final double growth;
  final bool isActual;

  PredictionData({
    required this.day,
    required this.growth,
    required this.isActual,
  });
}

class GrowthPrediction {
  final List<PredictionData> actualData;
  final List<PredictionData> predictedData;
  final double maxGrowth;
  final int totalDays;

  GrowthPrediction({
    required this.actualData,
    required this.predictedData,
    required this.maxGrowth,
    required this.totalDays,
  });

  factory GrowthPrediction.fromHistoryLogs(Map<String, dynamic> historyData) {
    final logs =
        (historyData['logs'] as List)
            .map((log) => Map<String, dynamic>.from(log))
            .toList();

    // Sort logs by timestamp (oldest first)
    logs.sort(
      (a, b) => DateTime.parse(
        a['timestamp'],
      ).compareTo(DateTime.parse(b['timestamp'])),
    );

    final actualData = <PredictionData>[];
    final predictedData = <PredictionData>[];

    // Calculate days from the first log
    final firstLogDate = DateTime.parse(logs.first['timestamp']);

    // Generate actual data points from logs
    for (int i = 0; i < logs.length; i++) {
      final log = logs[i];
      final logDate = DateTime.parse(log['timestamp']);
      final daysDifference = logDate.difference(firstLogDate).inHours / 24;

      // Use skorPertumbuhan as growth indicator (scaled)
      final growth =
          (log['skorPertumbuhan'] as int) / 1.5; // Scale to reasonable height

      actualData.add(
        PredictionData(day: daysDifference, growth: growth, isActual: true),
      );
    }

    // Generate prediction data points (5 days into the future)
    final lastActualData = actualData.last;
    final lastGrowth = lastActualData.growth;
    final lastDay = lastActualData.day;

    // Simple growth model: logarithmic growth that slows down
    for (int i = 1; i <= 5; i++) {
      final day = lastDay + i;
      // Calculate predicted growth with a logarithmic model
      final growth = lastGrowth + (0.5 * math.log(i + 1));

      predictedData.add(
        PredictionData(day: day, growth: growth, isActual: false),
      );
    }

    // Calculate max growth for scaling
    double maxGrowth = 0;
    for (final data in [...actualData, ...predictedData]) {
      if (data.growth > maxGrowth) {
        maxGrowth = data.growth;
      }
    }

    // Calculate total days for x-axis scaling
    final totalDays = (lastDay + 5).ceil();

    return GrowthPrediction(
      actualData: actualData,
      predictedData: predictedData,
      maxGrowth: maxGrowth,
      totalDays: totalDays,
    );
  }
}

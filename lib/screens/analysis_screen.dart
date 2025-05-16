import 'package:flutter/material.dart';
import 'package:jamur/models/analysis_data.dart';
import 'package:jamur/services/analysis_service.dart';
import 'package:jamur/widgets/simple_risk_gauge.dart';
import 'package:jamur/widgets/simple_scatter_chart.dart';
import 'package:jamur/widgets/simple_trend_chart.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final AnalysisService _analysisService = AnalysisService();
  late Future<PredictionSummary> _summaryFuture;
  late Future<HistoryData> _historyFuture;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    _summaryFuture = _analysisService.getPredictionSummary();
    _historyFuture = _analysisService.getHistoryData();

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Growth Analysis'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Prediction Summary Section
                        _buildPredictionSummarySection(),

                        const SizedBox(height: 24),

                        // Charts Section
                        _buildChartsSection(),

                        const SizedBox(height: 24),

                        // Insights Section
                        _buildInsightsSection(),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }

  Widget _buildPredictionSummarySection() {
    return FutureBuilder<PredictionSummary>(
      future: _summaryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return _buildErrorCard(
            'Failed to load prediction summary',
            snapshot.error.toString(),
          );
        } else if (!snapshot.hasData) {
          return _buildErrorCard(
            'No Data',
            'No prediction summary data available',
          );
        }

        final summary = snapshot.data!;

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.analytics,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Prediction Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Center(child: SimpleRiskGauge(score: summary.skorPertumbuhan)),
                const SizedBox(height: 16),
                Text(
                  summary.kesimpulan,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(summary.deskripsi, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _getRiskColor(
                      summary.tingkatRisiko,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getRiskColor(
                        summary.tingkatRisiko,
                      ).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.tips_and_updates,
                            color: _getRiskColor(summary.tingkatRisiko),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Recommended Actions',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _getRiskColor(summary.tingkatRisiko),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(summary.saran, style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChartsSection() {
    return FutureBuilder<HistoryData>(
      future: _historyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return _buildErrorCard(
            'Failed to load history data',
            snapshot.error.toString(),
          );
        } else if (!snapshot.hasData || snapshot.data!.logs.isEmpty) {
          return _buildErrorCard(
            'No Data',
            'No history data available for analysis',
          );
        }

        final historyData = snapshot.data!;
        final logs = historyData.logs;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Data Analysis',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SimpleScatterChart(logs: logs, height: 250),
            const SizedBox(height: 16),
            SimpleTrendChart(logs: logs, height: 250),
          ],
        );
      },
    );
  }

  Widget _buildInsightsSection() {
    return FutureBuilder<HistoryData>(
      future: _historyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data!.logs.isEmpty) {
          return const SizedBox.shrink();
        }

        final historyData = snapshot.data!;
        final logs = historyData.logs;

        // Calculate insights
        final avgScore =
            logs.map((log) => log.skorPertumbuhan).reduce((a, b) => a + b) /
            logs.length;
        final highRiskCount =
            logs
                .where((log) => log.tingkatRisiko.toLowerCase() == 'tinggi')
                .length;
        final highRiskPercentage = (highRiskCount / logs.length) * 100;

        // Find optimal conditions
        final optimalConditions = _findOptimalConditions(logs);

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Insights',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInsightItem(
                  'Average Score',
                  '${avgScore.toStringAsFixed(1)} out of 10',
                  Icons.score,
                ),
                const Divider(),
                _buildInsightItem(
                  'High Risk Frequency',
                  '${highRiskPercentage.toStringAsFixed(1)}% of total predictions',
                  Icons.warning,
                ),
                const Divider(),
                _buildInsightItem(
                  'Optimal Conditions',
                  'Temperature: ${optimalConditions['minTemp']}°C - ${optimalConditions['maxTemp']}°C\nHumidity: ${optimalConditions['minHumidity']}% - ${optimalConditions['maxHumidity']}%',
                  Icons.thermostat,
                ),
                const Divider(),
                _buildInsightItem(
                  'Recommendation',
                  'Maintain temperature and humidity within the optimal range to prevent unwanted mushroom growth.',
                  Icons.recommend,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInsightItem(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String title, String message) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRiskColor(String risk) {
    switch (risk.toLowerCase()) {
      case 'rendah':
      case 'low':
        return Colors.green;
      case 'sedang':
      case 'medium':
        return Colors.orange;
      case 'tinggi':
      case 'high':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  Map<String, dynamic> _findOptimalConditions(List<HistoryLog> logs) {
    // Find logs with low risk
    final lowRiskLogs =
        logs
            .where(
              (log) =>
                  log.tingkatRisiko.toLowerCase() == 'rendah' ||
                  log.tingkatRisiko.toLowerCase() == 'low',
            )
            .toList();

    // If no low risk logs, use all logs
    final targetLogs = lowRiskLogs.isEmpty ? logs : lowRiskLogs;

    // Extract temperature and humidity values
    final temperatures = <double>[];
    final humidities = <double>[];

    for (final log in targetLogs) {
      for (final input in log.inputLogs) {
        temperatures.add(input.temperature);
        humidities.add(input.humidity);
      }
    }

    // Calculate min and max values
    double minTemp = 100;
    double maxTemp = 0;
    double minHumidity = 100;
    double maxHumidity = 0;

    if (temperatures.isNotEmpty) {
      minTemp = temperatures.reduce((a, b) => a < b ? a : b);
      maxTemp = temperatures.reduce((a, b) => a > b ? a : b);
    }

    if (humidities.isNotEmpty) {
      minHumidity = humidities.reduce((a, b) => a < b ? a : b);
      maxHumidity = humidities.reduce((a, b) => a > b ? a : b);
    }

    // Round values
    minTemp = (minTemp * 10).round() / 10;
    maxTemp = (maxTemp * 10).round() / 10;
    minHumidity = (minHumidity * 10).round() / 10;
    maxHumidity = (maxHumidity * 10).round() / 10;

    return {
      'minTemp': minTemp,
      'maxTemp': maxTemp,
      'minHumidity': minHumidity,
      'maxHumidity': maxHumidity,
    };
  }
}

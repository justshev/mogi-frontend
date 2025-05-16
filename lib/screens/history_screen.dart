import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jamur/models/prediction_log.dart';

import 'package:jamur/services/api_services.dart';
import 'package:jamur/widgets/log_detail_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ApiService _apiService = ApiService();
  late Future<PredictionHistory> _historyFuture;
  PredictionLog? _selectedLog;

  @override
  void initState() {
    super.initState();
    _historyFuture = _apiService.getPredictionHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Prediction History'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [],
      ),
      body: FutureBuilder<PredictionHistory>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    'Error occurred: ${snapshot.error}',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _historyFuture = _apiService.getPredictionHistory();
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.logs.isEmpty) {
            return const Center(
              child: Text('No prediction history data available'),
            );
          }

          final history = snapshot.data!;
          final logs = history.logs;

          return Column(
            children: [
              // User info card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: Text(
                        history.userName.isNotEmpty ? history.userName[0] : '?',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            history.userName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            history.userEmail,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${logs.length} Prediction Records',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Timeline header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.history, size: 20, color: Colors.grey),
                    const SizedBox(width: 8),
                    const Text(
                      'Prediction History',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Last updated: ${DateFormat('dd MMM, HH:mm').format(DateTime.now())}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Log list
              Expanded(
                child:
                    _selectedLog == null
                        ? _buildLogList(logs)
                        : _buildLogDetail(_selectedLog!),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLogList(List<PredictionLog> logs) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];

        // Group logs by date
        final bool showDateHeader =
            index == 0 || !_isSameDay(logs[index - 1].timestamp, log.timestamp);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showDateHeader) ...[
              if (index > 0) const SizedBox(height: 16),
              _buildDateHeader(log.timestamp),
              const SizedBox(height: 8),
            ],
            LogDetailCard(
              log: log,
              onTap: () {
                setState(() {
                  _selectedLog = log;
                });
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDateHeader(DateTime date) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _formatDateHeader(date),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildLogDetail(PredictionLog log) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedLog = null;
              });
            },
            child: Row(
              children: [
                Icon(
                  Icons.arrow_back,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Back to list',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Date and risk level
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('dd MMMM yyyy, HH:mm').format(log.timestamp),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildRiskBadge(log.tingkatRisiko),
            ],
          ),

          const SizedBox(height: 24),

          // Score card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getScoreColor(log.skorPertumbuhan).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _getScoreColor(log.skorPertumbuhan).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: _getScoreColor(log.skorPertumbuhan),
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      log.skorPertumbuhan.toString(),
                      style: TextStyle(
                        color: _getScoreColor(log.skorPertumbuhan),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Growth Score',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getScoreDescription(log.skorPertumbuhan),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Input data
          const Text(
            'Input Data',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: log.inputLogs.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final inputLog = log.inputLogs[index];
                return ListTile(
                  title: Text(
                    'Data ${index + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Temperature: ${inputLog.temperature}°C, Humidity: ${inputLog.humidity}%',
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    child: Icon(
                      Icons.thermostat,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // Conclusion
          _buildDetailSection(
            'Conclusion',
            log.kesimpulan,
            Icons.lightbulb,
            Colors.amber,
          ),

          const SizedBox(height: 16),

          // Description
          _buildDetailSection(
            'Description',
            log.deskripsi,
            Icons.description,
            Colors.blue,
          ),

          const SizedBox(height: 16),

          // Suggestions
          _buildDetailSection(
            'Suggestions',
            log.saran,
            Icons.tips_and_updates,
            Colors.green,
          ),

          const SizedBox(height: 24),

          // Share button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // Share functionality
              },
              icon: const Icon(Icons.share),
              label: const Text('Share Prediction Results'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(
    String title,
    String content,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(content, style: const TextStyle(fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildRiskBadge(String risk) {
    Color color;
    IconData icon;

    switch (risk.toLowerCase()) {
      case 'low':
      case 'rendah':
        color = Colors.green;
        icon = Icons.check_circle;
        risk = 'Low';
        break;
      case 'medium':
      case 'sedang':
        color = Colors.orange;
        icon = Icons.warning;
        risk = 'Medium';
        break;
      case 'high':
      case 'tinggi':
        color = Colors.red;
        icon = Icons.error;
        risk = 'High';
        break;
      default:
        color = Colors.blue;
        icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            'Risk: $risk',
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
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

  String _getScoreDescription(int score) {
    if (score <= 3) {
      return 'Low probability of mushroom growth';
    } else if (score <= 6) {
      return 'Medium probability of mushroom growth';
    } else {
      return 'High probability of mushroom growth';
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();

    if (_isSameDay(date, now)) {
      return 'Today';
    } else if (_isSameDay(date, now.subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    } else {
      return DateFormat('EEEE, dd MMMM yyyy').format(date);
    }
  }
}

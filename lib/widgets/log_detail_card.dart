import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jamur/models/prediction_log.dart';

class LogDetailCard extends StatelessWidget {
  final PredictionLog log;
  final VoidCallback onTap;

  const LogDetailCard({super.key, required this.log, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildRiskBadge(log.tingkatRisiko),
                  Text(
                    _formatDate(log.timestamp),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                log.kesimpulan,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildScoreIndicator(log.skorPertumbuhan),
                  const SizedBox(width: 16),
                  Expanded(child: _buildInputLogSummary(log.inputLogs)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRiskBadge(String risk) {
    Color color;
    IconData icon;

    switch (risk.toLowerCase()) {
      case 'low':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'medium':
        color = Colors.orange;
        icon = Icons.warning;
        break;
      case 'high':
        color = Colors.red;
        icon = Icons.error;
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
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            '$risk Risk',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreIndicator(int score) {
    Color color;
    if (score <= 3) {
      color = Colors.green;
    } else if (score <= 6) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.1),
        border: Border.all(color: color, width: 2),
      ),
      child: Center(
        child: Text(
          score.toString(),
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildInputLogSummary(List<InputLog> inputLogs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Data Input:',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              inputLogs.asMap().entries.map((entry) {
                final index = entry.key;
                final log = entry.value;
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Data ${index + 1}: ${log.temperature}°C, ${log.humidity}%',
                    style: const TextStyle(fontSize: 11),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }
}

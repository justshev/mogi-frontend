import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jamur/models/sensor_data.dart';

class SensorCard extends StatelessWidget {
  final SensorData sensorData;
  final VoidCallback onTap;

  const SensorCard({super.key, required this.sensorData, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0), // Reduced padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Ensure column takes minimum space
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    sensorData.icon,
                    color: sensorData.color,
                    size: 24, // Reduced size
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6, // Reduced padding
                      vertical: 2, // Reduced padding
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        sensorData.status,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      sensorData.status,
                      style: TextStyle(
                        color: _getStatusColor(sensorData.status),
                        fontSize: 10, // Reduced font size
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8), // Reduced spacing
              Text(
                sensorData.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2), // Reduced spacing
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    sensorData.value.toString(),
                    style: const TextStyle(
                      fontSize: 20, // Reduced font size
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    sensorData.unit,
                    style: TextStyle(
                      fontSize: 12, // Reduced font size
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4), // Reduced spacing
              Text(
                'Last Update: ${_formatTime(sensorData.lastUpdated)}',
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                maxLines: 1, // Ensure text doesn't wrap
                overflow:
                    TextOverflow.ellipsis, // Handle overflow with ellipsis
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'normal':
        return Colors.green;
      case 'rendah':
        return Colors.orange;
      case 'tinggi':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  String _formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }
}

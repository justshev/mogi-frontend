import 'package:flutter/material.dart';

class SensorData {
  final int id;
  final String name;
  final double value;
  final String unit;
  final IconData icon;
  final Color color;
  final String status;
  final DateTime lastUpdated;

  SensorData({
    required this.id,
    required this.name,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    required this.status,
    required this.lastUpdated,
  });
}

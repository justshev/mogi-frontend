class PredictionLog {
  final String id;
  final String kesimpulan;
  final int skorPertumbuhan;
  final String tingkatRisiko;
  final String saran;
  final String deskripsi;
  final List<InputLog> inputLogs;
  final DateTime timestamp;

  PredictionLog({
    required this.id,
    required this.kesimpulan,
    required this.skorPertumbuhan,
    required this.tingkatRisiko,
    required this.saran,
    required this.deskripsi,
    required this.inputLogs,
    required this.timestamp,
  });

  factory PredictionLog.fromJson(Map<String, dynamic> json) {
    return PredictionLog(
      id: json['id'],
      kesimpulan: json['kesimpulan'],
      skorPertumbuhan: json['skorPertumbuhan'],
      tingkatRisiko: json['tingkatRisiko'],
      saran: json['saran'],
      deskripsi: json['deskripsi'],
      inputLogs:
          (json['inputLogs'] as List)
              .map((log) => InputLog.fromJson(log))
              .toList(),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class InputLog {
  final double temperature;
  final double humidity;

  InputLog({required this.temperature, required this.humidity});

  factory InputLog.fromJson(Map<String, dynamic> json) {
    return InputLog(
      temperature: json['temperature'].toDouble(),
      humidity: json['humidity'].toDouble(),
    );
  }
}

class PredictionHistory {
  final String userId;
  final String userName;
  final String userEmail;
  final List<PredictionLog> logs;

  PredictionHistory({
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.logs,
  });

  factory PredictionHistory.fromJson(Map<String, dynamic> json) {
    return PredictionHistory(
      userId: json['userId'],
      userName: json['userName'],
      userEmail: json['userEmail'],
      logs:
          (json['logs'] as List)
              .map((log) => PredictionLog.fromJson(log))
              .toList(),
    );
  }
}

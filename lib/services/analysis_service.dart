import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jamur/models/analysis_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnalysisService {
  static const String baseUrl =
      'https://c969-149-113-224-229.ngrok-free.app/api';

  Future<PredictionSummary> getPredictionSummary() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('idToken') ?? '';

      final response = await http.get(
        Uri.parse('$baseUrl/prediksi-jamur/prediksi-from-history'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return PredictionSummary.fromJson(data);
      } else {
        throw Exception(
          'Failed to load prediction summary: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching prediction summary: $e');
    }
  }

  Future<HistoryData> getHistoryData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('idToken') ?? '';

      final response = await http.get(
        Uri.parse('$baseUrl/prediksi-jamur/history'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return HistoryData.fromJson(data);
      } else {
        throw Exception('Failed to load history data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching history data: $e');
    }
  }
}

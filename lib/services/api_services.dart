import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jamur/models/prediction_log.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl =
      'https://c969-149-113-224-229.ngrok-free.app/api';

  // Metode untuk mendapatkan token dari SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('idToken');
  }

  // Metode untuk mendapatkan headers dengan token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': token != null ? 'Bearer $token' : '',
    };
  }

  Future<PredictionHistory> getPredictionHistory() async {
    try {
      final headers = await _getHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/prediksi-jamur/history'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return PredictionHistory.fromJson(data);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        // Token tidak valid, bisa menangani dengan redirect ke login
        throw Exception('Unauthorized: Token expired or invalid');
      } else {
        throw Exception(
          'Failed to load prediction history: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching prediction history: $e');
    }
  }

  // Metode untuk API lainnya yang memerlukan token
  Future<dynamic> postPredictionData(Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();

      final response = await http.post(
        Uri.parse('$baseUrl/prediksi-jamur'),
        headers: headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Unauthorized: Token expired or invalid');
      } else {
        throw Exception(
          'Failed to post prediction data: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error posting prediction data: $e');
    }
  }

  // Metode untuk memeriksa status otentikasi
  Future<bool> isAuthenticated() async {
    final token = await _getToken();
    return token != null && token.isNotEmpty;
  }

  // Metode untuk logout
  Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('idToken');
      await prefs.remove('uid');
      await prefs.remove('userName');
      return true;
    } catch (e) {
      print('Error during logout: $e');
      return false;
    }
  }
}

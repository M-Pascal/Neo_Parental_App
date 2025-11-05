import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/prediction_history_model.dart';

class HistoryService {
  /// Fetch user's prediction history from the API
  Future<List<PredictionHistoryModel>> fetchMyPredictions(
    String? authToken,
  ) async {
    if (authToken == null) {
      throw HistoryException('Authentication required');
    }

    try {
      print('Fetching prediction history...');
      print('   URL: ${ApiConfig.baseUrl}/predictions/me');

      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/predictions/me'),
            headers: {
              'Authorization': 'Bearer $authToken',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 30));

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        print('Fetched ${jsonData.length} predictions');

        return jsonData
            .map((item) => PredictionHistoryModel.fromJson(item))
            .toList();
      } else if (response.statusCode == 401) {
        throw HistoryException('Authentication failed. Please log in again.');
      } else {
        throw HistoryException(
          'Failed to fetch history: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is HistoryException) rethrow;
      print('Error fetching history: $e');
      throw HistoryException('Failed to load history: ${e.toString()}');
    }
  }

  /// Delete a prediction from history
  Future<void> deletePrediction(String predictionId, String? authToken) async {
    if (authToken == null) {
      throw HistoryException('Authentication required');
    }

    try {
      print('Deleting prediction: $predictionId');

      final response = await http
          .delete(
            Uri.parse('${ApiConfig.baseUrl}/predictions/me/$predictionId'),
            headers: {
              'Authorization': 'Bearer $authToken',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 30));

      print('Delete response status: ${response.statusCode}');

      if (response.statusCode == 204) {
        print('Prediction deleted successfully');
      } else if (response.statusCode == 401) {
        throw HistoryException('Authentication failed. Please log in again.');
      } else if (response.statusCode == 403) {
        throw HistoryException('You can only delete your own predictions');
      } else if (response.statusCode == 404) {
        throw HistoryException('Prediction not found');
      } else {
        throw HistoryException(
          'Failed to delete prediction: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is HistoryException) rethrow;
      print('Error deleting prediction: $e');
      throw HistoryException('Failed to delete: ${e.toString()}');
    }
  }
}

class HistoryException implements Exception {
  final String message;

  HistoryException(this.message);

  @override
  String toString() => message;
}

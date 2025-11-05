import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class PredictionService {
  // Use the local API configuration instead of hardcoded Render URL
  static String get baseUrl => ApiConfig.baseUrl;

  /// Predict audio using the trained ML model via API
  /// Requires authentication token
  Future<PredictionResponse> predictAudio(
    String filePath, {
    String? authToken,
  }) async {
    try {
      print('Starting audio prediction...');
      print('   API URL: $baseUrl/predict');
      print('   File: $filePath');
      print('   Auth token: ${authToken != null ? "Present" : "Missing"}');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/predict'),
      );

      // Add authentication header if token is provided
      if (authToken != null) {
        request.headers['Authorization'] = 'Bearer $authToken';
      }

      // Add the audio file
      var file = await http.MultipartFile.fromPath('file', filePath);
      request.files.add(file);

      print(' Sending request to server...');

      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw PredictionException(
            'Request timeout. The server took too long to respond.',
          );
        },
      );

      var response = await http.Response.fromStream(streamedResponse);

      print(' Response status: ${response.statusCode}');
      print(' Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print(' Prediction successful!');
        print('   Predicted label: ${jsonData['predicted_label']}');
        print('   Confidence: ${jsonData['confidence']}%');
        return PredictionResponse.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        throw PredictionException(
          'Authentication required. Please log in again.',
        );
      } else if (response.statusCode == 503) {
        throw PredictionException(
          'Model not available. Please try again later.',
        );
      } else {
        final errorBody = response.body;
        try {
          final errorJson = json.decode(errorBody);
          final errorMessage =
              errorJson['detail'] ?? errorJson['error'] ?? 'Unknown error';
          throw PredictionException('Prediction failed: $errorMessage');
        } catch (e) {
          throw PredictionException(
            'Prediction failed: ${response.statusCode} - $errorBody',
          );
        }
      }
    } on SocketException catch (e) {
      print(' Socket exception: $e');
      throw PredictionException(
        'Network error. Please check your internet connection and ensure the API server is running.',
      );
    } on FormatException catch (e) {
      print(' Format exception: $e');
      throw PredictionException('Invalid response format from server.');
    } on PredictionException {
      rethrow;
    } catch (e) {
      print(' General exception: $e');
      throw PredictionException('Prediction failed: ${e.toString()}');
    }
  }
}

class PredictionResponse {
  final int predictionValue;
  final String predictedLabel;
  final int confidence;
  final double processingTime;
  final String timestamp;

  PredictionResponse({
    required this.predictionValue,
    required this.predictedLabel,
    required this.confidence,
    required this.processingTime,
    required this.timestamp,
  });

  factory PredictionResponse.fromJson(Map<String, dynamic> json) {
    return PredictionResponse(
      predictionValue: (json['prediction_value'] ?? 0) is int
          ? json['prediction_value']
          : (json['prediction_value'] ?? 0).toInt(),
      predictedLabel: json['predicted_label']?.toString() ?? 'Unknown',
      confidence: (json['confidence'] ?? 0) is int
          ? json['confidence']
          : (json['confidence'] ?? 0).toInt(),
      processingTime: (json['processing_time'] ?? 0) is double
          ? json['processing_time']
          : (json['processing_time'] ?? 0).toDouble(),
      timestamp: json['timestamp']?.toString() ?? '',
    );
  }

  String getFormattedTime() {
    try {
      final dateTime = DateTime.parse(timestamp);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'N/A';
    }
  }

  String getFormattedProcessingTime() {
    return '${processingTime.toStringAsFixed(2)}s';
  }
}

class PredictionException implements Exception {
  final String message;

  PredictionException(this.message);

  @override
  String toString() => message;
}

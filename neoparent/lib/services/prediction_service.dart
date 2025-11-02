import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PredictionService {
  static const String baseUrl = 'https://neoparental-fast-api.onrender.com';

  Future<PredictionResponse> predictAudio(String filePath) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/predict'),
      );

      var file = await http.MultipartFile.fromPath('file', filePath);
      request.files.add(file);

      print('Sending request to: $baseUrl/predict');
      print('File: $filePath');

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return PredictionResponse.fromJson(jsonData);
      } else {
        throw PredictionException(
          'Prediction failed: ${response.statusCode} - ${response.body}',
        );
      }
    } on SocketException catch (e) {
      print('Socket exception: $e');
      throw PredictionException(
        'Network error. Please check your internet connection.',
      );
    } on FormatException catch (e) {
      print('Format exception: $e');
      throw PredictionException('Invalid response format from server.');
    } catch (e) {
      print('General exception: $e');
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

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ChatService {
  /// Send a message to the chatbot API and get a response
  Future<String> sendMessage(String message, String? authToken) async {
    if (authToken == null) {
      throw ChatException('Authentication required');
    }

    try {
      print('Sending message to chatbot API...');
      print('   URL: ${ApiConfig.baseUrl}/chat');
      print('   Message: $message');

      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/chat'),
            headers: {
              'Authorization': 'Bearer $authToken',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'message': message}),
          )
          .timeout(const Duration(seconds: 30));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final reply =
            jsonData['reply']?.toString() ??
            'Sorry, I could not process your request.';
        print('Bot reply: $reply');
        return reply;
      } else if (response.statusCode == 401) {
        throw ChatException('Authentication failed. Please log in again.');
      } else {
        final errorBody = response.body;
        try {
          final errorJson = json.decode(errorBody);
          final errorMessage =
              errorJson['detail'] ?? errorJson['error'] ?? 'Unknown error';
          throw ChatException('Chat failed: $errorMessage');
        } catch (e) {
          throw ChatException(
            'Chat failed: ${response.statusCode} - $errorBody',
          );
        }
      }
    } catch (e) {
      if (e is ChatException) rethrow;
      print('Error sending message: $e');
      throw ChatException('Failed to send message: ${e.toString()}');
    }
  }
}

class ChatException implements Exception {
  final String message;

  ChatException(this.message);

  @override
  String toString() => message;
}

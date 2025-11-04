import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  // Automatically detect the correct base URL based on platform
  static String get baseUrl {
    if (kIsWeb) {
      // Web platform
      return 'http://127.0.0.1:8000';
    } else if (Platform.isAndroid) {
      // Android Emulator uses 10.0.2.2 to access host machine
      // For physical Android device, use your computer's IP (e.g., 'http://192.168.1.x:8000')
      return 'http://10.0.2.2:8000';
    } else if (Platform.isIOS) {
      // iOS Simulator can use localhost
      // For physical iOS device, use your computer's IP (e.g., 'http://192.168.1.x:8000')
      return 'http://127.0.0.1:8000';
    } else {
      // Windows, macOS, Linux desktop
      return 'http://127.0.0.1:8000';
    }
  }

  // Manual override for physical devices (uncomment and set your IP)
  // static const String baseUrl = 'http://192.168.1.100:8000';

  // Auth endpoints
  static const String registerEndpoint = '/register';
  static const String loginEndpoint = '/login';
  static const String usersMeEndpoint = '/users/me';
  static const String healthEndpoint = '/health';

  // Full URLs
  static String get registerUrl => '$baseUrl$registerEndpoint';
  static String get loginUrl => '$baseUrl$loginEndpoint';
  static String get usersMeUrl => '$baseUrl$usersMeEndpoint';
  static String get healthUrl => '$baseUrl$healthEndpoint';

  // Request timeout duration
  static const Duration requestTimeout = Duration(seconds: 30);

  // Helper method to test connection
  static void printConnectionInfo() {
    final currentUrl = baseUrl;
    print('🔌 API Configuration:');
    print('   Platform: ${_getPlatformName()}');
    print('   Base URL: $currentUrl');
    print('   Register: $registerUrl');
    print('   Login: $loginUrl');
    print('   User Profile: $usersMeUrl');
    print('   Health Check: $healthUrl');
  }

  static String _getPlatformName() {
    if (kIsWeb) return 'Web';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }

  // Test connection method
  static Future<bool> testConnection() async {
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 5);

      final request = await client.getUrl(Uri.parse(healthUrl));
      final response = await request.close();

      print(' Connection test successful: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print(' Connection test failed: $e');
      return false;
    }
  }
}

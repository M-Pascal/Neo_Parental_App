import 'package:flutter/material.dart';

/// Application color constants
class AppColors {
  // Primary colors
  static const Color primary = Color(0xFFD64612); // RGB(214, 70, 18)
  static const Color primaryLight = Color(0xFFFF6B35);
  static const Color primaryDark = Color(0xFFD2691E);

  // Secondary colors
  static const Color secondary = Color(0xFFFB8239);

  // Neutral colors
  static const Color white = Colors.white;
  static const Color black = Colors.black87;
  static const Color grey = Colors.grey;
  static const Color greyLight = Color(0xFFF5F5F5);

  // Status colors
  static const Color success = Colors.green;
  static const Color error = Colors.red;
  static const Color warning = Colors.orange;
  static const Color info = Colors.blue;

  // Background colors
  static const Color background = Colors.white;
  static const Color cardBackground = Colors.white;

  /// Gradient colors
  static LinearGradient get primaryGradient => const LinearGradient(
    colors: [primaryLight, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

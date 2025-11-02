import 'package:flutter/foundation.dart';

/// Provider for managing bottom navigation state
class NavigationProvider with ChangeNotifier {
  int _selectedIndex = 0;

  /// Get current selected navigation index
  int get selectedIndex => _selectedIndex;

  /// Set selected navigation index
  void setSelectedIndex(int index) {
    if (_selectedIndex != index) {
      _selectedIndex = index;
      notifyListeners();
    }
  }

  /// Navigate to home
  void navigateToHome() => setSelectedIndex(0);

  /// Navigate to audio/record
  void navigateToAudio() => setSelectedIndex(1);

  /// Navigate to history
  void navigateToHistory() => setSelectedIndex(2);

  /// Navigate to chat
  void navigateToChat() => setSelectedIndex(3);
}

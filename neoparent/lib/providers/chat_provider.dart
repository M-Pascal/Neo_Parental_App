import 'package:flutter/foundation.dart';
import '../services/chat_service.dart';

/// Provider for managing chat state across the app
class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  /// Get all chat messages
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  /// Get typing state
  bool get isTyping => _isTyping;

  /// Initialize with welcome message
  ChatProvider() {
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    if (_messages.isEmpty) {
      _messages.add(
        ChatMessage(
          text:
              "Hello! I'm your NeoParental assistant. How can I help you with your baby today?",
          isBot: true,
          timestamp: DateTime.now(),
          isDelivered: true,
        ),
      );
    }
  }

  /// Add a user message
  void addUserMessage(String text) {
    _messages.add(
      ChatMessage(
        text: text,
        isBot: false,
        timestamp: DateTime.now(),
        isDelivered: false,
      ),
    );
    notifyListeners();
  }

  /// Mark last user message as delivered
  void markLastMessageDelivered() {
    if (_messages.isNotEmpty && !_messages.last.isBot) {
      final lastMessage = _messages.last;
      _messages[_messages.length - 1] = ChatMessage(
        text: lastMessage.text,
        isBot: false,
        timestamp: lastMessage.timestamp,
        isDelivered: true,
      );
      notifyListeners();
    }
  }

  /// Set typing indicator state
  void setTyping(bool typing) {
    _isTyping = typing;
    notifyListeners();
  }

  /// Add a bot message
  void addBotMessage(String text) {
    _messages.add(
      ChatMessage(
        text: text,
        isBot: true,
        timestamp: DateTime.now(),
        isDelivered: true,
      ),
    );
    notifyListeners();
  }

  /// Send a message to the chatbot API
  Future<void> sendMessage(String message, String? authToken) async {
    if (authToken == null) {
      throw Exception('Authentication required');
    }

    try {
      // Add user message
      addUserMessage(message);

      // Mark as delivered after short delay
      await Future.delayed(const Duration(milliseconds: 300));
      markLastMessageDelivered();

      // Show typing indicator
      await Future.delayed(const Duration(milliseconds: 500));
      setTyping(true);

      // Get bot response from API
      final response = await _chatService.sendMessage(message, authToken);

      // Hide typing indicator and add bot response
      setTyping(false);
      addBotMessage(response);
    } catch (e) {
      // Hide typing indicator
      setTyping(false);

      // Add error message
      addBotMessage('Sorry, I encountered an error. Please try again later.');

      rethrow;
    }
  }

  /// Clear all messages (called on logout)
  void clearMessages() {
    _messages.clear();
    _isTyping = false;
    _addWelcomeMessage();
    notifyListeners();
  }

  /// Reset to initial state
  void reset() {
    clearMessages();
  }
}

/// Model for chat messages
class ChatMessage {
  final String text;
  final bool isBot;
  final DateTime timestamp;
  final bool isDelivered;

  ChatMessage({
    required this.text,
    required this.isBot,
    required this.timestamp,
    this.isDelivered = false,
  });
}

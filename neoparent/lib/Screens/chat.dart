import 'package:flutter/material.dart';
import './profile.dart';
import './register.dart';
import './main_navigation.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    // Add a welcome message
    _messages.add(
      ChatMessage(
        text:
            "Hello! I'm your NeoParental assistant. How can I help you with your baby today?",
        isBot: true,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: _buildSideDrawer(),
      body: Column(
        children: [
          // Header Section
          _buildHeaderSection(),

          // Chat Messages
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: _messages.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        return _buildMessageBubble(_messages[index]);
                      },
                    ),
            ),
          ),

          // Message Input
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFD2691E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(45.0),
          bottomRight: Radius.circular(45.0),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 10,
          left: 20.0,
          right: 20.0,
          bottom: 30.0,
        ),
        child: Column(
          children: [
            // Top row with menu and notification icons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Menu Icon
                IconButton(
                  icon: const Icon(
                    Icons.menu_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                ),

                // Notification Icon
                IconButton(
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                    size: 26,
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notifications pressed!'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 15),

            // Title
            const Text(
              'Virtual\nAssistant',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                height: 1.0,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Subtitle
            const Text(
              'Your parenting companion.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w300,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isBot
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: [
          if (message.isBot) ...[
            CircleAvatar(
              backgroundColor: const Color(0xFFFF6B35),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isBot
                    ? Colors.grey[100]
                    : const Color(0xFFFF6B35),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isBot ? Colors.black87 : Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          if (!message.isBot) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.grey[300],
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: Color(0xFFFF6B35)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              onSubmitted: (value) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFF6B35),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Start a Conversation',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ask me anything about parenting and baby care',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          text: _messageController.text.trim(),
          isBot: false,
          timestamp: DateTime.now(),
        ),
      );
    });

    // Simulate bot response
    _simulateBotResponse(_messageController.text.trim());
    _messageController.clear();
  }

  void _simulateBotResponse(String userMessage) {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      String response = _generateBotResponse(userMessage);

      setState(() {
        _messages.add(
          ChatMessage(text: response, isBot: true, timestamp: DateTime.now()),
        );
      });
    });
  }

  String _generateBotResponse(String userMessage) {
    final message = userMessage.toLowerCase();

    if (message.contains('cry') || message.contains('crying')) {
      return "Crying can indicate different needs. Try the cry analysis feature in the Audio section to understand what your baby might need - hunger, tiredness, discomfort, or pain.";
    } else if (message.contains('feed') || message.contains('hungry')) {
      return "For feeding, newborns typically eat every 2-3 hours. Watch for hunger cues like lip smacking, rooting, or putting hands to mouth.";
    } else if (message.contains('sleep') || message.contains('tired')) {
      return "Sleep patterns vary by age. Newborns sleep 14-17 hours daily. Create a calm environment with dim lights and soft sounds for better sleep.";
    } else if (message.contains('help') || message.contains('advice')) {
      return "I'm here to help! You can ask me about feeding, sleep, development milestones, or use the audio analysis feature to understand your baby's cries.";
    } else {
      return "That's a great question! While I can provide general guidance, always consult your pediatrician for specific medical concerns. Feel free to use our cry analysis feature for real-time insights.";
    }
  }

  Widget _buildSideDrawer() {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFF6B35), Color(0xFFD2691E)],
          ),
        ),
        child: Column(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.transparent),
              child: Center(
                child: Text(
                  'NeoParental',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildMenuItem(Icons.home, 'Home', () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainNavigationPage(),
                      ),
                    );
                  }),
                  _buildMenuItem(Icons.mic, 'Audio', () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainNavigationPage(),
                      ),
                    );
                  }),
                  _buildMenuItem(Icons.history, 'History', () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainNavigationPage(),
                      ),
                    );
                  }),
                  _buildMenuItem(Icons.chat, 'Chat', () {
                    Navigator.pop(context);
                    // Already on chat page
                  }),
                  _buildMenuItem(Icons.person, 'Profile', () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfilePage(),
                      ),
                    );
                  }),
                  const Divider(color: Colors.white30),
                  _buildMenuItem(Icons.logout, 'Logout', () {
                    _showLogoutDialog();
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterPage()),
                  (route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

// Data model for chat messages
class ChatMessage {
  final String text;
  final bool isBot;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isBot,
    required this.timestamp,
  });
}

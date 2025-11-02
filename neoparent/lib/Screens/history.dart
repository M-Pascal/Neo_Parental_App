import 'package:flutter/material.dart';
import './main_navigation.dart';
import './profile.dart';
import './register.dart';
import './chat.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // Sample history data
  final List<HistoryItem> _historyItems = [
    HistoryItem(
      id: '1',
      date: DateTime.now().subtract(const Duration(hours: 2)),
      duration: const Duration(seconds: 15),
      analysis: 'Hunger',
      confidence: 89,
      status: AnalysisStatus.completed,
    ),
    HistoryItem(
      id: '2',
      date: DateTime.now().subtract(const Duration(days: 1)),
      duration: const Duration(seconds: 23),
      analysis: 'Discomfort',
      confidence: 76,
      status: AnalysisStatus.completed,
    ),
    HistoryItem(
      id: '3',
      date: DateTime.now().subtract(const Duration(days: 2)),
      duration: const Duration(seconds: 18),
      analysis: 'Tired',
      confidence: 82,
      status: AnalysisStatus.completed,
    ),
    HistoryItem(
      id: '4',
      date: DateTime.now().subtract(const Duration(days: 3)),
      duration: const Duration(seconds: 12),
      analysis: 'Pain',
      confidence: 65,
      status: AnalysisStatus.lowConfidence,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: _buildSideDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section with Orange Background
          _buildHeaderSection(),

          // Content Section with padding
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),

                  // History List Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Recordings',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Navigate to detailed history
                        },
                        child: const Text(
                          'View All',
                          style: TextStyle(
                            color: Color(0xFFFF6B35),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // History List
                  Expanded(
                    child: _historyItems.isNotEmpty
                        ? ListView.separated(
                            itemCount: _historyItems.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              return _buildHistoryCard(_historyItems[index]);
                            },
                          )
                        : _buildEmptyState(),
                  ),
                ],
              ),
            ),
          ),
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
          top:
              MediaQuery.of(context).padding.top +
              10, // Status bar height + extra padding
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
              'History',
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
              'Analysis of sounds and uploads',
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

  Widget _buildHistoryCard(HistoryItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getAnalysisColor(item.analysis).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getAnalysisIcon(item.analysis),
                      size: 20,
                      color: _getAnalysisColor(item.analysis),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.analysis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        '${item.confidence}% confidence',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
              _buildStatusChip(item.status),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDateTime(item.date),
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              Text(
                'Duration: ${_formatDuration(item.duration)}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _playRecording(item),
                  icon: const Icon(Icons.play_arrow_rounded, size: 18),
                  label: const Text('Play'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFF6B35),
                    side: const BorderSide(color: Color(0xFFFF6B35)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _shareAnalysis(item),
                  icon: const Icon(Icons.description_outlined, size: 18),
                  label: const Text('Details'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(AnalysisStatus status) {
    Color color;
    String text;

    switch (status) {
      case AnalysisStatus.completed:
        color = Colors.green;
        text = 'Completed';
        break;
      case AnalysisStatus.lowConfidence:
        color = Colors.orange;
        text = 'Low Confidence';
        break;
      case AnalysisStatus.failed:
        color = Colors.red;
        text = 'Failed';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Recordings Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start recording your baby\'s cries to see analysis history here',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helper methods

  Color _getAnalysisColor(String analysis) {
    switch (analysis.toLowerCase()) {
      case 'hunger':
        return Colors.orange;
      case 'discomfort':
        return Colors.red;
      case 'tired':
        return Colors.blue;
      case 'pain':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getAnalysisIcon(String analysis) {
    switch (analysis.toLowerCase()) {
      case 'hunger':
        return Icons.restaurant;
      case 'discomfort':
        return Icons.sentiment_dissatisfied;
      case 'tired':
        return Icons.bedtime;
      case 'pain':
        return Icons.healing;
      default:
        return Icons.help_outline;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  String _formatDuration(Duration duration) {
    return '${duration.inSeconds}s';
  }

  void _playRecording(HistoryItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Playing recording from ${_formatDateTime(item.date)}'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareAnalysis(HistoryItem item) {
    _showRecommendationDialog(item);
  }

  void _showRecommendationDialog(HistoryItem item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Colored header section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF6B35), Color(0xFFD2691E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                child: const Text(
                  'Recommendation',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // White content section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Lorem ipsum dolor sit amet consectetur adipiscing elit sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 20),
                    // Close button
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Close',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B35),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          minimumSize: const Size(100, 36),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
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
                    // Already on history page
                  }),
                  _buildMenuItem(Icons.chat, 'Chat', () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ChatPage()),
                    );
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
}

// Data models
class HistoryItem {
  final String id;
  final DateTime date;
  final Duration duration;
  final String analysis;
  final int confidence;
  final AnalysisStatus status;

  HistoryItem({
    required this.id,
    required this.date,
    required this.duration,
    required this.analysis,
    required this.confidence,
    required this.status,
  });
}

enum AnalysisStatus { completed, lowConfidence, failed }

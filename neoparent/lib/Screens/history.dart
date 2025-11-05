import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/history_service.dart';
import '../models/prediction_history_model.dart';
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
  final HistoryService _historyService = HistoryService();
  List<PredictionHistoryModel> _predictions = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPredictions();
  }

  Future<void> _loadPredictions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final authToken = authProvider.accessToken;

    try {
      final predictions = await _historyService.fetchMyPredictions(authToken);
      setState(() {
        _predictions = predictions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

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
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _errorMessage != null
                        ? _buildErrorState()
                        : _predictions.isNotEmpty
                        ? RefreshIndicator(
                            onRefresh: _loadPredictions,
                            child: ListView.separated(
                              itemCount: _predictions.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                return _buildHistoryCard(_predictions[index]);
                              },
                            ),
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

  Widget _buildHistoryCard(PredictionHistoryModel item) {
    final confidence = item.confidence?.toInt() ?? 0;
    final label = item.predictedLabel ?? 'Unknown';

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
                      color: _getAnalysisColor(label).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getAnalysisIcon(label),
                      size: 20,
                      color: _getAnalysisColor(label),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        '${confidence}% confidence',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
              _buildStatusChip(confidence),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  item.getFormattedDate(),
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: Text(
                  item.audioFilename,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
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
                  onPressed: () => _showDetailsDialog(item),
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

  Widget _buildStatusChip(int confidence) {
    Color color;
    String text;

    if (confidence >= 75) {
      color = Colors.green;
      text = 'High Confidence';
    } else if (confidence >= 50) {
      color = Colors.orange;
      text = 'Medium Confidence';
    } else {
      color = Colors.red;
      text = 'Low Confidence';
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

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Failed to Load History',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage ?? 'An error occurred',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadPredictions,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
              foregroundColor: Colors.white,
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
      case 'hungry':
        return Colors.orange;
      case 'belly_pain':
        return Colors.purple;
      case 'burping':
        return Colors.blue;
      case 'discomfort':
        return Colors.red;
      case 'tired/sleepy':
      case 'tired':
      case 'sleepy':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  IconData _getAnalysisIcon(String analysis) {
    switch (analysis.toLowerCase()) {
      case 'hungry':
        return Icons.restaurant;
      case 'belly_pain':
        return Icons.healing;
      case 'burping':
        return Icons.air;
      case 'discomfort':
        return Icons.sentiment_dissatisfied;
      case 'tired/sleepy':
      case 'tired':
      case 'sleepy':
        return Icons.bedtime;
      default:
        return Icons.help_outline;
    }
  }

  void _playRecording(PredictionHistoryModel item) {
    // TODO: Implement audio playback from Cloudinary URL
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Playing: ${item.audioFilename}'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showDetailsDialog(PredictionHistoryModel item) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: EdgeInsets.zero,
          content: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B35), Color(0xFFD2691E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.analytics,
                        color: Colors.white,
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Prediction Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.audioFilename,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(
                        'Baby Needs',
                        item.predictedLabel ?? 'Unknown',
                        Icons.baby_changing_station,
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow(
                        'Confidence',
                        item.getConfidenceText(),
                        Icons.analytics,
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow(
                        'Date & Time',
                        item.getFormattedDate(),
                        Icons.access_time,
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow(
                        'Prediction Value',
                        item.predictionValue.toString(),
                        Icons.numbers,
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: Colors.orange[700],
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'AI Recommendation',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _getRecommendation(item.predictedLabel ?? 'Unknown'),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6B35),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Close',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFFF6B35).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFFFF6B35), size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getRecommendation(String predictedLabel) {
    switch (predictedLabel.toLowerCase()) {
      case 'hungry':
        return 'Your baby might be hungry. Try feeding them or offering a bottle/breast.';
      case 'belly_pain':
        return 'Your baby may have belly discomfort. Try gentle tummy massage, burping, or bicycle leg movements.';
      case 'burping':
        return 'Your baby needs to burp. Hold them upright and gently pat their back.';
      case 'discomfort':
        return 'Your baby seems uncomfortable. Check their diaper, temperature, and clothing. Comfort them with gentle rocking.';
      case 'tired/sleepy':
      case 'tired':
      case 'sleepy':
        return 'Your baby is tired and needs rest. Create a calm environment and help them settle down for sleep.';
      default:
        return 'Monitor your baby\'s condition. If crying persists or you\'re concerned, consult your pediatrician.';
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

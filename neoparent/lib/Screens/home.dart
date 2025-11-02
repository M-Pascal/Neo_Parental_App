import 'package:flutter/material.dart';
import './login.dart';
import './main_navigation.dart';
import './profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // Track selected navigation item

  // Track expanded state for parenting skills cards
  Map<int, bool> _expandedCards = {};

  // Sample history data for statistics
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

  // Parenting skills data
  final List<ParentingSkill> _parentingSkills = [
    ParentingSkill(
      id: 1,
      title: 'Understanding Baby Cries',
      shortContent:
          'Learn to identify different types of baby cries and respond appropriately.',
      fullContent:
          'Understanding your baby\'s cries is crucial for effective parenting. Different cries indicate different needs:\n\n• Hunger cries are rhythmic and repetitive\n• Tired cries are often whiny and continuous\n• Pain cries are sudden and piercing\n• Discomfort cries vary in intensity\n\nPay attention to timing, context, and accompanying body language to better understand what your baby is communicating.',
      imageAsset: './assets/parents_01.jpg',
    ),
    ParentingSkill(
      id: 2,
      title: 'Safe Sleep Practices',
      shortContent:
          'Essential guidelines for creating a safe sleeping environment for your baby.',
      fullContent:
          'Safe sleep is vital for your baby\'s health and reduces SIDS risk:\n\n• Always place baby on their back to sleep\n• Use a firm sleep surface\n• Keep the crib bare - no blankets, pillows, or toys\n• Avoid smoke exposure\n• Room-share without bed-sharing\n• Breastfeed if possible\n\nMaintain a comfortable room temperature and dress your baby in light sleep clothing.',
      imageAsset: './assets/parents_01.jpg',
    ),
    ParentingSkill(
      id: 3,
      title: 'Feeding Techniques',
      shortContent:
          'Master proper feeding techniques for both breastfeeding and bottle feeding.',
      fullContent:
          'Proper feeding techniques ensure your baby gets adequate nutrition:\n\n• For breastfeeding: Ensure proper latch, comfortable positioning\n• Feed on demand, typically every 2-3 hours\n• Watch for hunger cues: rooting, lip smacking, hand-to-mouth\n• Burp baby during and after feeding\n• For bottle feeding: Hold baby upright, tilt bottle to avoid air bubbles\n\nEvery baby is different, so follow your baby\'s cues and consult your pediatrician for guidance.',
      imageAsset: './assets/parents_01.jpg',
    ),
    ParentingSkill(
      id: 4,
      title: 'Bonding & Development',
      shortContent:
          'Build strong emotional connections and support your baby\'s development.',
      fullContent:
          'Bonding and development go hand in hand:\n\n• Talk and sing to your baby regularly\n• Make eye contact during feeding and play\n• Practice skin-to-skin contact\n• Read to your baby daily\n• Provide tummy time when awake\n• Respond consistently to baby\'s needs\n• Play simple games like peek-a-boo\n\nThese activities stimulate brain development and strengthen your emotional bond.',
      imageAsset: './assets/parents_01.jpg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: Colors.black87, size: 28),
          onPressed: () {
            // Navigate back to login page
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          },
        ),
        centerTitle: true,
        actions: [
          // Notification Icon
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: Colors.black87,
              size: 26,
            ),
            onPressed: () {
              // notification functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notifications pressed!'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          // Profile Icon
          IconButton(
            icon: const Icon(
              Icons.person_outline,
              color: Colors.black87,
              size: 26,
            ),
            onPressed: () {
              // Navigate to profile page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B35), Color(0xFFD2691E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Text Section (Left Side)
                  const Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Good Morning,',
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                        const Text(
                          'John Doe',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Welcome to NeoParental\nYour parenting companion',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Image Section (Right Side)
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/family_01.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback to icon if image fails to load
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.family_restroom,
                                  size: 60,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Statistics Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Statistics',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStatisticsSection(),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Parenting Skills Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Parenting Skills',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildParentingSkillsSection(),
                ],
              ),
            ),

            const SizedBox(height: 100), // Extra space for bottom navigation
          ],
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFFF6B35),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6B35).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(icon: Icons.home, label: 'Home', index: 0),
            _buildNavItem(icon: Icons.hearing, label: 'Audio', index: 1),
            _buildNavItem(icon: Icons.history, label: 'History', index: 2),
            _buildNavItem(icon: Icons.chat, label: 'Chat', index: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });

        // Navigate to main navigation page with the selected index
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationPage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFFFF6B35) : Colors.white,
              size: 24,
            ),
            // Show text for all buttons when selected
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFFFF6B35),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'This Week',
            value:
                '${_historyItems.where((item) => item.date.isAfter(DateTime.now().subtract(const Duration(days: 7)))).length}',
            icon: Icons.calendar_today,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Avg Confidence',
            value: '${_calculateAverageConfidence()}%',
            icon: Icons.trending_up,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Most Common',
            value: _getMostCommonAnalysis(),
            icon: Icons.analytics,
            color: Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
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
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helper methods
  int _calculateAverageConfidence() {
    if (_historyItems.isEmpty) return 0;
    int total = _historyItems.fold(0, (sum, item) => sum + item.confidence);
    return total ~/ _historyItems.length;
  }

  String _getMostCommonAnalysis() {
    if (_historyItems.isEmpty) return 'N/A';
    Map<String, int> analysisCount = {};
    for (var item in _historyItems) {
      analysisCount[item.analysis] = (analysisCount[item.analysis] ?? 0) + 1;
    }
    return analysisCount.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  Widget _buildParentingSkillsSection() {
    return Column(
      children: _parentingSkills.map((skill) {
        bool isExpanded = _expandedCards[skill.id] ?? false;
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image placeholder (since we don't have actual images)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFF6B35).withOpacity(0.8),
                      const Color(0xFFD2691E).withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(
                    _getSkillIcon(skill.id),
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      skill.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Content (short or full based on expanded state)
                    Text(
                      isExpanded ? skill.fullContent : skill.shortContent,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 12),

                    // Read more/less button
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _expandedCards[skill.id] = !isExpanded;
                        });
                      },
                      child: Row(
                        children: [
                          Text(
                            isExpanded ? 'Read less' : 'Read more',
                            style: const TextStyle(
                              color: Color(0xFFFF6B35),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: const Color(0xFFFF6B35),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  IconData _getSkillIcon(int skillId) {
    switch (skillId) {
      case 1:
        return Icons.hearing; // Understanding Baby Cries
      case 2:
        return Icons.bedtime; // Safe Sleep Practices
      case 3:
        return Icons.restaurant; // Feeding Techniques
      case 4:
        return Icons.favorite; // Bonding & Development
      default:
        return Icons.info;
    }
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

// Parenting skill data model
class ParentingSkill {
  final int id;
  final String title;
  final String shortContent;
  final String fullContent;
  final String imageAsset;

  ParentingSkill({
    required this.id,
    required this.title,
    required this.shortContent,
    required this.fullContent,
    required this.imageAsset,
  });
}

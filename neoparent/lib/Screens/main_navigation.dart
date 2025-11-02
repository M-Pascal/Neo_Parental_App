import 'dart:async';
import 'package:flutter/material.dart';
import './register.dart';
import './record.dart';
import './history.dart';
import './profile.dart';
import './chat.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  // List of pages to display
  final List<Widget> _pages = [
    const HomeContentPage(),
    const RecordPage(),
    const HistoryPage(),
    const ChatPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: _buildSideDrawer(),
      appBar: _selectedIndex != 2 && _selectedIndex != 1 && _selectedIndex != 3
          ? AppBar(
              // Hide AppBar for History page (index 2), Record page (index 1), and Chat page (index 3)
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.menu_rounded,
                  color: Colors.black87,
                  size: 28,
                ),
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
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
                      MaterialPageRoute(
                        builder: (context) => const ProfilePage(),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
              ],
            )
          : null, // No AppBar for History and Record pages
      body: _pages[_selectedIndex],
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
                    setState(() => _selectedIndex = 0);
                  }),
                  _buildMenuItem(Icons.mic, 'Audio', () {
                    Navigator.pop(context);
                    setState(() => _selectedIndex = 1);
                  }),
                  _buildMenuItem(Icons.history, 'History', () {
                    Navigator.pop(context);
                    setState(() => _selectedIndex = 2);
                  }),
                  _buildMenuItem(Icons.chat, 'Chat', () {
                    Navigator.pop(context);
                    setState(() => _selectedIndex = 3);
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

// Create a separate widget for the home content without scaffold
class HomeContentPage extends StatefulWidget {
  const HomeContentPage({super.key});

  @override
  State<HomeContentPage> createState() => _HomeContentPageState();
}

class _HomeContentPageState extends State<HomeContentPage> {
  // Track expanded state for parenting skills cards
  Map<int, bool> _expandedCards = {};

  // Current skill index for rotation
  int _currentSkillIndex = 0;
  Timer? _skillRotationTimer;

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
      imageAsset: 'assets/images/baby_crying.png',
    ),
    ParentingSkill(
      id: 2,
      title: 'Safe Sleep Practices',
      shortContent:
          'Essential guidelines for creating a safe sleeping environment for your baby.',
      fullContent:
          'Safe sleep is vital for your baby\'s health and reduces SIDS risk:\n\n• Always place baby on their back to sleep\n• Use a firm sleep surface\n• Keep the crib bare - no blankets, pillows, or toys\n• Avoid smoke exposure\n• Room-share without bed-sharing\n• Breastfeed if possible\n\nMaintain a comfortable room temperature and dress your baby in light sleep clothing.',
      imageAsset: 'assets/images/safe_sleep.png',
    ),
    ParentingSkill(
      id: 3,
      title: 'Feeding Techniques',
      shortContent:
          'Master proper feeding techniques for both breastfeeding and bottle feeding.',
      fullContent:
          'Proper feeding techniques ensure your baby gets adequate nutrition:\n\n• For breastfeeding: Ensure proper latch, comfortable positioning\n• Feed on demand, typically every 2-3 hours\n• Watch for hunger cues: rooting, lip smacking, hand-to-mouth\n• Burp baby during and after feeding\n• For bottle feeding: Hold baby upright, tilt bottle to avoid air bubbles\n\nEvery baby is different, so follow your baby\'s cues and consult your pediatrician for guidance.',
      imageAsset: 'assets/images/feeding.png',
    ),
    ParentingSkill(
      id: 4,
      title: 'Bonding & Development',
      shortContent:
          'Build strong emotional connections and support your baby\'s development.',
      fullContent:
          'Bonding and development go hand in hand:\n\n• Talk and sing to your baby regularly\n• Make eye contact during feeding and play\n• Practice skin-to-skin contact\n• Read to your baby daily\n• Provide tummy time when awake\n• Respond consistently to baby\'s needs\n• Play simple games like peek-a-boo\n\nThese activities stimulate brain development and strengthen your emotional bond.',
      imageAsset: 'assets/images/bonding.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startSkillRotation();
  }

  @override
  void dispose() {
    _skillRotationTimer?.cancel();
    super.dispose();
  }

  void _startSkillRotation() {
    _skillRotationTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _currentSkillIndex =
              (_currentSkillIndex + 1) % _parentingSkills.length;
          // Clear expanded state when switching to new skill
          _expandedCards.clear();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                      Text(
                        'Good Morning,',
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                      Text(
                        'John Doe',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
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
    if (_parentingSkills.isEmpty) return const SizedBox.shrink();

    final skill = _parentingSkills[_currentSkillIndex];
    final isExpanded = _expandedCards[skill.id] ?? false;

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
          // Image section with title overlay (always present)
          Stack(
            children: [
              // Background image
              Container(
                height: 220,
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: Image.asset(
                    'assets/parents_01.jpg',
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback to gradient background if image fails to load
                      return Container(
                        height: 220,
                        width: double.infinity,
                        decoration: BoxDecoration(
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
                      );
                    },
                  ),
                ),
              ),

              // Title and short content overlay (always present)
              Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.0),
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title (always visible)
                    Text(
                      skill.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Short content (only when collapsed)
                    if (!isExpanded)
                      Text(
                        skill.shortContent,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),

          // Read more/less button section (below the image)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: GestureDetector(
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
          ), // Expanded content section (only when expanded)
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Full content
                  Text(
                    skill.fullContent,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 8),

                  // Skill indicator dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_parentingSkills.length, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index == _currentSkillIndex
                              ? const Color(0xFFFF6B35)
                              : Colors.grey[300],
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
        ],
      ),
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

// Data models (if not already defined elsewhere)
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

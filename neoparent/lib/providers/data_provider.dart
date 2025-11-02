import 'package:flutter/foundation.dart';
import '../models/history_item_model.dart';
import '../models/parenting_skill_model.dart';

/// Provider for managing history items
class HistoryProvider with ChangeNotifier {
  List<HistoryItemModel> _historyItems = [];

  /// Get all history items
  List<HistoryItemModel> get historyItems => [..._historyItems];

  /// Get history items from the last week
  List<HistoryItemModel> get thisWeekItems {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return _historyItems.where((item) => item.date.isAfter(weekAgo)).toList();
  }

  /// Calculate average confidence from all history items
  int get averageConfidence {
    if (_historyItems.isEmpty) return 0;
    final total = _historyItems.fold<int>(
      0,
      (sum, item) => sum + item.confidence,
    );
    return total ~/ _historyItems.length;
  }

  /// Get most common analysis type
  String get mostCommonAnalysis {
    if (_historyItems.isEmpty) return 'N/A';

    final analysisCount = <String, int>{};
    for (var item in _historyItems) {
      analysisCount[item.analysis] = (analysisCount[item.analysis] ?? 0) + 1;
    }

    return analysisCount.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Initialize with sample data
  void initializeSampleData() {
    _historyItems = [
      HistoryItemModel(
        id: '1',
        date: DateTime.now().subtract(const Duration(hours: 2)),
        duration: const Duration(seconds: 15),
        analysis: 'Hunger',
        confidence: 89,
        status: AnalysisStatus.completed,
      ),
      HistoryItemModel(
        id: '2',
        date: DateTime.now().subtract(const Duration(days: 1)),
        duration: const Duration(seconds: 23),
        analysis: 'Discomfort',
        confidence: 76,
        status: AnalysisStatus.completed,
      ),
      HistoryItemModel(
        id: '3',
        date: DateTime.now().subtract(const Duration(days: 2)),
        duration: const Duration(seconds: 18),
        analysis: 'Tired',
        confidence: 82,
        status: AnalysisStatus.completed,
      ),
      HistoryItemModel(
        id: '4',
        date: DateTime.now().subtract(const Duration(days: 3)),
        duration: const Duration(seconds: 12),
        analysis: 'Pain',
        confidence: 65,
        status: AnalysisStatus.lowConfidence,
      ),
    ];
    notifyListeners();
  }

  /// Add new history item
  void addHistoryItem(HistoryItemModel item) {
    _historyItems.insert(0, item);
    notifyListeners();
  }

  /// Remove history item by id
  void removeHistoryItem(String id) {
    _historyItems.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  /// Update history item
  void updateHistoryItem(HistoryItemModel updatedItem) {
    final index = _historyItems.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      _historyItems[index] = updatedItem;
      notifyListeners();
    }
  }

  /// Clear all history items
  void clearHistory() {
    _historyItems.clear();
    notifyListeners();
  }
}

/// Provider for managing parenting skills content
class ParentingSkillsProvider with ChangeNotifier {
  List<ParentingSkillModel> _skills = [];
  int _currentSkillIndex = 0;
  final Map<int, bool> _expandedStates = {};

  /// Get all parenting skills
  List<ParentingSkillModel> get skills => [..._skills];

  /// Get current skill index for carousel
  int get currentSkillIndex => _currentSkillIndex;

  /// Get current skill
  ParentingSkillModel? get currentSkill {
    if (_skills.isEmpty) return null;
    return _skills[_currentSkillIndex];
  }

  /// Check if a skill is expanded
  bool isSkillExpanded(int skillId) => _expandedStates[skillId] ?? false;

  /// Initialize parenting skills with sample data
  void initializeSampleData() {
    _skills = [
      ParentingSkillModel(
        id: 1,
        title: 'Understanding Baby Cries',
        shortContent:
            'Learn to identify different types of baby cries and respond appropriately.',
        fullContent:
            'Understanding your baby\'s cries is crucial for effective parenting. Different cries indicate different needs:\n\n• Hunger cries are rhythmic and repetitive\n• Tired cries are often whiny and continuous\n• Pain cries are sudden and piercing\n• Discomfort cries vary in intensity\n\nPay attention to timing, context, and accompanying body language to better understand what your baby is communicating.',
        imageAsset: 'assets/parents_01.jpg',
        tags: ['crying', 'communication', 'needs'],
      ),
      ParentingSkillModel(
        id: 2,
        title: 'Safe Sleep Practices',
        shortContent:
            'Essential guidelines for creating a safe sleeping environment for your baby.',
        fullContent:
            'Safe sleep is vital for your baby\'s health and reduces SIDS risk:\n\n• Always place baby on their back to sleep\n• Use a firm sleep surface\n• Keep the crib bare - no blankets, pillows, or toys\n• Avoid smoke exposure\n• Room-share without bed-sharing\n• Breastfeed if possible\n\nMaintain a comfortable room temperature and dress your baby in light sleep clothing.',
        imageAsset: 'assets/parents_01.jpg',
        tags: ['sleep', 'safety', 'SIDS'],
      ),
      ParentingSkillModel(
        id: 3,
        title: 'Feeding Techniques',
        shortContent:
            'Master proper feeding techniques for both breastfeeding and bottle feeding.',
        fullContent:
            'Proper feeding techniques ensure your baby gets adequate nutrition:\n\n• For breastfeeding: Ensure proper latch, comfortable positioning\n• Feed on demand, typically every 2-3 hours\n• Watch for hunger cues: rooting, lip smacking, hand-to-mouth\n• Burp baby during and after feeding\n• For bottle feeding: Hold baby upright, tilt bottle to avoid air bubbles\n\nEvery baby is different, so follow your baby\'s cues and consult your pediatrician for guidance.',
        imageAsset: 'assets/parents_01.jpg',
        tags: ['feeding', 'nutrition', 'breastfeeding'],
      ),
      ParentingSkillModel(
        id: 4,
        title: 'Bonding & Development',
        shortContent:
            'Build strong emotional connections and support your baby\'s development.',
        fullContent:
            'Bonding and development go hand in hand:\n\n• Talk and sing to your baby regularly\n• Make eye contact during feeding and play\n• Practice skin-to-skin contact\n• Read to your baby daily\n• Provide tummy time when awake\n• Respond consistently to baby\'s needs\n• Play simple games like peek-a-boo\n\nThese activities stimulate brain development and strengthen your emotional bond.',
        imageAsset: 'assets/parents_01.jpg',
        tags: ['bonding', 'development', 'play'],
      ),
    ];
    notifyListeners();
  }

  /// Move to next skill in carousel
  void nextSkill() {
    if (_skills.isEmpty) return;
    _currentSkillIndex = (_currentSkillIndex + 1) % _skills.length;
    _expandedStates.clear(); // Collapse when changing skills
    notifyListeners();
  }

  /// Move to previous skill in carousel
  void previousSkill() {
    if (_skills.isEmpty) return;
    _currentSkillIndex =
        (_currentSkillIndex - 1 + _skills.length) % _skills.length;
    _expandedStates.clear(); // Collapse when changing skills
    notifyListeners();
  }

  /// Toggle expanded state for a skill
  void toggleSkillExpanded(int skillId) {
    _expandedStates[skillId] = !(_expandedStates[skillId] ?? false);
    notifyListeners();
  }

  /// Set current skill index
  void setCurrentSkillIndex(int index) {
    if (index >= 0 && index < _skills.length) {
      _currentSkillIndex = index;
      notifyListeners();
    }
  }
}

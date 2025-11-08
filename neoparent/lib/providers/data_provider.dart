import 'package:flutter/foundation.dart';
import '../models/history_item_model.dart';
import '../models/parenting_skill_model.dart';
import '../models/prediction_history_model.dart';
import '../services/history_service.dart';

/// Provider for managing history items
class HistoryProvider with ChangeNotifier {
  List<HistoryItemModel> _historyItems = [];
  List<PredictionHistoryModel> _predictions = [];
  DateTime? _accountCreationDate;
  bool _isLoading = false;
  final HistoryService _historyService = HistoryService();

  /// Get all history items
  List<HistoryItemModel> get historyItems => [..._historyItems];

  /// Get loading state
  bool get isLoading => _isLoading;

  /// Load predictions from API
  Future<void> loadPredictions(String? authToken) async {
    if (authToken == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      _predictions = await _historyService.fetchMyPredictions(authToken);

      // Set account creation date based on earliest prediction
      // If no predictions, use current date as account creation date
      if (_predictions.isNotEmpty) {
        _accountCreationDate = _predictions
            .map((p) => p.createdAt)
            .reduce((a, b) => a.isBefore(b) ? a : b);
      } else {
        // For new users with no predictions, use current date
        _accountCreationDate = DateTime.now();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading predictions: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get history items from the last week based on account creation date
  List<HistoryItemModel> get thisWeekItems {
    // If no predictions, return empty list (will show 0)
    if (_predictions.isEmpty) {
      return [];
    }

    if (_accountCreationDate == null) {
      // Fallback to old behavior if account creation date is not set
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      return _historyItems.where((item) => item.date.isAfter(weekAgo)).toList();
    }

    // Calculate week based on account creation date
    final now = DateTime.now();
    final daysSinceCreation = now.difference(_accountCreationDate!).inDays;
    final currentWeekNumber = daysSinceCreation ~/ 7;

    final currentWeekStart = _accountCreationDate!.add(
      Duration(days: currentWeekNumber * 7),
    );
    final currentWeekEnd = currentWeekStart.add(const Duration(days: 7));

    // Return empty list to show count
    return List.generate(
      _predictions.where((prediction) {
        return prediction.createdAt.isAfter(currentWeekStart) &&
            prediction.createdAt.isBefore(currentWeekEnd);
      }).length,
      (index) => HistoryItemModel(
        id: index.toString(),
        date: DateTime.now(),
        duration: const Duration(seconds: 0),
        analysis: '',
        confidence: 0,
        status: AnalysisStatus.completed,
      ),
    );
  }

  /// Calculate average confidence from all predictions
  int get averageConfidence {
    // If no predictions, return 0
    if (_predictions.isEmpty) {
      return 0;
    }

    double total = _predictions.fold(
      0.0,
      (sum, prediction) => sum + (prediction.confidence ?? 0.0),
    );
    return (total / _predictions.length).round();
  }

  /// Get most common analysis type from predictions
  String get mostCommonAnalysis {
    // If no predictions, return 'None'
    if (_predictions.isEmpty) {
      return 'None';
    }

    Map<String, int> analysisCount = {};
    for (var prediction in _predictions) {
      final label = prediction.predictedLabel ?? 'Unknown';
      analysisCount[label] = (analysisCount[label] ?? 0) + 1;
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

/// Enum representing analysis status
enum AnalysisStatus { completed, lowConfidence, failed }

/// Model representing a baby cry analysis history item
class HistoryItemModel {
  final String id;
  final DateTime date;
  final Duration duration;
  final String analysis;
  final int confidence;
  final AnalysisStatus status;
  final String? audioPath;
  final String? notes;

  HistoryItemModel({
    required this.id,
    required this.date,
    required this.duration,
    required this.analysis,
    required this.confidence,
    required this.status,
    this.audioPath,
    this.notes,
  });

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'duration': duration.inSeconds,
      'analysis': analysis,
      'confidence': confidence,
      'status': status.name,
      'audioPath': audioPath,
      'notes': notes,
    };
  }

  /// Create from JSON
  factory HistoryItemModel.fromJson(Map<String, dynamic> json) {
    return HistoryItemModel(
      id: json['id'],
      date: DateTime.parse(json['date']),
      duration: Duration(seconds: json['duration']),
      analysis: json['analysis'],
      confidence: json['confidence'],
      status: AnalysisStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AnalysisStatus.completed,
      ),
      audioPath: json['audioPath'],
      notes: json['notes'],
    );
  }

  /// Copy with method for updates
  HistoryItemModel copyWith({
    String? id,
    DateTime? date,
    Duration? duration,
    String? analysis,
    int? confidence,
    AnalysisStatus? status,
    String? audioPath,
    String? notes,
  }) {
    return HistoryItemModel(
      id: id ?? this.id,
      date: date ?? this.date,
      duration: duration ?? this.duration,
      analysis: analysis ?? this.analysis,
      confidence: confidence ?? this.confidence,
      status: status ?? this.status,
      audioPath: audioPath ?? this.audioPath,
      notes: notes ?? this.notes,
    );
  }
}

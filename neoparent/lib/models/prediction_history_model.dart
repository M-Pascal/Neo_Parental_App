class PredictionHistoryModel {
  final String id;
  final String userId;
  final String username;
  final String audioFilename;
  final String audioUrl;
  final String cloudinaryPublicId;
  final double predictionValue;
  final String? predictedLabel;
  final double? confidence;
  final DateTime createdAt;

  PredictionHistoryModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.audioFilename,
    required this.audioUrl,
    required this.cloudinaryPublicId,
    required this.predictionValue,
    this.predictedLabel,
    this.confidence,
    required this.createdAt,
  });

  factory PredictionHistoryModel.fromJson(Map<String, dynamic> json) {
    return PredictionHistoryModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      audioFilename: json['audio_filename']?.toString() ?? 'Unknown',
      audioUrl: json['audio_url']?.toString() ?? '',
      cloudinaryPublicId: json['cloudinary_public_id']?.toString() ?? '',
      predictionValue: (json['prediction_value'] ?? 0).toDouble(),
      predictedLabel: json['predicted_label']?.toString(),
      confidence: json['confidence'] != null
          ? (json['confidence'] is int
                ? (json['confidence'] as int).toDouble()
                : (json['confidence'] as num).toDouble())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'username': username,
      'audio_filename': audioFilename,
      'audio_url': audioUrl,
      'cloudinary_public_id': cloudinaryPublicId,
      'prediction_value': predictionValue,
      'predicted_label': predictedLabel,
      'confidence': confidence,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String getFormattedTime() {
    return '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
  }

  String getFormattedDate() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays == 0) {
      return 'Today at ${getFormattedTime()}';
    } else if (difference.inDays == 1) {
      return 'Yesterday at ${getFormattedTime()}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  String getConfidenceText() {
    if (confidence == null) return 'N/A';
    return '${confidence!.toInt()}%';
  }
}

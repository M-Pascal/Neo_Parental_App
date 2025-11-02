/// Model representing parenting skill educational content
class ParentingSkillModel {
  final int id;
  final String title;
  final String shortContent;
  final String fullContent;
  final String imageAsset;
  final List<String>? tags;

  ParentingSkillModel({
    required this.id,
    required this.title,
    required this.shortContent,
    required this.fullContent,
    required this.imageAsset,
    this.tags,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'shortContent': shortContent,
      'fullContent': fullContent,
      'imageAsset': imageAsset,
      'tags': tags,
    };
  }

  /// Create from JSON
  factory ParentingSkillModel.fromJson(Map<String, dynamic> json) {
    return ParentingSkillModel(
      id: json['id'],
      title: json['title'],
      shortContent: json['shortContent'],
      fullContent: json['fullContent'],
      imageAsset: json['imageAsset'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
    );
  }

  /// Copy with method
  ParentingSkillModel copyWith({
    int? id,
    String? title,
    String? shortContent,
    String? fullContent,
    String? imageAsset,
    List<String>? tags,
  }) {
    return ParentingSkillModel(
      id: id ?? this.id,
      title: title ?? this.title,
      shortContent: shortContent ?? this.shortContent,
      fullContent: fullContent ?? this.fullContent,
      imageAsset: imageAsset ?? this.imageAsset,
      tags: tags ?? this.tags,
    );
  }
}

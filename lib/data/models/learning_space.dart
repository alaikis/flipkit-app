import 'package:json_annotation/json_annotation.dart';

part 'learning_space.g.dart';

/// 学习空间模型（多儿童支持）
@JsonSerializable()
class LearningSpace {
  final String id;
  final String userId; // 父账户 ID
  final String childName;
  final String childGender;
  final String grade;
  final String? avatar;
  final String textbookVersion;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  LearningSpace({
    required this.id,
    required this.userId,
    required this.childName,
    required this.childGender,
    required this.grade,
    this.avatar,
    required this.textbookVersion,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LearningSpace.fromJson(Map<String, dynamic> json) =>
      _$LearningSpaceFromJson(json);

  Map<String, dynamic> toJson() => _$LearningSpaceToJson(this);

  LearningSpace copyWith({
    String? id,
    String? userId,
    String? childName,
    String? childGender,
    String? grade,
    String? avatar,
    String? textbookVersion,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LearningSpace(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      childName: childName ?? this.childName,
      childGender: childGender ?? this.childGender,
      grade: grade ?? this.grade,
      avatar: avatar ?? this.avatar,
      textbookVersion: textbookVersion ?? this.textbookVersion,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

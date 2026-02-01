import 'package:json_annotation/json_annotation.dart';

part 'answer_record.g.dart';

/// 答题记录模型
@JsonSerializable()
class AnswerRecord {
  final String id;
  final String spaceId;
  final String questionId;
  final String? userAnswer;
  final String? correctAnswer;
  final double score; // 得分
  final double maxScore; // 满分
  final bool isCorrect;
  final int attemptCount;
  final String? feedback; // AI反馈
  final String? imageUrl; // 手写答案图片
  final DateTime createdAt;

  AnswerRecord({
    required this.id,
    required this.spaceId,
    required this.questionId,
    this.userAnswer,
    this.correctAnswer,
    required this.score,
    this.maxScore = 100.0,
    required this.isCorrect,
    this.attemptCount = 1,
    this.feedback,
    this.imageUrl,
    required this.createdAt,
  });

  factory AnswerRecord.fromJson(Map<String, dynamic> json) =>
      _$AnswerRecordFromJson(json);

  Map<String, dynamic> toJson() => _$AnswerRecordToJson(this);

  AnswerRecord copyWith({
    String? id,
    String? spaceId,
    String? questionId,
    String? userAnswer,
    String? correctAnswer,
    double? score,
    double? maxScore,
    bool? isCorrect,
    int? attemptCount,
    String? feedback,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return AnswerRecord(
      id: id ?? this.id,
      spaceId: spaceId ?? this.spaceId,
      questionId: questionId ?? this.questionId,
      userAnswer: userAnswer ?? this.userAnswer,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      score: score ?? this.score,
      maxScore: maxScore ?? this.maxScore,
      isCorrect: isCorrect ?? this.isCorrect,
      attemptCount: attemptCount ?? this.attemptCount,
      feedback: feedback ?? this.feedback,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// 获取得分百分比
  double get scorePercentage => (score / maxScore) * 100;

  /// 是否是满分
  bool get isFullScore => score >= maxScore;

  /// 答题状态
  String get status {
    if (isFullScore) return '优秀';
    if (scorePercentage >= 80) return '良好';
    if (scorePercentage >= 60) return '及格';
    return '不及格';
  }
}

import 'package:json_annotation/json_annotation.dart';

part 'question.g.dart';

/// 题目模型
@JsonSerializable()
class Question {
  final String id;
  final String spaceId; // 所属学习空间
  final String subject;
  final String grade;
  final String chapter;
  final String type; // 选择题、填空题、判断题、简答题
  final String difficulty; // 简单、中等、困难
  final String content;
  final List<String>? options; // 选择题选项
  final String? answer;
  final String? explanation; // 解析
  final List<String>? tags; // 知识点标签
  final String source; // AI生成或人工录入
  final DateTime createdAt;
  final DateTime? updatedAt;

  Question({
    required this.id,
    required this.spaceId,
    required this.subject,
    required this.grade,
    required this.chapter,
    required this.type,
    required this.difficulty,
    required this.content,
    this.options,
    this.answer,
    this.explanation,
    this.tags,
    required this.source,
    required this.createdAt,
    this.updatedAt,
  });

  factory Question.fromJson(Map<String, dynamic> json) =>
      _$QuestionFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionToJson(this);

  Question copyWith({
    String? id,
    String? spaceId,
    String? subject,
    String? grade,
    String? chapter,
    String? type,
    String? difficulty,
    String? content,
    List<String>? options,
    String? answer,
    String? explanation,
    List<String>? tags,
    String? source,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Question(
      id: id ?? this.id,
      spaceId: spaceId ?? this.spaceId,
      subject: subject ?? this.subject,
      grade: grade ?? this.grade,
      chapter: chapter ?? this.chapter,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      content: content ?? this.content,
      options: options ?? this.options,
      answer: answer ?? this.answer,
      explanation: explanation ?? this.explanation,
      tags: tags ?? this.tags,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 是否是选择题
  bool get isChoiceQuestion => type == '选择题';

  /// 是否是填空题
  bool get isFillInQuestion => type == '填空题';

  /// 是否是判断题
  bool get isTrueFalseQuestion => type == '判断题';

  /// 是否是简答题
  bool get isShortAnswerQuestion => type == '简答题';
}

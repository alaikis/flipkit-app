import 'dart:convert';
import '../models/model_adapter.dart';

/// 知乐岛 (Knowledge Quest Island) - 自动生成题目，错题复现，进度跟踪
class KnowledgeQuestModule {
  final ModelAdapter modelAdapter;
  final String spaceId;

  KnowledgeQuestModule({required this.modelAdapter, required this.spaceId});

  /// Generate questions automatically based on chapter knowledge
  Future<List<Map<String, dynamic>>> generateQuestions({
    required String subject,
    required String chapter,
    int count = 5,
    bool includeSingleChoice = true,
    bool includeMultipleChoice = true,
  }) async {
    final prompt = '''
根据${subject}${chapter}的知识点，生成$count个选择题。
${includeSingleChoice ? '- 包含单选题' : ''}
${includeMultipleChoice ? '- 包含多选题' : ''}

返回JSON数组格式：[
  {
    "id": "q1",
    "type": "single",
    "question": "题目文本",
    "options": ["A) 选项1", "B) 选项2", "C) 选项3", "D) 选项4"],
    "answer": "B",
    "explanation": "解释为什么B是正确答案"
  },
  ...
]
''';

    final result = await modelAdapter.generate(prompt);
    // Try to parse LLM JSON response safely, handle a few common fallback formats
    try {
      final parsed = jsonDecode(result);
      if (parsed is List) {
        return parsed.cast<Map<String, dynamic>>();
      }
      // Some models wrap questions in an object
      if (parsed is Map && parsed['questions'] is List) {
        return (parsed['questions'] as List).cast<Map<String, dynamic>>();
      }
    } catch (_) {
      // fall through to fallback
    }

    // If LLM output couldn't be parsed, use a lightweight local generator as fallback
    return _localGenerateQuestions(subject, chapter, count, includeSingleChoice, includeMultipleChoice);
  }

  /// Local fallback generator for environments without reliable LLM output
  List<Map<String, dynamic>> _localGenerateQuestions(String subject, String chapter, int count, bool single, bool multiple) {
    final questions = <Map<String, dynamic>>[];
    for (var i = 0; i < count; i++) {
      final qid = 'local_${subject}_${chapter}_${i+1}';
      if (single) {
        questions.add({
          'id': qid,
          'type': 'single',
          'question': '$subject $chapter 问题 ${i + 1}: 请选择正确的选项。',
          'options': ['A) 选项1', 'B) 选项2', 'C) 选项3', 'D) 选项4'],
          'answer': 'A',
          'explanation': '因为这是一个示例题，A 是正确答案。',
        });
      } else if (multiple) {
        questions.add({
          'id': qid,
          'type': 'multiple',
          'question': '$subject $chapter 多选题 ${i + 1}: 选择所有正确项。',
          'options': ['A) 选项1', 'B) 选项2', 'C) 选项3', 'D) 选项4'],
          'answer': 'A,C',
          'explanation': '示例多选题，A 和 C 为正确答案。',
        });
      }
    }
    return questions;
  }

  /// Track progress and return incorrect questions for review
  Future<List<Map<String, dynamic>>> getIncorrectQuestionsForReview(String subject, String chapter) async {
    // TODO: Query database for incorrect answers, return them for user to redo
    return [];
  }

  /// Check answer and provide feedback
  Future<Map<String, dynamic>> checkAnswer({
    required String questionId,
    required String userAnswer,
    required String correctAnswer,
    required String explanation,
  }) async {
    final isCorrect = userAnswer.trim().toUpperCase() == correctAnswer.trim().toUpperCase();
    return {
      'isCorrect': isCorrect,
      'yourAnswer': userAnswer,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
    };
  }

  /// Calculate chapter mastery rate and recommend next actions
  Future<Map<String, dynamic>> getChapterMasteryLevel(String subject, String chapter) async {
    // TODO: Query AnswerRecord and calculate stats
    return {
      'correctRate': 0.75,
      'totalAttempts': 20,
      'lastReviewTime': DateTime.now().toIso8601String(),
      'recommendation': '掌握良好，可继续下一章节',
    };
  }
}

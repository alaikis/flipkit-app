import 'dart:convert';
import 'dart:io';
import '../models/model_adapter.dart';
import '../services/image_processing_service.dart';

/// 聪明屋 (Smart House) - 应用题和问答题，拍照阅卷，纠错教学，推荐视频
class SmartHouseModule {
  final ModelAdapter modelAdapter;
  final ImageProcessingService imageService;
  final String spaceId;

  SmartHouseModule({
    required this.modelAdapter,
    required this.imageService,
    required this.spaceId,
  });

  /// Grade an essay/application problem submission using OCR + LLM
  Future<Map<String, dynamic>> gradeEssaySubmission({
    required String questionContent,
    required File submissionImageFile,
    required String modelId,
  }) async {
    // Step 1: OCR the submission image
    final userAnswerText = await imageService.recognizeText(submissionImageFile);
    
    // Step 2: Send to LLM for grading
    final prompt = '''
请评判这道题目的答案：

题目：$questionContent

学生答案（从拍照识别）：
$userAnswerText

请返回JSON格式的评分结果：{
  "score": 85,
  "maxScore": 100,
  "strengths": ["正确理解了题意", "逻辑清晰"],
  "weaknesses": ["计算过程不完整"],
  "correctionExplanation": "正确的解答步骤应该是...",
  "videoSearchKeywords": ["应用题解题技巧", "数学建模方法"]
}
''';

    final result = await modelAdapter.generate(prompt);
    try {
      final parsed = jsonDecode(result);
      return {
        'score': parsed['score'] ?? 0,
        'maxScore': parsed['maxScore'] ?? 100,
        'recognizedText': userAnswerText,
        'strengths': parsed['strengths'] ?? [],
        'weaknesses': parsed['weaknesses'] ?? [],
        'correctionExplanation': parsed['correctionExplanation'] ?? '',
        'videoSearchKeywords': parsed['videoSearchKeywords'] ?? [],
      };
    } catch (_) {
      return {
        'score': 0,
        'maxScore': 100,
        'recognizedText': userAnswerText,
        'feedback': result,
      };
    }
  }

  /// Enhanced grading function to include additional metrics
  Future<Map<String, dynamic>> enhancedGradeEssaySubmission({
    required String questionContent,
    required File submissionImageFile,
    required String modelId,
  }) async {
    // Step 1: OCR the submission image
    final userAnswerText = await imageService.recognizeText(submissionImageFile);

    // Step 2: Send to LLM for grading with additional metrics
    final prompt = '''
Please evaluate the following answer:

Question: $questionContent

Student Answer (from OCR):
$userAnswerText

Return JSON format with additional metrics:
{
  "score": 85,
  "maxScore": 100,
  "strengths": ["Correct understanding of the topic", "Clear logic"],
  "weaknesses": ["Incomplete calculation process"],
  "correctionExplanation": "The correct steps to solve this problem should be...",
  "videoSearchKeywords": ["problem-solving techniques", "math modeling methods"],
  "grammarScore": 90,
  "contentRelevance": 95,
  "plagiarismCheck": "No issues detected"
}
''';

    final result = await modelAdapter.generate(prompt);
    try {
      final parsed = jsonDecode(result);
      return {
        'score': parsed['score'] ?? 0,
        'maxScore': parsed['maxScore'] ?? 100,
        'recognizedText': userAnswerText,
        'strengths': parsed['strengths'] ?? [],
        'weaknesses': parsed['weaknesses'] ?? [],
        'correctionExplanation': parsed['correctionExplanation'] ?? '',
        'videoSearchKeywords': parsed['videoSearchKeywords'] ?? [],
        'grammarScore': parsed['grammarScore'] ?? 0,
        'contentRelevance': parsed['contentRelevance'] ?? 0,
        'plagiarismCheck': parsed['plagiarismCheck'] ?? 'Unknown',
      };
    } catch (_) {
      return {
        'score': 0,
        'maxScore': 100,
        'recognizedText': userAnswerText,
        'feedback': result,
      };
    }
  }

  /// Generate correction explanation and teaching video recommendations
  Future<Map<String, dynamic>> generateCorrectionAndVideos({
    required String question,
    required String userAnswer,
    required String correctionExplanation,
  }) async {
    final prompt = '''
基于这道题的错误分析，推荐相关的教学视频：

题目：$question
学生答案：$userAnswer
纠正说明：$correctionExplanation

返回JSON格式：{
  "detailedExplanation": "详细的纠正说明和解题过程",
  "videoRecommendations": [
    {"title": "视频标题", "keyword": "搜索关键词", "source": "YouTube/B站"},
    ...
  ]
}
''';

    final result = await modelAdapter.generate(prompt);
    try {
      return jsonDecode(result);
    } catch (_) {
      return {'detailedExplanation': result, 'videoRecommendations': []};
    }
  }

  /// Generate application/essay questions based on chapter
  Future<List<Map<String, dynamic>>> generateApplicationQuestions({
    required String subject,
    required String chapter,
    int count = 3,
  }) async {
    final prompt = '''
根据${subject}${chapter}的内容，生成$count道应用题或问答题。

返回JSON数组格式：[
  {
    "id": "q1",
    "type": "application",
    "question": "题目文本",
    "maxScore": 10,
    "keyPoints": ["考查重点1", "考查重点2"]
  },
  ...
]
''';

    final result = await modelAdapter.generate(prompt);
    try {
      final parsed = jsonDecode(result) as List;
      return parsed.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  /// Mark a video as watched for tracking
  Future<void> markVideoAsWatched(String submissionId) async {
    // TODO: Update EssaySubmission.videoWatched = true
  }

  /// Get submission history for a space
  Future<List<Map<String, dynamic>>> getSubmissionHistory({
    int limit = 10,
  }) async {
    // TODO: Query database for recent submissions
    return [];
  }

  /// Analyze learning progress across multiple submissions
  Future<Map<String, dynamic>> analyzeLearningProgress({
    required List<String> submissionIds,
  }) async {
    final prompt = '''
根据以下多个提交的评分结果，分析学生的学习进度和薄弱环节：

提交ID: ${submissionIds.join(', ')}

返回JSON格式的分析报告：{
  "overallProgress": "excellent|good|fair|needs_improvement",
  "strongAreas": ["强项1", "强项2"],
  "weakAreas": ["弱项1", "弱项2"],
  "improvementTrend": "improving|stable|declining",
  "recommendedFocus": ["重点关注方向1", "重点关注方向2"],
  "nextStepsSuggestions": ["建议1", "建议2"]
}
''';

    final result = await modelAdapter.generate(prompt);
    try {
      return jsonDecode(result);
    } catch (_) {
      return {
        'overallProgress': 'fair',
        'strongAreas': [],
        'weakAreas': [],
        'improvementTrend': 'stable',
        'recommendedFocus': [],
        'nextStepsSuggestions': [],
      };
    }
  }

  /// Get detailed recommendations for improvement
  Future<Map<String, dynamic>> getImprovementRecommendations({
    required String weakness,
    required String subject,
  }) async {
    final prompt = '''
学生在 $subject 科目中存在以下问题：$weakness

请提供详细的改进建议和学习资源：

返回JSON格式：{
  "detailedAnalysis": "对问题的详细分析",
  "solvingStrategies": ["策略1", "策略2", "策略3"],
  "practiceExamples": [
    {
      "example": "例题1",
      "explanation": "解答说明"
    }
  ],
  "recommendedResources": [
    {
      "title": "资源名称",
      "type": "video|article|exercise",
      "url": "资源链接"
    }
  ]
}
''';

    final result = await modelAdapter.generate(prompt);
    try {
      return jsonDecode(result);
    } catch (_) {
      return {
        'detailedAnalysis': result,
        'solvingStrategies': [],
        'practiceExamples': [],
        'recommendedResources': [],
      };
    }
  }

  /// Create a peer comparison report (anonymized)
  Future<Map<String, dynamic>> getPeerComparisonReport({
    required double studentScore,
    required String gradeLevel,
    required String subject,
  }) async {
    final prompt = '''
一个$gradeLevel年级的学生在$subject科目中得分为$studentScore分（满分100分）。

请提供与同级学生的对标分析（匿名）：

返回JSON格式：{
  "percentileRank": 75,
  "averageScoreForLevel": 75,
  "performanceLevel": "above_average|average|below_average",
  "comparisonInsight": "与同级学生相比的分析"
}
''';

    final result = await modelAdapter.generate(prompt);
    try {
      return jsonDecode(result);
    } catch (_) {
      return {
        'percentileRank': 50,
        'averageScoreForLevel': 75,
        'performanceLevel': 'average',
        'comparisonInsight': result,
      };
    }
  }
}

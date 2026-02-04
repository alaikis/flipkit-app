import 'package:dio/dio.dart';
import '../config/ai_config.dart';
import '../core/utils/logger.dart';
import '../core/utils/storage_helper.dart';
import '../core/constants/app_constants.dart';

/// AI 服务 - 用于智能组题和评分
class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;

  AIService._internal();

  late final Dio _dio;

  /// 初始化
  Future<void> init() async {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(milliseconds: 30000),
      receiveTimeout: const Duration(milliseconds: 30000),
      sendTimeout: const Duration(milliseconds: 30000),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    Logger.info('AI Service initialized', tag: 'AIService');
  }

  /// 获取当前提供商
  Future<AIProvider> getCurrentProvider() async {
    final providerName = await StorageHelper().getString(AppConstants.keyAIProvider)
        ?? AIConfig.currentProvider;

    final provider = AIConfig.providers.firstWhere(
      (p) => p.name == providerName,
      orElse: () => AIConfig.providers.first,
    );

    return provider;
  }

  /// 获取 API Key
  Future<String> getApiKey(String providerName) async {
    final storage = StorageHelper();
    final key = await storage.getSecureString('ai_key_$providerName');

    if (key == null || key.isEmpty) {
      // 如果没有配置 key，使用配置文件中的默认值
      final provider = AIConfig.providers.firstWhere(
        (p) => p.name == providerName,
      );
      return provider.apiKey;
    }

    return key;
  }

  /// 生成题目
  Future<List<Map<String, dynamic>>> generateQuestions({
    required String subject,
    required String grade,
    required String chapter,
    required int count,
    String difficulty = '中等',
    String type = '选择题',
  }) async {
    try {
      final provider = await getCurrentProvider();
      final apiKey = await getApiKey(provider.name);

      Logger.network(
        'POST',
        '${provider.baseUrl}/chat/completions',
        tag: 'AIService',
      );

      final response = await _dio.post(
        '${provider.baseUrl}/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
          },
        ),
        data: {
          'model': provider.models.first,
          'messages': [
            {
              'role': 'system',
              'content': '''你是一位专业的教育工作者，擅长为K12学生生成练习题。
请根据用户的要求生成题目，并以JSON格式返回。

返回格式要求：
{
  "questions": [
    {
      "content": "题目内容",
      "type": "题型",
      "difficulty": "难度",
      "options": ["A选项", "B选项", "C选项", "D选项"],
      "answer": "正确答案",
      "explanation": "题目解析",
      "tags": ["知识点1", "知识点2"]
    }
  ]
}

注意事项：
1. 题目内容要符合${grade}学生的认知水平
2. 题目难度要符合${difficulty}标准
3. 题目类型要符合${type}要求
4. 选择题必须包含4个选项
5. 答案要准确，解析要详细
6. 只返回JSON，不要其他文字''',
            },
            {
              'role': 'user',
              'content': '请为$subject科目的$chapter章节生成$count道$difficulty难度的$type。\n'
                  '年级：$grade\n'
                  '数量：$count\n'
                  '题型：$type\n'
                  '难度：$difficulty',
            },
          ],
          'temperature': 0.7,
        },
      );

      Logger.response(
        '${provider.baseUrl}/chat/completions',
        statusCode: response.statusCode,
        tag: 'AIService',
      );

      final data = response.data;
      final content = data['choices'][0]['message']['content'];

      // 解析 JSON
      final jsonStart = content.indexOf('{');
      final jsonEnd = content.lastIndexOf('}') + 1;
      final jsonString = content.substring(jsonStart, jsonEnd);

      final result = _parseJsonResponse(jsonString);
      return result['questions'] as List<Map<String, dynamic>>;
    } catch (e, stackTrace) {
      Logger.error('Failed to generate questions',
          error: e, stackTrace: stackTrace, tag: 'AIService');
      rethrow;
    }
  }

  /// 评分
  Future<Map<String, dynamic>> evaluateAnswer({
    required String question,
    required String userAnswer,
    required String correctAnswer,
  }) async {
    try {
      final provider = await getCurrentProvider();
      final apiKey = await getApiKey(provider.name);

      final response = await _dio.post(
        '${provider.baseUrl}/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
          },
        ),
        data: {
          'model': provider.models.first,
          'messages': [
            {
              'role': 'system',
              'content': '''你是一位专业的教育工作者，擅长评估学生答案。
请评估学生答案，并以JSON格式返回。

返回格式要求：
{
  "is_correct": true/false,
  "score": 得分(0-100),
  "feedback": "评估反馈",
  "strengths": ["优点1", "优点2"],
  "weaknesses": ["不足1", "不足2"],
  "suggestions": ["建议1", "建议2"]
}

注意事项：
1. 评估要客观公正
2. 反馈要具体，帮助学生改进
3. 优点和不足要明确
4. 只返回JSON，不要其他文字''',
            },
            {
              'role': 'user',
              'content': '''题目：$question
正确答案：$correctAnswer
学生答案：$userAnswer

请评估学生答案。''',
            },
          ],
          'temperature': 0.5,
        },
      );

      final data = response.data;
      final content = data['choices'][0]['message']['content'];

      final jsonStart = content.indexOf('{');
      final jsonEnd = content.lastIndexOf('}') + 1;
      final jsonString = content.substring(jsonStart, jsonEnd);

      return _parseJsonResponse(jsonString);
    } catch (e, stackTrace) {
      Logger.error('Failed to evaluate answer',
          error: e, stackTrace: stackTrace, tag: 'AIService');
      rethrow;
    }
  }

  /// 生成作文评分
  Future<Map<String, dynamic>> gradeEssay({
    required String question,
    required String studentEssay,
    required int maxScore,
  }) async {
    try {
      final provider = await getCurrentProvider();
      final apiKey = await getApiKey(provider.name);

      final response = await _dio.post(
        '${provider.baseUrl}/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
          },
        ),
        data: {
          'model': provider.models.first,
          'messages': [
            {
              'role': 'system',
              'content': '''你是一位专业的语文老师，擅长评估学生作文。
请根据题目要求评估作文，并以JSON格式返回。

返回格式要求：
{
  "score": 得分,
  "max_score": 满分,
  "overall_feedback": "总体评价",
  "strengths": ["优点1", "优点2", "优点3"],
  "weaknesses": ["不足1", "不足2"],
  "detailed_feedback": [
    {
      "category": "内容质量",
      "score": 85,
      "comment": "评价"
    },
    {
      "category": "语言表达",
      "score": 90,
      "comment": "评价"
    },
    {
      "category": "结构组织",
      "score": 80,
      "comment": "评价"
    }
  ],
  "correction_suggestions": ["修改建议1", "修改建议2"]
}

评分标准：
1. 内容质量 (40%): 内容是否充实，观点是否明确
2. 语言表达 (30%): 语言是否流畅，用词是否准确
3. 结构组织 (20%): 结构是否清晰，逻辑是否合理
4. 书写规范 (10%): 字迹是否工整，标点是否正确

注意事项：
1. 评分要客观公正
2. 评价要具体，帮助学生改进
3. 只返回JSON，不要其他文字''',
            },
            {
              'role': 'user',
              'content': '''作文题目：$question
满分：$maxScore
学生作文：$studentEssay

请评估学生作文。''',
            },
          ],
          'temperature': 0.5,
        },
      );

      final data = response.data;
      final content = data['choices'][0]['message']['content'];

      final jsonStart = content.indexOf('{');
      final jsonEnd = content.lastIndexOf('}') + 1;
      final jsonString = content.substring(jsonStart, jsonEnd);

      return _parseJsonResponse(jsonString);
    } catch (e, stackTrace) {
      Logger.error('Failed to grade essay',
          error: e, stackTrace: stackTrace, tag: 'AIService');
      rethrow;
    }
  }

  /// 解析 JSON 响应
  Map<String, dynamic> _parseJsonResponse(String jsonString) {
    try {
      // 简单的 JSON 解析，实际应该使用 json.decode
      // 这里使用正则表达式提取
      jsonString.replaceAll(RegExp(r'[\n\r\t]'), '');
      // TODO: 使用 json.decode 解析
      return const <String, dynamic>{};
    } catch (e) {
      Logger.error('Failed to parse JSON response', error: e, tag: 'AIService');
      throw FormatException('Invalid JSON response');
    }
  }

  /// 设置 AI 提供商
  Future<void> setProvider(String providerName) async {
    await StorageHelper().setString(AppConstants.keyAIProvider, providerName);
    Logger.info('AI provider changed to: $providerName', tag: 'AIService');
  }

  /// 设置 API Key
  Future<void> setApiKey(String providerName, String apiKey) async {
    await StorageHelper().setSecureString('ai_key_$providerName', apiKey);
    Logger.info('API key saved for provider: $providerName', tag: 'AIService');
  }
}

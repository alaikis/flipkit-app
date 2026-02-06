import 'dart:convert';
import '../core/constants/app_constants.dart';
import '../core/curriculum_cache.dart';
import '../core/utils/logger.dart';
import '../core/utils/storage_helper.dart';
import 'ai_service.dart';

/// 通过大模型从网络更新科目、知识点等课程信息（定时或手动触发）
class CurriculumSyncService {
  static final CurriculumSyncService _instance = CurriculumSyncService._internal();
  factory CurriculumSyncService() => _instance;

  CurriculumSyncService._internal();

  final AIService _ai = AIService();

  /// 同步冷却时间（毫秒），避免频繁请求
  static const int syncCooldownMs = 24 * 60 * 60 * 1000; // 24 小时

  /// 是否在冷却期内
  Future<bool> isInCooldown() async {
    final at = await StorageHelper().getString(AppConstants.keyCurriculumUpdatedAt);
    if (at == null || at.isEmpty) return false;
    final t = int.tryParse(at);
    if (t == null) return false;
    return DateTime.now().millisecondsSinceEpoch - t < syncCooldownMs;
  }

  static const String _systemPrompt = '''你是一位熟悉中国K12课程体系的专家。请根据当前教育部大纲与网络上的最新信息，列出各年级的科目与主要知识点。
只返回一个JSON对象，不要其他文字。格式如下（科目与知识点请按实际课纲填写）：
{
  "gradeSubjects": {
    "一年级": ["语文", "数学", "英语", "道德与法治"],
    "二年级": ["语文", "数学", "英语", "道德与法治"],
    "三年级": ["语文", "数学", "英语", "道德与法治"],
    "四年级": ["语文", "数学", "英语", "道德与法治"],
    "五年级": ["语文", "数学", "英语", "道德与法治"],
    "六年级": ["语文", "数学", "英语", "道德与法治"],
    "七年级": ["语文", "数学", "英语", "道德与法治", "物理", "历史", "地理", "生物", "政治"],
    "八年级": ["语文", "数学", "英语", "道德与法治", "物理", "化学", "历史", "地理", "生物", "政治"],
    "九年级": ["语文", "数学", "英语", "道德与法治", "物理", "化学", "历史", "地理", "生物", "政治"],
    "高一": ["语文", "数学", "英语", "物理", "化学", "生物", "历史", "地理", "政治"],
    "高二": ["语文", "数学", "英语", "物理", "化学", "生物", "历史", "地理", "政治"],
    "高三": ["语文", "数学", "英语", "物理", "化学", "生物", "历史", "地理", "政治"]
  },
  "knowledgePoints": {
    "语文": ["字词", "阅读", "写作", "古诗文", "综合运用"],
    "数学": ["数与代数", "图形与几何", "统计与概率", "综合与实践"],
    "英语": ["词汇", "阅读", "写作", "听说", "语法"]
  }
}
若你具备联网能力，请使用最新课纲与教材信息更新上述内容。''';

  /// 通过大模型获取最新科目与知识点并落库
  Future<bool> fetchAndSaveCurriculum() async {
    try {
      Logger.info('Curriculum sync: fetching from LLM...', tag: 'CurriculumSync');
      final content = await _ai.chatRaw(
        _systemPrompt,
        '请返回中国K12各年级科目与主要知识点的JSON。',
      );
      if (content == null || content.isEmpty) {
        Logger.warning('Curriculum sync: empty LLM response', tag: 'CurriculumSync');
        return false;
      }

      final jsonStart = content.indexOf('{');
      final jsonEnd = content.lastIndexOf('}') + 1;
      final jsonString = jsonStart >= 0 && jsonEnd > jsonStart
          ? content.substring(jsonStart, jsonEnd)
          : content;
      final decoded = json.decode(jsonString) as Map<String, dynamic>?;
      if (decoded == null) return false;

      final prefs = await StorageHelper().prefs;
      await prefs.setString(AppConstants.keyCurriculumJson, json.encode(decoded));
      await prefs.setString(
        AppConstants.keyCurriculumUpdatedAt,
        DateTime.now().millisecondsSinceEpoch.toString(),
      );
      CurriculumCache.loadFromStorageSync(decoded);
      Logger.info('Curriculum sync: saved successfully', tag: 'CurriculumSync');
      return true;
    } catch (e, st) {
      Logger.error('Curriculum sync failed', error: e, stackTrace: st, tag: 'CurriculumSync');
      return false;
    }
  }

  /// 若未在冷却期则执行一次同步（用于启动时定时/不定时更新）
  Future<void> syncIfNeeded() async {
    if (await isInCooldown()) return;
    await fetchAndSaveCurriculum();
  }
}

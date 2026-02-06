import 'dart:convert';
import 'constants/app_constants.dart';
import 'utils/storage_helper.dart';

/// 科目与知识点缓存（来自大模型定时/不定时更新，优先于内置常量）
class CurriculumCache {
  CurriculumCache._();

  static Map<String, List<String>> _gradeSubjects = {};
  static Map<String, List<String>> _knowledgePoints = {};
  static bool _loaded = false;

  /// 从已解析的 JSON 写入内存（供同步服务调用）
  static void loadFromStorageSync(Map<String, dynamic>? data) {
    if (data == null) return;
    try {
      final gs = data['gradeSubjects'] as Map<String, dynamic>?;
      if (gs != null) {
        _gradeSubjects = gs.map((k, v) {
          final list = v is List ? v : (v as List<dynamic>?) ?? [];
          return MapEntry(k as String, list.map((e) => e.toString()).toList());
        });
      }
      final kp = data['knowledgePoints'] as Map<String, dynamic>?;
      if (kp != null) {
        _knowledgePoints = kp.map((k, v) {
          final list = v is List ? v : (v as List<dynamic>?) ?? [];
          return MapEntry(k as String, list.map((e) => e.toString()).toList());
        });
      }
      _loaded = true;
    } catch (_) {}
  }

  /// 从本地存储加载到内存（应用启动时调用）
  static Future<void> loadFromStorage() async {
    try {
      final prefs = await StorageHelper().prefs;
      final raw = prefs.getString(AppConstants.keyCurriculumJson);
      if (raw == null || raw.isEmpty) return;
      final data = json.decode(raw) as Map<String, dynamic>?;
      loadFromStorageSync(data);
    } catch (_) {}
  }

  /// 按年级返回科目（优先使用大模型更新结果，否则回退到内置）
  static List<String> getSubjectsForGrade(String grade) {
    if (_loaded && _gradeSubjects.isNotEmpty && _gradeSubjects.containsKey(grade)) {
      return List.from(_gradeSubjects[grade]!);
    }
    return AppConstants.subjectsForGrade(grade);
  }

  /// 按科目返回知识点（大模型更新结果）
  static List<String> getKnowledgePoints(String subject) {
    if (_loaded && _knowledgePoints.containsKey(subject)) {
      return List.from(_knowledgePoints[subject]!);
    }
    return [];
  }

  static bool get hasCachedCurriculum => _loaded && _gradeSubjects.isNotEmpty;
}

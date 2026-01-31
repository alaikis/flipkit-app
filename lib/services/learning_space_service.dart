import 'package:shared_preferences/shared_preferences.dart';
import '../data/app_db.dart';
import '../data/tables.dart';

class LearningSpaceService {
  static const _activeSpaceKey = 'activeSpaceId';

  late AppDatabase _db;

  LearningSpaceService(this._db);

  /// Create a new learning space for a child
  Future<String> createLearningSpace({
    required String parentId,
    required String childName,
    String? childGender,
    String? grade,
    String? textbookVersion,
    String? favoriteSubjectsJson,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final spaceId = _generateId();
    // Insert into database (real implementation would use Drift)
    // For now, just track in SharedPreferences for demo
    await prefs.setString('space_$spaceId', childName);
    return spaceId;
  }

  /// List all learning spaces for a parent
  Future<List<Map<String, dynamic>>> listSpaces(String parentId) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('space_')).toList();
    return keys.map((k) => {'id': k.replaceFirst('space_', ''), 'name': prefs.getString(k)}).toList();
  }

  /// Set active learning space
  Future<void> setActiveSpace(String spaceId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeSpaceKey, spaceId);
  }

  /// Get current active learning space
  Future<String?> getActiveSpace() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_activeSpaceKey);
  }

  /// Update learning space configuration (grade, textbook)
  Future<void> updateSpaceConfig({
    required String spaceId,
    String? grade,
    String? textbookVersion,
    String? favoriteSubjectsJson,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'space_config_$spaceId';
    final config = {
      'grade': grade,
      'textbook': textbookVersion,
      'subjects': favoriteSubjectsJson,
    };
    await prefs.setString(key, _encodeConfig(config));
  }

  /// Get space configuration
  Future<Map<String, dynamic>?> getSpaceConfig(String spaceId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'space_config_$spaceId';
    final encoded = prefs.getString(key);
    if (encoded == null) return null;
    return _decodeConfig(encoded);
  }

  /// Get space progress summary
  Future<Map<String, dynamic>> getSpaceProgressSummary(String spaceId) async {
    // Placeholder: would query SpaceProgress table from DB
    return {
      'totalQuestions': 150,
      'correctCount': 95,
      'correctRate': 0.633,
      'subjects': {
        'English': {'correctRate': 0.75, 'lastStudied': '2 hours ago'},
        'Chinese': {'correctRate': 0.60, 'lastStudied': '1 day ago'},
      },
    };
  }

  String _generateId() => DateTime.now().millisecondsSinceEpoch.toString();

  String _encodeConfig(Map<String, dynamic> config) => config.toString();

  Map<String, dynamic>? _decodeConfig(String encoded) {
    try {
      return Map.from(encoded as Map);
    } catch (_) {
      return null;
    }
  }
}

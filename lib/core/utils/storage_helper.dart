import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';
import 'logger.dart';

/// 存储辅助类
class StorageHelper {
  static final StorageHelper _instance = StorageHelper._internal();
  factory StorageHelper() => _instance;

  StorageHelper._internal();

  Future<SharedPreferences>? _prefsInstance;
  FlutterSecureStorage? _secureStorage;

  /// 获取 SharedPreferences 实例
  Future<SharedPreferences> get prefs async {
    if (_prefsInstance == null) {
      _prefsInstance = SharedPreferences.getInstance();
    }
    return await _prefsInstance!;
  }

  /// 获取 FlutterSecureStorage 实例
  FlutterSecureStorage get secureStorage {
    _secureStorage ??= const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ),
    );
    return _secureStorage!;
  }

  /// ==================== 普通存储 (SharedPreferences) ====================

  /// 保存字符串
  Future<bool> setString(String key, String value) async {
    final p = await prefs;
    return await p.setString(key, value);
  }

  /// 获取字符串
  Future<String?> getString(String key) async {
    final p = await prefs;
    return p.getString(key);
  }

  /// 保存整数
  Future<bool> setInt(String key, int value) async {
    final p = await prefs;
    return await p.setInt(key, value);
  }

  /// 获取整数
  Future<int?> getInt(String key) async {
    final p = await prefs;
    return p.getInt(key);
  }

  /// 保存布尔值
  Future<bool> setBool(String key, bool value) async {
    final p = await prefs;
    return await p.setBool(key, value);
  }

  /// 获取布尔值
  Future<bool?> getBool(String key) async {
    final p = await prefs;
    return p.getBool(key);
  }

  /// 保存字符串列表
  Future<bool> setStringList(String key, List<String> value) async {
    final p = await prefs;
    return await p.setStringList(key, value);
  }

  /// 获取字符串列表
  Future<List<String>?> getStringList(String key) async {
    final p = await prefs;
    return p.getStringList(key);
  }

  /// 删除键
  Future<bool> remove(String key) async {
    final p = await prefs;
    return await p.remove(key);
  }

  /// 清空所有数据
  Future<bool> clear() async {
    final p = await prefs;
    return await p.clear();
  }

  /// ==================== 安全存储 (FlutterSecureStorage) ====================

  /// 保存安全字符串
  Future<void> setSecureString(String key, String value) async {
    final storage = secureStorage;
    await storage.write(key: key, value: value);
    Logger.debug('Saved secure data: $key', tag: 'Storage');
  }

  /// 获取安全字符串
  Future<String?> getSecureString(String key) async {
    final storage = secureStorage;
    return await storage.read(key: key);
  }

  /// 删除安全字符串
  Future<void> removeSecureString(String key) async {
    final storage = secureStorage;
    await storage.delete(key: key);
    Logger.debug('Removed secure data: $key', tag: 'Storage');
  }

  /// 清空所有安全数据
  Future<void> clearSecure() async {
    final storage = secureStorage;
    await storage.deleteAll();
    Logger.info('Cleared all secure data', tag: 'Storage');
  }

  /// ==================== 便捷方法 ====================

  /// 检查是否首次启动
  Future<bool> isFirstLaunch() async {
    final p = await prefs;
    return p.getBool(AppConstants.keyFirstLaunch) ?? true;
  }

  /// 设置首次启动标志
  Future<void> setFirstLaunch(bool value) async {
    await setBool(AppConstants.keyFirstLaunch, value);
  }

  /// 获取当前学习空间 ID
  Future<String?> getCurrentSpaceId() async {
    return await getString(AppConstants.keyCurrentSpaceId);
  }

  /// 设置当前学习空间 ID
  Future<void> setCurrentSpaceId(String spaceId) async {
    await setString(AppConstants.keyCurrentSpaceId, spaceId);
  }

  /// 获取用户 ID
  Future<String?> getUserId() async {
    return await getString(AppConstants.keyUserId);
  }

  /// 设置用户 ID
  Future<void> setUserId(String userId) async {
    await setString(AppConstants.keyUserId, userId);
  }

  /// 检查深色模式
  Future<bool> isDarkMode() async {
    return await getBool(AppConstants.keyDarkMode) ?? false;
  }

  /// 设置深色模式
  Future<void> setDarkMode(bool value) async {
    await setBool(AppConstants.keyDarkMode, value);
  }

  /// 获取当前语言
  Future<String?> getLanguage() async {
    return await getString(AppConstants.keyLanguage);
  }

  /// 设置当前语言
  Future<void> setLanguage(String language) async {
    await setString(AppConstants.keyLanguage, language);
  }

  /// 获取AI提供商配置
  Future<String?> getAIProvider() async {
    return await getString(AppConstants.keyAIProvider);
  }

  /// 设置AI提供商配置
  Future<void> setAIProvider(String provider) async {
    await setString(AppConstants.keyAIProvider, provider);
  }
}

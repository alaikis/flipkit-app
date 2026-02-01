import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';
import 'logger.dart';

/// 存储辅助类
class StorageHelper {
  static final StorageHelper _instance = StorageHelper._internal();
  factory StorageHelper() => _instance;

  StorageHelper._internal();

  final _prefs = SharedPreferences.getInstance();
  final _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  /// 获取 SharedPreferences 实例
  Future<SharedPreferences> get prefs async => await _prefs;

  /// ==================== 普通存储 (SharedPreferences) ====================

  /// 保存字符串
  Future<bool> setString(String key, String value) async {
    final prefs = await _prefs;
    return await prefs.setString(key, value);
  }

  /// 获取字符串
  Future<String?> getString(String key) async {
    final prefs = await _prefs;
    return prefs.getString(key);
  }

  /// 保存整数
  Future<bool> setInt(String key, int value) async {
    final prefs = await _prefs;
    return await prefs.setInt(key, value);
  }

  /// 获取整数
  Future<int?> getInt(String key) async {
    final prefs = await _prefs;
    return prefs.getInt(key);
  }

  /// 保存布尔值
  Future<bool> setBool(String key, bool value) async {
    final prefs = await _prefs;
    return await prefs.setBool(key, value);
  }

  /// 获取布尔值
  Future<bool?> getBool(String key) async {
    final prefs = await _prefs;
    return prefs.getBool(key);
  }

  /// 保存字符串列表
  Future<bool> setStringList(String key, List<String> value) async {
    final prefs = await _prefs;
    return await prefs.setStringList(key, value);
  }

  /// 获取字符串列表
  Future<List<String>?> getStringList(String key) async {
    final prefs = await _prefs;
    return prefs.getStringList(key);
  }

  /// 删除键
  Future<bool> remove(String key) async {
    final prefs = await _prefs;
    return await prefs.remove(key);
  }

  /// 清空所有数据
  Future<bool> clear() async {
    final prefs = await _prefs;
    return await prefs.clear();
  }

  /// ==================== 安全存储 (FlutterSecureStorage) ====================

  /// 保存安全字符串
  Future<void> setSecureString(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
    Logger.debug('Saved secure data: $key', tag: 'Storage');
  }

  /// 获取安全字符串
  Future<String?> getSecureString(String key) async {
    return await _secureStorage.read(key: key);
  }

  /// 删除安全字符串
  Future<void> removeSecureString(String key) async {
    await _secureStorage.delete(key: key);
    Logger.debug('Removed secure data: $key', tag: 'Storage');
  }

  /// 清空所有安全数据
  Future<void> clearSecure() async {
    await _secureStorage.deleteAll();
    Logger.info('Cleared all secure data', tag: 'Storage');
  }

  /// ==================== 便捷方法 ====================

  /// 检查是否首次启动
  Future<bool> isFirstLaunch() async {
    final prefs = await _prefs;
    return prefs.getBool(AppConstants.keyFirstLaunch) ?? true;
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

  /// 检查深色模式
  Future<bool> isDarkMode() async {
    return await getBool(AppConstants.keyDarkMode) ?? false;
  }

  /// 设置深色模式
  Future<void> setDarkMode(bool value) async {
    await setBool(AppConstants.keyDarkMode, value);
  }
}

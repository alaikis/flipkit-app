import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _configuredKey = 'isConfigured';
  static const _backupProviderKey = 'backupProvider';
  static const _modelProviderKey = 'modelProvider';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  SettingsService();

  Future<void> saveBasicSettings({required String backupProvider, String? modelProvider}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_backupProviderKey, backupProvider);
    if (modelProvider != null) await prefs.setString(_modelProviderKey, modelProvider);
    await prefs.setBool(_configuredKey, true);
  }

  Future<Map<String, String?>> getBasicSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'backupProvider': prefs.getString(_backupProviderKey),
      'modelProvider': prefs.getString(_modelProviderKey),
      'configured': prefs.getBool(_configuredKey)?.toString(),
    };
  }

  Future<void> saveProviderToken(String provider, String token) async {
    // store tokens in secure storage keyed by provider
    await _secureStorage.write(key: 'token_$provider', value: token);
  }

  Future<String?> getProviderToken(String provider) async {
    return await _secureStorage.read(key: 'token_$provider');
  }

  Future<void> clearProviderToken(String provider) async {
    await _secureStorage.delete(key: 'token_$provider');
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _secureStorage.deleteAll();
  }
}

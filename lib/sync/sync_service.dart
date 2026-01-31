import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../services/settings_service.dart';
import '../backup/backup_adapter.dart';
import '../backup/baidu_adapter.dart';
import '../backup/wechat_adapter.dart';

/// SyncService: provides push/pull stubs and backup adapter integration.
class SyncService {
  final SettingsService _settings = SettingsService();

  SyncService();

  /// Push local changes (ChangeLog) to server.
  Future<void> pushChanges() async {
    // TODO: collect local changelog entries and POST to /sync/push
  }

  /// Pull remote changes since lastSyncToken and merge locally.
  Future<void> pullChanges(String lastSyncToken) async {
    // TODO: GET /sync/pull?since=... and apply merges
  }

  /// Create a full export backup file (gzipped JSON or similar) and return path.
  Future<String> exportBackupToFile() async {
    // TODO: collect DB tables and serialize; here create a small demo file
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/qukit_backup_${DateTime.now().millisecondsSinceEpoch}.json');
    await file.writeAsString(jsonEncode({'demo': 'backup', 'ts': DateTime.now().toIso8601String()}));
    return file.path;
  }

  /// Upload full backup to configured provider (baidu/wechat) and return provider response.
  Future<String> uploadBackupToProvider() async {
    final settings = await _settings.getBasicSettings();
    final provider = settings['backupProvider'] ?? 'none';
    if (provider == 'none' || provider == null) {
      throw Exception('No backup provider configured');
    }

    final adapter = await _createAdapterForProvider(provider);
    if (adapter == null) throw Exception('Adapter not available');

    final path = await exportBackupToFile();
    final file = File(path);
    final result = await adapter.uploadBackup(file);
    return result;
  }

  Future<BackupAdapter?> _createAdapterForProvider(String provider) async {
    if (provider == 'baidu') {
      final a = BaiduAdapter();
      await a.init({
        'clientId': 'YOUR_BAIDU_CLIENT_ID',
        'clientSecret': 'YOUR_BAIDU_CLIENT_SECRET',
        'redirectUri': 'urn:ietf:wg:oauth:2.0:oob',
      });
      // in real app, restore tokens from SettingsService secure storage and set on adapter
      return a;
    }
    if (provider == 'wechat') {
      final a = WechatAdapter();
      await a.init({
        'appId': 'YOUR_WECHAT_APPID',
        'appSecret': 'YOUR_WECHAT_SECRET',
        'redirectUri': 'https://your.app/callback',
      });
      return a;
    }
    return null;
  }

  /// Import backup from provider by remote id
  Future<File> downloadBackupFromProvider(String remoteId) async {
    final settings = await _settings.getBasicSettings();
    final provider = settings['backupProvider'] ?? 'none';
    final adapter = await _createAdapterForProvider(provider);
    if (adapter == null) throw Exception('Adapter not available');
    final dir = await getTemporaryDirectory();
    final localPath = '${dir.path}/downloaded_backup_$remoteId.json';
    return await adapter.downloadBackup(remoteId, localPath);
  }

  /// Import backup: apply the contents of the provided file into DB (stub)
  Future<void> importBackupFromFile(File file) async {
    // TODO: parse and apply, handle schema compatibility and conflicts
    final content = await file.readAsString();
    // placeholder: log
    // ignore: avoid_print
    print('Importing backup: ${content.substring(0, content.length > 200 ? 200 : content.length)}');
  }
}

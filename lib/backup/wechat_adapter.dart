import 'dart:convert';
import 'dart:io';

import 'backup_adapter.dart';

class WechatAdapter implements BackupAdapter {
  late String appId;
  late String appSecret;
  late String redirectUri;
  String? accessToken;

  WechatAdapter();

  @override
  Future<void> init(Map<String, dynamic> config) async {
    appId = config['appId'] ?? '';
    appSecret = config['appSecret'] ?? '';
    redirectUri = config['redirectUri'] ?? '';
  }

  @override
  Uri getAuthorizationUrl({required String state}) {
    // WeChat web auth example (use proper URL/params per platform)
    return Uri.parse('https://open.weixin.qq.com/connect/qrconnect?appid=$appId&redirect_uri=$redirectUri&response_type=code&scope=snsapi_login&state=$state#wechat_redirect');
  }

  @override
  Future<void> handleAuthorizationCallback(Map<String, String> params) async {
    final code = params['code'];
    if (code == null) throw Exception('Missing code');
    // Exchange code for token - placeholder
    accessToken = 'wechat-demo-token-$code';
  }

  @override
  Future<String> uploadBackup(File backupFile) async {
    final size = await backupFile.length();
    final id = 'wechat-${DateTime.now().millisecondsSinceEpoch}';
    await Future.delayed(const Duration(milliseconds: 300));
    return jsonEncode({'id': id, 'size': size});
  }

  @override
  Future<File> downloadBackup(String remoteId, String downloadToPath) async {
    final file = File(downloadToPath);
    await file.create(recursive: true);
    await file.writeAsString('remoteId:$remoteId');
    return file;
  }

  @override
  Future<void> revoke() async {
    accessToken = null;
  }
}

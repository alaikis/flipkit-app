import 'dart:convert';
import 'dart:io';

import 'backup_adapter.dart';

class BaiduAdapter implements BackupAdapter {
  late String clientId;
  late String clientSecret;
  late String redirectUri;
  String? accessToken;

  BaiduAdapter();

  @override
  Future<void> init(Map<String, dynamic> config) async {
    clientId = config['clientId'] ?? '';
    clientSecret = config['clientSecret'] ?? '';
    redirectUri = config['redirectUri'] ?? 'urn:ietf:wg:oauth:2.0:oob';
  }

  @override
  Uri getAuthorizationUrl({required String state}) {
    // Baidu OAuth 2.0 example URL (needs correct params in production)
    return Uri.parse('https://openapi.baidu.com/oauth/2.0/authorize?client_id=$clientId&response_type=code&redirect_uri=$redirectUri&state=$state');
  }

  @override
  Future<void> handleAuthorizationCallback(Map<String, String> params) async {
    final code = params['code'];
    if (code == null) throw Exception('Missing code');
    // Exchange code for token - placeholder implementation
    // In production: POST https://openapi.baidu.com/oauth/2.0/token
    accessToken = 'demo-token-from-code-$code';
  }

  @override
  Future<String> uploadBackup(File backupFile) async {
    // Placeholder: real upload would call Baidu PCS APIs using accessToken
    // For now simulate by returning a fake remote id
    final size = await backupFile.length();
    final id = 'baidu-${DateTime.now().millisecondsSinceEpoch}';
    // simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    return jsonEncode({'id': id, 'size': size});
  }

  @override
  Future<File> downloadBackup(String remoteId, String downloadToPath) async {
    // Placeholder: simulate download by creating an empty file
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

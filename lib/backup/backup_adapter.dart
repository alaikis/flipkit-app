import 'dart:io';

/// BackupAdapter: abstract interface for cloud backup providers (OAuth, upload, download)
abstract class BackupAdapter {
  /// Initialize adapter with provider-specific config (clientId, clientSecret, redirectUri...)
  Future<void> init(Map<String, dynamic> config);

  /// Get authorization URL to start OAuth flow (mobile: open in webview/browser)
  Uri getAuthorizationUrl({required String state});

  /// Handle OAuth callback (exchange code for token)
  /// `params` may contain code/state returned by provider.
  Future<void> handleAuthorizationCallback(Map<String, String> params);

  /// Upload a local backup file and return a remote id or URL
  Future<String> uploadBackup(File backupFile);

  /// Download a backup by id to local path, return file path
  Future<File> downloadBackup(String remoteId, String downloadToPath);

  /// Revoke token / logout
  Future<void> revoke();
}

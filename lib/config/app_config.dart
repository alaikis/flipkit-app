/// 应用配置
class AppConfig {
  /// 应用信息
  static const String appName = 'FlipKit';
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';

  /// 数据库配置
  static const String dbName = 'flipkit.db';
  static const int dbVersion = 1;

  /// 本地存储
  static const String storageKey = 'flipkit_storage';
  static const String secureStorageKey = 'flipkit_secure';

  /// 主题配置
  static const bool useDarkTheme = false;
  static const String primaryColor = '#2196F3';

  /// 学习配置
  static const int questionsPerBatch = 10;
  static const int dailyGoalMinutes = 30;
  static const int maxRetries = 3;

  /// OCR 配置
  static const double ocrConfidenceThreshold = 0.7;

  /// 资源配置
  static const String githubRepo = ''; // 用户的 GitHub 仓库
  static const String resourceCacheDir = 'resources';
  static const int maxCacheSizeMB = 500;

  /// 网络配置
  static const int connectTimeout = 30000; // 30秒
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;
}

/// 学习模块配置
class ModuleConfig {
  /// 支持的学习模块
  static const List<String> modules = [
    '听写',
    '问答',
    '作文',
  ];

  /// 科目列表
  static const List<String> subjects = [
    '语文',
    '数学',
    '英语',
    '科学',
    '历史',
    '地理',
  ];

  /// 年级列表
  static const List<String> grades = [
    '一年级',
    '二年级',
    '三年级',
    '四年级',
    '五年级',
    '六年级',
    '七年级',
    '八年级',
    '九年级',
    '高一',
    '高二',
    '高三',
  ];
}

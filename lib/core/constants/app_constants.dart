/// 应用常量
class AppConstants {
  // ==================== 路由路径 ====================
  static const String routeSplash = '/splash';
  static const String routeHome = '/home';
  static const String routeOnboarding = '/onboarding';
  static const String routeLogin = '/login';
  static const String routeDictation = '/dictation';
  static const String routeQuiz = '/quiz';
  static const String routeEssay = '/essay';
  static const String routeDaoism = '/daoism';
  static const String routeSettings = '/settings';
  static const String routeProfile = '/profile';
  static const String routeResources = '/resources';
  static const String routeGitHub = '/github';

  // ==================== 存储键 ====================
  static const String keyFirstLaunch = 'first_launch';
  static const String keyUserId = 'user_id';
  static const String keyCurrentSpaceId = 'current_space_id';
  static const String keyDarkMode = 'dark_mode';
  static const String keyAIProvider = 'ai_provider';
  static const String keyLanguage = 'language';

  // ==================== API 端点 ====================
  static const String endpointGenerateQuestions = '/generate/questions';
  static const String endpointEvaluateAnswer = '/evaluate/answer';
  static const String endpointGradeEssay = '/grade/essay';
  static const String endpointGenerateFeedback = '/generate/feedback';

  // ==================== 文件路径 ====================
  static const String pathResources = 'resources';
  static const String pathCache = 'cache';
  static const String pathImages = 'images';
  static const String pathAudio = 'audio';

  // ==================== 时间常量 ====================
  static const int splashDuration = 2000; // 2秒
  static const int animationDuration = 300; // 300ms
  static const int debounceDuration = 500; // 500ms

  // ==================== UI 常量 ====================
  static const double borderRadius = 12.0;
  static const double cardElevation = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;

  // ==================== 题型 ====================
  static const List<String> questionTypes = [
    '选择题',
    '填空题',
    '判断题',
    '简答题',
    '作文题',
    '诵读题',
  ];

  // ==================== 难度等级 ====================
  static const List<String> difficultyLevels = [
    '简单',
    '中等',
    '困难',
  ];

  // ==================== 科目列表 ====================
  static const List<String> subjects = [
    '语文',
    '数学',
    '英语',
    '物理',
    '化学',
    '生物',
    '历史',
    '地理',
    '政治',
  ];

  // ==================== 年级列表 ====================
  static const List<String> gradeLevels = [
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

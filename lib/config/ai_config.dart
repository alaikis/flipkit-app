/// AI 服务配置
class AIConfig {
  /// 支持的 AI 提供商
  static const List<AIProvider> providers = [
    AIProvider(
      name: 'Deepseek',
      apiKey: '',
      baseUrl: 'https://api.deepseek.com/v1',
      models: ['deepseek-chat', 'deepseek-coder'],
    ),
    AIProvider(
      name: '通义千问',
      apiKey: '',
      baseUrl: 'https://dashscope.aliyuncs.com/api/v1',
      models: ['qwen-turbo', 'qwen-plus', 'qwen-max'],
    ),
    AIProvider(
      name: '文心一言',
      apiKey: '',
      baseUrl: 'https://aip.baidubce.com/rpc/2.0/ai_custom/v1/wenxinworkshop',
      models: ['ernie-bot', 'ernie-bot-turbo'],
    ),
    AIProvider(
      name: '智谱AI',
      apiKey: '',
      baseUrl: 'https://open.bigmodel.cn/api/paas/v4',
      models: ['glm-4', 'glm-3-turbo'],
    ),
    AIProvider(
      name: 'Kimi',
      apiKey: '',
      baseUrl: 'https://api.moonshot.cn/v1',
      models: ['moonshot-v1-8k', 'moonshot-v1-32k'],
    ),
  ];

  /// 当前使用的提供商
  static String currentProvider = 'Deepseek';

  /// 默认模型
  static String defaultModel = 'deepseek-chat';
}

/// AI 提供商配置
class AIProvider {
  final String name;
  final String apiKey;
  final String baseUrl;
  final List<String> models;

  const AIProvider({
    required this.name,
    required this.apiKey,
    required this.baseUrl,
    required this.models,
  });
}

import '../model_adapter.dart';
import 'openai_adapter.dart';
import 'deepseek_adapter.dart';
import 'doubao_adapter.dart';
import 'coze_adapter.dart';
import 'qianwen_adapter.dart';
import 'yiyan_adapter.dart';

class ModelAdapterFactory {
  static ModelAdapter createAdapter(String provider, Map<String, dynamic> config) {
    switch (provider.toLowerCase()) {
      case 'openai':
        final adapter = OpenAIAdapter(model: config['model'] ?? 'gpt-3.5-turbo');
        adapter.init(config);
        return adapter;
      case 'deepseek':
        final adapter = DeepseekAdapter(model: config['model'] ?? 'deepseek-chat');
        adapter.init(config);
        return adapter;
      case 'doubao':
        final adapter = DoubaoAdapter(model: config['model'] ?? 'doubao-pro');
        adapter.init(config);
        return adapter;
      case 'coze':
        final adapter = CozeAdapter(botId: config['botId'] ?? '');
        adapter.init(config);
        return adapter;
      case 'qianwen':
        final adapter = QianwenAdapter(model: config['model'] ?? 'qwen-max');
        adapter.init(config);
        return adapter;
      case 'yiyan':
        final adapter = YiyanAdapter();
        adapter.init(config);
        return adapter;
      default:
        // Default to OpenAI-compatible adapter
        final adapter = OpenAIAdapter(
          model: config['model'] ?? 'gpt-3.5-turbo',
          baseUrl: config['baseUrl'] ?? 'https://api.openai.com/v1',
        );
        adapter.init(config);
        return adapter;
    }
  }

  static List<String> getSupportedProviders() {
    return ['openai', 'deepseek', 'doubao', 'coze', 'qianwen', 'yiyan'];
  }
}

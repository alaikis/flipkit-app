import 'package:dio/dio.dart';
import '../model_adapter.dart';

class YiyanAdapter implements ModelAdapter {
  late String apiKey;
  late String secretKey;
  final Dio _dio = Dio();
  static const baseUrl = 'https://aip.baidubce.com/rpc/2.0/ai_custom/v1';

  YiyanAdapter();

  @override
  Future<void> init(Map<String, dynamic> config) async {
    apiKey = config['apiKey'] ?? '';
    secretKey = config['secretKey'] ?? '';
  }

  @override
  Future<String> generate(String prompt, {Map<String, dynamic>? params}) async {
    try {
      final accessToken = await _getAccessToken();
      final response = await _dio.post(
        '$baseUrl/wenxin/eb-instant?access_token=$accessToken',
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: {
          'messages': [{'role': 'user', 'content': prompt}],
          'temperature': params?['temperature'] ?? 0.7,
          'top_p': params?['topP'] ?? 1.0,
        },
      );
      return response.data['result'] ?? '';
    } catch (e) {
      throw Exception('Yiyan API error: $e');
    }
  }

  @override
  Stream<String> generateStream(String prompt, {Map<String, dynamic>? params}) async* {
    try {
      final result = await generate(prompt, params: params);
      yield result;
    } catch (e) {
      yield 'Error: $e';
    }
  }

  @override
  Future<List<double>> embed(String text, {Map<String, dynamic>? params}) async {
    return List.filled(384, 0.0);
  }

  @override
  Future<void> close() async {
    _dio.close();
  }

  Future<String> _getAccessToken() async {
    // Placeholder: real implementation would fetch token from Baidu API
    // POST https://aip.baidubce.com/oauth/2.0/token
    return 'placeholder_token';
  }
}

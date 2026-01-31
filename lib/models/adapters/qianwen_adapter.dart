import 'package:dio/dio.dart';
import '../model_adapter.dart';

class QianwenAdapter implements ModelAdapter {
  late String apiKey;
  late String model;
  final Dio _dio = Dio();
  static const baseUrl = 'https://dashscope.aliyuncs.com/api/v1';

  QianwenAdapter({this.model = 'qwen-max'});

  @override
  Future<void> init(Map<String, dynamic> config) async {
    apiKey = config['apiKey'] ?? '';
    model = config['model'] ?? 'qwen-max';
  }

  @override
  Future<String> generate(String prompt, {Map<String, dynamic>? params}) async {
    try {
      final response = await _dio.post(
        '$baseUrl/services/aigc/text-generation/generation',
        options: Options(
          headers: {'Authorization': 'Bearer $apiKey', 'Content-Type': 'application/json'},
        ),
        data: {
          'model': model,
          'input': {'messages': [{'role': 'user', 'content': prompt}]},
        },
      );
      return response.data['output']['text'] ?? '';
    } catch (e) {
      throw Exception('Qianwen API error: $e');
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
    return List.filled(1536, 0.0);
  }

  @override
  Future<void> close() async {
    _dio.close();
  }
}

import 'package:dio/dio.dart';
import '../model_adapter.dart';

class DoubaoAdapter implements ModelAdapter {
  late String apiKey;
  late String model;
  final Dio _dio = Dio();
  static const baseUrl = 'https://api.doubao.com/v1';

  DoubaoAdapter({this.model = 'doubao-pro'});

  @override
  Future<void> init(Map<String, dynamic> config) async {
    apiKey = config['apiKey'] ?? '';
    model = config['model'] ?? 'doubao-pro';
  }

  @override
  Future<String> generate(String prompt, {Map<String, dynamic>? params}) async {
    try {
      final response = await _dio.post(
        '$baseUrl/chat/completions',
        options: Options(
          headers: {'Authorization': 'Bearer $apiKey', 'Content-Type': 'application/json'},
        ),
        data: {
          'model': model,
          'messages': [{'role': 'user', 'content': prompt}],
          'max_tokens': params?['maxTokens'] ?? 1000,
        },
      );
      return response.data['choices'][0]['message']['content'] ?? '';
    } catch (e) {
      throw Exception('Doubao API error: $e');
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
    return List.filled(768, 0.0);
  }

  @override
  Future<void> close() async {
    _dio.close();
  }
}

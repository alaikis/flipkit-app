import 'package:dio/dio.dart';
import '../model_adapter.dart';

class OpenAIAdapter implements ModelAdapter {
  late String apiKey;
  late String model;
  late String baseUrl;
  final Dio _dio = Dio();

  OpenAIAdapter({this.model = 'gpt-3.5-turbo', this.baseUrl = 'https://api.openai.com/v1'});

  @override
  Future<void> init(Map<String, dynamic> config) async {
    apiKey = config['apiKey'] ?? '';
    model = config['model'] ?? 'gpt-3.5-turbo';
    baseUrl = config['baseUrl'] ?? 'https://api.openai.com/v1';
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
          'temperature': params?['temperature'] ?? 0.7,
        },
      );
      return response.data['choices'][0]['message']['content'] ?? '';
    } catch (e) {
      throw Exception('OpenAI API error: $e');
    }
  }

  @override
  Stream<String> generateStream(String prompt, {Map<String, dynamic>? params}) async* {
    // Placeholder for streaming
    try {
      final result = await generate(prompt, params: params);
      yield result;
    } catch (e) {
      yield 'Error: $e';
    }
  }

  @override
  Future<List<double>> embed(String text, {Map<String, dynamic>? params}) async {
    // Placeholder embedding implementation
    return List.filled(1536, 0.0);
  }

  @override
  Future<void> close() async {
    _dio.close();
  }
}

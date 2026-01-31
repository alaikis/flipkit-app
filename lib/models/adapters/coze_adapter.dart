import 'package:dio/dio.dart';
import '../model_adapter.dart';

class CozeAdapter implements ModelAdapter {
  late String apiKey;
  late String botId;
  final Dio _dio = Dio();
  static const baseUrl = 'https://api.coze.com/v1';

  CozeAdapter({this.botId = ''});

  @override
  Future<void> init(Map<String, dynamic> config) async {
    apiKey = config['apiKey'] ?? '';
    botId = config['botId'] ?? '';
  }

  @override
  Future<String> generate(String prompt, {Map<String, dynamic>? params}) async {
    try {
      final response = await _dio.post(
        '$baseUrl/conversation/message',
        options: Options(
          headers: {'Authorization': 'Bearer $apiKey', 'Content-Type': 'application/json'},
        ),
        data: {
          'bot_id': botId,
          'user_id': 'app_user',
          'query': prompt,
        },
      );
      return response.data['msg'] ?? '';
    } catch (e) {
      throw Exception('Coze API error: $e');
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

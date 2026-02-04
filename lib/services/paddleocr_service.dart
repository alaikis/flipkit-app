import 'package:flutter/services.dart';
import 'ocr_service_base.dart';
import '../core/utils/logger.dart';

/// PaddleOCR 服务 - 国内开源 OCR 解决方案
/// 
/// PaddleOCR 是百度开源的 OCR 项目，支持多种语言，识别准确率高
/// 项目地址: https://github.com/PaddlePaddle/PaddleOCR
/// 
/// 特点：
/// - 完全开源，免费使用
/// - 支持中英文混排
/// - 轻量级，可本地运行
/// - 支持倾斜矫正
class PaddleOCRService extends OCRServiceBase {
  MethodChannel? _channel;
  bool _isInitialized = false;

  static const String _channelName = 'com.flipkit.paddleocr';

  @override
  Future<void> initialize() async {
    if (_isInitialized) {
      Logger.info('PaddleOCR 已初始化', tag: 'PaddleOCRService');
      return;
    }

    try {
      _channel = MethodChannel(_channelName);
      
      // 调用原生平台初始化
      await _channel!.invokeMethod('initialize');
      
      _isInitialized = true;
      Logger.info('PaddleOCR 初始化成功', tag: 'PaddleOCRService');
    } catch (e) {
      Logger.error('PaddleOCR 初始化失败', error: e, tag: 'PaddleOCRService');
      rethrow;
    }
  }

  @override
  Future<String> recognizeText(String imagePath) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final result = await _channel!.invokeMethod<String>('recognize', {
        'imagePath': imagePath,
      });

      if (result == null) {
        throw Exception('OCR 识别返回空结果');
      }

      Logger.info('OCR 识别完成', tag: 'PaddleOCRService');
      return result;
    } catch (e) {
      Logger.error('OCR 识别失败', error: e, tag: 'PaddleOCRService');
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> recognizeTextWithRegions(String imagePath) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final result = await _channel!.invokeMethod<List<dynamic>>('recognizeWithRegions', {
        'imagePath': imagePath,
      });

      if (result == null || result.isEmpty) {
        return [];
      }

      final regions = result.map((item) {
        return {
          'text': item['text'] as String,
          'confidence': item['confidence'] as double,
          'box': item['box'] as List<double>,
          'angle': item['angle'] as double,
        };
      }).toList();

      Logger.info('OCR 识别完成，识别到 ${regions.length} 个区域', tag: 'PaddleOCRService');
      return regions;
    } catch (e) {
      Logger.error('OCR 识别失败', error: e, tag: 'PaddleOCRService');
      rethrow;
    }
  }

  @override
  void dispose() {
    if (_isInitialized) {
      _channel?.invokeMethod('dispose');
      _isInitialized = false;
      Logger.info('PaddleOCR 已释放', tag: 'PaddleOCRService');
    }
  }

  /// 获取 PaddleOCR 版本
  Future<String> getVersion() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final version = await _channel!.invokeMethod<String>('getVersion');
      return version ?? 'unknown';
    } catch (e) {
      Logger.error('获取版本失败', error: e, tag: 'PaddleOCRService');
      return 'unknown';
    }
  }

  /// 设置识别参数
  Future<void> setParams({
    String? language,
    bool? useAngleClassifier,
    bool? useGPU,
    int? maxSideLen,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      await _channel!.invokeMethod('setParams', {
        if (language != null) 'language': language,
        if (useAngleClassifier != null) 'useAngleClassifier': useAngleClassifier,
        if (useGPU != null) 'useGPU': useGPU,
        if (maxSideLen != null) 'maxSideLen': maxSideLen,
      });

      Logger.info('OCR 参数已更新', tag: 'PaddleOCRService');
    } catch (e) {
      Logger.error('设置参数失败', error: e, tag: 'PaddleOCRService');
    }
  }
}

import 'dart:io';
import 'package:flutter/services.dart';
import 'ocr_service_base.dart';
import '../core/utils/logger.dart';

/// Tesseract OCR 服务
/// 
/// Tesseract 是 Google 开源的 OCR 引擎，支持多种语言
/// 项目地址: https://github.com/tesseract-ocr/tesseract
/// 
/// 特点：
/// - 完全开源，免费使用
/// - 支持 100+ 种语言
/// - 社区活跃，文档丰富
/// - 可在 Linux/macOS/Windows 运行
class TesseractService extends OCRServiceBase {
  MethodChannel? _channel;
  bool _isInitialized = false;
  String? _currentLanguage;

  static const String _channelName = 'com.flipkit.tesseract';

  @override
  Future<void> initialize() async {
    if (_isInitialized) {
      Logger.info('Tesseract 已初始化', tag: 'TesseractService');
      return;
    }

    try {
      _channel = MethodChannel(_channelName);
      
      // 调用原生平台初始化
      await _channel!.invokeMethod('initialize');
      
      _isInitialized = true;
      Logger.info('Tesseract 初始化成功', tag: 'TesseractService');
    } catch (e) {
      Logger.error('Tesseract 初始化失败', error: e, tag: 'TesseractService');
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
        'language': _currentLanguage ?? 'chi_sim+eng',
      });

      if (result == null) {
        throw Exception('OCR 识别返回空结果');
      }

      Logger.info('OCR 识别完成', tag: 'TesseractService');
      return result;
    } catch (e) {
      Logger.error('OCR 识别失败', error: e, tag: 'TesseractService');
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
        'language': _currentLanguage ?? 'chi_sim+eng',
      });

      if (result == null || result.isEmpty) {
        return [];
      }

      final regions = result.map((item) {
        return {
          'text': item['text'] as String,
          'confidence': item['confidence'] as double,
          'box': item['box'] as List<int>,
        };
      }).toList();

      Logger.info('OCR 识别完成，识别到 ${regions.length} 个区域', tag: 'TesseractService');
      return regions;
    } catch (e) {
      Logger.error('OCR 识别失败', error: e, tag: 'TesseractService');
      rethrow;
    }
  }

  @override
  void dispose() {
    if (_isInitialized) {
      _channel?.invokeMethod('dispose');
      _isInitialized = false;
      Logger.info('Tesseract 已释放', tag: 'TesseractService');
    }
  }

  /// 设置识别语言
  /// 
  /// 支持的语言：
  /// - chi_sim: 简体中文
  /// - chi_tra: 繁体中文
  /// - eng: 英文
  /// - jpn: 日文
  /// - kor: 韩文
  /// - 多语言组合: 'chi_sim+eng'
  Future<void> setLanguage(String language) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      await _channel!.invokeMethod('setLanguage', {'language': language});
      _currentLanguage = language;
      Logger.info('OCR 语言已设置为: $language', tag: 'TesseractService');
    } catch (e) {
      Logger.error('设置语言失败', error: e, tag: 'TesseractService');
    }
  }

  /// 获取 Tesseract 版本
  Future<String> getVersion() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final version = await _channel!.invokeMethod<String>('getVersion');
      return version ?? 'unknown';
    } catch (e) {
      Logger.error('获取版本失败', error: e, tag: 'TesseractService');
      return 'unknown';
    }
  }

  /// 设置识别参数
  Future<void> setParams({
    int? pageSegMode,
    int? ocrEngineMode,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      await _channel!.invokeMethod('setParams', {
        if (pageSegMode != null) 'pageSegMode': pageSegMode,
        if (ocrEngineMode != null) 'ocrEngineMode': ocrEngineMode,
      });

      Logger.info('OCR 参数已更新', tag: 'TesseractService');
    } catch (e) {
      Logger.error('设置参数失败', error: e, tag: 'TesseractService');
    }
  }
}

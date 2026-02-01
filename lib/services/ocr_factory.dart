import 'dart:io';
import 'ocr_service_base.dart';
import 'paddleocr_service.dart';
import 'tesseract_service.dart';
import '../core/utils/logger.dart';

/// OCR 服务工厂
/// 
/// 根据平台和配置选择合适的 OCR 服务
class OCRFactory {
  static OCRServiceBase? _instance;
  static OCRProvider? _currentProvider;

  /// OCR 提供商类型
  static const Map<OCRProvider, String> providerNames = {
    OCRProvider.auto: '自动选择',
    OCRProvider.googleMLKit: 'Google ML Kit',
    OCRProvider.paddleOCR: 'PaddleOCR（百度开源）',
    OCRProvider.tesseract: 'Tesseract（Google开源）',
  };

  /// 获取 OCR 服务实例
  static Future<OCRServiceBase> getService({OCRProvider? provider}) async {
    provider ??= _currentProvider ?? OCRProvider.auto;

    if (_instance != null && _currentProvider == provider) {
      return _instance!;
    }

    // 释放旧实例
    if (_instance != null) {
      _instance!.dispose();
      _instance = null;
    }

    // 创建新实例
    switch (provider) {
      case OCRProvider.auto:
        _instance = await _autoSelectProvider();
        break;
      case OCRProvider.googleMLKit:
        _instance = await _createGoogleMLKit();
        break;
      case OCRProvider.paddleOCR:
        _instance = PaddleOCRService();
        break;
      case OCRProvider.tesseract:
        _instance = TesseractService();
        break;
    }

    _currentProvider = provider;
    
    // 初始化服务
    try {
      await _instance!.initialize();
      Logger.info('OCR 服务已创建: ${providerNames[provider]}', tag: 'OCRFactory');
    } catch (e) {
      Logger.error('OCR 服务初始化失败，尝试切换到备用方案', error: e, tag: 'OCRFactory');
      
      // 初始化失败，尝试使用 Tesseract 作为备用
      if (provider != OCRProvider.tesseract) {
        Logger.info('尝试使用 Tesseract 作为备用方案', tag: 'OCRFactory');
        _instance = TesseractService();
        await _instance!.initialize();
        _currentProvider = OCRProvider.tesseract;
      } else {
        rethrow;
      }
    }

    return _instance!;
  }

  /// 自动选择最合适的 OCR 提供商
  static Future<OCRServiceBase> _autoSelectProvider() async {
    if (Platform.isAndroid || Platform.isIOS) {
      // 移动端优先使用 Google ML Kit
      Logger.info('移动端平台，使用 Google ML Kit', tag: 'OCRFactory');
      return await _createGoogleMLKit();
    } else if (Platform.isLinux || Platform.isMacOS) {
      // Linux/macOS 使用 Tesseract
      Logger.info('桌面平台，使用 Tesseract', tag: 'OCRFactory');
      return TesseractService();
    } else if (Platform.isWindows) {
      // Windows 使用 PaddleOCR
      Logger.info('Windows 平台，使用 PaddleOCR', tag: 'OCRFactory');
      return PaddleOCRService();
    } else {
      // 默认使用 Tesseract
      Logger.info('未知平台，使用 Tesseract', tag: 'OCRFactory');
      return TesseractService();
    }
  }

  /// 创建 Google ML Kit 服务
  static Future<OCRServiceBase> _createGoogleMLKit() async {
    // 这里需要根据实际项目中的 Google ML Kit 服务创建
    // 暂时返回占位符
    throw UnimplementedError('Google ML Kit 服务需要单独实现');
  }

  /// 获取当前提供商
  static OCRProvider? getCurrentProvider() => _currentProvider;

  /// 重置服务
  static void reset() {
    if (_instance != null) {
      _instance!.dispose();
      _instance = null;
    }
    _currentProvider = null;
  }
}

/// OCR 提供商枚举
enum OCRProvider {
  /// 自动选择
  auto,
  
  /// Google ML Kit（移动端）
  googleMLKit,
  
  /// PaddleOCR（百度开源）
  paddleOCR,
  
  /// Tesseract（Google开源）
  tesseract,
}

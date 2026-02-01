import 'dart:io';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'ocr_factory.dart';
import '../core/utils/logger.dart';

/// OCR 服务 - 图像文字识别
/// 
/// 现支持多种 OCR 引擎：
/// - Google ML Kit（移动端，闭源）
/// - PaddleOCR（百度开源，推荐）
/// - Tesseract（Google开源，备用）
/// 
/// 使用 OCRFactory 自动选择合适的引擎
class OCRService {
  static final OCRService _instance = OCRService._internal();
  factory OCRService() => _instance;

  OCRService._internal();

  TextRecognizer? _textRecognizer;
  OCRProvider? _currentProvider;

  /// 初始化（使用默认 OCR 提供商）
  Future<void> init() async {
    try {
      await initWithProvider();
    } catch (e) {
      Logger.error('Failed to initialize OCR service', error: e, tag: 'OCRService');
      // 不抛出异常，允许应用继续运行
    }
  }

  /// 使用指定提供商初始化
  Future<void> initWithProvider({OCRProvider? provider}) async {
    // 尝试使用开源 OCR 服务
    try {
      final ocrBase = await OCRFactory.getService(provider: provider);
      _currentProvider = OCRFactory.getCurrentProvider();
      Logger.info('OCR Service initialized with ${OCRFactory.providerNames[_currentProvider]}', 
                  tag: 'OCRService');
      return;
    } catch (e) {
      Logger.warning('开源 OCR 初始化失败，回退到 Google ML Kit: $e', tag: 'OCRService');
    }

    // 回退到 Google ML Kit
    try {
      _textRecognizer = GoogleMlKit.vision.textRecognizer();
      _currentProvider = OCRProvider.googleMLKit;
      Logger.info('OCR Service initialized with Google ML Kit (fallback)', 
                  tag: 'OCRService');
    } catch (e, stackTrace) {
      Logger.error('Google ML Kit 初始化失败',
          error: e, stackTrace: stackTrace, tag: 'OCRService');
      rethrow;
    }
  }

  /// 识别图片中的文字
  Future<String> recognizeText(File imageFile) async {
    try {
      Logger.info('Recognizing text from image', tag: 'OCRService');

      // 如果使用 Google ML Kit
      if (_currentProvider == OCRProvider.googleMLKit && _textRecognizer != null) {
        return await _recognizeWithGoogleMLKit(imageFile);
      }

      // 如果使用开源 OCR
      return await _recognizeWithOpenSource(imageFile);
    } catch (e, stackTrace) {
      Logger.error('Failed to recognize text',
          error: e, stackTrace: stackTrace, tag: 'OCRService');
      
      // 如果当前方法失败，尝试切换到备用方案
      if (_currentProvider != OCRProvider.tesseract) {
        Logger.info('尝试切换到 Tesseract 作为备用方案', tag: 'OCRService');
        try {
          await initWithProvider(provider: OCRProvider.tesseract);
          return await _recognizeWithOpenSource(imageFile);
        } catch (e2) {
          Logger.error('备用 OCR 也失败', error: e2, tag: 'OCRService');
        }
      }
      
      rethrow;
    }
  }

  /// 使用 Google ML Kit 识别
  Future<String> _recognizeWithGoogleMLKit(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final recognizedText = await _textRecognizer!.processImage(inputImage);

    String text = '';
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        text += '${line.text}\n';
      }
    }

    Logger.info('Google ML Kit OCR completed. Text length: ${text.length}', 
                tag: 'OCRService');
    return text.trim();
  }

  /// 使用开源 OCR 识别
  Future<String> _recognizeWithOpenSource(File imageFile) async {
    final ocrBase = await OCRFactory.getService();
    final text = await ocrBase.recognizeText(imageFile.path);
    Logger.info('Open Source OCR completed. Text length: ${text.length}', 
                tag: 'OCRService');
    return text;
  }

  /// 计算文本相似度 (Levenshtein 距离)
  double calculateSimilarity(String text1, String text2) {
    final distance = _levenshteinDistance(text1, text2);
    final maxLength = text1.length > text2.length ? text1.length : text2.length;
    return maxLength == 0 ? 1.0 : 1.0 - (distance / maxLength);
  }

  /// Levenshtein 距离算法
  int _levenshteinDistance(String a, String b) {
    final m = a.length;
    final n = b.length;

    if (m == 0) return n;
    if (n == 0) return m;

    List<List<int>> dp = List.generate(m + 1, (i) => List.filled(n + 1, 0));

    for (int i = 0; i <= m; i++) {
      dp[i][0] = i;
    }

    for (int j = 0; j <= n; j++) {
      dp[0][j] = j;
    }

    for (int i = 1; i <= m; i++) {
      for (int j = 1; j <= n; j++) {
        if (a[i - 1] == b[j - 1]) {
          dp[i][j] = dp[i - 1][j - 1];
        } else {
          dp[i][j] = 1 + [
            dp[i - 1][j],
            dp[i][j - 1],
            dp[i - 1][j - 1]
          ].reduce((a, b) => a < b ? a : b);
        }
      }
    }

    return dp[m][n];
  }

  /// 对比原文和识别结果，返回差异分析
  Map<String, dynamic> compareTexts(String original, String recognized) {
    final originalChars = original.replaceAll(' ', '').split('');
    final recognizedChars = recognized.replaceAll(' ', '').split('');

    final similarity = calculateSimilarity(original, recognized);

    List<String> missing = [];
    List<String> extra = [];
    List<Map<String, String>> wrong = [];

    int i = 0, j = 0;
    while (i < originalChars.length && j < recognizedChars.length) {
      if (originalChars[i] == recognizedChars[j]) {
        i++;
        j++;
      } else {
        // 检查是否是多余字符
        if (j + 1 < recognizedChars.length &&
            originalChars[i] == recognizedChars[j + 1]) {
          extra.add(recognizedChars[j]);
          j++;
        }
        // 检查是否是缺失字符
        else if (i + 1 < originalChars.length &&
            originalChars[i + 1] == recognizedChars[j]) {
          missing.add(originalChars[i]);
          i++;
        }
        // 否则是错误字符
        else {
          wrong.add({'原字': originalChars[i], '识别为': recognizedChars[j]});
          i++;
          j++;
        }
      }
    }

    // 处理剩余字符
    while (i < originalChars.length) {
      missing.add(originalChars[i]);
      i++;
    }

    while (j < recognizedChars.length) {
      extra.add(recognizedChars[j]);
      j++;
    }

    return {
      '相似度': similarity,
      '缺失': missing,
      '多余': extra,
      '错误': wrong,
      '总字符数': originalChars.length,
      '错误总数': missing.length + extra.length + wrong.length,
    };
  }

  /// 从相机拍照
  Future<File?> pickImageFromCamera() async {
    try {
      final picker = ImagePicker();
      final XFile? photo = await picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        return File(photo.path);
      }
      return null;
    } catch (e, stackTrace) {
      Logger.error('Failed to pick image from camera',
          error: e, stackTrace: stackTrace, tag: 'OCRService');
      return null;
    }
  }

  /// 从相册选择
  Future<File?> pickImageFromGallery() async {
    try {
      final picker = ImagePicker();
      final XFile? photo = await picker.pickImage(source: ImageSource.gallery);
      if (photo != null) {
        return File(photo.path);
      }
      return null;
    } catch (e, stackTrace) {
      Logger.error('Failed to pick image from gallery',
          error: e, stackTrace: stackTrace, tag: 'OCRService');
      return null;
    }
  }

  /// 释放资源
  void dispose() {
    _textRecognizer?.close();
    Logger.info('OCR Service disposed', tag: 'OCRService');
  }
}

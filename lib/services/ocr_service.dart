import 'dart:io';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import '../core/utils/logger.dart';

/// OCR 服务 - 图像文字识别
class OCRService {
  static final OCRService _instance = OCRService._internal();
  factory OCRService() => _instance;

  OCRService._internal();

  TextRecognizer? _textRecognizer;

  /// 初始化
  Future<void> init() async {
    _textRecognizer = GoogleMlKit.vision.textRecognizer();
    Logger.info('OCR Service initialized', tag: 'OCRService');
  }

  /// 识别图片中的文字
  Future<String> recognizeText(File imageFile) async {
    try {
      Logger.info('Recognizing text from image', tag: 'OCRService');

      // 创建输入图像
      final inputImage = InputImage.fromFile(imageFile);

      // 识别文字
      final RecognizedText recognizedText =
          await _textRecognizer!.processImage(inputImage);

      // 提取文字
      String text = '';
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          text += '${line.text}\n';
        }
      }

      Logger.info('OCR completed. Text length: ${text.length}', tag: 'OCRService');
      return text.trim();
    } catch (e, stackTrace) {
      Logger.error('Failed to recognize text',
          error: e, stackTrace: stackTrace, tag: 'OCRService');
      rethrow;
    }
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

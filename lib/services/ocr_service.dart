import 'dart:io';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image/image.dart' as img;
import '../config/app_config.dart';
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

      // 压缩图片
      final compressedImage = await _compressImage(imageFile);

      // 创建输入图像
      final inputImage = InputImage.fromFile(compressedImage);

      // 识别文字
      final RecognizedText recognizedText =
          await _textRecognizer!.processImage(inputImage);

      // 提取文字
      String text = '';
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          text += line.text + '\n';
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

  /// 压缩图片
  Future<File> _compressImage(File imageFile) async {
    try {
      // 读取图片
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // 计算新尺寸
      final maxDimension = 1280;
      int width = image.width;
      int height = image.height;

      if (width > maxDimension || height > maxDimension) {
        if (width > height) {
          height = (height * maxDimension / width).round();
          width = maxDimension;
        } else {
          width = (width * maxDimension / height).round();
          height = maxDimension;
        }
      }

      // 调整大小
      final resized = img.copyResize(
        image,
        width: width,
        height: height,
        interpolation: img.Interpolation.linear,
      );

      // 编码为 JPEG
      final compressedBytes = img.encodeJpg(resized, quality: 85);

      // 保存到临时文件
      final tempFile = File(imageFile.path.replaceAll('.jpg', '_compressed.jpg'));
      await tempFile.writeAsBytes(compressedBytes);

      Logger.debug(
        'Image compressed: ${bytes.length} -> ${compressedBytes.length} bytes',
        tag: 'OCRService',
      );

      return tempFile;
    } catch (e, stackTrace) {
      Logger.error('Failed to compress image',
          error: e, stackTrace: stackTrace, tag: 'OCRService');
      return imageFile;
    }
  }

  /// 计算文本相似度 (Levenshtein 距离)
  double calculateSimilarity(String text1, String text2) {
    // 清理文本
    final cleanText1 = text1.replaceAll(RegExp(r'\s+'), '').toLowerCase();
    final cleanText2 = text2.replaceAll(RegExp(r'\s+'), '').toLowerCase();

    if (cleanText1.isEmpty && cleanText2.isEmpty) {
      return 100.0;
    }

    if (cleanText1.isEmpty || cleanText2.isEmpty) {
      return 0.0;
    }

    final distance = _levenshteinDistance(cleanText1, cleanText2);
    final maxLength = cleanText1.length > cleanText2.length
        ? cleanText1.length
        : cleanText2.length;

    final similarity = (1 - distance / maxLength) * 100;
    return similarity;
  }

  /// Levenshtein 距离算法
  int _levenshteinDistance(String text1, String text2) {
    final m = text1.length;
    final n = text2.length;

    // 创建矩阵
    final dp = List.generate(m + 1, (i) => List.filled(n + 1, 0));

    // 初始化第一行和第一列
    for (int i = 0; i <= m; i++) {
      dp[i][0] = i;
    }
    for (int j = 0; j <= n; j++) {
      dp[0][j] = j;
    }

    // 填充矩阵
    for (int i = 1; i <= m; i++) {
      for (int j = 1; j <= n; j++) {
        if (text1[i - 1] == text2[j - 1]) {
          dp[i][j] = dp[i - 1][j - 1];
        } else {
          dp[i][j] = [
            dp[i - 1][j] + 1, // 删除
            dp[i][j - 1] + 1, // 插入
            dp[i - 1][j - 1] + 1, // 替换
          ].reduce((a, b) => a < b ? a : b);
        }
      }
    }

    return dp[m][n];
  }

  /// 查找文本差异
  List<Map<String, dynamic>> findErrors(String original, String recognized) {
    final errors = <Map<String, dynamic>>[];

    final originalWords = original.split(RegExp(r'\s+'));
    final recognizedWords = recognized.split(RegExp(r'\s+'));

    final maxLength =
        originalWords.length > recognizedWords.length
            ? originalWords.length
            : recognizedWords.length;

    for (int i = 0; i < maxLength; i++) {
      final originalWord = i < originalWords.length ? originalWords[i] : '';
      final recognizedWord = i < recognizedWords.length ? recognizedWords[i] : '';

      if (originalWord.isEmpty && recognizedWord.isNotEmpty) {
        errors.add({
          'type': 'extra',
          'original': '',
          'recognized': recognizedWord,
          'position': i,
        });
      } else if (originalWord.isNotEmpty && recognizedWord.isEmpty) {
        errors.add({
          'type': 'missing',
          'original': originalWord,
          'recognized': '',
          'position': i,
        });
      } else if (originalWord != recognizedWord) {
        final similarity = _calculateWordSimilarity(originalWord, recognizedWord);
        if (similarity > 0.8) {
          errors.add({
            'type': 'typo',
            'original': originalWord,
            'recognized': recognizedWord,
            'position': i,
          });
        } else {
          errors.add({
            'type': 'substitution',
            'original': originalWord,
            'recognized': recognizedWord,
            'position': i,
          });
        }
      }
    }

    return errors;
  }

  /// 计算单词相似度
  double _calculateWordSimilarity(String word1, String word2) {
    if (word1.isEmpty && word2.isEmpty) return 1.0;
    if (word1.isEmpty || word2.isEmpty) return 0.0;

    final distance = _levenshteinDistance(word1, word2);
    final maxLength = word1.length > word2.length ? word1.length : word2.length;

    return 1 - distance / maxLength;
  }

  /// 释放资源
  Future<void> dispose() async {
    await _textRecognizer?.close();
    Logger.info('OCR Service disposed', tag: 'OCRService');
  }
}

import 'package:image_picker/image_picker.dart';
import 'ocr_factory.dart';

/// OCR 服务 - 图像文字识别
///
/// 现支持多种 OCR 引擎：
/// - PaddleOCR（百度开源，推荐）
/// - Tesseract（Google开源，备用）
///
/// 使用 OCRFactory 自动选择合适的引擎
/// 注意：已移除 Google ML Kit 以支持国内手机（华为等）
class OCRService {
  static final OCRService _instance = OCRService._internal();
  factory OCRService() => _instance;

  OCRService._internal();

  OCRProvider? _currentProvider;

  /// 初始化（使用默认 OCR 提供商）
  Future<void> init() async {
    try {
      await initWithProvider();
    } catch (e) {
      print('[OCRService] Failed to initialize OCR service: $e');
      // 不抛出异常，允许应用继续运行
    }
  }

  /// 使用指定提供商初始化
  Future<void> initWithProvider({OCRProvider? provider}) async {
    // 尝试使用开源 OCR 服务
    try {
      await OCRFactory.getService(provider: provider);
      _currentProvider = OCRFactory.getCurrentProvider();
      print('[OCRService] Initialized with ${OCRFactory.providerNames[_currentProvider]}');
      return;
    } catch (e) {
      print('[OCRService] Open source OCR failed: $e');
      rethrow;
    }
  }

  /// 识别图片中的文字
  Future<String> recognizeText(String imageFilePath) async {
    try {
      print('[OCRService] Recognizing text from image: $imageFilePath');

      // 使用开源 OCR
      return await _recognizeWithOpenSource(imageFilePath);
    } catch (e, stackTrace) {
      print('[OCRService] Failed to recognize text: $e\n$stackTrace');

      // 如果当前方法失败，尝试切换到备用方案
      if (_currentProvider != OCRProvider.tesseract) {
        print('[OCRService] Trying Tesseract as fallback');
        try {
          await initWithProvider(provider: OCRProvider.tesseract);
          return await _recognizeWithOpenSource(imageFilePath);
        } catch (e2) {
          print('[OCRService] Fallback OCR also failed: $e2');
        }
      }

      rethrow;
    }
  }

  /// 使用开源 OCR 识别
  Future<String> _recognizeWithOpenSource(String imageFilePath) async {
    try {
      final ocrBase = await OCRFactory.getService();
      return await ocrBase.recognizeText(imageFilePath);
    } catch (e) {
      print('[OCRService] Open source OCR failed: $e');
      rethrow;
    }
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

    final similarity = _calculateSimilarity(original, recognized);

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

  /// 计算相似度
  double _calculateSimilarity(String a, String b) {
    if (a == b) return 1.0;
    
    final distance = _levenshteinDistance(a, b);
    final maxLength = a.length > b.length ? a.length : b.length;
    return 1.0 - (distance / maxLength);
  }

  /// 从相机拍照
  Future<String?> pickImageFromCamera() async {
    try {
      final picker = ImagePicker();
      final XFile? photo = await picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        return photo.path;
      }
      return null;
    } catch (e, stackTrace) {
      print('[OCRService] Failed to pick image from camera: $e\n$stackTrace');
      return null;
    }
  }

  /// 从相册选择
  Future<String?> pickImageFromGallery() async {
    try {
      final picker = ImagePicker();
      final XFile? photo = await picker.pickImage(source: ImageSource.gallery);
      if (photo != null) {
        return photo.path;
      }
      return null;
    } catch (e, stackTrace) {
      print('[OCRService] Failed to pick image from gallery: $e\n$stackTrace');
      return null;
    }
  }

  /// 释放资源
  void dispose() {
    // Google ML Kit 已移除，使用开源OCR
    print('[OCRService] Disposed');
  }
}

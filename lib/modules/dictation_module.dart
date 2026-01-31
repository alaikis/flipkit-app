import 'dart:convert';
import 'dart:io';
import '../models/model_adapter.dart';
import '../services/image_processing_service.dart';
import '../services/tts_service.dart';

/// 你播我写 (Dictation module) - 文本转语音播报，用户手写后拍照，OCR识别，对比评分
class DictationModule {
  final ModelAdapter modelAdapter;
  final ImageProcessingService imageService;
  final TTSService? ttsService;
  final String spaceId;

  // 预定义的听写内容库
  final Map<String, Map<String, String>> _dictationContent = {
    'English': {
      'Unit 1': 'The quick brown fox jumps over the lazy dog.',
      'Unit 2': 'Practice makes perfect. Learning English every day.',
      'Unit 3': 'Hello, how are you today? I am fine, thank you.',
    },
    'Chinese': {
      '第一章': '勤能补拙是良训，一分辛苦一分才。',
      '第二章': '千里之行，始于足下。',
      '第三章': '学而时习之，不亦说乎？',
    },
    'Math': {
      '第一节': '两个数相加，然后再减去一个数，结果会改变吗？',
      '第二节': '三角形的三个内角之和等于一百八十度。',
      '第三节': '圆的周长等于直径乘以圆周率。',
    },
  };

  DictationModule({
    required this.modelAdapter,
    required this.imageService,
    required this.spaceId,
    this.ttsService,
  });

  /// Get available subjects
  List<String> getSubjects() => _dictationContent.keys.toList();

  /// Get chapters for a subject
  List<String> getChapters(String subject) {
    return _dictationContent[subject]?.keys.toList() ?? [];
  }

  /// Load dictation content for a specific chapter
  Future<String> loadDictationContent(String subject, String chapter) async {
    return _dictationContent[subject]?[chapter] ?? '';
  }

  /// Play dictation text using TTS (Chinese + English)
  Future<void> playDictation(String text) async {
    if (ttsService != null) {
      await ttsService!.speak(text);
    } else {
      // Fallback: just log if TTS not available
      print('Playing dictation: $text');
    }
  }

  /// Stop TTS playback
  Future<void> stopPlayback() async {
    if (ttsService != null) {
      await ttsService!.stop();
    }
  }

  /// Check if TTS is currently playing
  bool isPlaying() => ttsService?.isSpeaking ?? false;

  /// Compare user's written/OCR result with original, calculate score and error analysis
  Future<Map<String, dynamic>> evaluateDictation({
    required String originalText,
    required File userImageFile,
  }) async {
    // Step 1: OCR the image
    final ocrText = await imageService.recognizeText(userImageFile);
    
    // Step 2: Calculate similarity
    final similarity = imageService.calculateSimilarity(originalText, ocrText);
    final score = (similarity * 100).toStringAsFixed(1);
    
    // Step 3: Find detailed errors
    final errors = imageService.findErrors(originalText, ocrText);
    
    // Step 4: Use LLM to generate detailed feedback
    final prompt = '''
请评估这个听写练习的结果：

原文：$originalText

学生答案（OCR识别）：$ocrText

相似度：$score%

错误列表：
${errors.map((e) => '- ${e['type']}: 应为"${e['original']}"，写成"${e['recognized']}"').join('\n')}

请提供鼓励性反馈和改进建议，返回JSON格式：{
  "score": $score,
  "feedback": "鼓励性反馈",
  "corrections": [
    {"original": "word", "written": "wrod", "explanation": "解释"}
  ]
}
''';
    
    final llmResponse = await modelAdapter.generate(prompt);
    try {
      final parsed = jsonDecode(llmResponse);
      return {
        'score': double.parse(score),
        'ocrText': ocrText,
        'errors': errors,
        'feedback': parsed['feedback'] ?? 'Keep practicing!',
        'corrections': parsed['corrections'] ?? [],
        'suggestions': _generateDefaultSuggestions(errors),
      };
    } catch (_) {
      return {
        'score': double.parse(score),
        'ocrText': ocrText,
        'errors': errors,
        'feedback': llmResponse,
        'suggestions': _generateDefaultSuggestions(errors),
      };
    }
  }

  /// Generate default suggestions based on error types
  List<String> _generateDefaultSuggestions(List<Map<String, dynamic>> errors) {
    final suggestions = <String>[];
    final errorTypes = errors.map((e) => e['type'] as String).toList();
    
    if (errorTypes.contains('missing')) {
      suggestions.add('注意完整性：有些字被漏掉了，请逐字逐句比对。');
    }
    if (errorTypes.contains('extra')) {
      suggestions.add('不要添加原文中没有的字词，要仔细辨认。');
    }
    if (errorTypes.contains('substitution')) {
      suggestions.add('这些错别字很常见，建议多练习这些易混淆的字。');
    }
    if (errorTypes.contains('typo')) {
      suggestions.add('笔画有误，可以通过练字帖来纠正笔画笔顺。');
    }
    
    if (suggestions.isEmpty) {
      suggestions.add('很好！继续保持这个水平，挑战更难的内容吧。');
    }
    
    return suggestions;
  }

  /// Generate a new dictation exercise from chapter content
  Future<String> generateDictationText(String subject, String chapter) async {
    final prompt = '''
请根据${subject}${chapter}的知识点，生成一段50-100字的听写文本（适合$spaceId学生水平）。
只返回听写文本，不需要其他说明。''';
    return await modelAdapter.generate(prompt);
  }

  void dispose() {
    ttsService?.dispose();
  }
}

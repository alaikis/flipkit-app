import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;

class ImageProcessingService {
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  /// Recognize text from image file using Google ML Kit
  Future<String> recognizeText(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      
      final extractedText = recognizedText.blocks
          .map((block) => block.lines.map((line) => line.text).join(' '))
          .join('\n');
      
      await inputImage.close();
      return extractedText;
    } catch (e) {
      throw Exception('OCR error: $e');
    }
  }

  /// Recognize text from image file path
  Future<String> recognizeTextFromPath(String imagePath) async {
    return recognizeText(File(imagePath));
  }

  /// Calculate similarity between two texts (Levenshtein distance)
  double calculateSimilarity(String text1, String text2) {
    // Normalize: remove spaces, convert to lowercase
    final s1 = text1.replaceAll(RegExp(r'\s+'), '').toLowerCase();
    final s2 = text2.replaceAll(RegExp(r'\s+'), '').toLowerCase();
    
    final distance = _levenshteinDistance(s1, s2);
    final maxLength = [s1.length, s2.length].reduce((a, b) => a > b ? a : b);
    
    if (maxLength == 0) return 1.0;
    return 1.0 - (distance / maxLength);
  }

  /// Levenshtein distance algorithm for string similarity
  int _levenshteinDistance(String s1, String s2) {
    final len1 = s1.length;
    final len2 = s2.length;
    
    final d = List<List<int>>.generate(
      len1 + 1,
      (i) => List<int>.filled(len2 + 1, 0),
    );
    
    for (var i = 0; i <= len1; i++) d[i][0] = i;
    for (var j = 0; j <= len2; j++) d[0][j] = j;
    
    for (var i = 1; i <= len1; i++) {
      for (var j = 1; j <= len2; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        d[i][j] = [
          d[i - 1][j] + 1,      // deletion
          d[i][j - 1] + 1,      // insertion
          d[i - 1][j - 1] + cost // substitution
        ].reduce((a, b) => a < b ? a : b);
      }
    }
    
    return d[len1][len2];
  }

  /// Find word-level errors between original and OCR text
  List<Map<String, dynamic>> findErrors(String originalText, String ocrText) {
    final origWords = originalText.split(RegExp(r'\s+'));
    final ocrWords = ocrText.split(RegExp(r'\s+'));
    final errors = <Map<String, dynamic>>[];
    
    final maxLen = [origWords.length, ocrWords.length].reduce((a, b) => a > b ? a : b);
    
    for (var i = 0; i < maxLen; i++) {
      final orig = i < origWords.length ? origWords[i] : '';
      final ocr = i < ocrWords.length ? ocrWords[i] : '';
      
      if (orig != ocr) {
        errors.add({
          'position': i,
          'original': orig,
          'recognized': ocr,
          'type': _getErrorType(orig, ocr),
        });
      }
    }
    
    return errors;
  }

  String _getErrorType(String original, String recognized) {
    if (recognized.isEmpty) return 'missing';
    if (original.isEmpty) return 'extra';
    if (original.length != recognized.length) return 'substitution';
    
    var diffCount = 0;
    for (var i = 0; i < original.length; i++) {
      if (original[i] != recognized[i]) diffCount++;
    }
    
    if (diffCount == 1) return 'typo';
    return 'error';
  }

  /// Compress/resize image to reduce file size
  Future<File> compressImage(File imageFile, {int maxWidth = 1024, int maxHeight = 1024}) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      
      if (image == null) throw Exception('Failed to decode image');
      
      final resized = img.copyResize(
        image,
        width: [image.width, maxWidth].reduce((a, b) => a < b ? a : b),
        height: [image.height, maxHeight].reduce((a, b) => a < b ? a : b),
      );
      
      final compressedFile = File('${imageFile.path}_compressed.jpg');
      await compressedFile.writeAsBytes(img.encodeJpg(resized, quality: 85));
      return compressedFile;
    } catch (e) {
      throw Exception('Image compression error: $e');
    }
  }

  /// Cleanup OCR recognizer
  Future<void> dispose() async {
    await _textRecognizer.close();
  }
}

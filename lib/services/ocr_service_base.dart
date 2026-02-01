/// OCR 服务接口
abstract class OCRServiceBase {
  /// 识别图片中的文字
  Future<String> recognizeText(String imagePath);
  
  /// 识别图片中的文字（带区域）
  Future<List<Map<String, dynamic>>> recognizeTextWithRegions(String imagePath);
  
  /// 初始化 OCR 引擎
  Future<void> initialize();
  
  /// 释放资源
  void dispose();
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'app/app.dart';
import 'core/utils/logger.dart';
import 'services/ai_service.dart';
import 'services/ocr_service.dart';
import 'services/tts_service.dart';
import 'services/github_service.dart';
import 'services/resource_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Logger.info('==================== App Starting ====================', tag: 'Main');

  try {
    // 设置状态栏样式
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    Logger.info('System UI overlay set', tag: 'Main');

    // 设置首选方向
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    Logger.info('Preferred orientation set', tag: 'Main');
  } catch (e) {
    // 忽略系统设置错误，不影响应用启动
    Logger.warning('System setup error: $e', tag: 'Main');
  }

  // 初始化服务（每个服务独立捕获异常）
  Logger.info('Initializing services...', tag: 'Main');

  int successCount = 0;
  int failureCount = 0;

  try {
    await AIService().init();
    successCount++;
  } catch (e) {
    failureCount++;
    Logger.error('Failed to initialize AI Service', error: e, tag: 'Main');
  }

  try {
    await OCRService().init();
    successCount++;
  } catch (e) {
    failureCount++;
    Logger.error('Failed to initialize OCR Service', error: e, tag: 'Main');
  }

  try {
    await TTSService().init();
    successCount++;
  } catch (e) {
    failureCount++;
    Logger.error('Failed to initialize TTS Service', error: e, tag: 'Main');
  }

  try {
    await GitHubService().init();
    successCount++;
  } catch (e) {
    failureCount++;
    Logger.error('Failed to initialize GitHub Service', error: e, tag: 'Main');
  }

  try {
    await ResourceService().init();
    successCount++;
  } catch (e) {
    failureCount++;
    Logger.error('Failed to initialize Resource Service', error: e, tag: 'Main');
  }

  Logger.info('Services initialization complete: $successCount success, $failureCount failed', tag: 'Main');
  Logger.info('App starting...', tag: 'Main');

  runApp(const App());
}

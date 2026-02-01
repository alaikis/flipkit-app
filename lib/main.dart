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

  try {
    // 设置状态栏样式
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    // 设置首选方向
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  } catch (e) {
    // 忽略系统设置错误，不影响应用启动
    print('System setup error: $e');
  }

  // 初始化服务（每个服务独立捕获异常）
  Logger.info('Initializing services...', tag: 'Main');

  try {
    await AIService().init();
  } catch (e) {
    Logger.error('Failed to initialize AI Service', error: e, tag: 'Main');
  }

  try {
    await OCRService().init();
  } catch (e) {
    Logger.error('Failed to initialize OCR Service', error: e, tag: 'Main');
  }

  try {
    await TTSService().init();
  } catch (e) {
    Logger.error('Failed to initialize TTS Service', error: e, tag: 'Main');
  }

  try {
    await GitHubService().init();
  } catch (e) {
    Logger.error('Failed to initialize GitHub Service', error: e, tag: 'Main');
  }

  try {
    await ResourceService().init();
  } catch (e) {
    Logger.error('Failed to initialize Resource Service', error: e, tag: 'Main');
  }

  Logger.info('App starting', tag: 'Main');

  runApp(const App());
}

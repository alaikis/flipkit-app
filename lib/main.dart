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

  try {
    // 初始化服务
    Logger.info('Initializing services...', tag: 'Main');

    await AIService().init();
    await OCRService().init();
    await TTSService().init();
    await GitHubService().init();
    await ResourceService().init();

    Logger.info('All services initialized successfully', tag: 'Main');
  } catch (e, stackTrace) {
    Logger.error('Failed to initialize services',
        error: e, stackTrace: stackTrace, tag: 'Main');
  }

  runApp(const App());
}

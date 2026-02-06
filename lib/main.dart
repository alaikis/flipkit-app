import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  } catch (e) {
    Logger.warning('System setup error: $e', tag: 'Main');
  }

  // 先启动 UI，再在后台初始化服务，避免启动阶段崩溃导致“闪一下退出”
  runApp(const App());

  Future.microtask(() async {
    Logger.info('Initializing services in background...', tag: 'Main');
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
    Logger.info('Services init done: $successCount ok, $failureCount failed', tag: 'Main');
  });
}

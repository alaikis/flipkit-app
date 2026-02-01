import 'package:flutter_tts/flutter_tts.dart';
import '../core/utils/logger.dart';

/// TTS 服务 - 文本转语音
class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;

  TTSService._internal();

  FlutterTts? _flutterTts;
  bool _isSpeaking = false;
  bool _isInitialized = false;

  /// 初始化
  Future<void> init() async {
    if (_isInitialized) return;

    _flutterTts = FlutterTts();

    // 设置语言
    await _flutterTts!.setLanguage('zh-CN');
    await _flutterTts!.setSharedInstance(true);

    // 设置音调
    await _flutterTts!.setPitch(1.0);

    // 设置语速
    await _flutterTts!.setSpeechRate(0.5);

    // 设置音量
    await _flutterTts!.setVolume(1.0);

    // 监听状态
    _flutterTts!.setStartHandler(() {
      _isSpeaking = true;
      Logger.info('TTS started speaking', tag: 'TTSService');
    });

    _flutterTts!.setCompletionHandler(() {
      _isSpeaking = false;
      Logger.info('TTS completed', tag: 'TTSService');
    });

    _flutterTts!.setErrorHandler((msg) {
      _isSpeaking = false;
      Logger.error('TTS error: $msg', tag: 'TTSService');
    });

    _isInitialized = true;
    Logger.info('TTS Service initialized', tag: 'TTSService');
  }

  /// 播放文本
  Future<void> speak(String text) async {
    try {
      if (!_isInitialized) {
        await init();
      }

      if (_isSpeaking) {
        await stop();
      }

      Logger.info('Speaking text: ${text.substring(0, 50)}...', tag: 'TTSService');

      await _flutterTts!.speak(text);
    } catch (e, stackTrace) {
      Logger.error('Failed to speak text',
          error: e, stackTrace: stackTrace, tag: 'TTSService');
      rethrow;
    }
  }

  /// 停止播放
  Future<void> stop() async {
    try {
      await _flutterTts!.stop();
      _isSpeaking = false;
      Logger.info('TTS stopped', tag: 'TTSService');
    } catch (e, stackTrace) {
      Logger.error('Failed to stop TTS',
          error: e, stackTrace: stackTrace, tag: 'TTSService');
    }
  }

  /// 暂停播放
  Future<void> pause() async {
    try {
      await _flutterTts!.pause();
      Logger.info('TTS paused', tag: 'TTSService');
    } catch (e, stackTrace) {
      Logger.error('Failed to pause TTS',
          error: e, stackTrace: stackTrace, tag: 'TTSService');
    }
  }

  /// 恢复播放
  Future<void> resume() async {
    try {
      await _flutterTts!.speak(''); // 触发恢复
      Logger.info('TTS resumed', tag: 'TTSService');
    } catch (e, stackTrace) {
      Logger.error('Failed to resume TTS',
          error: e, stackTrace: stackTrace, tag: 'TTSService');
    }
  }

  /// 是否正在播放
  bool get isSpeaking => _isSpeaking;

  /// 设置语言
  Future<void> setLanguage(String language) async {
    try {
      await _flutterTts!.setLanguage(language);
      Logger.info('TTS language set to: $language', tag: 'TTSService');
    } catch (e, stackTrace) {
      Logger.error('Failed to set TTS language',
          error: e, stackTrace: stackTrace, tag: 'TTSService');
    }
  }

  /// 设置语速
  Future<void> setSpeechRate(double rate) async {
    try {
      await _flutterTts!.setSpeechRate(rate);
      Logger.info('TTS speech rate set to: $rate', tag: 'TTSService');
    } catch (e, stackTrace) {
      Logger.error('Failed to set TTS speech rate',
          error: e, stackTrace: stackTrace, tag: 'TTSService');
    }
  }

  /// 设置音调
  Future<void> setPitch(double pitch) async {
    try {
      await _flutterTts!.setPitch(pitch);
      Logger.info('TTS pitch set to: $pitch', tag: 'TTSService');
    } catch (e, stackTrace) {
      Logger.error('Failed to set TTS pitch',
          error: e, stackTrace: stackTrace, tag: 'TTSService');
    }
  }

  /// 设置音量
  Future<void> setVolume(double volume) async {
    try {
      await _flutterTts!.setVolume(volume);
      Logger.info('TTS volume set to: $volume', tag: 'TTSService');
    } catch (e, stackTrace) {
      Logger.error('Failed to set TTS volume',
          error: e, stackTrace: stackTrace, tag: 'TTSService');
    }
  }

  /// 获取可用语言
  Future<List<String>> getLanguages() async {
    try {
      final languages = await _flutterTts!.getLanguages;
      Logger.info('Available TTS languages: ${languages.length}', tag: 'TTSService');
      return languages.cast<String>();
    } catch (e, stackTrace) {
      Logger.error('Failed to get TTS languages',
          error: e, stackTrace: stackTrace, tag: 'TTSService');
      return [];
    }
  }

  /// 释放资源
  Future<void> dispose() async {
    await _flutterTts!.stop();
    _flutterTts = null;
    _isInitialized = false;
    Logger.info('TTS Service disposed', tag: 'TTSService');
  }
}

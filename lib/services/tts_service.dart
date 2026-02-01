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
    if (_isInitialized || _flutterTts != null) {
      Logger.info('TTS already initialized', tag: 'TTSService');
      return;
    }

    try {
      _flutterTts = FlutterTts();
      Logger.info('Creating FlutterTts instance', tag: 'TTSService');

      // 设置语言（带超时保护）
      try {
        await _flutterTts!.setLanguage('zh-CN').timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            Logger.warning('TTS setLanguage timeout', tag: 'TTSService');
          },
        );
      } catch (e) {
        Logger.warning('TTS setLanguage failed: $e', tag: 'TTSService');
      }

      // 设置音调
      try {
        await _flutterTts!.setPitch(1.0);
      } catch (e) {
        Logger.warning('TTS setPitch failed: $e', tag: 'TTSService');
      }

      // 设置语速
      try {
        await _flutterTts!.setSpeechRate(0.5);
      } catch (e) {
        Logger.warning('TTS setSpeechRate failed: $e', tag: 'TTSService');
      }

      // 设置音量
      try {
        await _flutterTts!.setVolume(1.0);
      } catch (e) {
        Logger.warning('TTS setVolume failed: $e', tag: 'TTSService');
      }

      // 监听状态（带错误保护）
      try {
        _flutterTts!.setStartHandler(() {
          _isSpeaking = true;
          Logger.info('TTS started speaking', tag: 'TTSService');
        });
      } catch (e) {
        Logger.warning('TTS setStartHandler failed: $e', tag: 'TTSService');
      }

      try {
        _flutterTts!.setCompletionHandler(() {
          _isSpeaking = false;
          Logger.info('TTS completed', tag: 'TTSService');
        });
      } catch (e) {
        Logger.warning('TTS setCompletionHandler failed: $e', tag: 'TTSService');
      }

      try {
        _flutterTts!.setErrorHandler((msg) {
          _isSpeaking = false;
          Logger.error('TTS error: $msg', tag: 'TTSService');
        });
      } catch (e) {
        Logger.warning('TTS setErrorHandler failed: $e', tag: 'TTSService');
      }

      _isInitialized = true;
      Logger.info('TTS Service initialized successfully', tag: 'TTSService');
    } catch (e) {
      Logger.error('Failed to initialize TTS', error: e, tag: 'TTSService');
      _flutterTts = null;
      _isInitialized = false;
      // 不抛出异常，允许应用继续运行
    }
  }

  /// 播放文本
  Future<void> speak(String text) async {
    try {
      if (!_isInitialized || _flutterTts == null) {
        await init();
      }

      if (_isSpeaking) {
        await stop();
      }

      final previewText = text.length > 50 ? '${text.substring(0, 50)}...' : text;
      Logger.info('Speaking text: $previewText', tag: 'TTSService');

      if (_flutterTts != null) {
        await _flutterTts!.speak(text);
      }
    } catch (e, stackTrace) {
      Logger.error('Failed to speak text',
          error: e, stackTrace: stackTrace, tag: 'TTSService');
      rethrow;
    }
  }

  /// 停止播放
  Future<void> stop() async {
    try {
      if (_flutterTts == null) {
        await init();
      }
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
      if (_flutterTts == null) {
        await init();
      }
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
      if (_flutterTts == null) {
        await init();
      }
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
      if (_flutterTts == null) {
        await init();
      }
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
      if (_flutterTts == null) {
        await init();
      }
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
      if (_flutterTts == null) {
        await init();
      }
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
      if (_flutterTts == null) {
        await init();
      }
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
      if (_flutterTts == null) {
        await init();
      }
      final languages = await _flutterTts!.getLanguages;
      Logger.info('Available TTS languages: ${languages.length}', tag: 'TTSService');
      return languages;
    } catch (e, stackTrace) {
      Logger.error('Failed to get TTS languages',
          error: e, stackTrace: stackTrace, tag: 'TTSService');
      return [];
    }
  }

  /// 释放资源
  Future<void> dispose() async {
    try {
      if (_flutterTts != null) {
        await _flutterTts!.stop();
        _flutterTts = null;
      }
    } catch (e) {
      Logger.error('Failed to dispose TTS', error: e, tag: 'TTSService');
    }
    _isInitialized = false;
    Logger.info('TTS Service disposed', tag: 'TTSService');
  }
}

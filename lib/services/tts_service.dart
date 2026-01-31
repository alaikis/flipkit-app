import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  late FlutterTts _flutterTts;
  bool _isInitialized = false;
  bool _isSpeaking = false;

  TTSService() {
    _flutterTts = FlutterTts();
  }

  /// 初始化 TTS 服务
  Future<void> init({
    String language = 'zh-CN',
    double pitch = 1.0,
    double rate = 0.5,
    double volume = 1.0,
  }) async {
    try {
      // 设置语言
      await _flutterTts.setLanguage(language);
      
      // 设置音高（1.0 = 正常）
      await _flutterTts.setPitch(pitch);
      
      // 设置播放速度（0.0-2.0，0.5 = 较慢）
      await _flutterTts.setSpeechRate(rate);
      
      // 设置音量（0.0-1.0）
      await _flutterTts.setVolume(volume);

      // 监听播放状态
      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
      });

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
      });

      _flutterTts.setErrorHandler((message) {
        _isSpeaking = false;
      });

      _isInitialized = true;
    } catch (e) {
      print('TTS 初始化失败: $e');
    }
  }

  /// 播放文本
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      await init();
    }

    try {
      if (!_isSpeaking) {
        await _flutterTts.speak(text);
      }
    } catch (e) {
      print('TTS 播放失败: $e');
    }
  }

  /// 停止播放
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      _isSpeaking = false;
    } catch (e) {
      print('TTS 停止失败: $e');
    }
  }

  /// 暂停播放
  Future<void> pause() async {
    try {
      await _flutterTts.pause();
    } catch (e) {
      print('TTS 暂停失败: $e');
    }
  }

  /// 获取是否正在播放
  bool get isSpeaking => _isSpeaking;

  /// 清理资源
  Future<void> dispose() async {
    try {
      await _flutterTts.stop();
      _isSpeaking = false;
    } catch (e) {
      print('TTS 释放失败: $e');
    }
  }
}

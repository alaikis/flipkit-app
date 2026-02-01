import 'package:flutter/foundation.dart';

/// 日志工具类
class Logger {
  /// 调试日志
  static void debug(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      print('[DEBUG] $prefix$message');
    }
  }

  /// 信息日志
  static void info(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      print('[INFO] $prefix$message');
    }
  }

  /// 警告日志
  static void warning(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      print('[WARNING] $prefix$message');
    }
  }

  /// 错误日志
  static void error(String message, {Object? error, StackTrace? stackTrace, String? tag}) {
    final prefix = tag != null ? '[$tag] ' : '';
    print('[ERROR] $prefix$message');
    if (error != null) {
      print('[ERROR] Exception: $error');
    }
    if (stackTrace != null) {
      print('[ERROR] StackTrace: $stackTrace');
    }
  }

  /// 网络请求日志
  static void network(String method, String url, {dynamic data, String? tag}) {
    final prefix = tag != null ? '[$tag] ' : '';
    print('[NETWORK] $prefix$method $url');
    if (data != null) {
      print('[NETWORK] $prefixData: $data');
    }
  }

  /// 网络响应日志
  static void response(String url, {int? statusCode, dynamic data, String? tag}) {
    final prefix = tag != null ? '[$tag] ' : '';
    print('[RESPONSE] $prefix$url Status: $statusCode');
    if (data != null) {
      print('[RESPONSE] $prefixData: $data');
    }
  }
}

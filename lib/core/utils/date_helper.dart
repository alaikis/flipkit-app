import 'package:intl/intl.dart';

/// 日期时间辅助类
class DateHelper {
  /// 格式化日期时间
  static String formatDateTime(DateTime dateTime, {String pattern = 'yyyy-MM-dd HH:mm:ss'}) {
    return DateFormat(pattern).format(dateTime);
  }

  /// 格式化日期
  static String formatDate(DateTime dateTime, {String pattern = 'yyyy-MM-dd'}) {
    return DateFormat(pattern).format(dateTime);
  }

  /// 格式化时间
  static String formatTime(DateTime dateTime, {String pattern = 'HH:mm:ss'}) {
    return DateFormat(pattern).format(dateTime);
  }

  /// 获取友好时间显示
  static String getFriendlyTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return '刚刚';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return formatDate(dateTime);
    }
  }

  /// 获取今天的日期
  static String getTodayDate() {
    return formatDate(DateTime.now());
  }

  /// 获取昨天的日期
  static String getYesterdayDate() {
    return formatDate(DateTime.now().subtract(const Duration(days: 1)));
  }

  /// 获取本周的日期范围
  static List<String> getWeekRange() {
    final now = DateTime.now();
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final lastDayOfWeek = firstDayOfWeek.add(const Duration(days: 6));

    return [
      formatDate(firstDayOfWeek),
      formatDate(lastDayOfWeek),
    ];
  }

  /// 获取本月的日期范围
  static List<String> getMonthRange() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    return [
      formatDate(firstDayOfMonth),
      formatDate(lastDayOfMonth),
    ];
  }

  /// 判断是否是今天
  static bool isToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  /// 判断是否是昨天
  static bool isYesterday(DateTime dateTime) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return dateTime.year == yesterday.year &&
        dateTime.month == yesterday.month &&
        dateTime.day == yesterday.day;
  }

  /// 计算两个日期之间的天数
  static int daysBetween(DateTime from, DateTime to) {
    return to.difference(from).inDays;
  }

  /// 获取星期几
  static String getWeekday(DateTime dateTime) {
    const weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    return '星期${weekdays[dateTime.weekday - 1]}';
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// 儿童乐园风格的主题配置和过渡动画
class ChildTheme {
  // 儿童乐园配色
  static const Color skyBlue = Color(0xFF87CEEB);
  static const Color grassGreen = Color(0xFF90EE90);
  static const Color sunshineYellow = Color(0xFFFFD700);
  static const Color cottonPink = Color(0xFFFFB6C1);
  static const Color bubblePurple = Color(0xFFDDA0DD);

  // 柔和渐变背景
  static const LinearGradient rainbowGradient = LinearGradient(
    colors: [
      Color(0xFFFF9AA2),  // 珊瑚粉
      Color(0xFFFFB6C1),  // 棉花粉
      Color(0xFFFFD700),  // 阳光黄
      Color(0xFF90EE90),  // 草地绿
      Color(0xFF87CEEB),  // 天空蓝
      Color(0xFFDDA0DD),  // 气泡紫
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
  );

  // 云朵装饰
  static Widget cloudDecoration({required Widget child}) {
    return Stack(
      children: [
        // 左上角云朵
        Positioned(
          top: 20,
          left: -20,
          child: _buildCloud(Colors.white.withOpacity(0.3), 1.0),
        ),
        // 右上角云朵
        Positioned(
          top: 40,
          right: -30,
          child: _buildCloud(Colors.white.withOpacity(0.25), 0.8),
        ),
        // 底部云朵
        Positioned(
          bottom: -50,
          left: 50,
          child: _buildCloud(Colors.white.withOpacity(0.2), 1.2),
        ),
        child,
      ],
    );
  }

  static Widget _buildCloud(Color color, double scale) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: 100,
        height: 50,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(50),
        ),
      ),
    );
  }
}

/// 儿童乐园风格的过渡动画
class ChildThemeTransitions {
  /// 弹跳过渡动画（像弹簧一样）
  static Widget bounce({
    required Widget child,
    required bool animate,
    Duration duration = const Duration(milliseconds: 600),
    Duration delay = Duration.zero,
  }) {
    if (!animate) return child;
    return child
        .animate()
        .scale(
          begin: const Offset(0.0, 0.0),
          end: const Offset(1.0, 1.0),
          duration: duration,
          delay: delay,
          curve: Curves.elasticOut,
        )
        .fadeIn(
          duration: duration ~/ 2,
          delay: delay,
        );
  }

  /// 从下方滑入（像从滑梯滑下）
  static Widget slideUp({
    required Widget child,
    required bool animate,
    Duration duration = const Duration(milliseconds: 500),
    Duration delay = Duration.zero,
  }) {
    if (!animate) return child;
    return child
        .animate()
        .slideY(
          begin: 100.0,
          end: 0.0,
          duration: duration,
          delay: delay,
          curve: Curves.easeOutBack,
        )
        .fadeIn(
          duration: duration ~/ 3,
          delay: delay,
        );
  }

  /// 左右摇摆（像不倒翁）
  static Widget wobble({
    required Widget child,
    required bool animate,
    Duration duration = const Duration(milliseconds: 800),
    Duration delay = Duration.zero,
  }) {
    if (!animate) return child;
    return child
        .animate(
          onPlay: (controller) => controller.repeat(),
        )
        .shimmer(
          duration: duration,
          delay: delay,
          color: Colors.yellow.withOpacity(0.3),
        );
  }

  /// 旋转出现（像玩具旋转）
  static Widget rotate({
    required Widget child,
    required bool animate,
    Duration duration = const Duration(milliseconds: 700),
    Duration delay = Duration.zero,
  }) {
    if (!animate) return child;
    return child
        .animate()
        .rotate(
          begin: -0.5,
          end: 0.0,
          duration: duration,
          delay: delay,
          curve: Curves.elasticOut,
        )
        .fadeIn(
          duration: duration ~/ 2,
          delay: delay,
        );
  }

  /// 缩放淡入（像魔法棒效果）
  static Widget scaleFade({
    required Widget child,
    required bool animate,
    Duration duration = const Duration(milliseconds: 600),
    Duration delay = Duration.zero,
  }) {
    if (!animate) return child;
    return child
        .animate()
        .scale(
          begin: const Offset(0.5, 0.5),
          end: const Offset(1.0, 1.0),
          duration: duration,
          delay: delay,
          curve: Curves.easeOutBack,
        )
        .fadeIn(
          duration: duration ~/ 2,
          delay: delay,
        );
  }

  /// 左右滑入（像从门口进来）
  static Widget slideRight({
    required Widget child,
    required bool animate,
    Duration duration = const Duration(milliseconds: 500),
    Duration delay = Duration.zero,
  }) {
    if (!animate) return child;
    return child
        .animate()
        .slideX(
          begin: -50.0,
          end: 0.0,
          duration: duration,
          delay: delay,
          curve: Curves.easeOutCubic,
        )
        .fadeIn(
          duration: duration ~/ 3,
          delay: delay,
        );
  }

  /// 组合动画：弹跳 + 缩放
  static Widget bounceScale({
    required Widget child,
    required bool animate,
    Duration duration = const Duration(milliseconds: 800),
    Duration delay = Duration.zero,
  }) {
    if (!animate) return child;
    return child
        .animate()
        .scale(
          begin: const Offset(0.0, 0.0),
          end: const Offset(1.0, 1.0),
          duration: duration,
          delay: delay,
          curve: Curves.bounceOut,
        )
        .fadeIn(
          duration: duration ~/ 2,
          delay: delay,
        );
  }

  /// 闪光效果（像星星闪烁）
  static Widget sparkle({
    required Widget child,
    required bool animate,
    Duration duration = const Duration(milliseconds: 400),
    Duration delay = Duration.zero,
  }) {
    if (!animate) return child;
    return child
        .animate(
          onPlay: (controller) => controller.repeat(reverse: true),
        )
        .then()
        .shimmer(
          duration: duration,
          delay: delay,
          color: Colors.yellow,
        );
  }
}

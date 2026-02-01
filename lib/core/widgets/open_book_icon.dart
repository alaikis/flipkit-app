import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// 展开的书本图标
class OpenBookIcon extends StatelessWidget {
  const OpenBookIcon({
    super.key,
    this.size = 80,
    this.frontColor,
    this.backColor,
    this.animate = true,
  });

  final double size;
  final Color? frontColor;
  final Color? backColor;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final defaultFrontColor = frontColor ?? Theme.of(context).colorScheme.primary;
    final defaultBackColor = backColor ?? Theme.of(context).colorScheme.primary.withOpacity(0.6);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        size: Size(size, size),
        painter: _OpenBookPainter(
          frontColor: defaultFrontColor,
          backColor: defaultBackColor,
        ),
      ).animate(
        onPlay: (controller) {
          if (animate) {
            controller.repeat();
          }
        },
      ).then()
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
        )
        .shimmer(
          duration: const Duration(milliseconds: 800),
          color: Colors.yellow.withOpacity(0.3),
        ),
    );
  }
}

class _OpenBookPainter extends CustomPainter {
  _OpenBookPainter({
    required this.frontColor,
    required this.backColor,
  });

  final Color frontColor;
  final Color backColor;

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final bookWidth = size.width * 0.7;
    final bookHeight = size.height * 0.6;

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // 后页（左边）
    final backPagePath = Path()
      ..moveTo(centerX - bookWidth / 2, centerY - bookHeight / 2)
      ..lineTo(centerX - bookWidth / 2, centerY + bookHeight / 2)
      ..lineTo(centerX - 2, centerY + bookHeight / 2)
      ..cubicTo(
        centerX - 10, centerY + bookHeight / 2,
        centerX - bookWidth / 2, centerY + bookHeight / 3,
        centerX - bookWidth / 2, centerY + bookHeight / 2,
      )
      ..lineTo(centerX - bookWidth / 2, centerY - bookHeight / 2)
      ..close();

    paint.color = backColor;
    canvas.drawPath(backPagePath, paint);

    // 前页（右边，展开状态）
    final frontPagePath = Path()
      ..moveTo(centerX, centerY - bookHeight / 2)
      ..lineTo(centerX + bookWidth / 2, centerY - bookHeight / 2)
      ..lineTo(centerX + bookWidth / 2, centerY + bookHeight / 3)
      ..cubicTo(
        centerX + 10, centerY + bookHeight / 3,
        centerX + bookWidth / 2, centerY + bookHeight / 2,
        centerX, centerY + bookHeight / 2,
      )
      ..lineTo(centerX, centerY - bookHeight / 2)
      ..close();

    paint.color = frontColor;
    canvas.drawPath(frontPagePath, paint);

    // 中间书脊阴影
    final spinePaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(centerX, centerY - bookHeight / 2),
      Offset(centerX, centerY + bookHeight / 2),
      spinePaint,
    );

    // 页面文字线条（表示内容）
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final lineSpacing = bookHeight / 6;
    for (int i = 1; i < 5; i++) {
      final y = centerY - bookHeight / 2 + i * lineSpacing;
      // 前页线条
      canvas.drawLine(
        Offset(centerX + 5, y),
        Offset(centerX + bookWidth / 2 - 5, y),
        linePaint,
      );
      // 后页线条
      canvas.drawLine(
        Offset(centerX - bookWidth / 2 + 5, y),
        Offset(centerX - 5, y),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(_OpenBookPainter oldDelegate) {
    return oldDelegate.frontColor != frontColor ||
        oldDelegate.backColor != backColor;
  }
}

import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../core/utils/storage_helper.dart';
import '../../core/widgets/open_book_icon.dart';
import '../../core/theme/child_theme_transitions.dart';

/// 启动页
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstLaunch();
    });
  }

  Future<void> _checkFirstLaunch() async {
    try {
      // 等待一段时间，确保UI完全渲染
      await Future.delayed(const Duration(milliseconds: 1500));

      // 检查是否首次启动
      final isFirstLaunch = await StorageHelper().isFirstLaunch();

      // 跳转到相应页面
      if (isFirstLaunch) {
        AppRoutes.toOnboarding();
      } else {
        AppRoutes.toHome();
      }
    } catch (e, stackTrace) {
      // 发生错误时，直接跳转到主页
      print('Splash error: $e\n$stackTrace');
      AppRoutes.toHome();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFF9AA2),  // 珊瑚粉
              Color(0xFFFFD700),  // 阳光黄
              Color(0xFF90EE90),  // 草地绿
            ],
          ),
        ),
        child: ChildTheme.cloudDecoration(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 展开的书本图标
                ChildThemeTransitions.bounceScale(
                  animate: true,
                  child: const OpenBookIcon(
                    size: 100,
                    frontColor: Color(0xFFFFD700),
                    backColor: Color(0xFFFF9AA2),
                  ),
                ),

                const SizedBox(height: 32),

                // 应用名称
                ChildThemeTransitions.slideUp(
                  animate: true,
                  delay: const Duration(milliseconds: 300),
                  child: const Text(
                    '趣学',
                    style: TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 3,
                      shadows: [
                        Shadow(
                          color: Colors.black45,
                          offset: Offset(2, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // 副标题
                ChildThemeTransitions.slideUp(
                  animate: true,
                  delay: const Duration(milliseconds: 500),
                  child: const Text(
                    '智能学习，快乐成长',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                      shadows: [
                        Shadow(
                          color: Colors.black45,
                          offset: Offset(1, 1),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // 加载指示器 - 使用儿童乐园风格
                ChildThemeTransitions.rotate(
                  animate: true,
                  delay: const Duration(milliseconds: 700),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const SizedBox(
                      width: 40,
                      height: 40,
                      child: Center(
                        child: SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(
                            strokeWidth: 4,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              ChildTheme.sunshineYellow,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ChildThemeTransitions.fadeIn(
            animate: true,
            delay: const Duration(milliseconds: 800),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '福州阿莱克斯信息技术有限公司',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => AppRoutes.toPrivacyPolicy(),
                      child: Text(
                        '隐私政策',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    Text(
                      ' · ',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                    TextButton(
                      onPressed: () => AppRoutes.toTermsOfService(),
                      child: Text(
                        '使用条款',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

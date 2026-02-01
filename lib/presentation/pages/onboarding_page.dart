import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../app/routes.dart';
import '../../core/utils/storage_helper.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/child_theme_transitions.dart';

/// 引导页
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'icon': Icons.auto_awesome,
      'title': 'AI 智能组题',
      'description': '使用大模型自动生成个性化题目',
      'color': ChildTheme.skyBlue,
      'bgColor': Color(0xFF87CEEB).withOpacity(0.15),
    },
    {
      'icon': Icons.camera_alt,
      'title': 'OCR 智能识别',
      'description': '拍照识别手写内容，智能评分反馈',
      'color': ChildTheme.sunshineYellow,
      'bgColor': Color(0xFFFFD700).withOpacity(0.15),
    },
    {
      'icon': Icons.folder_special,
      'title': '资源进化系统',
      'description': 'GitHub 资源搜索下载，扩展学习资料',
      'color': ChildTheme.grassGreen,
      'bgColor': Color(0xFF90EE90).withOpacity(0.15),
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _skip() async {
    await StorageHelper().setFirstLaunch(false);
    AppRoutes.toHome();
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _skip();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: ChildTheme.rainbowGradient,
          ),
          child: Column(
            children: [
              // 顶部跳过按钮
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Align(
                  alignment: Alignment.topRight,
                  child: ChildThemeTransitions.sparkle(
                    animate: true,
                    child: TextButton(
                      onPressed: _skip,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('跳过'),
                    ),
                  ),
                ),
              ),

              // 页面内容
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 图标
                        ChildThemeTransitions.bounce(
                          animate: _currentPage == index,
                          delay: Duration(milliseconds: 100 * index),
                          child: Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              color: page['bgColor'],
                              borderRadius: BorderRadius.circular(110),
                              border: Border.all(
                                color: page['color'].withOpacity(0.3),
                                width: 3,
                              ),
                            ),
                            child: Icon(
                              page['icon'],
                              size: 100,
                              color: page['color'],
                            ),
                          ),
                        ),

                        const SizedBox(height: 48),

                        // 标题
                        ChildThemeTransitions.slideUp(
                          animate: _currentPage == index,
                          delay: Duration(milliseconds: 200 + index * 100),
                          child: Text(
                            page['title'],
                            style: Get.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              fontSize: 36,
                              shadows: [
                                Shadow(
                                  color: Colors.black45,
                                  offset: Offset(2, 2),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // 描述
                        ChildThemeTransitions.slideUp(
                          animate: _currentPage == index,
                          delay: Duration(milliseconds: 400 + index * 100),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Text(
                              page['description'],
                              style: Get.textTheme.bodyLarge?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                shadows: [
                                  Shadow(
                                    color: Colors.black45,
                                    offset: Offset(1, 1),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // 页面指示器 - 儿童乐园风格（星星）
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: ChildThemeTransitions.sparkle(
                        animate: _currentPage == index,
                        child: Icon(
                          _currentPage == index ? Icons.star : Icons.star_border,
                          size: _currentPage == index ? 32 : 24,
                          color: _currentPage == index
                              ? ChildTheme.sunshineYellow
                              : Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 底部按钮
              Padding(
                padding: const EdgeInsets.all(20),
                child: ChildThemeTransitions.bounceScale(
                  animate: true,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFF9AA2),
                          Color(0xFFFFD700),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _next,
                        borderRadius: BorderRadius.circular(24),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          child: Text(
                            '下一页',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
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
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:getwidget/getwidget.dart';
import 'package:get/get.dart';
import '../../app/routes.dart';
import '../../core/utils/storage_helper.dart';
import '../../core/constants/app_constants.dart';

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
      'color': Color(0xFF2196F3),
    },
    {
      'icon': Icons.camera_alt,
      'title': 'OCR 智能识别',
      'description': '拍照识别手写内容，智能评分反馈',
      'color': Color(0xFFFF9800),
    },
    {
      'icon': 'assets/images/github_logo.png',
      'title': '资源进化系统',
      'description': 'GitHub 资源搜索下载，扩展学习资料',
      'color': Color(0xFF4CAF50),
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
        duration: const Duration(milliseconds: 300),
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
        child: Column(
          children: [
            // 顶部跳过按钮
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Align(
                alignment: Alignment.topRight,
                child: GFButton(
                  text: '跳过',
                  type: GFButtonType.transparent,
                  textColor: Get.theme.colorScheme.primary,
                  onPressed: _skip,
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
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: page['color'].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Icon(
                          page['icon'],
                          size: 100,
                          color: page['color'],
                        ),
                      ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

                      const SizedBox(height: 40),

                      // 标题
                      Text(
                        page['title'],
                        style: Get.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: page['color'],
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 200.ms),

                      const SizedBox(height: 16),

                      // 描述
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          page['description'],
                          style: Get.textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ).animate().fadeIn(delay: 400.ms),
                    ],
                  );
                },
              ),
            ),

            // 页面指示器
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? Get.theme.colorScheme.primary
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),

            // 底部按钮
            Padding(
              padding: const EdgeInsets.all(20),
              child: GFButton(
                text: _currentPage == _pages.length - 1 ? '开始使用' : '下一页',
                size: GFSize.LARGE,
                type: GFButtonType.solid,
                color: Get.theme.colorScheme.primary,
                blockButton: true,
                onPressed: _next,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

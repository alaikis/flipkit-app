import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:getwidget/getwidget.dart';
import 'package:get/get.dart';
import '../../app/routes.dart';
import '../../core/utils/storage_helper.dart';
import '../../core/constants/app_constants.dart';

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
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    await Future.delayed(const Duration(seconds: 2));

    final isFirstLaunch = await StorageHelper().isFirstLaunch();

    if (isFirstLaunch) {
      AppRoutes.toOnboarding();
    } else {
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
              Color(0xFF2196F3),
              Color(0xFF64B5F6),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.school,
                  size: 80,
                  color: Color(0xFF2196F3),
                ),
              ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

              const SizedBox(height: 24),

              // 应用名称
              const Text(
                'FlipKit',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 600.ms),

              const SizedBox(height: 12),

              // 副标题
              const Text(
                '智能学习，快乐成长',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ).animate().fadeIn(delay: 600.ms, duration: 600.ms),

              const SizedBox(height: 48),

              // 加载指示器
              GFLoader(
                type: GFLoaderType.circle,
              ).animate().fadeIn(delay: 900.ms, duration: 600.ms),
            ],
          ),
        ),
      ),
    );
  }
}

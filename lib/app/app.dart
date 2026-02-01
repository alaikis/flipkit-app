import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/theme/app_theme.dart';
import 'routes.dart';

/// 应用配置
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ThemeData>(
      future: AppTheme.getCurrentTheme(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        return GetMaterialApp(
          title: 'FlipKit',
          debugShowCheckedModeBanner: false,
          theme: snapshot.data!,
          getPages: AppRoutes.routes,
          initialRoute: AppRoutes.splash,
          defaultTransition: Transition.rightToLeft,
          transitionDuration: const Duration(milliseconds: 300),
          locale: const Locale('zh', 'CN'),
          fallbackLocale: const Locale('zh', 'CN'),
        );
      },
    );
  }
}

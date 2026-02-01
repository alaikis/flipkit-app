import 'package:get/get.dart';
import '../presentation/pages/splash_page.dart';
import '../presentation/pages/home_page.dart';
import '../presentation/pages/onboarding_page.dart';
import '../presentation/pages/dictation_page.dart';
import '../presentation/pages/quiz_page.dart';
import '../presentation/pages/essay_page.dart';
import '../presentation/pages/settings_page.dart';
import '../presentation/pages/resource_page.dart';

/// 应用路由
class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String dictation = '/dictation';
  static const String quiz = '/quiz';
  static const String essay = '/essay';
  static const String settings = '/settings';
  static const String resources = '/resources';

  /// 路由配置
  static final routes = [
    GetPage(
      name: splash,
      page: () => const SplashPage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: onboarding,
      page: () => const OnboardingPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: home,
      page: () => const HomePage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: dictation,
      page: () => const DictationPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: quiz,
      page: () => const QuizPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: essay,
      page: () => const EssayPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: settings,
      page: () => const SettingsPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: resources,
      page: () => const ResourcePage(),
      transition: Transition.rightToLeft,
    ),
  ];

  /// 跳转到启动页
  static void toSplash() => Get.offAllNamed(splash);

  /// 跳转到引导页
  static void toOnboarding() => Get.offAllNamed(onboarding);

  /// 跳转到主页
  static void toHome() => Get.offAllNamed(home);

  /// 跳转到听写页
  static void toDictation() => Get.toNamed(dictation);

  /// 跳转到问答页
  static void toQuiz() => Get.toNamed(quiz);

  /// 跳转到作文页
  static void toEssay() => Get.toNamed(essay);

  /// 跳转到设置页
  static void toSettings() => Get.toNamed(settings);

  /// 跳转到资源页
  static void toResources() => Get.toNamed(resources);

  /// 返回上一页
  static void back() => Get.back();
}

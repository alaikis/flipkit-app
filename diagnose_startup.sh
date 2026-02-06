#!/bin/bash
# 全面诊断应用启动闪退问题

echo "=========================================="
echo "全面诊断启动闪退问题"
echo "=========================================="
echo ""

# 1. 检查依赖配置
echo "1. 检查 pubspec.yaml 依赖..."
if grep -q "google_ml_kit" pubspec.yaml; then
    echo "   [!] 仍存在 google_ml_kit 依赖"
else
    echo "   ✓ google_ml_kit 已移除"
fi

if grep -q "google_fonts" pubspec.yaml; then
    echo "   [!] 仍存在 google_fonts 依赖"
else
    echo "   ✓ google_fonts 已移除"
fi

echo ""
echo "2. 检查 Android 配置..."
if grep -q "minSdkVersion 21" android/app/build.gradle; then
    echo "   ✓ minSdkVersion 设置为 21"
else
    echo "   [!] minSdkVersion 未正确设置"
fi

if grep -q "multiDexEnabled true" android/app/build.gradle; then
    echo "   ✓ MultiDex 已启用"
else
    echo "   [!] MultiDex 未启用"
fi

echo ""
echo "3. 检查服务初始化..."
if grep -q "WidgetsBinding.instance.addPostFrameCallback" lib/presentation/pages/splash_page.dart; then
    echo "   ✓ Splash 页面使用 PostFrameCallback"
else
    echo "   [!] Splash 页面未使用 PostFrameCallback"
fi

if grep -q "_prefsInstance is! Future<SharedPreferences>" lib/core/utils/storage_helper.dart; then
    echo "   ✓ StorageHelper 使用懒加载"
else
    echo "   [!] StorageHelper 可能未使用懒加载"
fi

echo ""
echo "4. 检查异常处理..."
if grep -q "Thread.setDefaultUncaughtExceptionHandler" android/app/src/main/kotlin/com/alaikis/flipkit/MainActivity.kt; then
    echo "   ✓ MainActivity 有全局异常处理"
else
    echo "   [!] MainActivity 缺少全局异常处理"
fi

if grep -q "MultiDex.install" android/app/src/main/kotlin/com/alaikis/flipkit/MainActivity.kt; then
    echo "   ✓ MainActivity 有 MultiDex 安装"
else
    echo "   [!] MainActivity 缺少 MultiDex 安装"
fi

echo ""
echo "5. 检查路由配置..."
if grep -q "initialRoute: AppRoutes.splash" lib/app/app.dart; then
    echo "   ✓ 初始路由设置为 splash"
else
    echo "   [!] 初始路由未正确设置"
fi

echo ""
echo "6. 尝试编译检查..."
echo "   运行 flutter analyze..."

echo ""
echo "=========================================="
echo "诊断完成"
echo "=========================================="

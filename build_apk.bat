@echo off
chcp 65001 >nul
echo ======================================
echo 快学喵 APK 构建脚本 (Windows)
echo ======================================

where flutter >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [错误] 未检测到 Flutter，请先安装 Flutter 并加入 PATH。
    echo 安装指南: https://docs.flutter.dev/get-started/install/windows
    exit /b 1
)

echo 检查 Java 版本（需要 Java 17）...
java -version 2>&1 | findstr /C:"17." >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [警告] 当前可能不是 Java 17。若构建报错，请安装 JDK 17 并设置 JAVA_HOME 或运行:
    echo   flutter config --jdk-dir="C:\Program Files\Amazon Corretto\jdk17.x.x_x"
    echo.
)

echo.
echo 步骤 1: 清理之前的构建...
call flutter clean

echo.
echo 步骤 2: 获取依赖...
call flutter pub get

echo.
echo 步骤 3: 构建 Release APK...
call flutter build apk --release

echo.
echo ======================================
echo 构建完成！
echo ======================================
echo APK 位置: build\app\outputs\flutter-apk\app-release.apk
echo.
if exist "build\app\outputs\flutter-apk\app-release.apk" (
    dir "build\app\outputs\flutter-apk\app-release.apk"
)
pause

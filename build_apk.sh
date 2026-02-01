#!/bin/bash

echo "======================================"
echo "FlipKit APK 构建脚本"
echo "======================================"

# 设置 Flutter 路径
export PATH="$PATH:$HOME/flutter/bin"

# 进入项目目录
cd /home/alex/devspace/flipkit-app

echo ""
echo "步骤 1: 清理之前的构建..."
flutter clean

echo ""
echo "步骤 2: 获取依赖包..."
flutter pub get

echo ""
echo "步骤 3: 运行代码生成（如果需要）..."
# flutter pub run build_runner build --delete-conflicting-outputs

echo ""
echo "步骤 4: 分析代码..."
flutter analyze

echo ""
echo "步骤 5: 构建 Release APK (arm64-v8a)..."
flutter build apk --release --target-platform android-arm64

echo ""
echo "步骤 6: 构建 Release APK (armeabi-v7a)..."
flutter build apk --release --target-platform android-arm

echo ""
echo "步骤 7: 构建 Release APK (x86_64)..."
flutter build apk --release --target-platform android-x64

echo ""
echo "======================================"
echo "构建完成！"
echo "======================================"
echo ""
echo "APK 文件位置:"
echo "  - arm64-v8a: build/app/outputs/flutter-apk/app-release.apk"
echo "  - armeabi-v7a: build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk"
echo "  - x86_64: build/app/outputs/flutter-apk/app-x86_64-release.apk"
echo ""
echo "要生成通用 APK（包含所有架构），请运行:"
echo "  flutter build apk --release"
echo ""

# 列出生成的 APK 文件
if [ -d "build/app/outputs/flutter-apk" ]; then
    echo "生成的 APK 文件:"
    ls -lh build/app/outputs/flutter-apk/*.apk
fi

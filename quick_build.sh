#!/bin/bash

echo "======================================"
echo "FlipKit 快速 APK 构建脚本"
echo "======================================"

# 设置环境变量
export PATH="$PATH:$HOME/flutter/bin"
export ANDROID_HOME=/home/alex/Android/Sdk
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export CHROME_EXECUTABLE=google-chrome

# 进入项目目录
cd /home/alex/devspace/flipkit-app

echo ""
echo "步骤 1: 清理之前的构建..."
flutter clean

echo ""
echo "步骤 2: 获取依赖包..."
flutter pub get

echo ""
echo "步骤 3: 分析代码..."
flutter analyze

echo ""
echo "步骤 4: 构建 Release APK..."
flutter build apk --release

echo ""
echo "======================================"
echo "构建完成！"
echo "======================================"
echo ""
echo "APK 文件位置:"
ls -lh build/app/outputs/flutter-apk/app-release.apk
echo ""

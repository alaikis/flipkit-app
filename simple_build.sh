#!/bin/bash

echo "========================================="
echo "FlipKit APK 快速构建脚本"
echo "========================================="
echo ""

cd /home/alex/devspace/flipkit-app
export PATH="$PATH:$HOME/flutter/bin"

echo "步骤 1: 清理..."
flutter clean

echo ""
echo "步骤 2: 获取依赖..."
flutter pub get

echo ""
echo "步骤 3: 修复 Gradle 配置..."
# 临时使用旧的 apply 方法
cd android
sed -i 's/id "maven"/id "maven"\1' build.gradle

echo ""
echo "步骤 4: 构建 APK..."
flutter build apk --release

echo ""
echo "========================================="
echo "构建完成！"
echo "========================================="
echo ""
echo "APK 文件位置:"
ls -lh build/app/outputs/flutter-apk/*.apk 2>/dev/null || echo "未找到 APK 文件"

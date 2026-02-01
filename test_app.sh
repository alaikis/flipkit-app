#!/bin/bash

echo "======================================"
echo "FlipKit 测试脚本"
echo "======================================"

# 设置 Flutter 路径
export PATH="$PATH:$HOME/flutter/bin"

# 进入项目目录
cd /home/alex/devspace/flipkit-app

echo ""
echo "步骤 1: 检查 Flutter 环境..."
flutter doctor

echo ""
echo "步骤 2: 检查依赖..."
flutter pub deps

echo ""
echo "步骤 3: 运行代码分析..."
flutter analyze

echo ""
echo "步骤 4: 检查 Android 设备..."
flutter devices

echo ""
echo "步骤 5: 运行单元测试..."
flutter test

echo ""
echo "步骤 6: 在连接的设备上运行..."
echo "如果没有连接设备，请使用 'flutter emulators' 查看可用模拟器"
echo "然后使用 'flutter emulators --launch <emulator_id>' 启动模拟器"
echo ""

# 提供运行选项
read -p "是否要在设备/模拟器上运行应用？(y/n): " run_app
if [ "$run_app" = "y" ] || [ "$run_app" = "Y" ]; then
    flutter run
fi

#!/bin/bash

# FlipKit Linux Build Script
# 用于构建 Linux 平台的可执行文件

set -e

echo "========================================="
echo "FlipKit Linux Build Script"
echo "========================================="

# 检查 Flutter 环境
echo "[1/5] 检查 Flutter 环境..."

# 尝试多种 Flutter 安装路径
FLUTTER_CMD=""
if command -v flutter &> /dev/null; then
    FLUTTER_CMD="flutter"
elif [ -d "$HOME/flutter" ]; then
    FLUTTER_CMD="$HOME/flutter/bin/flutter"
elif [ -d "/opt/flutter" ]; then
    FLUTTER_CMD="/opt/flutter/bin/flutter"
else
    echo "错误: Flutter 未安装或未添加到 PATH"
    echo ""
    echo "请安装 Flutter 或设置正确的路径："
    echo "  1. 下载 Flutter: https://flutter.dev/docs/get-started/install/linux"
    echo "  2. 解压到 ~/flutter 或 /opt/flutter"
    echo "  3. 添加到 PATH: export PATH=\"\$PATH:\$HOME/flutter/bin\""
    exit 1
fi

$FLUTTER_CMD --version
echo ""

# 清理之前的构建
echo "[2/5] 清理之前的构建..."
$FLUTTER_CMD clean
echo ""

# 获取依赖
echo "[3/5] 获取依赖..."
$FLUTTER_CMD pub get
echo ""

# 检查 Linux 构建依赖
echo "[4/5] 检查 Linux 构建依赖..."
if ! command -v cmake &> /dev/null; then
    echo "警告: cmake 未安装，尝试自动安装..."
    sudo apt-get update && sudo apt-get install -y cmake || {
        echo "错误: 无法安装 cmake"
        exit 1
    }
fi

if ! dpkg -l | grep -q libgtk-3-dev; then
    echo "警告: libgtk-3-dev 未安装，尝试自动安装..."
    sudo apt-get install -y libgtk-3-dev || {
        echo "错误: 无法安装 libgtk-3-dev"
        exit 1
    }
fi

echo "Linux 构建依赖检查完成"
echo ""

# 构建 Linux 可执行文件
echo "[5/5] 构建 Linux 可执行文件..."
$FLUTTER_CMD build linux --release
echo ""

# 检查构建结果
BUILD_DIR="build/linux/x64/release/bundle"
if [ -d "$BUILD_DIR" ]; then
    echo "========================================="
    echo "构建成功！"
    echo "========================================="
    echo "可执行文件位置: $BUILD_DIR/flipkit"
    echo ""
    echo "运行应用："
    echo "  cd $BUILD_DIR"
    echo "  ./flipkit"
    echo ""
    echo "或者创建启动器图标："
    echo "  sudo cp flipkit.desktop /usr/share/applications/"
    echo ""
else
    echo "错误: 构建失败"
    exit 1
fi

# 创建桌面快捷方式文件
cat > flipkit.desktop <<EOF
[Desktop Entry]
Name=FlipKit
Comment=智能学习应用 - 支持 K12 全学段
Exec=$(pwd)/build/linux/x64/release/bundle/flipkit
Icon=$(pwd)/assets/icons/app_icon.png
Terminal=false
Type=Application
Categories=Education;Utility;
StartupWMClass=flipkit
EOF

echo "桌面快捷方式已创建: flipkit.desktop"
echo "可以将其复制到 ~/.local/share/applications/ 或 /usr/share/applications/"

#!/bin/bash

echo "======================================"
echo "FlipKit Flutter 安装脚本"
echo "======================================"

# 检查是否已安装 Flutter
if [ -d "$HOME/flutter" ]; then
    echo "✓ Flutter 已安装在 $HOME/flutter"
    export PATH="$PATH:$HOME/flutter/bin"
else
    echo "下载 Flutter SDK..."
    
    # 选择稳定版 Flutter
    FLUTTER_VERSION="3.24.5"
    FLUTTER_CHANNEL="stable"
    
    # 创建临时目录
    mkdir -p /tmp/flutter_install
    cd /tmp/flutter_install
    
    # 下载 Flutter（Linux 版本）
    if [ ! -f "flutter_linux_${FLUTTER_VERSION}-${FLUTTER_CHANNEL}.tar.xz" ]; then
        echo "正在下载 Flutter ${FLUTTER_VERSION}..."
        wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-${FLUTTER_CHANNEL}.tar.xz
    fi
    
    # 解压到用户目录
    echo "正在解压 Flutter..."
    tar xf flutter_linux_${FLUTTER_VERSION}-${FLUTTER_CHANNEL}.tar.xz
    mv flutter $HOME/
    
    # 清理临时文件
    cd /home/alex/devspace/flipkit-app
    rm -rf /tmp/flutter_install
    
    echo "✓ Flutter 安装完成"
fi

# 设置环境变量
export PATH="$PATH:$HOME/flutter/bin"
export CHROME_EXECUTABLE=google-chrome

# 验证安装
echo ""
echo "验证 Flutter 安装..."
flutter --version

echo ""
echo "运行 flutter doctor 检查环境..."
flutter doctor -v

echo ""
echo "======================================"
echo "安装完成！"
echo "======================================"
echo "Flutter 路径: $HOME/flutter/bin"
echo ""
echo "请将以下内容添加到 ~/.bashrc 或 ~/.zshrc:"
echo "export PATH=\"\$PATH:\$HOME/flutter/bin\""
echo ""

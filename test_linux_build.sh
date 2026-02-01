#!/bin/bash

# 测试 Linux 构建配置

echo "========================================="
echo "Linux 构建配置测试"
echo "========================================="

# 检查必要文件
echo "[1/4] 检查必要文件..."
files_ok=true

if [ -f "linux/CMakeLists.txt" ]; then
    echo "✅ linux/CMakeLists.txt"
else
    echo "❌ linux/CMakeLists.txt 缺失"
    files_ok=false
fi

if [ -f "linux/main.cc" ]; then
    echo "✅ linux/main.cc"
else
    echo "❌ linux/main.cc 缺失"
    files_ok=false
fi

if [ -f "linux/my_application.cc" ]; then
    echo "✅ linux/my_application.cc"
else
    echo "❌ linux/my_application.cc 缺失"
    files_ok=false
fi

if [ -f "pubspec.yaml" ]; then
    echo "✅ pubspec.yaml"
else
    echo "❌ pubspec.yaml 缺失"
    files_ok=false
fi

echo ""

# 检查应用名称配置
echo "[2/4] 检查应用名称配置..."
if grep -q "BINARY_NAME \"flipkit\"" linux/CMakeLists.txt; then
    echo "✅ 应用名称: flipkit"
else
    echo "❌ 应用名称未正确配置"
fi

if grep -q "APPLICATION_ID \"com.flipkit.app\"" linux/CMakeLists.txt; then
    echo "✅ 应用 ID: com.flipkit.app"
else
    echo "❌ 应用 ID 未正确配置"
fi

echo ""

# 检查窗口标题
echo "[3/4] 检查窗口标题..."
if grep -q "FlipKit" linux/my_application.cc; then
    echo "✅ 窗口标题: FlipKit"
else
    echo "❌ 窗口标题未正确配置"
fi

echo ""

# 检查构建脚本
echo "[4/4] 检查构建脚本..."
if [ -f "build_linux.sh" ]; then
    echo "✅ build_linux.sh 存在"
    if [ -x "build_linux.sh" ]; then
        echo "✅ build_linux.sh 可执行"
    else
        echo "⚠️  build_linux.sh 不可执行，运行: chmod +x build_linux.sh"
    fi
else
    echo "❌ build_linux.sh 缺失"
fi

echo ""
echo "========================================="
if [ "$files_ok" = true ]; then
    echo "✅ 配置检查通过"
    echo "可以运行 ./build_linux.sh 进行构建"
else
    echo "❌ 配置检查失败"
    echo "请检查缺失的文件"
fi
echo "========================================="

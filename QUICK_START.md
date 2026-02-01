# FlipKit 快速启动指南

## 🎉 项目已完成重构！

FlipKit 智能K12学习应用已从头重新开发完成。现在开始使用吧！

---

## ⚡ 快速开始（3步启动）

### 第 1 步：安装 Flutter

如果您还没有安装 Flutter，请先安装：

**Windows:**
```bash
# 下载 Flutter SDK
# https://flutter.dev/docs/get-started/install/windows

# 解压到指定目录，例如：C:\flutter

# 添加到环境变量
# 将 C:\flutter\bin 添加到 PATH

# 验证安装
flutter doctor
```

**macOS:**
```bash
# 使用 Homebrew 安装
brew install --cask flutter

# 验证安装
flutter doctor
```

**Linux:**
```bash
# 下载 Flutter SDK
# https://flutter.dev/docs/get-started/install/linux

# 解压并添加到 PATH
export PATH="$PATH:/path/to/flutter/bin"

# 验证安装
flutter doctor
```

### 第 2 步：安装依赖

进入项目目录：

```bash
cd /home/alex/devspace/flipkit-app

# 安装依赖
flutter pub get
```

### 第 3 步：运行应用

```bash
# 连接设备或启动模拟器
flutter devices

# 运行应用
flutter run
```

---

## 📋 生成代码（可选）

如果使用了代码生成（如 json_serializable），需要运行：

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 🔑 配置 AI API Key

在使用 AI 功能之前，需要配置 API Key。

### 方法 1：通过应用设置

1. 运行应用
2. 进入"设置"页面
3. 选择 AI 提供商
4. 输入 API Key

### 方法 2：修改配置文件

编辑 `lib/config/ai_config.dart`：

```dart
static const List<AIProvider> providers = [
  AIProvider(
    name: 'Deepseek',
    apiKey: 'your-api-key-here',  // 在这里填入您的 API Key
    baseUrl: 'https://api.deepseek.com/v1',
    models: ['deepseek-chat'],
  ),
  // ...
];
```

---

## 📱 功能预览

### 学习模块

| 模块 | 功能 |
|------|------|
| 🎧 **听写** | TTS播放 + OCR识别 + 智能评分 |
| ❓ **问答** | AI组题 + 答案核对 |
| ✍️ **作文** | OCR识别 + AI评分 + 详细反馈 |

### 进化功能

| 功能 | 说明 |
|------|------|
| 🔍 **GitHub搜索** | 搜索教育相关仓库 |
| 📥 **资源下载** | 下载PDF、视频等资源 |
| 🌐 **网络资源** | 搜索和下载网络资源 |

---

## 🛠️ 常见问题

### Q: Flutter 命令找不到？
A: 确保 Flutter SDK 已正确安装并添加到系统 PATH。

### Q: 依赖安装失败？
A: 运行 `flutter clean` 后再试一次：
```bash
flutter clean
flutter pub get
```

### Q: 代码生成失败？
A: 尝试清理并重新生成：
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Q: 运行时报错？
A: 检查：
1. 是否连接了设备或模拟器
2. `flutter doctor` 是否显示所有检查通过
3. 查看完整的错误信息

### Q: AI 功能不工作？
A:
1. 确保已配置正确的 API Key
2. 检查网络连接
3. 查看 AI 提供商的 API 限制

---

## 📚 项目文档

- **README.md** - 项目概述
- **DEVELOPMENT.md** - 开发文档
- **PROJECT_COMPLETION.md** - 完成报告
- **QUICK_START.md** - 本文件

---

## 🎯 下一步建议

### 立即体验
1. 运行应用，体验基础功能
2. 尝试听写模块（模拟数据）
3. 探索资源中心

### 配置 AI
1. 获取 AI 提供商的 API Key
2. 在设置中配置
3. 体验 AI 智能组题

### 功能完善
1. 实现拍照功能
2. 完成资源下载
3. 优化用户体验

---

## 📞 技术支持

如遇到问题：
1. 查看 `DEVELOPMENT.md` 开发文档
2. 检查 Flutter 官方文档：https://flutter.dev
3. 查看各依赖库的文档

---

**祝您使用愉快！** 🚀

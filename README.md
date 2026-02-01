# FlipKit - 智能K12学习应用

## 📋 项目概述

FlipKit 是一款基于 Flutter 开发的智能 K12 教育学习应用，具备以下核心特性：

- **AI 智能组题** - 使用大模型自动生成学习题目
- **多模块学习** - 听写、问答、作文等多个学习模块
- **进化功能** - GitHub 资源搜索与下载、网络资源集成
- **统一 UI** - 使用 GetWidget 组件库打造一致的用户体验
- **多儿童支持** - 独立的学习空间和进度追踪

## 🎯 核心功能

### 1. 智能组题系统
- 使用大模型 API (Deepseek、通义千问、文心一言等) 自动生成题目
- 支持多种题型：选择题、填空题、判断题、简答题
- 可配置难度等级和知识点范围

### 2. 学习模块
- **听写模块** - TTS 播放 + OCR 识别 + 智能评分
- **问答模块** - AI 组题 + 答案核对
- **作文模块** - OCR 识别 + AI 评分 + 详细反馈

### 3. 进化功能
- GitHub 资源搜索和下载
- 网络教育资源聚合
- 自动更新和扩展题库

### 4. 数据管理
- 本地 SQLite 存储
- 多儿童学习空间隔离
- 学习进度统计和分析

## 🏗️ 技术架构

```
lib/
├── main.dart                 # 应用入口
├── app/                      # 应用层
│   ├── app.dart             # App 配置
│   └── routes.dart          # 路由配置
├── core/                     # 核心层
│   ├── constants/           # 常量
│   ├── utils/               # 工具类
│   └── theme/               # 主题配置
├── data/                     # 数据层
│   ├── models/              # 数据模型
│   ├── repositories/        # 仓库层
│   └── datasources/         # 数据源
├── domain/                   # 领域层
│   ├── entities/            # 实体
│   └── usecases/            # 用例
├── presentation/             # 表现层
│   ├── pages/               # 页面
│   ├── widgets/             # 组件
│   └── controllers/         # 控制器
├── services/                 # 服务层
│   ├── ai_service.dart      # AI 服务
│   ├── ocr_service.dart     # OCR 服务
│   ├── tts_service.dart     # TTS 服务
│   ├── github_service.dart  # GitHub 服务
│   └── resource_service.dart # 资源服务
└── config/                   # 配置
    ├── api_config.dart      # API 配置
    └── app_config.dart      # 应用配置
```

## 🚀 快速开始

### 环境要求
- Flutter SDK >= 3.10.0
- Dart SDK >= 3.0.0
- Android Studio / Xcode

### 安装依赖
```bash
flutter pub get
```

### 运行应用
```bash
flutter run
```

## 📦 主要依赖

| 依赖 | 用途 |
|------|------|
| get | 状态管理和路由 |
| getwidget | UI 组件库 |
| dio | 网络请求 |
| hive | 本地存储 |
| sqflite | 数据库 |
| google_ml_kit | OCR 识别 |
| flutter_tts | 文本转语音 |
| webview_flutter | WebView |

## 🎨 UI 设计原则

- 使用 GetWidget 组件库保持一致性
- 遵循 Material Design 3 规范
- 支持深色模式
- 响应式设计，适配不同屏幕

## 🔐 安全性

- API 密钥安全存储
- 用户数据加密
- HTTPS 通信
- 权限最小化原则

## 📄 许可证

[待添加]

## 👥 贡献

欢迎提交 Issue 和 Pull Request！

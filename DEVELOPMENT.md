# FlipKit 开发说明

## 项目概述

FlipKit 是一款全新的智能 K12 教育学习应用，具备以下核心特性：

- **AI 智能组题** - 使用大模型自动生成学习题目
- **多模块学习** - 听写、问答、作文等多个学习模块
- **进化功能** - GitHub 资源搜索与下载、网络资源集成
- **统一 UI** - 使用 GetWidget 组件库打造一致的用户体验
- **多儿童支持** - 独立的学习空间和进度追踪

## 技术栈

### 前端
- **Flutter 3.x** - 跨平台开发框架
- **GetX** - 状态管理和路由
- **GetWidget** - UI 组件库（国内可用）
- **Google Fonts** - 字体支持

### 后端/服务
- **SQLite** - 本地数据库
- **Dio** - 网络请求
- **Hive** - 轻量级存储
- **Google ML Kit** - OCR 识别
- **Flutter TTS** - 文本转语音

### AI 集成
- **Deepseek** - 国内大模型
- **通义千问** - 阿里云
- **文心一言** - 百度
- **智谱AI** - 清华
- **Kimi** - 月之暗面

## 项目结构

```
lib/
├── main.dart                     # 应用入口
├── app/                          # 应用层
│   ├── app.dart                 # App 配置
│   └── routes.dart              # 路由配置
├── core/                         # 核心层
│   ├── constants/               # 常量
│   ├── utils/                   # 工具类
│   └── theme/                   # 主题配置
├── data/                         # 数据层
│   ├── models/                  # 数据模型
│   ├── database/                # 数据库
│   └── repositories/            # 仓库层
├── presentation/                 # 表现层
│   ├── pages/                   # 页面
│   ├── widgets/                 # 组件
│   └── controllers/             # 控制器
├── services/                     # 服务层
│   ├── ai_service.dart          # AI 服务
│   ├── ocr_service.dart         # OCR 服务
│   ├── tts_service.dart         # TTS 服务
│   ├── github_service.dart      # GitHub 服务
│   └── resource_service.dart   # 资源服务
└── config/                       # 配置
    ├── ai_config.dart           # AI 配置
    └── app_config.dart          # 应用配置
```

## 快速开始

### 1. 安装依赖

```bash
flutter pub get
```

### 2. 生成代码

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. 运行应用

```bash
flutter run
```

## 核心功能说明

### AI 智能组题

使用大模型自动生成题目，支持：
- 选择题
- 填空题
- 判断题
- 简答题

可配置参数：
- 科目
- 年级
- 章节
- 难度
- 数量

### OCR 识别

使用 Google ML Kit 识别手写内容：
- 听写评测
- 作文识别
- 错误检测

### TTS 播放

使用 Flutter TTS 播放内容：
- 听写播放
- 多语言支持
- 语速/音调调节

### GitHub 集成

- 搜索仓库
- 浏览文件
- 下载资源
- PDF/视频等格式支持

### 资源管理

- 本地资源管理
- 网络资源搜索
- GitHub 资源集成
- 资源预览和播放

## 配置说明

### AI 配置

编辑 `lib/config/ai_config.dart`：

```dart
static const List<AIProvider> providers = [
  AIProvider(
    name: 'Deepseek',
    apiKey: 'your-api-key',  // 在此配置或通过设置页面配置
    baseUrl: 'https://api.deepseek.com/v1',
    models: ['deepseek-chat'],
  ),
  // ...
];
```

### 数据库配置

编辑 `lib/config/app_config.dart`：

```dart
static const String dbName = 'flipkit.db';
static const int dbVersion = 1;
```

## 开发任务清单

### 基础功能 ✅
- [x] 项目架构搭建
- [x] 路由配置
- [x] 主题配置
- [x] 数据库设计
- [x] 服务层实现
- [x] 基础页面

### AI 功能
- [ ] AI 组题实现
- [ ] AI 评分实现
- [ ] 多模型切换
- [ ] API Key 管理

### 学习模块
- [ ] 听写模块完整实现
- [ ] 问答模块完整实现
- [ ] 作文模块完整实现

### OCR & TTS
- [ ] OCR 识别优化
- [ ] TTS 播放优化
- [ ] 错误检测改进

### GitHub & 资源
- [ ] GitHub API 集成
- [ ] 资源下载功能
- [ ] 文件预览功能

### UI 完善
- [ ] 组件封装
- [ ] 动画效果
- [ ] 深色模式

## 测试

### 单元测试
```bash
flutter test
```

### 集成测试
```bash
flutter test integration_test/
```

## 构建发布

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## 注意事项

1. **API Key**: 使用前需要配置 AI 服务的 API Key
2. **权限**: 需要摄像头、麦克风、存储等权限
3. **网络**: 部分功能需要网络连接
4. **依赖**: 确保所有依赖都已正确安装

## 常见问题

### 1. 代码生成失败
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### 2. 运行时错误
检查 `pubspec.yaml` 中的依赖版本是否正确

### 3. OCR 不工作
确保已正确配置 Google ML Kit

### 4. TTS 没有声音
检查设备音量设置和 TTS 引擎

## 贡献指南

1. Fork 本项目
2. 创建特性分支
3. 提交更改
4. 推送到分支
5. 创建 Pull Request

## 许可证

[待添加]

## 联系方式

[待添加]

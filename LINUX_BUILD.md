# FlipKit Linux 平台构建指南

## 概述

FlipKit 现已支持 Linux 平台构建，可在 Ubuntu、Fedora、Debian 等主流 Linux 发行版上运行。

## 系统要求

### 必需软件

- **Flutter SDK** >= 3.24.5
- **CMake** >= 3.10
- **GTK+ 3.0** 开发库
- **Clang** 或 **GCC** 编译器

### Ubuntu/Debian 安装依赖

```bash
sudo apt-get update
sudo apt-get install -y \
    cmake \
    ninja-build \
    libgtk-3-dev \
    libglib2.0-dev \
    pkg-config
```

### Fedora/RHEL 安装依赖

```bash
sudo dnf install -y \
    cmake \
    ninja-build \
    gtk3-devel \
    glib2-devel \
    pkg-config
```

## 快速开始

### 1. 使用构建脚本（推荐）

```bash
./build_linux.sh
```

脚本会自动完成以下操作：
- 检查 Flutter 环境
- 清理之前的构建
- 获取依赖
- 检查并安装 Linux 构建依赖
- 构建 Linux 可执行文件
- 创建桌面快捷方式

### 2. 手动构建

```bash
# 清理
flutter clean

# 获取依赖
flutter pub get

# 构建 Linux Release 版本
flutter build linux --release

# 运行应用
cd build/linux/x64/release/bundle
./flipkit
```

## 构建产物

构建完成后，可执行文件位于：

```
build/linux/x64/release/bundle/
├── flipkit          # 主可执行文件
├── data/            # 应用数据
│   ├── flutter_assets/  # Flutter 资源
│   └── icudtl.dat      # ICU 数据
└── lib/             # 动态库
```

## 安装应用

### 方式 1：本地运行（无需安装）

直接运行构建的可执行文件：

```bash
cd build/linux/x64/release/bundle
./flipkit
```

### 方式 2：安装到系统

```bash
# 复制到 /opt 目录
sudo cp -r build/linux/x64/release/bundle /opt/flipkit

# 创建符号链接
sudo ln -s /opt/flipkit/flipkit /usr/local/bin/flipkit
```

### 方式 3：添加桌面快捷方式

```bash
# 复制桌面文件到系统应用目录
sudo cp flipkit.desktop /usr/share/applications/

# 或者复制到用户目录
mkdir -p ~/.local/share/applications
cp flipkit.desktop ~/.local/share/applications/
```

## 平台限制

由于平台差异，以下功能在 Linux 上可能受限或不可用：

### 已知限制

| 功能 | Linux 支持情况 | 说明 |
|------|----------------|------|
| UI 界面 | ✅ 完全支持 | 所有 UI 功能正常 |
| AI 组题 | ✅ 完全支持 | AI 功能正常工作 |
| TTS 语音 | ✅ 支持 | 使用系统 TTS 引擎 |
| OCR 识别 | ❌ 不支持 | Google ML Kit 不支持 Linux |
| 摄像头 | ⚠️ 部分支持 | 需要用户权限 |
| 文件选择 | ✅ 支持 | 使用系统文件选择器 |
| 网络资源 | ✅ 支持 | GitHub、下载等功能正常 |
| 数据存储 | ✅ 支持 | SQLite、Hive 正常工作 |

### OCR 替代方案

Linux 平台不支持 Google ML Kit OCR，可以考虑以下替代方案：

1. **在线 OCR 服务**
   - 使用 API 调用云端 OCR 服务
   - 需要网络连接

2. **Tesseract OCR**
   - 开源 OCR 引擎
   - 需要安装 Tesseract 库：
     ```bash
     sudo apt-get install -y tesseract-ocr
     ```

3. **平台条件编译**
   ```dart
   import 'dart:io';
   
   bool get isLinux => Platform.isLinux;
   
   void startOCR() {
     if (isLinux) {
       // 使用 Linux 特定的 OCR 实现
     } else {
       // 使用 Google ML Kit
     }
   }
   ```

## 调试

### Debug 构建

```bash
flutter build linux --debug
```

### 查看日志

```bash
# 运行时查看日志
flutter run -d linux --verbose

# 或使用 Flutter DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

## 常见问题

### 1. 缺少 GTK 库

**错误信息：**
```
Could not find GTK 3.0
```

**解决方案：**
```bash
sudo apt-get install libgtk-3-dev
```

### 2. 缺少 CMake

**错误信息：**
```
CMake is required to build for Linux
```

**解决方案：**
```bash
sudo apt-get install cmake
```

### 3. 权限问题

**错误信息：**
```
Permission denied when accessing camera
```

**解决方案：**
```bash
# 检查用户组
groups $USER

# 如果不在 video/audio 组，添加用户
sudo usermod -a -G video,audio $USER
# 注销后重新登录生效
```

### 4. 字体显示异常

**错误信息：**
中文字体显示为方框

**解决方案：**
```bash
# 安装中文字体
sudo apt-get install -y fonts-noto-cjk fonts-wqy-microhei
```

## 发布到 Linux

### 创建 AppImage（跨发行版）

```bash
# 安装 appimagetool
wget https://github.com/AppImage/AppImageKit/releases/download/13/appimagetool-x86_64.AppImage
chmod +x appimagetool-x86_64.AppImage

# 创建 AppImage
./appimagetool-x86_64.AppImage build/linux/x64/release/bundle flipkit-x86_64.AppImage
```

### 创建 Snap 包（Ubuntu）

创建 `snap/snapcraft.yaml` 文件，然后运行：

```bash
sudo snap install snapcraft --classic
cd snap
snapcraft
```

### 创建 DEB 包（Debian/Ubuntu）

使用 `makeself` 或 `fpm` 工具创建 DEB 包。

## 性能优化

### 1. 启用 AOT 编译

```bash
flutter build linux --release
```

Release 模式会自动启用 AOT 编译，提升性能。

### 2. 减小应用体积

```bash
# 使用 --split-debug-info 分离调试符号
flutter build linux --release --split-debug-info=./debug-info

# 使用 --obfuscate 混淆代码
flutter build linux --release --obfuscate --split-debug-info=./debug-info
```

### 3. 优化资源

- 使用压缩图片
- 移除未使用的资源
- 启用代码分割

## 开发建议

### 平台检测

```dart
import 'dart:io';

void main() {
  if (Platform.isLinux) {
    print('Running on Linux platform');
    // Linux 特定的初始化
  }
  runApp(FlipKitApp());
}
```

### 条件导入

```dart
import 'ocr_service_base.dart' as base;
import 'ocr_service_native.dart' if (dart.library.io) 'ocr_service_io.dart';

class OCRService {
  static Future<String> recognizeText(File image) {
    if (Platform.isLinux) {
      return OCRServiceLinux.recognizeText(image);
    } else {
      return OCRServiceNative.recognizeText(image);
    }
  }
}
```

## 相关文档

- [Flutter Linux 官方文档](https://flutter.dev/desktop#linux)
- [GTK+ 3.0 文档](https://developer.gnome.org/gtk3/)
- [CMake 文档](https://cmake.org/documentation/)

## 更新日志

### v1.0.0 (2026-01-01)
- ✅ 新增 Linux 平台支持
- ✅ 更新构建配置
- ✅ 创建 Linux 构建脚本
- ✅ 添加平台检测代码
- ⚠️ OCR 功能暂时不可用（Google ML Kit 限制）

## 技术支持

如有问题，请提交 Issue 或联系开发团队。

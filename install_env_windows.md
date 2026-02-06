# Windows 环境安装与打包 APK

## 1. 安装 Java 17（必须）

本项目的 Android 构建需要 **Java 17**。

- **下载**： [Amazon Corretto 17](https://docs.aws.amazon.com/corretto/latest/corretto-17-ug/downloads-list.html) 或 [Oracle JDK 17](https://www.oracle.com/java/technologies/downloads/#java17)
- **安装后** 设置环境变量 **JAVA_HOME** 指向 JDK 17 根目录（例如 `C:\Program Files\Amazon Corretto\jdk17.x.x_x`）
- 或在项目根目录执行（路径按实际安装修改）：
  ```cmd
  flutter config --jdk-dir="C:\Program Files\Amazon Corretto\jdk17.x.x_x"
  ```
- 验证：`java -version` 应显示 17.x

## 2. 安装 Flutter

1. **下载 Flutter SDK**  
   - 打开 https://docs.flutter.dev/get-started/install/windows  
   - 或直接下载：https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_*.zip  

2. **解压**  
   - 解压到不含空格和中文的路径，例如：`C:\flutter`

3. **配置 PATH**  
   - 系统属性 → 环境变量 → 用户变量 `Path` → 新建 → 添加：`C:\flutter\bin`（按你的解压路径修改）

4. **启用开发者模式**（用于插件符号链接）  
   - 设置 → 隐私和安全性 → 开发者模式 → 打开  
   - 或运行：`start ms-settings:developers`

5. **验证**（新开一个命令行）  
   ```cmd
   flutter doctor
   ```
   - 若提示缺少 Android 工具，按提示安装 **Android Studio** 或 **Android SDK command-line tools**，并接受 Android 许可：
   ```cmd
   flutter doctor --android-licenses
   ```

## 3. 打包 APK

在项目根目录执行：

```cmd
build_apk.bat
```

或手动执行：

```cmd
flutter clean
flutter pub get
flutter build apk --release
```

APK 输出路径：`build\app\outputs\flutter-apk\app-release.apk`。

---

## 常见问题

| 现象 | 处理 |
|------|------|
| `Android Gradle plugin requires Java 17` | 安装 JDK 17 并设置 `JAVA_HOME` 或 `flutter config --jdk-dir=...` |
| `Building with plugins requires symlink support` | 在 Windows 设置中开启「开发者模式」 |
| `flutter` 不是内部或外部命令 | 将 Flutter 的 `bin` 目录加入系统 PATH |

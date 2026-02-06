@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion
echo ======================================
echo 快学喵 - 自动验证并打包 APK
echo ======================================
echo.

echo [Step 1/5] 验证 Java 环境...
set "USE_JAVA="
java -version 2>&1 | findstr /C:"17." >nul 2>&1
if %ERRORLEVEL% equ 0 set "USE_JAVA=1"
if not defined USE_JAVA (
    echo 当前不是 Java 17，自动查找 Amazon Corretto 17...
    for /d %%d in ("C:\Program Files\Amazon Corretto\jdk17*") do (
        if exist "%%d\bin\java.exe" set "CORRETTO17=%%d"
    )
    if not defined CORRETTO17 (
        for /d %%d in ("C:\Program Files (x86)\Amazon Corretto\jdk17*") do (
            if exist "%%d\bin\java.exe" set "CORRETTO17=%%d"
        )
    )
    if not defined CORRETTO17 (
        for /d %%d in ("D:\Program Files\Amazon Corretto\jdk17*") do (
            if exist "%%d\bin\java.exe" set "CORRETTO17=%%d"
        )
    )
    if defined CORRETTO17 (
        echo 找到: !CORRETTO17!
        set "JAVA_HOME=!CORRETTO17!"
        set "PATH=!CORRETTO17!\bin;!PATH!"
        set "USE_JAVA=1"
    )
)
if not defined USE_JAVA (
    echo [ERROR] 未检测到 Java 17。请安装 Amazon Corretto 17 或将 JAVA_HOME 指向 JDK17。
    exit /b 1
)
java -version 2>&1
echo.

echo [Step 2/5] 验证 Flutter...
where flutter >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] 未检测到 Flutter。请先安装并加入 PATH。
    exit /b 1
)
flutter --version 2>nul
echo.

echo [Step 3/5] 清理旧构建...
call flutter clean
if %ERRORLEVEL% neq 0 ( echo [ERROR] flutter clean 失败。 & exit /b 1 )
echo.

echo [Step 4/5] 获取依赖...
call flutter pub get
if %ERRORLEVEL% neq 0 ( echo [ERROR] flutter pub get 失败。 & exit /b 1 )
echo.

echo [Step 5/5] 构建 Release APK...
call flutter build apk --release
set BUILD_EXIT=!ERRORLEVEL!
echo.

if !BUILD_EXIT! equ 0 (
    echo ======================================
    echo 验证与打包完成
    echo ======================================
    echo APK: build\app\outputs\flutter-apk\app-release.apk
    if exist "build\app\outputs\flutter-apk\app-release.apk" (
        for %%A in ("build\app\outputs\flutter-apk\app-release.apk") do echo Size: %%~zA bytes
    )
    exit /b 0
) else (
    echo [ERROR] 构建失败 exit code: !BUILD_EXIT!
    exit /b !BUILD_EXIT!
)

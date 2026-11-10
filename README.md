# FlipKit

An intelligent K12 learning companion built with Flutter. FlipKit helps students practice, review and create homework with AI-powered question generation, OCR homework assistance, dictation, essay writing and a rich set of learning resources.

## Features

- **AI-powered question generation** — generate exercises per grade and subject, with automatic scoring. Supports multiple providers: DeepSeek, Qwen (通义千问), ERNIE (文心一言), Zhipu GLM and Kimi.
- **OCR homework assistance** — pluggable OCR engines (PaddleOCR, Tesseract, Google ML Kit) to recognize questions from photos and textbooks.
- **Text-to-speech** — built-in TTS for listening practice.
- **Learning modules** — quiz, dictation (听写), essay (作文), homework, morality and more.
- **Learning spaces & curriculum sync** — organized spaces with offline curriculum caching.
- **Resource center** — browse and download open educational resources, including GitHub-hosted assets.
- **Offline-first storage** — Hive, SQLite and secure storage for local data persistence.

## Tech Stack

- Flutter (>= 3.24) / Dart (>= 3.0)
- State management: GetX
- Networking: Dio
- Local storage: Hive, sqflite, shared_preferences, flutter_secure_storage, get_storage
- PDF: Syncfusion Flutter PDF, flutter_pdfview
- UI: GetWidget, flutter_animate, lottie, shimmer, pull_to_refresh

## Supported Platforms

Android, iOS, Web, Windows, macOS, Linux

## Getting Started

```bash
flutter pub get
flutter run
```

### Release build

```bash
# Android
flutter build apk --release

# Web
flutter build web --release
```

## Project Structure

```
lib/
├── app/                 # Application bootstrap & routes
├── config/              # App & AI provider configuration
├── core/                # Constants, theme, utils, shared widgets
├── data/                # Local database & data models
├── presentation/pages/  # Feature pages (home, quiz, dictation, essay, ...)
└── services/            # AI, OCR, TTS, curriculum sync, resource services
```

AI provider credentials are configured in `lib/config/ai_config.dart` (or via in-app settings); OCR engine can be selected automatically or manually in `lib/services/ocr_factory.dart`.

## License

Not yet specified. Contact the maintainers before reusing this codebase.

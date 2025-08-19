# Open Web UI App 📱

> ⚠️ **BETA WARNING**: This project is currently in **beta stage** and is **not yet complete**. Features may be incomplete, unstable, or subject to breaking changes. Use at your own discretion and expect bugs!

A Flutter mobile application for [Open WebUI](https://github.com/open-webui/open-webui), bringing AI chat capabilities to your mobile device with a native, smooth experience.

## 🚀 Features

- 💬 Native mobile chat interface
- 🔐 Secure authentication 
- 📱 Cross-platform support (iOS, Android, Web, macOS, Linux, Windows)
- 🎨 Modern Material Design UI
- 🔄 Real-time messaging
- 📂 Chat session management

## 🛠️ Getting Started

### Prerequisites

- [Flutter](https://flutter.dev/docs/get-started/install) (SDK 3.9.0 or higher)
- [Dart](https://dart.dev/get-dart)
- For iOS development: Xcode
- For Android development: Android Studio/SDK

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/open-webui-flutter.git
   cd open-webui-flutter
   ```

2. **Navigate to the source directory**
   ```bash
   cd src
   ```

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Set up environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

5. **Run the app**
   ```bash
   # For development
   flutter run

   # For specific platform
   flutter run -d chrome      # Web
   flutter run -d ios         # iOS Simulator
   flutter run -d android     # Android Emulator
   ```

### Building for Production

```bash
# Android APK
flutter build apk --release

# iOS (requires Mac)
flutter build ios --release

# Web
flutter build web --release

# Desktop (macOS)
flutter build macos --release

# Desktop (Linux)
flutter build linux --release

# Desktop (Windows)
flutter build windows --release
```

## 🔧 Configuration

Create a `.env` file in the `src` directory with your Open WebUI server configuration:

```env
OPEN_WEBUI_BASE_URL=https://your-openwebui-instance.com
API_KEY=your-api-key-here
```

## 📖 Development

### Project Structure

```
src/
├── lib/
│   ├── api/          # API clients and endpoints
│   ├── models/       # Data models
│   ├── screens/      # UI screens
│   ├── services/     # Business logic services
│   ├── utils/        # Utility functions
│   └── widgets/      # Reusable UI components
├── android/          # Android-specific code
├── ios/              # iOS-specific code
├── web/              # Web-specific code
└── test/            # Unit and widget tests
```

### Running Tests

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage
```

### Code Generation

```bash
# Generate JSON serialization code
flutter packages pub run build_runner build
```

## 🤝 Contributing

We welcome contributions from everyone! This is an open-source project and we'd love your help to make it better.

### How to Contribute

1. **🍴 Fork the repository**
2. **🌿 Create a feature branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. **📝 Make your changes**
4. **✅ Write/update tests if needed**
5. **🧪 Run tests and ensure they pass**
   ```bash
   flutter test
   flutter analyze
   ```
6. **📤 Commit and push your changes**
   ```bash
   git commit -m "Add amazing feature"
   git push origin feature/amazing-feature
   ```
7. **🔄 Open a Pull Request**

### What We're Looking For

- 🐛 Bug fixes
- ✨ New features
- 📚 Documentation improvements
- 🎨 UI/UX enhancements
- 🧪 Test coverage improvements
- 🌐 Internationalization/localization
- ♿ Accessibility improvements

### Development Guidelines

- Follow [Flutter's style guide](https://dart.dev/guides/language/effective-dart/style)
- Write meaningful commit messages
- Add tests for new features
- Update documentation when needed
- Keep PRs focused and atomic

### Getting Help

- 💬 Join our [Discord](#) (coming soon)
- 🐛 Report bugs via [GitHub Issues](https://github.com/your-username/open-webui-flutter/issues)
- 💡 Suggest features via [GitHub Discussions](https://github.com/your-username/open-webui-flutter/discussions)

## 📱 Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| 🤖 Android | ✅ Working | API 21+ |
| 🍎 iOS | ✅ Working | iOS 12+ |
| 🌐 Web | ✅ Working | Modern browsers |
| 🖥️ macOS | ⚠️ Beta | macOS 10.14+ |
| 🐧 Linux | ⚠️ Beta | Ubuntu 18.04+ |
| 🪟 Windows | ⚠️ Beta | Windows 10+ |

## 🛣️ Roadmap

- [ ] Offline support
- [ ] Push notifications
- [ ] File upload/download
- [ ] Voice messages
- [ ] Dark/Light theme toggle
- [ ] Multiple server support
- [ ] Biometric authentication
- [ ] Chat backup/restore

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Thanks to the [Open WebUI](https://github.com/open-webui/open-webui) team for the amazing backend
- Flutter team for the excellent cross-platform framework
- All contributors who help make this project better

---

**⭐ Star this repo if you find it useful!**

**🐛 Found a bug?** [Report it here](https://github.com/your-username/open-webui-flutter/issues)

**💡 Have an idea?** [Share it with us](https://github.com/your-username/open-webui-flutter/discussions)
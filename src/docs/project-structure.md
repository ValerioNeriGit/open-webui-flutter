# OpenWebUI Flutter - Project Structure & Developer Guide

## Overview

This Flutter app is a client for OpenWebUI, providing a native mobile interface for AI chat interactions. The project follows a layered architecture designed to handle a complex backend API while maintaining clean separation of concerns.

## 🏗️ Architecture Overview

```
lib/
├── api/           # API layer - HTTP calls and complex workflows
├── models/        # Data models and JSON serialization
├── screens/       # UI screens and pages
├── services/      # Business logic and validation
├── utils/         # Shared utilities (colors, logger)
└── widgets/       # Reusable UI components
```

### Architecture Philosophy

The app uses **3-layer architecture** to isolate complexity:

1. **API Layer** (`lib/api/`): Raw HTTP calls and complex API workflows
2. **Services Layer** (`lib/services/`): Business logic and validation  
3. **UI Layer** (`lib/screens/`, `lib/widgets/`): State management and presentation

## 📁 Detailed Structure

### `/lib/api/` - API Layer

```
api/
├── api_client.dart       # Singleton HTTP client with auth
├── api_exception.dart    # Custom exceptions hierarchy  
├── endpoints/           # Direct 1:1 API mappings
│   ├── auth/           # Authentication endpoints
│   ├── chats/         # Chat CRUD operations
│   └── completions/   # AI completion endpoints
└── wrappers/          # Complex multi-step workflows
    └── send_message/  # 6-step message sending workflow
```

**Key Concepts:**
- **Endpoints**: Simple 1:1 mappings to backend routes
- **Wrappers**: Handle complex multi-step API workflows (like message sending)
- **ApiClient**: Singleton with automatic auth header injection

### `/lib/models/` - Data Models

```
models/
├── chat.dart         # Chat, ChatMessage, ChatListItem
├── chat.g.dart      # Generated JSON serialization
└── [other models]
```

**Features:**
- JSON serialization with `json_annotation`
- Custom converters for timestamps
- Immutable data structures with `copyWith` methods

### `/lib/services/` - Business Logic

```
services/
├── auth_service.dart      # Authentication & session management
├── chat_service.dart      # Chat operations business logic
└── messaging_service.dart # Message sending validation
```

**Responsibilities:**
- Input validation
- Business logic enforcement
- Error handling and user-friendly messages
- State management coordination

### `/lib/screens/` - UI Screens

```
screens/
├── chat_home_screen.dart  # Main chat interface
├── login_screen.dart      # Authentication screen
└── splash_screen.dart     # App startup screen
```

### `/lib/widgets/` - Reusable Components

```
widgets/
├── chat_interface.dart    # Message list and input
└── chat_sidebar.dart      # Chat list sidebar
```

### `/lib/utils/` - Utilities

```
utils/
├── colors.dart           # App color scheme
└── logger.dart          # Comprehensive logging system
```

## 🐛 Debugging & Development

### Comprehensive Logging System

The app includes a sophisticated logging system built on the `logger` package:

**Location**: `lib/utils/logger.dart`

**Features:**
- **Automatic error tracking** with file locations and stack traces
- **Emoji categorization** for easy log filtering
- **Request/response logging** for all API calls
- **Different log levels**: debug, info, warning, error
- **Centralized operation wrapper** to eliminate code duplication
- **Clean success logs** (no stack traces) vs **detailed error logs** (full stack traces)

**Usage:**

*Basic logging:*
```dart
import '../utils/logger.dart';

AppLogger.info('✅ Operation completed successfully');
AppLogger.warning('⚠️ Potential issue detected'); // Shows stack trace
AppLogger.logError('OperationName.methodName()', error, stackTrace);
```

*Centralized operation wrapper (recommended):*
```dart
// Instead of repetitive try-catch blocks everywhere:
static Future<Chat> getChat(String chatId) async {
  return AppLogger.wrapOperation(
    'ChatService.getChat($chatId)',
    () async {
      final chat = await ChatEndpoints.getChat(chatId);
      AppLogger.debug('📋 Chat loaded: ${chat.title}');
      return chat;
    },
    startMessage: '📥 Fetching chat details for ID: $chatId',
    successMessage: '✅ Chat loaded successfully',
  );
}
```

**What You'll See:**

*Clean success logs:*
```
🚀 Starting OpenWebUI Flutter App
🔐 Initializing AuthService
📁 Loading chats from ChatService
🌐 API GET Request: URL: https://api.example.com/chats
✅ Successfully loaded 73 chats
💬 Sending message to chat: abc123-def456
```

*Detailed error logs (only when problems occur):*
```
┌─────────────────────────────────────────────────────────
│ 🔥 ERROR in ChatService.getChat(chatId123)
│    Error Type: ApiException  
│    Message: Failed to fetch chat
│    Location: chat_service.dart:45
├─────────────────────────────────────────────────────────
│ #0 ChatService.getChat (chat_service.dart:45:7)
│ #1 ChatHomeScreen._selectChat (chat_home_screen.dart:67:23)
└─────────────────────────────────────────────────────────
```

### Debugging Best Practices

#### 1. **Use Centralized Operation Wrapper**
For service methods, use the operation wrapper for consistent logging:
```dart
static Future<Result> newOperation(String param) async {
  return AppLogger.wrapOperation(
    'ClassName.newOperation($param)',
    () async {
      final result = await apiCall(param);
      AppLogger.debug('📊 Got result: ${result.summary}');
      return result;
    },
    startMessage: '🔄 Starting newOperation with: $param',
    successMessage: '✅ newOperation completed successfully',
  );
}
```

#### 2. **Log State Changes**
```dart
setState(() {
  _currentState = newState;
});
AppLogger.debug('🔄 State updated to: $newState');
```

#### 3. **Add Context Logging**
All API calls are automatically logged by `ApiClient`, but add context where helpful:
```dart
AppLogger.debug('📤 Processing data with keys: ${requestData.keys}');
```

#### 4. **Log Levels Guide**
- `AppLogger.debug()` - Development info (clean logs)
- `AppLogger.info()` - Important operations (clean logs)  
- `AppLogger.warning()` - Potential issues (shows stack trace)
- `AppLogger.error()` - Failures (shows stack trace)
- `AppLogger.logError()` - Structured error logging (shows stack trace)

### Where to Find Logs

**Development (flutter run --debug):**
- **Terminal**: Primary location for all logs
- **iOS Device**: Use Xcode → Window → Devices → Console
- **Chrome**: Browser DevTools → Console tab
- **Flutter DevTools**: Access via URL shown in terminal

**Log Format:**
```
┌─────────────────────────────────────────────────────────
│ 🔥 ERROR in ChatService.getChat(chatId123)
│    Error Type: ApiException  
│    Message: Failed to fetch chat
│    Location: chat_service.dart:45
├─────────────────────────────────────────────────────────
│ #0 ChatService.getChat (chat_service.dart:45:7)
│ #1 ChatHomeScreen._selectChat (chat_home_screen.dart:67:23)
└─────────────────────────────────────────────────────────
```

## 🚨 Known Issues & Workarounds

### Server Data Corruption
**Issue**: Backend sometimes returns chat objects with empty `id` fields
**Workaround**: `chat_endpoints.dart` automatically injects the correct ID
**Location**: `lib/api/endpoints/chats/chat_endpoints.dart:38-44`

### JSON Parsing
**Issue**: Server may return `null` values for required fields
**Solution**: Use nullable types in models or provide `defaultValue` in `@JsonKey`

## 🔧 Development Workflow

### Adding New Features

1. **Plan the layers**:
   - Does this need new API endpoints?
   - What business logic is required?
   - Which UI components are affected?

2. **Start with models** (if needed):
   ```bash
   # After adding model changes
   flutter packages pub run build_runner build
   ```

3. **Add API layer**:
   - Create endpoint methods
   - Add proper error handling
   - Include logging

4. **Implement service layer**:
   - Add validation
   - Handle business logic
   - Provide user-friendly errors

5. **Update UI**:
   - Modify screens/widgets
   - Add loading states
   - Handle errors gracefully

### Testing Your Changes

1. **Check logs**: Ensure proper logging is in place
2. **Test error cases**: What happens when API fails?
3. **Verify state management**: Does UI update correctly?
4. **Cross-platform**: Test on both iOS and web if possible

## 🔍 Debugging Common Issues

### "Chat ID is required"
**Cause**: Chat loading failed or returned empty ID
**Debug**: Check logs for `🚨 CRITICAL: Chat ID loaded as:`
**Solution**: Server data issue - the workaround handles this

### Authentication Problems
**Check**: `AuthService` logs show login flow
**Debug**: Look for `🔐` emoji logs in terminal

### API Failures
**Check**: All API calls show request/response in logs
**Look for**: `🌐 API GET Request` and `✅ API GET Response`

## 📱 Platform-Specific Notes

### iOS Development
- Logs appear in Xcode console when using device
- Simulator logs show in terminal
- Network permissions may be required for local development

### Web Development  
- Use browser DevTools for additional debugging
- Network tab shows actual HTTP requests
- Console shows Flutter debug output

## 🎯 Next Steps for New Developers

1. **Run the app** and watch the logs to understand the flow
2. **Try sending a message** and observe the complete request/response cycle
3. **Break something** intentionally to see error handling in action
4. **Add a simple feature** following the layered architecture
5. **Always add proper logging** to any new code

## 📚 Key Files to Understand

**Start Here:**
- `lib/main.dart` - App initialization and global error handling
- `lib/utils/logger.dart` - Logging system
- `lib/services/auth_service.dart` - Authentication flow
- `lib/screens/chat_home_screen.dart` - Main app logic

**API Integration:**
- `lib/api/api_client.dart` - HTTP client setup
- `lib/api/endpoints/chats/chat_endpoints.dart` - Chat API calls
- `lib/api/api_reference.md` - Detailed API documentation

Remember: **When in doubt, check the logs!** The comprehensive logging system will show you exactly what's happening at each step.
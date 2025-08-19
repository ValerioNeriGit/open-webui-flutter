import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'screens/chat_home_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'services/model_service.dart';
import 'utils/colors.dart';
import 'utils/logger.dart';

void main() {
  AppLogger.info('🚀 Starting OpenWebUI Flutter App');
  
  FlutterError.onError = (FlutterErrorDetails details) {
    AppLogger.logError('Flutter Framework Error', details.exception, details.stack);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.logError('Uncaught Platform Error', error, stack);
    return true;
  };

  runApp(const NocoChatApp());
}

class NocoChatApp extends StatelessWidget {
  const NocoChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ModelService()),
      ],
      child: MaterialApp(
        title: 'OpenWebUI',
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: AppColors.accent,
          scaffoldBackgroundColor: AppColors.primaryBackground,
          fontFamily: '-apple-system',
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: AppColors.primaryText),
            bodyMedium: TextStyle(color: AppColors.secondaryText),
            titleLarge: TextStyle(color: AppColors.white),
            headlineSmall: TextStyle(color: AppColors.primaryText),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.primaryBackground,
            elevation: 0,
            titleTextStyle: TextStyle(
              color: AppColors.primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            iconTheme: IconThemeData(
              color: AppColors.lightGrey,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppColors.inputBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.accent,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            hintStyle: const TextStyle(color: AppColors.hintText),
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: AppColors.inputBackground,
          ),
          colorScheme: const ColorScheme.dark(
            primary: AppColors.accent,
            secondary: AppColors.secondaryBackground,
            surface: AppColors.primaryBackground,
            onPrimary: AppColors.white,
            onSecondary: AppColors.white,
            onSurface: AppColors.primaryText,
            error: Colors.red,
            onError: AppColors.white,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
        routes: {
          '/chat': (context) => const ChatHomeScreen(),
          '/login': (context) => const LoginScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkAuthAndLoadModels();
  }

  void _checkAuthAndLoadModels() {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (authService.isAuthenticated) {
      Provider.of<ModelService>(context, listen: false).fetchModels();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    if (authService.isAuthenticated) {
      return const ChatHomeScreen();
    } else {
      return const LoginScreen();
    }
  }
}

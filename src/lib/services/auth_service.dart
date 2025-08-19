import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_client.dart';
import '../api/api_exception.dart' hide AuthException;
import '../api/endpoints/auth/auth_endpoints.dart';
import '../api/endpoints/auth/auth_types.dart';
import '../utils/logger.dart';
import 'auth_exception.dart';


class AuthService extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _serverUrl;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String? get serverUrl => _serverUrl;

  AuthService() {
    AppLogger.info('🔐 Initializing AuthService');
    _loadSession();
  }

  Future<void> _loadSession() async {
    try {
      AppLogger.info('📱 Loading saved user session');
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('user_token');
      final email = prefs.getString('user_email');
      final name = prefs.getString('user_name');
      final id = prefs.getString('user_id');
      var serverUrl = prefs.getString('serverUrl');

      if (serverUrl == null || serverUrl.isEmpty) {
        _serverUrl = 'https://openwebui.valerioneri.com';
        AppLogger.info('🌐 Using default server URL: $_serverUrl');
      } else {
        _serverUrl = serverUrl;
        AppLogger.info('🌐 Using saved server URL: $_serverUrl');
      }

      if (token != null && email != null && name != null && id != null) {
        _user = User(id: id, email: email, name: name, token: token);
        ApiClient.instance.configure(_serverUrl!, token);
        AppLogger.info('✅ User session restored for: $email');
      } else {
        AppLogger.info('ℹ️ No saved user session found');
      }
      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.logError('AuthService._loadSession()', e, stackTrace);
    }
  }

  Future<void> _saveSession() async {
    if (_user == null || _serverUrl == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_token', _user!.token);
    await prefs.setString('user_email', _user!.email);
    await prefs.setString('user_name', _user!.name);
    await prefs.setString('user_id', _user!.id);
    await prefs.setString('serverUrl', _serverUrl!);
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_token');
    await prefs.remove('user_email');
    await prefs.remove('user_name');
    await prefs.remove('user_id');
  }

  Future<void> signIn(String serverUrl, String email, String password) async {
    _setLoading(true);
    try {
      // 1. Sanitize URL
      _serverUrl = _sanitizeUrl(serverUrl);
      AppLogger.info('🔑 Attempting sign in for: $email on $_serverUrl');

      final request = SignInRequest(email: email, password: password);
      final response = await AuthEndpoints.signIn(_serverUrl!, request);
      
      _user = User.fromSignInResponse(response);
      ApiClient.instance.configure(_serverUrl!, response.token);
      await _saveSession();
      AppLogger.info('✅ Sign in successful for: $email');

    } on ApiException catch (e, stackTrace) {
      AppLogger.logError('AuthService.signIn() - API Error', e, stackTrace);
      throw AuthException(_handleApiError(e));
    } catch (error, stackTrace) {
      AppLogger.logError('AuthService.signIn() - Unexpected Error', error, stackTrace);
      throw AuthException('An unexpected error occurred. Please try again.');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      AppLogger.info('👋 Signing out user');
      _user = null;
      await _clearSession();
      notifyListeners();
      AppLogger.info('✅ Sign out completed');
    } catch (e, stackTrace) {
      AppLogger.logError('AuthService.signOut()', e, stackTrace);
    }
  }

  String _sanitizeUrl(String url) {
    if (url.endsWith('/')) {
      return url.substring(0, url.length - 1);
    }
    return url;
  }

  String _handleApiError(ApiException e) {
    switch (e.statusCode) {
      case 400:
        return 'Incorrect email or password. Please check your credentials and try again.';
      case 401:
        return 'Authentication failed. Please check your credentials.';
      case 405:
        return 'Method not allowed. Please check the server URL.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return 'An unknown error occurred (Code: ${e.statusCode}). Please check your connection and server URL.';
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}


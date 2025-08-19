import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../api_exception.dart';
import 'auth_types.dart';

class AuthEndpoints {
  static Future<SignInResponse> signIn(String serverUrl, SignInRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$serverUrl/api/v1/auths/signin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return SignInResponse.fromJson(responseData);
      } else {
        throw AuthException(
          'Sign in failed: ${response.body}', 
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Network error during sign in: $e');
    }
  }
}
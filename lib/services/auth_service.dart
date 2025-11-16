// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
class AuthService {
  // For Flutter Web / Windows desktop use localhost:
  static const String baseUrl = 'http://localhost:4000';
  // If you run Android emulator, change this to: 'http://10.0.2.2:4000';

  static const String _registerPath = '/api/auth/register';
  static const String _loginPath = '/api/auth/login';
  static const String _refreshPath = '/api/auth/refresh';
  static const String _mePath = '/api/users/me';

  /// Register user → throws on error. Stores tokens on success.
  static Future<void> register(
    String email,
    String password, {
    String? name,
  }) async {
    final url = Uri.parse('$baseUrl$_registerPath');

    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'name': name ?? '',
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('Register failed: ${res.body}');
    }

    final decoded = jsonDecode(res.body);
    if (decoded is! Map) {
      throw Exception('Register failed: invalid response format');
    }

    final access = decoded['accessToken'];
    final refresh = decoded['refreshToken'];

    if (access is String && refresh is String) {
      await _storeTokens(access, refresh);
    } else {
      throw Exception('Register failed: missing tokens in response');
    }
  }

  /// Login → throws on error. Stores tokens on success.
  static Future<void> login(
    String email,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl$_loginPath');

    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (res.statusCode != 200) {
      // Try to show backend's error field if present
      try {
        final decoded = jsonDecode(res.body);
        if (decoded is Map && decoded['error'] is String) {
          throw Exception(decoded['error']);
        }
      } catch (_) {
        // ignore parse errors
      }
      throw Exception('Login failed: ${res.body}');
    }

    final decoded = jsonDecode(res.body);
    if (decoded is! Map) {
      throw Exception('Login failed: invalid response format');
    }

    final access = decoded['accessToken'];
    final refresh = decoded['refreshToken'];

    if (access is String && refresh is String) {
      await _storeTokens(access, refresh);
    } else {
      throw Exception('Login failed: missing tokens in response');
    }
  }

  /// Try to refresh access token using stored refresh token.
  /// Returns true if refresh succeeded.
  static Future<bool> tryRefresh() async {
    final prefs = await SharedPreferences.getInstance();
    final refresh = prefs.getString('refreshToken');
    if (refresh == null) return false;

    final url = Uri.parse('$baseUrl$_refreshPath');
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refresh}),
    );

    if (res.statusCode != 200) return false;

    final decoded = jsonDecode(res.body);
    if (decoded is! Map) return false;

    final access = decoded['accessToken'];
    if (access is! String) return false;

    await prefs.setString('accessToken', access);
    return true;
  }

  /// Get current user from /api/users/me. (Optional; for future auto-login)
  static Future<Map<String, dynamic>> getMe() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('accessToken');
    if (token == null) {
      throw Exception('No access token');
    }

    final url = Uri.parse('$baseUrl$_mePath');
    var res = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 401) {
      // try refresh once
      final ok = await tryRefresh();
      if (!ok) throw Exception('Unauthorized');
      token = prefs.getString('accessToken');
      res = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
    }

    if (res.statusCode != 200) {
      throw Exception('getMe failed: ${res.body}');
    }

    final decoded = jsonDecode(res.body);
    if (decoded is! Map) {
      throw Exception('getMe failed: invalid response format');
    }

    // we return a non-null Map; any error throws above
    return Map<String, dynamic>.from(decoded);
  }

  /// Clear tokens (simple logout).
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
  }

  static Future<void> _storeTokens(String access, String refresh) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', access);
    await prefs.setString('refreshToken', refresh);
  }
}

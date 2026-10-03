import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Smart base URL: defaults to localhost for web/desktop, 10.0.2.2 for Android emulator
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:3000/api';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000/api';
    }
    return 'http://localhost:3000/api';
  }

  String? _authToken = 'dev-token';
  String _devUserId = 'usr_demo_777';

  void setAuth({String? token, String? devUserId}) {
    if (token != null) _authToken = token;
    if (devUserId != null) _devUserId = devUserId;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
        'x-dev-user-id': _devUserId,
      };

  // HTTP GET with offline SharedPreferences caching
  Future<dynamic> get(String endpoint, {bool useCache = true}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final cacheKey = 'cache_$endpoint';

    try {
      final response = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 4));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        if (useCache) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(cacheKey, response.body);
        }
        return data;
      }
    } catch (e) {
      debugPrint('API GET $endpoint failed ($e). Attempting offline cache lookup.');
    }

    if (useCache) {
      final prefs = await SharedPreferences.getInstance();
      final cachedStr = prefs.getString(cacheKey);
      if (cachedStr != null) {
        return jsonDecode(cachedStr);
      }
    }

    return null;
  }

  // HTTP POST
  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http
          .post(uri, headers: _headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 6));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('API POST $endpoint error: $e');
    }
    return null;
  }

  // HTTP PATCH
  Future<dynamic> patch(String endpoint, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http
          .patch(uri, headers: _headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 4));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('API PATCH $endpoint error: $e');
    }
    return null;
  }
}

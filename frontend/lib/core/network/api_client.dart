import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}

class ApiClient {
  final http.Client _client;
  String? _token;
  String? _userId;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  String? get currentUserId => _userId;

  void setAuthCredentials({String? token, String? userId}) {
    _token = token;
    _userId = userId;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
        if (_userId != null) 'x-dev-user-id': _userId!,
      };

  Future<dynamic> get(String endpoint, {bool useCache = true}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    final cacheKey = 'cache_$endpoint';

    try {
      final response = await _client.get(uri, headers: _headers).timeout(ApiConstants.connectTimeout);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (useCache) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(cacheKey, response.body);
        }
        return decoded;
      } else {
        throw ApiException('Request failed with code ${response.statusCode}', response.statusCode);
      }
    } catch (e) {
      debugPrint('Network GET $endpoint failed ($e). Attempting local offline cache.');
      if (useCache) {
        final prefs = await SharedPreferences.getInstance();
        final cached = prefs.getString(cacheKey);
        if (cached != null) {
          return jsonDecode(cached);
        }
      }
      rethrow;
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body, {Duration? timeout}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    final response = await _client
        .post(uri, headers: _headers, body: jsonEncode(body))
        .timeout(timeout ?? ApiConstants.connectTimeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    }
    throw ApiException('POST $endpoint failed with status ${response.statusCode}', response.statusCode);
  }

  Future<dynamic> patch(String endpoint, Map<String, dynamic> body) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    final response = await _client
        .patch(uri, headers: _headers, body: jsonEncode(body))
        .timeout(ApiConstants.connectTimeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    }
    throw ApiException('PATCH $endpoint failed with status ${response.statusCode}', response.statusCode);
  }
}

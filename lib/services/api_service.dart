import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Base URL — use 10.0.2.2 for Android emulator (maps to host machine localhost)
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  final Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Map<String, String> _authHeaders(String token) => {
        ..._defaultHeaders,
        'Authorization': 'Bearer $token',
      };

  // ─── Auth ───────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: _defaultHeaders,
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200) return data;
    throw ApiException(data['message'] ?? 'Login failed', response.statusCode);
  }

  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: _defaultHeaders,
      body: jsonEncode({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'password_confirmation': password,
      }),
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 201) return data;
    // Extract validation errors if present
    if (response.statusCode == 422 && data.containsKey('errors')) {
      final errors = data['errors'] as Map<String, dynamic>;
      final firstError = errors.values.first;
      final msg = firstError is List ? firstError.first : firstError.toString();
      throw ApiException(msg, response.statusCode);
    }
    throw ApiException(data['message'] ?? 'Registration failed', response.statusCode);
  }

  Future<void> logout(String token) async {
    await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: _authHeaders(token),
    );
  }

  // ─── Products ────────────────────────────────────────────────────────────────

  Future<List<dynamic>> fetchProducts({String? token}) async {
    final headers = token != null ? _authHeaders(token) : _defaultHeaders;
    final response = await http.get(
      Uri.parse('$baseUrl/products'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }
    throw ApiException('Failed to load products', response.statusCode);
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

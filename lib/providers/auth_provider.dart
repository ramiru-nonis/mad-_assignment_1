import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String _userName = '';
  String _userEmail = '';
  String _token = '';
  String? _errorMessage;

  final _secureStorage = const FlutterSecureStorage();
  final _apiService = ApiService();

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get token => _token;
  String? get errorMessage => _errorMessage;

  /// Call once on app startup to restore session from secure storage.
  Future<void> tryAutoLogin() async {
    final token = await _secureStorage.read(key: 'auth_token');
    final email = await _secureStorage.read(key: 'user_email');
    final name = await _secureStorage.read(key: 'user_name');
    if (token != null && email != null) {
      _token = token;
      _userEmail = email;
      _userName = name ?? email.split('@').first;
      _isLoggedIn = true;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _apiService.login(email, password);
      await _persistSession(data);
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Network error. Please check your connection.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _apiService.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
      );
      await _persistSession(data);
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Network error. Please check your connection.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_token.isNotEmpty) await _apiService.logout(_token);
    } catch (_) {
      // Ignore — still clear local session
    }

    await _secureStorage.deleteAll();
    _isLoggedIn = false;
    _token = '';
    _userName = '';
    _userEmail = '';
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _persistSession(Map<String, dynamic> data) async {
    _token = data['token'] as String;
    final user = data['user'] as Map<String, dynamic>;
    _userEmail = user['email'] as String;
    _userName = '${user['firstName']} ${user['lastName']}';
    _isLoggedIn = true;

    await _secureStorage.write(key: 'auth_token', value: _token);
    await _secureStorage.write(key: 'user_email', value: _userEmail);
    await _secureStorage.write(key: 'user_name', value: _userName);
  }
}

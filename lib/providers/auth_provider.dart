import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String? get error => _error;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.login(email, password);
      _user = User.fromJson(response);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      throw Exception('Login failed: $e');
    }
  }

  Future<void> signup(Map<String, String> userData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.register(userData);
      _user = User.fromJson(response);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      throw Exception('Signup failed: $e');
    }
  }

  Future<void> logout() async {
    await ApiService.deleteToken();
    _user = null;
    notifyListeners();
  }

  void updateUser(User updatedUser) {
    _user = updatedUser;
    notifyListeners();
  }

  Future<void> loadUser() async {
    try {
      final token = await ApiService.getToken();
      if (token != null) {
        // يمكنك إضافة استدعاء API لتحميل بيانات المستخدم هنا
        // final userData = await ApiService.getUserProfile();
        // _user = User.fromJson(userData);
      }
    } catch (e) {
      print('Error loading user: $e');
    }
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
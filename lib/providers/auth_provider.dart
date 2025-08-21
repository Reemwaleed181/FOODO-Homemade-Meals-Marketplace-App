import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/data_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate login - replace with actual authentication
      await Future.delayed(Duration(seconds: 1));

      // Try to find user by email from JSON data
      final dataService = DataService.instance;
      final user = await dataService.getUserByEmail(email);

      if (user != null) {
        _user = user;
      } else {
        // Create a default user if not found in JSON
        _user = User(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: "John Doe",
          email: email,
          phone: "+1234567890",
          address: "123 Main St",
          city: "New York",
          zipCode: "10001",
          role: UserRole.customer,
          isChef: false,
        );
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signup(Map<String, String> userData) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(Duration(seconds: 1));

      _user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: userData['name']!,
        email: userData['email']!,
        phone: userData['phone']!,
        address: userData['address']!,
        city: userData['city']!,
        zipCode: userData['zipCode']!,
        role: UserRole.customer,
        isChef: false,
      );
    } catch (e) {
      throw Exception('Signup failed: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _user = null;
    notifyListeners();
  }

  void updateUser(User updatedUser) {
    _user = updatedUser;
    notifyListeners();
  }

  void toggleChefMode() {
    if (_user == null) return;

    UserRole newRole;
    switch (_user!.role) {
      case UserRole.customer:
        newRole = UserRole.chef;
        break;
      case UserRole.chef:
        newRole = UserRole.customer;
        break;
      case UserRole.both:
        newRole = UserRole.customer;
        break;
    }

    _user = _user!.copyWith(
      role: newRole,
      isChef: newRole == UserRole.chef || newRole == UserRole.both,
    );

    notifyListeners();
  }

  Future<void> loadUser() async {
    // For now, we'll load from JSON data
    // In a real app, you'd load from secure storage
    try {
      final dataService = DataService.instance;
      final users = await dataService.getAllUsers();
      if (users.isNotEmpty) {
        _user = users.first; // Load first user as default
      }
    } catch (e) {
      print('Error loading user: $e');
    }
    notifyListeners();
  }
}

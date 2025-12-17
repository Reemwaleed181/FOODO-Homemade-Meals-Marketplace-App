import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';
  static const String _customerProfileKey = 'customer_profile';
  static const String _chefProfileKey = 'chef_profile';
  static const String _activeProfileKey = 'active_profile'; // 'customer' or 'chef'
  static const String _addressesKey = 'user_addresses';
  static const String _onboardingCompletedKey = 'onboarding_completed';

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDataKey, json.encode(userData));
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(_userDataKey);
    if (userDataString != null) {
      return json.decode(userDataString);
    }
    return null;
  }

  Future<void> deleteUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userDataKey);
  }

  Future<void> saveAddresses(List<Map<String, dynamic>> addresses) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_addressesKey, json.encode(addresses));
  }

  Future<List<Map<String, dynamic>>> getAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final addressesString = prefs.getString(_addressesKey);
    if (addressesString != null) {
      final decoded = json.decode(addressesString);
      if (decoded is List) {
        return decoded.cast<Map<String, dynamic>>();
      }
    }
    return [];
  }

  Future<void> deleteAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_addressesKey);
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompletedKey, completed);
  }

  Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompletedKey) ?? false;
  }

  // Dual profile support
  Future<void> saveCustomerProfile(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_customerProfileKey, json.encode(userData));
  }

  Future<Map<String, dynamic>?> getCustomerProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileString = prefs.getString(_customerProfileKey);
    if (profileString != null) {
      return json.decode(profileString);
    }
    return null;
  }

  Future<void> saveChefProfile(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chefProfileKey, json.encode(userData));
  }

  Future<Map<String, dynamic>?> getChefProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileString = prefs.getString(_chefProfileKey);
    if (profileString != null) {
      return json.decode(profileString);
    }
    return null;
  }

  Future<void> setActiveProfile(String profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeProfileKey, profile); // 'customer' or 'chef'
  }

  Future<String?> getActiveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_activeProfileKey);
  }

  Future<bool> hasBothProfiles() async {
    final customer = await getCustomerProfile();
    final chef = await getChefProfile();
    return customer != null && chef != null;
  }
}

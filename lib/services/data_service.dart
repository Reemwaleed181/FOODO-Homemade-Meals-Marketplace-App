import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/meal.dart';
import '../models/user.dart';

class DataService {
  static DataService? _instance;
  static DataService get instance => _instance ??= DataService._internal();

  DataService._internal();

  // Cache for loaded data
  Map<String, dynamic>? _mealsData;
  Map<String, dynamic>? _usersData;
  Map<String, dynamic>? _appConfig;

  // Load meals data from JSON
  Future<Map<String, dynamic>> loadMealsData() async {
    if (_mealsData != null) return _mealsData!;

    try {
      final String response = await rootBundle.loadString(
        'assets/data/meals.json',
      );
      _mealsData = json.decode(response);
      return _mealsData!;
    } catch (e) {
      print('Error loading meals data: $e');
      return {'meals': [], 'frequentlyOrdered': []};
    }
  }

  // Load users data from JSON
  Future<Map<String, dynamic>> loadUsersData() async {
    if (_usersData != null) return _usersData!;

    try {
      final String response = await rootBundle.loadString(
        'assets/data/users.json',
      );
      _usersData = json.decode(response);
      return _usersData!;
    } catch (e) {
      print('Error loading users data: $e');
      return {'users': []};
    }
  }

  // Load app configuration from JSON
  Future<Map<String, dynamic>> loadAppConfig() async {
    if (_appConfig != null) return _appConfig!;

    try {
      final String response = await rootBundle.loadString(
        'assets/data/app_config.json',
      );
      _appConfig = json.decode(response);
      return _appConfig!;
    } catch (e) {
      print('Error loading app config: $e');
      return {};
    }
  }

  // Get all meals
  Future<List<Meal>> getAllMeals() async {
    final data = await loadMealsData();
    final List<dynamic> mealsList = data['meals'] as List<dynamic>;

    return mealsList.map((mealJson) => Meal.fromJson(mealJson)).toList();
  }

  // Get frequently ordered meals
  Future<List<Meal>> getFrequentlyOrderedMeals() async {
    final data = await loadMealsData();
    final List<dynamic> frequentIdsList =
        data['frequentlyOrdered'] as List<dynamic>;
    final List<String> frequentIds = frequentIdsList.cast<String>();

    final allMeals = await getAllMeals();
    return allMeals.where((meal) => frequentIds.contains(meal.id)).toList();
  }

  // Get meal by ID
  Future<Meal?> getMealById(String mealId) async {
    final allMeals = await getAllMeals();
    try {
      return allMeals.firstWhere((meal) => meal.id == mealId);
    } catch (e) {
      return null;
    }
  }

  // Get all users
  Future<List<User>> getAllUsers() async {
    final data = await loadUsersData();
    final List<dynamic> usersList = data['users'] as List<dynamic>;

    return usersList.map((userJson) => User.fromJson(userJson)).toList();
  }

  // Get user by ID
  Future<User?> getUserById(String userId) async {
    final allUsers = await getAllUsers();
    try {
      return allUsers.firstWhere((user) => user.id == userId);
    } catch (e) {
      return null;
    }
  }

  // Get user by email (for login)
  Future<User?> getUserByEmail(String email) async {
    final allUsers = await getAllUsers();
    try {
      return allUsers.firstWhere(
        (user) => user.email.toLowerCase() == email.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  // Get delivery configuration
  Future<Map<String, dynamic>> getDeliveryConfig() async {
    final config = await loadAppConfig();
    return config['delivery'] as Map<String, dynamic>;
  }

  // Get tax rate
  Future<double> getTaxRate() async {
    final config = await loadAppConfig();
    return (config['tax'] as Map<String, dynamic>)['rate'] as double;
  }

  // Get free delivery threshold
  Future<double> getFreeDeliveryThreshold() async {
    final deliveryConfig = await getDeliveryConfig();
    return deliveryConfig['freeDeliveryThreshold'] as double;
  }

  // Get delivery fee
  Future<double> getDeliveryFee() async {
    final deliveryConfig = await getDeliveryConfig();
    return deliveryConfig['deliveryFee'] as double;
  }

  // Get filters configuration
  Future<List<Map<String, dynamic>>> getFilters() async {
    final config = await loadAppConfig();
    final List<dynamic> filtersList = config['filters'] as List<dynamic>;
    return filtersList.cast<Map<String, dynamic>>();
  }

  // Get categories configuration
  Future<List<Map<String, dynamic>>> getCategories() async {
    final config = await loadAppConfig();
    final List<dynamic> categoriesList = config['categories'] as List<dynamic>;
    return categoriesList.cast<Map<String, dynamic>>();
  }

  // Get payment methods
  Future<List<Map<String, dynamic>>> getPaymentMethods() async {
    final config = await loadAppConfig();
    final List<dynamic> paymentMethodsList =
        config['paymentMethods'] as List<dynamic>;
    return paymentMethodsList.cast<Map<String, dynamic>>();
  }

  // Search meals
  Future<List<Meal>> searchMeals(String query) async {
    final allMeals = await getAllMeals();
    final lowercaseQuery = query.toLowerCase();

    return allMeals.where((meal) {
      return meal.name.toLowerCase().contains(lowercaseQuery) ||
          meal.chef.toLowerCase().contains(lowercaseQuery) ||
          meal.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery)) ||
          meal.description.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Filter meals by dietary preferences
  Future<List<Meal>> filterMealsByDiet(String dietType) async {
    final allMeals = await getAllMeals();

    switch (dietType) {
      case 'vegetarian':
        return allMeals.where((meal) => meal.isVegetarian).toList();
      case 'vegan':
        return allMeals.where((meal) => meal.isVegan).toList();
      case 'gluten-free':
        return allMeals.where((meal) => meal.isGlutenFree).toList();
      default:
        return allMeals;
    }
  }

  // Get meals by chef
  Future<List<Meal>> getMealsByChef(String chefId) async {
    final allMeals = await getAllMeals();
    return allMeals.where((meal) => meal.chefId == chefId).toList();
  }

  // Clear cache (useful for testing or when data needs to be refreshed)
  void clearCache() {
    _mealsData = null;
    _usersData = null;
    _appConfig = null;
  }
}

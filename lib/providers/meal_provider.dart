import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../services/data_service.dart';

class MealProvider extends ChangeNotifier {
  List<Meal> _allMeals = [];
  List<Meal> _featuredMeals = [];
  List<Meal> _communityMeals = [];
  List<Meal> _userMeals = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedFilter = 'all';

  List<Meal> get allMeals => _allMeals;
  List<Meal> get featuredMeals => _featuredMeals;
  List<Meal> get communityMeals => _communityMeals;
  List<Meal> get userMeals => _userMeals;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedFilter => _selectedFilter;

  // Get filtered meals based on search and filter
  List<Meal> get filteredMeals {
    List<Meal> meals = _allMeals;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final lowercaseQuery = _searchQuery.toLowerCase();
      meals = meals.where((meal) {
        return meal.name.toLowerCase().contains(lowercaseQuery) ||
               meal.chef.toLowerCase().contains(lowercaseQuery) ||
               meal.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery)) ||
               meal.description.toLowerCase().contains(lowercaseQuery);
      }).toList();
    }

    // Apply dietary filter
    if (_selectedFilter != 'all') {
      switch (_selectedFilter) {
        case 'vegetarian':
          meals = meals.where((meal) => meal.isVegetarian).toList();
          break;
        case 'vegan':
          meals = meals.where((meal) => meal.isVegan).toList();
          break;
        case 'gluten-free':
          meals = meals.where((meal) => meal.isGlutenFree).toList();
          break;
      }
    }

    return meals;
  }

  // Load all meals from JSON data
  Future<void> loadMeals() async {
    _isLoading = true;
    notifyListeners();

    try {
      final dataService = DataService.instance;
      _allMeals = await dataService.getAllMeals();
      _featuredMeals = await dataService.getFrequentlyOrderedMeals();
      _communityMeals = _allMeals.where((meal) => meal.isActive).toList();
    } catch (e) {
      print('Error loading meals: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get meal by ID
  Meal? getMealById(String mealId) {
    try {
      return _allMeals.firstWhere((meal) => meal.id == mealId);
    } catch (e) {
      return null;
    }
  }

  // Search meals
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Set filter
  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  // Get meals by chef
  List<Meal> getMealsByChef(String chefId) {
    return _allMeals.where((meal) => meal.chefId == chefId).toList();
  }

  // Add user meal (for chefs)
  void addUserMeal(Meal meal) {
    _userMeals.add(meal);
    _allMeals.add(meal);
    notifyListeners();
  }

  // Update user meal
  void updateUserMeal(String mealId, Meal updatedMeal) {
    final allMealsIndex = _allMeals.indexWhere((meal) => meal.id == mealId);
    final userMealsIndex = _userMeals.indexWhere((meal) => meal.id == mealId);

    if (allMealsIndex != -1) {
      _allMeals[allMealsIndex] = updatedMeal;
    }
    if (userMealsIndex != -1) {
      _userMeals[userMealsIndex] = updatedMeal;
    }
    notifyListeners();
  }

  // Delete user meal
  void deleteUserMeal(String mealId) {
    _userMeals.removeWhere((meal) => meal.id == mealId);
    _allMeals.removeWhere((meal) => meal.id == mealId);
    notifyListeners();
  }

  // Get meals by category
  List<Meal> getMealsByCategory(String category) {
    return _allMeals.where((meal) => 
      meal.tags.any((tag) => tag.toLowerCase() == category.toLowerCase())
    ).toList();
  }

  // Get popular meals (by order count)
  List<Meal> getPopularMeals({int limit = 5}) {
    final sortedMeals = List<Meal>.from(_allMeals);
    sortedMeals.sort((a, b) => b.orderCount.compareTo(a.orderCount));
    return sortedMeals.take(limit).toList();
  }

  // Get recently added meals
  List<Meal> getRecentMeals({int limit = 5}) {
    final sortedMeals = List<Meal>.from(_allMeals);
    sortedMeals.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedMeals.take(limit).toList();
  }

  // Clear search and filters
  void clearFilters() {
    _searchQuery = '';
    _selectedFilter = 'all';
    notifyListeners();
  }
}

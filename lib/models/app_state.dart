import 'package:flutter/foundation.dart';
import 'user.dart';
import 'meal.dart';
import 'cart_item.dart';
import '../services/data_service.dart';

class AppState with ChangeNotifier {
  User? _user;
  List<CartItem> _cartItems = [];
  List<Meal> _userMeals = [];
  List<Meal> _allMeals = [];
  List<Meal> _frequentlyOrderedMeals = [];
  String _currentPage = 'welcome';
  String? _selectedMealId;
  bool _isLoading = false;

  User? get user => _user;
  List<CartItem> get cartItems => _cartItems;
  List<Meal> get userMeals => _userMeals;
  List<Meal> get allMeals => _allMeals;
  List<Meal> get frequentlyOrderedMeals => _frequentlyOrderedMeals;
  String get currentPage => _currentPage;
  String? get selectedMealId => _selectedMealId;
  bool get isLoading => _isLoading;

  void navigateTo(String page, {String? mealId}) {
    _selectedMealId = mealId;
    _currentPage = page;
    notifyListeners();
  }

  void login(User userData) {
    _user = userData;
    _currentPage = 'home';
    _loadMealsData();
    notifyListeners();
  }

  // Public: Load initial data from JSON
  Future<void> loadInitialData() async {
    await _loadMealsData();
  }

  // Load meals data from JSON
  Future<void> _loadMealsData() async {
    _isLoading = true;
    // Use microtask to avoid calling notifyListeners during build
    Future.microtask(() => notifyListeners());

    try {
      final dataService = DataService.instance;
      _allMeals = await dataService.getAllMeals();
      _frequentlyOrderedMeals = await dataService.getFrequentlyOrderedMeals();
    } catch (e) {
      print('Error loading meals data: $e');
    }

    _isLoading = false;
    // Use microtask to avoid calling notifyListeners during build
    Future.microtask(() => notifyListeners());
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
  List<Meal> searchMeals(String query) {
    if (query.isEmpty) return _allMeals;

    final lowercaseQuery = query.toLowerCase();
    return _allMeals.where((meal) {
      return meal.name.toLowerCase().contains(lowercaseQuery) ||
          meal.chef.toLowerCase().contains(lowercaseQuery) ||
          meal.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  // Filter meals by diet
  List<Meal> filterMealsByDiet(String dietType) {
    switch (dietType) {
      case 'vegetarian':
        return _allMeals.where((meal) => meal.isVegetarian).toList();
      case 'vegan':
        return _allMeals.where((meal) => meal.isVegan).toList();
      case 'gluten-free':
        return _allMeals.where((meal) => meal.isGlutenFree).toList();
      default:
        return _allMeals;
    }
  }

  void logout() {
    _user = null;
    _cartItems = [];
    _currentPage = 'welcome';
    notifyListeners();
  }

  void updateUser(User updatedUser) {
    _user = updatedUser;
    notifyListeners();
  }

  void addToCart(CartItem newItem) {
    final existingIndex = _cartItems.indexWhere(
      (item) => item.mealId == newItem.mealId,
    );

    if (existingIndex != -1) {
      _cartItems[existingIndex] = _cartItems[existingIndex].copyWith(
        quantity: _cartItems[existingIndex].quantity + newItem.quantity,
      );
    } else {
      _cartItems.add(newItem);
    }
    notifyListeners();
  }

  void updateCartItem(String itemId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(itemId);
      return;
    }

    final index = _cartItems.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      _cartItems[index] = _cartItems[index].copyWith(quantity: quantity);
      notifyListeners();
    }
  }

  void removeFromCart(String itemId) {
    _cartItems.removeWhere((item) => item.id == itemId);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  double get cartTotal {
    return _cartItems.fold(
      0.0,
      (total, item) => total + (item.price * item.quantity),
    );
  }

  int get cartItemCount {
    return _cartItems.fold(0, (total, item) => total + item.quantity);
  }

  void addUserMeal(Meal meal) {
    _userMeals.add(meal);
    notifyListeners();
  }

  void updateUserMeal(String mealId, Meal updatedMeal) {
    final index = _userMeals.indexWhere((meal) => meal.id == mealId);
    if (index != -1) {
      _userMeals[index] = updatedMeal;
      notifyListeners();
    }
  }

  void deleteUserMeal(String mealId) {
    _userMeals.removeWhere((meal) => meal.id == mealId);
    notifyListeners();
  }

  void toggleChefMode() {
    if (_user != null) {
      final newRole =
          _user!.role == UserRole.customer
              ? UserRole.chef
              : _user!.role == UserRole.chef
              ? UserRole.customer
              : UserRole.both;

      _user = _user!.copyWith(
        role: newRole,
        isChef: newRole == UserRole.chef || newRole == UserRole.both,
      );
      notifyListeners();
    }
  }
}

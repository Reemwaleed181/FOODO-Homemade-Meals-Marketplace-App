import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/meal.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];

  List<CartItem> get items => _items;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  double get total => _items.fold(0, (sum, item) => sum + item.totalPrice);

  void addToCart(Meal meal, int quantity) {
    final existingIndex = _items.indexWhere((item) => item.mealId == meal.id);
    
    if (existingIndex >= 0) {
      _items[existingIndex] = _items[existingIndex].copyWith(
        quantity: _items[existingIndex].quantity + quantity,
      );
    } else {
      _items.add(CartItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        mealId: meal.id,
        name: meal.name,
        chef: meal.chef,
        price: meal.price,
        image: meal.image,
        quantity: quantity,
        portionSize: meal.portionSize,
      ));
    }
    notifyListeners();
  }

  void updateQuantity(String itemId, int quantity) {
    if (quantity <= 0) {
      removeItem(itemId);
      return;
    }

    final index = _items.indexWhere((item) => item.id == itemId);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(quantity: quantity);
      notifyListeners();
    }
  }

  void removeItem(String itemId) {
    _items.removeWhere((item) => item.id == itemId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // Check if cart is empty
  bool get isEmpty => _items.isEmpty;

  // Get cart item by ID
  CartItem? getItemById(String itemId) {
    try {
      return _items.firstWhere((item) => item.id == itemId);
    } catch (e) {
      return null;
    }
  }

  // Get cart item by meal ID
  CartItem? getItemByMealId(String mealId) {
    try {
      return _items.firstWhere((item) => item.mealId == mealId);
    } catch (e) {
      return null;
    }
  }
}

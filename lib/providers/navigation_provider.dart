import 'package:flutter/material.dart';

enum AppPage {
  welcome,
  login,
  signup,
  home,
  mealDetail,
  profile,
  delivery,
  payment,
  cart,
  checkout,
  orderConfirmation,
  sellMeal,
  chefDashboard,
}

class NavigationProvider extends ChangeNotifier {
  AppPage _currentPage = AppPage.welcome;
  String? _selectedMealId;

  AppPage get currentPage => _currentPage;
  String? get selectedMealId => _selectedMealId;

  void navigateTo(AppPage page, {String? mealId}) {
    _currentPage = page;
    if (mealId != null) {
      _selectedMealId = mealId;
    }
    notifyListeners();
  }

  void navigateBack() {
    // Implement back navigation logic based on current page
    switch (_currentPage) {
      case AppPage.login:
      case AppPage.signup:
        _currentPage = AppPage.welcome;
        break;
      case AppPage.mealDetail:
      case AppPage.profile:
      case AppPage.delivery:
      case AppPage.payment:
      case AppPage.cart:
      case AppPage.sellMeal:
      case AppPage.chefDashboard:
        _currentPage = AppPage.home;
        break;
      case AppPage.checkout:
        _currentPage = AppPage.cart;
        break;
      default:
        _currentPage = AppPage.home;
    }
    notifyListeners();
  }
}

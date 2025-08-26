import 'package:flutter/foundation.dart';

enum AppPage {
  welcome,
  login,
  signup,
  verification,
  forgotPassword,
  resetPassword,
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

class NavigationProvider with ChangeNotifier {
  AppPage _currentPage = AppPage.welcome;
  Map<String, dynamic> _pageData = {};

  AppPage get currentPage => _currentPage;
  Map<String, dynamic> get pageData => _pageData;
  String? get selectedMealId => _pageData['mealId'];

  void navigateTo(AppPage page, {Map<String, dynamic>? data}) {
    _currentPage = page;
    _pageData = data ?? {};
    // Use microtask to avoid calling notifyListeners during build
    Future.microtask(() => notifyListeners());
  }

  void goBack() {
    if (_currentPage != AppPage.welcome) {
      navigateTo(AppPage.welcome);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/meal_provider.dart';
import '../models/user.dart';
import '../widgets/bottom_navigation.dart';
import 'welcome_screen.dart';
import 'home/home_screen.dart';
import 'home/meal_detail_screen.dart';
import 'profile/profile_screen.dart';
import 'cart/cart_screen.dart';
import 'cart/checkout_screen.dart';
import 'cart/order_confirmation_screen.dart';

class AppShell extends StatefulWidget {
  @override
  _AppShellState createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  @override
  void initState() {
    super.initState();
    // Load user data and meals on app start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().loadUser();
      context.read<MealProvider>().loadMeals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<NavigationProvider, AuthProvider>(
      builder: (context, navigationProvider, authProvider, child) {
        final currentPage = navigationProvider.currentPage;
        final user = authProvider.user;

        return Scaffold(
          body: _buildCurrentScreen(currentPage, user),
          bottomNavigationBar:
              _shouldShowBottomNav(currentPage, user)
                  ? BottomNavigation()
                  : null,
        );
      },
    );
  }

  Widget _buildCurrentScreen(AppPage currentPage, User? user) {
    switch (currentPage) {
      case AppPage.welcome:
        return WelcomeScreen();
      case AppPage.login:
        return _buildLoginScreen();
      case AppPage.signup:
        return _buildSignupScreen();
      case AppPage.home:
        return HomeScreen();
      case AppPage.mealDetail:
        return MealDetailScreen();
      case AppPage.profile:
        return ProfileScreen();
      case AppPage.delivery:
        return _buildDeliveryScreen();
      case AppPage.payment:
        return _buildPaymentScreen();
      case AppPage.cart:
        return CartScreen();
      case AppPage.checkout:
        return CheckoutScreen();
      case AppPage.sellMeal:
        return _buildSellMealScreen();
      case AppPage.chefDashboard:
        return _buildChefDashboardScreen();
      default:
        return WelcomeScreen();
    }
  }

  bool _shouldShowBottomNav(AppPage currentPage, User? user) {
    if (user == null) return false;
    return ![
      AppPage.welcome,
      AppPage.login,
      AppPage.signup,
      AppPage.checkout,
      AppPage.orderConfirmation,
    ].contains(currentPage);
  }

  // Placeholder screens - these will be implemented later
  Widget _buildLoginScreen() {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Login Screen - Coming Soon'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Simulate login
                context.read<AuthProvider>().login(
                  'test@email.com',
                  'password',
                );
                context.read<NavigationProvider>().navigateTo(AppPage.home);
              },
              child: Text('Login as Test User'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignupScreen() {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Sign Up Screen - Coming Soon'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<NavigationProvider>().navigateTo(AppPage.login);
              },
              child: Text('Back to Login'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryScreen() {
    return Scaffold(
      appBar: AppBar(title: Text('Delivery')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Delivery Screen - Coming Soon'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<NavigationProvider>().navigateTo(AppPage.home);
              },
              child: Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentScreen() {
    return Scaffold(
      appBar: AppBar(title: Text('Payment')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Payment Screen - Coming Soon'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<NavigationProvider>().navigateTo(AppPage.home);
              },
              child: Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSellMealScreen() {
    return Scaffold(
      appBar: AppBar(title: Text('Sell Meal')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Sell Meal Screen - Coming Soon'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<NavigationProvider>().navigateTo(AppPage.home);
              },
              child: Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChefDashboardScreen() {
    return Scaffold(
      appBar: AppBar(title: Text('Chef Dashboard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Chef Dashboard - Coming Soon'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<NavigationProvider>().navigateTo(AppPage.home);
              },
              child: Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/meal_provider.dart';
import '../models/user.dart';
import '../widgets/bottom_navigation.dart';
import 'welcome_screen.dart';
import 'auth/login_screen.dart';
import 'auth/signup_screen.dart';
import 'auth/verification_screen.dart';
import 'home/home_screen.dart';
import 'home/meal_detail_screen.dart';
import 'cart/cart_screen.dart';
import 'cart/checkout_screen.dart';
import 'cart/order_confirmation_screen.dart';
import 'profile/profile_screen.dart';
import 'profile/delivery_screen.dart';
import 'profile/payment_screen.dart';
import 'chef/sell_meal_screen.dart';
import 'chef/chef_dashboard_screen.dart';
import '../models/app_state.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  _AppShellState createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAppData();
    });
  }

  void _initializeAppData() {
    final authProvider = context.read<AuthProvider>();
    final mealProvider = context.read<MealProvider>();
    final appState = context.read<AppState>();

    authProvider.loadUser();
    mealProvider.loadMeals();
    appState.loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<NavigationProvider, AuthProvider>(
      builder: (context, navigationProvider, authProvider, child) {
        final currentPage = navigationProvider.currentPage;
        final pageData = navigationProvider.pageData;
        final user = authProvider.user;

        return Scaffold(
          body: _buildCurrentScreen(currentPage, pageData),
          bottomNavigationBar:
              _shouldShowBottomNav(currentPage, user)
                  ? const BottomNavigation()
                  : null,
        );
      },
    );
  }

  Widget _buildCurrentScreen(
    AppPage currentPage,
    Map<String, dynamic> pageData,
  ) {
    switch (currentPage) {
      case AppPage.welcome:
        return WelcomeScreen();
      case AppPage.login:
        return LoginScreen();
      case AppPage.signup:
        return SignupScreen();
      case AppPage.verification:
        return VerificationScreen();
      case AppPage.home:
        return HomeScreen();
      case AppPage.mealDetail:
        return MealDetailScreen();
      case AppPage.profile:
        return ProfileScreen();
      case AppPage.delivery:
        return DeliveryScreen();
      case AppPage.payment:
        return PaymentScreen();
      case AppPage.cart:
        return CartScreen();
      case AppPage.checkout:
        return CheckoutScreen();
      case AppPage.orderConfirmation:
        return OrderConfirmationScreen();
      case AppPage.sellMeal:
        return SellMealScreen();
      case AppPage.chefDashboard:
        return ChefDashboardScreen();
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
      AppPage.verification,
      AppPage.checkout,
      AppPage.orderConfirmation,
    ].contains(currentPage);
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/meal_provider.dart';
import '../providers/address_provider.dart';
import '../models/user.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/modern_drawer.dart';
import '../services/storage_service.dart';
import 'auth/auth_selection_screen.dart';
import 'auth/profile_selection_screen.dart';
import 'auth/login_screen.dart';
import 'auth/signup_screen.dart';
import 'auth/verification_screen.dart';
import 'auth/password/forgot_password_screen.dart';
import 'auth/password/reset_password_screen.dart';

import 'customer/home/home_screen.dart';
import 'customer/home/meal_detail_screen.dart';
import 'customer/cart/cart_screen.dart';
import 'customer/cart/checkout_screen.dart';
import 'customer/cart/order_confirmation_screen.dart';
import 'customer/profile/profile_screen.dart';
import 'customer/profile/delivery_screen.dart';
import 'customer/profile/payment_screen.dart';
import 'chef/sell_meal_screen.dart';
import 'chef/chef_dashboard_screen.dart';
import 'onboarding_screen.dart';
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
    _initializeAppData();
  }

  void _initializeAppData() {
    // Use microtask to avoid calling providers during build
    Future.microtask(() async {
      final authProvider = context.read<AuthProvider>();
      final mealProvider = context.read<MealProvider>();
      final addressProvider = context.read<AddressProvider>();
      final appState = context.read<AppState>();
      final navigationProvider = context.read<NavigationProvider>();
      final storageService = StorageService();

      // Check if onboarding has been completed
      final onboardingCompleted = await storageService.isOnboardingCompleted();
      if (!onboardingCompleted) {
        navigationProvider.navigateTo(AppPage.onboarding);
        return;
      }

      // Load user first - this will automatically navigate to home if user is logged in
      await authProvider.loadUser();

      // Sync AppState with AuthProvider user
      if (authProvider.user != null && appState.user == null) {
        appState.login(authProvider.user!);
      }

      // Load addresses
      await addressProvider.loadAddresses();

      mealProvider.loadMeals();
      appState.loadInitialData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, child) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final currentPage = navigationProvider.currentPage;
        final pageData = navigationProvider.pageData;
        final user = authProvider.user;

        return Scaffold(
          endDrawer: user != null ? const ModernDrawer() : null,
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
      case AppPage.onboarding:
        return const OnboardingScreen();
      case AppPage.authSelection:
        return const AuthSelectionScreen();
      case AppPage.login:
        return LoginScreen();
      case AppPage.signup:
        return SignupScreen(initialData: pageData);
      case AppPage.verification:
        return VerificationScreen(
          email:
              pageData['email'] ??
              context.read<AuthProvider>().user?.email ??
              '',
          token: pageData['token'],
        );
      case AppPage.forgotPassword:
        return ForgotPasswordScreen();
      case AppPage.resetPassword:
        return ResetPasswordScreen(
          email: pageData['email'] ?? '',
          otpCode: pageData['otpCode'] ?? '',
        );
      case AppPage.profileSelection:
        return const ProfileSelectionScreen();

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
    }
  }

  bool _shouldShowBottomNav(AppPage currentPage, User? user) {
    if (user == null) return false;

    return ![
      AppPage.onboarding,
      AppPage.authSelection,
      AppPage.login,
      AppPage.signup,
      AppPage.verification,
      AppPage.forgotPassword,
      AppPage.resetPassword,
      AppPage.checkout,
      AppPage.orderConfirmation,
    ].contains(currentPage);
  }
}

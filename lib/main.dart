import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/meal_provider.dart';
import 'providers/cart_provider.dart';
import 'models/app_state.dart';
import 'services/api_service.dart';
import 'services/storage_service.dart';
import 'screens/app_shell.dart';
import 'config/app_config.dart';
import 'theme/app_colors.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ApiService apiService = ApiService(baseUrl: AppConfig.djangoBaseUrl);
  final StorageService storageService = StorageService();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(
          create: (context) => AuthProvider(
            apiService: apiService,
            storageService: storageService,
            navigationProvider: context.read<NavigationProvider>(),
          ),
        ),

        ChangeNotifierProvider(create: (_) => MealProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: MaterialApp(
        title: 'Foodo App',
        theme: ThemeData(
          primarySwatch: Colors.teal,
          primaryColor: AppColors.primary,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
            secondary: AppColors.secondary,
            surface: AppColors.surface,
            background: AppColors.backgroundPrimary,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: AppColors.textPrimary,
            onBackground: AppColors.textPrimary,
          ),
          useMaterial3: true,
        ),
        home: AppShell(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

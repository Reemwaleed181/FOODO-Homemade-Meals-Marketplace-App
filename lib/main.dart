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
          create:
              (context) => AuthProvider(
                apiService: apiService,
                storageService: storageService,
                navigationProvider: Provider.of<NavigationProvider>(
                  context,
                  listen: false,
                ),
              ),
        ),
        ChangeNotifierProvider(create: (_) => MealProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: MaterialApp(
        title: 'Foodo App',
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        home: AppShell(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

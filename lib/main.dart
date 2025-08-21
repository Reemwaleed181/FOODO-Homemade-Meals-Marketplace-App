import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/meal_provider.dart';
import 'providers/navigation_provider.dart';
import 'screens/app_shell.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => MealProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ],
      child: MaterialApp(
        title: 'HomeCook',
        theme: ThemeData(
          primaryColor: Color(0xFFFF6B35),
          scaffoldBackgroundColor: Colors.white,
          fontFamily: 'Inter',
          colorScheme: ColorScheme.fromSeed(
            seedColor: Color(0xFFFF6B35),
            brightness: Brightness.light,
          ),
        ),
        home: AppShell(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

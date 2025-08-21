import 'package:flutter/material.dart';
import 'package:foodo/screens/auth/login_screen.dart';
import 'package:foodo/screens/auth/signup_screen.dart';
import 'package:foodo/screens/home/home_screen.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';

import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'HomeCook App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: FutureBuilder<bool>(
          future: _checkLoginStatus(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(body: Center(child: CircularProgressIndicator()));
            } else {
              return snapshot.data == true ? HomeScreen() : LoginScreen();
            }
          },
        ),
        routes: {
          '/login': (context) => LoginScreen(),
          '/signup': (context) => SignupScreen(),
          '/home': (context) => HomeScreen(),
        },
      ),
    );
  }

  Future<bool> _checkLoginStatus() async {
    final token = await ApiService.getToken();
    return token != null;
  }
}
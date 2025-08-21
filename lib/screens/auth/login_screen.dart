import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_state.dart';
import '../../models/user.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(Duration(seconds: 1));

    final user = User(
      id: '1',
      name: 'Jane Doe',
      email: _emailController.text,
      phone: '+1-555-0123',
      address: '123 Main Street',
      city: 'New York',
      zipCode: '10001',
      role: UserRole.customer,
      isChef: false,
    );

    Provider.of<AppState>(context, listen: false).login(user);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF8F2), Color(0xFFFFF0F0)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'HomeCook',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('Welcome back! Sign in to your account'),
                  SizedBox(height: 32),

                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Text('Sign In', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          SizedBox(height: 16),

                          CustomInput(
                            controller: _emailController,
                            hintText: 'Enter your email',
                            keyboardType: TextInputType.emailAddress,
                          ),
                          SizedBox(height: 16),

                          CustomInput(
                            controller: _passwordController,
                            hintText: 'Enter your password',
                            obscureText: true,
                          ),
                          SizedBox(height: 24),

                          CustomButton(
                            text: _isLoading ? 'Signing In...' : 'Sign In',
                            onPressed: _isLoading ? null : _login,
                          ),

                          SizedBox(height: 24),
                          TextButton(
                            onPressed: () => appState.navigateTo('signup'),
                            child: Text('Don\'t have an account? Sign up'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
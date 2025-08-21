import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/navigation_provider.dart';
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

    try {
      await context.read<AuthProvider>().login(
        _emailController.text,
        _passwordController.text,
      );

      context.read<NavigationProvider>().navigateTo(AppPage.home);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  // Brand
                  Text(
                    'HomeCook',
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('Welcome back! Sign in to your account'),
                  SizedBox(height: 24),

                  // Card
                  Container(
                    constraints: BoxConstraints(maxWidth: 480),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16),

                            CustomInput(
                              controller: _emailController,
                              label: 'Email',
                              hintText: 'name@email.com',
                              keyboardType: TextInputType.emailAddress,
                            ),
                            SizedBox(height: 16),

                            CustomInput(
                              controller: _passwordController,
                              label: 'Password',
                              hintText: '••••••••',
                              obscureText: true,
                            ),
                            SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {},
                                child: Text('Forgot password?'),
                              ),
                            ),
                            SizedBox(height: 8),

                            SizedBox(
                              width: double.infinity,
                              child: CustomButton(
                                text: _isLoading ? 'Signing In...' : 'Sign In',
                                onPressed: _isLoading ? null : _login,
                                size: ButtonSize.large,
                              ),
                            ),

                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Don\'t have an account?'),
                                TextButton(
                                  onPressed:
                                      () => context
                                          .read<NavigationProvider>()
                                          .navigateTo(AppPage.signup),
                                  child: Text('Create one'),
                                ),
                              ],
                            ),
                          ],
                        ),
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

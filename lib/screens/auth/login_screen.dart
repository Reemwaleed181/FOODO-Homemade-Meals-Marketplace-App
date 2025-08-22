import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../widgets/custom_button.dart';
import '../../theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String _errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final auth = context.read<AuthProvider>();
      await auth.login(_emailController.text.trim(), _passwordController.text);

      // Navigation is handled by AuthProvider
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/food_background.jpg'),
                fit: BoxFit.cover,
                onError: (exception, stackTrace) {
                  // Fallback to gradient if image fails to load
                },
              ),
              // Fallback gradient background
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.foodOrange.withOpacity(0.8),
                  AppColors.foodRed.withOpacity(0.6),
                  AppColors.foodPurple.withOpacity(0.4),
                ],
              ),
            ),
          ),

          // Curved White Container
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.65,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowMedium,
                    blurRadius: 24,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Welcome Header
                    _buildWelcomeHeader(),

                    const SizedBox(height: 40),

                    // Login Form
                    _buildLoginForm(),

                    const SizedBox(height: 30),

                    // Navigation Links
                    _buildNavigationLinks(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Column(
      children: [
        // App Title with Creative Typography
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Welcome to ',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              TextSpan(
                text: 'HomeCook',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 12),

        Text(
          'Sign in to continue your culinary journey',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Form Title
          Text(
            'Sign In',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Email Field
          _buildInputField(
            controller: _emailController,
            label: 'Email Address',
            hint: 'Enter your email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email is required';
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),

          const SizedBox(height: 24),

          // Password Field
          _buildInputField(
            controller: _passwordController,
            label: 'Password',
            hint: 'Enter your password',
            icon: Icons.lock_outlined,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: AppColors.textSecondary,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password is required';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Forgot Password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // TODO: Implement forgot password
              },
              child: Text(
                'Forgot Password?',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Error Message
          if (_errorMessage.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
              child: Text(
                _errorMessage,
                style: TextStyle(color: AppColors.error, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),

          const SizedBox(height: 24),

          // Login Button
          CustomButton(
            text: _isLoading ? 'Signing In...' : 'Sign In',
            onPressed: _isLoading ? null : _submitForm,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.textSecondary),
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.borderPrimary),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.inputFocus, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.borderPrimary),
            ),
            filled: true,
            fillColor: AppColors.inputBackground,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationLinks() {
    return Column(
      children: [
        TextButton(
          onPressed: () {
            context.read<NavigationProvider>().navigateTo(AppPage.signup);
          },
          child: RichText(
            text: TextSpan(
              text: "Don't have an account? ",
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              children: [
                TextSpan(
                  text: 'Sign Up',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        TextButton(
          onPressed: () {
            context.read<NavigationProvider>().navigateTo(AppPage.welcome);
          },
          child: Text(
            '← Back to Home',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
        ),
      ],
    );
  }
}

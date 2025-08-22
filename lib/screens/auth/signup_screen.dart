import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../widgets/custom_button.dart';
import '../../theme/app_colors.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _errorMessage = '';
  Map<String, String> _errors = {};

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipCodeController.dispose();
    super.dispose();
  }

  void _handleInputChange(String field, String value) {
    if (_errors.containsKey(field)) {
      setState(() {
        _errors.remove(field);
      });
    }
  }

  bool _validateForm() {
    final newErrors = <String, String>{};

    if (_nameController.text.trim().isEmpty)
      newErrors['name'] = 'Name is required';
    if (_emailController.text.trim().isEmpty)
      newErrors['email'] = 'Email is required';
    if (_phoneController.text.trim().isEmpty)
      newErrors['phone'] = 'Phone number is required';
    if (_passwordController.text.isEmpty)
      newErrors['password'] = 'Password is required';
    if (_passwordController.text.length < 6)
      newErrors['password'] = 'Password must be at least 6 characters';
    if (_passwordController.text != _confirmPasswordController.text) {
      newErrors['confirmPassword'] = 'Passwords do not match';
    }
    if (_addressController.text.trim().isEmpty)
      newErrors['address'] = 'Address is required';
    if (_cityController.text.trim().isEmpty)
      newErrors['city'] = 'City is required';
    if (_zipCodeController.text.trim().isEmpty)
      newErrors['zipCode'] = 'ZIP code is required';

    setState(() => _errors = newErrors);
    return newErrors.isEmpty;
  }

  Future<void> _submitForm() async {
    if (!_validateForm()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final auth = context.read<AuthProvider>();
      await auth.register(
        _nameController.text,
        _emailController.text,
        _passwordController.text,
      );

      // After successful registration, navigate to verification screen
      // The navigation is handled by the AuthProvider
    } catch (error) {
      setState(() {
        _errors['general'] = 'Signup failed. Please try again.';
      });
    } finally {
      setState(() => _isLoading = false);
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
                image: AssetImage('assets/images/food_background_2.jpg'),
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
                  AppColors.foodGreen.withOpacity(0.8),
                  AppColors.foodOrange.withOpacity(0.6),
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
              height: MediaQuery.of(context).size.height * 0.75,
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

                    // Signup Form
                    _buildSignupForm(),

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
                text: 'Join ',
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
          'Create your account and start cooking',
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

  Widget _buildSignupForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Form Title
          Text(
            'Create Account',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Name Field
          _buildInputField(
            controller: _nameController,
            label: 'Full Name',
            hint: 'Enter your full name',
            icon: Icons.person_outline,
            onChanged: (value) => _handleInputChange('name', value),
            error: _errors['name'],
          ),

          const SizedBox(height: 20),

          // Email Field
          _buildInputField(
            controller: _emailController,
            label: 'Email Address',
            hint: 'Enter your email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) => _handleInputChange('email', value),
            error: _errors['email'],
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

          const SizedBox(height: 20),

          // Phone Field
          _buildInputField(
            controller: _phoneController,
            label: 'Phone Number',
            hint: 'Enter your phone number',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            onChanged: (value) => _handleInputChange('phone', value),
            error: _errors['phone'],
          ),

          const SizedBox(height: 20),

          // Password Field
          _buildInputField(
            controller: _passwordController,
            label: 'Password',
            hint: 'Create a password',
            icon: Icons.lock_outlined,
            obscureText: _obscurePassword,
            onChanged: (value) => _handleInputChange('password', value),
            error: _errors['password'],
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
          ),

          const SizedBox(height: 20),

          // Confirm Password Field
          _buildInputField(
            controller: _confirmPasswordController,
            label: 'Confirm Password',
            hint: 'Confirm your password',
            icon: Icons.lock_outlined,
            obscureText: _obscureConfirmPassword,
            onChanged: (value) => _handleInputChange('confirmPassword', value),
            error: _errors['confirmPassword'],
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: AppColors.textSecondary,
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
          ),

          const SizedBox(height: 20),

          // Address Field
          _buildInputField(
            controller: _addressController,
            label: 'Address',
            hint: 'Enter your address',
            icon: Icons.home_outlined,
            onChanged: (value) => _handleInputChange('address', value),
            error: _errors['address'],
          ),

          const SizedBox(height: 20),

          // City and ZIP Code Row
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  controller: _cityController,
                  label: 'City',
                  hint: 'Enter your city',
                  icon: Icons.location_city_outlined,
                  onChanged: (value) => _handleInputChange('city', value),
                  error: _errors['city'],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInputField(
                  controller: _zipCodeController,
                  label: 'ZIP Code',
                  hint: 'Enter ZIP code',
                  icon: Icons.pin_drop_outlined,
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _handleInputChange('zipCode', value),
                  error: _errors['zipCode'],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // General Error Message
          if (_errors.containsKey('general'))
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
              child: Text(
                _errors['general']!,
                style: TextStyle(color: AppColors.error, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),

          const SizedBox(height: 24),

          // Signup Button
          CustomButton(
            text: _isLoading ? 'Creating Account...' : 'Create Account',
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
    String? error,
    ValueChanged<String>? onChanged,
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
          onChanged: onChanged,
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.inputError, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.inputError, width: 2),
            ),
            filled: true,
            fillColor: AppColors.inputBackground,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 8),
          Text(error, style: TextStyle(color: AppColors.error, fontSize: 12)),
        ],
      ],
    );
  }

  Widget _buildNavigationLinks() {
    return Column(
      children: [
        TextButton(
          onPressed: () {
            context.read<NavigationProvider>().navigateTo(AppPage.login);
          },
          child: RichText(
            text: TextSpan(
              text: 'Already have an account? ',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              children: [
                TextSpan(
                  text: 'Sign In',
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

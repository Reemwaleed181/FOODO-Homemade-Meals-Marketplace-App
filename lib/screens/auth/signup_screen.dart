import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
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

  bool _isLoading = false;
  Map<String, String> _errors = {};

  void _handleInputChange(String field, String value) {
    if (_errors.containsKey(field)) {
      setState(() => _errors.remove(field));
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

  void _submitForm() async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);

    try {
      await context.read<AuthProvider>().signup({
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'city': _cityController.text,
        'zipCode': _zipCodeController.text,
      });
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
            colors: [Color(0xFFFFF8F2), Color(0xFFFFF0F0)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'HomeCook',
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('Join our community of food lovers'),
                SizedBox(height: 24),

                Container(
                  constraints: BoxConstraints(maxWidth: 720),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),

                          CustomInput(
                            controller: _nameController,
                            label: 'Full Name',
                            onChanged:
                                (value) => _handleInputChange('name', value),
                          ),
                          if (_errors.containsKey('name'))
                            Text(
                              _errors['name']!,
                              style: TextStyle(color: Colors.red),
                            ),

                          SizedBox(height: 16),
                          CustomInput(
                            controller: _emailController,
                            label: 'Email',
                            keyboardType: TextInputType.emailAddress,
                            onChanged:
                                (value) => _handleInputChange('email', value),
                          ),
                          if (_errors.containsKey('email'))
                            Text(
                              _errors['email']!,
                              style: TextStyle(color: Colors.red),
                            ),

                          SizedBox(height: 16),
                          CustomInput(
                            controller: _phoneController,
                            label: 'Phone Number',
                            keyboardType: TextInputType.phone,
                            onChanged:
                                (value) => _handleInputChange('phone', value),
                          ),
                          if (_errors.containsKey('phone'))
                            Text(
                              _errors['phone']!,
                              style: TextStyle(color: Colors.red),
                            ),

                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: CustomInput(
                                  controller: _passwordController,
                                  label: 'Password',
                                  obscureText: true,
                                  onChanged:
                                      (value) =>
                                          _handleInputChange('password', value),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: CustomInput(
                                  controller: _confirmPasswordController,
                                  label: 'Confirm Password',
                                  obscureText: true,
                                  onChanged:
                                      (value) => _handleInputChange(
                                        'confirmPassword',
                                        value,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          if (_errors.containsKey('password'))
                            Text(
                              _errors['password']!,
                              style: TextStyle(color: Colors.red),
                            ),
                          if (_errors.containsKey('confirmPassword'))
                            Text(
                              _errors['confirmPassword']!,
                              style: TextStyle(color: Colors.red),
                            ),

                          SizedBox(height: 16),
                          CustomInput(
                            controller: _addressController,
                            label: 'Address',
                            onChanged:
                                (value) => _handleInputChange('address', value),
                          ),
                          if (_errors.containsKey('address'))
                            Text(
                              _errors['address']!,
                              style: TextStyle(color: Colors.red),
                            ),

                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: CustomInput(
                                  controller: _cityController,
                                  label: 'City',
                                  onChanged:
                                      (value) =>
                                          _handleInputChange('city', value),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: CustomInput(
                                  controller: _zipCodeController,
                                  label: 'ZIP Code',
                                  onChanged:
                                      (value) =>
                                          _handleInputChange('zipCode', value),
                                ),
                              ),
                            ],
                          ),
                          if (_errors.containsKey('city'))
                            Text(
                              _errors['city']!,
                              style: TextStyle(color: Colors.red),
                            ),
                          if (_errors.containsKey('zipCode'))
                            Text(
                              _errors['zipCode']!,
                              style: TextStyle(color: Colors.red),
                            ),

                          SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: CustomButton(
                              text:
                                  _isLoading
                                      ? 'Creating Account...'
                                      : 'Create Account',
                              onPressed: _isLoading ? null : _submitForm,
                              size: ButtonSize.large,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account?'),
                    TextButton(
                      onPressed:
                          () => context.read<NavigationProvider>().navigateTo(
                            AppPage.login,
                          ),
                      child: Text('Sign in'),
                    ),
                  ],
                ),
                TextButton(
                  onPressed:
                      () => context.read<NavigationProvider>().navigateTo(
                        AppPage.welcome,
                      ),
                  child: Text('← Back to Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

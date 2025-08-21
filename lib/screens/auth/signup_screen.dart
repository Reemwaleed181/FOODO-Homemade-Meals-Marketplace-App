import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

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

  final _formKey = GlobalKey<FormState>();
  Map<String, String> _errors = {};

  void _handleInputChange(String field, String value) {
    if (_errors.containsKey(field)) {
      setState(() => _errors.remove(field));
    }
  }

  bool _validateForm() {
    final newErrors = <String, String>{};

    if (_nameController.text.trim().isEmpty) newErrors['name'] = 'Name is required';
    if (_emailController.text.trim().isEmpty) newErrors['email'] = 'Email is required';
    if (_phoneController.text.trim().isEmpty) newErrors['phone'] = 'Phone number is required';
    if (_passwordController.text.isEmpty) newErrors['password'] = 'Password is required';
    if (_passwordController.text.length < 6) newErrors['password'] = 'Password must be at least 6 characters';
    if (_passwordController.text != _confirmPasswordController.text) {
      newErrors['confirmPassword'] = 'Passwords do not match';
    }
    if (_addressController.text.trim().isEmpty) newErrors['address'] = 'Address is required';
    if (_cityController.text.trim().isEmpty) newErrors['city'] = 'City is required';
    if (_zipCodeController.text.trim().isEmpty) newErrors['zipCode'] = 'ZIP code is required';

    setState(() => _errors = newErrors);
    return newErrors.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

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
                Text('HomeCook', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Join our community of food lovers'),
                SizedBox(height: 32),

                Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Text('Create Account', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          SizedBox(height: 16),

                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Full Name',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) => _handleInputChange('name', value),
                            validator: (value) => _errors['name'],
                          ),
                          SizedBox(height: 16),

                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (value) => _handleInputChange('email', value),
                            validator: (value) => _errors['email'],
                          ),
                          SizedBox(height: 16),

                          TextFormField(
                            controller: _phoneController,
                            decoration: InputDecoration(
                              labelText: 'Phone Number',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.phone,
                            onChanged: (value) => _handleInputChange('phone', value),
                            validator: (value) => _errors['phone'],
                          ),
                          SizedBox(height: 16),

                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(),
                            ),
                            obscureText: true,
                            onChanged: (value) => _handleInputChange('password', value),
                            validator: (value) => _errors['password'],
                          ),
                          SizedBox(height: 16),

                          TextFormField(
                            controller: _confirmPasswordController,
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              border: OutlineInputBorder(),
                            ),
                            obscureText: true,
                            onChanged: (value) => _handleInputChange('confirmPassword', value),
                            validator: (value) => _errors['confirmPassword'],
                          ),
                          SizedBox(height: 16),

                          TextFormField(
                            controller: _addressController,
                            decoration: InputDecoration(
                              labelText: 'Address',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) => _handleInputChange('address', value),
                            validator: (value) => _errors['address'],
                          ),
                          SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _cityController,
                                  decoration: InputDecoration(
                                    labelText: 'City',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (value) => _handleInputChange('city', value),
                                  validator: (value) => _errors['city'],
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _zipCodeController,
                                  decoration: InputDecoration(
                                    labelText: 'ZIP Code',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (value) => _handleInputChange('zipCode', value),
                                  validator: (value) => _errors['zipCode'],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 24),
                          if (authProvider.error != null)
                            Text(
                              authProvider.error!,
                              style: TextStyle(color: Colors.red),
                            ),
                          SizedBox(height: 16),

                          ElevatedButton(
                            onPressed: authProvider.isLoading
                                ? null
                                : () async {
                              if (_formKey.currentState!.validate() && _validateForm()) {
                                try {
                                  final userData = {
                                    'username': _emailController.text.split('@')[0],
                                    'email': _emailController.text,
                                    'password': _passwordController.text,
                                    'first_name': _nameController.text.split(' ')[0],
                                    'last_name': _nameController.text.split(' ').length > 1
                                        ? _nameController.text.split(' ')[1]
                                        : '',
                                    'phone': _phoneController.text,
                                    'address': _addressController.text,
                                    'city': _cityController.text,
                                    'zip_code': _zipCodeController.text,
                                  };

                                  await authProvider.signup(userData);
                                  Navigator.pushReplacementNamed(context, '/home');
                                } catch (e) {
                                  // Error is handled by provider
                                }
                              }
                            },
                            child: authProvider.isLoading
                                ? CircularProgressIndicator()
                                : Text('Create Account'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, 50),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 24),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: Text('Already have an account? Sign in'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
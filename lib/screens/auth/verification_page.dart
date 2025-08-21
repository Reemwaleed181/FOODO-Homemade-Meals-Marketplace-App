import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VerificationPage extends StatefulWidget {
  final String verificationToken;

  const VerificationPage({Key? key, required this.verificationToken}) : super(key: key);

  @override
  _VerificationPageState createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  bool _isLoading = false;
  String _message = '';
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _verifyEmail();
  }

  Future<void> _verifyEmail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://your-django-domain.com/api/verify-email/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'token': widget.verificationToken}),
      );

      final responseData = json.decode(response.body);

      setState(() {
        _isLoading = false;
        if (response.statusCode == 200) {
          _isSuccess = true;
          _message = responseData['message'];
        } else {
          _isSuccess = false;
          _message = responseData['error'] ?? 'An error occurred during verification.';
        }
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _isSuccess = false;
        _message = 'Network error. Please check your connection.';
      });
    }
  }

  Future<void> _resendVerification() async {
    // This would typically require the user to be logged in
    // You might need to implement a login flow first or use a different approach
    // For simplicity, we'll just show a message
    setState(() {
      _message = 'Please log in to resend verification email.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Email Verification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_isLoading)
              CircularProgressIndicator()
            else if (_isSuccess)
              Icon(Icons.check_circle, color: Colors.green, size: 64)
            else
              Icon(Icons.error, color: Colors.red, size: 64),

            SizedBox(height: 20),

            Text(
              _isLoading ? 'Verifying your email...' : _message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: _isSuccess ? Colors.green : Colors.red,
              ),
            ),

            SizedBox(height: 20),

            if (!_isLoading && !_isSuccess)
              ElevatedButton(
                onPressed: _resendVerification,
                child: Text('Resend Verification Email'),
              ),

            if (!_isLoading && _isSuccess)
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: Text('Continue to Login'),
              ),
          ],
        ),
      ),
    );
  }
}
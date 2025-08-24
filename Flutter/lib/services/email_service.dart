import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class EmailService {
  // Example using EmailJS (free service for testing)
  static const String _serviceId = 'your_service_id';
  static const String _templateId = 'your_template_id';
  static const String _publicKey = 'your_public_key';

  Future<bool> sendOtpEmail(String email, String otp) async {
    if (kDebugMode) {
      // In debug mode, just log and return success
      print('📧 EMAIL SERVICE (DEBUG MODE)');
      print('To: $email');
      print('OTP: $otp');
      print('Email would be sent in production');
      return true;
    }

    try {
      // Example EmailJS integration
      final response = await http.post(
        Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'service_id': _serviceId,
          'template_id': _templateId,
          'user_id': _publicKey,
          'template_params': {
            'to_email': email,
            'otp_code': otp,
            'app_name': 'Foodo App',
          },
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Email sending failed: $e');
      }
      return false;
    }
  }

  // Alternative: Firebase Cloud Functions endpoint
  Future<bool> sendOtpViaFirebase(String email, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('https://your-project.cloudfunctions.net/sendOtp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'otp': otp}),
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Firebase email sending failed: $e');
      }
      return false;
    }
  }
}

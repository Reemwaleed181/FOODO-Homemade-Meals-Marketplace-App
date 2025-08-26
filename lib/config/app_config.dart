import 'dart:io';
import 'package:flutter/foundation.dart';

class AppConfig {
  // App Branding
  static const String appName = 'Foodo';
  static const String appTagline = 'buying & selling';
  static const String appDescription = 'Delicious homemade meals made with love';
  
  // Django Backend Configuration
  // Returns the correct host for each platform (Android emulator uses 10.0.2.2)
  static String get djangoBaseUrl {
    // Build-time override: flutter run --dart-define BACKEND_BASE_URL=http://192.168.x.x:8000
    const String envBaseUrl = String.fromEnvironment('BACKEND_BASE_URL', defaultValue: '');
    if (envBaseUrl.isNotEmpty) {
      return envBaseUrl;
    }
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    }
    try {
      if (Platform.isAndroid) {
        // Use your computer's actual IP address for real device testing
        return 'http://192.168.10.17:8000';  // Your mobile hotspot IP
      }
    } catch (_) {
      // Platform may not be available in some runtimes; fallback below
    }
    return 'http://127.0.0.1:8000';
  }
  // Alternative ports: 'http://127.0.0.1:8001', 'http://localhost:8000'

  // API Endpoints - Updated to match Django backend
  static const String registerEndpoint = '/api/auth/signup/';
  static const String loginEndpoint = '/api/auth/login/';
  static const String verifyEmailEndpoint = '/api/verify-email/';
  static const String sendOtpEndpoint = '/api/send-otp/';
  static const String resendOtpEndpoint = '/api/resend-otp/';

  // Full API URLs
  static String get registerUrl => '$djangoBaseUrl$registerEndpoint';
  static String get loginUrl => '$djangoBaseUrl$loginEndpoint';
  static String get verifyEmailUrl => '$djangoBaseUrl$verifyEmailEndpoint';
  static String get sendOtpUrl => '$djangoBaseUrl$sendOtpEndpoint';
  static String get resendOtpUrl => '$djangoBaseUrl$resendOtpEndpoint';

  // Development Settings
  static const bool enableDebugLogging = true;
  static const bool enableMockMode = false; // Must be false to use real Django backend
  static const bool enableFallbackMode = true; // Enable fallback for development

  // OTP Settings
  static const int otpExpiryMinutes = 10;
  static const int otpLength = 6;
}

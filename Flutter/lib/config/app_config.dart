class AppConfig {
  // Django Backend Configuration
  // Change this to match your Django server port
  static const String djangoBaseUrl = 'http://127.0.0.1:8000';
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
  static const bool enableMockMode =
      true; // Set to true for development without Django
  static const bool enableFallbackMode =
      true; // Enable fallback when Django is unavailable

  // OTP Settings
  static const int otpExpiryMinutes = 10;
  static const int otpLength = 6;
}

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiResponse {
  final bool success;
  final dynamic data;
  final String? message;

  ApiResponse({required this.success, this.data, this.message});
}

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  Future<ApiResponse> register(
    String name,
    String email,
    String password, {
    String phone = '',
    String address = '',
    String city = '',
    String zipCode = '',
  }) async {
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/api/auth/signup/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'name': name,
          'email': email, 
          'password': password,
          'phone': phone,
          'address': address,
          'city': city,
          'zip_code': zipCode,
        }),
      )
          .timeout(const Duration(seconds: 15));

      print('Server status code: ${response.statusCode}');
      print('Server response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return ApiResponse(
          success: true,
          data: data['data'] ?? data,
          message: data['message'] ?? 'Registration successful',
        );
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse(
          success: false,
          message:
              errorData['message'] ??
              errorData['error'] ??
              'Registration failed',
        );
      }
    } catch (e) {
      print('Server connection error: $e');
      return ApiResponse(
        success: false,
        message: 'Server connection error: $e',
      );
    }
  }

  Future<ApiResponse> login(String email, String password) async {
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/api/auth/login/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'email': email, 'password': password}),
      )
          .timeout(const Duration(seconds: 15));

      print('Login response: ${response.statusCode}');
      print('Login body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse(
          success: true,
          data: data['data'] ?? data,
          message: data['message'] ?? 'Login successful',
        );
      } else {
        final errorData = json.decode(response.body);
        
        // Extract error message from different possible fields
        String errorMessage = 'Login failed';
        if (errorData['errors'] != null && errorData['errors'] is List) {
          // Handle array of error messages
          List errors = errorData['errors'];
          if (errors.isNotEmpty) {
            errorMessage = errors.first.toString();
          }
        } else if (errorData['message'] != null) {
          errorMessage = errorData['message'];
        } else if (errorData['error'] != null) {
          errorMessage = errorData['error'];
        } else if (errorData['detail'] != null) {
          errorMessage = errorData['detail'];
        }
        
        return ApiResponse(
          success: false,
          message: errorMessage,
        );
      }
    } catch (e) {
      print('Login error: $e');
      return ApiResponse(
        success: false,
        message: 'Server connection error: $e',
      );
    }
  }

  Future<ApiResponse> verifyEmail(String email, String code) async {
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/api/verify-email/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'email': email, 'code': code}),
      )
          .timeout(const Duration(seconds: 15));

      print('Verify email response: ${response.statusCode}');
      print('Verify email body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse(
          success: true,
          data: data,
          message: data['message'] ?? 'Email verification successful',
        );
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse(
          success: false,
          message:
              errorData['message'] ??
              errorData['error'] ??
              'Verification failed',
        );
      }
    } catch (e) {
      print('Verify email error: $e');
      return ApiResponse(
        success: false,
        message: 'Server connection error: $e',
      );
    }
  }

  // Send OTP to email via Django backend
  Future<ApiResponse> sendOtp(String email) async {
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/api/send-otp/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'email': email}),
      )
          .timeout(const Duration(seconds: 15));

      print('Send OTP response: ${response.statusCode}');
      print('Send OTP body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse(
          success: true,
          data: data,
          message: data['message'] ?? 'OTP sent successfully',
        );
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse(
          success: false,
          message:
              errorData['message'] ??
              errorData['error'] ??
              'Failed to send OTP',
        );
      }
    } catch (e) {
      print('Send OTP error: $e');
      return ApiResponse(
        success: false,
        message: 'Server connection error: $e',
      );
    }
  }

  // Forgot password via Django backend
  Future<ApiResponse> forgotPassword(String email) async {
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/api/forgot-password/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'email': email}),
      )
          .timeout(const Duration(seconds: 15));



      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse(
          success: true,
          data: data,
          message: data['message'] ?? 'Password reset OTP sent successfully',
        );
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse(
          success: false,
          message:
              errorData['message'] ??
              errorData['error'] ??
              'Failed to send password reset OTP',
        );
      }
    } catch (e) {
      print('Forgot password error: $e');
      return ApiResponse(
        success: false,
        message: 'Server connection error: $e',
      );
    }
  }

  // Verify password reset OTP
  Future<ApiResponse> verifyPasswordResetOtp(String email, String otpCode) async {
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/api/verify-password-reset-otp/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email,
          'otp_code': otpCode,
        }),
      )
          .timeout(const Duration(seconds: 15));



      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse(
          success: true,
          data: data,
          message: data['message'] ?? 'OTP verified successfully',
        );
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse(
          success: false,
          message:
              errorData['message'] ??
              errorData['error'] ??
              'Failed to verify OTP',
        );
      }
    } catch (e) {
      print('Verify OTP error: $e');
      return ApiResponse(
        success: false,
        message: 'Server connection error: $e',
      );
    }
  }

  // Reset password via Django backend
  Future<ApiResponse> resetPassword(String email, String otpCode, String newPassword) async {
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/api/reset-password/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email,
          'otp_code': otpCode,
          'new_password': newPassword,
        }),
      )
          .timeout(const Duration(seconds: 15));



      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse(
          success: true,
          data: data,
          message: data['message'] ?? 'Password reset successfully',
        );
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse(
          success: false,
          message:
              errorData['message'] ??
              errorData['error'] ??
              'Failed to reset password',
        );
      }
    } catch (e) {
      print('Reset password error: $e');
      return ApiResponse(
        success: false,
        message: 'Server connection error: $e',
      );
    }
  }

  // Resend OTP via Django backend
  Future<ApiResponse> resendOtp(String email) async {
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/api/resend-otp/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'email': email}),
      )
          .timeout(const Duration(seconds: 15));

      print('Resend OTP response: ${response.statusCode}');
      print('Resend OTP body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse(
          success: true,
          data: data,
          message: data['message'] ?? 'OTP resent successfully',
        );
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse(
          success: false,
          message:
              errorData['message'] ??
              errorData['error'] ??
              'Failed to resend OTP',
        );
      }
    } catch (e) {
      print('Resend OTP error: $e');
      return ApiResponse(
        success: false,
        message: 'Server connection error: $e',
      );
    }
  }
}

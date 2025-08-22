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
    String email,
    String password,
    String name,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/register/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'email': email, 'password': password, 'name': name}),
      );

      print('Server status code: ${response.statusCode}');
      print('Server response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return ApiResponse(
          success: true,
          data: data,
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
      final response = await http.post(
        Uri.parse('$baseUrl/api/login/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse(
          success: true,
          data: data,
          message: data['message'] ?? 'Login successful',
        );
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse(
          success: false,
          message: errorData['message'] ?? errorData['error'] ?? 'Login failed',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Server connection error: $e',
      );
    }
  }

  Future<ApiResponse> verifyEmail(String email, String code) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/verify-email/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'email': email, 'code': code}),
      );

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
      final response = await http.post(
        Uri.parse('$baseUrl/api/send-otp/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'email': email}),
      );

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

  // Resend OTP via Django backend
  Future<ApiResponse> resendOtp(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/resend-otp/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'email': email}),
      );

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

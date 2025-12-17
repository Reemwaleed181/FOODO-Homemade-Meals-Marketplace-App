import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/meal.dart';

// Response model for API calls
class ApiResponse {
  final bool success;
  final String? message;
  final Map<String, dynamic>? data;

  ApiResponse({required this.success, this.message, this.data});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'],
    );
  }
}

class ApiService {
  // Update this IP address to match your computer's IP address
  // Run 'ipconfig' in PowerShell to find your IP (look for IPv4 Address)
  static const String baseUrl =
      'http://localhost:8000/api'; // Updated with your Wi-Fi IP

  // Get all meals from backend
  static Future<List<Meal>> getAllMeals() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/meals/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((mealJson) => Meal.fromApiJson(mealJson)).toList();
      } else {
        print('Error fetching meals: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching meals: $e');
      return [];
    }
  }

  // Get meal by ID from backend
  static Future<Meal?> getMealById(String mealId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/meals/$mealId/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Meal.fromApiJson(data);
      } else {
        print('Error fetching meal: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching meal: $e');
      return null;
    }
  }

  // Place order
  static Future<Map<String, dynamic>?> placeOrder({
    required List<Map<String, dynamic>> items,
    required String deliveryNotes,
    required bool isExpress,
    required String authToken,
    Map<String, dynamic>? deliveryAddress,
  }) async {
    try {
      final body = {
        'items': items,
        'delivery_notes': deliveryNotes,
        'express': isExpress,
      };

      // Add delivery address if provided
      if (deliveryAddress != null) {
        body['delivery_address'] = deliveryAddress;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/orders/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        print('Error placing order: ${response.statusCode}');
        print('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error placing order: $e');
      return null;
    }
  }

  // Get order history
  static Future<List<Map<String, dynamic>>> getOrders(String authToken) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        print('Error fetching orders: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching orders: $e');
      return [];
    }
  }

  // Address Management Methods
  static Future<ApiResponse> getAddresses(String authToken) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/addresses/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        return ApiResponse.fromJson(json.decode(response.body));
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse(
          success: false,
          message: errorData['message'] ?? 'Failed to fetch addresses',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Network error: $e');
    }
  }

  static Future<ApiResponse> createAddress(
    Map<String, dynamic> addressData,
    String authToken,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/addresses/create/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode(addressData),
      );

      if (response.statusCode == 201) {
        return ApiResponse.fromJson(json.decode(response.body));
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse(
          success: false,
          message: errorData['message'] ?? 'Failed to create address',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Network error: $e');
    }
  }

  static Future<ApiResponse> updateAddress(
    String addressId,
    Map<String, dynamic> addressData,
    String authToken,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/addresses/$addressId/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode(addressData),
      );

      if (response.statusCode == 200) {
        return ApiResponse.fromJson(json.decode(response.body));
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse(
          success: false,
          message: errorData['message'] ?? 'Failed to update address',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Network error: $e');
    }
  }

  static Future<ApiResponse> deleteAddress(
    String addressId,
    String authToken,
  ) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/addresses/$addressId/delete/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        return ApiResponse.fromJson(json.decode(response.body));
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse(
          success: false,
          message: errorData['message'] ?? 'Failed to delete address',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Network error: $e');
    }
  }

  static Future<ApiResponse> setDefaultAddress(
    String addressId,
    String authToken,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/addresses/$addressId/set-default/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        return ApiResponse.fromJson(json.decode(response.body));
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse(
          success: false,
          message: errorData['message'] ?? 'Failed to set default address',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Network error: $e');
    }
  }

  // Authentication methods
  static Future<ApiResponse> register(
    String name,
    String email,
    String password, {
    String phone = '',
    String address = '',
    String city = '',
    String zipCode = '',
    bool isChef = false,
  }) async {
    try {
      final body = {
        'name': name,
        'email': email,
        'password': password,
        if (phone.isNotEmpty) 'phone': phone,
        if (address.isNotEmpty) 'address': address,
        if (city.isNotEmpty) 'city': city,
        if (zipCode.isNotEmpty) 'zip_code': zipCode,
        'is_chef': isChef,
      };
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/signup/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        return ApiResponse.fromJson(json.decode(response.body));
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse(
          success: false,
          message: errorData['message'] ?? 'Registration failed',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Network error: $e');
    }
  }

  static Future<ApiResponse> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        return ApiResponse.fromJson(json.decode(response.body));
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse(
          success: false,
          message: errorData['message'] ?? 'Login failed',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Network error: $e');
    }
  }

  static Future<ApiResponse> googleSignIn(String accessToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/google-signin/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'access_token': accessToken}),
      );

      if (response.statusCode == 200) {
        return ApiResponse.fromJson(json.decode(response.body));
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse(
          success: false,
          message: errorData['message'] ?? 'Google sign-in failed',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Network error: $e');
    }
  }

  static Future<ApiResponse> sendOtp(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/send-otp/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      if (response.statusCode == 200) {
        return ApiResponse.fromJson(json.decode(response.body));
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse(
          success: false,
          message: errorData['message'] ?? 'Failed to send OTP',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Network error: $e');
    }
  }

  static Future<ApiResponse> resendOtp(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/resend-otp/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      if (response.statusCode == 200) {
        return ApiResponse.fromJson(json.decode(response.body));
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse(
          success: false,
          message: errorData['message'] ?? 'Failed to resend OTP',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Network error: $e');
    }
  }

  static Future<ApiResponse> verifyEmail(String email, String code) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-email/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'code': code}),
      );

      if (response.statusCode == 200) {
        return ApiResponse.fromJson(json.decode(response.body));
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse(
          success: false,
          message: errorData['message'] ?? 'Email verification failed',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Network error: $e');
    }
  }

  static Future<ApiResponse> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      if (response.statusCode == 200) {
        return ApiResponse.fromJson(json.decode(response.body));
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse(
          success: false,
          message: errorData['message'] ?? 'Failed to send password reset',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Network error: $e');
    }
  }

  static Future<ApiResponse> verifyPasswordResetOtp(
    String email,
    String code,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-password-reset-otp/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'otp_code': code}),
      );

      if (response.statusCode == 200) {
        return ApiResponse.fromJson(json.decode(response.body));
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse(
          success: false,
          message: errorData['message'] ?? 'OTP verification failed',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Network error: $e');
    }
  }

  static Future<ApiResponse> resetPassword(
    String email,
    String otpCode,
    String newPassword,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/reset-password/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'otp_code': otpCode,
          'new_password': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        return ApiResponse.fromJson(json.decode(response.body));
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse(
          success: false,
          message: errorData['message'] ?? 'Password reset failed',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Network error: $e');
    }
  }

  static Future<ApiResponse> updateProfile(
    Map<String, dynamic> profileData,
    String authToken,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/auth/profile/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode(profileData),
      );

      if (response.statusCode == 200) {
        return ApiResponse.fromJson(json.decode(response.body));
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse(
          success: false,
          message: errorData['message'] ?? 'Failed to update profile',
          data: errorData,
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Network error: $e');
    }
  }
}

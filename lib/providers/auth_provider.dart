import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../models/user.dart';
import './navigation_provider.dart';
import '../config/app_config.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService;
  final StorageService _storageService;
  final NavigationProvider _navigationProvider;

  User? _user;
  bool _isLoading = false;
  String? _error;

  // OTP management for development
  String? _currentOtp;
  String? _otpEmail;
  DateTime? _otpExpiry;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentOtp => _currentOtp; // For development testing

  AuthProvider({
    required ApiService apiService,
    required StorageService storageService,
    required NavigationProvider navigationProvider,
  }) : _apiService = apiService,
       _storageService = storageService,
       _navigationProvider = navigationProvider;

  // Generate a 6-digit OTP
  String _generateOtp() {
    final random = Random();
    return List.generate(6, (_) => random.nextInt(10)).join();
  }

  // Send OTP to email
  Future<void> _sendOtpToEmail(String email, String otp) async {
    _currentOtp = otp;
    _otpEmail = email;
    _otpExpiry = DateTime.now().add(
      Duration(minutes: AppConfig.otpExpiryMinutes),
    );

    if (kDebugMode) {
      print('=== OTP GENERATED (DEV MODE) ===');
      print('Email: $email');
      print('OTP Code: $otp');
      print('Expires: ${_otpExpiry.toString()}');
      print('==============================');

      // In development mode, we'll simulate sending the email
      // In production, this would call a real email service
      print('📧 Simulating email delivery to: $email');
      print('🔐 OTP Code: $otp');
      print('⏰ This code will expire in ${AppConfig.otpExpiryMinutes} minutes');
    }

    // Try to send via Django backend first
    try {
      final response = await _apiService.sendOtp(email);
      if (response.success) {
        if (kDebugMode) {
          print('✅ OTP sent successfully via Django backend');
        }
        return;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Django OTP sending failed: $e');
        print('📧 Using development fallback mode');
      }
    }

    // Fallback: In a real app, you would integrate with an email service here
    // For now, we'll just simulate it in development mode
    if (kDebugMode) {
      print('📧 Development mode: OTP would be sent to $email');
      print('🔐 The actual OTP code is: $otp');
      print('💡 In production, this would be sent via email service');
    }
  }

  // Verify OTP
  bool _verifyOtp(String email, String code) {
    if (_currentOtp == null || _otpEmail != email) {
      return false;
    }

    if (_otpExpiry != null && DateTime.now().isAfter(_otpExpiry!)) {
      _currentOtp = null;
      _otpEmail = null;
      _otpExpiry = null;
      return false;
    }

    return _currentOtp == code;
  }

  // Resend OTP via Django backend
  Future<void> resendOtp(String email) async {
    try {
      setError(null);

      // Try Django backend first
      try {
        final response = await _apiService.resendOtp(email);

        if (response.success) {
          if (kDebugMode) {
            print('✅ OTP resent successfully via Django backend to: $email');
          }
          return;
        } else {
          throw Exception('Failed to resend OTP: ${response.message}');
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ Django resend OTP failed: $e');
          print('📧 Falling back to development mode');
        }
        throw e; // Re-throw to trigger fallback
      }

      // Fallback to development mode if Django fails
      if (kDebugMode) {
        print('Using development fallback mode for resend OTP');

        // Generate new OTP locally for development
        final otp = _generateOtp();
        _currentOtp = otp;
        _otpEmail = email;
        _otpExpiry = DateTime.now().add(
          Duration(minutes: AppConfig.otpExpiryMinutes),
        );

        // Send OTP to email
        await _sendOtpToEmail(email, otp);

        if (kDebugMode) {
          print('OTP resent successfully in development mode');
        }
      } else {
        throw Exception('Failed to resend OTP. Please try again later.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception during resend OTP: $e');
      }
      throw Exception('Error occurred while resending OTP: $e');
    }
  }

  // Forgot password
  Future<void> forgotPassword(String email) async {
    try {
      setError(null);

      // Try Django backend first
      try {
        final response = await _apiService.forgotPassword(email);

        if (response.success) {
          if (kDebugMode) {
            print('✅ Password reset instructions sent successfully via Django backend to: $email');
          }
          return;
        } else {
          throw Exception('Failed to send password reset instructions: ${response.message}');
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ Django forgot password failed: $e');
          print('📧 Falling back to development mode');
        }
        
        // Fallback to development mode if Django fails
        if (kDebugMode) {
          print('Using development fallback mode for forgot password');

          // Generate new OTP locally for development
          final otp = _generateOtp();
          _currentOtp = otp;
          _otpEmail = email;
          _otpExpiry = DateTime.now().add(
            Duration(minutes: AppConfig.otpExpiryMinutes),
          );

          // Send OTP to email
          await _sendOtpToEmail(email, otp);

          if (kDebugMode) {
            print('✅ Password reset OTP sent successfully in development mode');
          }
          return; // Success in development mode
        } else {
          throw Exception('Failed to send password reset instructions. Please try again later.');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception during forgot password: $e');
      }
      throw Exception('Error occurred while sending password reset instructions: $e');
    }
  }

  // Reset password
  Future<void> resetPassword(String email, String otpCode, String newPassword) async {
    try {
      setError(null);

      // Try Django backend first
      try {
        final response = await _apiService.resetPassword(email, otpCode, newPassword);

        if (response.success) {
          if (kDebugMode) {
            print('✅ Password reset successfully via Django backend for: $email');
          }
          return;
        } else {
          throw Exception('Failed to reset password: ${response.message}');
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ Django password reset failed: $e');
          print('📧 Falling back to development mode');
        }
        throw e; // Re-throw to trigger fallback
      }

      // Fallback to development mode if Django fails
      if (kDebugMode) {
        print('Using development fallback mode for password reset');

        // Verify OTP first
        if (_verifyOtp(email, otpCode)) {
          if (kDebugMode) {
            print('✅ Password reset successful in development mode');
          }
          return;
        } else {
          throw Exception('Invalid OTP code or OTP has expired');
        }
      } else {
        throw Exception('Failed to reset password. Please try again later.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception during password reset: $e');
      }
      throw Exception('Error occurred while resetting password: $e');
    }
  }

  // Verify password reset OTP
  Future<void> verifyPasswordResetOtp(String email, String otpCode) async {
    try {
      setError(null);

      // Try Django backend first
      try {
        final response = await _apiService.verifyPasswordResetOtp(email, otpCode);

        if (response.success) {
          if (kDebugMode) {
            print('✅ Password reset OTP verified successfully via Django backend for: $email');
          }
          return;
        } else {
          throw Exception('Failed to verify OTP: ${response.message}');
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ Django password reset OTP verification failed: $e');
          print('📧 Falling back to development mode');
        }
        throw e; // Re-throw to trigger fallback
      }

      // Fallback to development mode if Django fails
      if (kDebugMode) {
        print('Using development fallback mode for password reset OTP verification');

        // Verify OTP using local verification
        if (_verifyOtp(email, otpCode)) {
          if (kDebugMode) {
            print('✅ Password reset OTP verified successfully in development mode');
          }
          return;
        } else {
          throw Exception('Invalid OTP code or OTP has expired');
        }
      } else {
        throw Exception('Failed to verify OTP. Please try again later.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception during password reset OTP verification: $e');
      }
      throw Exception('Error occurred while verifying OTP: $e');
    }
  }

  // Check if email exists in the system
  Future<bool> checkEmailExists(String email) async {
    try {
      setError(null);
      
      // Try Django backend first
      try {
        final response = await _apiService.sendOtp(email);
        
        if (response.success) {
          if (kDebugMode) {
            print('✅ Email check successful via Django backend: $email');
          }
          return true;
        } else {
          // If OTP sending fails, it might mean the email doesn't exist
          if (response.message?.contains('not found') == true) {
            throw Exception('User not found');
          }
          throw Exception(response.message ?? 'Failed to check email');
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ Django email check failed: $e');
        }
        throw e;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception during email check: $e');
      }
      throw Exception('Error occurred while checking email: $e');
    }
  }

  Future<void> register(String name, String email, String password, {
    String phone = '',
    String address = '',
    String city = '',
    String zipCode = '',
  }) async {
    try {
      setLoading(true);
      setError(null);

      // Try Django backend first
      try {
        final response = await _apiService.register(name, email, password);

        if (response.success) {
          if (kDebugMode) {
            print('Registration successful via Django: ${response.message}');
          }

          // Store user data from Django response
          if (response.data != null) {
            await _storageService.saveUserData(response.data);
            _user = User.fromJson(response.data);
            notifyListeners();
          }

          // Now send OTP via Django backend
          try {
            final otpResponse = await _apiService.sendOtp(email);
            if (otpResponse.success) {
              if (kDebugMode) {
                print('✅ OTP sent successfully via Django backend to: $email');
              }

              // Navigate to verification page with email
              _navigationProvider.navigateTo(
                AppPage.verification,
                data: {'email': email},
              );
              return;
            } else {
              throw Exception('Failed to send OTP: ${otpResponse.message}');
            }
          } catch (otpError) {
            if (kDebugMode) {
              print('❌ Django OTP sending failed: $otpError');
              print('📧 Falling back to development mode');
            }
            throw otpError; // Re-throw to trigger fallback
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Django backend failed, using fallback mode: $e');
        }
      }

      // Fallback to development mode if Django fails
      if (kDebugMode && AppConfig.enableFallbackMode) {
        print('Using development fallback mode for registration');

        // Generate OTP for development
        final otp = _generateOtp();
        _currentOtp = otp;

        // Send OTP to email (in development, this will be simulated)
        await _sendOtpToEmail(email, otp);

        // Create mock user for development
        final mockUser = {
          'id': 'user_${DateTime.now().millisecondsSinceEpoch}',
          'name': name,
          'email': email,
          'role': 'customer',
          'isChef': false,
          'isVerified': false,
          'phone': phone,
          'address': address,
          'city': city,
          'zipCode': zipCode,
        };

        await _storageService.saveUserData(mockUser);
        _user = User.fromJson(mockUser);
        notifyListeners();

        // Navigate to verification page with email
        _navigationProvider.navigateTo(
          AppPage.verification,
          data: {'email': email},
        );
      } else {
        setError('Registration failed. Please try again later.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception during registration: $e');
      }
      setError('Error occurred during registration: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<void> login(String email, String password) async {
    try {
      setLoading(true);
      setError(null);

      // Try Django backend first
      try {
        final response = await _apiService.login(email, password);

        if (response.success) {
          if (kDebugMode) {
            print('Login successful via Django: ${response.message}');
          }

          // Store user data from Django response
          if (response.data != null) {
            await _storageService.saveUserData(response.data);
            _user = User.fromJson(response.data);
            notifyListeners();
          }

          // Navigate to home page
          _navigationProvider.navigateTo(AppPage.home);
          return;
        } else {
          // Handle specific error messages from backend
          String errorMessage = response.message ?? 'Login failed';
          
          // Check for specific error types
          if (response.message?.contains('not registered') == true) {
            throw Exception('This email is not registered. Please sign up first.');
          } else if (response.message?.contains('Invalid password') == true) {
            throw Exception('Invalid password. Please check your credentials.');
          } else if (response.message?.contains('verify your email') == true) {
            throw Exception('Please verify your email before logging in. Check your inbox for the verification code.');
          } else if (response.message?.contains('account has been disabled') == true) {
            throw Exception('Your account has been disabled. Please contact support.');
          } else {
            throw Exception(errorMessage);
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Django backend failed, using fallback mode: $e');
        }
        
        // Re-throw the error to be handled by the calling code
        throw e;
      }

      // Fallback to development mode if Django fails
      if (kDebugMode && AppConfig.enableFallbackMode) {
        print('Backend unavailable. Consider using fallback mode for testing.');
        
        // In a real app, you might want to show a dialog asking the user
        // if they want to use fallback mode or retry
        print('Using development fallback mode for login');

        // Create mock user for development
        final mockUser = {
          'id': 'user_${DateTime.now().millisecondsSinceEpoch}',
          'name': email.split('@')[0],
          'email': email,
          'role': 'customer',
          'isChef': false,
          'isVerified': true,
          'phone': '',
          'address': '',
          'city': '',
          'zipCode': '',
        };

        await _storageService.saveUserData(mockUser);
        _user = User.fromJson(mockUser);
        notifyListeners();

        // Navigate to home page
        _navigationProvider.navigateTo(AppPage.home);
      } else {
        setError('Login failed. Please try again later.');
      }
    } catch (e) {
      setError('Error occurred during login: $e');
      // Re-throw the error so the UI can handle it appropriately
      throw e;
    } finally {
      setLoading(false);
    }
  }

  Future<void> verifyEmail(String email, String code) async {
    try {
      setLoading(true);
      setError(null);

      // Try Django backend first
      try {
        final response = await _apiService.verifyEmail(email, code);

        if (response.success) {
          if (kDebugMode) {
            print('✅ Email verification successful via Django backend');
          }

          // Update user verification status
          if (_user != null) {
            _user = _user!.copyWith(isVerified: true);
            await _storageService.saveUserData(_user!.toJson());
            notifyListeners();
          }

          // Navigate to home page after successful verification
          _navigationProvider.navigateTo(AppPage.home);
          return;
        } else {
          throw Exception('Verification failed: ${response.message}');
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ Django verification failed: $e');
          print('📧 Falling back to development mode');
        }
        throw e; // Re-throw to trigger fallback
      }

      // Fallback to development mode if Django fails
      if (kDebugMode) {
        print('Using development fallback mode for email verification');

        // Check if OTP matches and is valid
        if (_currentOtp == code && _otpEmail == email && _otpExpiry != null) {
          if (DateTime.now().isBefore(_otpExpiry!)) {
            // Mark OTP as used
            _currentOtp = null;
            _otpEmail = null;
            _otpExpiry = null;

            // Update user verification status
            if (_user != null) {
              _user = _user!.copyWith(isVerified: true);
              await _storageService.saveUserData(_user!.toJson());
              notifyListeners();
            }

            if (kDebugMode) {
              print(
                'Email verification successful in development mode for: $email',
              );
            }
            
            // Navigate to home page after successful verification
            _navigationProvider.navigateTo(AppPage.home);
            return;
          } else {
            throw Exception('OTP code has expired');
          }
        } else {
          throw Exception('Invalid OTP code');
        }
      } else {
        throw Exception('Email verification failed. Please try again later.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception during email verification: $e');
      }
      throw Exception('Error occurred during email verification: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<void> loadUser() async {
    try {
      final token = await _storageService.getToken();
      if (token != null) {
        final userData = await _storageService.getUserData();
        if (userData != null) {
          _user = User.fromJson(userData);
          notifyListeners();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading user data: $e');
      }
    }
  }

  Future<void> logout() async {
    await _storageService.deleteToken();
    await _storageService.deleteUserData();
    _user = null;
    _navigationProvider.navigateTo(AppPage.welcome);
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

}

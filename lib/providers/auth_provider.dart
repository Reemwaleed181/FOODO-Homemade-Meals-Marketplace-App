import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../models/user.dart';
import './navigation_provider.dart';
import '../config/app_config.dart';

class AuthProvider with ChangeNotifier {
  final StorageService _storageService;
  final NavigationProvider _navigationProvider;

  User? _user;
  User? _customerProfile;
  User? _chefProfile;
  bool _isLoading = false;
  String? _error;

  User? get customerProfile => _customerProfile;
  User? get chefProfile => _chefProfile;

  // Helper function to safely convert to double
  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  // Helper function to safely convert to int
  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  // OTP management for development
  String? _currentOtp;
  String? _otpEmail;
  DateTime? _otpExpiry;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentOtp => _currentOtp; // For development testing

  AuthProvider({
    required StorageService storageService,
    required NavigationProvider navigationProvider,
  }) : _storageService = storageService,
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
      final response = await ApiService.sendOtp(email);
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
        final response = await ApiService.resendOtp(email);

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
        final response = await ApiService.forgotPassword(email);

        if (response.success) {
          if (kDebugMode) {
            print(
              '✅ Password reset instructions sent successfully via Django backend to: $email',
            );
          }
          return;
        } else {
          throw Exception(
            'Failed to send password reset instructions: ${response.message}',
          );
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
          throw Exception(
            'Failed to send password reset instructions. Please try again later.',
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception during forgot password: $e');
      }
      throw Exception(
        'Error occurred while sending password reset instructions: $e',
      );
    }
  }

  // Reset password
  Future<void> resetPassword(
    String email,
    String otpCode,
    String newPassword,
  ) async {
    try {
      setError(null);

      // Try Django backend first
      try {
        final response = await ApiService.resetPassword(
          email,
          otpCode,
          newPassword,
        );

        if (response.success) {
          if (kDebugMode) {
            print(
              '✅ Password reset successfully via Django backend for: $email',
            );
          }
          return;
        } else {
          throw Exception('Failed to reset password: ${response.message}');
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ Django password reset failed: $e');
          print('📧 Falling back to development mode');
          
          // Fallback to development mode if Django fails
          print('Using development fallback mode for password reset');

          // Verify OTP first
          if (_verifyOtp(email, otpCode)) {
            print('✅ Password reset successful in development mode');
            return;
          } else {
            throw Exception('Invalid OTP code or OTP has expired');
          }
        } else {
          throw Exception('Failed to reset password. Please try again later.');
        }
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
        final response = await ApiService.verifyPasswordResetOtp(
          email,
          otpCode,
        );

        if (response.success) {
          if (kDebugMode) {
            print(
              '✅ Password reset OTP verified successfully via Django backend for: $email',
            );
          }
          return;
        } else {
          throw Exception('Failed to verify OTP: ${response.message}');
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ Django password reset OTP verification failed: $e');
          print('📧 Falling back to development mode');
          
          // Fallback to development mode if Django fails
          print(
            'Using development fallback mode for password reset OTP verification',
          );

          // Verify OTP using local verification
          if (_verifyOtp(email, otpCode)) {
            print(
              '✅ Password reset OTP verified successfully in development mode',
            );
            return;
          } else {
            throw Exception('Invalid OTP code or OTP has expired');
          }
        } else {
          throw Exception('Failed to verify OTP. Please try again later.');
        }
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
        final response = await ApiService.sendOtp(email);

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

  Future<void> register(
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
      setLoading(true);
      setError(null);

      // Try Django backend first
      try {
        final response = await ApiService.register(
          name,
          email,
          password,
          phone: phone,
          address: address,
          city: city,
          zipCode: zipCode,
          isChef: isChef,
        );

        if (response.success) {
          if (kDebugMode) {
            print('Registration successful via Django: ${response.message}');
          }

          // Store user data and tokens from Django response
          final userData = response.data;
          if (userData != null) {
            // Save access token if available
            if (userData['access'] != null) {
              await _storageService.saveToken(userData['access']);
            }

            // Extract user object if nested, or use the data directly
            Map<String, dynamic> userDataToSave = userData['user'] ?? userData;

            // Normalize user data - convert ID to string if it's an integer
            if (userDataToSave['id'] != null && userDataToSave['id'] is int) {
              userDataToSave['id'] = userDataToSave['id'].toString();
            }

            // Ensure all required fields have default values and convert types safely
            // Preserve address fields from signup if backend doesn't return them
            userDataToSave = {
              'id': userDataToSave['id']?.toString() ?? '',
              'name':
                  userDataToSave['name'] ??
                  userDataToSave['first_name'] ??
                  userDataToSave['username'] ??
                  '',
              'email': userDataToSave['email'] ?? '',
              'phone': userDataToSave['phone']?.toString() ?? phone,
              'address': userDataToSave['address']?.toString() ?? address,
              'city': userDataToSave['city']?.toString() ?? city,
              'zipCode':
                  userDataToSave['zipCode']?.toString() ??
                  userDataToSave['zip_code']?.toString() ??
                  zipCode,
              'role': userDataToSave['role']?.toString() ?? 'customer',
              'isChef':
                  userDataToSave['isChef'] ??
                  userDataToSave['is_chef'] ??
                  isChef,
              'chefBio':
                  userDataToSave['chefBio']?.toString() ??
                  userDataToSave['chef_bio']?.toString(),
              'chefRating': _toDouble(
                userDataToSave['chefRating'] ?? userDataToSave['chef_rating'],
              ),
              'totalOrders': _toInt(
                userDataToSave['totalOrders'] ?? userDataToSave['total_orders'],
              ),
              'isVerified':
                  userDataToSave['isVerified'] ??
                  userDataToSave['is_verified'] ??
                  false,
              'profilePicture':
                  userDataToSave['profilePicture'] ??
                  userDataToSave['profile_picture'],
            };

            await _storageService.saveUserData(userDataToSave);
            _user = User.fromJson(userDataToSave);
            
            // Save to appropriate profile storage
            if (isChef) {
              await _storageService.saveChefProfile(userDataToSave);
              _chefProfile = _user;
              await _storageService.setActiveProfile('chef');
            } else {
              await _storageService.saveCustomerProfile(userDataToSave);
              _customerProfile = _user;
              await _storageService.setActiveProfile('customer');
            }
            
            notifyListeners();

            if (kDebugMode) {
              print('✅ User data saved after signup:');
              print('   Name: ${_user?.name}');
              print('   Email: ${_user?.email}');
              print('   Phone: ${_user?.phone}');
              print('   Address: ${_user?.address}');
              print('   City: ${_user?.city}');
              print('   ZipCode: ${_user?.zipCode}');
              print('   Is Chef: ${_user?.isChef}');
            }
          }

          // Now send OTP via Django backend
          try {
            final otpResponse = await ApiService.sendOtp(email);
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
          'role': isChef ? 'chef' : 'customer',
          'isChef': isChef,
          'isVerified': false,
          'phone': phone,
          'address': address,
          'city': city,
          'zipCode': zipCode,
          'profilePicture': null, // Will be set when user selects one
        };

        // Generate a mock token for fallback mode
        final mockToken = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
        await _storageService.saveToken(mockToken);
        
        await _storageService.saveUserData(mockUser);
        _user = User.fromJson(mockUser);
        notifyListeners();
        
        if (kDebugMode) {
          print('✅ Mock token saved for fallback mode');
        }

        if (kDebugMode) {
          print('✅ User data saved after signup (fallback mode):');
          print('   Name: ${_user?.name}');
          print('   Email: ${_user?.email}');
          print('   Phone: ${_user?.phone}');
          print('   Address: ${_user?.address}');
          print('   City: ${_user?.city}');
        }

        // Navigate to verification page with email
        // After verification, navigation will be handled based on chef status
        _navigationProvider.navigateTo(
          AppPage.verification,
          data: {'email': email, 'isChef': isChef},
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
        final response = await ApiService.login(email, password);

        if (response.success) {
          if (kDebugMode) {
            print('Login successful via Django: ${response.message}');
          }

          // Store user data and tokens from Django response
          final userData = response.data;
          if (userData != null) {
            // Save access token if available
            if (userData['access'] != null) {
              await _storageService.saveToken(userData['access']);
            }

            // Extract user object if nested, or use the data directly
            Map<String, dynamic> userDataToSave = userData['user'] ?? userData;

            // Normalize user data - convert ID to string if it's an integer
            if (userDataToSave['id'] != null && userDataToSave['id'] is int) {
              userDataToSave['id'] = userDataToSave['id'].toString();
            }

            // Ensure all required fields have default values and convert types safely
            userDataToSave = {
              'id': userDataToSave['id']?.toString() ?? '',
              'name':
                  userDataToSave['name'] ??
                  userDataToSave['first_name'] ??
                  userDataToSave['username'] ??
                  '',
              'email': userDataToSave['email'] ?? '',
              'phone': userDataToSave['phone']?.toString() ?? '',
              'address': userDataToSave['address']?.toString() ?? '',
              'city': userDataToSave['city']?.toString() ?? '',
              'zipCode':
                  userDataToSave['zipCode']?.toString() ??
                  userDataToSave['zip_code']?.toString() ??
                  '',
              'role': userDataToSave['role']?.toString() ?? 'customer',
              'isChef':
                  userDataToSave['isChef'] ??
                  userDataToSave['is_chef'] ??
                  false,
              'chefBio':
                  userDataToSave['chefBio']?.toString() ??
                  userDataToSave['chef_bio']?.toString(),
              'chefRating': _toDouble(
                userDataToSave['chefRating'] ?? userDataToSave['chef_rating'],
              ),
              'totalOrders': _toInt(
                userDataToSave['totalOrders'] ?? userDataToSave['total_orders'],
              ),
              'isVerified':
                  userDataToSave['isVerified'] ??
                  userDataToSave['is_verified'] ??
                  false,
              'profilePicture':
                  userDataToSave['profilePicture'] ??
                  userDataToSave['profile_picture'],
            };

            await _storageService.saveUserData(userDataToSave);
            _user = User.fromJson(userDataToSave);
            
            // Check if user already has a profile with opposite role
            final existingCustomer = await _storageService.getCustomerProfile();
            final existingChef = await _storageService.getChefProfile();
            final hasBoth = existingCustomer != null && existingChef != null;
            
            // Save to appropriate profile storage
            if (_user!.isChef) {
              await _storageService.saveChefProfile(userDataToSave);
              _chefProfile = _user;
              if (!hasBoth) {
                await _storageService.setActiveProfile('chef');
              }
            } else {
              await _storageService.saveCustomerProfile(userDataToSave);
              _customerProfile = _user;
              if (!hasBoth) {
                await _storageService.setActiveProfile('customer');
              }
            }
            
            // If user has both profiles, show selection screen
            if (hasBoth || (existingCustomer != null && _user!.isChef) || (existingChef != null && !_user!.isChef)) {
              // Load both profiles
              if (existingCustomer != null) {
                _customerProfile = User.fromJson(_normalizeUserData(existingCustomer));
              }
              if (existingChef != null) {
                _chefProfile = User.fromJson(_normalizeUserData(existingChef));
              }
              notifyListeners();
              _navigationProvider.navigateTo(AppPage.profileSelection);
              return;
            }
            
            notifyListeners();

            if (kDebugMode) {
              print('✅ User data saved after login:');
              print('   Name: ${_user?.name}');
              print('   Email: ${_user?.email}');
              print('   Phone: ${_user?.phone}');
              print('   Address: ${_user?.address}');
              print('   City: ${_user?.city}');
              print('   Profile Picture: ${_user?.profilePicture}');
            }
          }

          // Navigate based on user type
          if (_user != null && _user!.isChef) {
            _navigationProvider.navigateTo(AppPage.chefDashboard);
          } else {
            _navigationProvider.navigateTo(AppPage.home);
          }
          return;
        } else {
          // Handle specific error messages from backend
          String errorMessage = response.message ?? 'Login failed';

          // Check for specific error types
          if (response.message?.contains('not registered') == true) {
            throw Exception(
              'This email is not registered. Please sign up first.',
            );
          } else if (response.message?.contains('Invalid password') == true) {
            throw Exception('Invalid password. Please check your credentials.');
          } else if (response.message?.contains('verify your email') == true) {
            throw Exception(
              'Please verify your email before logging in. Check your inbox for the verification code.',
            );
          } else if (response.message?.contains('account has been disabled') ==
              true) {
            throw Exception(
              'Your account has been disabled. Please contact support.',
            );
          } else {
            throw Exception(errorMessage);
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Django backend failed, using fallback mode: $e');

          // Fallback to development mode if Django fails
          if (AppConfig.enableFallbackMode) {
            print(
                'Backend unavailable. Consider using fallback mode for testing.');

            // In a real app, you might want to show a dialog asking the user
            // if they want to use fallback mode or retry
            print('Using development fallback mode for login');

            // Try to load existing user data first to preserve profile picture and other data
            final existingUserData = await _storageService.getUserData();
            
            // Create mock user for development
            final mockUser = {
              'id': existingUserData?['id'] ?? 'user_${DateTime.now().millisecondsSinceEpoch}',
              'name': existingUserData?['name'] ?? email.split('@')[0],
              'email': email,
              'role': existingUserData?['role'] ?? 'customer',
              'isChef': existingUserData?['isChef'] ?? false,
              'isVerified': existingUserData?['isVerified'] ?? true,
              'phone': existingUserData?['phone'] ?? '',
              'address': existingUserData?['address'] ?? '',
              'city': existingUserData?['city'] ?? '',
              'zipCode': existingUserData?['zipCode'] ?? '',
              'profilePicture': existingUserData?['profilePicture'],
              'chefBio': existingUserData?['chefBio'],
              'chefRating': existingUserData?['chefRating'],
              'totalOrders': existingUserData?['totalOrders'],
            };

            // Generate a mock token for fallback mode if not exists
            final existingToken = await _storageService.getToken();
            if (existingToken == null) {
              final mockToken = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
              await _storageService.saveToken(mockToken);
              if (kDebugMode) {
                print('✅ Mock token saved for fallback login mode');
              }
            }

            await _storageService.saveUserData(mockUser);
            _user = User.fromJson(mockUser);
            notifyListeners();

            if (kDebugMode) {
              print('✅ User data saved after login (fallback mode):');
              print('   Name: ${_user?.name}');
              print('   Email: ${_user?.email}');
              print('   Phone: ${_user?.phone}');
              print('   Address: ${_user?.address}');
              print('   City: ${_user?.city}');
              print('   Profile Picture: ${_user?.profilePicture}');
            }

            // Navigate based on user type
            if (_user != null && _user!.isChef) {
              _navigationProvider.navigateTo(AppPage.chefDashboard);
            } else {
              _navigationProvider.navigateTo(AppPage.home);
            }
            return;
          } else {
            setError('Login failed. Please try again later.');
            throw e;
          }
        } else {
          throw e;
        }
      }
    } catch (e) {
      setError('Error occurred during login: $e');
      // Re-throw the error so the UI can handle it appropriately
      throw e;
    } finally {
      setLoading(false);
    }
  }

  // Google Sign-In
  Future<void> signInWithGoogle() async {
    try {
      setLoading(true);
      setError(null);

      // Initialize Google Sign-In
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );

      // Sign out first to ensure fresh sign-in
      await googleSignIn.signOut();

      // Trigger the sign-in flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        setLoading(false);
        return;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.accessToken == null) {
        throw Exception('Failed to obtain Google access token');
      }

      if (kDebugMode) {
        print('✅ Google Sign-In successful');
        print('   Email: ${googleUser.email}');
        print('   Name: ${googleUser.displayName}');
      }

      // Send token to backend
      try {
        final response = await ApiService.googleSignIn(googleAuth.accessToken!);

        if (response.success) {
          if (kDebugMode) {
            print('✅ Google sign-in successful via Django: ${response.message}');
          }

          // Store user data and tokens from Django response
          final userData = response.data;
          if (userData != null) {
            // Save access token if available
            if (userData['access'] != null) {
              await _storageService.saveToken(userData['access']);
            }

            // Extract user object if nested, or use the data directly
            Map<String, dynamic> userDataToSave = userData['user'] ?? userData;

            // Normalize user data - convert ID to string if it's an integer
            if (userDataToSave['id'] != null && userDataToSave['id'] is int) {
              userDataToSave['id'] = userDataToSave['id'].toString();
            }

            // Ensure all required fields have default values and convert types safely
            userDataToSave = {
              'id': userDataToSave['id']?.toString() ?? '',
              'name':
                  userDataToSave['name'] ??
                  userDataToSave['first_name'] ??
                  userDataToSave['username'] ??
                  googleUser.displayName ??
                  '',
              'email': userDataToSave['email'] ?? googleUser.email ?? '',
              'phone': userDataToSave['phone']?.toString() ?? '',
              'address': userDataToSave['address']?.toString() ?? '',
              'city': userDataToSave['city']?.toString() ?? '',
              'zipCode':
                  userDataToSave['zipCode']?.toString() ??
                  userDataToSave['zip_code']?.toString() ??
                  '',
              'role': userDataToSave['role']?.toString() ?? 'customer',
              'isChef':
                  userDataToSave['isChef'] ??
                  userDataToSave['is_chef'] ??
                  false,
              'chefBio':
                  userDataToSave['chefBio']?.toString() ??
                  userDataToSave['chef_bio']?.toString(),
              'chefRating': _toDouble(
                userDataToSave['chefRating'] ?? userDataToSave['chef_rating'],
              ),
              'totalOrders': _toInt(
                userDataToSave['totalOrders'] ?? userDataToSave['total_orders'],
              ),
              'isVerified':
                  userDataToSave['isVerified'] ??
                  userDataToSave['is_verified'] ??
                  true, // Google accounts are pre-verified
              'profilePicture':
                  userDataToSave['profilePicture'] ??
                  userDataToSave['profile_picture'] ??
                  googleUser.photoUrl,
            };

            await _storageService.saveUserData(userDataToSave);
            _user = User.fromJson(userDataToSave);
            
            // Check if user already has a profile with opposite role
            final existingCustomer = await _storageService.getCustomerProfile();
            final existingChef = await _storageService.getChefProfile();
            final hasBoth = existingCustomer != null && existingChef != null;
            
            // Save to appropriate profile storage
            if (_user!.isChef) {
              await _storageService.saveChefProfile(userDataToSave);
              _chefProfile = _user;
              if (!hasBoth) {
                await _storageService.setActiveProfile('chef');
              }
            } else {
              await _storageService.saveCustomerProfile(userDataToSave);
              _customerProfile = _user;
              if (!hasBoth) {
                await _storageService.setActiveProfile('customer');
              }
            }
            
            // If user has both profiles, show selection screen
            if (hasBoth || (existingCustomer != null && _user!.isChef) || (existingChef != null && !_user!.isChef)) {
              // Load both profiles
              if (existingCustomer != null) {
                _customerProfile = User.fromJson(_normalizeUserData(existingCustomer));
              }
              if (existingChef != null) {
                _chefProfile = User.fromJson(_normalizeUserData(existingChef));
              }
              notifyListeners();
              _navigationProvider.navigateTo(AppPage.profileSelection);
              return;
            }
            
            notifyListeners();

            if (kDebugMode) {
              print('✅ User data saved after Google sign-in:');
              print('   Name: ${_user?.name}');
              print('   Email: ${_user?.email}');
              print('   Profile Picture: ${_user?.profilePicture}');
            }
          }

          // Navigate based on user type
          if (_user != null && _user!.isChef) {
            _navigationProvider.navigateTo(AppPage.chefDashboard);
          } else {
            _navigationProvider.navigateTo(AppPage.home);
          }
          return;
        } else {
          throw Exception(response.message ?? 'Google sign-in failed');
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ Google sign-in backend failed: $e');
        }
        throw Exception('Failed to authenticate with Google: $e');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception during Google sign-in: $e');
      }
      setError(e.toString());
      throw Exception('Error occurred during Google sign-in: $e');
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
        final response = await ApiService.verifyEmail(email, code);

        if (response.success) {
          if (kDebugMode) {
            print('✅ Email verification successful via Django backend');
          }

          // Update user verification status
          if (_user != null) {
            _user = _user!.copyWith(isVerified: true);
            final userDataToSave = _user!.toJson();
            await _storageService.saveUserData(userDataToSave);
            notifyListeners();

            if (kDebugMode) {
              print('✅ User data saved after email verification:');
              print('   Name: ${_user?.name}');
              print('   Email: ${_user?.email}');
              print('   Phone: ${_user?.phone}');
              print('   Address: ${_user?.address}');
              print('   City: ${_user?.city}');
              print('   Profile Picture: ${_user?.profilePicture}');
              print('   Is Verified: ${_user?.isVerified}');
            }
          }

          // Navigate based on user type after successful verification
          if (_user != null && _user!.isChef) {
            _navigationProvider.navigateTo(AppPage.chefDashboard);
          } else {
            _navigationProvider.navigateTo(AppPage.home);
          }
          return;
        } else {
          throw Exception('Verification failed: ${response.message}');
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ Django verification failed: $e');
          print('📧 Falling back to development mode');
          
          // Fallback to development mode if Django fails
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
              final userDataToSave = _user!.toJson();
              await _storageService.saveUserData(userDataToSave);
              notifyListeners();

              if (kDebugMode) {
                print('✅ User data saved after email verification (fallback mode):');
                print('   Name: ${_user?.name}');
                print('   Email: ${_user?.email}');
                print('   Phone: ${_user?.phone}');
                print('   Address: ${_user?.address}');
                print('   City: ${_user?.city}');
                print('   Profile Picture: ${_user?.profilePicture}');
                print('   Is Verified: ${_user?.isVerified}');
              }
            }

            print(
              'Email verification successful in development mode for: $email',
            );

            // Navigate based on user type after successful verification
            if (_user != null && _user!.isChef) {
              _navigationProvider.navigateTo(AppPage.chefDashboard);
            } else {
              _navigationProvider.navigateTo(AppPage.home);
            }
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

  Future<void> updateProfile(Map<String, dynamic> profileData) async {
    try {
      setLoading(true);
      setError(null);

      if (_user == null) {
        throw Exception('No user logged in');
      }

      final token = await _storageService.getToken();
      if (token == null) {
        if (kDebugMode) {
          print('❌ No authentication token found');
          print('   User email: ${_user?.email}');
          print('   Attempting to save profile locally only...');
        }
        
        // Fallback: Save profile data locally without backend update
        // This allows profile updates to work even without a token
        final updatedUserData = {
          ..._user!.toJson(),
          ...profileData,
        };
        
        // Convert camelCase to snake_case for storage
        if (profileData.containsKey('zipCode')) {
          updatedUserData['zipCode'] = profileData['zipCode'];
        }
        if (profileData.containsKey('profilePicture')) {
          updatedUserData['profilePicture'] = profileData['profilePicture'];
        }
        
        await _storageService.saveUserData(updatedUserData);
        _user = User.fromJson(updatedUserData);
        
        // Also update profile-specific storage
        if (_user!.isChef) {
          await _storageService.saveChefProfile(updatedUserData);
          _chefProfile = _user;
        } else {
          await _storageService.saveCustomerProfile(updatedUserData);
          _customerProfile = _user;
        }
        
        notifyListeners();
        
        if (kDebugMode) {
          print('✅ Profile updated locally (no backend sync - token missing)');
        }
        
        setLoading(false);
        return; // Exit early - profile saved locally
      }

      // Try Django backend first
      try {
        final response = await ApiService.updateProfile(profileData, token);

        if (response.success) {
          if (kDebugMode) {
            print('✅ Profile updated successfully via Django backend');
          }

          // Update user data from response
          final userData = response.data;
          if (userData != null) {
            // Normalize user data
            Map<String, dynamic> userDataToSave = userData;

            // Ensure all required fields have default values and convert types safely
            userDataToSave = {
              'id': userDataToSave['id']?.toString() ?? _user!.id,
              'name':
                  userDataToSave['name'] ??
                  userDataToSave['first_name'] ??
                  userDataToSave['username'] ??
                  _user!.name,
              'email': userDataToSave['email'] ?? _user!.email,
              'phone': userDataToSave['phone']?.toString() ?? _user!.phone,
              'address':
                  userDataToSave['address']?.toString() ?? _user!.address,
              'city': userDataToSave['city']?.toString() ?? _user!.city,
              'zipCode':
                  userDataToSave['zipCode']?.toString() ??
                  userDataToSave['zip_code']?.toString() ??
                  _user!.zipCode,
              'role': userDataToSave['role']?.toString() ?? 'customer',
              'isChef':
                  userDataToSave['isChef'] ??
                  userDataToSave['is_chef'] ??
                  _user!.isChef,
              'chefBio':
                  userDataToSave['chefBio']?.toString() ??
                  userDataToSave['chef_bio']?.toString() ??
                  _user!.chefBio,
              'chefRating':
                  _toDouble(
                    userDataToSave['chefRating'] ??
                        userDataToSave['chef_rating'],
                  ) ??
                  _user!.chefRating,
              'totalOrders':
                  _toInt(
                    userDataToSave['totalOrders'] ??
                        userDataToSave['total_orders'],
                  ) ??
                  _user!.totalOrders,
              'isVerified':
                  userDataToSave['isVerified'] ??
                  userDataToSave['is_verified'] ??
                  _user!.isVerified,
              'profilePicture':
                  userDataToSave['profilePicture'] ??
                  userDataToSave['profile_picture'] ??
                  profileData['profilePicture'] ??
                  _user!.profilePicture,
            };

            await _storageService.saveUserData(userDataToSave);
            _user = User.fromJson(userDataToSave);
            notifyListeners();

            if (kDebugMode) {
              print('✅ Profile updated and saved:');
              print('   Name: ${_user?.name}');
              print('   Email: ${_user?.email}');
              print('   Phone: ${_user?.phone}');
              print('   Address: ${_user?.address}');
              print('   City: ${_user?.city}');
              print('   ZipCode: ${_user?.zipCode}');
              print('   Profile Picture: ${_user?.profilePicture}');
            }
          }
        } else {
          throw Exception(response.message ?? 'Failed to update profile');
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ Django profile update failed: $e');
        }
        throw e;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception during profile update: $e');
      }
      setError('Error occurred during profile update: $e');
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> loadUser() async {
    try {
      final token = await _storageService.getToken();
      if (token != null) {
        // Check for dual profiles
        final hasBothProfiles = await _storageService.hasBothProfiles();
        
        if (hasBothProfiles) {
          // Load both profiles
          final customerData = await _storageService.getCustomerProfile();
          final chefData = await _storageService.getChefProfile();
          
          if (customerData != null) {
            _customerProfile = User.fromJson(_normalizeUserData(customerData));
          }
          if (chefData != null) {
            _chefProfile = User.fromJson(_normalizeUserData(chefData));
          }
          
          // Load active profile
          final activeProfile = await _storageService.getActiveProfile();
          if (activeProfile == 'chef' && _chefProfile != null) {
            _user = _chefProfile;
          } else if (_customerProfile != null) {
            _user = _customerProfile;
          }
          
          // Ensure token is still available (preserve from storage)
          final existingToken = await _storageService.getToken();
          if (existingToken == null && kDebugMode) {
            print('⚠️ Warning: No token found when loading dual profiles');
          }
          
          notifyListeners();
          
          if (kDebugMode) {
            print('✅ Dual profiles found - Showing profile selection');
            print('   Token available: ${existingToken != null}');
          }
          
          // Navigate to profile selection screen
          _navigationProvider.navigateTo(AppPage.profileSelection);
          return true;
        }
        
        // Single profile - load normally
        final userData = await _storageService.getUserData();
        if (userData != null) {
          final normalizedData = _normalizeUserData(userData);
          _user = User.fromJson(normalizedData);
          
          // If user is chef, also save as chef profile
          if (_user!.isChef) {
            await _storageService.saveChefProfile(normalizedData);
            _chefProfile = _user;
          } else {
            await _storageService.saveCustomerProfile(normalizedData);
            _customerProfile = _user;
          }
          
          // Verify token is still available
          final token = await _storageService.getToken();
          if (token == null && kDebugMode) {
            print('⚠️ Warning: User data loaded but no token found');
            print('   This may cause issues with authenticated API calls');
          }
          
          notifyListeners();

          if (kDebugMode) {
            print('✅ User found in storage - Auto-login successful');
            print('   Name: ${_user?.name}');
            print('   Email: ${_user?.email}');
            print('   Is Chef: ${_user?.isChef}');
            print('   Token available: ${token != null}');
          }

          // Automatically navigate based on user type if user is logged in
          if (_user != null && _user!.isChef) {
            _navigationProvider.navigateTo(AppPage.chefDashboard);
          } else {
            _navigationProvider.navigateTo(AppPage.home);
          }
          return true; // User was found and loaded
        }
      }

      if (kDebugMode) {
        print('ℹ️ No user found in storage - Showing auth selection screen');
      }
      return false; // No user found
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading user data: $e');
        print('Error details: ${e.toString()}');
      }
      return false;
    }
  }

  Future<void> logout() async {
    await _storageService.deleteToken();
    await _storageService.deleteUserData();
    _user = null;
    _navigationProvider.navigateTo(AppPage.authSelection);
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

  /// Refresh user data from storage
  Future<void> refreshUserData() async {
    try {
      final userData = await _storageService.getUserData();
      if (userData != null) {
        final normalizedData = _normalizeUserData(userData);
        _user = User.fromJson(normalizedData);
        notifyListeners();

        if (kDebugMode) {
          print('✅ User data refreshed from storage');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error refreshing user data: $e');
      }
    }
  }

  /// Normalize user data for consistent format
  Map<String, dynamic> _normalizeUserData(Map<String, dynamic> userData) {
    return {
      'id': userData['id']?.toString() ?? '',
      'name': userData['name']?.toString() ?? '',
      'email': userData['email']?.toString() ?? '',
      'phone': userData['phone']?.toString() ?? '',
      'address': userData['address']?.toString() ?? '',
      'city': userData['city']?.toString() ?? '',
      'zipCode': userData['zipCode']?.toString() ?? '',
      'role': userData['role']?.toString() ?? 'customer',
      'isChef': userData['isChef'] ?? false,
      'chefBio': userData['chefBio']?.toString(),
      'chefRating': _toDouble(userData['chefRating']),
      'totalOrders': _toInt(userData['totalOrders']),
      'isVerified': userData['isVerified'] ?? false,
      'profilePicture': userData['profilePicture']?.toString(),
    };
  }

  /// Switch to customer profile
  Future<void> switchToCustomerProfile() async {
    if (_customerProfile != null) {
      // Preserve token before switching
      final currentToken = await _storageService.getToken();
      
      _user = _customerProfile;
      await _storageService.setActiveProfile('customer');
      await _storageService.saveUserData(_user!.toJson());
      
      // Restore token if it was present
      if (currentToken != null) {
        await _storageService.saveToken(currentToken);
      }
      
      notifyListeners();
      
      if (kDebugMode) {
        print('✅ Switched to customer profile');
        print('   Token preserved: ${currentToken != null}');
      }
    }
  }

  /// Switch to chef profile
  Future<void> switchToChefProfile() async {
    if (_chefProfile != null) {
      // Preserve token before switching
      final currentToken = await _storageService.getToken();
      
      _user = _chefProfile;
      await _storageService.setActiveProfile('chef');
      await _storageService.saveUserData(_user!.toJson());
      
      // Restore token if it was present
      if (currentToken != null) {
        await _storageService.saveToken(currentToken);
      }
      
      notifyListeners();
      
      if (kDebugMode) {
        print('✅ Switched to chef profile');
        print('   Token preserved: ${currentToken != null}');
      }
    }
  }

  /// Check if user has both profiles (synchronous getter)
  bool hasBothProfilesSync() {
    return _customerProfile != null && _chefProfile != null;
  }
  
  /// Check if user has both profiles (async)
  Future<bool> hasBothProfiles() async {
    return await _storageService.hasBothProfiles();
  }
}


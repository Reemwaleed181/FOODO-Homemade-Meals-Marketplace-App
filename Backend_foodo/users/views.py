from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth import login
from django.core.mail import send_mail
from django.conf import settings
from django.utils import timezone
from .serializers import LoginSerializer, SignupSerializer, UserSerializer, AddressSerializer
from .models import User, OTP, PasswordResetToken, Address
import json
import requests

@api_view(['POST'])
@permission_classes([AllowAny])
def login_view(request):
    try:
        serializer = LoginSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.validated_data['user']
            login(request, user)
            refresh = RefreshToken.for_user(user)
            return Response({
                'success': True,
                'message': 'Login successful',
                'data': {
                'refresh': str(refresh),
                'access': str(refresh.access_token),
                'user': UserSerializer(user).data
                }
            })
        
        # Handle validation errors with specific messages
        error_messages = []
        for field, errors in serializer.errors.items():
            if field == 'non_field_errors':
                error_messages.extend(errors)
            else:
                error_messages.extend([f"{field}: {error}" for error in errors])
        
        return Response({
            'success': False,
            'message': 'Login failed',
            'errors': error_messages
        }, status=status.HTTP_400_BAD_REQUEST)
        
    except Exception as e:
        return Response({
            'success': False,
            'message': 'An unexpected error occurred during login',
            'errors': [str(e)]
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(['POST'])
@permission_classes([AllowAny])
def signup_view(request):
    try:
        serializer = SignupSerializer(data=request.data)
        if serializer.is_valid():
            # Create the user
            user = serializer.save()
            
            # Log successful user creation for admin visibility
            print(f"✅ New user created successfully: {user.email} (ID: {user.id})")
            print(f"   Username: {user.username}")
            print(f"   Name: {user.get_full_name()}")
            print(f"   Active: {user.is_active}")
            print(f"   Verified: {user.is_verified}")
            print(f"   Date Joined: {user.date_joined}")
            
            # Generate refresh token
            refresh = RefreshToken.for_user(user)
            
            # Immediately generate and send OTP on signup
            try:
                otp = OTP.generate_otp(user, user.email)
                subject = 'Your OTP Code - HomeCook Verification'
                user_display_name = user.get_full_name() if user.get_full_name() else user.username
                message = f'''Hello {user_display_name}!

Your verification code is: {otp.otp_code}

This code expires in 10 minutes.

If you didn't request this code, please ignore this email.

Best regards,
The HomeCook Team'''
                
                # Send email
                send_mail(subject, message, settings.EMAIL_HOST_USER, [user.email])
                
                if settings.DEBUG:
                    print("=== OTP EMAIL SENT ON SIGNUP ===")
                    print(f"To: {user.email}")
                    print(f"OTP Code: {otp.otp_code}")
                    print(f"Expires: {otp.expires_at}")
                    print("===============================")
                    
            except Exception as email_error:
                print(f"❌ Failed to send signup OTP email: {email_error}")
                if settings.DEBUG:
                    print("=== OTP EMAIL (SIGNUP FALLBACK) ===")
                    print(f"To: {user.email}")
                    print(f"OTP Code: {otp.otp_code}")
                    print(f"Expires: {otp.expires_at}")
                    print("===================================")
            
            return Response({
                'success': True,
                'message': 'User registered successfully. Please check your email for verification code.',
                'data': {
                'refresh': str(refresh),
                'access': str(refresh.access_token),
                'user': UserSerializer(user).data
                }
            }, status=status.HTTP_201_CREATED)
        else:
            # Log validation errors for admin debugging
            print(f"❌ User registration validation failed: {serializer.errors}")
            return Response({
                'success': False,
                'message': 'Registration failed due to validation errors',
                'errors': serializer.errors
            }, status=status.HTTP_400_BAD_REQUEST)
            
    except Exception as e:
        # Log unexpected errors for admin debugging
        print(f"❌ Unexpected error during user registration: {e}")
        return Response({
            'success': False,
            'message': f'Registration failed: {str(e)}'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(['POST'])
@permission_classes([AllowAny])
def send_otp(request):
    try:
        data = json.loads(request.body)
        email = data.get('email')
        
        if not email:
            return Response({
                'success': False,
                'message': 'Email is required'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            user = User.objects.get(email=email)
        except User.DoesNotExist:
            return Response({
                'success': False,
                'message': 'User not found'
            }, status=status.HTTP_404_NOT_FOUND)
        
        # Generate OTP
        otp = OTP.generate_otp(user, email)
        
        if settings.DEBUG:
            print(f"=== OTP GENERATED ===")
            print(f"User: {user.email}")
            print(f"OTP Code: {otp.otp_code}")
            print(f"Expires: {otp.expires_at}")
            print(f"===============================")
        
        # Send email with OTP (always send actual email)
        try:
            subject = 'Your OTP Code - HomeCook Verification'
            # Get user's display name
            user_display_name = user.get_full_name() if user.get_full_name() else user.username
            
            message = f'''Hello {user_display_name}!

Your verification code is: {otp.otp_code}

This code expires in 10 minutes.

If you didn't request this code, please ignore this email.

Best regards,
The HomeCook Team'''
            
            send_mail(subject, message, settings.EMAIL_HOST_USER, [email])
            
            if settings.DEBUG:
                print(f"=== OTP EMAIL SENT ===")
                print(f"To: {email}")
                print(f"OTP Code: {otp.otp_code}")
                print(f"Expires: {otp.expires_at}")
                print(f"============================")
                
        except Exception as email_error:
            print(f"Failed to send email: {email_error}")
            # Still return success but log the email error
            if settings.DEBUG:
                print(f"=== OTP EMAIL (FALLBACK) ===")
                print(f"To: {email}")
                print(f"OTP Code: {otp.otp_code}")
                print(f"Expires: {otp.expires_at}")
                print(f"============================")
        
        return Response({
            'success': True,
            'message': 'OTP sent successfully'
        })
        
    except Exception as e:
        return Response({
            'success': False,
            'message': f'Failed to send OTP: {str(e)}'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(['POST'])
@permission_classes([AllowAny])
def verify_email(request):
    try:
        data = json.loads(request.body)
        email = data.get('email')
        code = data.get('code')
        
        if not email or not code:
            return Response({
                'success': False,
                'message': 'Email and code are required'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            user = User.objects.get(email=email)
        except User.DoesNotExist:
            return Response({
                'success': False,
                'message': 'User not found'
            }, status=status.HTTP_404_NOT_FOUND)
        
        # Find valid OTP
        try:
            otp = OTP.objects.get(user=user, email=email, otp_code=code, is_used=False)
        except OTP.DoesNotExist:
            return Response({
                'success': False,
                'message': 'Invalid OTP code'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Check if OTP is expired
        if otp.is_expired():
            return Response({
                'success': False,
                'message': 'OTP code has expired'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Mark OTP as used
        otp.is_used = True
        otp.save()
        
        # Mark user as verified
        user.is_verified = True
        user.save()
        
        return Response({
            'success': True,
            'message': 'Email verified successfully',
            'data': UserSerializer(user).data
        })
        
    except Exception as e:
        return Response({
            'success': False,
            'message': f'Verification failed: {str(e)}'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(['POST'])
@permission_classes([AllowAny])
def resend_otp(request):
    try:
        data = json.loads(request.body)
        email = data.get('email')
        
        if not email:
            return Response({
                'success': False,
                'message': 'Email is required'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            user = User.objects.get(email=email)
        except User.DoesNotExist:
            return Response({
                'success': False,
                'message': 'User not found'
            }, status=status.HTTP_404_NOT_FOUND)
        
        # Generate new OTP
        otp = OTP.generate_otp(user, email)
        
        # Send email with new OTP
        if settings.DEBUG:
            # In development, just print to console
            print(f"=== OTP RESENT (DEV MODE) ===")
            print(f"To: {email}")
            print(f"New OTP Code: {otp.otp_code}")
            print(f"Expires: {otp.expires_at}")
            print(f"=============================")
        else:
            # In production, send actual email
            subject = 'Your New OTP Code'
            message = f'Your new verification code is: {otp.otp_code}\n\nThis code expires in 10 minutes.'
            send_mail(subject, message, settings.EMAIL_HOST_USER, [email])
        
        return Response({
            'success': True,
            'message': 'OTP resent successfully'
        })
        
    except Exception as e:
        return Response({
            'success': False,
            'message': f'Failed to resend OTP: {str(e)}'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(['GET'])
def current_user(request):
    serializer = UserSerializer(request.user)
    return Response({
        'success': True,
        'data': serializer.data
    })

@api_view(['PUT', 'PATCH'])
@permission_classes([IsAuthenticated])
def update_profile(request):
    """Update the current user's profile"""
    try:
        user = request.user
        data = request.data.copy()
        
        # Handle name field - split into first_name and last_name
        if 'name' in data:
            name = data.pop('name', '').strip()
            if name:
                name_parts = name.split(' ', 1)
                data['first_name'] = name_parts[0]
                if len(name_parts) > 1:
                    data['last_name'] = name_parts[1]
                else:
                    data['last_name'] = ''
        
        # Convert camelCase to snake_case for Django
        if 'zipCode' in data:
            data['zip_code'] = data.pop('zipCode')
        if 'chefBio' in data:
            data['chef_bio'] = data.pop('chefBio')
        if 'profilePicture' in data:
            data['profile_picture'] = data.pop('profilePicture')
        
        # Check if email is being changed and if it's unique
        if 'email' in data and data['email'] != user.email:
            email = data['email']
            if User.objects.filter(email=email).exclude(id=user.id).exists():
                return Response({
                    'success': False,
                    'message': 'Email already exists',
                    'errors': {'email': ['This email is already registered']}
                }, status=status.HTTP_400_BAD_REQUEST)
        
        # Check if username is being changed and if it's unique
        if 'username' in data and data['username'] != user.username:
            username = data['username']
            if User.objects.filter(username=username).exclude(id=user.id).exists():
                return Response({
                    'success': False,
                    'message': 'Username already exists',
                    'errors': {'username': ['This username is already taken']}
                }, status=status.HTTP_400_BAD_REQUEST)
        
        # Use UserSerializer for validation and update
        serializer = UserSerializer(user, data=data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response({
                'success': True,
                'message': 'Profile updated successfully',
                'data': serializer.data
            })
        else:
            return Response({
                'success': False,
                'message': 'Validation failed',
                'errors': serializer.errors
            }, status=status.HTTP_400_BAD_REQUEST)
            
    except Exception as e:
        return Response({
            'success': False,
            'message': f'Failed to update profile: {str(e)}'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(['POST'])
@permission_classes([AllowAny])
def forgot_password(request):
    """Request password reset - sends OTP via email"""
    try:
        data = json.loads(request.body)
        email = data.get('email')
        
        if not email:
            return Response({
                'success': False,
                'message': 'Email is required'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            user = User.objects.get(email=email)
        except User.DoesNotExist:
            return Response({
                'success': False,
                'message': 'User not found'
            }, status=status.HTTP_404_NOT_FOUND)
        
        # Generate OTP for password reset
        otp = OTP.generate_otp(user, email)
        
        if settings.DEBUG:
            print(f"=== FORGOT PASSWORD OTP GENERATED ===")
            print(f"User: {user.email}")
            print(f"OTP Code: {otp.otp_code}")
            print(f"Expires: {otp.expires_at}")
            print(f"Is Used: {otp.is_used}")
            print(f"===============================")
        
        # Send email with OTP
        try:
            subject = 'Password Reset OTP - HomeCook'
            user_display_name = user.get_full_name() if user.get_full_name() else user.username
            
            message = f'''Hello {user_display_name}!

You requested a password reset for your HomeCook account.

Your verification code is: {otp.otp_code}

This code expires in 10 minutes.

If you didn't request this reset, please ignore this email.

Best regards,
The HomeCook Team'''
            
            send_mail(subject, message, settings.EMAIL_HOST_USER, [email])
            
            if settings.DEBUG:
                print(f"=== PASSWORD RESET OTP SENT ===")
                print(f"To: {email}")
                print(f"OTP Code: {otp.otp_code}")
                print(f"Expires: {otp.expires_at}")
                print(f"================================")
                
        except Exception as email_error:
            print(f"Failed to send password reset OTP email: {email_error}")
            # Still return success but log the email error
            if settings.DEBUG:
                print(f"=== PASSWORD RESET OTP (FALLBACK) ===")
                print(f"To: {email}")
                print(f"OTP Code: {otp.otp_code}")
                print(f"Expires: {otp.expires_at}")
                print(f"=====================================")
        
        return Response({
            'success': True,
            'message': 'Password reset OTP sent to your email'
        })
        
    except Exception as e:
        return Response({
            'success': False,
            'message': f'Failed to process password reset request: {str(e)}'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(['POST'])
@permission_classes([AllowAny])
def verify_password_reset_otp(request):
    """Verify OTP for password reset"""
    try:
        data = json.loads(request.body)
        email = data.get('email')
        otp_code = data.get('otp_code')
        
        if not email or not otp_code:
            return Response({
                'success': False,
                'message': 'Email and OTP code are required'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            user = User.objects.get(email=email)
        except User.DoesNotExist:
            return Response({
                'success': False,
                'message': 'User not found'
            }, status=status.HTTP_404_NOT_FOUND)
        
        # Verify OTP
        try:
            if settings.DEBUG:
                print(f"=== OTP VERIFICATION REQUEST ===")
                print(f"Email: {email}")
                print(f"OTP Code: {otp_code}")
                print(f"===============================")
                
                # Debug: Check what OTPs exist for this user
                all_otps = OTP.objects.filter(user=user)
                print(f"All OTPs for user: {[f'{o.otp_code}(used:{o.is_used},expires:{o.expires_at})' for o in all_otps]}")
            
            otp = OTP.objects.get(user=user, otp_code=otp_code, is_used=False)
            
            if settings.DEBUG:
                print(f"OTP found: {otp.otp_code}, expires: {otp.expires_at}, is_used: {otp.is_used}")
            
            # Check if OTP is expired
            if otp.is_expired():
                if settings.DEBUG:
                    print(f"OTP expired: {otp.expires_at}")
                return Response({
                    'success': False,
                    'message': 'OTP has expired'
                }, status=status.HTTP_400_BAD_REQUEST)
            
            return Response({
                'success': True,
                'message': 'OTP verified successfully'
            })
            
        except OTP.DoesNotExist:
            if settings.DEBUG:
                print(f"OTP not found: user={user.email}, code={otp_code}")
                # Debug: Check what OTPs exist for this user
                all_otps = OTP.objects.filter(user=user)
                print(f"Available OTPs: {[f'{o.otp_code}(used:{o.is_used},expires:{o.expires_at})' for o in all_otps]}")
            return Response({
                'success': False,
                'message': 'Invalid OTP code'
            }, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            if settings.DEBUG:
                print(f"Unexpected error during OTP verification: {str(e)}")
                print(f"Error type: {type(e)}")
                import traceback
                print(f"Traceback: {traceback.format_exc()}")
            return Response({
                'success': False,
                'message': f'OTP verification failed: {str(e)}'
            }, status=status.HTTP_400_BAD_REQUEST)
        
    except Exception as e:
        return Response({
            'success': False,
            'message': f'Failed to verify OTP: {str(e)}'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(['POST'])
@permission_classes([AllowAny])
def reset_password(request):
    """Reset password using email and OTP verification"""
    try:
        data = json.loads(request.body)
        email = data.get('email')
        otp_code = data.get('otp_code')
        new_password = data.get('new_password')
        
        if settings.DEBUG:
            print(f"=== RESET PASSWORD REQUEST ===")
            print(f"Email: {email}")
            print(f"OTP Code: {otp_code}")
            print(f"New Password Length: {len(new_password) if new_password else 0}")
            print(f"===============================")
        
        if not email or not otp_code or not new_password:
            return Response({
                'success': False,
                'message': 'Email, OTP code, and new password are required'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        if len(new_password) < 6:
            return Response({
                'success': False,
                'message': 'Password must be at least 6 characters long'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            user = User.objects.get(email=email)
        except User.DoesNotExist:
            return Response({
                'success': False,
                'message': 'User not found'
            }, status=status.HTTP_404_NOT_FOUND)
        
        # Verify OTP again for security
        try:
            if settings.DEBUG:
                print(f"=== OTP VERIFICATION ===")
                print(f"Looking for OTP: user={user.email}, code={otp_code}, is_used=False")
                
                # Debug: Check what OTPs exist for this user
                all_otps = OTP.objects.filter(user=user)
                print(f"All OTPs for user: {[f'{o.otp_code}(used:{o.is_used},expires:{o.expires_at})' for o in all_otps]}")
            
            otp = OTP.objects.get(user=user, otp_code=otp_code, is_used=False)
            
            if settings.DEBUG:
                print(f"OTP found: {otp.otp_code}, expires: {otp.expires_at}, is_used: {otp.is_used}")
            
            # Check if OTP is expired
            if otp.is_expired():
                if settings.DEBUG:
                    print(f"OTP expired: {otp.expires_at}")
                return Response({
                    'success': False,
                    'message': 'OTP has expired'
                }, status=status.HTTP_400_BAD_REQUEST)
            
            # Mark OTP as used
            otp.is_used = True
            otp.save()
            
        except OTP.DoesNotExist:
            if settings.DEBUG:
                print(f"OTP not found: user={user.email}, code={otp_code}")
                # Debug: Check what OTPs exist for this user
                all_otps = OTP.objects.filter(user=user)
                print(f"Available OTPs: {[f'{o.otp_code}(used:{o.is_used},expires:{o.expires_at})' for o in all_otps]}")
            return Response({
                'success': False,
                'message': 'Invalid OTP code'
            }, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            if settings.DEBUG:
                print(f"Unexpected error during OTP lookup: {str(e)}")
                print(f"Error type: {type(e)}")
                import traceback
                print(f"Traceback: {traceback.format_exc()}")
            return Response({
                'success': False,
                'message': f'OTP verification failed: {str(e)}'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Update user password
        user.set_password(new_password)
        user.save()
        
        if settings.DEBUG:
            print(f"=== PASSWORD RESET SUCCESSFUL ===")
            print(f"User: {user.email}")
            print(f"OTP: {otp_code}")
            print(f"===============================")
        
        return Response({
            'success': True,
            'message': 'Password reset successfully'
        })
        
    except Exception as e:
        return Response({
            'success': False,
            'message': f'Failed to reset password: {str(e)}'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

# Address Management Endpoints
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_addresses(request):
    """Get all addresses for the current user"""
    try:
        addresses = Address.objects.filter(user=request.user)
        serializer = AddressSerializer(addresses, many=True)
        return Response({
            'success': True,
            'data': serializer.data
        })
    except Exception as e:
        return Response({
            'success': False,
            'message': f'Failed to fetch addresses: {str(e)}'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_address(request):
    """Create a new address for the current user"""
    try:
        data = request.data
        
        # If setting as default, unset other defaults
        if data.get('is_default', False) or data.get('isDefault', False):
            Address.objects.filter(user=request.user, is_default=True).update(is_default=False)
        
        # Convert camelCase to snake_case for Django
        if 'fullName' in data:
            data['full_name'] = data.pop('fullName')
        if 'streetAddress' in data:
            data['street_address'] = data.pop('streetAddress')
        if 'zipCode' in data:
            data['zip_code'] = data.pop('zipCode')
        if 'isDefault' in data:
            data['is_default'] = data.pop('isDefault')
        
        serializer = AddressSerializer(data=data)
        if serializer.is_valid():
            address = serializer.save(user=request.user)
            return Response({
                'success': True,
                'message': 'Address created successfully',
                'data': AddressSerializer(address).data
            }, status=status.HTTP_201_CREATED)
        else:
            return Response({
                'success': False,
                'message': 'Validation failed',
                'errors': serializer.errors
            }, status=status.HTTP_400_BAD_REQUEST)
    except Exception as e:
        return Response({
            'success': False,
            'message': f'Failed to create address: {str(e)}'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(['PUT', 'PATCH'])
@permission_classes([IsAuthenticated])
def update_address(request, address_id):
    """Update an existing address"""
    try:
        try:
            address = Address.objects.get(id=address_id, user=request.user)
        except Address.DoesNotExist:
            return Response({
                'success': False,
                'message': 'Address not found'
            }, status=status.HTTP_404_NOT_FOUND)
        
        data = request.data.copy()
        
        # If setting as default, unset other defaults
        if data.get('is_default', False) or data.get('isDefault', False):
            Address.objects.filter(user=request.user, is_default=True).exclude(id=address_id).update(is_default=False)
        
        # Convert camelCase to snake_case for Django
        if 'fullName' in data:
            data['full_name'] = data.pop('fullName')
        if 'streetAddress' in data:
            data['street_address'] = data.pop('streetAddress')
        if 'zipCode' in data:
            data['zip_code'] = data.pop('zipCode')
        if 'isDefault' in data:
            data['is_default'] = data.pop('isDefault')
        
        serializer = AddressSerializer(address, data=data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response({
                'success': True,
                'message': 'Address updated successfully',
                'data': serializer.data
            })
        else:
            return Response({
                'success': False,
                'message': 'Validation failed',
                'errors': serializer.errors
            }, status=status.HTTP_400_BAD_REQUEST)
    except Exception as e:
        return Response({
            'success': False,
            'message': f'Failed to update address: {str(e)}'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def delete_address(request, address_id):
    """Delete an address"""
    try:
        try:
            address = Address.objects.get(id=address_id, user=request.user)
        except Address.DoesNotExist:
            return Response({
                'success': False,
                'message': 'Address not found'
            }, status=status.HTTP_404_NOT_FOUND)
        
        address.delete()
        return Response({
            'success': True,
            'message': 'Address deleted successfully'
        })
    except Exception as e:
        return Response({
            'success': False,
            'message': f'Failed to delete address: {str(e)}'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def set_default_address(request, address_id):
    """Set an address as default"""
    try:
        try:
            address = Address.objects.get(id=address_id, user=request.user)
        except Address.DoesNotExist:
            return Response({
                'success': False,
                'message': 'Address not found'
            }, status=status.HTTP_404_NOT_FOUND)
        
        # Unset all other defaults
        Address.objects.filter(user=request.user).exclude(id=address_id).update(is_default=False)
        
        # Set this address as default
        address.is_default = True
        address.save()
        
        return Response({
            'success': True,
            'message': 'Default address updated successfully',
            'data': AddressSerializer(address).data
        })
    except Exception as e:
        return Response({
            'success': False,
            'message': f'Failed to set default address: {str(e)}'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(['POST'])
@permission_classes([AllowAny])
def google_signin(request):
    """Handle Google Sign-In authentication"""
    try:
        data = json.loads(request.body)
        access_token = data.get('access_token')
        
        if not access_token:
            return Response({
                'success': False,
                'message': 'Google access token is required'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Verify the Google token and get user info
        try:
            # Verify token with Google
            google_response = requests.get(
                'https://www.googleapis.com/oauth2/v2/userinfo',
                headers={'Authorization': f'Bearer {access_token}'}
            )
            
            if google_response.status_code != 200:
                return Response({
                    'success': False,
                    'message': 'Invalid Google token'
                }, status=status.HTTP_400_BAD_REQUEST)
            
            google_user_data = google_response.json()
            google_email = google_user_data.get('email')
            google_name = google_user_data.get('name', '')
            google_picture = google_user_data.get('picture', '')
            google_id = google_user_data.get('id', '')
            
            if not google_email:
                return Response({
                    'success': False,
                    'message': 'Email not provided by Google'
                }, status=status.HTTP_400_BAD_REQUEST)
            
            # Check if user exists
            try:
                user = User.objects.get(email=google_email)
                # User exists, just log them in
                if not user.is_active:
                    return Response({
                        'success': False,
                        'message': 'Account is deactivated'
                    }, status=status.HTTP_400_BAD_REQUEST)
                
                # Update user info from Google if needed
                if google_picture and not user.profile_picture:
                    user.profile_picture = google_picture
                if google_name and not user.get_full_name():
                    name_parts = google_name.split(' ', 1)
                    user.first_name = name_parts[0]
                    if len(name_parts) > 1:
                        user.last_name = name_parts[1]
                    user.save()
                
            except User.DoesNotExist:
                # Create new user from Google account
                name_parts = google_name.split(' ', 1) if google_name else ['User', '']
                username = google_email.split('@')[0]
                
                # Ensure username is unique
                base_username = username
                counter = 1
                while User.objects.filter(username=username).exists():
                    username = f"{base_username}{counter}"
                    counter += 1
                
                # Create user without password (Google OAuth users)
                user = User(
                    username=username,
                    email=google_email,
                    first_name=name_parts[0],
                    last_name=name_parts[1] if len(name_parts) > 1 else '',
                    profile_picture=google_picture if google_picture else '',
                    is_active=True,
                    is_verified=True,  # Google accounts are pre-verified
                    is_chef=False,
                )
                # Set an unusable password for Google OAuth users
                user.set_unusable_password()
                user.save()
                
                if settings.DEBUG:
                    print(f"✅ New Google user created: {user.email} (ID: {user.id})")
            
            # Generate JWT tokens
            refresh = RefreshToken.for_user(user)
            login(request, user)
            
            return Response({
                'success': True,
                'message': 'Google sign-in successful',
                'data': {
                    'refresh': str(refresh),
                    'access': str(refresh.access_token),
                    'user': UserSerializer(user).data
                }
            }, status=status.HTTP_200_OK)
            
        except requests.RequestException as e:
            if settings.DEBUG:
                print(f"❌ Google API request failed: {e}")
            return Response({
                'success': False,
                'message': 'Failed to verify Google token'
            }, status=status.HTTP_400_BAD_REQUEST)
            
    except Exception as e:
        if settings.DEBUG:
            print(f"❌ Google sign-in error: {e}")
        return Response({
            'success': False,
            'message': f'Google sign-in failed: {str(e)}'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
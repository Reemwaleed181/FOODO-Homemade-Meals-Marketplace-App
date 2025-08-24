from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth import login
from django.core.mail import send_mail
from django.conf import settings
from django.utils import timezone
from .serializers import LoginSerializer, SignupSerializer, UserSerializer
from .models import User, OTP
import json

@api_view(['POST'])
@permission_classes([AllowAny])
def login_view(request):
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
    return Response({
        'success': False,
        'message': 'Login failed',
        'errors': serializer.errors
    }, status=status.HTTP_400_BAD_REQUEST)

@api_view(['POST'])
@permission_classes([AllowAny])
def signup_view(request):
    serializer = SignupSerializer(data=request.data)
    if serializer.is_valid():
        user = serializer.save()
        refresh = RefreshToken.for_user(user)
        return Response({
            'success': True,
            'message': 'User registered successfully',
            'data': {
            'refresh': str(refresh),
            'access': str(refresh.access_token),
            'user': UserSerializer(user).data
            }
        }, status=status.HTTP_201_CREATED)
    return Response({
        'success': False,
        'message': 'Registration failed',
        'errors': serializer.errors
    }, status=status.HTTP_400_BAD_REQUEST)

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
        
        # Send email with OTP (always send actual email)
        try:
            subject = 'Your OTP Code - HomeCook Verification'
            message = f'''Hello {user.name or user.username}!

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
#!/usr/bin/env python3
"""
Comprehensive test script for email functionality
Tests OTP sending, verification, and forgot password
"""

import os
import sys
import django
import json
from datetime import datetime

# Add the project directory to Python path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

# Set up Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'homecook_backend.settings')
django.setup()

from django.core.mail import send_mail
from django.conf import settings
from users.models import User, OTP, PasswordResetToken
from users.serializers import UserSerializer

def test_email_configuration():
    """Test if email configuration is working"""
    print("🧪 Testing Email Configuration")
    print("=" * 50)
    
    print(f"EMAIL_BACKEND: {settings.EMAIL_BACKEND}")
    print(f"EMAIL_HOST: {settings.EMAIL_HOST}")
    print(f"EMAIL_PORT: {settings.EMAIL_PORT}")
    print(f"EMAIL_HOST_USER: {settings.EMAIL_HOST_USER}")
    print(f"EMAIL_USE_TLS: {settings.EMAIL_USE_TLS}")
    print(f"DEBUG: {settings.DEBUG}")
    
    if settings.DEBUG:
        print("⚠️  DEBUG is True - emails will be printed to console only")
    else:
        print("✅ DEBUG is False - emails will be sent to real addresses")
    
    return True

def test_send_test_email():
    """Test sending a test email"""
    print("\n🧪 Testing Email Sending")
    print("=" * 50)
    
    try:
        subject = 'Test Email from HomeCook Backend'
        message = f'''Hello!

This is a test email from your HomeCook backend.

Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
Backend: Django
Email Backend: {settings.EMAIL_BACKEND}

If you receive this, email is working!'''
        
        recipient_email = 'reem.waleed.ahmed@gmail.com'
        
        print(f"Sending test email to: {recipient_email}")
        print(f"Subject: {subject}")
        
        # Send the email
        result = send_mail(
            subject=subject,
            message=message,
            from_email=settings.EMAIL_HOST_USER,
            recipient_list=[recipient_email],
            fail_silently=False
        )
        
        print(f"Email sent successfully: {result}")
        print("✅ Test email sent!")
        
        if settings.DEBUG:
            print("📧 Check your console/terminal for the email content")
        else:
            print("📧 Check your email inbox for the test message")
        
        return True
        
    except Exception as e:
        print(f"❌ Failed to send test email: {e}")
        return False

def test_otp_generation():
    """Test OTP generation and email sending"""
    print("\n🧪 Testing OTP Generation and Email")
    print("=" * 50)
    
    try:
        # Get or create a test user
        user, created = User.objects.get_or_create(
            email='reem.waleed.ahmed@gmail.com',
            defaults={
                'username': 'testuser',
                'first_name': 'Test',
                'last_name': 'User'
            }
        )
        
        if created:
            print(f"✅ Created test user: {user.email}")
        else:
            print(f"✅ Using existing user: {user.email}")
        
        # Generate OTP
        otp = OTP.generate_otp(user, user.email)
        print(f"✅ OTP generated: {otp.otp_code}")
        print(f"✅ OTP expires: {otp.expires_at}")
        
        # Send OTP email
        subject = 'Your OTP Code - HomeCook Verification'
        message = f'''Hello {user.get_full_name() or user.username}!

Your verification code is: {otp.otp_code}

This code expires in 10 minutes.

If you didn't request this code, please ignore this email.

Best regards,
The HomeCook Team'''
        
        print(f"Sending OTP email to: {user.email}")
        result = send_mail(subject, message, settings.EMAIL_HOST_USER, [user.email])
        
        print(f"OTP email sent successfully: {result}")
        print("✅ OTP generation and email test passed!")
        
        return True
        
    except Exception as e:
        print(f"❌ OTP test failed: {e}")
        return False

def test_forgot_password_flow():
    """Test the complete forgot password flow"""
    print("\n🧪 Testing Forgot Password Flow")
    print("=" * 50)
    
    try:
        # Get the test user
        user = User.objects.get(email='reem.waleed.ahmed@gmail.com')
        
        # Generate password reset token
        reset_token = PasswordResetToken.generate_token(user)
        print(f"✅ Reset token generated: {reset_token.token[:20]}...")
        print(f"✅ Token expires: {reset_token.expires_at}")
        
        # Send password reset email
        subject = 'Password Reset Request - HomeCook'
        message = f'''Hello {user.get_full_name() or user.username}!

You requested a password reset for your HomeCook account.

To reset your password, use this token: {reset_token.token}

This token expires in 1 hour.

If you didn't request this reset, please ignore this email.

Best regards,
The HomeCook Team'''
        
        print(f"Sending password reset email to: {user.email}")
        result = send_mail(subject, message, settings.EMAIL_HOST_USER, [user.email])
        
        print(f"Password reset email sent successfully: {result}")
        print("✅ Forgot password flow test passed!")
        
        return True
        
    except Exception as e:
        print(f"❌ Forgot password test failed: {e}")
        return False

def main():
    """Run all email functionality tests"""
    print("🚀 Starting Email Functionality Tests")
    print("=" * 60)
    
    tests = [
        test_email_configuration,
        test_send_test_email,
        test_otp_generation,
        test_forgot_password_flow,
    ]
    
    passed = 0
    total = len(tests)
    
    for test in tests:
        try:
            if test():
                passed += 1
        except Exception as e:
            print(f"❌ Test failed with exception: {e}")
    
    print("\n" + "=" * 60)
    print(f"📊 Test Results: {passed}/{total} tests passed")
    
    if passed == total:
        print("🎉 All email functionality tests passed!")
    elif passed > 0:
        print("⚠️  Some tests failed. Check the output above for details.")
    else:
        print("❌ All tests failed. Check the output above for details.")
    
    print("\n📧 Email Summary:")
    if settings.DEBUG:
        print("   - Emails are being printed to console (DEBUG mode)")
        print("   - Check your terminal/console for email content")
    else:
        print("   - Emails are being sent to real addresses")
        print("   - Check your email inbox for messages")

if __name__ == "__main__":
    main()

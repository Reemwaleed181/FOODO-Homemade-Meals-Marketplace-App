#!/usr/bin/env python
"""
Test script to verify Django backend is working properly
Run this from the Backend_foodo directory
"""

import os
import sys
import django

# Add the project directory to Python path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

# Set up Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'homecook_backend.settings')
django.setup()

from django.contrib.auth import get_user_model
from users.models import OTP
from django.core.mail import send_mail
from django.conf import settings

User = get_user_model()

def test_database():
    """Test database connection and models"""
    print("🔍 Testing database connection...")
    try:
        # Check if we can query the database
        user_count = User.objects.count()
        print(f"✅ Database connection successful. Users count: {user_count}")
        
        # List existing users
        if user_count > 0:
            print("\n📋 Existing users:")
            for user in User.objects.all():
                print(f"  - {user.email} (ID: {user.id}, Verified: {user.is_verified})")
        else:
            print("📝 No users found in database")
            
    except Exception as e:
        print(f"❌ Database error: {e}")
        return False
    return True

def test_email_config():
    """Test email configuration"""
    print("\n📧 Testing email configuration...")
    try:
        print(f"Email backend: {settings.EMAIL_BACKEND}")
        print(f"Email host: {settings.EMAIL_HOST}")
        print(f"Email port: {settings.EMAIL_PORT}")
        print(f"Email user: {settings.EMAIL_HOST_USER}")
        print(f"Email TLS: {settings.EMAIL_USE_TLS}")
        
        if settings.EMAIL_BACKEND == 'django.core.mail.backends.console.EmailBackend':
            print("✅ Using console email backend (emails will be printed to console)")
        elif settings.EMAIL_BACKEND == 'django.core.mail.backends.smtp.EmailBackend':
            print("✅ Using SMTP email backend")
        else:
            print("⚠️ Unknown email backend")
            
    except Exception as e:
        print(f"❌ Email config error: {e}")
        return False
    return True

def test_create_test_user():
    """Create a test user if none exists"""
    print("\n👤 Testing user creation...")
    try:
        if User.objects.count() == 0:
            # Create a test user
            test_user = User.objects.create_user(
                username='testuser',
                email='test@foodo.com',
                password='testpass123',
                first_name='Test',
                last_name='User'
            )
            print(f"✅ Test user created: {test_user.email}")
            return test_user
        else:
            print("✅ Users already exist, skipping test user creation")
            return User.objects.first()
    except Exception as e:
        print(f"❌ User creation error: {e}")
        return None

def test_otp_generation():
    """Test OTP generation"""
    print("\n🔐 Testing OTP generation...")
    try:
        user = User.objects.first()
        if user:
            otp = OTP.generate_otp(user, user.email)
            print(f"✅ OTP generated: {otp.otp_code}")
            print(f"   Expires: {otp.expires_at}")
            print(f"   Valid: {otp.is_valid()}")
            return otp
        else:
            print("⚠️ No user found to test OTP generation")
            return None
    except Exception as e:
        print(f"❌ OTP generation error: {e}")
        return None

def test_api_endpoints():
    """Test if API endpoints are accessible"""
    print("\n🌐 Testing API endpoints...")
    try:
        from django.urls import reverse
        from django.test import Client
        
        client = Client()
        
        # Test signup endpoint
        signup_url = '/api/auth/signup/'
        response = client.get(signup_url)
        print(f"✅ Signup endpoint accessible: {response.status_code}")
        
        # Test login endpoint
        login_url = '/api/auth/login/'
        response = client.get(login_url)
        print(f"✅ Login endpoint accessible: {response.status_code}")
        
        # Test OTP endpoint
        otp_url = '/api/send-otp/'
        response = client.get(otp_url)
        print(f"✅ OTP endpoint accessible: {response.status_code}")
        
    except Exception as e:
        print(f"❌ API endpoint test error: {e}")
        return False
    return True

def main():
    """Run all tests"""
    print("🚀 Starting Django backend tests...\n")
    
    tests = [
        test_database,
        test_email_config,
        test_create_test_user,
        test_otp_generation,
        test_api_endpoints,
    ]
    
    passed = 0
    total = len(tests)
    
    for test in tests:
        try:
            if test():
                passed += 1
        except Exception as e:
            print(f"❌ Test {test.__name__} failed with exception: {e}")
    
    print(f"\n📊 Test Results: {passed}/{total} tests passed")
    
    if passed == total:
        print("🎉 All tests passed! Your Django backend is ready.")
        print("\n📝 Next steps:")
        print("1. Start Django server: python manage.py runserver")
        print("2. Test Flutter app connection")
        print("3. Create admin user: python manage.py createsuperuser")
    else:
        print("⚠️ Some tests failed. Check the errors above.")
    
    return passed == total

if __name__ == '__main__':
    main()

#!/usr/bin/env python
"""
Test OTP Functionality using Django's built-in test client
Run this to test your Django OTP endpoints without external dependencies
"""

import os
import sys
import django
from datetime import datetime

# Add the project directory to Python path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

# Set Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'homecook_backend.settings')

# Setup Django
django.setup()

from django.test import Client
from django.urls import reverse
import json

def test_otp_endpoints():
    print("🧪 Testing Django OTP Endpoints (Native)...\n")
    
    client = Client()
    
    # Test data - using unique email to avoid conflicts
    timestamp = int(datetime.now().timestamp())
    test_email = f"test{timestamp}@example.com"
    test_password = "testpass123"
    test_name = "Test User"
    
    print(f"Test Email: {test_email}")
    print(f"Test Password: {test_password}")
    print(f"Test Name: {test_name}")
    print()
    
    # Test 1: User Registration
    print("1️⃣ Testing User Registration...")
    try:
        response = client.post('/api/auth/signup/', 
            data=json.dumps({
                'email': test_email,
                'password': test_password,
                'name': test_name
            }),
            content_type='application/json'
        )
        print(f"Status: {response.status_code}")
        
        if response.status_code == 201:
            print("✅ Registration successful!")
            try:
                response_data = response.json()
                print(f"Response: {json.dumps(response_data, indent=2)}")
            except:
                print(f"Response body: {response.content.decode()}")
        else:
            print("❌ Registration failed!")
            try:
                response_data = response.json()
                print(f"Error: {json.dumps(response_data, indent=2)}")
            except:
                print(f"Response body: {response.content.decode()}")
        print()
    except Exception as e:
        print(f"❌ Error: {e}")
        return
    
    # Test 2: Send OTP
    print("2️⃣ Testing Send OTP...")
    try:
        response = client.post('/api/send-otp/', 
            data=json.dumps({
                'email': test_email
            }),
            content_type='application/json'
        )
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            print("✅ OTP sent successfully!")
            try:
                response_data = response.json()
                print(f"Response: {json.dumps(response_data, indent=2)}")
                
                # Store the OTP code for verification test
                global stored_otp
                stored_otp = None
                
                # Try to extract OTP from console output (development mode)
                print("\n🔍 Check Django console above for the OTP code!")
                print("💡 Copy the OTP code and use it in the next test")
                
            except:
                print(f"Response body: {response.content.decode()}")
        else:
            print("❌ OTP sending failed!")
            try:
                response_data = response.json()
                print(f"Error: {json.dumps(response_data, indent=2)}")
            except:
                print(f"Response body: {response.content.decode()}")
        print()
    except Exception as e:
        print(f"❌ Error: {e}")
        return
    
    # Test 3: Verify Email (this will fail without valid OTP)
    print("3️⃣ Testing Verify Email (will fail without valid OTP)...")
    try:
        response = client.post('/api/verify-email/', 
            data=json.dumps({
                'email': test_email,
                'code': '000000'  # Invalid OTP
            }),
            content_type='application/json'
        )
        print(f"Status: {response.status_code}")
        
        if response.status_code == 400:
            print("✅ Verification correctly rejected invalid OTP!")
            try:
                response_data = response.json()
                print(f"Response: {json.dumps(response_data, indent=2)}")
            except:
                print(f"Response body: {response.content.decode()}")
        else:
            print("❌ Unexpected verification response!")
            try:
                response_data = response.json()
                print(f"Response: {json.dumps(response_data, indent=2)}")
            except:
                print(f"Response body: {response.content.decode()}")
        print()
    except Exception as e:
        print(f"❌ Error: {e}")
    
    # Test 4: Manual OTP Verification (requires user input)
    print("4️⃣ Manual OTP Verification Test...")
    print("📱 Enter the OTP code from Django console above:")
    print("💡 Look for: 'OTP Code: XXXXXX' in the console output")
    
    try:
        # This is a placeholder - in real testing you'd input the OTP
        print("🔐 To test with real OTP, manually call the API with the code from console")
        print("📝 Example: POST /api/verify-email/ with the actual OTP code")
    except Exception as e:
        print(f"❌ Error: {e}")
    
    print("\n✅ OTP Endpoint Testing Complete!")
    print("\n📝 Check Django console for OTP codes in development mode")
    print("🔍 If you see errors, check Django server logs")
    print("\n🚀 Next: Test your Flutter app - it should now connect to Django!")

if __name__ == '__main__':
    test_otp_endpoints()

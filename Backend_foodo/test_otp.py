#!/usr/bin/env python
"""
Test OTP Functionality
Run this to test your Django OTP endpoints
"""

import requests
import json

BASE_URL = 'http://127.0.0.1:8000'

def test_otp_endpoints():
    print("🧪 Testing Django OTP Endpoints...\n")
    
    # Test data - using unique email to avoid conflicts
    import time
    timestamp = int(time.time())
    test_email = f"test{timestamp}@example.com"
    test_password = "testpass123"
    test_name = "Test User"
    
    # Test 1: User Registration
    print("1️⃣ Testing User Registration...")
    try:
        response = requests.post(f"{BASE_URL}/api/auth/signup/", json={
            'email': test_email,
            'password': test_password,
            'name': test_name
        })
        print(f"Status: {response.status_code}")
        print(f"Response: {response.json()}")
        print()
    except Exception as e:
        print(f"❌ Error: {e}")
        return
    
    # Test 2: Send OTP
    print("2️⃣ Testing Send OTP...")
    try:
        response = requests.post(f"{BASE_URL}/api/send-otp/", json={
            'email': test_email
        })
        print(f"Status: {response.status_code}")
        print(f"Response: {response.json()}")
        print()
    except Exception as e:
        print(f"❌ Error: {e}")
        return
    
    # Test 3: Verify Email (this will fail without valid OTP)
    print("3️⃣ Testing Verify Email (will fail without valid OTP)...")
    try:
        response = requests.post(f"{BASE_URL}/api/verify-email/", json={
            'email': test_email,
            'code': '000000'  # Invalid OTP
        })
        print(f"Status: {response.status_code}")
        print(f"Response: {response.json()}")
        print()
    except Exception as e:
        print(f"❌ Error: {e}")
    
    print("✅ OTP Endpoint Testing Complete!")
    print("\n📝 Check Django console for OTP codes in development mode")

if __name__ == '__main__':
    test_otp_endpoints()

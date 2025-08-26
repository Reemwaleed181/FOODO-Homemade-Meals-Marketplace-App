#!/usr/bin/env python3
"""
Test script for email functionality using localhost
"""

import requests
import json

# Configuration - use localhost since server is running locally
BASE_URL = "http://127.0.0.1:8000"
TEST_EMAIL = "reem.waleed.ahmed@gmail.com"

def test_forgot_password():
    """Test the forgot password endpoint"""
    print("🧪 Testing Forgot Password Endpoint")
    print("=" * 50)
    
    url = f"{BASE_URL}/api/forgot-password/"
    data = {"email": TEST_EMAIL}
    
    try:
        response = requests.post(url, json=data, timeout=10)
        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.text}")
        
        if response.status_code == 200:
            print("✅ Forgot password request successful!")
            response_data = response.json()
            if response_data.get('success'):
                print("✅ Password reset instructions sent!")
                return True
            else:
                print("❌ Unexpected response format")
                return False
        else:
            print("❌ Forgot password request failed")
            return False
            
    except requests.exceptions.RequestException as e:
        print(f"❌ Request failed: {e}")
        return False

def test_send_otp():
    """Test the send OTP endpoint"""
    print("\n🧪 Testing Send OTP Endpoint")
    print("=" * 50)
    
    url = f"{BASE_URL}/api/send-otp/"
    data = {"email": TEST_EMAIL}
    
    try:
        response = requests.post(url, json=data, timeout=10)
        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.text}")
        
        if response.status_code == 200:
            print("✅ OTP sent successfully!")
            response_data = response.json()
            if response_data.get('success'):
                print("✅ OTP email sent!")
                return True
            else:
                print("❌ Unexpected response format")
                return False
        else:
            print("❌ OTP sending failed")
            return False
            
    except requests.exceptions.RequestException as e:
        print(f"❌ Request failed: {e}")
        return False

def test_verify_email():
    """Test the verify email endpoint with a dummy OTP"""
    print("\n🧪 Testing Verify Email Endpoint")
    print("=" * 50)
    
    url = f"{BASE_URL}/api/verify-email/"
    data = {
        "email": TEST_EMAIL,
        "code": "123456"  # Dummy OTP code
    }
    
    try:
        response = requests.post(url, json=data, timeout=10)
        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.text}")
        
        if response.status_code == 400:
            print("✅ Correctly rejected invalid OTP!")
            return True
        else:
            print("❌ Should have rejected invalid OTP")
            return False
            
    except requests.exceptions.RequestException as e:
        print(f"❌ Request failed: {e}")
        return False

def main():
    """Run all tests"""
    print("🚀 Starting Email Functionality Tests")
    print("=" * 60)
    
    tests = [
        test_forgot_password,
        test_send_otp,
        test_verify_email,
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
        print("🎉 All tests passed!")
    elif passed > 0:
        print("⚠️  Some tests failed. Check the output above for details.")
    else:
        print("❌ All tests failed. Check the output above for details.")

if __name__ == "__main__":
    main()

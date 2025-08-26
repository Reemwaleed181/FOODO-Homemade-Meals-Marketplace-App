#!/usr/bin/env python3
"""
Test script for forgot password functionality
"""

import requests
import json

# Configuration
BASE_URL = "http://192.168.10.17:8000"
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

def test_reset_password_with_invalid_token():
    """Test reset password with invalid token"""
    print("\n🧪 Testing Reset Password with Invalid Token")
    print("=" * 50)
    
    url = f"{BASE_URL}/api/reset-password/"
    data = {
        "token": "invalid_token_123",
        "new_password": "newpassword123"
    }
    
    try:
        response = requests.post(url, json=data, timeout=10)
        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.text}")
        
        if response.status_code == 400:
            print("✅ Correctly rejected invalid token!")
            return True
        else:
            print("❌ Should have rejected invalid token")
            return False
            
    except requests.exceptions.RequestException as e:
        print(f"❌ Request failed: {e}")
        return False

def test_reset_password_with_short_password():
    """Test reset password with short password"""
    print("\n🧪 Testing Reset Password with Short Password")
    print("=" * 50)
    
    url = f"{BASE_URL}/api/reset-password/"
    data = {
        "token": "some_token",
        "new_password": "123"
    }
    
    try:
        response = requests.post(url, json=data, timeout=10)
        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.text}")
        
        if response.status_code == 400:
            print("✅ Correctly rejected short password!")
            return True
        else:
            print("❌ Should have rejected short password")
            return False
            
    except requests.exceptions.RequestException as e:
        print(f"❌ Request failed: {e}")
        return False

def main():
    """Run all tests"""
    print("🚀 Starting Forgot Password Backend Tests")
    print("=" * 60)
    
    tests = [
        test_forgot_password,
        test_reset_password_with_invalid_token,
        test_reset_password_with_short_password,
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
        print("🎉 All tests passed! Forgot password backend is working correctly.")
    else:
        print("⚠️  Some tests failed. Check the output above for details.")

if __name__ == "__main__":
    main()

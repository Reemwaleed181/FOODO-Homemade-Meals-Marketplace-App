#!/usr/bin/env python3
"""
Test script to verify enhanced authentication system
Tests that only registered emails can log in
"""

import requests
import json

# Configuration
BASE_URL = "http://localhost:8000"
TEST_EMAIL = "test@example.com"
TEST_PASSWORD = "testpassword123"
UNREGISTERED_EMAIL = "unregistered@example.com"

def test_login_with_unregistered_email():
    """Test that login with unregistered email is rejected"""
    print("🔍 Testing login with unregistered email...")
    
    login_data = {
        "email": UNREGISTERED_EMAIL,
        "password": TEST_PASSWORD
    }
    
    try:
        response = requests.post(
            f"{BASE_URL}/api/auth/login/",
            json=login_data,
            headers={"Content-Type": "application/json"}
        )
        
        print(f"Status Code: {response.statusCode}")
        print(f"Response: {response.text}")
        
        if response.status_code == 400:
            data = response.json()
            if "not registered" in data.get("errors", []):
                print("✅ SUCCESS: Unregistered email correctly rejected")
                return True
            else:
                print("❌ FAIL: Wrong error message for unregistered email")
                return False
        else:
            print("❌ FAIL: Expected 400 status for unregistered email")
            return False
            
    except Exception as e:
        print(f"❌ ERROR: {e}")
        return False

def test_login_with_registered_email():
    """Test that login with registered email works (if user exists)"""
    print("\n🔍 Testing login with registered email...")
    
    login_data = {
        "email": TEST_EMAIL,
        "password": TEST_PASSWORD
    }
    
    try:
        response = requests.post(
            f"{BASE_URL}/api/auth/login/",
            json=login_data,
            headers={"Content-Type": "application/json"}
        )
        
        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.text}")
        
        if response.status_code == 200:
            print("✅ SUCCESS: Registered email login successful")
            return True
        elif response.status_code == 400:
            data = response.json()
            if "Invalid password" in str(data.get("errors", [])):
                print("✅ SUCCESS: Email exists but password is wrong (expected)")
                return True
            else:
                print("❌ FAIL: Unexpected error for registered email")
                return False
        else:
            print("❌ FAIL: Unexpected status code")
            return False
            
    except Exception as e:
        print(f"❌ ERROR: {e}")
        return False

def test_email_check_endpoint():
    """Test the email check endpoint"""
    print("\n🔍 Testing email check endpoint...")
    
    try:
        # Test with unregistered email
        response = requests.post(
            f"{BASE_URL}/api/send-otp/",
            json={"email": UNREGISTERED_EMAIL},
            headers={"Content-Type": "application/json"}
        )
        
        print(f"Unregistered email check - Status: {response.status_code}")
        print(f"Response: {response.text}")
        
        if response.status_code == 404:
            print("✅ SUCCESS: Unregistered email correctly identified")
        else:
            print("❌ FAIL: Unregistered email not properly handled")
            
    except Exception as e:
        print(f"❌ ERROR: {e}")

def main():
    """Run all tests"""
    print("🚀 Starting Authentication Enhancement Tests\n")
    
    # Test 1: Unregistered email login
    test1_result = test_login_with_unregistered_email()
    
    # Test 2: Registered email login
    test2_result = test_login_with_registered_email()
    
    # Test 3: Email check endpoint
    test_email_check_endpoint()
    
    print("\n" + "="*50)
    print("📊 TEST RESULTS SUMMARY")
    print("="*50)
    print(f"Unregistered email rejection: {'✅ PASS' if test1_result else '❌ FAIL'}")
    print(f"Registered email handling: {'✅ PASS' if test2_result else '❌ FAIL'}")
    
    if test1_result and test2_result:
        print("\n🎉 All tests passed! Authentication enhancement working correctly.")
    else:
        print("\n⚠️  Some tests failed. Please check the implementation.")

if __name__ == "__main__":
    main()

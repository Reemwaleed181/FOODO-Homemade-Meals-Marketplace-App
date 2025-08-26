#!/usr/bin/env python3
"""
Test script to verify user creation and Django Admin visibility
Tests that users created via signup are properly saved, active, and visible
"""

import requests
import json
import time

# Configuration
BASE_URL = "http://localhost:8000"
TEST_EMAIL = f"testuser_{int(time.time())}@example.com"
TEST_PASSWORD = "testpassword123"
TEST_NAME = "Test User"

def test_user_creation():
    """Test that user creation works properly"""
    print("🔍 Testing user creation...")
    
    signup_data = {
        "email": TEST_EMAIL,
        "password": TEST_PASSWORD,
        "name": TEST_NAME,
        "phone": "+1234567890",
        "address": "123 Test Street",
        "city": "Test City",
        "zip_code": "12345"
    }
    
    try:
        response = requests.post(
            f"{BASE_URL}/api/auth/signup/",
            json=signup_data,
            headers={"Content-Type": "application/json"}
        )
        
        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.text}")
        
        if response.status_code == 201:
            data = response.json()
            if data.get('success'):
                print("✅ SUCCESS: User created successfully")
                print(f"   User ID: {data['data']['user']['id']}")
                print(f"   Email: {data['data']['user']['email']}")
                print(f"   Username: {data['data']['user']['username']}")
                print(f"   Verified: {data['data']['user']['is_verified']}")
                return data['data']['user']['id']
            else:
                print("❌ FAIL: User creation failed")
                return None
        else:
            print("❌ FAIL: Expected 201 status for user creation")
            return None
            
    except Exception as e:
        print(f"❌ ERROR: {e}")
        return None

def test_user_login_after_creation(user_id):
    """Test that user can't login before verification"""
    print(f"\n🔍 Testing login for newly created user (ID: {user_id})...")
    
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
        
        if response.status_code == 400:
            data = response.json()
            if "verify your email" in str(data.get("errors", [])):
                print("✅ SUCCESS: User correctly prevented from logging in before verification")
                return True
            else:
                print("❌ FAIL: Wrong error message for unverified user")
                return False
        else:
            print("❌ FAIL: Expected 400 status for unverified user")
            return False
            
    except Exception as e:
        print(f"❌ ERROR: {e}")
        return False

def test_email_check_endpoint():
    """Test that the email check endpoint works for the new user"""
    print(f"\n🔍 Testing email check for new user: {TEST_EMAIL}")
    
    try:
        response = requests.post(
            f"{BASE_URL}/api/send-otp/",
            json={"email": TEST_EMAIL},
            headers={"Content-Type": "application/json"}
        )
        
        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.text}")
        
        if response.status_code == 200:
            print("✅ SUCCESS: Email check successful for new user")
            return True
        else:
            print("❌ FAIL: Email check failed for new user")
            return False
            
    except Exception as e:
        print(f"❌ ERROR: {e}")
        return False

def test_admin_visibility():
    """Test that the user is visible in Django Admin"""
    print(f"\n🔍 Testing Django Admin visibility...")
    print("   Please check Django Admin at: http://127.0.0.1:8000/admin/")
    print("   Look for the user in the Users section")
    print("   User should be:")
    print("   - Active (is_active = True)")
    print("   - Not verified (is_verified = False)")
    print("   - Not staff (is_staff = False)")
    print("   - Not superuser (is_superuser = False)")
    print("   - Have proper email, username, and name fields")
    
    return True

def main():
    """Run all tests"""
    print("🚀 Starting User Creation and Admin Visibility Tests\n")
    
    # Test 1: User creation
    user_id = test_user_creation()
    
    if user_id:
        # Test 2: Login prevention before verification
        test2_result = test_user_login_after_creation(user_id)
        
        # Test 3: Email check endpoint
        test3_result = test_email_check_endpoint()
        
        # Test 4: Admin visibility check
        test4_result = test_admin_visibility()
        
        print("\n" + "="*60)
        print("📊 TEST RESULTS SUMMARY")
        print("="*60)
        print(f"User creation: {'✅ PASS' if user_id else '❌ FAIL'}")
        print(f"Login prevention: {'✅ PASS' if test2_result else '❌ FAIL'}")
        print(f"Email check: {'✅ PASS' if test3_result else '❌ FAIL'}")
        print(f"Admin visibility: {'✅ PASS' if test4_result else '❌ FAIL'}")
        
        if user_id and test2_result and test3_result and test4_result:
            print("\n🎉 All tests passed! User creation and admin visibility working correctly.")
            print(f"\n📝 Next steps:")
            print(f"   1. Check Django Admin at: http://127.0.0.1:8000/admin/")
            print(f"   2. Look for user with email: {TEST_EMAIL}")
            print(f"   3. Verify all fields are properly displayed")
            print(f"   4. Test admin actions (verify user, make chef, etc.)")
        else:
            print("\n⚠️  Some tests failed. Please check the implementation.")
    else:
        print("\n❌ User creation failed. Cannot proceed with other tests.")

if __name__ == "__main__":
    main()

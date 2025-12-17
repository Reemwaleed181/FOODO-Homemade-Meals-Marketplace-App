#!/usr/bin/env python
"""
Test script to verify API endpoints are working
"""

import requests
import json

BASE_URL = "http://192.168.10.17:8000"

def test_endpoint(endpoint, method="GET", data=None):
    """Test an API endpoint"""
    url = f"{BASE_URL}{endpoint}"
    try:
        if method == "GET":
            response = requests.get(url)
        elif method == "POST":
            response = requests.post(url, json=data, headers={'Content-Type': 'application/json'})
        
        print(f"✅ {method} {endpoint} - Status: {response.status_code}")
        if response.status_code == 200:
            try:
                result = response.json()
                print(f"   Response: {json.dumps(result, indent=2)[:200]}...")
            except:
                print(f"   Response: {response.text[:200]}...")
        else:
            print(f"   Error: {response.text[:200]}...")
    except Exception as e:
        print(f"❌ {method} {endpoint} - Error: {str(e)}")

def main():
    print("🧪 Testing Foodo API Endpoints")
    print("=" * 50)
    
    # Test meals endpoint
    test_endpoint("/api/meals/")
    
    # Test authentication endpoints
    test_endpoint("/api/auth/login/", "POST", {"email": "test@example.com", "password": "test123"})
    test_endpoint("/api/auth/send-otp/", "POST", {"email": "test@example.com"})
    test_endpoint("/api/auth/forgot-password/", "POST", {"email": "test@example.com"})
    
    # Test admin interface
    test_endpoint("/admin/")
    
    print("\n🎯 API Testing Complete!")

if __name__ == "__main__":
    main()

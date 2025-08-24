# Django Backend Setup for Flutter OTP App

## 🚀 Quick Start

Your Flutter app is now configured to work with a Django backend at `http://127.0.0.1:8000`.

## 📋 Required Django Endpoints

Your Django backend needs these API endpoints:

### 1. User Registration
```
POST /api/register/
Body: {"email": "user@example.com", "password": "password123", "name": "User Name"}
Response: {"success": true, "message": "User registered successfully", "data": {...}}
```

### 2. User Login
```
POST /api/login/
Body: {"email": "user@example.com", "password": "password123"}
Response: {"success": true, "message": "Login successful", "data": {...}}
```

### 3. Send OTP
```
POST /api/send-otp/
Body: {"email": "user@example.com"}
Response: {"success": true, "message": "OTP sent successfully"}
```

### 4. Verify Email
```
POST /api/verify-email/
Body: {"email": "user@example.com", "code": "123456"}
Response: {"success": true, "message": "Email verified successfully", "data": {...}}
```

### 5. Resend OTP
```
POST /api/resend-otp/
Body: {"email": "user@example.com"}
Response: {"success": true, "message": "OTP resent successfully"}
```

## 🔧 Django Implementation Example

Here's a basic Django view structure:

```python
# views.py
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
import json
import random

@csrf_exempt
def send_otp(request):
    if request.method == 'POST':
        data = json.loads(request.body)
        email = data.get('email')
        
        # Generate 6-digit OTP
        otp = ''.join([str(random.randint(0, 9)) for _ in range(6)])
        
        # Store OTP in database or cache
        # Send email with OTP
        
        return JsonResponse({
            'success': True,
            'message': 'OTP sent successfully'
        })
    
    return JsonResponse({'success': False, 'message': 'Invalid request'})

@csrf_exempt
def verify_email(request):
    if request.method == 'POST':
        data = json.loads(request.body)
        email = data.get('email')
        code = data.get('code')
        
        # Verify OTP from database/cache
        # Update user verification status
        
        return JsonResponse({
            'success': True,
            'message': 'Email verified successfully',
            'data': {'isVerified': True}
        })
    
    return JsonResponse({'success': False, 'message': 'Invalid request'})
```

## 🧪 Testing Connection

Run this command to test your Django backend:

```bash
dart test_django_connection.dart
```

## ⚙️ Configuration

Update your Django backend URL in:
- `lib/config/app_config.dart` - Change `djangoBaseUrl`
- `lib/main.dart` - Will automatically use the config

## 🔍 Debug Mode

The Flutter app will show detailed logs when connecting to Django:
- API request/response details
- Error messages
- Connection status

## 🚨 Common Issues

1. **Connection Refused**: Django server not running
2. **404 Errors**: API endpoints not configured
3. **CORS Issues**: Add CORS headers in Django
4. **Port Conflicts**: Check if port 8000 is available

## 📱 Flutter App Features

- ✅ User registration with Django backend
- ✅ OTP generation and verification
- ✅ User login and authentication
- ✅ Error handling and user feedback
- ✅ Development mode for testing

## 🔄 Next Steps

1. Start your Django server
2. Test the connection with the test script
3. Run your Flutter app
4. Test registration and OTP flow
5. Check console logs for debugging

## 📞 Support

If you encounter issues:
1. Check Django server logs
2. Verify API endpoints are working
3. Test with the connection test script
4. Check Flutter console output

# 🚀 Foodo App Setup Guide

This guide will help you set up both the Django backend and Flutter app to work together properly.

## 📋 Prerequisites

- Python 3.8+ installed
- Flutter SDK installed
- Git installed
- A code editor (VS Code recommended)

## 🔧 Step 1: Django Backend Setup

### 1.1 Navigate to Django Directory
```bash
cd Backend_foodo
```

### 1.2 Activate Virtual Environment
```bash
# On Windows
env\Scripts\activate

# On macOS/Linux
source env/bin/activate
```

### 1.3 Install Dependencies
```bash
pip install -r requirements.txt
```

### 1.4 Run Database Migrations
```bash
python manage.py makemigrations
python manage.py migrate
```

### 1.5 Test Backend
```bash
python test_backend.py
```

This will test:
- Database connection
- Email configuration
- User models
- OTP generation
- API endpoints

### 1.6 Create Admin User
```bash
python manage.py createsuperuser
```

### 1.7 Start Django Server
```bash
python manage.py runserver
```

Your Django backend should now be running at `http://127.0.0.1:8000`

## 📱 Step 2: Flutter App Setup

### 2.1 Navigate to Flutter Directory
```bash
cd ..  # Go back to foodo root
```

### 2.2 Install Flutter Dependencies
```bash
flutter pub get
```

### 2.3 Test Backend Connection
```bash
flutter run -d chrome test_connection.dart
```

This will open a test page to verify:
- Django server accessibility
- API endpoint functionality
- CORS configuration
- Network connectivity

### 2.4 Run the Main App
```bash
flutter run
```

## 🔍 Step 3: Testing Authentication

### 3.1 Test Signup Flow
1. Open the Flutter app
2. Go to Sign Up
3. Fill in the form:
   - Name: Test User
   - Email: test@example.com
   - Password: testpass123
   - Phone: +1234567890
   - Address: 123 Test St
   - City: Test City
   - Zip Code: 12345
4. Click "Create Account"
5. Check Django console for OTP code
6. Enter OTP in verification screen
7. Should redirect to home page

### 3.2 Test Login Flow
1. Go to Login
2. Enter credentials:
   - Email: test@example.com
   - Password: testpass123
3. Click "Sign In"
4. Should redirect to home page

## 🐛 Troubleshooting

### Django Issues

#### Database Errors
```bash
# Reset database (WARNING: This will delete all data)
rm db.sqlite3
python manage.py migrate
python manage.py createsuperuser
```

#### Email Configuration Issues
If emails aren't sending, check:
1. Gmail app password is correct
2. Gmail 2FA is enabled
3. Less secure app access is disabled

#### Port Already in Use
```bash
# Find process using port 8000
netstat -ano | findstr :8000

# Kill the process
taskkill /PID <PID> /F
```

### Flutter Issues

#### Connection Refused
1. Ensure Django server is running
2. Check if port 8000 is accessible
3. Verify CORS settings in Django

#### API Errors
1. Check Django console for error logs
2. Verify API endpoints in `urls.py`
3. Test endpoints with Postman or curl

#### Build Errors
```bash
flutter clean
flutter pub get
flutter run
```

## 🌐 API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/auth/signup/` | POST | User registration |
| `/api/auth/login/` | POST | User authentication |
| `/api/send-otp/` | POST | Send OTP for verification |
| `/api/verify-email/` | POST | Verify email with OTP |
| `/api/auth/me/` | GET | Get current user info |

## 📧 Email Configuration

The app uses Gmail SMTP for sending OTP codes. In development mode, emails are printed to the console.

### Gmail Setup
1. Enable 2-Factor Authentication
2. Generate App Password
3. Update `settings.py` with your credentials

## 🔐 Security Notes

- **Never commit real credentials to Git**
- **Use environment variables in production**
- **Enable HTTPS in production**
- **Implement rate limiting for OTP requests**

## 📱 Testing on Different Platforms

### Android Emulator
- Backend URL: `http://10.0.2.2:8000`
- Django server must be accessible from host machine

### iOS Simulator
- Backend URL: `http://127.0.0.1:8000`
- Same as web testing

### Web
- Backend URL: `http://127.0.0.1:8000`
- CORS must be properly configured

### Real Device
- Backend URL: `http://<your-computer-ip>:8000`
- Ensure firewall allows connections

## 🎯 Success Indicators

✅ Django admin accessible at `http://127.0.0.1:8000/admin/`  
✅ Flutter app can connect to backend  
✅ User registration works  
✅ Email verification works  
✅ User login works  
✅ Navigation between screens works  

## 🆘 Getting Help

If you encounter issues:

1. Check Django console for error messages
2. Check Flutter console for error messages
3. Verify all services are running
4. Check network connectivity
5. Review this setup guide

## 🚀 Next Steps

Once everything is working:

1. Customize the UI design
2. Add more features
3. Implement real email service
4. Deploy to production
5. Add analytics and monitoring

---

**Happy coding! 🎉**

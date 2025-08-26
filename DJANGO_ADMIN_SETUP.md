# Django Admin Setup & User Management

## Overview

This document explains how to set up and use Django Admin for managing users in the Foodo application. The system ensures that **all users created via signup are properly saved, active, and visible in Django Admin**.

## 🚀 **Quick Start**

### 1. **Access Django Admin**
- URL: `http://127.0.0.1:8000/admin/`
- Use your superuser credentials to log in

### 2. **View Users**
- Navigate to **Users** section
- All registered users are visible with their status
- Use filters to find specific users

### 3. **Manage Users**
- Click on any user to edit their details
- Use bulk actions for multiple users
- Monitor user verification status

## 🔧 **Admin Configuration**

### **User Admin Features**

#### **List View Display**
- **ID**: Unique user identifier
- **Email**: User's email address
- **Username**: Generated username
- **Full Name**: Combined first and last name
- **Phone**: Contact number
- **City**: User's city
- **Verified**: Email verification status
- **Active**: Account activation status
- **Chef**: Chef role status
- **Date Joined**: Registration date
- **Last Login**: Last login timestamp

#### **Search & Filtering**
- **Search Fields**: Email, username, first name, last name, phone
- **Filters**: Verification status, activity status, chef status, date ranges
- **Quick Actions**: Edit verification status, activate/deactivate users

#### **Bulk Actions**
- **Verify Users**: Mark selected users as verified
- **Activate Users**: Activate selected users
- **Deactivate Users**: Deactivate selected users
- **Make Chefs**: Grant chef status to selected users
- **Remove Chefs**: Remove chef status from selected users

### **OTP Admin Features**

#### **List View Display**
- **ID**: OTP identifier
- **User Email**: Linked user email (clickable)
- **OTP Code**: 6-digit verification code
- **Created**: OTP creation timestamp
- **Expires**: OTP expiry timestamp
- **Used**: Whether OTP has been used
- **Expired**: Whether OTP has expired
- **Time Remaining**: Time until expiry

#### **OTP Management**
- **Mark as Used**: Mark OTPs as used
- **Delete Expired**: Remove expired OTPs
- **Time Tracking**: Monitor OTP validity periods

## 📊 **User Status Management**

### **User States**

| Status | Description | Admin Action |
|--------|-------------|--------------|
| **Active** | User can log in | Toggle in list view |
| **Verified** | Email verified | Use "Verify Users" action |
| **Chef** | Has chef privileges | Use "Make Chefs" action |
| **Staff** | Can access admin | Edit in user detail view |
| **Superuser** | Full admin access | Edit in user detail view |

### **Default User Configuration**

When users sign up via the API:
- ✅ **is_active**: `True` (User can log in)
- ❌ **is_verified**: `False` (Email verification required)
- ❌ **is_chef**: `False` (Not a chef by default)
- ❌ **is_staff**: `False` (No admin access)
- ❌ **is_superuser**: `False` (No superuser privileges)

## 🛠 **Management Commands**

### **User Management Commands**

Run these commands from the `Backend_foodo` directory:

#### **List All Users**
```bash
python manage.py manage_users --list
```

#### **Fix Inactive Users**
```bash
python manage.py manage_users --fix-inactive
```

#### **Clean Up Users**
```bash
python manage.py manage_users --cleanup
```

#### **Show User Statistics**
```bash
python manage.py manage_users --stats
```

### **Command Output Examples**

#### **User List**
```
📋 User List:
================================================================================
✅   1 | test@example.com              | testuser           | ❌ | 👤 | 2024-01-15 10:30
✅   2 | chef@example.com              | chefuser           | ✅ | 👨‍🍳 | 2024-01-15 11:45
❌   3 | old@example.com               | olduser            | ❌ | 👤 | 2024-01-10 09:15
================================================================================
Total users: 3
```

#### **User Statistics**
```
📊 User Statistics:
==================================================
Total Users: 15
Active Users: 12
Verified Users: 8
Unverified Users: 7
Chef Users: 3
Staff Users: 2
Superusers: 1
Users (Last 7 days): 5
Verification Rate: 53.3%
==================================================
```

## 🧪 **Testing User Creation**

### **Automated Testing**

Run the test script to verify user creation and admin visibility:

```bash
cd Backend_foodo
python test_user_creation.py
```

### **Manual Testing**

1. **Create a test user** via the signup API
2. **Check Django Admin** for the new user
3. **Verify user fields** are properly displayed
4. **Test admin actions** on the user

### **Test Scenarios**

| Test | Expected Result |
|------|-----------------|
| User signup | User created with proper defaults |
| Admin visibility | User visible in Users section |
| Field display | All fields properly shown |
| Status management | Actions work correctly |

## 🔍 **Troubleshooting**

### **Common Issues**

#### **1. Users Not Visible in Admin**
- Check if Django server is running
- Verify user model is registered in admin
- Check database for user records
- Run `python manage.py manage_users --list`

#### **2. User Fields Not Displaying**
- Check admin configuration in `users/admin.py`
- Verify model fields exist
- Check for migration issues
- Restart Django server

#### **3. Admin Actions Not Working**
- Check user permissions
- Verify action methods are defined
- Check for JavaScript errors in browser
- Clear browser cache

#### **4. User Creation Failing**
- Check API endpoints
- Verify database connectivity
- Check for validation errors
- Review server logs

### **Debug Commands**

#### **Check User Count**
```bash
python manage.py shell
>>> from users.models import User
>>> User.objects.count()
```

#### **Check Specific User**
```bash
python manage.py shell
>>> from users.models import User
>>> user = User.objects.get(email='test@example.com')
>>> print(f"Active: {user.is_active}, Verified: {user.is_verified}")
```

#### **Check Admin Registration**
```bash
python manage.py shell
>>> from django.contrib import admin
>>> admin.site._registry.keys()
```

## 📋 **Admin Best Practices**

### **User Management**

1. **Regular Monitoring**: Check user statistics weekly
2. **Verification Process**: Monitor unverified users
3. **Cleanup**: Remove old, inactive users
4. **Security**: Review staff and superuser accounts

### **Data Integrity**

1. **Backup**: Regular database backups
2. **Validation**: Ensure data consistency
3. **Audit**: Track user status changes
4. **Monitoring**: Watch for unusual activity

### **Performance**

1. **Pagination**: Use list_per_page setting
2. **Filtering**: Use database indexes
3. **Caching**: Implement admin caching
4. **Optimization**: Monitor query performance

## 🚀 **Advanced Features**

### **Custom Admin Actions**

The admin includes custom actions for:
- **Bulk user verification**
- **Role management**
- **Account activation/deactivation**
- **OTP management**

### **Admin Customization**

- **Custom site header**: "Foodo Administration"
- **Custom site title**: "Foodo Admin Portal"
- **Custom index title**: "Welcome to Foodo Administration"

### **Field Organization**

Users are organized into logical groups:
- **Basic Information**: Email, username, name
- **Contact Information**: Phone, address, city, zip
- **Account Status**: Active, verified, chef status
- **Chef Information**: Bio, rating, orders
- **Permissions**: Groups and user permissions
- **Important Dates**: Join date and last login

## 📚 **API Integration**

### **User Creation Flow**

1. **Signup API** creates user with proper defaults
2. **User is saved** to database with all fields
3. **User is active** but not verified
4. **OTP is generated** and sent via email
5. **User appears in admin** immediately

### **Verification Flow**

1. **User enters OTP** from email
2. **System verifies OTP** validity
3. **User is marked verified** in database
4. **Admin shows updated status**
5. **User can now log in**

## 🔐 **Security Considerations**

### **Admin Access Control**

- **Staff users**: Limited admin access
- **Superusers**: Full admin access
- **Regular users**: No admin access
- **Guest users**: No system access

### **Data Protection**

- **Password hashing**: Secure password storage
- **Field permissions**: Read-only sensitive fields
- **Action logging**: Track admin changes
- **Access control**: Limit admin actions

## 📞 **Support & Maintenance**

### **Regular Tasks**

- **Daily**: Check for new user registrations
- **Weekly**: Review user statistics
- **Monthly**: Clean up old users and OTPs
- **Quarterly**: Review admin permissions

### **Monitoring**

- **User growth**: Track registration rates
- **Verification rates**: Monitor email verification
- **Activity levels**: Track user engagement
- **System health**: Monitor admin performance

---

**Note**: This Django Admin setup ensures that all users created via the signup process are properly saved, active, and visible in the admin interface, providing administrators with full control over user management and system monitoring.

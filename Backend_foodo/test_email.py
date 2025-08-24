#!/usr/bin/env python
"""
Test Django Email Configuration
Run this script to test if Django can send emails
"""

import os
import django
from django.core.mail import send_mail
from django.conf import settings

# Setup Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'homecook_backend.settings')
django.setup()

def test_email_sending():
    """Test if Django can send emails"""
    print("🧪 Testing Django Email Configuration...")
    print(f"📧 Email Backend: {settings.EMAIL_BACKEND}")
    print(f"📧 Email Host: {settings.EMAIL_HOST}")
    print(f"📧 Email Port: {settings.EMAIL_PORT}")
    print(f"📧 Email User: {settings.EMAIL_HOST_USER}")
    print(f"📧 Use TLS: {settings.EMAIL_USE_TLS}")
    print()
    
    try:
        # Test email sending
        subject = 'Test Email from Django - HomeCook'
        message = '''Hello!

This is a test email from your Django backend.

If you receive this, your email configuration is working correctly!

Best regards,
HomeCook Team'''
        
        recipient_email = 'reem.waleed.ahmed@gmail.com'  # Test to your email
        
        print(f"📤 Sending test email to: {recipient_email}")
        
        result = send_mail(
            subject=subject,
            message=message,
            from_email=settings.EMAIL_HOST_USER,
            recipient_list=[recipient_email],
            fail_silently=False
        )
        
        if result == 1:
            print("✅ Test email sent successfully!")
            print("📧 Check your inbox for the test email")
        else:
            print("❌ Email sending failed - unexpected result")
            
    except Exception as e:
        print(f"❌ Error sending test email: {e}")
        print()
        print("🔍 Common issues:")
        print("1. Check if Gmail App Password is correct")
        print("2. Ensure 2FA is enabled on Gmail")
        print("3. Check if 'Less secure app access' is enabled")
        print("4. Verify Gmail SMTP settings")

if __name__ == "__main__":
    test_email_sending()

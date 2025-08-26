from django.contrib.auth.models import AbstractUser
from django.db import models
import random
import string
from datetime import datetime, timedelta

class User(AbstractUser):
    email = models.EmailField(unique=True)
    phone = models.CharField(max_length=15, blank=True, null=True)
    address = models.TextField(blank=True, null=True)
    city = models.CharField(max_length=100, blank=True, null=True)
    zip_code = models.CharField(max_length=10, blank=True, null=True)
    is_chef = models.BooleanField(default=False)
    chef_bio = models.TextField(blank=True, null=True)
    chef_rating = models.DecimalField(max_digits=3, decimal_places=2, default=0.00)
    total_orders = models.IntegerField(default=0)
    is_verified = models.BooleanField(default=False)
    
    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['username']

    def __str__(self):
        return self.email

class OTP(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    email = models.EmailField()
    otp_code = models.CharField(max_length=6)
    created_at = models.DateTimeField(auto_now_add=True)
    expires_at = models.DateTimeField()
    is_used = models.BooleanField(default=False)
    
    def __str__(self):
        return f"OTP for {self.email}: {self.otp_code}"
    
    def is_expired(self):
        from django.utils import timezone
        result = timezone.now() > self.expires_at
        
        # Debug logging
        import os
        if os.environ.get('DJANGO_SETTINGS_MODULE') and 'DEBUG' in os.environ:
            print(f"=== OTP EXPIRY CHECK ===")
            print(f"OTP: {self.otp_code}")
            print(f"Current time: {timezone.now()}")
            print(f"Expires at: {self.expires_at}")
            print(f"Is expired: {result}")
            print(f"===============================")
        
        return result
    
    def is_valid(self):
        return not self.is_used and not self.is_expired()
    
    @classmethod
    def generate_otp(cls, user, email):
        # Delete any existing unused OTPs for this user
        cls.objects.filter(user=user, is_used=False).delete()
        
        # Generate new 6-digit OTP
        from django.utils import timezone
        otp_code = ''.join(random.choices(string.digits, k=6))
        
        # Create OTP with 10 minutes expiry
        expires_at = timezone.now() + timedelta(minutes=10)
        
        otp = cls.objects.create(
            user=user,
            email=email,
            otp_code=otp_code,
            expires_at=expires_at
        )
        
        # Debug logging
        import os
        if os.environ.get('DJANGO_SETTINGS_MODULE') and 'DEBUG' in os.environ:
            print(f"=== OTP MODEL CREATED ===")
            print(f"User: {user.email}")
            print(f"OTP Code: {otp.otp_code}")
            print(f"Expires: {otp.expires_at}")
            print(f"Is Used: {otp.is_used}")
            print(f"===============================")
        
        return otp

class PasswordResetToken(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    token = models.CharField(max_length=100, unique=True)
    created_at = models.DateTimeField(auto_now_add=True)
    expires_at = models.DateTimeField()
    is_used = models.BooleanField(default=False)
    
    def __str__(self):
        return f"Password reset token for {self.user.email}"
    
    def is_expired(self):
        from django.utils import timezone
        result = timezone.now() > self.expires_at
        
        # Debug logging
        import os
        if os.environ.get('DJANGO_SETTINGS_MODULE') and 'DEBUG' in os.environ:
            print(f"=== TOKEN EXPIRY CHECK ===")
            print(f"Token: {self.token[:10]}...")
            print(f"Current time: {timezone.now()}")
            print(f"Expires at: {self.expires_at}")
            print(f"Is expired: {result}")
            print(f"===============================")
        
        return result
    
    def is_valid(self):
        return not self.is_used and not self.is_expired()
    
    @classmethod
    def generate_token(cls, user):
        # Delete any existing unused tokens for this user
        cls.objects.filter(user=user, is_used=False).delete()
        
        # Generate a secure random token
        token = ''.join(random.choices(string.ascii_letters + string.digits, k=64))
        
        # Create token with 1 hour expiry
        from django.utils import timezone
        expires_at = timezone.now() + timedelta(hours=1)
        
        reset_token = cls.objects.create(
            user=user,
            token=token,
            expires_at=expires_at
        )
        
        return reset_token
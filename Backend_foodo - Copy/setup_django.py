#!/usr/bin/env python
"""
Django Backend Setup Script
Run this to set up your Django backend with OTP functionality
"""

import os
import sys
import django

# Add the project directory to Python path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

# Set Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'homecook_backend.settings')

# Setup Django
django.setup()

from django.core.management import execute_from_command_line

def main():
    print("🚀 Setting up Django Backend with OTP...")
    
    # Create migrations
    print("📝 Creating database migrations...")
    execute_from_command_line(['manage.py', 'makemigrations'])
    
    # Apply migrations
    print("🗄️ Applying database migrations...")
    execute_from_command_line(['manage.py', 'migrate'])
    
    # Create superuser (optional)
    print("👤 Creating superuser...")
    print("You can skip this by pressing Ctrl+C")
    try:
        execute_from_command_line(['manage.py', 'createsuperuser'])
    except KeyboardInterrupt:
        print("Superuser creation skipped.")
    
    print("\n✅ Django Backend Setup Complete!")
    print("\n🔧 Next Steps:")
    print("1. Start Django server: python manage.py runserver")
    print("2. Test OTP endpoints")
    print("3. Run your Flutter app")

if __name__ == '__main__':
    main()

#!/usr/bin/env python3
"""
Setup script for Django Admin configuration
Creates superuser and ensures proper admin setup
"""

import os
import sys
import django
from pathlib import Path

# Add the project directory to Python path
project_dir = Path(__file__).resolve().parent
sys.path.insert(0, str(project_dir))

# Set Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'homecook_backend.settings')
django.setup()

from django.contrib.auth import get_user_model
from django.core.management import call_command
from django.db import connection

User = get_user_model()

def check_database_connection():
    """Check if database is accessible"""
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1")
        print("✅ Database connection successful")
        return True
    except Exception as e:
        print(f"❌ Database connection failed: {e}")
        return False

def check_user_model():
    """Check if User model is properly configured"""
    try:
        # Check if User model exists
        user_count = User.objects.count()
        print(f"✅ User model accessible - {user_count} users found")
        return True
    except Exception as e:
        print(f"❌ User model check failed: {e}")
        return False

def create_superuser():
    """Create a superuser for admin access"""
    try:
        # Check if superuser already exists
        if User.objects.filter(is_superuser=True).exists():
            print("✅ Superuser already exists")
            return True
        
        # Create superuser
        superuser = User.objects.create_superuser(
            username='admin',
            email='admin@foodo.com',
            password='admin123456',
            first_name='Admin',
            last_name='User'
        )
        
        print("✅ Superuser created successfully")
        print(f"   Username: {superuser.username}")
        print(f"   Email: {superuser.email}")
        print(f"   Password: admin123456")
        print("   ⚠️  Remember to change the password!")
        return True
        
    except Exception as e:
        print(f"❌ Superuser creation failed: {e}")
        return False

def check_admin_configuration():
    """Check if admin is properly configured"""
    try:
        # Import admin configuration
        from users.admin import UserAdmin, OTPAdmin
        
        print("✅ Admin configuration loaded successfully")
        print(f"   UserAdmin: {UserAdmin}")
        print(f"   OTPAdmin: {OTPAdmin}")
        return True
        
    except Exception as e:
        print(f"❌ Admin configuration check failed: {e}")
        return False

def run_migrations():
    """Run database migrations"""
    try:
        print("🔄 Running migrations...")
        call_command('makemigrations')
        call_command('migrate')
        print("✅ Migrations completed successfully")
        return True
    except Exception as e:
        print(f"❌ Migration failed: {e}")
        return False

def show_setup_instructions():
    """Show setup instructions"""
    print("\n" + "="*60)
    print("🚀 DJANGO ADMIN SETUP COMPLETE")
    print("="*60)
    print("\n📋 Next Steps:")
    print("1. Start Django server:")
    print("   cd Backend_foodo")
    print("   python manage.py runserver")
    print("\n2. Access Django Admin:")
    print("   URL: http://127.0.0.1:8000/admin/")
    print("   Username: admin")
    print("   Password: admin123456")
    print("\n3. Test user management:")
    print("   - Create a test user via signup API")
    print("   - Check if user appears in admin")
    print("   - Test admin actions")
    print("\n4. Run user management commands:")
    print("   python manage.py manage_users --stats")
    print("   python manage.py manage_users --list")
    print("\n5. Test user creation:")
    print("   python test_user_creation.py")
    print("\n" + "="*60)

def main():
    """Main setup function"""
    print("🔧 Setting up Django Admin for Foodo...")
    print("="*50)
    
    # Check prerequisites
    if not check_database_connection():
        print("❌ Cannot proceed without database connection")
        return False
    
    if not check_user_model():
        print("❌ Cannot proceed without User model")
        return False
    
    # Run migrations
    if not run_migrations():
        print("❌ Cannot proceed without migrations")
        return False
    
    # Check admin configuration
    if not check_admin_configuration():
        print("❌ Admin configuration check failed")
        return False
    
    # Create superuser
    if not create_superuser():
        print("❌ Superuser creation failed")
        return False
    
    print("\n✅ Django Admin setup completed successfully!")
    show_setup_instructions()
    
    return True

if __name__ == "__main__":
    try:
        success = main()
        if success:
            print("\n🎉 Setup completed successfully!")
        else:
            print("\n⚠️  Setup completed with warnings")
            sys.exit(1)
    except KeyboardInterrupt:
        print("\n\n⚠️  Setup interrupted by user")
        sys.exit(1)
    except Exception as e:
        print(f"\n❌ Setup failed with error: {e}")
        sys.exit(1)

#!/usr/bin/env python
"""
Script to load seed meals data into the database
Run this after setting up your Django backend
"""

import os
import sys
import django

# Add the project directory to Python path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

# Set up Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'homecook_backend.settings')
django.setup()

from django.core.management import call_command

if __name__ == '__main__':
    print("Loading seed meals data...")
    try:
        call_command('load_seed_meals')
        print("✅ Seed data loaded successfully!")
    except Exception as e:
        print(f"❌ Error loading seed data: {e}")
        sys.exit(1)

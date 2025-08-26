from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model
from django.utils import timezone
from datetime import timedelta

User = get_user_model()

class Command(BaseCommand):
    help = 'Manage users for Foodo application - ensure proper admin visibility'

    def add_arguments(self, parser):
        parser.add_argument(
            '--list',
            action='store_true',
            help='List all users with their status',
        )
        parser.add_argument(
            '--fix-inactive',
            action='store_true',
            help='Fix inactive users that should be active',
        )
        parser.add_argument(
            '--cleanup',
            action='store_true',
            help='Clean up users and mark appropriate ones as inactive',
        )
        parser.add_argument(
            '--stats',
            action='store_true',
            help='Show user statistics',
        )

    def handle(self, *args, **options):
        if options['list']:
            self.list_users()
        elif options['fix_inactive']:
            self.fix_inactive_users()
        elif options['cleanup']:
            self.cleanup_users()
        elif options['stats']:
            self.show_stats()
        else:
            self.stdout.write(
                self.style.WARNING('Please specify an action. Use --help for options.')
            )

    def list_users(self):
        """List all users with their status"""
        self.stdout.write(self.style.SUCCESS('📋 User List:'))
        self.stdout.write('=' * 80)
        
        users = User.objects.all().order_by('date_joined')
        
        for user in users:
            status_icon = '✅' if user.is_active else '❌'
            verified_icon = '✅' if user.is_verified else '❌'
            chef_icon = '👨‍🍳' if user.is_chef else '👤'
            
            self.stdout.write(
                f"{status_icon} {user.id:3d} | {user.email:<30} | "
                f"{user.username:<20} | {verified_icon} | {chef_icon} | "
                f"{user.date_joined.strftime('%Y-%m-%d %H:%M')}"
            )
        
        self.stdout.write('=' * 80)
        self.stdout.write(f"Total users: {users.count()}")

    def fix_inactive_users(self):
        """Fix users that should be active but aren't"""
        self.stdout.write(self.style.SUCCESS('🔧 Fixing inactive users...'))
        
        # Find users that should be active (have email, not staff/superuser)
        inactive_users = User.objects.filter(
            is_active=False,
            email__isnull=False,
            is_staff=False,
            is_superuser=False
        )
        
        if inactive_users.exists():
            count = inactive_users.update(is_active=True)
            self.stdout.write(
                self.style.SUCCESS(f'✅ Activated {count} users')
            )
        else:
            self.stdout.write(
                self.style.WARNING('No inactive users found to activate')
            )

    def cleanup_users(self):
        """Clean up users and mark appropriate ones as inactive"""
        self.stdout.write(self.style.SUCCESS('🧹 Cleaning up users...'))
        
        # Mark users with no email as inactive
        no_email_users = User.objects.filter(
            email__isnull=True,
            is_active=True
        )
        
        if no_email_users.exists():
            count = no_email_users.update(is_active=False)
            self.stdout.write(
                self.style.WARNING(f'⚠️  Deactivated {count} users with no email')
            )
        
        # Mark very old unverified users as inactive (older than 30 days)
        old_unverified = User.objects.filter(
            is_verified=False,
            is_active=True,
            date_joined__lt=timezone.now() - timedelta(days=30)
        )
        
        if old_unverified.exists():
            count = old_unverified.update(is_active=False)
            self.stdout.write(
                self.style.WARNING(f'⚠️  Deactivated {count} old unverified users')
            )
        
        self.stdout.write(self.style.SUCCESS('✅ User cleanup completed'))

    def show_stats(self):
        """Show user statistics"""
        self.stdout.write(self.style.SUCCESS('📊 User Statistics:'))
        self.stdout.write('=' * 50)
        
        total_users = User.objects.count()
        active_users = User.objects.filter(is_active=True).count()
        verified_users = User.objects.filter(is_verified=True).count()
        chef_users = User.objects.filter(is_chef=True).count()
        staff_users = User.objects.filter(is_staff=True).count()
        superusers = User.objects.filter(is_superuser=True).count()
        
        # Recent users (last 7 days)
        week_ago = timezone.now() - timedelta(days=7)
        recent_users = User.objects.filter(date_joined__gte=week_ago).count()
        
        # Users by verification status
        unverified_users = User.objects.filter(is_verified=False).count()
        
        self.stdout.write(f"Total Users: {total_users}")
        self.stdout.write(f"Active Users: {active_users}")
        self.stdout.write(f"Verified Users: {verified_users}")
        self.stdout.write(f"Unverified Users: {unverified_users}")
        self.stdout.write(f"Chef Users: {chef_users}")
        self.stdout.write(f"Staff Users: {staff_users}")
        self.stdout.write(f"Superusers: {superusers}")
        self.stdout.write(f"Users (Last 7 days): {recent_users}")
        
        # Verification rate
        if total_users > 0:
            verification_rate = (verified_users / total_users) * 100
            self.stdout.write(f"Verification Rate: {verification_rate:.1f}%")
        
        self.stdout.write('=' * 50)

from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from django.utils.html import format_html
from django.urls import reverse
from django.utils.safestring import mark_safe
from .models import User, OTP
from django.utils import timezone

@admin.register(User)
class UserAdmin(BaseUserAdmin):
    """Custom User Admin for Foodo application"""
    
    # Fields to display in the list view
    list_display = [
        'id', 'email', 'username', 'full_name', 'phone', 'city', 
        'is_verified', 'is_active', 'is_chef', 'date_joined', 'last_login'
    ]
    
    # Fields that can be used for searching
    search_fields = ['email', 'username', 'first_name', 'last_name', 'phone']
    
    # Fields that can be used for filtering
    list_filter = [
        'is_verified', 'is_active', 'is_chef', 'date_joined', 
        'last_login', 'city', 'is_staff', 'is_superuser'
    ]
    
    # Fields that can be edited directly in the list view
    list_editable = ['is_verified', 'is_active', 'is_chef']
    
    # Number of items per page
    list_per_page = 25
    
    # Fields to display in the detail view
    fieldsets = (
        ('Basic Information', {
            'fields': ('email', 'username', 'password', 'first_name', 'last_name')
        }),
        ('Contact Information', {
            'fields': ('phone', 'address', 'city', 'zip_code')
        }),
        ('Account Status', {
            'fields': ('is_active', 'is_verified', 'is_chef', 'is_staff', 'is_superuser')
        }),
        ('Chef Information', {
            'fields': ('chef_bio', 'chef_rating', 'total_orders'),
            'classes': ('collapse',)
        }),
        ('Permissions', {
            'fields': ('groups', 'user_permissions'),
            'classes': ('collapse',)
        }),
        ('Important Dates', {
            'fields': ('date_joined', 'last_login'),
            'classes': ('collapse',)
        }),
    )
    
    # Fields to display when adding a new user
    add_fieldsets = (
        ('Basic Information', {
            'classes': ('wide',),
            'fields': ('email', 'username', 'password1', 'password2', 'first_name', 'last_name'),
        }),
        ('Contact Information', {
            'classes': ('wide',),
            'fields': ('phone', 'address', 'city', 'zip_code'),
        }),
        ('Account Status', {
            'classes': ('wide',),
            'fields': ('is_active', 'is_verified', 'is_chef'),
        }),
    )
    
    # Read-only fields
    readonly_fields = ['id', 'date_joined', 'last_login', 'chef_rating', 'total_orders']
    
    # Custom methods for display
    def full_name(self, obj):
        """Display full name or username if no name is set"""
        if obj.first_name and obj.last_name:
            return f"{obj.first_name} {obj.last_name}"
        elif obj.first_name:
            return obj.first_name
        elif obj.last_name:
            return obj.last_name
        else:
            return obj.username
    full_name.short_description = 'Full Name'
    full_name.admin_order_field = 'first_name'
    
    def get_queryset(self, request):
        """Optimize queryset for admin performance"""
        return super().get_queryset(request).select_related()
    
    # Custom actions
    actions = ['verify_users', 'deactivate_users', 'activate_users', 'make_chefs', 'remove_chefs']
    
    def verify_users(self, request, queryset):
        """Mark selected users as verified"""
        updated = queryset.update(is_verified=True)
        self.message_user(request, f'{updated} users have been marked as verified.')
    verify_users.short_description = "Mark selected users as verified"
    
    def deactivate_users(self, request, queryset):
        """Deactivate selected users"""
        updated = queryset.update(is_active=False)
        self.message_user(request, f'{updated} users have been deactivated.')
    deactivate_users.short_description = "Deactivate selected users"
    
    def activate_users(self, request, queryset):
        """Activate selected users"""
        updated = queryset.update(is_active=True)
        self.message_user(request, f'{updated} users have been activated.')
    activate_users.short_description = "Activate selected users"
    
    def make_chefs(self, request, queryset):
        """Make selected users chefs"""
        updated = queryset.update(is_chef=True)
        self.message_user(request, f'{updated} users have been made chefs.')
    make_chefs.short_description = "Make selected users chefs"
    
    def remove_chefs(self, request, queryset):
        """Remove chef status from selected users"""
        updated = queryset.update(is_chef=False)
        self.message_user(request, f'{updated} users are no longer chefs.')
    remove_chefs.short_description = "Remove chef status from selected users"

@admin.register(OTP)
class OTPAdmin(admin.ModelAdmin):
    """Admin for OTP model"""
    
    list_display = [
        'id', 'user_email', 'otp_code', 'created_at', 'expires_at', 
        'is_used', 'is_expired', 'time_remaining'
    ]
    
    list_filter = ['is_used', 'created_at', 'expires_at']
    
    search_fields = ['user__email', 'email', 'otp_code']
    
    readonly_fields = ['id', 'created_at', 'is_expired', 'time_remaining']
    
    list_per_page = 50
    
    fieldsets = (
        ('OTP Information', {
            'fields': ('user', 'email', 'otp_code', 'is_used')
        }),
        ('Timing', {
            'fields': ('created_at', 'expires_at', 'is_expired', 'time_remaining')
        }),
    )
    
    def user_email(self, obj):
        """Display user email with link to user admin"""
        if obj.user:
            url = reverse('admin:users_user_change', args=[obj.user.id])
            return format_html('<a href="{}">{}</a>', url, obj.user.email)
        return obj.email
    user_email.short_description = 'User Email'
    user_email.admin_order_field = 'user__email'
    
    def is_expired(self, obj):
        """Display if OTP is expired"""
        return obj.is_expired()
    is_expired.boolean = True
    is_expired.short_description = 'Expired'
    
    def time_remaining(self, obj):
        """Display time remaining until expiry"""
        if obj.is_expired():
            return "Expired"
        
        remaining = obj.expires_at - obj.created_at.replace(tzinfo=obj.expires_at.tzinfo)
        minutes = remaining.total_seconds() / 60
        
        if minutes < 1:
            return "Less than 1 minute"
        elif minutes < 60:
            return f"{int(minutes)} minutes"
        else:
            hours = minutes / 60
            return f"{hours:.1f} hours"
    
    time_remaining.short_description = 'Time Remaining'
    
    # Custom actions
    actions = ['mark_as_used', 'delete_expired_otps']
    
    def mark_as_used(self, request, queryset):
        """Mark selected OTPs as used"""
        updated = queryset.update(is_used=True)
        self.message_user(request, f'{updated} OTPs have been marked as used.')
    mark_as_used.short_description = "Mark selected OTPs as used"
    
    def delete_expired_otps(self, request, queryset):
        """Delete expired OTPs"""
        expired_otps = queryset.filter(expires_at__lt=timezone.now())
        count = expired_otps.count()
        expired_otps.delete()
        self.message_user(request, f'{count} expired OTPs have been deleted.')
    delete_expired_otps.short_description = "Delete expired OTPs"

# Customize admin site
admin.site.site_header = "Foodo Administration"
admin.site.site_title = "Foodo Admin Portal"
admin.site.index_title = "Welcome to Foodo Administration"

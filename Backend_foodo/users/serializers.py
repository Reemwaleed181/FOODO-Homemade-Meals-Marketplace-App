from rest_framework import serializers
from django.contrib.auth import authenticate
from .models import User, Address

class AddressSerializer(serializers.ModelSerializer):
    class Meta:
        model = Address
        fields = ('id', 'type', 'label', 'full_name', 'street_address', 
                 'city', 'zip_code', 'phone', 'instructions', 'is_default',
                 'created_at', 'updated_at')
        read_only_fields = ('id', 'created_at', 'updated_at')

class UserSerializer(serializers.ModelSerializer):
    name = serializers.SerializerMethodField()  # Add computed name field
    addresses = AddressSerializer(many=True, read_only=True)
    
    class Meta:
        model = User
        fields = ('id', 'username', 'email', 'name', 'first_name', 'last_name', 'phone', 'address', 
                 'city', 'zip_code', 'is_chef', 'chef_bio', 
                 'chef_rating', 'total_orders', 'is_verified', 'profile_picture', 'addresses')
        read_only_fields = ('id', 'is_chef', 'is_verified', 'addresses', 'name')

    def get_name(self, obj):
        """Combine first_name and last_name or return username"""
        if obj.first_name and obj.last_name:
            return f"{obj.first_name} {obj.last_name}"
        elif obj.first_name:
            return obj.first_name
        else:
            return obj.username

class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField()

    def validate(self, data):
        email = data.get('email')
        password = data.get('password')

        if not email or not password:
            raise serializers.ValidationError('Email and password are required.')

        # First check if the email exists in the database
        try:
            user = User.objects.get(email=email)
        except User.DoesNotExist:
            raise serializers.ValidationError('This email is not registered. Please sign up first.')
        
        # Check if user account is active
        if not user.is_active:
            raise serializers.ValidationError('Your account has been disabled. Please contact support.')
        
        # Now attempt to authenticate with the provided credentials
        authenticated_user = authenticate(username=email, password=password)
        if not authenticated_user:
            raise serializers.ValidationError('Invalid password. Please check your credentials and try again.')
        
        # Check if the authenticated user matches the found user
        if authenticated_user.id != user.id:
            raise serializers.ValidationError('Authentication failed. Please try again.')
        
        # Email verification is no longer required for login
        # Users can login immediately after registration
        
        data['user'] = authenticated_user
        return data

class SignupSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)
    name = serializers.CharField(write_only=True)  # Add name field

    class Meta:
        model = User
        fields = ('email', 'password', 'name', 'phone', 
                 'address', 'city', 'zip_code', 'is_chef', 'profile_picture')

    def create(self, validated_data):
        # Extract name and use it as username
        name = validated_data.pop('name', '')
        email = validated_data['email']
        
        # Generate username from email if name is empty
        username = name if name else email.split('@')[0]
        
        # Ensure username is unique
        base_username = username
        counter = 1
        while User.objects.filter(username=username).exists():
            username = f"{base_username}{counter}"
            counter += 1
        
        # Create user with proper defaults
        user = User.objects.create_user(
            username=username,
            email=email,
            password=validated_data['password'],
            phone=validated_data.get('phone', ''),
            address=validated_data.get('address', ''),
            city=validated_data.get('city', ''),
            zip_code=validated_data.get('zip_code', ''),
            profile_picture=validated_data.get('profile_picture', ''),
            # Ensure user is active and properly configured
            is_active=True,  # User is active by default
            is_verified=False,  # Email verification required
            is_chef=validated_data.get('is_chef', False),  # Chef status from signup
            is_staff=False,  # Not admin staff by default
            is_superuser=False,  # Not superuser by default
        )
        
        # Set first_name and last_name from name
        if name:
            name_parts = name.split(' ', 1)
            user.first_name = name_parts[0]
            if len(name_parts) > 1:
                user.last_name = name_parts[1]
        
        # Save the user to ensure all fields are properly stored
        user.save()
        
        return user

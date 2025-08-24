from rest_framework import serializers
from django.contrib.auth import authenticate
from .models import User

class UserSerializer(serializers.ModelSerializer):
    name = serializers.SerializerMethodField()  # Add computed name field
    
    class Meta:
        model = User
        fields = ('id', 'username', 'email', 'name', 'phone', 'address', 
                 'city', 'zip_code', 'is_chef', 'chef_bio', 
                 'chef_rating', 'total_orders', 'is_verified')
        read_only_fields = ('id', 'is_chef', 'is_verified')
    
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

        if email and password:
            user = authenticate(username=email, password=password)
            if user:
                if user.is_active:
                    data['user'] = user
                else:
                    raise serializers.ValidationError('User account is disabled.')
            else:
                raise serializers.ValidationError('Unable to log in with provided credentials.')
        else:
            raise serializers.ValidationError('Must include "email" and "password".')

        return data

class SignupSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)
    name = serializers.CharField(write_only=True)  # Add name field

    class Meta:
        model = User
        fields = ('email', 'password', 'name', 'phone', 
                 'address', 'city', 'zip_code')

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
        
        user = User.objects.create_user(
            username=username,
            email=email,
            password=validated_data['password'],
            phone=validated_data.get('phone', ''),
            address=validated_data.get('address', ''),
            city=validated_data.get('city', ''),
            zip_code=validated_data.get('zip_code', ''),
        )
        
        # Set first_name and last_name from name
        if name:
            name_parts = name.split(' ', 1)
            user.first_name = name_parts[0]
            if len(name_parts) > 1:
                user.last_name = name_parts[1]
            user.save()
        
        return user
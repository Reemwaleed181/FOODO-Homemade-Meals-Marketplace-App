from rest_framework import serializers
from .models import Order, OrderItem
from meals.serializers import MealSerializer

class OrderItemSerializer(serializers.ModelSerializer):
    meal_name = serializers.CharField(source='meal.name', read_only=True)
    meal_image = serializers.CharField(source='meal.image.url', read_only=True)
    
    class Meta:
        model = OrderItem
        fields = '__all__'

class OrderSerializer(serializers.ModelSerializer):
    items = OrderItemSerializer(many=True, read_only=True)
    user_name = serializers.CharField(source='user.username', read_only=True)
    
    class Meta:
        model = Order
        fields = '__all__'
        read_only_fields = ('user', 'subtotal', 'delivery_fee', 'tax', 'total', 'created_at', 'status')
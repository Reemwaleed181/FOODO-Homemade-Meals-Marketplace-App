from rest_framework import serializers
from .models import Meal, Nutrition

class NutritionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Nutrition
        fields = '__all__'

class MealSerializer(serializers.ModelSerializer):
    nutrition = NutritionSerializer(read_only=True)
    chef_name = serializers.CharField(source='chef.username', read_only=True)
    
    class Meta:
        model = Meal
        fields = '__all__'
        read_only_fields = ('chef', 'rating', 'order_count', 'created_at')
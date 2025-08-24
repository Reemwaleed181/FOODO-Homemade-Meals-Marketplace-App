from django.db import models
from users.models import User

class Nutrition(models.Model):
    calories = models.IntegerField()
    protein = models.FloatField()
    carbs = models.FloatField()
    fat = models.FloatField()
    fiber = models.FloatField()
    sugar = models.FloatField()
    
    def __str__(self):
        return f"{self.calories} calories"

class Meal(models.Model):
    name = models.CharField(max_length=255)
    description = models.TextField()
    chef = models.ForeignKey(User, on_delete=models.CASCADE, related_name='meals')
    price = models.DecimalField(max_digits=6, decimal_places=2)
    image = models.ImageField(upload_to='meals/')
    prep_time = models.CharField(max_length=50)
    portion_size = models.CharField(max_length=50)
    rating = models.FloatField(default=0.0)
    order_count = models.IntegerField(default=0)
    tags = models.JSONField(default=list)
    is_vegetarian = models.BooleanField(default=False)
    is_vegan = models.BooleanField(default=False)
    is_gluten_free = models.BooleanField(default=False)
    nutrition = models.OneToOneField(Nutrition, on_delete=models.CASCADE, null=True, blank=True)
    ingredients = models.JSONField(default=list)
    allergens = models.JSONField(default=list)
    created_at = models.DateTimeField(auto_now_add=True)
    is_active = models.BooleanField(default=True)
    
    def __str__(self):
        return self.name
import json
import os
from django.core.management.base import BaseCommand
from django.contrib.auth.models import User
from meals.models import Meal, Nutrition
from datetime import datetime

class Command(BaseCommand):
    help = 'Load seed meals from JSON file into database'

    def handle(self, *args, **options):
        # Path to the meals.json file
        json_file_path = os.path.join(
            os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(__file__)))),
            '..', 'assets', 'data', 'meals.json'
        )
        
        try:
            with open(json_file_path, 'r') as file:
                data = json.load(file)
            
            meals_data = data.get('meals', [])
            
            # Create demo chef users if they don't exist
            chef_users = {}
            for meal_data in meals_data:
                chef_name = meal_data.get('chef', 'Demo Chef')
                chef_id = meal_data.get('chefId', 'demo-chef')
                
                if chef_id not in chef_users:
                    # Create or get chef user
                    chef_user, created = User.objects.get_or_create(
                        username=chef_id,
                        defaults={
                            'first_name': chef_name.split()[0] if ' ' in chef_name else chef_name,
                            'last_name': chef_name.split()[1] if ' ' in chef_name else '',
                            'email': f'{chef_id}@demo.com',
                            'is_chef': True,
                        }
                    )
                    chef_users[chef_id] = chef_user
                    if created:
                        self.stdout.write(f'Created chef user: {chef_name}')
            
            # Load meals
            for meal_data in meals_data:
                # Check if meal already exists
                if Meal.objects.filter(name=meal_data['name']).exists():
                    self.stdout.write(f'Meal "{meal_data["name"]}" already exists, skipping...')
                    continue
                
                # Create nutrition data
                nutrition_data = meal_data.get('nutrition', {})
                nutrition = Nutrition.objects.create(
                    calories=nutrition_data.get('calories', 0),
                    protein=nutrition_data.get('protein', 0),
                    carbs=nutrition_data.get('carbs', 0),
                    fat=nutrition_data.get('fat', 0),
                    fiber=nutrition_data.get('fiber', 0),
                    sugar=nutrition_data.get('sugar', 0),
                )
                
                # Create meal
                chef_id = meal_data.get('chefId', 'demo-chef')
                chef_user = chef_users[chef_id]
                
                meal = Meal.objects.create(
                    name=meal_data['name'],
                    description=meal_data['description'],
                    chef=chef_user,
                    price=meal_data['price'],
                    image=meal_data['image'],  # This will be a URL, you might want to download and store locally
                    prep_time=meal_data['prepTime'],
                    portion_size=meal_data['portionSize'],
                    rating=meal_data['rating'],
                    order_count=meal_data['orderCount'],
                    tags=meal_data['tags'],
                    is_vegetarian=meal_data['isVegetarian'],
                    is_vegan=meal_data['isVegan'],
                    is_gluten_free=meal_data['isGlutenFree'],
                    nutrition=nutrition,
                    ingredients=meal_data['ingredients'],
                    allergens=meal_data['allergens'],
                    is_active=meal_data['isActive'],
                )
                
                self.stdout.write(f'Created meal: {meal.name}')
            
            self.stdout.write(
                self.style.SUCCESS(f'Successfully loaded {len(meals_data)} meals into database')
            )
            
        except FileNotFoundError:
            self.stdout.write(
                self.style.ERROR(f'Could not find meals.json file at {json_file_path}')
            )
        except Exception as e:
            self.stdout.write(
                self.style.ERROR(f'Error loading meals: {str(e)}')
            )

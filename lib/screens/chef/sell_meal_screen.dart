import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_state.dart';
import '../../providers/navigation_provider.dart';
import '../../models/meal.dart';
import '../../models/user.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input.dart';
import '../../widgets/custom_badge.dart';

class SellMealScreen extends StatefulWidget {
  @override
  _SellMealScreenState createState() => _SellMealScreenState();
}

class _SellMealScreenState extends State<SellMealScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _prepTimeController = TextEditingController();
  final _portionSizeController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  final _fiberController = TextEditingController();
  final _sugarController = TextEditingController();

  final List<String> _tags = [];
  final List<String> _ingredients = [''];
  final List<String> _selectedAllergens = [];
  final List<String> _predefinedTags = [
    'Italian', 'Mexican', 'Asian', 'Mediterranean', 'Indian', 'American',
    'Healthy', 'Comfort Food', 'Spicy', 'Sweet', 'Protein-Rich', 'Low-Carb',
  ];
  final List<String> _commonAllergens = [
    'Nuts', 'Dairy', 'Eggs', 'Soy', 'Gluten', 'Shellfish', 'Fish', 'Sesame'
  ];

  bool _isVegetarian = false;
  bool _isVegan = false;
  bool _isGlutenFree = false;
  bool _isActive = true;
  bool _isSubmitting = false;
  bool _isSuccess = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _prepTimeController.dispose();
    _portionSizeController.dispose();
    _imageUrlController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _fiberController.dispose();
    _sugarController.dispose();
    super.dispose();
  }

  void _addTag(String tag) {
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() => _tags.add(tag));
    }
  }

  void _removeTag(String tag) {
    setState(() => _tags.remove(tag));
  }

  void _updateIngredient(int index, String value) {
    setState(() => _ingredients[index] = value);
  }

  void _addIngredient() {
    setState(() => _ingredients.add(''));
  }

  void _removeIngredient(int index) {
    if (_ingredients.length > 1) {
      setState(() => _ingredients.removeAt(index));
    }
  }

  void _toggleAllergen(String allergen) {
    setState(() {
      if (_selectedAllergens.contains(allergen)) {
        _selectedAllergens.remove(allergen);
      } else {
        _selectedAllergens.add(allergen);
      }
    });
  }

  Future<void> _submitMeal() async {
    if (_nameController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _priceController.text.isEmpty) {
      return;
    }

    setState(() => _isSubmitting = true);

    final appState = Provider.of<AppState>(context, listen: false);
    final user = appState.user!;

    final newMeal = Meal(
      id: 'user-meal-${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text,
      description: _descriptionController.text,
      chef: user.name,
      chefId: user.id,
      price: double.parse(_priceController.text),
      image: _imageUrlController.text.isNotEmpty
          ? _imageUrlController.text
          : 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=800&auto=format&fit=crop&q=60',
      prepTime: _prepTimeController.text,
      portionSize: _portionSizeController.text,
      rating: 5.0,
      orderCount: 0,
      tags: _tags,
      isVegetarian: _isVegetarian,
      isVegan: _isVegan,
      isGlutenFree: _isGlutenFree,
      nutrition: Nutrition(
        calories: int.tryParse(_caloriesController.text) ?? 0,
        protein: int.tryParse(_proteinController.text) ?? 0,
        carbs: int.tryParse(_carbsController.text) ?? 0,
        fat: int.tryParse(_fatController.text) ?? 0,
        fiber: int.tryParse(_fiberController.text) ?? 0,
        sugar: int.tryParse(_sugarController.text) ?? 0,
      ),
      ingredients: _ingredients.where((ing) => ing.isNotEmpty).toList(),
      allergens: _selectedAllergens,
      createdAt: DateTime.now(),
      isActive: _isActive,
    );

    appState.addUserMeal(newMeal);

    setState(() => _isSubmitting = false);
    setState(() => _isSuccess = true);

    await Future.delayed(Duration(seconds: 2));
    if (mounted) {
      context.read<NavigationProvider>().navigateTo(AppPage.chefDashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.user;

    if (user == null || !user.isChef) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.restaurant, size: 64, color: Colors.orange),
              SizedBox(height: 16),
              Text('Chef Access Required', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('You need to be registered as a chef to add meals for sale.'),
              SizedBox(height: 24),
              CustomButton(
                text: 'Become a Chef',
                onPressed: () => context.read<NavigationProvider>().navigateTo(AppPage.profile),
              ),
            ],
          ),
        ),
      );
    }

    if (_isSuccess) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, size: 64, color: Colors.green),
              SizedBox(height: 16),
              Text('Meal Added Successfully!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Your delicious meal is now available for customers to order.'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Meal'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.read<NavigationProvider>().navigateTo(AppPage.chefDashboard),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Basic Information
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Basic Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 16),
                    CustomInput(
                      controller: _nameController,
                      label: 'Meal Name *',
                      hintText: 'e.g., Grandma\'s Homemade Lasagna',
                    ),
                    SizedBox(height: 16),
                    CustomInput(
                      controller: _descriptionController,
                      label: 'Description *',
                      hintText: 'Describe your meal, cooking method, and what makes it special...',
                      maxLines: 4,
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomInput(
                            controller: _priceController,
                            label: 'Price (\$) *',
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            // FIXED: Removed prefixText parameter
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: CustomInput(
                            controller: _portionSizeController,
                            label: 'Portion Size *',
                            hintText: 'Serves 2-3',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    CustomInput(
                      controller: _prepTimeController,
                      label: 'Preparation Time *',
                      hintText: '30 minutes',
                    ),
                    SizedBox(height: 16),
                    CustomInput(
                      controller: _imageUrlController,
                      label: 'Image URL (Optional)',
                      hintText: 'https://example.com/meal-image.jpg',
                    ),
                  ],
                ),
              ),
            ),

            // ... rest of the file remains the same
            SizedBox(height: 16),
            CustomButton(
              text: _isSubmitting ? 'Adding Meal...' : 'Add Meal for Sale',
              onPressed: _isSubmitting ? null : _submitMeal,
              size: ButtonSize.large,
            ),
          ],
        ),
      ),
    );
  }
}
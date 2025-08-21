import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/meal_provider.dart';
import '../../models/app_state.dart';
import '../../models/cart_item.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/image_with_fallback.dart';

class MealDetailScreen extends StatefulWidget {
  const MealDetailScreen({super.key});

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  int _quantity = 1;
  bool _isAddedToCart = false;

  void _addToCart(AppState appState, String mealId) {
    final meal = appState.getMealById(mealId);
    if (meal == null) return;

    final newItem = CartItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      mealId: meal.id,
      name: meal.name,
      chef: meal.chef,
      price: meal.price,
      image: meal.image,
      quantity: _quantity,
      portionSize: meal.portionSize,
    );

    appState.addToCart(newItem);
    setState(() => _isAddedToCart = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _isAddedToCart = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final navigation = context.watch<NavigationProvider>();
    final mealProvider = context.watch<MealProvider>();
    final appState = context.watch<AppState>();

    final selectedId = navigation.selectedMealId;
    final meal = selectedId != null ? mealProvider.getMealById(selectedId) : null;

    if (meal == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Meal not found', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 12),
              CustomButton(
                text: 'Back to Home',
                onPressed: () =>
                    context.read<NavigationProvider>().navigateTo(AppPage.home),
              ),
            ],
          ),
        ),
      );
    }

    final totalPrice = (meal.price * _quantity).toStringAsFixed(2);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
              Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  onTap: () =>
                      context.read<NavigationProvider>().navigateTo(AppPage.home),
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text('Back to Meals',
                            style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Meal Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ImageWithFallback(
                  imageUrl: meal.image,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 16),

              // Meal Title and Rating
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      meal.name,
                      style:
                      const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(meal.rating.toString()),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 8),
              Text('by ${meal.chef}', style: TextStyle(color: Colors.grey[600])),

              const SizedBox(height: 12),
              Text(meal.description,
                  style: TextStyle(color: Colors.grey[700], height: 1.4)),

              const SizedBox(height: 16),

              // Quantity Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Quantity', style: TextStyle(fontWeight: FontWeight.w600)),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _quantity > 1 ? () => setState(() => _quantity--) : null,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: _quantity > 1 ? Colors.grey[200] : Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.remove,
                              size: 16,
                              color: _quantity > 1 ? Colors.grey[700] : Colors.grey[400]),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('$_quantity',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => setState(() => _quantity++),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.add, size: 16, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Total Price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  Text('\$$totalPrice',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),

              const SizedBox(height: 16),

              // Add to Cart and View Cart Buttons
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: _isAddedToCart
                          ? 'Added!'
                          : 'Add to Cart - \$$totalPrice',
                      onPressed:
                      _isAddedToCart ? null : () => _addToCart(appState, meal.id),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () =>
                        context.read<NavigationProvider>().navigateTo(AppPage.cart),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: const Text('View Cart'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

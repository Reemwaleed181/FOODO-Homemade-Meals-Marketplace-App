import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/navigation_provider.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/meal_provider.dart';
import '../../../theme/app_colors.dart';

class MealDetailScreen extends StatefulWidget {
  const MealDetailScreen({super.key});

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isLiked = false;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);
    final mealProvider = Provider.of<MealProvider>(context);
    final mealId = navigationProvider.selectedMealId;

    // Get the actual meal from the provider
    final meal = mealProvider.getMealById(mealId ?? '1');

    // If meal is not found, show error
    if (meal == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.backgroundPrimary,
                AppColors.backgroundSecondary,
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Meal Not Found',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'The requested meal could not be found.',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryLight],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Go Back',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: CustomScrollView(
        slivers: [
          // Modern Hero Header with Parallax Effect
          SliverAppBar(
            expandedHeight: 320,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Hero Image with Parallax
                  Container(
                    height: 320,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(meal.image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  
                  // Modern Gradient Overlay
                  Container(
                    height: 320,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.1),
                          Colors.black.withOpacity(0.4),
                          Colors.black.withOpacity(0.7),
                        ],
                        stops: const [0.0, 0.4, 0.7, 1.0],
                      ),
                    ),
                  ),
                  
                  // Floating Action Buttons
                  Positioned(
                    top: 30,
                    left: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            child: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Like Button
                  Positioned(
                    top: 30,
                    right: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            setState(() {
                              _isLiked = !_isLiked;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            child: Icon(
                              _isLiked ? Icons.favorite : Icons.favorite_border,
                              color: _isLiked ? Colors.red : Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Rating Badge with Glassmorphism
                  Positioned(
                    bottom: 33,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.star,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${meal.rating} (${meal.orderCount})',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Modern Content with Animations
          SliverToBoxAdapter(
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                                  child: Container(
                    padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and Rating Section (like first image)
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                            child: Text(
                                    meal.name,
                                    style: const TextStyle(
                                fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2C3E50),
                                      height: 1.2,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                    children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${meal.rating}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2C3E50),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                                            Text(
                                '(${meal.orderCount} orders)',
                                              style: TextStyle(
                                  fontSize: 13,
                                                color: AppColors.textSecondary,
                                  fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                          ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Simple Description (like first image)
                      Text(
                          meal.description,
                          style: TextStyle(
                          fontSize: 15,
                            color: AppColors.textSecondary,
                            height: 1.6,
                          fontWeight: FontWeight.normal,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Simple Stats Row (like first image)
                      Row(
                          children: [
                          _buildSimpleStatItem(
                            Icons.access_time_outlined,
                            meal.prepTime,
                          ),
                          const SizedBox(width: 24),
                          _buildSimpleStatItem(
                            Icons.scale_outlined,
                              meal.portionSize,
                          ),
                          const SizedBox(width: 24),
                          _buildSimpleStatItem(
                            Icons.local_fire_department,
                            '${meal.nutrition.calories} calories',
                            ),
                          ],
                        ),

                      const SizedBox(height: 28),

                      // Simple Dietary Tags (like first image)
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          ...meal.tags.map((tag) => _buildSimpleDietaryTag(tag)),
                          if (meal.isGlutenFree)
                            _buildSimpleDietaryTag('Gluten-Free', hasIcon: true),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Nutrition Facts Card (like second image)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            const Text(
                              'Nutritional Facts',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Separator line
                            Divider(
                              color: Colors.grey.shade300,
                              thickness: 1,
                              height: 1,
                            ),
                            const SizedBox(height: 16),
                            // Nutrition items
                            _buildNutritionFactItem('Calories', '${meal.nutrition.calories} Cal', isLast: false),
                            _buildNutritionFactItem('Protein', '${meal.nutrition.protein} g', isLast: false),
                            _buildNutritionFactItem('Carbs', '${meal.nutrition.carbs} g', isLast: false),
                            _buildNutritionFactItem('Fat', '${meal.nutrition.fat} g', isLast: false),
                            _buildNutritionFactItem('Fiber', '${meal.nutrition.fiber} g', isLast: false),
                            _buildNutritionFactItem('Sugar', '${meal.nutrition.sugar} g', isLast: true),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Ingredients Section (like image)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ingredients',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: meal.ingredients.map((ingredient) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              ingredient,
                              style: TextStyle(
                                fontSize: 14,
                                    color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )).toList(),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      const SizedBox(height: 20),

                      // Allergen Information Section (like image)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.orange.shade200,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.orange.shade700,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Allergen Information',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange.shade800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    meal.allergens.isEmpty
                                        ? 'No known allergens'
                                        : 'Contains: ${meal.allergens.join(', ')}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.orange.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Price and Quantity Section (like image)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Price Display
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                  '\$${meal.price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    'per serving',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            
                            // Quantity Selector
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                    Text(
                                  'Quantity:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(Icons.remove, size: 20),
                                        color: AppColors.textPrimary,
                                        onPressed: () {
                                          if (_quantity > 1) {
                                            setState(() {
                                              _quantity--;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                    Container(
                                      width: 50,
                                      alignment: Alignment.center,
                                      child: Text(
                                        '$_quantity',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(Icons.add, size: 20),
                                        color: AppColors.textPrimary,
                                        onPressed: () {
                                          setState(() {
                                            _quantity++;
                                          });
                                        },
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
                                Text(
                                  'Total:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '\$${(_quantity * meal.price).toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                    ),
                                  ],
                                ),
                            const SizedBox(height: 20),
                            
                            // Action Buttons
                            Row(
                              children: [
                                Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                      context.read<CartProvider>().addToCart(meal, _quantity);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${meal.name} added to cart!'),
                                        backgroundColor: AppColors.success,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        margin: const EdgeInsets.all(16),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                        const Icon(Icons.shopping_cart, size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Add to Cart - \$${(_quantity * meal.price).toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      context.read<NavigationProvider>().navigateTo(AppPage.cart);
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.textPrimary,
                                      side: BorderSide(color: Colors.grey.shade300),
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      'View Cart',
                                        style: TextStyle(
                                          fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                  ),
                                ),
                              ],
                              ),
                          ],
                        ),
                                              ),

                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  // Simple stat item (like first image)
  Widget _buildSimpleStatItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 15,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
  }

  // Simple dietary tag (like first image - light grey background)
  Widget _buildSimpleDietaryTag(String text, {bool hasIcon = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasIcon) ...[
            const Icon(
              Icons.auto_awesome,
              size: 14,
              color: Colors.amber,
            ),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Nutrition fact item (like second image - label left, value right)
  Widget _buildNutritionFactItem(String label, String value, {bool isLast = false}) {
    return Column(
        children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
          Text(
            label,
            style: TextStyle(
                  fontSize: 15,
              color: AppColors.textSecondary,
                  fontWeight: FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
        ),
        if (!isLast)
          Divider(
            color: Colors.grey.shade300,
            thickness: 1,
            height: 1,
          ),
      ],
    );
  }
}

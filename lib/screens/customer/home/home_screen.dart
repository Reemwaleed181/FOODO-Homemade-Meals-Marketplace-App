import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/meal_provider.dart';
import '../../../providers/navigation_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../models/meal.dart';
import '../../../widgets/modern_drawer.dart';
import 'meal_card.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _categories = [];
  String? _selectedCategory;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _mealsSectionKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToMealsSection() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_mealsSectionKey.currentContext != null) {
        Scrollable.ensureVisible(
          _mealsSectionKey.currentContext!,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
          alignment: 0.1, // Show section near top with some padding
        );
      }
    });
  }

  Future<void> _loadCategories() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/data/app_config.json',
      );
      final data = json.decode(response);
      setState(() {
        _categories = List<Map<String, dynamic>>.from(data['categories'] ?? []);
      });
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  IconData _getIconForCategory(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'restaurant':
        return Icons.restaurant;
      case 'favorite':
        return Icons.favorite;
      case 'home':
        return Icons.home;
      case 'breakfast_dining':
        return Icons.breakfast_dining;
      case 'lunch_dining':
        return Icons.lunch_dining;
      case 'dinner_dining':
        return Icons.dinner_dining;
      case 'cake':
        return Icons.cake;
      default:
        return Icons.restaurant;
    }
  }

  Color _getColorFromHex(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  Widget _buildGradientBackground(
    Map<String, dynamic> category,
    List<dynamic>? gradientColors,
  ) {
    if (gradientColors != null && gradientColors.length >= 2) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _getColorFromHex(gradientColors[0] as String),
              _getColorFromHex(gradientColors[1] as String),
            ],
          ),
        ),
      );
    } else {
      final color = _getColorFromHex(category['color'] ?? '#4E94AB');
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.withOpacity(0.7)],
          ),
        ),
      );
    }
  }

  List<Meal> _getFilteredMealsByCategory(MealProvider mealProvider) {
    // Start with dietary filtered meals
    List<Meal> meals =
        mealProvider.filteredMeals.where((meal) => meal.isActive).toList();

    // Then apply category filter if selected
    if (_selectedCategory != null) {
      // Map category IDs to tag names
      final categoryTagMap = {
        'breakfast': 'Breakfast',
        'lunch': 'Lunch',
        'dinner': 'Dinner',
        'dessert': 'Dessert',
        'asian': 'Asian',
        'italian': 'Italian',
        'indian': 'Indian',
        'healthy': 'Healthy',
      };

      final tagName = categoryTagMap[_selectedCategory] ?? _selectedCategory!;
      meals =
          meals
              .where(
                (meal) => meal.tags.any(
                  (tag) => tag.toLowerCase() == tagName.toLowerCase(),
                ),
              )
              .toList();
    }

    return meals;
  }

  String _getFilterTitle(String filter) {
    switch (filter) {
      case 'vegetarian':
        return '🌱 Vegetarian Meals';
      case 'vegan':
        return '🌿 Vegan Meals';
      case 'gluten-free':
        return '🌾 Gluten-Free Meals';
      case 'high-protein':
        return '💪 High Protein Meals';
      case 'low-calorie':
        return '🔥 Low Calorie Meals';
      case 'dairy-free':
        return '🥛 Dairy-Free Meals';
      case 'keto':
        return '🥑 Keto Meals';
      default:
        return '🍽️ All Meals';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final mealProvider = Provider.of<MealProvider>(context);
    final navigationProvider = Provider.of<NavigationProvider>(context);

    // Note: Chefs can access home screen via "Buying" button in navigation
    // So we don't redirect them automatically

    final filteredMeals = _getFilteredMealsByCategory(mealProvider);
    final popularMeals = mealProvider.getPopularMeals(limit: 8);
    final recentMeals = mealProvider.getRecentMeals(limit: 8);
    final featuredMeals = mealProvider.featuredMeals;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      endDrawer: const ModernDrawer(),
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header Section - First Pic (App Color Background Style)
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primaryDark,
                      AppColors.primaryLight,
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile and Greeting
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              // Hamburger Menu Icon
                              IconButton(
                                icon: const Icon(
                                  Icons.menu_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                onPressed: () {
                                  Scaffold.of(context).openEndDrawer();
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              const SizedBox(width: 8),
                              // Profile Picture
                              GestureDetector(
                                onTap:
                                    () => navigationProvider.navigateTo(
                                      AppPage.profile,
                                    ),
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 2,
                                    ),
                                  ),
                                  child: ClipOval(
                                    child:
                                        authProvider.user?.profilePicture !=
                                                    null &&
                                                authProvider
                                                    .user!
                                                    .profilePicture!
                                                    .isNotEmpty
                                            ? Image.asset(
                                              authProvider
                                                  .user!
                                                  .profilePicture!,
                                              fit: BoxFit.cover,
                                              errorBuilder: (
                                                context,
                                                error,
                                                stackTrace,
                                              ) {
                                                return Container(
                                                  color: Colors.white
                                                      .withOpacity(0.2),
                                                  child: const Icon(
                                                    Icons.person,
                                                    color: Colors.white,
                                                    size: 24,
                                                  ),
                                                );
                                              },
                                            )
                                            : Container(
                                              color: Colors.white.withOpacity(
                                                0.2,
                                              ),
                                              child: const Icon(
                                                Icons.person,
                                                color: Colors.white,
                                                size: 24,
                                              ),
                                            ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hello, ${authProvider.user?.name ?? 'Foodie'}!',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Check Amazing homemade meals..',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.9),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          // Notification Icon
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Stack(
                              children: [
                                const Center(
                                  child: Icon(
                                    Icons.notifications_outlined,
                                    color: Color(0xFF2C3E50),
                                    size: 22,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Search Bar
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Search functionality coming soon!',
                              ),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search_rounded,
                                color: AppColors.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Search..',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
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
            ),

            // Hero Banner - "Delicious Food Is Waiting For You" (Second Pic - No Buttons)
            if (_selectedCategory == null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Container(
                    height: 240,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFF5F5F5),
                          const Color(0xFFFFF8F0),
                          const Color(0xFFFFF4E6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Left side - Text content
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          right: 160,
                          child: Padding(
                            padding: const EdgeInsets.all(28),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: const Text(
                                    'Delicious Food Is\nWaiting For You',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2C3E50),
                                      letterSpacing: -0.8,
                                      height: 1.2,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Flexible(
                                  child: Text(
                                    'Discover amazing meals from local home chefs.\nFresh ingredients, authentic flavors, delivered to you.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                      height: 1.4,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Right side - Food image
                        Positioned(
                          right: -20,
                          top: 20,
                          bottom: 20,
                          child: Container(
                            width: 180,
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.asset(
                                'images/food8.png',
                                fit: BoxFit.cover,
                                width: 180,
                                height: 200,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: AppColors.primary.withOpacity(0.1),
                                    child: Image.asset(
                                      'images/food8.png',
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Modern Categories Section
            if (_categories.isNotEmpty)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 28, top: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Modern Section Header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              AppColors.primary,
                                              AppColors.primaryDark,
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.primary
                                                  .withOpacity(0.4),
                                              blurRadius: 12,
                                              offset: const Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.apps_rounded,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      const Text(
                                        'Explore Categories',
                                        style: TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1A202C),
                                          letterSpacing: -0.8,
                                          height: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),
                            if (_selectedCategory != null)
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOutBack,
                                builder: (context, value, child) {
                                  final clampedValue = value.clamp(0.0, 1.0);
                                  return Transform.scale(
                                    scale: clampedValue,
                                    child: Opacity(
                                      opacity: clampedValue,
                                      child: child,
                                    ),
                                  );
                                },
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedCategory = null;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.primary,
                                          AppColors.primaryDark,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary.withOpacity(
                                            0.4,
                                          ),
                                          blurRadius: 12,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.close_rounded,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Clear',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Modern Category Cards with Enhanced Design
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          physics: const BouncingScrollPhysics(),
                          itemCount: _categories.length,
                          itemBuilder: (context, index) {
                            final category = _categories[index];
                            final isSelected =
                                _selectedCategory == category['id'];
                            final imagePath = category['image'] as String?;
                            final gradientColors =
                                category['gradient'] as List<dynamic>?;

                            return TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: Duration(
                                milliseconds: 300 + (index * 50),
                              ),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, child) {
                                final clampedValue = value.clamp(0.0, 1.0);
                                return Transform.scale(
                                  scale: 0.85 + (clampedValue * 0.15),
                                  child: Opacity(
                                    opacity: clampedValue,
                                    child: Transform.translate(
                                      offset: Offset(
                                        0,
                                        15 * (1 - clampedValue),
                                      ),
                                      child: child,
                                    ),
                                  ),
                                );
                              },
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedCategory =
                                        isSelected ? null : category['id'];
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOutCubic,
                                  width: 190,
                                  margin: EdgeInsets.only(
                                    right:
                                        index < _categories.length - 1 ? 16 : 0,
                                  ),
                                  transform:
                                      Matrix4.identity()
                                        ..scale(isSelected ? 1.03 : 1.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color:
                                          isSelected
                                              ? _getColorFromHex(
                                                category['color'] ?? '#4E94AB',
                                              )
                                              : Colors.white.withOpacity(0.5),
                                      width: isSelected ? 3 : 1.5,
                                    ),
                                    boxShadow:
                                        isSelected
                                            ? [
                                              BoxShadow(
                                                color: _getColorFromHex(
                                                  category['color'] ??
                                                      '#4E94AB',
                                                ).withOpacity(0.4),
                                                blurRadius: 24,
                                                offset: const Offset(0, 10),
                                                spreadRadius: 2,
                                              ),
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.1,
                                                ),
                                                blurRadius: 20,
                                                offset: const Offset(0, 8),
                                              ),
                                            ]
                                            : [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.08,
                                                ),
                                                blurRadius: 20,
                                                offset: const Offset(0, 8),
                                                spreadRadius: 0,
                                              ),
                                            ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(28),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        // Glow effect when selected
                                        if (isSelected)
                                          Container(
                                            decoration: BoxDecoration(
                                              gradient: RadialGradient(
                                                center: Alignment.center,
                                                radius: 1.5,
                                                colors: [
                                                  _getColorFromHex(
                                                    category['color'] ??
                                                        '#4E94AB',
                                                  ).withOpacity(0.3),
                                                  Colors.transparent,
                                                ],
                                              ),
                                            ),
                                          ),
                                        // Background - Image or Gradient
                                        if (imagePath != null)
                                          Image.asset(
                                            imagePath,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                            errorBuilder: (
                                              context,
                                              error,
                                              stackTrace,
                                            ) {
                                              return _buildGradientBackground(
                                                category,
                                                gradientColors,
                                              );
                                            },
                                          )
                                        else
                                          _buildGradientBackground(
                                            category,
                                            gradientColors,
                                          ),

                                        // Animated Gradient Overlay
                                        AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.transparent,
                                                isSelected
                                                    ? Colors.black.withOpacity(
                                                      0.85,
                                                    )
                                                    : Colors.black.withOpacity(
                                                      0.75,
                                                    ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        // Multiple Decorative circles for depth
                                        if (gradientColors != null ||
                                            imagePath == null) ...[
                                          Positioned(
                                            top: -40,
                                            right: -40,
                                            child: Container(
                                              width: 120,
                                              height: 120,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white.withOpacity(
                                                  0.12,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: -20,
                                            right: -20,
                                            child: Container(
                                              width: 80,
                                              height: 80,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white.withOpacity(
                                                  0.18,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: -30,
                                            left: -30,
                                            child: Container(
                                              width: 90,
                                              height: 90,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white.withOpacity(
                                                  0.1,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],

                                        // Enhanced Category Icon (for gradient cards)
                                        if (gradientColors != null ||
                                            imagePath == null)
                                          Positioned(
                                            top: 18,
                                            left: 18,
                                            child: TweenAnimationBuilder<
                                              double
                                            >(
                                              tween: Tween(
                                                begin: 0.0,
                                                end: isSelected ? 1.0 : 0.0,
                                              ),
                                              duration: const Duration(
                                                milliseconds: 400,
                                              ),
                                              curve: Curves.elasticOut,
                                              builder: (context, value, child) {
                                                return Transform.scale(
                                                  scale: 1.0 + (value * 0.2),
                                                  child: Transform.rotate(
                                                    angle: value * 0.1,
                                                    child: child,
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  12,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.3),
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                  border: Border.all(
                                                    color: Colors.white
                                                        .withOpacity(0.5),
                                                    width: 1.5,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.15),
                                                      blurRadius: 12,
                                                      offset: const Offset(
                                                        0,
                                                        4,
                                                      ),
                                                      spreadRadius: 0,
                                                    ),
                                                  ],
                                                ),
                                                child: Icon(
                                                  _getIconForCategory(
                                                    category['icon'] ??
                                                        'restaurant',
                                                  ),
                                                  color: Colors.white,
                                                  size: 32,
                                                ),
                                              ),
                                            ),
                                          ),

                                        // Enhanced Category Name Section
                                        Positioned(
                                          bottom: 0,
                                          left: 0,
                                          right: 0,
                                          child: Container(
                                            padding: const EdgeInsets.all(18),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Colors.transparent,
                                                  Colors.black.withOpacity(
                                                    0.95,
                                                  ),
                                                ],
                                                stops: const [0.0, 0.5],
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        category['name'] ?? '',
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                          letterSpacing: 0.8,
                                                          shadows: [
                                                            Shadow(
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                    0.6,
                                                                  ),
                                                              offset:
                                                                  const Offset(
                                                                    0,
                                                                    2,
                                                                  ),
                                                              blurRadius: 6,
                                                            ),
                                                          ],
                                                        ),
                                                        maxLines: 1,
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                      ),
                                                      if (isSelected)
                                                        TweenAnimationBuilder<
                                                          double
                                                        >(
                                                          tween: Tween(
                                                            begin: 0.0,
                                                            end: 1.0,
                                                          ),
                                                          duration:
                                                              const Duration(
                                                                milliseconds:
                                                                    300,
                                                              ),
                                                          builder: (
                                                            context,
                                                            value,
                                                            child,
                                                          ) {
                                                            return Transform.scale(
                                                              scale: value,
                                                              child: Opacity(
                                                                opacity: value,
                                                                child: child,
                                                              ),
                                                            );
                                                          },
                                                          child: Container(
                                                            margin:
                                                                const EdgeInsets.only(
                                                                  top: 6,
                                                                ),
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      10,
                                                                  vertical: 4,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              gradient: LinearGradient(
                                                                colors: [
                                                                  _getColorFromHex(
                                                                    category['color'] ??
                                                                        '#4E94AB',
                                                                  ),
                                                                  _getColorFromHex(
                                                                    category['color'] ??
                                                                        '#4E94AB',
                                                                  ).withOpacity(
                                                                    0.8,
                                                                  ),
                                                                ],
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    12,
                                                                  ),
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: _getColorFromHex(
                                                                    category['color'] ??
                                                                        '#4E94AB',
                                                                  ).withOpacity(
                                                                    0.5,
                                                                  ),
                                                                  blurRadius: 8,
                                                                  offset:
                                                                      const Offset(
                                                                        0,
                                                                        2,
                                                                      ),
                                                                ),
                                                              ],
                                                            ),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .radio_button_checked,
                                                                  size: 12,
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                ),
                                                                const SizedBox(
                                                                  width: 4,
                                                                ),
                                                                const Text(
                                                                  'Active',
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        11,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    color:
                                                                        Colors
                                                                            .white,
                                                                    letterSpacing:
                                                                        0.5,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                                if (isSelected)
                                                  TweenAnimationBuilder<double>(
                                                    tween: Tween(
                                                      begin: 0.0,
                                                      end: 1.0,
                                                    ),
                                                    duration: const Duration(
                                                      milliseconds: 400,
                                                    ),
                                                    curve: Curves.elasticOut,
                                                    builder: (
                                                      context,
                                                      value,
                                                      child,
                                                    ) {
                                                      return Transform.scale(
                                                        scale: value,
                                                        child: Transform.rotate(
                                                          angle: value * 0.2,
                                                          child: child,
                                                        ),
                                                      );
                                                    },
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            8,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        shape: BoxShape.circle,
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: _getColorFromHex(
                                                              category['color'] ??
                                                                  '#4E94AB',
                                                            ).withOpacity(0.5),
                                                            blurRadius: 12,
                                                            offset:
                                                                const Offset(
                                                                  0,
                                                                  4,
                                                                ),
                                                            spreadRadius: 2,
                                                          ),
                                                        ],
                                                      ),
                                                      child: Icon(
                                                        Icons.check_circle,
                                                        color: _getColorFromHex(
                                                          category['color'] ??
                                                              '#4E94AB',
                                                        ),
                                                        size: 20,
                                                      ),
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
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Modern Dietary Filters Section
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.primary,
                                        AppColors.primaryDark,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(
                                          0.4,
                                        ),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.filter_list_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                const Text(
                                  'Dietary Preferences',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A202C),
                                    letterSpacing: -0.8,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (mealProvider.selectedFilter != 'all')
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutBack,
                              builder: (context, value, child) {
                                final clampedValue = value.clamp(0.0, 1.0);
                                return Transform.scale(
                                  scale: clampedValue,
                                  child: Opacity(
                                    opacity: clampedValue,
                                    child: child,
                                  ),
                                );
                              },
                              child: GestureDetector(
                                onTap: () {
                                  mealProvider.setFilter('all');
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.secondary,
                                        AppColors.secondaryDark,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.secondary.withOpacity(
                                          0.4,
                                        ),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.close_rounded,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Clear',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        physics: const BouncingScrollPhysics(),
                        itemCount: 8,
                        itemBuilder: (context, index) {
                          final filters = [
                            {
                              'label': 'All Meals',
                              'filter': 'all',
                              'icon': Icons.restaurant_menu_rounded,
                              'color': AppColors.primary,
                            },
                            {
                              'label': 'Vegetarian',
                              'filter': 'vegetarian',
                              'icon': Icons.eco_rounded,
                              'color': const Color(0xFF4CAF50),
                            },
                            {
                              'label': 'Vegan',
                              'filter': 'vegan',
                              'icon': Icons.eco_rounded,
                              'color': const Color(0xFF66BB6A),
                            },
                            {
                              'label': 'Gluten-Free',
                              'filter': 'gluten-free',
                              'icon': Icons.grain_rounded,
                              'color': const Color(0xFFFFB74D),
                            },
                            {
                              'label': 'High Protein',
                              'filter': 'high-protein',
                              'icon': Icons.fitness_center_rounded,
                              'color': const Color(0xFFE91E63),
                            },
                            {
                              'label': 'Low Calorie',
                              'filter': 'low-calorie',
                              'icon': Icons.local_fire_department_rounded,
                              'color': const Color(0xFFFF5722),
                            },
                            {
                              'label': 'Dairy-Free',
                              'filter': 'dairy-free',
                              'icon': Icons.no_food_rounded,
                              'color': const Color(0xFF9C27B0),
                            },
                            {
                              'label': 'Keto',
                              'filter': 'keto',
                              'icon': Icons.whatshot_rounded,
                              'color': const Color(0xFFFF6F00),
                            },
                          ];

                          final filter = filters[index];
                          final isSelected =
                              mealProvider.selectedFilter == filter['filter'];

                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: Duration(
                              milliseconds: 150 + (index * 40),
                            ),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              final clampedValue = value.clamp(0.0, 1.0);
                              return Transform.scale(
                                scale: 0.9 + (clampedValue * 0.1),
                                child: Opacity(
                                  opacity: clampedValue,
                                  child: Transform.translate(
                                    offset: Offset(0, 8 * (1 - clampedValue)),
                                    child: child,
                                  ),
                                ),
                              );
                            },
                            child: GestureDetector(
                              onTap: () {
                                mealProvider.setFilter(
                                  filter['filter'] as String,
                                );
                                Future.delayed(
                                  const Duration(milliseconds: 150),
                                  () {
                                    _scrollToMealsSection();
                                  },
                                );
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOutCubic,
                                margin: EdgeInsets.only(
                                  right: index < 7 ? 14 : 0,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  gradient:
                                      isSelected
                                          ? LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              filter['color'] as Color,
                                              (filter['color'] as Color)
                                                  .withOpacity(0.85),
                                            ],
                                          )
                                          : null,
                                  color: isSelected ? null : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color:
                                        isSelected
                                            ? Colors.transparent
                                            : Colors.grey[300]!,
                                    width: isSelected ? 0 : 1.5,
                                  ),
                                  boxShadow:
                                      isSelected
                                          ? [
                                            BoxShadow(
                                              color: (filter['color'] as Color)
                                                  .withOpacity(0.35),
                                              blurRadius: 16,
                                              offset: const Offset(0, 6),
                                              spreadRadius: 0,
                                            ),
                                          ]
                                          : [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.06,
                                              ),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color:
                                            isSelected
                                                ? Colors.white.withOpacity(0.25)
                                                : (filter['color'] as Color)
                                                    .withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        filter['icon'] as IconData,
                                        color:
                                            isSelected
                                                ? Colors.white
                                                : filter['color'] as Color,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Text(
                                      filter['label'] as String,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color:
                                            isSelected
                                                ? Colors.white
                                                : Colors.grey[800],
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Trending Now Section (only show when no category is selected)
            if (_selectedCategory == null && featuredMeals.isNotEmpty)
              _buildMealSection(
                title: "Trending Now",
                icon: Icons.local_fire_department,
                meals: featuredMeals.take(6).toList(),
                navigationProvider: navigationProvider,
              ),

            // Friday Offer Banner - Third Pic Style
            if (_selectedCategory == null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 22,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Today Offer',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFC62828),
                              const Color(0xFFC62828),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFC62828).withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Left side - Text content
                            Positioned(
                              left: 0,
                              top: 0,
                              bottom: 0,
                              right: 160,
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Get',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      '50% Off',
                                      style: TextStyle(
                                        fontSize: 38,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'On All Meals',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white.withOpacity(0.95),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Right side - Food images (burger and coke icons)
                            Positioned(
                              right: 5,
                              top: -80,
                              bottom: 10,
                              child: Row(
                                children: [
                                  // Burger icon
                                  Container(
                                    width: 220,
                                    height: 200,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withOpacity(0.15),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                        width: 2,
                                      ),
                                    ),
                                    child: Image.asset(
                                      "images/food6.png",
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Popular Meals Section (only show when no category is selected)
            if (_selectedCategory == null && popularMeals.isNotEmpty)
              _buildMealSection(
                title: 'Popular Meals',
                icon: Icons.star,
                meals: popularMeals.take(6).toList(),
                navigationProvider: navigationProvider,
              ),

            // New Arrivals Section (only show when no category is selected)
            if (_selectedCategory == null && recentMeals.isNotEmpty)
              _buildMealSection(
                title: 'New Arrivals',
                icon: Icons.fiber_new,
                meals: recentMeals.take(6).toList(),
                navigationProvider: navigationProvider,
              ),

            // Category Filtered Meals Section (when category is selected)
            if (_selectedCategory != null)
              filteredMeals.isEmpty
                  ? SliverToBoxAdapter(
                    key: _mealsSectionKey,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 80,
                        horizontal: 24,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary.withOpacity(0.15),
                                  AppColors.primary.withOpacity(0.08),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.restaurant_menu_rounded,
                              size: 72,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'No meals found',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'We couldn\'t find any meals in this category.\nTry selecting another category!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[600],
                              height: 1.6,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  : _buildMealSection(
                    key: _mealsSectionKey,
                    title:
                        '${_categories.firstWhere((c) => c['id'] == _selectedCategory)['name']} Meals',
                    icon: Icons.restaurant_menu,
                    meals: filteredMeals,
                    navigationProvider: navigationProvider,
                    isFiltered: mealProvider.selectedFilter != 'all',
                  ),

            // All Meals Section (only show when no category is selected)
            if (_selectedCategory == null && filteredMeals.isNotEmpty)
              _buildMealSection(
                key: _mealsSectionKey,
                title:
                    mealProvider.selectedFilter != 'all'
                        ? _getFilterTitle(mealProvider.selectedFilter)
                        : 'All Meals',
                icon: Icons.restaurant_menu,
                meals: filteredMeals.take(8).toList(),
                navigationProvider: navigationProvider,
                isFiltered: mealProvider.selectedFilter != 'all',
              ),

            // Bottom padding
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildMealSection({
    Key? key,
    required String title,
    required IconData icon,
    required List meals,
    required NavigationProvider navigationProvider,
    bool isFiltered = false,
  }) {
    if (meals.isEmpty)
      return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      key: key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration:
                isFiltered
                    ? BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.06),
                          Colors.transparent,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.topRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    )
                    : null,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient:
                              isFiltered
                                  ? LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      AppColors.primaryDark,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                  : null,
                          color:
                              isFiltered
                                  ? null
                                  : AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow:
                              isFiltered
                                  ? [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ]
                                  : null,
                        ),
                        child: Icon(
                          icon,
                          color: isFiltered ? Colors.white : AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color:
                              isFiltered
                                  ? AppColors.primary
                                  : const Color(0xFF1A202C),
                          letterSpacing: -0.8,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.15),
                          AppColors.primary.withOpacity(0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${meals.length}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 460,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              physics: const BouncingScrollPhysics(),
              itemCount: meals.length,
              itemBuilder: (context, index) {
                final meal = meals[index];
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 200 + (index * 50)),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    final clampedValue = value.clamp(0.0, 1.0);
                    return Transform.scale(
                      scale: 0.95 + (clampedValue * 0.05),
                      child: Opacity(
                        opacity: clampedValue,
                        child: Transform.translate(
                          offset: Offset(0, 10 * (1 - clampedValue)),
                          child: child,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 270,
                    margin: EdgeInsets.only(
                      right: index < meals.length - 1 ? 18 : 0,
                    ),
                    child: MealCard(
                      meal: meal,
                      onTap:
                          () => navigationProvider.navigateTo(
                            AppPage.mealDetail,
                            data: {'mealId': meal.id},
                          ),
                      compact: true,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 36),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_state.dart';
import '../../models/meal.dart';
import '../../models/user.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_badge.dart';
import '../../widgets/image_with_fallback.dart';
import '../../providers/navigation_provider.dart';

class ChefDashboardScreen extends StatefulWidget {
  @override
  _ChefDashboardScreenState createState() => _ChefDashboardScreenState();
}

class _ChefDashboardScreenState extends State<ChefDashboardScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.user;
    final userMeals =
        appState.userMeals.where((meal) => meal.chefId == user?.id).toList();

    if (user == null || !user.isChef) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.restaurant, size: 64, color: Colors.orange),
              SizedBox(height: 16),
              Text(
                'Chef Access Required',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'You need to be registered as a chef to access the dashboard.',
              ),
              SizedBox(height: 24),
              CustomButton(
                text: 'Become a Chef',
                onPressed:
                    () => context.read<NavigationProvider>().navigateTo(
                      AppPage.profile,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    final double totalRevenue = userMeals.fold(
      0.0,
      (sum, meal) => sum + (meal.price * meal.orderCount),
    );
    final int totalOrders = userMeals.fold(
      0,
      (sum, meal) => sum + meal.orderCount,
    );
    final double averageRating =
        userMeals.isNotEmpty
            ? userMeals.fold(0.0, (sum, meal) => sum + meal.rating) /
                userMeals.length
            : 0;
    final int activeMeals = userMeals.where((meal) => meal.isActive).length;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Chef Dashboard'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'My Meals'),
              Tab(text: 'Analytics'),
              Tab(text: 'Chef Profile'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildMealsTab(userMeals, appState, activeMeals),
            _buildAnalyticsTab(
              userMeals,
              totalRevenue,
              totalOrders,
              averageRating,
              activeMeals,
            ),
            _buildProfileTab(user, userMeals, totalOrders, averageRating),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed:
              () => context.read<NavigationProvider>().navigateTo(
                AppPage.sellMeal,
              ),
          child: Icon(Icons.add),
          backgroundColor: Colors.orange,
        ),
      ),
    );
  }

  Widget _buildMealsTab(
    List<Meal> userMeals,
    AppState appState,
    int activeMeals,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          if (userMeals.isEmpty)
            Card(
              child: Padding(
                padding: EdgeInsets.all(48),
                child: Column(
                  children: [
                    Icon(Icons.restaurant_menu, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No meals yet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Start sharing your culinary creations with food lovers!',
                    ),
                    SizedBox(height: 24),
                    CustomButton(
                      text: 'Add Your First Meal',
                      onPressed:
                          () => context.read<NavigationProvider>().navigateTo(
                            AppPage.sellMeal,
                          ),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Your Meals (${userMeals.length})',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        CustomBadge(text: '$activeMeals Active'),
                        SizedBox(width: 8),
                        CustomBadge(
                          text: '${userMeals.length - activeMeals} Inactive',
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16),
                ...userMeals.map(
                  (meal) => _MealCard(meal: meal, appState: appState),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab(
    List<Meal> userMeals,
    double totalRevenue,
    int totalOrders,
    double averageRating,
    int activeMeals,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Stats overview
          GridView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
            ),
            children: [
              _StatCard(
                icon: Icons.attach_money,
                label: 'Total Revenue',
                value: '\$${totalRevenue.toStringAsFixed(2)}',
                color: Colors.green,
              ),
              _StatCard(
                icon: Icons.shopping_bag,
                label: 'Total Orders',
                value: totalOrders.toString(),
                color: Colors.blue,
              ),
              _StatCard(
                icon: Icons.star,
                label: 'Average Rating',
                value: averageRating.toStringAsFixed(1),
                color: Colors.amber,
              ),
              _StatCard(
                icon: Icons.restaurant,
                label: 'Active Meals',
                value: activeMeals.toString(),
                color: Colors.purple,
              ),
            ],
          ),
          SizedBox(height: 24),
          if (userMeals.isNotEmpty) ...[
            Text(
              'Performance Analytics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileTab(
    User user,
    List<Meal> userMeals,
    int totalOrders,
    double averageRating,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.orange[100],
                        child: Icon(
                          Icons.restaurant,
                          size: 32,
                          color: Colors.orange,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              user.email,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      CustomButton(
                        text: 'Add Meal',
                        onPressed:
                            () => context.read<NavigationProvider>().navigateTo(
                              AppPage.sellMeal,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  final Meal meal;
  final AppState appState;

  const _MealCard({required this.meal, required this.appState});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: ImageWithFallback(
                imageUrl: meal.image,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Orders: ${meal.orderCount} • Rating: ${meal.rating.toStringAsFixed(1)}',
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.visibility),
              onPressed:
                  () => context.read<NavigationProvider>().navigateTo(
                    AppPage.mealDetail,
                    data: {'mealId': meal.id},
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.black54, fontSize: 12),
              ),
              Text(
                value,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

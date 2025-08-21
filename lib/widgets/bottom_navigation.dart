import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';

class BottomNavigation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);

    final currentPage = navigationProvider.currentPage;
    final user = authProvider.user;

    final customerNavItems = [
      NavItem(page: AppPage.home, icon: Icons.home, label: 'Home'),
      NavItem(
        page: AppPage.cart,
        icon: Icons.shopping_cart,
        label: 'Cart',
        badgeCount: cartProvider.itemCount,
      ),
      NavItem(page: AppPage.profile, icon: Icons.person, label: 'Profile'),
      NavItem(
        page: AppPage.delivery,
        icon: Icons.local_shipping,
        label: 'Delivery',
      ),
      NavItem(page: AppPage.payment, icon: Icons.credit_card, label: 'Payment'),
      NavItem(page: AppPage.welcome, icon: Icons.logout, label: 'Logout'),
    ];

    final navItems = user?.isChef ?? false ? _chefNavItems : customerNavItems;

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children:
                navItems.map((item) {
                  final isActive = currentPage == item.page;

                  return GestureDetector(
                    onTap: () {
                      if (item.page == AppPage.welcome) {
                        authProvider.logout();
                        navigationProvider.navigateTo(AppPage.welcome);
                      } else {
                        navigationProvider.navigateTo(item.page);
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isActive ? Colors.black : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            children: [
                              Icon(
                                item.icon,
                                size: 20,
                                color:
                                    isActive ? Colors.white : Colors.grey[400],
                              ),
                              if (item.badgeCount != null &&
                                  item.badgeCount! > 0)
                                Positioned(
                                  right: -4,
                                  top: -4,
                                  child: Container(
                                    padding: EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.orange,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    constraints: BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    child: Text(
                                      item.badgeCount!.toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 10,
                              color: isActive ? Colors.white : Colors.grey[400],
                              fontWeight:
                                  isActive ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }

  final List<NavItem> _chefNavItems = [
    NavItem(page: AppPage.home, icon: Icons.home, label: 'Home'),
    NavItem(
      page: AppPage.chefDashboard,
      icon: Icons.restaurant,
      label: 'Dashboard',
    ),
    NavItem(page: AppPage.sellMeal, icon: Icons.add, label: 'Add Meal'),
    NavItem(page: AppPage.cart, icon: Icons.shopping_cart, label: 'Cart'),
    NavItem(page: AppPage.profile, icon: Icons.person, label: 'Profile'),
    NavItem(page: AppPage.welcome, icon: Icons.logout, label: 'Logout'),
  ];
}

class NavItem {
  final AppPage page;
  final IconData icon;
  final String label;
  final int? badgeCount;

  NavItem({
    required this.page,
    required this.icon,
    required this.label,
    this.badgeCount,
  });
}

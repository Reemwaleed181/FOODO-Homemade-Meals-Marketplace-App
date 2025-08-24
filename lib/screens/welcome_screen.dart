import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFEFEFE), // Light cream at top
              Color(0xFFFDF2F2), // Soft peachy-pink at bottom
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              // Header/Navigation Bar
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo
                      Text(
                        'HomeCook',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      // Action Buttons
                      Row(
                        children: [
                          // Login Button
                          GestureDetector(
                            onTap: () => context
                                .read<NavigationProvider>()
                                .navigateTo(AppPage.login),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Text(
                                'Login',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          // Sign Up Button
                          GestureDetector(
                            onTap: () => context
                                .read<NavigationProvider>()
                                .navigateTo(AppPage.signup),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black87,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Text(
                                'Sign Up',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Hero Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Headline
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D2D2D), // Dark charcoal
                            height: 1.2,
                          ),
                          children: [
                            TextSpan(text: 'Delicious Homemade\n'),
                            TextSpan(text: 'Meals '),
                            TextSpan(
                              text: 'Made with Love',
                              style: TextStyle(
                                color: Color(0xFFFF6B35),
                              ), // Vibrant orange
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),

                      // Description
                      Text(
                        'Discover authentic, nutritious meals prepared by talented home chefs in your community. Every dish tells a story, every bite brings comfort.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 40),

                      // Call-to-Action Button
                      GestureDetector(
                        onTap: () => context
                            .read<NavigationProvider>()
                            .navigateTo(AppPage.signup),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Start Ordering Now',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Features Section
                Container(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Section Title
                      Text(
                        'Why Choose HomeCook!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 32),

                      // Feature Cards
                      Row(
                        children: [
                          Expanded(
                            child: _FeatureCard(
                              icon: Icons.restaurant,
                              title: 'Local Home Chefs',
                              description:
                              'Support talented women in your community who pour their heart into every meal they create.',
                              iconColor: Color(0xFFFF6B35),
                              backgroundColor: Color(0xFFFFF3E0),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _FeatureCard(
                              icon: Icons.restaurant_menu,
                              title: 'Fresh & Nutritious',
                              description:
                              'Complete nutritional information with calories, macros, and portion sizes for healthy living.',
                              iconColor: Colors.green[600]!,
                              backgroundColor: Colors.green[50]!,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _FeatureCard(
                              icon: Icons.local_shipping,
                              title: 'Fast Delivery',
                              description:
                              'Quick and reliable delivery service bringing restaurant-quality meals to your doorstep.',
                              iconColor: Colors.blue[600]!,
                              backgroundColor: Colors.blue[50]!,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Call-to-Action Section
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Color(0xFFFF6B35), // Bright orange
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Ready to Taste the Difference?',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Join thousands of satisfied customers who\'ve discovered the joy of authentic homemade meals.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 24),
                      GestureDetector(
                        onTap: () => context
                            .read<NavigationProvider>()
                            .navigateTo(AppPage.signup),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Get Started Today',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color iconColor;
  final Color backgroundColor;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.iconColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 30),
          ),
          SizedBox(height: 16),
          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          // Description
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

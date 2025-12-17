import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';

class ModernDrawer extends StatelessWidget {
  const ModernDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final navigationProvider = Provider.of<NavigationProvider>(context);
    final user = authProvider.user;

    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.primary, // Solid app color background
        ),
        child: Stack(
          children: [
            // Decorative wave patterns at bottom right (subtle lighter app color)
            Positioned(
              right: -40,
              bottom: 0,
              child: CustomPaint(
                size: const Size(180, 250),
                painter: WavePatternPainter(),
              ),
            ),
            // Decorative french fries illustration at bottom (behind log out button)
            Positioned(
              right: -15,
              bottom: 90,
              child: Opacity(
                opacity: 0.18,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                  child: Icon(
                    Icons.fastfood_rounded,
                    size: 150,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Close button (X) in top right
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // User Profile Section (Vertical Layout)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        // Profile Picture
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFFFB8A3), // Light pink
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                                spreadRadius: 2,
                              ),
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child:
                                user?.profilePicture != null &&
                                        user!.profilePicture!.isNotEmpty
                                    ? Image.asset(
                                      user.profilePicture!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Container(
                                          color: const Color(0xFFFFB8A3),
                                          child: const Icon(
                                            Icons.person,
                                            color: Colors.white,
                                            size: 40,
                                          ),
                                        );
                                      },
                                    )
                                    : Container(
                                      color: const Color(0xFFFFB8A3),
                                      child: const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                    ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // User Name
                        Text(
                          user?.name ?? 'Guest User',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        // User Email
                        Text(
                          user?.email ?? 'guest@example.com',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.95),
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),
                  // Menu Items
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        _buildMenuItem(
                          context,
                          icon: Icons.receipt_long_rounded,
                          title: 'My Orders',
                          onTap: () {
                            Navigator.pop(context);
                            // TODO: Navigate to orders page
                          },
                        ),
                        const SizedBox(height: 2),
                        _buildMenuItem(
                          context,
                          icon: Icons.person_rounded,
                          title: 'My Profile',
                          onTap: () {
                            Navigator.pop(context);
                            navigationProvider.navigateTo(AppPage.profile);
                          },
                        ),
                        const SizedBox(height: 2),
                        _buildMenuItem(
                          context,
                          icon: Icons.location_on_rounded,
                          title: 'Delivery Address',
                          onTap: () {
                            Navigator.pop(context);
                            navigationProvider.navigateTo(AppPage.delivery);
                          },
                        ),
                        const SizedBox(height: 2),
                        _buildMenuItem(
                          context,
                          icon: Icons.payment_rounded,
                          title: 'Payment Methods',
                          onTap: () {
                            Navigator.pop(context);
                            navigationProvider.navigateTo(AppPage.payment);
                          },
                        ),
                        const SizedBox(height: 2),
                        _buildMenuItem(
                          context,
                          icon: Icons.email_rounded,
                          title: 'Contact Us',
                          onTap: () {
                            Navigator.pop(context);
                            // TODO: Navigate to contact page
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Contact us feature coming soon!',
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 2),
                        _buildMenuItem(
                          context,
                          icon: Icons.settings_rounded,
                          title: 'Settings',
                          onTap: () {
                            Navigator.pop(context);
                            // TODO: Navigate to settings page
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Settings feature coming soon!'),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 2),
                        _buildMenuItem(
                          context,
                          icon: Icons.help_outline_rounded,
                          title: 'Helps & FAQs',
                          onTap: () {
                            Navigator.pop(context);
                            // TODO: Navigate to help page
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Help & FAQs coming soon!'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  // Log Out Button
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                            spreadRadius: 1,
                          ),
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            authProvider.logout();
                            navigationProvider.navigateTo(
                              AppPage.authSelection,
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          splashColor: AppColors.primary.withOpacity(0.1),
                          highlightColor: AppColors.primary.withOpacity(0.05),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 18,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.power_settings_new_rounded,
                                    color: AppColors.primary,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Log Out',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: Colors.white.withOpacity(0.1),
        highlightColor: Colors.white.withOpacity(0.05),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom painter for organic wavy edge (left side of drawer - inner edge)
class WavyEdgePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

    final path = Path();

    // Start from top right
    path.moveTo(size.width, 0);

    // Create smooth, organic curves along the left edge
    // The curve bulges inward (toward the right) creating the wavy effect
    final curvePoints = [
      Offset(size.width - 15, size.height * 0.05),
      Offset(size.width - 35, size.height * 0.15),
      Offset(size.width - 20, size.height * 0.25),
      Offset(size.width - 40, size.height * 0.35),
      Offset(size.width - 25, size.height * 0.45),
      Offset(size.width - 45, size.height * 0.55),
      Offset(size.width - 30, size.height * 0.65),
      Offset(size.width - 40, size.height * 0.75),
      Offset(size.width - 25, size.height * 0.85),
      Offset(size.width - 35, size.height * 0.95),
      Offset(size.width - 20, size.height),
    ];

    // Draw smooth curves between points
    for (int i = 0; i < curvePoints.length - 1; i++) {
      final current = curvePoints[i];
      final next = curvePoints[i + 1];

      // Control point for smooth bezier curve
      final controlX = (current.dx + next.dx) / 2;
      final controlY = (current.dy + next.dy) / 2;

      if (i == 0) {
        path.lineTo(current.dx, current.dy);
      }

      path.quadraticBezierTo(controlX, controlY, next.dx, next.dy);
    }

    // Complete the path
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for wave patterns at bottom right (lighter app color waves)
class WavePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = AppColors.primaryLight.withOpacity(0.3) // Lighter app color
          ..style = PaintingStyle.fill;

    final path = Path();

    // Create subtle wave-like patterns
    path.moveTo(0, size.height);

    // Create organic wave curves
    path.quadraticBezierTo(
      size.width * 0.2,
      size.height * 0.6,
      size.width * 0.4,
      size.height * 0.7,
    );
    path.quadraticBezierTo(
      size.width * 0.6,
      size.height * 0.8,
      size.width * 0.8,
      size.height * 0.75,
    );
    path.quadraticBezierTo(
      size.width * 0.95,
      size.height * 0.7,
      size.width,
      size.height * 0.8,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // Add another smaller wave layer for depth
    final paint2 =
        Paint()
          ..color = AppColors.primaryLight.withOpacity(0.2)
          ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(size.width * 0.3, size.height);
    path2.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.5,
      size.width * 0.7,
      size.height * 0.6,
    );
    path2.quadraticBezierTo(
      size.width * 0.9,
      size.height * 0.65,
      size.width,
      size.height * 0.7,
    );
    path2.lineTo(size.width, size.height);
    path2.lineTo(size.width * 0.3, size.height);
    path2.close();

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

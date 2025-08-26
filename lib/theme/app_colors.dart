import 'package:flutter/material.dart';

/// Centralized color palette for the Foodo app
/// This ensures consistent colors across all pages and components
/// Colors are based on the Foodo logo's teal/blue theme
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Responsive Design Constants
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;

  // Responsive Sizing
  static double getResponsiveSize(BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    final width = MediaQuery.of(context).size.width;
    if (width >= desktopBreakpoint) {
      return desktop ?? tablet ?? mobile;
    } else if (width >= tabletBreakpoint) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }

  static EdgeInsets getResponsivePadding(BuildContext context, {
    required EdgeInsets mobile,
    EdgeInsets? tablet,
    EdgeInsets? desktop,
  }) {
    final width = MediaQuery.of(context).size.width;
    if (width >= desktopBreakpoint) {
      return desktop ?? tablet ?? mobile;
    } else if (width >= tabletBreakpoint) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }

  static double getResponsiveSpacing(BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    final width = MediaQuery.of(context).size.width;
    if (width >= desktopBreakpoint) {
      return desktop ?? tablet ?? mobile;
    } else if (width >= tabletBreakpoint) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }

  // Primary Colors - Main brand colors (based on Foodo logo)
  static const Color primary = Color(0xFF4E94AB); // Logo color - Main brand color
  static const Color primaryLight = Color(0xFF6BA8BC); // Lighter version of logo color
  static const Color primaryDark = Color(0xFF3A7A8F); // Darker version of logo color for emphasis

  // Secondary Colors - Accent and highlight colors
  static const Color secondary = Color(0xFF87CEEB); // Light blue - Secondary accent
  static const Color secondaryLight = Color(0xFFB0E0E6); // Lighter light blue
  static const Color secondaryDark = Color(0xFF4682B4); // Darker light blue

  // Food Theme Colors - Culinary-inspired colors
  static const Color foodGreen = Color(0xFF4CAF50); // Fresh green for healthy options
  static const Color foodOrange = Color(0xFFFF9800); // Warm orange for comfort food
  static const Color foodRed = Color(0xFFF44336); // Spicy red for bold flavors
  static const Color foodPurple = Color(0xFF9C27B0); // Rich purple for premium items
  static const Color foodPink = Color(0xFFE91E63); // Sweet pink for desserts

  // Background Colors - Page and card backgrounds
  static const Color backgroundPrimary = Color(0xFFF0F8FF); // Main page background - Light blue tint
  static const Color backgroundSecondary = Color(0xFFF5F5F5); // Secondary background - Light grey
  static const Color backgroundTertiary = Color(0xFFE6F3FF); // Tertiary background - Very light blue
  static const Color surface = Color(0xFFFFFFFF); // Card and surface color - Pure white

  // Text Colors - Typography hierarchy
  static const Color textPrimary = Color(0xFF2C3E50); // Main text color - Dark blue-grey
  static const Color textSecondary = Color(0xFF5D6D7E); // Secondary text - Medium blue-grey
  static const Color textTertiary = Color(0xFF85929E); // Tertiary text - Light blue-grey
  static const Color textInverse = Color(0xFFFFFFFF); // Text on dark backgrounds - White

  // Status Colors - Success, warning, error states
  static const Color success = Color(0xFF4CAF50); // Green for success
  static const Color warning = Color(0xFFFF9800); // Orange for warnings
  static const Color error = Color(0xFFF44336); // Red for errors
  static const Color info = Color(0xFF4E94AB); // Logo color for information (matches primary)

  // Border and Divider Colors
  static const Color borderPrimary = Color(0xFFE8F4FD); // Main border color - Light blue
  static const Color borderSecondary = Color(0xFFD1E7DD); // Secondary border - Light teal
  static const Color borderAccent = Color(0xFF4E94AB); // Accent border - Logo color

  // Shadow Colors
  static const Color shadowLight = Color(0x1A000000); // Light shadow (10% opacity)
  static const Color shadowMedium = Color(0x14000000); // Medium shadow (8% opacity)
  static const Color shadowHeavy = Color(0x0D000000); // Heavy shadow (5% opacity)

  // Gradient Colors - For backgrounds and buttons
  static const List<Color> primaryGradient = [
    Color(0xFFF0F8FF), // Light blue tint
    Color(0xFFE6F3FF), // Very light blue
    Color(0xFFD1E7DD), // Light teal
  ];

  static const List<Color> secondaryGradient = [
    Color(0xFF4E94AB), // Logo color
    Color(0xFF6BA8BC), // Light logo color
  ];

  static const List<Color> primaryButtonGradient = [
    Color(0xFF4E94AB), // Logo color
    Color(0xFF3A7A8F), // Dark logo color
  ];

  // Food Category Colors - For different meal types
  static const Map<String, Color> foodCategories = {
    'vegetarian': Color(0xFF4CAF50), // Green
    'vegan': Color(0xFF66BB6A), // Light green
    'glutenFree': Color(0xFF4E94AB), // Logo color (matches primary)
    'healthy': Color(0xFF81C784), // Mint green
    'protein': Color(0xFF6BA8BC), // Light logo color
    'dessert': Color(0xFFE91E63), // Pink
    'spicy': Color(0xFFF44336), // Red
    'premium': Color(0xFF9C27B0), // Purple
  };

  // Rating Colors - For star ratings and reviews
  static const Color ratingStar = Color(0xFFFFD700); // Gold for stars
  static const Color ratingStarEmpty = Color(0xFFE0E0E0); // Light grey for empty stars

  // Price Colors - For cost displays
  static const Color priceRegular = Color(0xFF2C3E50); // Dark blue-grey for regular prices
  static const Color priceDiscount = Color(0xFF4CAF50); // Green for discounted prices
  static const Color pricePremium = Color(0xFF4E94AB); // Logo color for premium prices

  // Navigation Colors - For bottom navigation and tabs
  static const Color navSelected = Color(0xFF4E94AB); // Logo color for selected items
  static const Color navUnselected = Color(0xFF85929E); // Grey for unselected items
  static const Color navBackground = Color(0xFFFFFFFF); // White for nav background

  // Card Colors - For different card types
  static const Color cardPrimary = Color(0xFFFFFFFF); // White for main cards
  static const Color cardSecondary = Color(0xFFF8FAFC); // Light grey for secondary cards
  static const Color cardAccent = Color(0xFFF0F8FF); // Light blue for accent cards

  // Button Colors - For different button types
  static const Color buttonPrimary = Color(0xFF4E94AB); // Logo color for primary buttons
  static const Color buttonSecondary = Color(0xFF87CEEB); // Light blue for secondary buttons
  static const Color buttonOutline = Color(0xFFE8F4FD); // Light blue for outline buttons

  // Input Field Colors - For form inputs
  static const Color inputBackground = Color(0xFFF8FAFC); // Light grey for input backgrounds
  static const Color inputBorder = Color(0xFFE8F4FD); // Light blue for input borders
  static const Color inputFocus = Color(0xFF4E94AB); // Logo color for focused inputs
  static const Color inputError = Color(0xFFF44336); // Red for error states

  // Helper Methods for Color Variations
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  static Color darken(Color color, double amount) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  static Color lighten(Color color, double amount) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }
}

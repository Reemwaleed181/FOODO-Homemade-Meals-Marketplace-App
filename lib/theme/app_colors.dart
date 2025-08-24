import 'package:flutter/material.dart';

/// Centralized color palette for the HomeCook app
/// This ensures consistent colors across all pages and components
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Primary Colors - Main brand colors
  static const Color primary = Color(
    0xFF1E293B,
  ); // Dark blue - Main brand color
  static const Color primaryLight = Color(0xFF334155); // Lighter dark blue
  static const Color primaryDark = Color(
    0xFF0F172A,
  ); // Darker blue for emphasis

  // Secondary Colors - Accent and highlight colors
  static const Color secondary = Color(0xFFFF6B35); // Orange - Primary accent
  static const Color secondaryLight = Color(0xFFFF8A65); // Lighter orange
  static const Color secondaryDark = Color(0xFFE65100); // Darker orange

  // Food Theme Colors - Culinary-inspired colors
  static const Color foodGreen = Color(
    0xFF4CAF50,
  ); // Fresh green for healthy options
  static const Color foodOrange = Color(
    0xFFFF9800,
  ); // Warm orange for comfort food
  static const Color foodRed = Color(0xFFF44336); // Spicy red for bold flavors
  static const Color foodPurple = Color(
    0xFF9C27B0,
  ); // Rich purple for premium items
  static const Color foodPink = Color(0xFFE91E63); // Sweet pink for desserts

  // Background Colors - Page and card backgrounds
  static const Color backgroundPrimary = Color(
    0xFFFFF8F2,
  ); // Main page background - Warm cream
  static const Color backgroundSecondary = Color(
    0xFFFFF0F0,
  ); // Secondary background - Light pink
  static const Color backgroundTertiary = Color(
    0xFFFFE8E8,
  ); // Tertiary background - Light coral
  static const Color surface = Color(
    0xFFFFFFFF,
  ); // Card and surface color - Pure white

  // Text Colors - Typography hierarchy
  static const Color textPrimary = Color(
    0xFF1E293B,
  ); // Main text color - Dark blue
  static const Color textSecondary = Color(
    0xFF64748B,
  ); // Secondary text - Medium grey
  static const Color textTertiary = Color(
    0xFF94A3B8,
  ); // Tertiary text - Light grey
  static const Color textInverse = Color(
    0xFFFFFFFF,
  ); // Text on dark backgrounds - White

  // Status Colors - Success, warning, error states
  static const Color success = Color(0xFF4CAF50); // Green for success
  static const Color warning = Color(0xFFFF9800); // Orange for warnings
  static const Color error = Color(0xFFF44336); // Red for errors
  static const Color info = Color(0xFF2196F3); // Blue for information

  // Border and Divider Colors
  static const Color borderPrimary = Color(0xFFE2E8F0); // Main border color
  static const Color borderSecondary = Color(0xFFCBD5E1); // Secondary border
  static const Color borderAccent = Color(0xFFFF6B35); // Accent border - Orange

  // Shadow Colors
  static const Color shadowLight = Color(
    0x1A000000,
  ); // Light shadow (10% opacity)
  static const Color shadowMedium = Color(
    0x14000000,
  ); // Medium shadow (8% opacity)
  static const Color shadowHeavy = Color(
    0x0D000000,
  ); // Heavy shadow (5% opacity)

  // Gradient Colors - For backgrounds and buttons
  static const List<Color> primaryGradient = [
    Color(0xFFFFF8F2), // Warm cream
    Color(0xFFFFF0F0), // Light pink
    Color(0xFFFFE8E8), // Light coral
  ];

  static const List<Color> secondaryGradient = [
    Color(0xFFFF6B35), // Orange
    Color(0xFFFF8A65), // Light orange
  ];

  static const List<Color> primaryButtonGradient = [
    Color(0xFF1E293B), // Dark blue
    Color(0xFF334155), // Lighter blue
  ];

  // Food Category Colors - For different meal types
  static const Map<String, Color> foodCategories = {
    'vegetarian': Color(0xFF4CAF50), // Green
    'vegan': Color(0xFF66BB6A), // Light green
    'glutenFree': Color(0xFF42A5F5), // Blue
    'healthy': Color(0xFF81C784), // Mint green
    'protein': Color(0xFFFF7043), // Deep orange
    'dessert': Color(0xFFE91E63), // Pink
    'spicy': Color(0xFFF44336), // Red
    'premium': Color(0xFF9C27B0), // Purple
  };

  // Rating Colors - For star ratings and reviews
  static const Color ratingStar = Color(0xFFFFD700); // Gold for stars
  static const Color ratingStarEmpty = Color(
    0xFFE0E0E0,
  ); // Light grey for empty stars

  // Price Colors - For cost displays
  static const Color priceRegular = Color(
    0xFF1E293B,
  ); // Dark blue for regular prices
  static const Color priceDiscount = Color(
    0xFF4CAF50,
  ); // Green for discounted prices
  static const Color pricePremium = Color(
    0xFF9C27B0,
  ); // Purple for premium prices

  // Navigation Colors - For bottom navigation and tabs
  static const Color navSelected = Color(
    0xFFFF6B35,
  ); // Orange for selected items
  static const Color navUnselected = Color(
    0xFF94A3B8,
  ); // Grey for unselected items
  static const Color navBackground = Color(
    0xFFFFFFFF,
  ); // White for nav background

  // Card Colors - For different card types
  static const Color cardPrimary = Color(0xFFFFFFFF); // White for main cards
  static const Color cardSecondary = Color(
    0xFFF8FAFC,
  ); // Light grey for secondary cards
  static const Color cardAccent = Color(0xFFFFF8F2); // Cream for accent cards

  // Button Colors - For different button types
  static const Color buttonPrimary = Color(
    0xFF1E293B,
  ); // Dark blue for primary buttons
  static const Color buttonSecondary = Color(
    0xFFFF6B35,
  ); // Orange for secondary buttons
  static const Color buttonOutline = Color(
    0xFFE2E8F0,
  ); // Light grey for outline buttons

  // Input Field Colors - For form inputs
  static const Color inputBackground = Color(
    0xFFF8FAFC,
  ); // Light grey for input backgrounds
  static const Color inputBorder = Color(0xFFE2E8F0); // Grey for input borders
  static const Color inputFocus = Color(
    0xFFFF6B35,
  ); // Orange for focused inputs
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

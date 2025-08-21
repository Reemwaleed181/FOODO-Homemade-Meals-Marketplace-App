# HomePlate - Homemade Meal Marketplace

## Overview

HomePlate is a comprehensive Flutter mobile application that connects food lovers with local home chefs in their community. Built as a two-sided marketplace, users can seamlessly switch between buying delicious homemade meals as customers and selling their own culinary creations as chefs—all from a mobile-friendly interface.

## 🍽️ Key Features

### For Customers

* **Meal Discovery**: Browse featured meals and local chef offerings with detailed nutritional information
* **Smart Search**: Filter meals by dietary preferences (vegetarian, vegan, gluten-free)
* **Detailed Meal Pages**: View complete meal descriptions, ingredients, allergens, and chef information
* **Shopping Cart**: Add multiple meals, adjust quantities, and manage orders
* **Secure Checkout**: Complete purchase process with delivery and payment management
* **Profile Management**: Update delivery addresses and personal information

### For Chefs

* **Chef Mode Toggle**: Instantly switch between customer and chef experiences
* **Meal Creation**: Add new meals with complete nutritional data, pricing, and availability
* **Chef Dashboard**: Manage active listings, view sales analytics, and track orders
* **Profile Customization**: Build chef profiles with bios, ratings, and specialties

### Core Functionality

* **User Authentication**: Secure login and registration system
* **Role-Based Navigation**: Dynamic interface based on user role (customer/chef/both)
* **Real-Time Cart Management**: Live updates of cart items and totals
* **Responsive Mobile UI**: Flutter widgets optimized for both Android and iOS
* **State Management**: Using Provider for app-wide state updates

## 🛠️ Technical Architecture

### Frontend Framework

* **Flutter 3+** with Dart for cross-platform mobile development
* **Widget-based architecture** with reusable custom components
* **State management** using Provider or Riverpod
* **Material & Cupertino widgets** for a native look on both platforms

### Data Models

* **User Management**: Comprehensive user profiles with role switching
* **Meal System**: Detailed meal objects with nutrition, pricing, and metadata
* **Cart Functionality**: Real-time shopping cart with quantity management
* **Chef Integration**: Two-sided marketplace with chef-specific features

### UI Components

* Custom meal cards with nutritional information
* Dynamic navigation based on user authentication and role
* Responsive layout optimized for mobile devices
* Modern UI components using Flutter widgets and custom designs

## 📱 Application Flow

1. **Welcome & Authentication**: Users start with a welcome screen, then login/signup
2. **Home Discovery**: Browse featured meals and community chef offerings
3. **Meal Details**: View comprehensive meal information including nutrition and chef details
4. **Shopping Experience**: Add meals to cart, manage quantities, proceed to checkout
5. **Chef Experience**: Toggle to chef mode, add meals, manage dashboard and analytics
6. **Profile Management**: Update delivery info, payment methods, and user preferences

## 🎯 User Experience

* **Intuitive Navigation**: Bottom navigation bar for easy access to key features
* **Role Flexibility**: Seamless switching between customer and chef experiences
* **Community Focus**: Emphasis on local chefs and neighborhood meal sharing
* **Complete E-commerce**: Full purchase flow from discovery to delivery

## 🚀 Getting Startedggggg

The application is built with modern Flutter best practices, featuring a clean widget structure in the `/widgets` directory, Provider-based state management, and a scalable architecture that supports both individual users and the growing chef community.

Perfect for food enthusiasts who want to discover amazing homemade meals from their neighbors while also having the opportunity to share their own culinary creations with the community.


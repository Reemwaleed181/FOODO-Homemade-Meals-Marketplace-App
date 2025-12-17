class Nutrition {
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final int fiber;
  final int sugar;

  Nutrition({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.sugar,
  });

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'sugar': sugar,
    };
  }

  factory Nutrition.fromJson(Map<String, dynamic> json) {
    return Nutrition(
      calories: json['calories'],
      protein: json['protein'],
      carbs: json['carbs'],
      fat: json['fat'],
      fiber: json['fiber'],
      sugar: json['sugar'],
    );
  }

  // Factory method for API data (from Django backend)
  factory Nutrition.fromApiJson(Map<String, dynamic> json) {
    int toInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      return int.tryParse(value.toString()) ?? 0;
    }

    return Nutrition(
      calories: toInt(json['calories']),
      protein: toInt(json['protein']),
      carbs: toInt(json['carbs']),
      fat: toInt(json['fat']),
      fiber: toInt(json['fiber']),
      sugar: toInt(json['sugar']),
    );
  }
}

class Meal {
  final String id;
  final String name;
  final String description;
  final String chef;
  final String chefId;
  final double price;
  final String image;
  final String prepTime;
  final String portionSize;
  final double rating;
  final int orderCount;
  final List<String> tags;
  final bool isVegetarian;
  final bool isVegan;
  final bool isGlutenFree;
  final Nutrition nutrition;
  final List<String> ingredients;
  final List<String> allergens;
  final DateTime createdAt;
  final bool isActive;

  Meal({
    required this.id,
    required this.name,
    required this.description,
    required this.chef,
    required this.chefId,
    required this.price,
    required this.image,
    required this.prepTime,
    required this.portionSize,
    required this.rating,
    required this.orderCount,
    required this.tags,
    required this.isVegetarian,
    required this.isVegan,
    required this.isGlutenFree,
    required this.nutrition,
    required this.ingredients,
    required this.allergens,
    required this.createdAt,
    required this.isActive,
  });

  Meal copyWith({
    String? id,
    String? name,
    String? description,
    String? chef,
    String? chefId,
    double? price,
    String? image,
    String? prepTime,
    String? portionSize,
    double? rating,
    int? orderCount,
    List<String>? tags,
    bool? isVegetarian,
    bool? isVegan,
    bool? isGlutenFree,
    Nutrition? nutrition,
    List<String>? ingredients,
    List<String>? allergens,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return Meal(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      chef: chef ?? this.chef,
      chefId: chefId ?? this.chefId,
      price: price ?? this.price,
      image: image ?? this.image,
      prepTime: prepTime ?? this.prepTime,
      portionSize: portionSize ?? this.portionSize,
      rating: rating ?? this.rating,
      orderCount: orderCount ?? this.orderCount,
      tags: tags ?? this.tags,
      isVegetarian: isVegetarian ?? this.isVegetarian,
      isVegan: isVegan ?? this.isVegan,
      isGlutenFree: isGlutenFree ?? this.isGlutenFree,
      nutrition: nutrition ?? this.nutrition,
      ingredients: ingredients ?? this.ingredients,
      allergens: allergens ?? this.allergens,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'chef': chef,
      'chefId': chefId,
      'price': price,
      'image': image,
      'prepTime': prepTime,
      'portionSize': portionSize,
      'rating': rating,
      'orderCount': orderCount,
      'tags': tags,
      'isVegetarian': isVegetarian,
      'isVegan': isVegan,
      'isGlutenFree': isGlutenFree,
      'nutrition': nutrition.toJson(),
      'ingredients': ingredients,
      'allergens': allergens,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      chef: json['chef'],
      chefId: json['chefId'],
      price: json['price']?.toDouble(),
      image: json['image'],
      prepTime: json['prepTime'],
      portionSize: json['portionSize'],
      rating: json['rating']?.toDouble(),
      orderCount: json['orderCount'],
      tags: List<String>.from(json['tags']),
      isVegetarian: json['isVegetarian'],
      isVegan: json['isVegan'],
      isGlutenFree: json['isGlutenFree'],
      nutrition: Nutrition.fromJson(json['nutrition']),
      ingredients: List<String>.from(json['ingredients']),
      allergens: List<String>.from(json['allergens']),
      createdAt: DateTime.parse(json['createdAt']),
      isActive: json['isActive'],
    );
  }

  // Factory method for API data (from Django backend)
  factory Meal.fromApiJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'].toString(),
      name: json['name'],
      description: json['description'],
      chef: json['chef']['first_name'] + ' ' + json['chef']['last_name'],
      chefId: json['chef']['id'].toString(),
      price: json['price']?.toDouble(),
      image: json['image'], // This will be a URL from Django
      prepTime: json['prep_time'],
      portionSize: json['portion_size'],
      rating: json['rating']?.toDouble() ?? 0.0,
      orderCount: json['order_count'] ?? 0,
      tags: List<String>.from(json['tags'] ?? []),
      isVegetarian: json['is_vegetarian'] ?? false,
      isVegan: json['is_vegan'] ?? false,
      isGlutenFree: json['is_gluten_free'] ?? false,
      nutrition: json['nutrition'] != null 
          ? Nutrition.fromApiJson(json['nutrition'])
          : Nutrition(calories: 0, protein: 0, carbs: 0, fat: 0, fiber: 0, sugar: 0),
      ingredients: List<String>.from(json['ingredients'] ?? []),
      allergens: List<String>.from(json['allergens'] ?? []),
      createdAt: DateTime.parse(json['created_at']),
      isActive: json['is_active'] ?? true,
    );
  }
}

// Sample meals data
final mealsData = {
  'meals': [
    Meal(
      id: "1",
      name: "Mediterranean Quinoa Bowl",
      chef: "Sarah M.",
      price: 12.99,
      image: "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&h=300&fit=crop",
      description: "A nutritious bowl packed with quinoa, grilled chicken, chickpeas, cucumber, tomatoes, red onion, and feta cheese, drizzled with lemon-herb dressing.",
      portionSize: "350g",
      prepTime: "25 mins",
      rating: 4.8,
      orderCount: 127,
      tags: ["Healthy", "Protein-Rich", "Mediterranean"],
      nutrition: Nutrition(
        calories: 485,
        protein: 32,
        carbs: 45,
        fat: 18,
        fiber: 8,
        sugar: 6,
      ),
      ingredients: ["Quinoa", "Grilled Chicken", "Chickpeas", "Cucumber", "Cherry Tomatoes", "Red Onion", "Feta Cheese", "Olive Oil", "Lemon", "Fresh Herbs"],
      allergens: ["Dairy"],
      isVegetarian: false,
      isVegan: false,
      isGlutenFree: true,
      chefId: "chef-1",
      createdAt: DateTime.now(),
      isActive: true,
    ),
    Meal(
      id: "2",
      name: "Creamy Mushroom Pasta",
      chef: "Emma L.",
      price: 10.99,
      image: "https://images.unsplash.com/photo-1621996346565-e3dbc353d2e5?w=400&h=300&fit=crop",
      description: "Rich and creamy pasta with sautéed mushrooms, garlic, and fresh parmesan. Comfort food at its finest!",
      portionSize: "300g",
      prepTime: "20 mins",
      rating: 4.6,
      orderCount: 95,
      tags: ["Comfort Food", "Vegetarian", "Creamy"],
      nutrition: Nutrition(
        calories: 420,
        protein: 15,
        carbs: 58,
        fat: 16,
        fiber: 4,
        sugar: 5,
      ),
      ingredients: ["Fettuccine Pasta", "Mixed Mushrooms", "Heavy Cream", "Parmesan Cheese", "Garlic", "White Wine", "Fresh Thyme", "Butter"],
      allergens: ["Gluten", "Dairy"],
      isVegetarian: true,
      isVegan: false,
      isGlutenFree: false,
      chefId: "chef-2",
      createdAt: DateTime.now(),
      isActive: true,
    ),
    Meal(
      id: "3",
      name: "Asian Fusion Buddha Bowl",
      chef: "Lily C.",
      price: 13.99,
      image: "https://images.unsplash.com/photo-1546793665-c74683f339c1?w=400&h=300&fit=crop",
      description: "A colorful mix of brown rice, teriyaki tofu, edamame, shredded carrots, purple cabbage, and avocado with sesame ginger dressing.",
      portionSize: "380g",
      prepTime: "30 mins",
      rating: 4.9,
      orderCount: 203,
      tags: ["Vegan", "Asian", "Colorful", "Healthy"],
      nutrition: Nutrition(
        calories: 445,
        protein: 18,
        carbs: 52,
        fat: 20,
        fiber: 12,
        sugar: 8,
      ),
      ingredients: ["Brown Rice", "Teriyaki Tofu", "Edamame", "Shredded Carrots", "Purple Cabbage", "Avocado", "Sesame Seeds", "Ginger", "Soy Sauce"],
      allergens: ["Soy"],
      isVegetarian: true,
      isVegan: true,
      isGlutenFree: true,
      chefId: "chef-3",
      createdAt: DateTime.now(),
      isActive: true,
    ),
    Meal(
      id: "4",
      name: "Homestyle Chicken Curry",
      chef: "Priya S.",
      price: 14.99,
      image: "https://images.unsplash.com/photo-1588166524941-3bf61a9c41db?w=400&h=300&fit=crop",
      description: "Tender chicken in aromatic spices with coconut milk, served with basmati rice. A family recipe passed down for generations.",
      portionSize: "400g",
      prepTime: "45 mins",
      rating: 4.7,
      orderCount: 156,
      tags: ["Spicy", "Indian", "Comfort Food"],
      nutrition: Nutrition(
        calories: 520,
        protein: 35,
        carbs: 48,
        fat: 22,
        fiber: 3,
        sugar: 7,
      ),
      ingredients: ["Chicken Thighs", "Coconut Milk", "Basmati Rice", "Onions", "Tomatoes", "Ginger", "Garlic", "Curry Spices", "Cilantro"],
      allergens: [],
      isVegetarian: false,
      isVegan: false,
      isGlutenFree: true,
      chefId: "chef-4",
      createdAt: DateTime.now(),
      isActive: true,
    ),
  ],
  'frequentlyOrdered': ["3", "1", "4", "2"]
};
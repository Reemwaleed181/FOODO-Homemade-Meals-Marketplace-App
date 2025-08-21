class CartItem {
  final String id;
  final String mealId;
  final String name;
  final String chef;
  final double price;
  final String image;
  final int quantity;
  final String portionSize;

  CartItem({
    required this.id,
    required this.mealId,
    required this.name,
    required this.chef,
    required this.price,
    required this.image,
    required this.quantity,
    required this.portionSize,
  });

  CartItem copyWith({
    String? id,
    String? mealId,
    String? name,
    String? chef,
    double? price,
    String? image,
    int? quantity,
    String? portionSize,
  }) {
    return CartItem(
      id: id ?? this.id,
      mealId: mealId ?? this.mealId,
      name: name ?? this.name,
      chef: chef ?? this.chef,
      price: price ?? this.price,
      image: image ?? this.image,
      quantity: quantity ?? this.quantity,
      portionSize: portionSize ?? this.portionSize,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mealId': mealId,
      'name': name,
      'chef': chef,
      'price': price,
      'image': image,
      'quantity': quantity,
      'portionSize': portionSize,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      mealId: json['mealId'],
      name: json['name'],
      chef: json['chef'],
      price: json['price']?.toDouble(),
      image: json['image'],
      quantity: json['quantity'],
      portionSize: json['portionSize'],
    );
  }
}
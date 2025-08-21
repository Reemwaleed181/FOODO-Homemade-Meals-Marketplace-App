enum UserRole { customer, chef, both }

class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String zipCode;
  final UserRole role;
  final bool isChef;
  final String? chefBio;
  final double? chefRating;
  final int? totalOrders;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.zipCode,
    required this.role,
    required this.isChef,
    this.chefBio,
    this.chefRating,
    this.totalOrders,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? zipCode,
    UserRole? role,
    bool? isChef,
    String? chefBio,
    double? chefRating,
    int? totalOrders,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      zipCode: zipCode ?? this.zipCode,
      role: role ?? this.role,
      isChef: isChef ?? this.isChef,
      chefBio: chefBio ?? this.chefBio,
      chefRating: chefRating ?? this.chefRating,
      totalOrders: totalOrders ?? this.totalOrders,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'zipCode': zipCode,
      'role': role.toString(),
      'isChef': isChef,
      'chefBio': chefBio,
      'chefRating': chefRating,
      'totalOrders': totalOrders,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      city: json['city'],
      zipCode: json['zipCode'],
      role: UserRole.values.firstWhere(
            (e) => e.toString() == 'UserRole.${json['role']}',
        orElse: () => UserRole.customer,
      ),
      isChef: json['isChef'],
      chefBio: json['chefBio'],
      chefRating: json['chefRating']?.toDouble(),
      totalOrders: json['totalOrders'],
    );
  }
}
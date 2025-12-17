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
  final bool isVerified;
  final String? profilePicture;

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
    this.isVerified = false,
    this.profilePicture,
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
    bool? isVerified,
    String? profilePicture,
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
      isVerified: isVerified ?? this.isVerified,
      profilePicture: profilePicture ?? this.profilePicture,
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
      'isVerified': isVerified,
      'profilePicture': profilePicture,
    };
  }

  // Helper function to safely convert to double
  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  // Helper function to safely convert to int
  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  factory User.fromJson(Map<String, dynamic> json) {
    // Convert ID to string if it's an integer (Django returns int IDs)
    String id = '';
    if (json['id'] != null) {
      id = json['id'].toString();
    }
    
    return User(
      id: id,
      name: json['name'] ?? json['first_name'] ?? json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      zipCode: json['zipCode'] ?? json['zip_code'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${json['role']}',
        orElse: () => UserRole.customer,
      ),
      isChef: json['isChef'] ?? json['is_chef'] ?? false,
      chefBio: json['chefBio'] ?? json['chef_bio'],
      chefRating: _toDouble(json['chefRating'] ?? json['chef_rating']),
      totalOrders: _toInt(json['totalOrders'] ?? json['total_orders']),
      isVerified: json['isVerified'] ?? json['is_verified'] ?? false,
      profilePicture: json['profilePicture'] ?? json['profile_picture'],
    );
  }
}

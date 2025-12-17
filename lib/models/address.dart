class Address {
  final String id;
  final String type; // 'home', 'work', 'other'
  final String label;
  final String fullName;
  final String streetAddress;
  final String city;
  final String zipCode;
  final String phone;
  final String? instructions;
  bool isDefault;

  Address({
    required this.id,
    required this.type,
    required this.label,
    required this.fullName,
    required this.streetAddress,
    required this.city,
    required this.zipCode,
    required this.phone,
    this.instructions,
    required this.isDefault,
  });

  Address copyWith({
    String? id,
    String? type,
    String? label,
    String? fullName,
    String? streetAddress,
    String? city,
    String? zipCode,
    String? phone,
    String? instructions,
    bool? isDefault,
  }) {
    return Address(
      id: id ?? this.id,
      type: type ?? this.type,
      label: label ?? this.label,
      fullName: fullName ?? this.fullName,
      streetAddress: streetAddress ?? this.streetAddress,
      city: city ?? this.city,
      zipCode: zipCode ?? this.zipCode,
      phone: phone ?? this.phone,
      instructions: instructions ?? this.instructions,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  String get fullAddress => '$streetAddress, $city, $zipCode';

  Map<String, dynamic> toJson({bool useSnakeCase = false}) {
    if (useSnakeCase) {
      // For backend API (Django expects snake_case)
      return {
        'id': id,
        'type': type,
        'label': label,
        'full_name': fullName,
        'street_address': streetAddress,
        'city': city,
        'zip_code': zipCode,
        'phone': phone,
        'instructions': instructions,
        'is_default': isDefault,
      };
    } else {
      // For local storage (camelCase)
      return {
        'id': id,
        'type': type,
        'label': label,
        'fullName': fullName,
        'streetAddress': streetAddress,
        'city': city,
        'zipCode': zipCode,
        'phone': phone,
        'instructions': instructions,
        'isDefault': isDefault,
      };
    }
  }

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id']?.toString() ?? '',
      type: json['type'] ?? 'home',
      label: json['label'] ?? '',
      fullName: json['fullName'] ?? json['full_name'] ?? json['name'] ?? '',
      streetAddress:
          json['streetAddress'] ??
          json['street_address'] ??
          json['address'] ??
          '',
      city: json['city'] ?? '',
      zipCode: json['zipCode'] ?? json['zip_code'] ?? '',
      phone: json['phone'] ?? '',
      instructions: json['instructions'],
      isDefault: json['isDefault'] ?? json['is_default'] ?? false,
    );
  }

  bool isValid() {
    return fullName.isNotEmpty &&
        streetAddress.isNotEmpty &&
        city.isNotEmpty &&
        zipCode.isNotEmpty &&
        phone.isNotEmpty;
  }
}

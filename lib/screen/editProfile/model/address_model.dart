class Address {
  final int id;
  final int userId;
  final String address;
  final String pincode;
  final String city;
  final String state;
  final String createdAt;
  final String updatedAt;

  Address({
    required this.id,
    required this.userId,
    required this.address,
    required this.pincode,
    required this.city,
    required this.state,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      address: json['address'] ?? '',
      pincode: json['pincode'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}
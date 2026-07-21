class Partner {
  final String id;
  final String name;
  final String email;
  final String mobile;
  final String contactPerson;
  final String contactMobile;
  final String address;
  final String status; // "Active" or "Inactive"
  final String createdAt;

  Partner({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.contactPerson,
    required this.contactMobile,
    required this.address,
    required this.status,
    required this.createdAt,
  });

  factory Partner.fromJson(Map<String, dynamic> json) {
    return Partner(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      contactPerson: json['contact_person'] ?? '',
      contactMobile: json['contact_mobile'] ?? '',
      address: json['address'] ?? '',
      status: json['status_label'] ?? (json['status'] == 1 ? 'Active' : 'Inactive'),
      createdAt: json['created_at'] ?? '',
    );
  }
}

class PartnerListResponse {
  final bool status;
  final String message;
  final List<Partner> data;

  PartnerListResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory PartnerListResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List? ?? [];
    return PartnerListResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: dataList.map((item) => Partner.fromJson(item)).toList(),
    );
  }
}
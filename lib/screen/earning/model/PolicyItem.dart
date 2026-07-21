// Models
class PolicyItem {
  final int id;
  final String label;

  PolicyItem({required this.id, required this.label});

  factory PolicyItem.fromJson(Map<String, dynamic> json) {
    return PolicyItem(
      id: int.parse(json['id'].toString()),
      label: json['label'] ?? '',
    );
  }
}

class PartnerItem {
  final int id;
  final String name;
  final String email;
  final String mobile;

  PartnerItem({required this.id, required this.name, required this.email, required this.mobile});

  factory PartnerItem.fromJson(Map<String, dynamic> json) {
    return PartnerItem(
      id: int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
    );
  }
}
class UserProfile {
  final int id;
  final String name;
  final String email;
  final String mobile;
  final String? avatar;
  final String role;
  final int status;
  final int? planId;
  final int? planPriority;
  final String createdAt;
  final String updatedAt;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    this.avatar,
    required this.role,
    required this.status,
    this.planId,
    this.planPriority,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      avatar: json['avatar'],
      role: json['role'] ?? '',
      status: json['status'] ?? 0,
      planId: json['planId'],
      planPriority: json['planPriority'],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}
import 'dart:convert';

// ──────────────────────────────────────────────
// Top‑level response
// ──────────────────────────────────────────────
class VerifyOtpModel {
  final bool status;
  final String message;
  final String token;
  final User user;

  VerifyOtpModel({
    required this.status,
    required this.message,
    required this.token,
    required this.user,
  });

  factory VerifyOtpModel.fromJson(Map<String, dynamic> json) {
    return VerifyOtpModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      token: json['token'] ?? '',
      user: User.fromJson(json['user'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'token': token,
    'user': user.toJson(),
  };

  String toRawJson() => jsonEncode(toJson());
  factory VerifyOtpModel.fromRawJson(String str) =>
      VerifyOtpModel.fromJson(jsonDecode(str));
}

// ──────────────────────────────────────────────
// User (with plan details)
// ──────────────────────────────────────────────
class User {
  final int id;
  final String? name;
  final String? email;
  final String mobile;
  final String? avatar;
  final String role;
  final int status;
  final int planId;          // new
  final int planPriority;    // new
  final String createdAt;
  final String updatedAt;
  final UserPlan planDetails; // new, nested object

  User({
    required this.id,
    this.name,
    this.email,
    required this.mobile,
    this.avatar,
    required this.role,
    required this.status,
    required this.planId,
    required this.planPriority,
    required this.createdAt,
    required this.updatedAt,
    required this.planDetails,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'],
      email: json['email'],
      mobile: json['mobile'] ?? '',
      avatar: json['avatar'],
      role: json['role'] ?? '',
      status: json['status'] ?? 0,
      planId: json['planId'] ?? 0,
      planPriority: json['planPriority'] ?? 0,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      planDetails: UserPlan.fromJson(json['plan_details'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'mobile': mobile,
    'avatar': avatar,
    'role': role,
    'status': status,
    'planId': planId,
    'planPriority': planPriority,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'plan_details': planDetails.toJson(),
  };
}

// ──────────────────────────────────────────────
// Plan details (subset of full Plan)
// ──────────────────────────────────────────────
class UserPlan {
  final int id;
  final String planName;
  final String planImage;
  final int price;
  final int yearlyAmount;
  final int discountPercentage;
  final int discountAmount;
  final int status;
  final int priority;
  final String planTypes;
  final List<UserPlanMaster> planMasters;

  UserPlan({
    required this.id,
    required this.planName,
    required this.planImage,
    required this.price,
    required this.yearlyAmount,
    required this.discountPercentage,
    required this.discountAmount,
    required this.status,
    required this.priority,
    required this.planTypes,
    required this.planMasters,
  });

  factory UserPlan.fromJson(Map<String, dynamic> json) {
    return UserPlan(
      id: json['id'] ?? 0,
      planName: json['planName'] ?? '',
      planImage: json['planImage'] ?? '',
      price: json['price'] ?? 0,
      yearlyAmount: json['yearlyAmount'] ?? 0,
      discountPercentage: json['discountPercentage'] ?? 0,
      discountAmount: json['discountAmount'] ?? 0,
      status: json['status'] ?? 0,
      priority: json['priority'] ?? 0,
      planTypes: json['planTypes'] ?? '',
      planMasters: (json['planMasters'] as List?)
          ?.map((e) => UserPlanMaster.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'planName': planName,
    'planImage': planImage,
    'price': price,
    'yearlyAmount': yearlyAmount,
    'discountPercentage': discountPercentage,
    'discountAmount': discountAmount,
    'status': status,
    'priority': priority,
    'planTypes': planTypes,
    'planMasters': planMasters.map((e) => e.toJson()).toList(),
  };
}

// ──────────────────────────────────────────────
// PlanMaster inside plan_details
// ──────────────────────────────────────────────
class UserPlanMaster {
  final int id;
  final String masterId;
  final int count;
  final UserMaster master;

  UserPlanMaster({
    required this.id,
    required this.masterId,
    required this.count,
    required this.master,
  });

  factory UserPlanMaster.fromJson(Map<String, dynamic> json) {
    return UserPlanMaster(
      id: json['id'] ?? 0,
      masterId: json['masterId'] ?? '',
      count: json['count'] ?? 0,
      master: UserMaster.fromJson(json['master'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'masterId': masterId,
    'count': count,
    'master': master.toJson(),
  };
}

// ──────────────────────────────────────────────
// Master inside plan_details (simplified)
// ──────────────────────────────────────────────
class UserMaster {
  final String id;
  final String name;
  final String type;
  final String? alias;
  final int status;

  UserMaster({
    required this.id,
    required this.name,
    required this.type,
    this.alias,
    required this.status,
  });

  factory UserMaster.fromJson(Map<String, dynamic> json) {
    return UserMaster(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      alias: json['alias'],
      status: json['status'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'alias': alias,
    'status': status,
  };
}
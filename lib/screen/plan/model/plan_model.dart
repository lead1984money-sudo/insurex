class PlanResponse {
  final bool status;
  final String message;
  final String buyNowFalseMessage; // new
  final List<Plan> data;

  PlanResponse({
    required this.status,
    required this.message,
    required this.buyNowFalseMessage,
    required this.data,
  });

  factory PlanResponse.fromJson(Map<String, dynamic> json) {
    return PlanResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      buyNowFalseMessage: json['buy_now_false_message'] ?? '',
      data: (json['data'] as List)
          .map((e) => Plan.fromJson(e))
          .toList(),
    );
  }
}

class Plan {
  final int id;
  final String planName;
  final String planImage;
  final int price;
  final int yearlyAmount;
  final String validity;           // kept, but might be unused
  final int discountPercentage;
  final int discountAmount;
  final int status;
  final int priority;
  final String planTypes;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final List<PlanMaster> planMasters;
  final bool subscribed;           // new
  final bool buyNow;               // new

  Plan({
    required this.id,
    required this.planName,
    required this.planImage,
    required this.price,
    required this.yearlyAmount,
    required this.validity,
    required this.discountPercentage,
    required this.discountAmount,
    required this.status,
    required this.priority,
    required this.planTypes,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.planMasters,
    required this.subscribed,
    required this.buyNow,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['id'] ?? 0,
      planName: json['planName'] ?? '',
      planImage: json['planImage'] ?? '',
      price: json['price'] ?? 0,
      yearlyAmount: json['yearlyAmount'] ?? 0,
      validity: json['validity'] ?? '',
      discountPercentage: json['discountPercentage'] ?? 0,
      discountAmount: json['discountAmount'] ?? 0,
      status: json['status'] ?? 0,
      priority: json['priority'] ?? 0,
      planTypes: json['planTypes'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      deletedAt: json['deletedAt'],
      planMasters: (json['planMasters'] as List)
          .map((e) => PlanMaster.fromJson(e))
          .toList(),
      subscribed: json['subscribed'] ?? false,
      buyNow: json['buy_now'] ?? false,
    );
  }
}

class PlanMaster {
  final int id;
  final int planId;
  final String masterId;
  final int count;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final Master master;

  PlanMaster({
    required this.id,
    required this.planId,
    required this.masterId,
    required this.count,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.master,
  });

  factory PlanMaster.fromJson(Map<String, dynamic> json) {
    return PlanMaster(
      id: json['id'] ?? 0,
      planId: json['planId'] ?? 0,
      masterId: json['masterId'] ?? '',
      count: json['count'] ?? 0,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      deletedAt: json['deletedAt'],
      master: Master.fromJson(json['master'] ?? {}),
    );
  }
}

class Master {
  final String id;
  final String parentId;
  final String name;
  final String type;
  final String? alias;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final int status;

  Master({
    required this.id,
    required this.parentId,
    required this.name,
    required this.type,
    this.alias,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.status,
  });

  factory Master.fromJson(Map<String, dynamic> json) {
    return Master(
      id: json['id'] ?? '',
      parentId: json['parentId'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      alias: json['alias'],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      deletedAt: json['deletedAt'],
      status: json['status'] ?? 0,
    );
  }
}
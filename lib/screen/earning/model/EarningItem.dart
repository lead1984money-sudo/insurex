class EarningItem {
  final int id;
  final int userId;
  final String? userName;
  final int srMastersId;
  final String srMasterPolicyNo;
  final String srMasterVehicleNo;
  final String srMasterProposerName;
  final int partnerId;
  final String partnerName;
  final String partnerMobile;
  final double payInAmount;
  final double cashbackCustomerAmount;
  final double earningAmount;
  final String remarks;
  final int status;
  final String statusLabel;
  final String createdAt;
  final String updatedAt;

  EarningItem({
    required this.id,
    required this.userId,
    this.userName,
    required this.srMastersId,
    required this.srMasterPolicyNo,
    required this.srMasterVehicleNo,
    required this.srMasterProposerName,
    required this.partnerId,
    required this.partnerName,
    required this.partnerMobile,
    required this.payInAmount,
    required this.cashbackCustomerAmount,
    required this.earningAmount,
    required this.remarks,
    required this.status,
    required this.statusLabel,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EarningItem.fromJson(Map<String, dynamic> json) {
    return EarningItem(
      id: int.parse(json['id'].toString()),
      userId: int.parse(json['user_id'].toString()),
      userName: json['user_name'],
      srMastersId: int.parse(json['sr_masters_id'].toString()),
      srMasterPolicyNo: json['sr_master_policy_no'] ?? '',
      srMasterVehicleNo: json['sr_master_vehicle_no'] ?? '',
      srMasterProposerName: json['sr_master_proposer_name'] ?? '',
      partnerId: int.parse(json['partner_id'].toString()),
      partnerName: json['partner_name'] ?? '',
      partnerMobile: json['partner_mobile'] ?? '',
      payInAmount: double.tryParse(json['pay_in_amount']?.toString() ?? '0') ?? 0,
      cashbackCustomerAmount: double.tryParse(json['cashback_customer_amount']?.toString() ?? '0') ?? 0,
      earningAmount: double.tryParse(json['earning_amount']?.toString() ?? '0') ?? 0,
      remarks: json['remarks'] ?? '',
      status: int.parse(json['status'].toString()),
      statusLabel: json['status_label'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class EarningsListResponse {
  final bool status;
  final List<EarningItem> data;
  final Pagination pagination;
  final Stats stats;

  EarningsListResponse({
    required this.status,
    required this.data,
    required this.pagination,
    required this.stats,
  });

  factory EarningsListResponse.fromJson(Map<String, dynamic> json) {
    final List data = json['data'] ?? [];
    return EarningsListResponse(
      status: json['status'] ?? false,
      data: data.map((item) => EarningItem.fromJson(item)).toList(),
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
      stats: Stats.fromJson(json['stats'] ?? {}),
    );
  }
}

class Pagination {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  Pagination({required this.total, required this.page, required this.limit, required this.totalPages});

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      total: int.parse(json['total']?.toString() ?? '0'),
      page: int.parse(json['page']?.toString() ?? '1'),
      limit: int.parse(json['limit']?.toString() ?? '10'),
      totalPages: int.parse(json['total_pages']?.toString() ?? '1'),
    );
  }
}

class Stats {
  final double totalPayIn;
  final double totalCashback;
  final double totalEarning;
  final int active;

  Stats({required this.totalPayIn, required this.totalCashback, required this.totalEarning, required this.active});

  factory Stats.fromJson(Map<String, dynamic> json) {
    return Stats(
      totalPayIn: double.tryParse(json['total_pay_in']?.toString() ?? '0') ?? 0,
      totalCashback: double.tryParse(json['total_cashback']?.toString() ?? '0') ?? 0,
      totalEarning: double.tryParse(json['total_earning']?.toString() ?? '0') ?? 0,
      active: int.parse(json['active']?.toString() ?? '0'),
    );
  }
}
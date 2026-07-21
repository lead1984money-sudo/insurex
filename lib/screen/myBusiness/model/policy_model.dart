// policy_model.dart
class PolicyListResponse {
  final bool status;
  final List<PolicyData> data;
  final Pagination pagination;

  PolicyListResponse({
    required this.status,
    required this.data,
    required this.pagination,
  });

  factory PolicyListResponse.fromJson(Map<String, dynamic> json) {
    return PolicyListResponse(
      status: json['status'] ?? false,
      data: (json['data'] as List)
          .map((e) => PolicyData.fromJson(e))
          .toList(),
      pagination: Pagination.fromJson(json['pagination']),
    );
  }
}

class PolicyData {
  final String id;
  final String? userId;
  final int? lobId;
  final String? lobName;
  final int? productId;
  final String? productName;
  final String? masterId;
  final String? insuranceMasterId;
  final String? insurerName;
  final String? proposerName;
  final String? policyNo;
  final String? vehicleNo;
  final String? startDate;
  final String? endDate;
  final String? fileName;
  final String? createdAt;

  PolicyData({
    required this.id,
    this.userId,
    this.lobId,
    this.lobName,
    this.productId,
    this.productName,
    this.masterId,
    this.insuranceMasterId,
    this.insurerName,
    this.proposerName,
    this.policyNo,
    this.vehicleNo,
    this.startDate,
    this.endDate,
    this.fileName,
    this.createdAt,
  });

  factory PolicyData.fromJson(Map<String, dynamic> json) {
    return PolicyData(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString(),
      lobId: json['lob_id'] is int ? json['lob_id'] : int.tryParse(json['lob_id']?.toString() ?? ''),
      lobName: json['lob_name'],
      productId: json['product_id'] is int ? json['product_id'] : int.tryParse(json['product_id']?.toString() ?? ''),
      productName: json['product_name'],
      masterId: json['master_id']?.toString(),
      insuranceMasterId: json['insurance_master_id']?.toString(),
      insurerName: json['insurer_name'],
      proposerName: json['proposer_name'],
      policyNo: json['policy_no'],
      vehicleNo: json['vehicle_no'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      fileName: json['file_name'],
      createdAt: json['created_at'],
    );
  }
}

class Pagination {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  Pagination({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      totalPages: json['total_pages'] ?? 1,
    );
  }
}
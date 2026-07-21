class LeadDetailResponse {
  final bool status;
  final LeadDetail data;

  LeadDetailResponse({
    required this.status,
    required this.data,
  });

  factory LeadDetailResponse.fromJson(Map<String, dynamic> json) {
    return LeadDetailResponse(
      status: json['status'] ?? false,
      data: LeadDetail.fromJson(json['data'] ?? {}),
    );
  }
}

class LeadDetail {
  final LeadData lead;
  final List<History> history;

  LeadDetail({
    required this.lead,
    required this.history,
  });

  factory LeadDetail.fromJson(Map<String, dynamic> json) {
    return LeadDetail(
      lead: LeadData.fromJson(json['lead'] ?? {}),
      history: (json['history'] as List<dynamic>? ?? [])
          .map((e) => History.fromJson(e))
          .toList(),
    );
  }
}

class LeadData {
  final String id;
  final int userId;
  final String parentId;

  final int leadStatusId;
  final String leadStatusName;

  final int leadReferenceMasterId;
  final String leadReferenceName;

  final String customerName;
  final String mobile;
  final String email;
  final String pincode;

  final int lobId;
  final String lobName;

  final String? leadDetails;
  final String? vehicleNo;
  final String? policyNo;
  final String? address;

  final String? notes;
  final String? reference;
  final String source;

  final String createdAt;
  final String updatedAt;

  final List<DocumentModel> documents;

  LeadData({
    required this.id,
    required this.userId,
    required this.parentId,
    required this.leadStatusId,
    required this.leadStatusName,
    required this.leadReferenceMasterId,
    required this.leadReferenceName,
    required this.customerName,
    required this.mobile,
    required this.email,
    required this.pincode,
    required this.lobId,
    required this.lobName,
    this.leadDetails,
    this.vehicleNo,
    this.policyNo,
    this.address,
    this.notes,
    this.reference,
    required this.source,
    required this.createdAt,
    required this.updatedAt,
    required this.documents,
  });

  factory LeadData.fromJson(Map<String, dynamic> json) {
    return LeadData(
      id: json['id']?.toString() ?? '',
      userId: json['user_id'] ?? 0,
      parentId: json['parent_id']?.toString() ?? '',

      leadStatusId: json['lead_status_id'] ?? 0,
      leadStatusName: json['lead_status_name'] ?? '',

      leadReferenceMasterId:
      json['lead_reference_master_id'] ?? 0,
      leadReferenceName:
      json['lead_reference_name'] ?? '',

      customerName: json['customer_name'] ?? '',
      mobile: json['mobile'] ?? '',
      email: json['email'] ?? '',
      pincode: json['pincode'] ?? '',

      lobId: json['lob_id'] ?? 0,
      lobName: json['lob_name'] ?? '',

      leadDetails: json['lead_details'],
      vehicleNo: json['vehicle_no'],
      policyNo: json['policy_no'],
      address: json['address'],

      notes: json['notes'],
      reference: json['reference'],
      source: json['source'] ?? '',

      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',

      documents: (json['documents'] as List<dynamic>? ?? [])
          .map((e) => DocumentModel.fromJson(e))
          .toList(),
    );
  }
}

class DocumentModel {
  final String id;
  final String documentType;
  final String documentUrl;

  DocumentModel({
    required this.id,
    required this.documentType,
    required this.documentUrl,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id']?.toString() ?? '',
      documentType: json['document_type'] ?? '',
      documentUrl: json['document_url'] ?? '',
    );
  }
}

class History {
  final String id;
  final String leadId;

  final int leadStatusId;
  final String leadStatusName;

  final String dateTime;
  final String? remarks;

  final String createdAt;
  final String? updatedAt;

  History({
    required this.id,
    required this.leadId,
    required this.leadStatusId,
    required this.leadStatusName,
    required this.dateTime,
    this.remarks,
    required this.createdAt,
    this.updatedAt,
  });

  factory History.fromJson(Map<String, dynamic> json) {
    return History(
      id: json['id']?.toString() ?? '',
      leadId: json['lead_id']?.toString() ?? '',
      leadStatusId: json['lead_status_id'] ?? 0,
      leadStatusName: json['lead_status_name'] ?? '',
      dateTime: json['date_time'] ?? '',
      remarks: json['remarks'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'],
    );
  }
}
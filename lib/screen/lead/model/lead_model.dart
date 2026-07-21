
class Lead {
  final int id;
  final int userId;
  final int parentId;
  final String? parentType;
  final int srMasterId;
  final int leadStatusId;
  final int leadStatus;
  final String status;          // lead_status_name
  final String? statusAlias;
  final int leadReferenceMasterId;
  final String? leadReferenceName;      // lead_reference_name
  final String name;            // customer_name
  final String mobile;
  final String email;
  final String pincode;
  final int lobId;
  final String type;            // lob_name
  final String? lobAlias;
  final String? leadDetails;
  final String? vehicleNo;
  final String? policyNo;
  final String? address;
  final String? notes;
  final String? reference;
  final String? remarks;        // field actually named 'reference' in API – we can map it as remarks
  final String source;
  final String createdAt;
  final String updatedAt;
  final List<dynamic> documents; // if needed

  Lead({
    required this.id,
    required this.userId,
    required this.parentId,
    this.parentType,
    required this.srMasterId,
    required this.leadStatusId,
    required this.leadStatus,
    required this.status,
    this.statusAlias,
    required this.leadReferenceMasterId,
    this.leadReferenceName,
    required this.name,
    required this.mobile,
    required this.email,
    required this.pincode,
    required this.lobId,
    required this.type,
    this.lobAlias,
    this.leadDetails,
    this.vehicleNo,
    this.policyNo,
    this.address,
    this.notes,
    this.reference,
    this.remarks,
    required this.source,
    required this.createdAt,
    required this.updatedAt,
    this.documents = const [],
  });
}
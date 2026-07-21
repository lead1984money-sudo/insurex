class Bank {
  final int id;
  final int userId;
  final String bankName;
  final String acHolderName;
  final String ifsc;
  final String acNumber;
  final String acType;
  final String createdAt;
  final String updatedAt;

  Bank({
    required this.id,
    required this.userId,
    required this.bankName,
    required this.acHolderName,
    required this.ifsc,
    required this.acNumber,
    required this.acType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Bank.fromJson(Map<String, dynamic> json) {
    return Bank(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      bankName: json['bankName'] ?? '',
      acHolderName: json['acHolderName'] ?? '',
      ifsc: json['ifsc'] ?? '',
      acNumber: json['acNumber'] ?? '',
      acType: json['acType'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}
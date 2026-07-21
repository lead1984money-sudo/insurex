class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String targetPath;
  final String triggerType;
  final String templateCode;
  final String referenceType;
  final String referenceId;
  final bool read;
  final String createdAt;
  final String sentAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.targetPath,
    required this.triggerType,
    required this.templateCode,
    required this.referenceType,
    required this.referenceId,
    required this.read,
    required this.createdAt,
    required this.sentAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      targetPath: json['target_path'] ?? '',
      triggerType: json['trigger_type'] ?? '',
      templateCode: json['template_code'] ?? '',
      referenceType: json['reference_type'] ?? '',
      referenceId: json['reference_id']?.toString() ?? '',
      read: json['read'] ?? false,
      createdAt: json['created_at'] ?? '',
      sentAt: json['sent_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'target_path': targetPath,
      'trigger_type': triggerType,
      'template_code': templateCode,
      'reference_type': referenceType,
      'reference_id': referenceId,
      'read': read,
      'created_at': createdAt,
      'sent_at': sentAt,
    };
  }

  // Helper to copy with updated read status
  NotificationModel copyWith({bool? read}) {
    return NotificationModel(
      id: id,
      title: title,
      body: body,
      targetPath: targetPath,
      triggerType: triggerType,
      templateCode: templateCode,
      referenceType: referenceType,
      referenceId: referenceId,
      read: read ?? this.read,
      createdAt: createdAt,
      sentAt: sentAt,
    );
  }
}
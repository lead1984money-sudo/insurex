
class ReminderListResponse {
  final bool status;
  final String message;
  final List<Reminder> data;

  ReminderListResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ReminderListResponse.fromJson(Map<String, dynamic> json) {
    return ReminderListResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? List<Reminder>.from(json['data'].map((x) => Reminder.fromJson(x)))
          : [],
    );
  }
}

class Reminder {
  final String id;
  final String userId;          // added
  final String categoryId;      // added
  final String categoryName;
  final String categoryAlias;
  final String typeId;          // added
  final String typeName;
  final String typeAlias;
  final String title;
  final String? description;
  final String eventDate;
  final String? eventTime;
  final String? reminderBeforeId;      // added (can be null)
  final String? reminderBeforeLabel;
  final List<String> notificationChannels;
  final String? notes;                // added
  final int status;
  final String statusLabel;
  final String source;                // added
  final String createdAt;
  final String updatedAt;

  Reminder({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.categoryName,
    required this.categoryAlias,
    required this.typeId,
    required this.typeName,
    required this.typeAlias,
    required this.title,
    this.description,
    required this.eventDate,
    this.eventTime,
    this.reminderBeforeId,
    this.reminderBeforeLabel,
    required this.notificationChannels,
    this.notes,
    required this.status,
    required this.statusLabel,
    required this.source,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      categoryId: json['category_id']?.toString() ?? '',
      categoryName: json['category_name'] ?? '',
      categoryAlias: json['category_alias'] ?? '',
      typeId: json['type_id']?.toString() ?? '',
      typeName: json['type_name'] ?? '',
      typeAlias: json['type_alias'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      eventDate: json['event_date'] ?? '',
      eventTime: json['event_time'],
      reminderBeforeId: json['reminder_before_id']?.toString(),
      reminderBeforeLabel: json['reminder_before_label'],
      notificationChannels: json['notification_channels'] != null
          ? List<String>.from(json['notification_channels'])
          : [],
      notes: json['notes'],
      status: json['status'] ?? 0,
      statusLabel: json['status_label'] ?? '',
      source: json['source'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}
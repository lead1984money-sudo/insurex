// reminder_master_model.dart

class ReminderMasterResponse {
  final bool status;
  final MasterData data;

  ReminderMasterResponse({required this.status, required this.data});

  factory ReminderMasterResponse.fromJson(Map<String, dynamic> json) {
    return ReminderMasterResponse(
      status: json['status'] ?? false,
      data: MasterData.fromJson(json['data'] ?? {}),
    );
  }
}

class MasterData {
  final List<Category> categories;
  final List<Type> types;
  final List<ReminderBefore> reminderBeforeOptions;
  final List<NotificationChannel> notificationChannels;

  MasterData({
    required this.categories,
    required this.types,
    required this.reminderBeforeOptions,
    required this.notificationChannels,
  });

  factory MasterData.fromJson(Map<String, dynamic> json) {
    return MasterData(
      categories: json['categories'] != null
          ? List<Category>.from(json['categories'].map((x) => Category.fromJson(x)))
          : [],
      types: json['types'] != null
          ? List<Type>.from(json['types'].map((x) => Type.fromJson(x)))
          : [],
      reminderBeforeOptions: json['reminder_before_options'] != null
          ? List<ReminderBefore>.from(json['reminder_before_options'].map((x) => ReminderBefore.fromJson(x)))
          : [],
      notificationChannels: json['notification_channels'] != null
          ? List<NotificationChannel>.from(json['notification_channels'].map((x) => NotificationChannel.fromJson(x)))
          : [],
    );
  }
}

class Category {
  final String id;
  final String name;
  final String alias;
  final String type;
  final String parentId;

  Category({
    required this.id,
    required this.name,
    required this.alias,
    required this.type,
    required this.parentId,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      alias: json['alias'] ?? '',
      type: json['type'] ?? '',
      parentId: json['parent_id']?.toString() ?? '0',
    );
  }
}

class Type {
  final String id;
  final String name;
  final String alias;
  final String type;
  final String parentId;
  final String categoryId;

  Type({
    required this.id,
    required this.name,
    required this.alias,
    required this.type,
    required this.parentId,
    required this.categoryId,
  });

  factory Type.fromJson(Map<String, dynamic> json) {
    return Type(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      alias: json['alias'] ?? '',
      type: json['type'] ?? '',
      parentId: json['parent_id']?.toString() ?? '0',
      categoryId: json['category_id']?.toString() ?? '0',
    );
  }
}

class ReminderBefore {
  final String id;
  final String name;
  final String alias;
  final String type;
  final String parentId;

  ReminderBefore({
    required this.id,
    required this.name,
    required this.alias,
    required this.type,
    required this.parentId,
  });

  factory ReminderBefore.fromJson(Map<String, dynamic> json) {
    return ReminderBefore(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      alias: json['alias'] ?? '',
      type: json['type'] ?? '',
      parentId: json['parent_id']?.toString() ?? '0',
    );
  }
}

class NotificationChannel {
  final String value;
  final String label;

  NotificationChannel({required this.value, required this.label});

  factory NotificationChannel.fromJson(Map<String, dynamic> json) {
    return NotificationChannel(
      value: json['value'] ?? '',
      label: json['label'] ?? '',
    );
  }
}
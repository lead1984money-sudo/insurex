import 'package:flutter/material.dart';
import '../../../data/modifiednetwork/ApiConfig.dart';
import '../../../data/modifiednetwork/ApiService.dart';
import '../../../data/network/ConnectivityService.dart';
import '../../../data/sharedpreferences/PreferenceManager.dart';
import '../model/reminder_master_model.dart';
import '../model/reminder_model.dart';



class ReminderProvider extends ChangeNotifier {
  final ConnectivityService _connectivity = ConnectivityService();
  final ApiService _api = ApiService();
  bool _isLoading = false;
  String _errorMessage = '';
  List<Reminder> _reminders = [];

  // Master data
  MasterData? _masterData;

  // Counts
  Map<String, int> _categoryCounts = {};

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<Reminder> get reminders => _reminders;
  MasterData? get masterData => _masterData;
  Map<String, int> get categoryCounts => _categoryCounts;

  bool _isCreating = false;
  bool get isCreating => _isCreating;

  bool _isUpdating = false;
  bool get isUpdating => _isUpdating;

  bool _isDeleting = false;
  bool get isDeleting => _isDeleting;


  Future<String?> _getToken() async {
    final loginData = await PreferenceManager.getLoginData();
    return loginData?.token;
  }

  // Fetch both reminders and master data in parallel
  Future<void> fetchAllData() async {
    if (!await _connectivity.hasInternet()) {
      _errorMessage = 'No internet connection.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) {
        _errorMessage = 'Authentication token not found.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final reminderBody = {'source': 'app-android'};
      final masterBody = {'source': 'app-android'};

      final results = await Future.wait([
        _api.postWithProgress(ApiConfig.reminderListUrl, data: reminderBody, headers: headers),
        _api.postWithProgress(ApiConfig.reminderTypeUrl, data: masterBody, headers: headers),
      ]);

      final reminderResponse = results[0];
      if (reminderResponse.statusCode != null &&
          reminderResponse.statusCode! >= 200 &&
          reminderResponse.statusCode! < 300) {
        final json = reminderResponse.data;
        if (json is Map<String, dynamic> && json['status'] == true) {
          final result = ReminderListResponse.fromJson(json);

          _reminders = result.data.where((r) => r.status == 1).toList();
          _computeCounts();
        } else {
          _errorMessage = json['message'] ?? 'Failed to load reminders';
        }
      } else {
        _errorMessage = 'Server error (reminders): ${reminderResponse.statusCode}';
      }

      if (_errorMessage.isEmpty) {
        final masterResponse = results[1];
        if (masterResponse.statusCode != null &&
            masterResponse.statusCode! >= 200 &&
            masterResponse.statusCode! < 300) {
          final json = masterResponse.data;
          if (json is Map<String, dynamic> && json['status'] == true) {
            _masterData = MasterData.fromJson(json['data'] ?? {});
          } else {
            _errorMessage = json['message'] ?? 'Failed to load master data';
          }
        } else {
          _errorMessage = 'Server error (master): ${masterResponse.statusCode}';
        }
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  void _computeCounts() {
    _categoryCounts = {};
    if (_masterData != null) {
      for (var cat in _masterData!.categories) {
        _categoryCounts[cat.alias] = 0;
      }
    }
    for (var r in _reminders) {
      final alias = r.categoryAlias.toLowerCase();
      _categoryCounts[alias] = (_categoryCounts[alias] ?? 0) + 1;
    }
  }

  // Create Reminder
  Future<bool> createReminder({
    required String categoryId,
    required String typeId,
    required String title,
    required String description,
    required String eventDate,
    required String eventTime,
    required String reminderBeforeId,
    required List<String> notificationChannels,
    required String notes,
    int status = 1,
  }) async {
    if (!await _connectivity.hasInternet()) {
      _errorMessage = 'No internet connection.';
      notifyListeners();
      return false;
    }

    _isCreating = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) {
        _errorMessage = 'Authentication token not found.';
        _isCreating = false;
        notifyListeners();
        return false;
      }

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final body = {
        'source': 'app-android',
        'category_id': int.parse(categoryId),
        'type_id': int.parse(typeId),
        'title': title,
        'description': description,
        'event_date': eventDate,
        'event_time': eventTime,
        'reminder_before_id': int.parse(reminderBeforeId),
        'notification_channels': notificationChannels,
        'notes': notes,
        'status': status,
      };

      final response = await _api.postWithProgress(
        ApiConfig.reminderCreateUrl,
        data: body,
        headers: headers,
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final json = response.data;
        if (json is Map<String, dynamic> && json['status'] == true) {
          _isCreating = false;
          notifyListeners();
          return true;
        } else {
          _errorMessage = json['message'] ?? 'Failed to create reminder';
        }
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
    }

    _isCreating = false;
    notifyListeners();
    return false;
  }

  // ---------- UPDATE REMINDER ----------
  Future<bool> updateReminder(Map<String, dynamic> payload) async {
    if (!await _connectivity.hasInternet()) {
      _errorMessage = 'No internet connection.';
      notifyListeners();
      return false;
    }

    _isUpdating = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) {
        _errorMessage = 'Authentication token not found.';
        _isUpdating = false;
        notifyListeners();
        return false;
      }

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      // Ensure ID is int (if it's string, parse)
      final id = payload['id'];
      payload['id'] = int.tryParse(id.toString()) ?? id;

      // Ensure category_id, type_id, reminder_before_id are ints
      if (payload.containsKey('category_id')) {
        payload['category_id'] = int.tryParse(payload['category_id'].toString()) ?? payload['category_id'];
      }
      if (payload.containsKey('type_id')) {
        payload['type_id'] = int.tryParse(payload['type_id'].toString()) ?? payload['type_id'];
      }
      if (payload.containsKey('reminder_before_id')) {
        final rbId = payload['reminder_before_id'];
        payload['reminder_before_id'] = rbId != null && rbId.toString().isNotEmpty
            ? int.tryParse(rbId.toString())
            : null;
      }

      // Add source if not present
      if (!payload.containsKey('source')) {
        payload['source'] = 'app-android';
      }

      final response = await _api.postWithProgress(
        ApiConfig.reminderUpdateUrl,
        data: payload,
        headers: headers,
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final json = response.data;
        if (json is Map<String, dynamic> && json['status'] == true) {
          _isUpdating = false;
          notifyListeners();
          return true;
        } else {
          _errorMessage = json['message'] ?? 'Failed to update reminder';
        }
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
    }

    _isUpdating = false;
    notifyListeners();
    return false;
  }

  // ---------- DELETE REMINDER ----------
  Future<bool> deleteReminder(String id) async {
    if (!await _connectivity.hasInternet()) {
      _errorMessage = 'No internet connection.';
      notifyListeners();
      return false;
    }

    _isDeleting = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) {
        _errorMessage = 'Authentication token not found.';
        _isDeleting = false;
        notifyListeners();
        return false;
      }

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final body = {
        'id': int.parse(id),
        'source': 'app-android',
      };

      final response = await _api.postWithProgress(
        ApiConfig.reminderDeleteUrl,
        data: body,
        headers: headers,
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final json = response.data;
        if (json is Map<String, dynamic> && json['status'] == true) {
          _isDeleting = false;
          notifyListeners();
          return true;
        } else {
          _errorMessage = json['message'] ?? 'Failed to delete reminder';
        }
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
    }

    _isDeleting = false;
    notifyListeners();
    return false;
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
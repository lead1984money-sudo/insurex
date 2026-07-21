import 'package:flutter/material.dart';
import '../../../data/modifiednetwork/ApiConfig.dart';
import '../../../data/modifiednetwork/ApiService.dart';
import '../../../data/network/ConnectivityService.dart';
import '../../../data/sharedpreferences/PreferenceManager.dart';
import '../model/notification_model.dart';


class NotificationProvider extends ChangeNotifier {
  final ConnectivityService _connectivity = ConnectivityService();
  final ApiService _api = ApiService();

  bool _isLoading = false;
  String _errorMessage = '';
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;

  // Operation flags (like in ReminderProvider)
  bool _isMarkingRead = false;
  bool _isMarkingAllRead = false;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isMarkingRead => _isMarkingRead;
  bool get isMarkingAllRead => _isMarkingAllRead;

  Future<String?> _getToken() async {
    final loginData = await PreferenceManager.getLoginData();
    return loginData?.token;
  }

  // Fetch inbox list
  Future<void> fetchNotifications() async {
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

      final body = {'source': 'app-android'}; // adjust as per API requirements

      final response = await _api.postWithProgress(
        ApiConfig.notificationListUrl,
        data: body,
        headers: headers,
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final json = response.data;
        if (json is Map<String, dynamic> && json['status'] == true) {
          _unreadCount = json['unread_count'] ?? 0;
          final List<dynamic> data = json['data'] ?? [];
          _notifications = data
              .map((item) => NotificationModel.fromJson(item))
              .toList();
        } else {
          _errorMessage = json['message'] ?? 'Failed to load notifications';
        }
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Mark a single notification as read
  Future<bool> markAsRead(String id) async {
    if (!await _connectivity.hasInternet()) {
      _errorMessage = 'No internet connection.';
      notifyListeners();
      return false;
    }

    _isMarkingRead = true;
    _errorMessage = '';
    notifyListeners();

    // Optimistic update
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index == -1) {
      _isMarkingRead = false;
      notifyListeners();
      return false;
    }
    final old = _notifications[index];
    if (old.read) {
      _isMarkingRead = false;
      notifyListeners();
      return true; // already read
    }

    _notifications[index] = old.copyWith(read: true);
    _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) {
        _errorMessage = 'Authentication token not found.';
        // Revert
        _notifications[index] = old;
        _unreadCount += 1;
        _isMarkingRead = false;
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
        ApiConfig.notificationMarkReadUrl,
        data: body,
        headers: headers,
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final json = response.data;
        if (json is Map<String, dynamic> && json['status'] == true) {
          _isMarkingRead = false;
          notifyListeners();
          return true;
        } else {
          _errorMessage = json['message'] ?? 'Failed to mark as read';
          // Revert
          _notifications[index] = old;
          _unreadCount += 1;
          _isMarkingRead = false;
          notifyListeners();
          return false;
        }
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
        // Revert
        _notifications[index] = old;
        _unreadCount += 1;
        _isMarkingRead = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      // Revert
      _notifications[index] = old;
      _unreadCount += 1;
      _isMarkingRead = false;
      notifyListeners();
      return false;
    }
  }

  // Mark all as read
  Future<bool> markAllAsRead() async {
    if (!await _connectivity.hasInternet()) {
      _errorMessage = 'No internet connection.';
      notifyListeners();
      return false;
    }

    final unreadIds = _notifications.where((n) => !n.read).map((n) => n.id).toList();
    if (unreadIds.isEmpty) {
      return true;
    }

    _isMarkingAllRead = true;
    _errorMessage = '';
    // Optimistic update: mark all as read
    final oldList = List<NotificationModel>.from(_notifications);
    _notifications = _notifications.map((n) => n.copyWith(read: true)).toList();
    final oldUnreadCount = _unreadCount;
    _unreadCount = 0;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) {
        _errorMessage = 'Authentication token not found.';
        // Revert
        _notifications = oldList;
        _unreadCount = oldUnreadCount;
        _isMarkingAllRead = false;
        notifyListeners();
        return false;
      }

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final body = {
        'ids': unreadIds.map((id) => int.parse(id)).toList(),
        'source': 'app-android',
      };

      final response = await _api.postWithProgress(
        ApiConfig.notificationMarkReadUrl, // or a separate "mark all" endpoint
        data: body,
        headers: headers,
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final json = response.data;
        if (json is Map<String, dynamic> && json['status'] == true) {
          _isMarkingAllRead = false;
          notifyListeners();
          return true;
        } else {
          _errorMessage = json['message'] ?? 'Failed to mark all as read';
          // Revert
          _notifications = oldList;
          _unreadCount = oldUnreadCount;
          _isMarkingAllRead = false;
          notifyListeners();
          return false;
        }
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
        // Revert
        _notifications = oldList;
        _unreadCount = oldUnreadCount;
        _isMarkingAllRead = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      // Revert
      _notifications = oldList;
      _unreadCount = oldUnreadCount;
      _isMarkingAllRead = false;
      notifyListeners();
      return false;
    }
  }

  // Refresh (pull-to-refresh)
  Future<void> refresh() => fetchNotifications();

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
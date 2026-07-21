import 'package:flutter/material.dart';
import '../../../data/modifiednetwork/ApiConfig.dart';
import '../../../data/modifiednetwork/ApiService.dart';
import '../../../data/network/ConnectivityService.dart';
import '../../../data/sharedpreferences/PreferenceManager.dart';            // adjust import

class ServiceProvider extends ChangeNotifier {
  final ConnectivityService _connectivity = ConnectivityService();
  final ApiService _api = ApiService();

  List<Map<String, dynamic>> _menuItems = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<Map<String, dynamic>> get menuItems => _menuItems;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<String?> _getToken() async {
    final loginData = await PreferenceManager.getLoginData();
    return loginData?.token;
  }

  Future<void> fetchAppMenu() async {
    // Check internet
    if (!await _connectivity.hasInternet()) {
      _errorMessage = 'No internet connection.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Get token (if needed by your API, otherwise you can skip this)
      final token = await _getToken();
      // Build headers – include token only if available
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final body = {'source': 'app-android'}; // note the spelling used in your example

      final response = await _api.postWithProgress(
        ApiConfig.menuListUrl,
        data: body,
        headers: headers,
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final json = response.data;
        if (json is Map<String, dynamic> && json['status'] == true) {
          final List<dynamic> allItems = json['data'] ?? [];
          // Filter: appDisplay == 1 AND status == 1

          print("LiST SIZE"+allItems.length.toString());

          _menuItems = allItems
              .where((item) => item['appDisplay'] == 1 && item['status'] == 1)
              .map((item) => Map<String, dynamic>.from(item))
              .toList();


          _errorMessage = '';
        } else {
          _errorMessage = json['message'] ?? 'Failed to load menu';
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

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
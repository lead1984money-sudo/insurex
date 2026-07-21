// legal_provider.dart
import 'package:flutter/material.dart';

import '../../../data/modifiednetwork/ApiConfig.dart';
import '../../../data/modifiednetwork/ApiService.dart';
import '../../../data/network/ConnectivityService.dart';
import '../../../data/sharedpreferences/PreferenceManager.dart';

class LegalProvider extends ChangeNotifier {
  final ConnectivityService _connectivity = ConnectivityService();
  final ApiService _api = ApiService();

  bool _isLoading = false;
  String _error = '';
  Map<String, dynamic>? _data; // holds the response data

  bool get isLoading => _isLoading;
  String get error => _error;
  Map<String, dynamic>? get data => _data;

  /// Fetch legal content by slug (e.g., 'privacy_policy', 'terms_conditions')
  Future<void> fetchLegalContent() async {
    if (!await _connectivity.hasInternet()) {
      _error = 'No internet connection.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = '';
    _data = null;
    notifyListeners();

    try {
      final token = await _getToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) headers['Authorization'] = 'Bearer $token';

      final body = {
        'source': 'app-android',
        "slug": "about_us"

        // if the API needs a slug param, add it here; currently it's fixed
      };

      final response = await _api.postWithProgress(
        ApiConfig.aboutUsUrl,
        data: body,
        headers: headers,
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final json = response.data;
        if (json is Map<String, dynamic> && json['status'] == true) {
          // The actual content is inside 'data'
          _data = json['data'] as Map<String, dynamic>?;
          if (_data == null) {
            _error = 'No content found.';
          }
        } else {
          _error = json['message'] ?? 'Failed to load content.';
        }
      } else {
        _error = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchPrivacyPolicyContent() async {
    if (!await _connectivity.hasInternet()) {
      _error = 'No internet connection.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = '';
    _data = null;
    notifyListeners();

    try {
      final token = await _getToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) headers['Authorization'] = 'Bearer $token';

      final body = {
        'source': 'app-android',


        // if the API needs a slug param, add it here; currently it's fixed
      };

      final response = await _api.postWithProgress(
        ApiConfig.privacyUrl,
        data: body,
        headers: headers,
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final json = response.data;
        if (json is Map<String, dynamic> && json['status'] == true) {
          // The actual content is inside 'data'
          _data = json['data'] as Map<String, dynamic>?;
          if (_data == null) {
            _error = 'No content found.';
          }
        } else {
          _error = json['message'] ?? 'Failed to load content.';
        }
      } else {
        _error = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error: $e';
    }

    _isLoading = false;
    notifyListeners();
  }


  Future<void> fetchTermContent() async {
    if (!await _connectivity.hasInternet()) {
      _error = 'No internet connection.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = '';
    _data = null;
    notifyListeners();

    try {
      final token = await _getToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) headers['Authorization'] = 'Bearer $token';

      final body = {
        'source': 'app-android',
      };

      final response = await _api.postWithProgress(
        ApiConfig.termUrl,
        data: body,
        headers: headers,
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final json = response.data;
        if (json is Map<String, dynamic> && json['status'] == true) {
          // The actual content is inside 'data'
          _data = json['data'] as Map<String, dynamic>?;
          if (_data == null) {
            _error = 'No content found.';
          }
        } else {
          _error = json['message'] ?? 'Failed to load content.';
        }
      } else {
        _error = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error: $e';
    }

    _isLoading = false;
    notifyListeners();
  }


  Future<void> fetchContactSupport() async {
    if (!await _connectivity.hasInternet()) {
      _error = 'No internet connection.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = '';
    _data = null;
    notifyListeners();

    try {
      final token = await _getToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) headers['Authorization'] = 'Bearer $token';

      final body = {
        'source': 'app-android',
      };

      final response = await _api.postWithProgress(
        ApiConfig.contactSupportUrl,
        data: body,
        headers: headers,
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final json = response.data;
        if (json is Map<String, dynamic> && json['status'] == true) {
          // The actual content is inside 'data'
          _data = json['data'] as Map<String, dynamic>?;
          if (_data == null) {
            _error = 'No content found.';
          }
        } else {
          _error = json['message'] ?? 'Failed to load content.';
        }
      } else {
        _error = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error: $e';
    }

    _isLoading = false;
    notifyListeners();
  }




  Future<String?> _getToken() async {
    final loginData = await PreferenceManager.getLoginData();
    return loginData?.token;
  }
}
import 'package:flutter/material.dart';
import 'package:pdf_read/data/modifiednetwork/ApiConfig.dart';
import 'package:pdf_read/data/modifiednetwork/ApiService.dart';
import 'package:pdf_read/data/network/ConnectivityService.dart';
import 'package:pdf_read/data/sharedpreferences/PreferenceManager.dart';
import '../model/plan_model.dart';



class PlanProvider extends ChangeNotifier {
  final ConnectivityService _connectivity = ConnectivityService();
  final ApiService _api = ApiService();

  List<Plan> _plans = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String _strbuyNowFalseMessage = '';

  List<Plan> get plans => _plans;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get strbuyNowFalseMessage => _strbuyNowFalseMessage;

  Future<String?> _getToken() async {
    final loginData = await PreferenceManager.getLoginData();
    return loginData?.token;
  }

  Future<void> fetchPlans() async {
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

      final body = {'source': 'app-android'};
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final response = await _api.postWithProgress(
        ApiConfig.planListUrl, // add this constant
        data: body,
        headers: headers,
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final json = response.data;
        if (json is Map<String, dynamic> && json['status'] == true) {
          final result = PlanResponse.fromJson(json);
          _plans = result.data;
          _strbuyNowFalseMessage = result.buyNowFalseMessage;
          _errorMessage = '';
        } else {
          _errorMessage = json['message'] ?? 'Failed to load plans';
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
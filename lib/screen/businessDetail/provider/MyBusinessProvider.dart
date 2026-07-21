// lib/screen/businessDetail/provider/PolicyProvider.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../data/modifiednetwork/ApiConfig.dart';
import '../../../data/modifiednetwork/ApiService.dart';
import '../../../data/network/ConnectivityService.dart';

class MyBusinessProvider extends ChangeNotifier {
  final ConnectivityService _connectivity = ConnectivityService();
  final ApiService _api = ApiService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // ─── Top-level fields ───────────────────────────────────────────
  int? _lobId;
  int? get lobId => _lobId;

  String _lobName = '';
  String get lobName => _lobName;

  String? _productName;
  String? get productName => _productName;

  String _proposerName = '';
  String get proposerName => _proposerName;

  String _policyNo = '';
  String get policyNo => _policyNo;

  String? _vehicleNo;
  String? get vehicleNo => _vehicleNo;

  String _insurerName = '';
  String get insurerName => _insurerName;

  String? _reasonFail;
  String? get reasonFail => _reasonFail;

  bool _isFailed = false;
  bool get isFailed => _isFailed;

  int? _policyStatus;
  int? get policyStatus => _policyStatus;

  String _startDate = '';
  String get startDate => _startDate;

  String _endDate = '';
  String get endDate => _endDate;

  // ─── Log and response data ──────────────────────────────────────
  Map<String, dynamic>? _logData;
  Map<String, dynamic>? get logData => _logData;

  Map<String, dynamic>? _responseJson;
  Map<String, dynamic>? get responseJson => _responseJson;

  // ─── Fetch details ──────────────────────────────────────────────
  Future<void> fetchBusinessDetails({
    required String token,
    required int srMasterId, // pass the ID from previous screen
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      if (!await _connectivity.hasInternet()) {
        _errorMessage = 'No internet connection.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final dio = _api.dio;
      if (dio == null) throw Exception('Dio client not available.');

      final headers = {'Authorization': 'Bearer $token'};
      final body = {
        'sr_master_id': srMasterId,
        'source': 'app-android',
      };

      final response = await dio.post(
        ApiConfig.businessDetailsUrl,
        data: body,
        options: Options(headers: headers),
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final json = response.data as Map<String, dynamic>;
        if (json['status'] == true) {
          // Top-level fields
          _lobId = json['lob_id'];
          _lobName = json['lob_name'] ?? '';
          _productName = json['product_name'];
          _proposerName = json['proposer_name'] ?? '';
          _policyNo = json['policy_no'] ?? '';
          _vehicleNo = json['vehicle_no'];
          _insurerName = json['insurer_name'] ?? '';
          _reasonFail = json['reason_fail'];
          _isFailed = json['is_failed'] ?? false;
          _policyStatus = json['policy_status'];
          _startDate = json['start_date'] ?? '';
          _endDate = json['end_date'] ?? '';

          // Nested data
          final data = json['data'] as Map<String, dynamic>?;
          if (data != null) {
            _logData = data['log'] as Map<String, dynamic>?;
            _responseJson = data['response_json'] as Map<String, dynamic>?;
          }

          _isLoading = false;
          notifyListeners();
          return;
        } else {
          throw Exception(json['message'] ?? 'Failed to fetch details');
        }
      } else {
        throw Exception('Server error (${response.statusCode})');
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Helper to get a formatted value from response_json ────────
  String getResponseValue(String key, {String defaultValue = 'N/A'}) {
    if (_responseJson == null) return defaultValue;
    return _responseJson![key]?.toString() ?? defaultValue;
  }

  void reset() {
    _isLoading = false;
    _errorMessage = '';
    _logData = null;
    _responseJson = null;
    _lobId = null;
    _lobName = '';
    _productName = null;
    _proposerName = '';
    _policyNo = '';
    _vehicleNo = null;
    _insurerName = '';
    _reasonFail = null;
    _isFailed = false;
    _policyStatus = null;
    _startDate = '';
    _endDate = '';
    notifyListeners();
  }
}
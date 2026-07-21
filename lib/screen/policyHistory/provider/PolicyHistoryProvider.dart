import 'package:flutter/cupertino.dart';
import '../../../data/modifiednetwork/ApiConfig.dart';
import '../../../data/modifiednetwork/ApiService.dart';
import '../../../data/network/ConnectivityService.dart';
import '../../../data/sharedpreferences/PreferenceManager.dart';
import '../../myBusiness/model/policy_model.dart';

class PolicyHistoryProvider with ChangeNotifier {
  final ConnectivityService _connectivity = ConnectivityService();
  final ApiService _api = ApiService();

  List<PolicyData> _policies = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  int _totalPages = 1;
  String _errorMessage = '';
  String _currentFilter = 'all'; // 'all', 'success', 'fail'

  // Getters
  List<PolicyData> get policies => _policies;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String get errorMessage => _errorMessage;

  // ─── Token helper ──────────────────────────────────────────────
  Future<String?> _getToken() async {
    final loginData = await PreferenceManager.getLoginData();
    return loginData?.token;
  }

  // ─── Fetch policies (with filter) ─────────────────────────────
  Future<void> fetchPolicies({bool refresh = true}) async {
    if (!await _connectivity.hasInternet()) {
      _errorMessage = 'No internet connection.';
      notifyListeners();
      return;
    }

    if (refresh) {
      _policies.clear();
      _currentPage = 1;
      _hasMore = true;
      _errorMessage = '';
    }

    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) {
        _errorMessage = 'Authentication token not found. Please login again.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // ✅ Include the filter type in the request body
      final body = {
        'page': _currentPage,
        'limit': 10,
        'source': 'app-android',
        'type': _currentFilter, // 'all', 'success', or 'fail'
      };

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final response = await _api.postWithProgress(
        ApiConfig.policyListUrl,
        data: body,
        headers: headers,
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final json = response.data;
        if (json is Map<String, dynamic> && json['status'] == true) {
          final result = PolicyListResponse.fromJson(json);
          _policies.addAll(result.data);
          _totalPages = result.pagination.totalPages;
          _hasMore = _currentPage < _totalPages;
          _currentPage++;
          _errorMessage = '';
        } else {
          _errorMessage = json['message'] ?? 'Failed to load policies';
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

  // ─── Load more ──────────────────────────────────────────────────
  Future<void> loadMore() async {
    if (_hasMore && !_isLoading) {
      await fetchPolicies(refresh: false);
    }
  }

  // ─── Change filter → reset and fetch ──────────────────────────
  void setFilter(String filter) {
    if (_currentFilter == filter) return;
    _currentFilter = filter;
    // Reset pagination and fetch fresh data
    fetchPolicies(refresh: true);
  }

  // ─── Get signed file URL ──────────────────────────────────────
  Future<String?> getFileUrl(String fileUrl, String type) async {
    if (!await _connectivity.hasInternet()) {
      _errorMessage = 'No internet connection.';
      notifyListeners();
      return null;
    }

    try {
      final token = await _getToken();
      if (token == null) {
        _errorMessage = 'Authentication token not found.';
        notifyListeners();
        return null;
      }

      final body = {
        'url': fileUrl,
        'type': type,
        'source': 'app-android',
      };

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final response = await _api.postWithProgress(
        ApiConfig.downloadPolicyUrl,
        data: body,
        headers: headers,
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final json = response.data;
        if (json is Map<String, dynamic> && json['status'] == true) {
          final url = json['data']['url'] as String?;
          return url;
        } else {
          _errorMessage = json['message'] ?? 'Failed to get file URL';
          return null;
        }
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
        return null;
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      return null;
    }
  }

  // ─── Utility ────────────────────────────────────────────────────
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
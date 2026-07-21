// lib/screen/transaction/provider/TransactionProvider.dart
import 'package:flutter/material.dart';
import 'package:pdf_read/screen/transaction/model/TransactionResponse.dart';
import '../../../data/modifiednetwork/ApiConfig.dart';
import '../../../data/modifiednetwork/ApiService.dart';
import '../../../data/network/ConnectivityService.dart';
import '../../../data/sharedpreferences/PreferenceManager.dart';

class TransactionProvider extends ChangeNotifier {
  final ConnectivityService _connectivity = ConnectivityService();
  final ApiService _api = ApiService();

  List<Transaction> _transactions = [];
  Stats? _stats;
  Pagination? _pagination;
  bool _isLoading = false;
  String _errorMessage = '';
  int _currentPage = 1;
  final int _limit = 10;
  String _search = '';
  List<String> _statusFilters = ['completed', 'pending', 'failed'];
  String _source = 'app-android';
  String _id = '';
  int _requestId = 0; // for ignoring stale responses

  // --- Getters ---
  List<Transaction> get transactions => _transactions;
  Stats? get stats => _stats;
  Pagination? get pagination => _pagination;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  String get search => _search;
  List<String> get statusFilters => _statusFilters;

  // --- Setters (trigger fetch) ---
  void setSearch(String value) {
    if (_search != value) {
      _search = value;
      _currentPage = 1;
      _transactions.clear();
      fetchTransactions(refresh: true);
    }
  }

  void toggleStatusFilter(String status) {
    if (_statusFilters.contains(status)) {
      _statusFilters.remove(status);
    } else {
      _statusFilters.add(status);
    }
    // ✅ No auto‑reset – empty list is allowed
    _currentPage = 1;
    _transactions.clear();
    fetchTransactions(refresh: true);
  }

  void selectAllFilters() {
    _statusFilters = ['completed', 'pending', 'failed'];
    _currentPage = 1;
    _transactions.clear();
    fetchTransactions(refresh: true);
  }

  void setSource(String source) {
    _source = source;
    _currentPage = 1;
    _transactions.clear();
    fetchTransactions(refresh: true);
  }

  // --- Main fetch with request ID ---
  Future<void> fetchTransactions({bool refresh = false}) async {
    // Connectivity
    if (!await _connectivity.hasInternet()) {
      _errorMessage = 'No internet connection.';
      _isLoading = false;
      notifyListeners();
      return;
    }

    if (_isLoading && !refresh) return;
    if (!refresh && _pagination != null && _currentPage > _pagination!.totalPages) {
      return;
    }

    final int currentRequestId = ++_requestId;

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final token = await _getToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final body = <String, dynamic>{
        'page': _currentPage,
        'limit': _limit,
        'search': _search,
        'source': _source,
        'id': _id,
      };
      // Only add filters if list is not empty
      if (_statusFilters.isNotEmpty) {
        body['status_filters'] = _statusFilters;
      }

      final response = await _api.postWithProgress(
        ApiConfig.transactionListUrl,
        data: body,
        headers: headers,
      );

      // Ignore stale response
      if (currentRequestId != _requestId) return;

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final json = response.data;
        if (json is Map<String, dynamic> && json['status'] == true) {
          final transactionResponse = TransactionResponse.fromJson(json);
          if (refresh) {
            _transactions = transactionResponse.data;
          } else {
            _transactions.addAll(transactionResponse.data);
          }
          _stats = transactionResponse.stats;
          _pagination = transactionResponse.pagination;
          _currentPage = transactionResponse.pagination.page + 1;
          _errorMessage = '';
        } else {
          _errorMessage = json['message'] ?? 'Failed to load transactions.';
        }
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      if (currentRequestId != _requestId) return;
      _errorMessage = 'Error: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  // --- Pagination ---
  Future<void> loadMore() async {
    if (_pagination != null && _currentPage <= _pagination!.totalPages) {
      await fetchTransactions();
    }
  }

  // --- Refresh ---
  Future<void> refresh() async {
    _currentPage = 1;
    _transactions.clear();
    await fetchTransactions(refresh: true);
  }

  // --- Error clear ---
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  void resetState() {
    _currentPage = 1;
    _search = '';
    _statusFilters = ['completed', 'pending', 'failed'];
    _transactions.clear();
    _pagination = null;
    _stats = null;
    _errorMessage = '';
    notifyListeners();
  }

  // --- Token helper ---
  Future<String?> _getToken() async {
    final loginData = await PreferenceManager.getLoginData();
    return loginData?.token;
  }
}
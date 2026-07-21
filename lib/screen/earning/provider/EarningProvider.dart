import 'package:flutter/material.dart';
import '../../../data/modifiednetwork/ApiConfig.dart';
import '../../../data/modifiednetwork/ApiService.dart';
import '../../../data/network/ConnectivityService.dart';
import '../../../data/sharedpreferences/PreferenceManager.dart';
import '../model/EarningItem.dart';
import '../model/PolicyItem.dart';



class EarningsProvider extends ChangeNotifier {
  final ConnectivityService _connectivity = ConnectivityService();
  final ApiService _api = ApiService();

  // ----- Data -----
  List<EarningItem> _earnings = [];
  List<PartnerItem> _partners = [];

  // ----- Stats -----
  double _grossAmount = 0;
  double _cashback = 0;
  double _netEarning = 0;
  int _activeRecords = 0;

  // ----- Filters -----
  String _selectedStatus = 'All Status';
  String _selectedPartner = 'All Partners';
  int? _selectedPartnerId; // for API filter
  final TextEditingController _searchController = TextEditingController();

  // ----- Pagination -----
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;
  int _limit = 10;

  // ----- Loading & Error -----
  bool _isLoading = false;
  String _errorMessage = '';

  // ----- Getters -----
  List<EarningItem> get earnings => _earnings;
  List<PartnerItem> get partners => _partners;

  double get grossAmount => _grossAmount;
  double get cashback => _cashback;
  double get netEarning => _netEarning;
  int get activeRecords => _activeRecords;

  String get selectedStatus => _selectedStatus;
  String get selectedPartner => _selectedPartner;
  TextEditingController get searchController => _searchController;

  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalItems => _totalItems;
  int get limit => _limit;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;


  List<PolicyItem> _policies = [];
  List<PolicyItem> get policies => _policies;

  Future<void> fetchPolicies({String search = '', int? id }) async {
    // Same implementation as in EarningAddProvider
    // (you can extract the common logic to a separate service)
    if (!await _connectivity.hasInternet()) {
      _errorMessage = 'No internet connection.';
      notifyListeners();
      return;
    }

    try {
      final token = await _getToken();
      if (token == null) return;

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
      final body = {'source': 'app-android', 'search': search,'policy_id':id};

      final response = await _api.postWithProgress(
        ApiConfig.searchPoliciesUrl,
        data: body,
        headers: headers,
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final json = response.data;
        if (json is Map<String, dynamic> && json['status'] == true) {
          final List data = json['data'] ?? [];
          _policies = data.map((item) => PolicyItem.fromJson(item)).toList();
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
    notifyListeners();
  }




  // ----- Setters -----
  void updateStatus(String value) {
    if (_selectedStatus != value) {
      _selectedStatus = value;
      _currentPage = 1;
      _fetchEarnings();
    }
  }

  void updatePartner(String value) {
    if (_selectedPartner != value) {
      _selectedPartner = value;
      // Find partner id from the list
      final partner = _partners.firstWhere(
            (p) => p.name == value,
        orElse: () => PartnerItem(id: 0, name: '', email: '', mobile: ''),
      );
      _selectedPartnerId = partner.id == 0 ? null : partner.id;
      _currentPage = 1;
      _fetchEarnings();
    }
  }

  void onSearchChanged(String value) {
    _currentPage = 1;
    _fetchEarnings();
  }

  void resetFilter() {
    _selectedStatus = 'All Status';
    _selectedPartner = 'All Partners';
    _selectedPartnerId = null;
    _searchController.clear();
    _currentPage = 1;
    _fetchEarnings();
  }

  void goToPage(int page) {
    if (page >= 1 && page <= _totalPages && page != _currentPage) {
      _currentPage = page;
      _fetchEarnings();
    }
  }

  void changeLimit(int newLimit) {
    if (_limit != newLimit) {
      _limit = newLimit;
      _currentPage = 1;
      _fetchEarnings();
    }
  }

  // ----- API Calls -----
  Future<String?> _getToken() async {
    final loginData = await PreferenceManager.getLoginData();
    return loginData?.token;
  }

  Future<void> _fetchEarnings() async {
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

      // Prepare status filter
      List<int> statusFilter = [];
      if (_selectedStatus == 'Active') statusFilter = [1];
      else if (_selectedStatus == 'Inactive') statusFilter = [0];
      // else 'All Status' => empty list means all

      // Partner IDs filter
      List<int> partnerIds = [];
      if (_selectedPartnerId != null) partnerIds = [_selectedPartnerId!];

      final body = {
        'source': 'app-android',
        'page': _currentPage,
        'limit': _limit,
        'search': _searchController.text.trim(),
        'status': statusFilter,
        'partner_ids': partnerIds,
        'user_ids': [],
        'date_from': '',
        'date_to': '',
      };

      final response = await _api.postWithProgress(
        ApiConfig.earningsListUrl,
        data: body,
        headers: headers,
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final json = response.data;
        if (json is Map<String, dynamic> && json['status'] == true) {
          final result = EarningsListResponse.fromJson(json);
          _earnings = result.data;

          print("LINE180>>" +_earnings.length.toString());
          _totalItems = result.pagination.total;
          _totalPages = result.pagination.totalPages;
          _grossAmount = result.stats.totalPayIn;
          _cashback = result.stats.totalCashback;
          _netEarning = result.stats.totalEarning;
          _activeRecords = result.stats.active;
          _errorMessage = '';
        } else {
          _errorMessage = json['message'] ?? 'Failed to load earnings';
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

  // Fetch partners for dropdown
  Future<void> fetchPartners() async {
    if (!await _connectivity.hasInternet()) {
      _errorMessage = 'No internet connection.';
      notifyListeners();
      return;
    }



    try {
      final token = await _getToken();
      if (token == null) return;

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final body = {
        'source': 'app-android',
        'page': 1,
        'limit': 100,
        'search': '',
        'status': [1],
        'date_from': '',
        'date_to': '',
        'user_ids': [],
      };

      final response = await _api.postWithProgress(
        ApiConfig.partnerListUrl,
        data: body,
        headers: headers,
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final json = response.data;
        if (json is Map<String, dynamic> && json['status'] == true) {
          final List data = json['data'] ?? [];
          _partners = data.map((item) => PartnerItem.fromJson(item)).toList();
        }
      }
    } catch (e) {
      // ignore, fallback to empty list
    }
  }

  // Initial fetch
  Future<void> init() async {
    await fetchPartners();
    await _fetchEarnings();
   // await fetchPolicies();
  }

  // ---- dispose ----
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}